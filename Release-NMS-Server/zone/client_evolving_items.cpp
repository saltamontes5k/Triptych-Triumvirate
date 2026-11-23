#include "../common/evolving_items.h"

#include <unordered_set>

#include "../common/events/player_event_logs.h"
#include "../common/global_define.h"

#include "client.h"
#include "string_ids.h"
#include "worldserver.h"

extern WorldServer worldserver;
extern QueryServ*  QServ;
const std::string  SUB_TYPE_DELIMITER = ".";

void Client::DoEvolveItemToggle(const EQApplicationPacket *app)
{
	const auto in   = reinterpret_cast<EvolveItemToggle *>(app->pBuffer);
	auto       item = CharacterEvolvingItemsRepository::FindOne(database, in->unique_id);

	// The RoF2 client fills only the low byte of the activated dword; the
	// other three bytes are whatever was in its packet buffer (an ON request
	// for uid 30 arrived as 0x2DA87601). Reading the dword raw made every
	// non-zero high byte an ON, so a "turn it off" request carrying
	// 0x2DA87600 would still store 1. Only the low byte is the boolean.
	const bool requested_active = (in->activated & 0xFF) != 0;

	LogEvolveItemDetail(
		"Character ID <green>[{}] requested to set evolve item with unique id <yellow>[{}] to status <yellow>[{}] (raw <yellow>[{}])",
		CharacterID(),
		in->unique_id,
		requested_active ? 1 : 0,
		in->activated
	);

	if (!item.id) {
		LogEvolveItemDetail(
			"Character ID <green>[{}] toggle evolve item unique id <yellow>[{}] failed", CharacterID(), in->unique_id);
		return;
	}

	const bool was_active = item.activated != 0;
	item.activated        = requested_active ? 1 : 0;

	// Activation cap: keep at most MaxActiveEvolvingItems live items. Turning
	// one on while at the cap makes room by deactivating the least-progressed
	// active item (never the one being turned on, never a final-tier item).
	const int active_cap = RuleI(EvolvingItems, MaxActiveEvolvingItems);
	if (item.activated && !was_active && active_cap > 0) {
		for (int guard = 0; guard < 64 && CountActiveEvolvingItems(item.id) >= active_cap; ++guard) {
			auto victim = FindLeastProgressedActiveEvolvingItem(item.id);
			if (!victim.id) {
				break;
			}

			victim.activated = 0;
			CharacterEvolvingItemsRepository::ReplaceOne(database, victim);
			SetEvolvingItemActivatedForItem(victim.item_id, false);
			SendEvolvingPacket(EvolvingItems::Actions::UPDATE_ITEMS, victim);

			const auto *victim_def = database.GetItem(victim.item_id);
			Message(
				Chat::Yellow,
				"%s was deactivated - you can keep %i evolving item%s active at a time.",
				victim_def ? victim_def->Name : "An evolving item",
				active_cap,
				active_cap == 1 ? "" : "s"
			);
			LogEvolveItem(
				"Character ID <green>[{}] hit the evolving cap [{}] - deactivated item id [{}] uid [{}]",
				CharacterID(),
				active_cap,
				victim.item_id,
				victim.id
			);
		}
	}

	// The item may be a socketed augment, which HasItem cannot find; search
	// worn aug sockets as well before giving up (a stale row must not crash).
	const int16 inst_slot = GetInv().HasItem(item.item_id);
	EQ::ItemInstance *inst = (inst_slot != INVALID_INDEX) ? GetInv().GetItem(inst_slot) : nullptr;
	if (!inst) {
		for (auto &[worn_slot, worn_inst]: GetInv().GetWorn()) {
			if (!worn_inst) {
				continue;
			}
			for (uint8 s = EQ::invaug::SOCKET_BEGIN; s <= EQ::invaug::SOCKET_END; s++) {
				EQ::ItemInstance *aug = worn_inst->GetAugment(s);
				if (aug && aug->GetID() == item.item_id) {
					inst = aug;
					break;
				}
			}
			if (inst) {
				break;
			}
		}
	}

	if (inst) {
		inst->SetEvolveActivated(item.activated ? true : false);
	}
	else {
		Message(Chat::Yellow, "You are no longer carrying that item - activation saved for when you next hold it.");
	}

	CharacterEvolvingItemsRepository::ReplaceOne(database, item);

	SendEvolvingPacket(EvolvingItems::Actions::UPDATE_ITEMS, item);
}

void Client::SendEvolvingPacket(const int8 action, const CharacterEvolvingItemsRepository::CharacterEvolvingItems &item)
{
	auto       out  = std::make_unique<EQApplicationPacket>(OP_EvolveItem, sizeof(EvolveItemToggle));
	const auto data = reinterpret_cast<EvolveItemToggle *>(out->pBuffer);

	LogEvolveItemDetail(
		"Character ID <green>[{}] requested info for evolving item with unique id <yellow>[{}] status <yellow>[{}] "
		"percentage <yellow>[{}]",
		CharacterID(),
		item.id,
		item.activated,
		item.progression
	);

	data->action     = action;
	// The stock client never reads unknown_004; our dll uses it to name the
	// item an evolving id belongs to (a socketed augment is not in the client's
	// uid map, and the item packet carries augments as bare item ids).
	data->unknown_004 = item.item_id;
	data->unique_id  = item.id;
	data->percentage = item.progression;
	data->activated  = item.activated;

	QueuePacket(out.get());

	LogEvolveItem(
		"Sent evolve item with unique id <yellow>[{}] status <yellow>[{}] percentage <yellow>[{}] to Character ID "
		"<green>[{}]",
		data->unique_id,
		data->activated,
		data->percentage,
		CharacterID()
	);
}

// --- activation cap --------------------------------------------------------
// Only items that can still earn progression occupy a slot; a final-tier item
// (EvolvingLevel >= EvolvingMax) is skipped by the accrual path and is dead
// weight, so it never counts against the cap.

int Client::CountActiveEvolvingItems(uint64 exclude_id)
{
	auto rows = CharacterEvolvingItemsRepository::GetWhere(
		database,
		fmt::format(
			"`character_id` = {} AND `activated` = 1 AND `deleted_at` IS NULL",
			CharacterID()
		)
	);

	int count = 0;
	for (const auto &row : rows) {
		if (exclude_id && row.id == exclude_id) {
			continue;
		}

		const auto *def = database.GetItem(row.item_id);
		if (!def || def->EvolvingLevel >= def->EvolvingMax) {
			continue;
		}

		++count;
	}

	return count;
}

CharacterEvolvingItemsRepository::CharacterEvolvingItems
Client::FindLeastProgressedActiveEvolvingItem(uint64 exclude_id)
{
	auto rows = CharacterEvolvingItemsRepository::GetWhere(
		database,
		fmt::format(
			"`character_id` = {} AND `activated` = 1 AND `deleted_at` IS NULL",
			CharacterID()
		)
	);

	auto victim = CharacterEvolvingItemsRepository::NewEntity();
	bool found  = false;

	for (const auto &row : rows) {
		if (exclude_id && row.id == exclude_id) {
			continue;
		}

		const auto *def = database.GetItem(row.item_id);
		if (!def || def->EvolvingLevel >= def->EvolvingMax) {
			continue;
		}

		if (!found || row.progression < victim.progression) {
			victim = row;
			found  = true;
		}
	}

	return victim;
}

void Client::SetEvolvingItemActivatedForItem(uint32 item_id, bool activated)
{
	const int16 inst_slot = GetInv().HasItem(item_id);
	EQ::ItemInstance *inst = (inst_slot != INVALID_INDEX) ? GetInv().GetItem(inst_slot) : nullptr;

	if (!inst) {
		for (auto &[worn_slot, worn_inst]: GetInv().GetWorn()) {
			if (!worn_inst) {
				continue;
			}

			for (uint8 s = EQ::invaug::SOCKET_BEGIN; s <= EQ::invaug::SOCKET_END; s++) {
				EQ::ItemInstance *aug = worn_inst->GetAugment(s);
				if (aug && aug->GetID() == item_id) {
					inst = aug;
					break;
				}
			}

			if (inst) {
				break;
			}
		}
	}

	if (inst) {
		inst->SetEvolveActivated(activated);
	}
}

// Characters that predate the cap can log in with more active rows than it
// allows; reset them all so the player chooses again from a clean slate.
void Client::NormalizeEvolvingItemActivation()
{
	const int cap = RuleI(EvolvingItems, MaxActiveEvolvingItems);

	// Tell our dinput8 dll which listing bound the Evolution tab uses this
	// zone-in: bound 22 (worn + their socketed augs) when
	// EvolvingItems:TabExcludeInventoryItems is set, the whole item array
	// otherwise. TAB_CONFIG is swallowed by the dll's evolve tap; the stock
	// client handler never sees this action.
	{
		auto out        = std::make_unique<EQApplicationPacket>(OP_EvolveItem, sizeof(EvolveItemToggle));
		const auto data = reinterpret_cast<EvolveItemToggle *>(out->pBuffer);
		data->action     = EvolvingItems::Actions::TAB_CONFIG;
		data->unique_id  = 0;
		data->percentage = RuleB(EvolvingItems, TabExcludeInventoryItems) ? 1 : 0;
		QueuePacket(out.get());
	}

	auto rows = CharacterEvolvingItemsRepository::GetWhere(
		database,
		fmt::format("`character_id` = {} AND `deleted_at` IS NULL", CharacterID())
	);

	int cleared = 0;
	if (cap > 0 && CountActiveEvolvingItems() > cap) {
		for (auto &row : rows) {
			if (!row.activated) {
				continue;
			}

			row.activated = 0;
			CharacterEvolvingItemsRepository::ReplaceOne(database, row);
			SetEvolvingItemActivatedForItem(row.item_id, false);
			++cleared;
		}
	}

	// Publish every row's state, not just the cleared ones: the client's
	// per-item activated byte is set from the zone-in item packets, and a stale
	// "1" makes an inactive item read "Active: yes" (and stay tinted) until
	// something pushes the truth.
	for (auto &row : rows) {
		SendEvolvingPacket(EvolvingItems::Actions::UPDATE_ITEMS, row);
	}

	if (cleared) {
		Message(
			Chat::Yellow,
			"Your evolving items were deactivated. Activate up to %i at a time.",
			cap
		);
		LogEvolveItem(
			"Character ID <green>[{}] logged in with [{}] active evolving items (cap [{}]) - all deactivated",
			CharacterID(),
			cleared,
			cap
		);
	}
}

// Per-instance accrual for one evolving item - a worn item or a socketed
// augment. Called by ProcessEvolvingItem for both.
void Client::ProcessEvolvingInstance(
	EQ::ItemInstance *inst,
	const uint64 exp,
	const Mob *mob,
	std::vector<EQ::ItemInstance *> &queue
)
{
	if (!inst) {
		return;
	}

	if (!inst->IsEvolving() || !inst->GetEvolveActivated()) {
		// The activation cap leaves most worn rows deactivated, and this gate
		// dropped them with no zone-log line at all - invisible to accrual
		// diagnosis. Log the first skip per instance serial (evolving items
		// only; non-evolving worn items are not part of this system).
		if (inst->IsEvolving()) {
			static std::unordered_set<uint32> skip_logged;
			if (skip_logged.size() > 4096) {
				skip_logged.clear();
			}
			if (skip_logged.insert(inst->GetSerialNumber()).second) {
				LogInfo("EVOACC item [{}] serial [{}] char [{}] uid [{}] SKIP evo [1] act [{}]",
					inst->GetID(), inst->GetSerialNumber(), CharacterID(),
					inst->GetEvolveUniqueID(), inst->GetEvolveActivated() ? 1 : 0);
			}
		}
		return;
	}

	// EvolvingItems:DelayUponEquipping is a one-shot window after the item is
	// equipped (or zoned in), not a per-gain cooldown. Several inventory paths
	// re-mark worn items (SetEvolveEquipped(false) then (true)), which re-arms
	// the timer on the same instance - observed re-arming inside the same
	// second as a successful gain. Gating every kill on the timer therefore
	// held each item to one gain per 30 s, and a stage-2 item (1/10 of the
	// stage-1 energy) never visibly moved. Latch the window once it has
	// elapsed for this instance; after that the item gains on every
	// qualifying kill. A fresh instance (login, zone-in, evolved tier) starts
	// unlatched and still waits the full delay.
	if (!inst->GetEvolveDelaySatisfied()) {
		if (inst->GetTimers().contains("evolve") && !inst->GetTimers().at("evolve").Check(false)) {
			return;
		}
		inst->SetEvolveDelaySatisfied(true);
	}

	if (!EvolvingItemsManager::Instance()->GetEvolvingItemsCache().contains(inst->GetID())) {
		LogEvolveItem(
			"Character ID {} has an evolving item that is not found in the db. Please check your "
			"items_evolving_details table for item id {}",
			CharacterID(),
			inst->GetID()
		);
		return;
	}

		auto const type     = EvolvingItemsManager::Instance()->GetEvolvingItemsCache().at(inst->GetID()).type;
		auto const sub_type = EvolvingItemsManager::Instance()->GetEvolvingItemsCache().at(inst->GetID()).sub_type;

		auto sub_types = Strings::Split(sub_type, SUB_TYPE_DELIMITER);
		auto has_sub_type = [&](uint32_t type) {
			return Strings::Contains(sub_types, std::to_string(type));
		};

		switch (type) {
			case EvolvingItems::Types::AMOUNT_OF_EXP: {
				LogEvolveItemDetail("Type <green>[{}] Processing sub_type", type);

				// Determine the evolve amount based on sub_type conditions
				int evolve_amount = 0;

				if (has_sub_type(EvolvingItems::SubTypes::ALL_EXP) ||
					(has_sub_type(EvolvingItems::SubTypes::GROUP_EXP) && IsGrouped())) {
					evolve_amount = exp * RuleR(EvolvingItems, PercentOfGroupExperience) / 100;
				}
				else if (has_sub_type(EvolvingItems::SubTypes::ALL_EXP) ||
						 (has_sub_type(EvolvingItems::SubTypes::RAID_EXP) && IsRaidGrouped())) {
					evolve_amount = exp * RuleR(EvolvingItems, PercentOfRaidExperience) / 100;
				}
				else if (has_sub_type(EvolvingItems::SubTypes::ALL_EXP) ||
						 has_sub_type(EvolvingItems::SubTypes::SOLO_EXP)) {
					evolve_amount = exp * RuleR(EvolvingItems, PercentOfSoloExperience) / 100;
				}

				inst->SetEvolveAddToCurrentAmount(evolve_amount);
				inst->CalculateEvolveProgression();

				auto e = CharacterEvolvingItemsRepository::SetCurrentAmountAndProgression(
					database, inst->GetEvolveUniqueID(), inst->GetEvolveCurrentAmount(), inst->GetEvolveProgression()
				);
				if (!e.id) {
					break;
				}

				SendEvolvingPacket(EvolvingItems::Actions::UPDATE_ITEMS, e);

				LogEvolveItem(
					"Processing Complete for item id <green>[{1}] Type 1 Amount of EXP - SubType <yellow>[{0}] - "
					"Assigned <yellow>[{2}] of exp to <green>[{1}]",
					sub_type,
					inst->GetID(),
					exp * 0.001
				);

				if (inst->GetEvolveProgression() >= 100) {
					queue.push_back(inst);
				}

				break;
			}
			case EvolvingItems::Types::SPECIFIC_MOB_RACE: {
				LogEvolveItemDetail("Type <green>[{}] Processing sub type", type);
				if (mob && has_sub_type(mob->GetRace())) {
					LogEvolveItemDetail("Sub_Type <green>[{}] Processing Item", sub_type);
					inst->SetEvolveAddToCurrentAmount(1);
					inst->CalculateEvolveProgression();

					auto e = CharacterEvolvingItemsRepository::SetCurrentAmountAndProgression(
						database,
						inst->GetEvolveUniqueID(),
						inst->GetEvolveCurrentAmount(),
						inst->GetEvolveProgression()
					);
					if (!e.id) {
						break;
					}

					SendEvolvingPacket(EvolvingItems::Actions::UPDATE_ITEMS, e);

					LogEvolveItem(
						"Processing Complete for item id <green>[{1}] Type 3 Specific Mob Race - SubType "
						"<yellow>[{0}] "
						"- Increased count by 1 for <green>[{1}]",
						sub_type,
						inst->GetID()
					);
				}

				if (inst->GetEvolveProgression() >= 100) {
					queue.push_back(inst);
				}

				break;
			}
			case EvolvingItems::Types::SPECIFIC_ZONE_ID: {
				LogEvolveItemDetail("Type <green>[{}] Processing sub type", type);
				if (mob && has_sub_type(mob->GetZoneID())) {
					LogEvolveItemDetail("Sub_Type <green>[{}] Processing Item", sub_type);
					inst->SetEvolveAddToCurrentAmount(1);
					inst->CalculateEvolveProgression();

					auto e = CharacterEvolvingItemsRepository::SetCurrentAmountAndProgression(
						database,
						inst->GetEvolveUniqueID(),
						inst->GetEvolveCurrentAmount(),
						inst->GetEvolveProgression()
					);
					if (!e.id) {
						break;
					}

					SendEvolvingPacket(EvolvingItems::Actions::UPDATE_ITEMS, e);

					LogEvolveItem(
						"Processing Complete for item id <green>[{1}] Type 4 Specific Zone ID - SubType "
						"<yellow>[{0}] "
						"- Increased count by 1 for <green>[{1}]",
						sub_type,
						inst->GetID()
					);
				}

				if (inst->GetEvolveProgression() >= 100) {
					queue.push_back(inst);
				}

				break;
			}
			case EvolvingItems::Types::NUMBER_OF_KILLS: {
				LogEvolveItemDetail("Type <green>[{}] Processing sub type", type);
				if (mob) {
					if (mob->GetLevel() >= Strings::ToUnsignedInt(sub_types.front()) ||
						Strings::ToUnsignedInt(sub_types.front()) == 0
					) {
						LogEvolveItemDetail("Sub_Type <green>[{}] Processing Item", sub_type);
						inst->SetEvolveAddToCurrentAmount(1);
						inst->CalculateEvolveProgression();

						auto e = CharacterEvolvingItemsRepository::SetCurrentAmountAndProgression(
							database,
							inst->GetEvolveUniqueID(),
							inst->GetEvolveCurrentAmount(),
							inst->GetEvolveProgression()
						);
						if (!e.id) {
							break;
						}

						SendEvolvingPacket(EvolvingItems::Actions::UPDATE_ITEMS, e);

						LogEvolveItem(
							"Processing Complete for item id <green>[{1}] Type 4 Specific Zone ID - SubType "
							"<yellow>[{0}] "
							"- Increased count by 1 for <green>[{1}]",
							sub_type,
							inst->GetID()
						);
					}
				}

				if (inst->GetEvolveProgression() >= 100) {
					queue.push_back(inst);
				}

				break;
			}
			case EvolvingItems::Types::POWER_SOURCE_ENERGY: {
				// Legacy ench/leg energy curve (mirrors the retired slot-21
				// system): GetBaseExpValueForKill yields a small float per
				// kill (con table, Character modifiers, gearscore-of-final-
				// item division, tier floors, loot buff x1.5, XPRate), stored
				// x100 against required_amount (10000 = the old 100% fill).
				// Raids are skipped exactly as the old hook skipped them.
				if (!mob || (GetRaid() && GetRaid()->RaidCount())) {
					static std::unordered_set<uint32> raid_skip_logged;
					if (raid_skip_logged.size() > 4096) {
						raid_skip_logged.clear();
					}
					if (raid_skip_logged.insert(inst->GetSerialNumber()).second) {
						LogInfo("EVOACC item [{}] serial [{}] char [{}] uid [{}] SKIP raid [{}] mob [{}]",
							inst->GetID(), inst->GetSerialNumber(), CharacterID(), inst->GetEvolveUniqueID(),
							GetRaid() ? (int)GetRaid()->RaidCount() : 0, mob ? 1 : 0);
					}
					break;
				}

				// Final-stage items have no upgrade chain (GetMaxUpgrade
				// returns null when the item IS the max tier) and no further
				// evolution - skip them; the retired slot-21 system likewise
				// never accrued fully-upgraded items.
				if (inst->GetEvolveLvl() >= inst->GetMaxEvolveLvl()) {
					// One line per instance, not per kill: every final-tier item
					// that is still activated reaches here on every kill.
					static std::unordered_set<uint32> final_tier_logged;
					if (final_tier_logged.size() > 4096) {
						final_tier_logged.clear();
					}
					if (final_tier_logged.insert(inst->GetSerialNumber()).second) {
						LogInfo("EVOACC item [{}] serial [{}] char [{}] uid [{}] final tier lvl [{}] max [{}]",
							inst->GetID(), inst->GetSerialNumber(), CharacterID(), inst->GetEvolveUniqueID(),
							(int)inst->GetEvolveLvl(), (int)inst->GetMaxEvolveLvl());
					}
					break;
				}

				const int conlevel = static_cast<int>(Mob::GetLevelCon(GetLevel(), mob->GetLevel()));
				// The energy floors key on the UPGRADE TARGET's tier (the
				// retired slot-21 caller passed the next tier's id), not the
				// item's own tier: tier+1 from a base item floors at 0.75,
				// tier+1 from an Enchanted item at the orb curve's 0.075.
				// The orb floor is 1/10 of the stage-1 floor, so a stage-2
				// item gained exactly one tenth of the same family's stage-1
				// item and sat at 0% in the tab's integer percentage. Native
				// evolving items therefore pass their own stage-2 floor
				// (EvolvingItems:EnergyRateFloorTier2, 0.25 = the authored
				// v444 3:1 ratio) instead of the orb rule.
				const int item_tier = static_cast<int>(inst->GetID() / 1000000) + 1;

				EQ::ItemInstance *max_upgrade = inst->GetMaxUpgrade(database);
				const float energy = GetBaseExpValueForKill(
					conlevel, item_tier, max_upgrade ? max_upgrade : inst,
					RuleR(EvolvingItems, EnergyRateFloorTier2)
				);
				safe_delete(max_upgrade);

				const uint64 energy_units = static_cast<uint64>(energy * 100.0f + 0.5f);


				inst->SetEvolveAddToCurrentAmount(energy_units);
				inst->CalculateEvolveProgression();

				auto e = CharacterEvolvingItemsRepository::SetCurrentAmountAndProgression(
					database,
					inst->GetEvolveUniqueID(),
					inst->GetEvolveCurrentAmount(),
					inst->GetEvolveProgression()
				);
				if (!e.id) {
					break;
				}

				SendEvolvingPacket(EvolvingItems::Actions::UPDATE_ITEMS, e);

				LogEvolveItem(
					"Processing Complete for item id <green>[{1}] Type 5 Power Source Energy - conlevel <yellow>[{0}] "
					"- Assigned <yellow>[{2}] energy units for <green>[{1}]",
					conlevel,
					inst->GetID(),
					energy_units
				);

				if (inst->GetEvolveProgression() >= 100) {
					queue.push_back(inst);
				}

				break;
			}
			default: {
			}
	}
}

void Client::ProcessEvolvingItem(const uint64 exp, const Mob *mob)
{
	std::vector<EQ::ItemInstance *> queue{};

	for (auto &[worn_slot, worn_inst]: GetInv().GetWorn()) {
		if (!worn_inst) {
			continue;
		}

		ProcessEvolvingInstance(worn_inst, exp, mob, queue);

		// Socketed augments evolve as first-class items alongside their
		// worn parent.
		for (uint8 s = EQ::invaug::SOCKET_BEGIN; s <= EQ::invaug::SOCKET_END; s++) {
			if (EQ::ItemInstance *aug = worn_inst->GetAugment(s)) {
				ProcessEvolvingInstance(aug, exp, mob, queue);
			}
		}
	}

	if (queue.empty()) {
		return;
	}

	// A queued instance can be destroyed by an earlier completion in this
	// same batch (a parent that evolves carries and deletes its socketed
	// augs); verify each is still reachable before completing it.
	for (auto const &i: queue) {
		bool reachable = false;
		for (auto &[worn_slot, worn_inst]: GetInv().GetWorn()) {
			if (!worn_inst) {
				continue;
			}

			if (worn_inst == i) {
				reachable = true;
				break;
			}

			for (uint8 s = EQ::invaug::SOCKET_BEGIN; s <= EQ::invaug::SOCKET_END; s++) {
				if (worn_inst->GetAugment(s) == i) {
					reachable = true;
					break;
				}
			}

			if (reachable) {
				break;
			}
		}

		if (reachable) {
			DoEvolveCheckProgression(*i);
		}
	}
}

void Client::DoEvolveItemDisplayFinalResult(const EQApplicationPacket *app)
{
	const auto in        = reinterpret_cast<EvolveItemToggle *>(app->pBuffer);

	const uint32 item_id = static_cast<uint32>(in->unique_id & 0xFFFFFFFF);
	if (item_id == 0) {
		LogEvolveItem("Error - Item ID of final evolve item is blank.");
		return;
	}

	std::unique_ptr<EQ::ItemInstance> const inst(database.CreateItem(item_id));
	if (!inst) {
		return;
	}

	LogEvolveItemDetail(
		"Character ID <green>[{}] requested to view final evolve item id <yellow>[{}] for evolve item id <yellow>[{}]",
		CharacterID(),
		item_id,
		EvolvingItemsManager::Instance()->GetFirstItemInLoreGroupByItemID(item_id)
	);

	inst->SetEvolveProgression(100);

	LogEvolveItemDetail(
		"Sending final result for item id <yellow>[{}] to Character ID <green>[{}]", item_id, CharacterID()
	);
	SendItemPacket(0, inst.get(), ItemPacketViewLink);
}

bool Client::DoEvolveCheckProgression(EQ::ItemInstance &inst)
{
	if (!inst) {
		return false;
	}

	if (inst.GetEvolveProgression() < 100 || inst.GetEvolveLvl() == inst.GetMaxEvolveLvl()) {
		return false;
	}

	const auto new_item_id = EvolvingItemsManager::Instance()->GetNextEvolveItemID(inst);
	if (!new_item_id) {
		return false;
	}

	std::unique_ptr<EQ::ItemInstance> const new_inst(database.CreateItem(new_item_id));

	if (!new_inst) {
		return false;
	}

	// Socketed-augment evolution: the completed item may be an augment inside
	// a worn parent. RemoveItemBySerialNumber cannot unsocket, so handle it
	// here - unsocket the old tier, re-socket the evolved tier in place
	// (same family = same augtype fit), and push the updated parent.
	{
		EQ::ItemInstance *sock_parent = nullptr;
		int16 sock_parent_slot = INVALID_INDEX;
		uint8 sock_index = 0;

		for (auto &[worn_slot, worn_inst]: GetInv().GetWorn()) {
			if (!worn_inst) {
				continue;
			}

			for (uint8 s = EQ::invaug::SOCKET_BEGIN; s <= EQ::invaug::SOCKET_END; s++) {
				EQ::ItemInstance *aug = worn_inst->GetAugment(s);
				if (aug && aug->GetSerialNumber() == inst.GetSerialNumber()) {
					sock_parent      = worn_inst;
					sock_parent_slot = worn_slot;
					sock_index       = s;
					break;
				}
			}

			if (sock_parent) {
				break;
			}
		}

		if (sock_parent) {
			CheckItemDiscoverability(new_inst->GetID());

			PlayerEvent::EvolveItem e{};

			EQ::ItemInstance *old_aug = sock_parent->RemoveAugment(sock_index);
			safe_delete(old_aug);

			sock_parent->PutAugment(sock_index, *new_inst);

			// Bind the evolved tier's evolve row (the fresh instance starts
			// unbound) and arm its equip timer.
			if (EQ::ItemInstance *socketed = sock_parent->GetAugment(sock_index)) {
				EvolvingItemsManager::Instance()->DoLootChecks(
					CharacterID(), static_cast<uint16>(sock_parent_slot), *socketed
				);

				EvolvingItemsManager::Instance()->LoadPlayerEvent(*socketed, e);
				e.status = "Evolved Item due to obtaining progression - New augment tier socketed in place.";
				RecordPlayerEventLog(PlayerEvent::EVOLVE_ITEM, e);
			}

			database.SaveInventory(CharacterID(), sock_parent, sock_parent_slot);
			SendItemPacket(sock_parent_slot, sock_parent, ItemPacketTrade);

			EvolvingItemsManager::Instance()->LoadPlayerEvent(inst, e);
			e.status = "Evolved Item due to obtaining progression - Old augment tier removed from its socket.";
			RecordPlayerEventLog(PlayerEvent::EVOLVE_ITEM, e);

			MessageString(Chat::Yellow, EVOLVE_ITEM_EVOLVED, inst.GetItem()->Name);

			LogEvolveItem(
				"Evolved socketed augment id <red>[{}] into item id <green>[{}] in place for Character ID <green>[{}]",
				inst.GetID(),
				new_inst->GetID(),
				CharacterID());

			return true;
		}
	}

	// Legacy slot-21 parity: carry socketed augments onto the evolved item
	// (same-family tiers share aug sockets; blind per-slot copy, like the
	// retired slot-21 upgrade path). The parcel system remains the fallback
	// for any socket that did not carry.
	std::vector<bool> aug_carried(static_cast<size_t>(EQ::invaug::SOCKET_END) + 1, false);
	if (inst.IsAugmented()) {
		for (uint8 r = EQ::invaug::SOCKET_BEGIN; r <= EQ::invaug::SOCKET_END; r++) {
			EQ::ItemInstance *aug = inst.GetAugment(r);
			if (!aug) {
				continue;
			}

			new_inst->PutAugment(r, *aug);
			EQ::ItemInstance *carried = new_inst->GetAugment(r);
			aug_carried[r] = (carried && carried->GetID() == aug->GetID());
		}
	}

	if (RuleB(EvolvingItems, EnableParcelMerchants) &&
		!RuleB(EvolvingItems, DestroyAugmentsOnEvolve) &&
		inst.IsAugmented()
		) {
                auto const                                                augs = inst.GetAugmentIDs();
                std::vector<CharacterParcelsRepository::CharacterParcels> parcels;
                int32 next_slot = FindNextFreeParcelSlotUsingMemory();
                for (uint8 r = EQ::invaug::SOCKET_BEGIN; r <= EQ::invaug::SOCKET_END; r++) {
                        const uint32 item_id = (r < augs.size()) ? augs[r] : 0;
                        if (!item_id) {
                                continue;
                        }

                        if (r < aug_carried.size() && aug_carried[r]) {
                                continue;
                        }

                        if (next_slot == INVALID_INDEX) {
                                break;
                        }

                        CharacterParcelsRepository::CharacterParcels p{};
                        p.char_id   = CharacterID();
                        p.from_name = "Evolving Item Sub-System";
                        p.note      = fmt::format(
                                      "System automatically removed from {} which recently evolved.",
                                      inst.GetItem()->Name
                                      );
                        p.slot_id   = next_slot;
                        p.sent_date = time(nullptr);
                        p.item_id   = item_id;
                        p.quantity  = 1;

			if (PlayerEventLogs::Instance()->IsEventEnabled(PlayerEvent::PARCEL_SEND)) {
				PlayerEvent::ParcelSend e{};
				e.from_player_name = p.from_name;
				e.to_player_name   = GetCleanName();
				e.item_id          = p.item_id;
				e.quantity         = 1;
				e.sent_date        = p.sent_date;

				RecordPlayerEventLog(PlayerEvent::PARCEL_SEND, e);
			}

                        parcels.push_back(p);
                        m_parcels.emplace(p.slot_id, p);
                        next_slot = FindNextFreeParcelSlotUsingMemory();
                }

		CharacterParcelsRepository::InsertMany(database, parcels);
		SendParcelStatus();
		SendParcelIconStatus();
	}

	CheckItemDiscoverability(new_inst->GetID());

	PlayerEvent::EvolveItem e{};

	RemoveItemBySerialNumber(inst.GetSerialNumber());
	EvolvingItemsManager::Instance()->LoadPlayerEvent(inst, e);
	e.status = "Evolved Item due to obtaining progression - Old Evolve Item removed from inventory.";
	RecordPlayerEventLog(PlayerEvent::EVOLVE_ITEM, e);

	PushItemOnCursor(*new_inst, true);
	EvolvingItemsManager::Instance()->LoadPlayerEvent(*new_inst, e);
	e.status = "Evolved Item due to obtaining progression - New Evolve Item placed in inventory.";
	RecordPlayerEventLog(PlayerEvent::EVOLVE_ITEM, e);

	MessageString(Chat::Yellow, EVOLVE_ITEM_EVOLVED, inst.GetItem()->Name);

	LogEvolveItem(
		"Evolved item id <red>[{}] into item id <green>[{}] for Character ID <green>[{}]",
		inst.GetID(),
		new_inst->GetID(),
		CharacterID());

	return true;
}

void Client::SendEvolveXPTransferWindow()
{
	auto       out  = std::make_unique<EQApplicationPacket>(OP_EvolveItem, sizeof(EvolveItemToggle));
	const auto data = reinterpret_cast<EvolveItemToggle *>(out->pBuffer);

	data->action    = 1;

	QueuePacket(out.get());
}

void Client::SendEvolveXPWindowDetails(const EQApplicationPacket *app)
{
	const auto in = reinterpret_cast<EvolveXPWindowReceive *>(app->pBuffer);

	const auto item_1_slot =
		GetInv().HasEvolvingItem(in->item1_unique_id, 1, invWherePersonal | invWhereWorn | invWhereCursor);
	const auto item_2_slot =
		GetInv().HasEvolvingItem(in->item2_unique_id, 1, invWherePersonal | invWhereWorn | invWhereCursor);

	if (item_1_slot == INVALID_INDEX || item_2_slot == INVALID_INDEX) {
		return;
	}

	const auto inst_from = GetInv().GetItem(item_1_slot);
	const auto inst_to   = GetInv().GetItem(item_2_slot);

	if (!inst_from || !inst_to) {
		return;
	}

	const auto results = EvolvingItemsManager::Instance()->DetermineTransferResults(*inst_from, *inst_to);

	if (!results.item_from_id || !results.item_to_id) {
		SendEvolveTransferResults(*inst_from, *inst_to, *inst_from, *inst_to, 0, 0);
		return;
	}

	std::unique_ptr<EQ::ItemInstance> const inst_from_new(database.CreateItem(results.item_from_id));
	std::unique_ptr<EQ::ItemInstance> const inst_to_new(database.CreateItem(results.item_to_id));
	if (!inst_from_new || !inst_to_new) {
		SendEvolveTransferResults(*inst_from, *inst_to, *inst_from, *inst_to, 0, 0);
		return;
	}

	inst_from_new->SetEvolveCurrentAmount(results.item_from_current_amount);
	inst_from_new->CalculateEvolveProgression();
	inst_to_new->SetEvolveCurrentAmount(results.item_to_current_amount);
	inst_to_new->CalculateEvolveProgression();

	SendEvolveTransferResults(
		*inst_from, *inst_to, *inst_from_new, *inst_to_new, results.compatibility, results.max_transfer_level);
}

void Client::DoEvolveTransferXP(const EQApplicationPacket *app)
{
	const auto in = reinterpret_cast<EvolveXPWindowReceive *>(app->pBuffer);

	const auto item_1_slot =
		GetInv().HasEvolvingItem(in->item1_unique_id, 1, invWherePersonal | invWhereWorn | invWhereCursor);
	const auto item_2_slot =
		GetInv().HasEvolvingItem(in->item2_unique_id, 1, invWherePersonal | invWhereWorn | invWhereCursor);

	if (item_1_slot == INVALID_INDEX || item_2_slot == INVALID_INDEX) {
		return;
	}

	const auto inst_from = GetInv().GetItem(item_1_slot);
	const auto inst_to   = GetInv().GetItem(item_2_slot);

	if (!inst_from || !inst_to) {
		Message(Chat::Red, "Transfer Failed.  Incompatible Items.");
		LogEvolveItem("Transfer Failed for Character ID <green>[{}]", CharacterID());
		return;
	}

	const auto results = EvolvingItemsManager::Instance()->DetermineTransferResults(*inst_from, *inst_to);

	if (!results.item_from_id || !results.item_to_id) {
		Message(Chat::Red, "Transfer Failed.  Incompatible Items.");
		LogEvolveItem("Transfer Failed for Character ID <green>[{}]", CharacterID());
		return;
	}

	std::unique_ptr<const EQ::ItemInstance> const inst_from_new(database.CreateItem(results.item_from_id));
	std::unique_ptr<const EQ::ItemInstance> const inst_to_new(database.CreateItem(results.item_to_id));

	if (!inst_from_new || !inst_to_new) {
		Message(Chat::Red, "Transfer Failed.  Incompatible Items.");
		LogEvolveItem("Transfer Failed for Character ID <green>[{}]", CharacterID());
		return;
	}

	inst_from_new->SetEvolveCurrentAmount(results.item_from_current_amount);
	inst_from_new->CalculateEvolveProgression();
	inst_to_new->SetEvolveCurrentAmount(results.item_to_current_amount);
	inst_to_new->CalculateEvolveProgression();

	PlayerEvent::EvolveItem e{};

	RemoveItemBySerialNumber(inst_from->GetSerialNumber());
	EvolvingItemsManager::Instance()->LoadPlayerEvent(*inst_from, e);
	e.status = "Transfer XP - Original FROM Evolve Item removed from inventory.";
	RecordPlayerEventLog(PlayerEvent::EVOLVE_ITEM, e);

	PushItemOnCursor(*inst_from_new, true);
	EvolvingItemsManager::Instance()->LoadPlayerEvent(*inst_from_new, e);
	e.status = "Transfer XP - Updated FROM item placed in inventory.";
	RecordPlayerEventLog(PlayerEvent::EVOLVE_ITEM, e);

	RemoveItemBySerialNumber(inst_to->GetSerialNumber());
	EvolvingItemsManager::Instance()->LoadPlayerEvent(*inst_to, e);
	e.status = "Transfer XP - Original TO Evolve Item removed from inventory.";
	RecordPlayerEventLog(PlayerEvent::EVOLVE_ITEM, e);

	PushItemOnCursor(*inst_to_new, true);
	EvolvingItemsManager::Instance()->LoadPlayerEvent(*inst_to_new, e);
	e.status = "Transfer XP - Updated TO Evolve item placed in inventory.";
	RecordPlayerEventLog(PlayerEvent::EVOLVE_ITEM, e);

	LogEvolveItem(
		"Evolve Transfer XP resulted in evolved item id <red>[{}] into item id <green>[{}] for Character ID "
		"<green>[{}]",
		inst_to->GetID(),
		inst_to_new->GetID(),
		CharacterID()
	);
}

void Client::SendEvolveTransferResults(
	const EQ::ItemInstance &inst_from,
	const EQ::ItemInstance &inst_to,
	const EQ::ItemInstance &inst_from_new,
	const EQ::ItemInstance &inst_to_new,
	const uint32            compatibility,
	const uint32            max_transfer_level)
{
	std::stringstream           ss;
	cereal::BinaryOutputArchive ar(ss);

	EvolveXPWindowSend e{};
	e.action             = EvolvingItems::Actions::TRANSFER_WINDOW_DETAILS;
	e.compatibility      = compatibility;
	e.item1_unique_id    = inst_from.GetEvolveUniqueID();
	e.item2_unique_id    = inst_to.GetEvolveUniqueID();
	e.max_transfer_level = max_transfer_level;
	e.item1_present      = 1;
	e.item2_present      = 1;
	e.serialize_item_1   = inst_from_new.Serialize(0);
	e.serialize_item_2   = inst_to_new.Serialize(0);

	{
		ar(e);
	}

	uint32 packet_size = sizeof(EvolveItemMessaging) + ss.str().length();

	std::unique_ptr<EQApplicationPacket> out(new EQApplicationPacket(OP_EvolveItem, packet_size));
	const auto                           data = reinterpret_cast<EvolveItemMessaging *>(out->pBuffer);

	data->action                              = EvolvingItems::Actions::TRANSFER_WINDOW_DETAILS;
	memcpy(data->serialized_data, ss.str().data(), ss.str().length());

	QueuePacket(out.get());

	ss.str("");
	ss.clear();
}
