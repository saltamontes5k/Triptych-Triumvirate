/*	EQEmu: EQEmulator

	Copyright (C) 2001-2026 EQEmu Development Team

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program. If not, see <http://www.gnu.org/licenses/>.
*/
#include "client.h"

#include "../common/bazaar.h"
#include "../common/eq_packet_structs.h"
#include "../common/eqemu_logsys.h"
#include "../common/events/player_event_logs.h"
#include "../common/misc_functions.h"
#include "../common/repositories/buyer_buy_lines_repository.h"
#include "../common/repositories/buyer_repository.h"
#include "../common/repositories/character_offline_transactions_repository.h"
#include "../common/repositories/discovered_items_repository.h"
#include "../common/repositories/trader_repository.h"
#include "../common/rulesys.h"
#include "../common/strings.h"
#include "entity.h"
#include "mob.h"
#include "quest_parser_collection.h"
#include "string_ids.h"
#include "worldserver.h"
#include <limits>
#include <numeric>
#include <unordered_map>
#include <unordered_set>

class QueryServ;

extern WorldServer worldserver;
extern QueryServ* QServ;

// ##########################################
// Trade implementation
// ##########################################

Trade::Trade(Mob* in_owner)
{
	owner = in_owner;
	Reset();
}

Trade::~Trade()
{
	Reset();
}

void Trade::Reset()
{
	state = TradeNone;
	with_id = 0;
	pp=0; gp=0; sp=0; cp=0;
}

// Initiate a trade with another mob
// initiate_with specifies whether to start trade with other mob as well
void Trade::Start(uint32 mob_id, bool initiate_with)
{
	Reset();
	state = Trading;
	with_id = mob_id;

	// Autostart on other mob?
	if (initiate_with) {
		Mob *with = With();
		if (with) {
			with->trade->Start(owner->GetID(), false);
		}
	}
}

// Add item from a given slot to trade bucket (automatically does bag data too)
void Trade::AddEntity(uint16 trade_slot_id, uint32 stack_size) {
	// TODO: review for inventory saves / consider changing return type to bool so failure can be passed to desync handler

	if (!owner || !owner->IsClient()) {
		// This should never happen
		LogDebug("Programming error: NPC's should not call Trade::AddEntity()");
		return;
	}

	// If one party accepted the trade then an item was added, their state needs to be reset
	owner->trade->state = Trading;
	Mob* with = With();
	if (with)
		with->trade->state = Trading;

	// Item always goes into trade bucket from cursor
	Client* client = owner->CastToClient();
	EQ::ItemInstance* inst = client->GetInv().GetItem(EQ::invslot::slotCursor);

	if (!inst) {
		client->Message(Chat::Red, "Error: Could not find item on your cursor!");
		return;
	}

	EQ::ItemInstance* inst2 = client->GetInv().GetItem(trade_slot_id);

	// it looks like the original code attempted to allow stacking...
	// (it just didn't handle partial stack move actions)
	if (stack_size > 0) {
		if (!inst->IsStackable() || !inst2 || !inst2->GetItem() || (inst->GetID() != inst2->GetID()) || (stack_size > inst->GetCharges())) {
			client->Kick("Error stacking item in trade");
			return;
		}

		uint32 _stack_size = 0;

		if ((stack_size + inst2->GetCharges()) > inst2->GetItem()->StackSize) {
			_stack_size = (stack_size + inst2->GetCharges()) - inst->GetItem()->StackSize;
			inst2->SetCharges(inst2->GetItem()->StackSize);
		}
		else {
			_stack_size = inst->GetCharges() - stack_size;
			inst2->SetCharges(stack_size + inst2->GetCharges());
		}

		LogTrading("[{}] added partial item [{}] stack (qty: [{}]) to trade slot [{}]", owner->GetName(), inst->GetItem()->Name, stack_size, trade_slot_id);

		if (_stack_size > 0)
			inst->SetCharges(_stack_size);
		else
			client->DeleteItemInInventory(EQ::invslot::slotCursor);

		SendItemData(inst2, trade_slot_id);
	}
	else {
		if (inst2 && inst2->GetID()) {
			client->Kick("Attempting to add null item to trade");
			return;
		}

		SendItemData(inst, trade_slot_id);

		LogTrading("[{}] added item [{}] to trade slot [{}]", owner->GetName(), inst->GetItem()->Name, trade_slot_id);

		client->PutItemInInventory(trade_slot_id, *inst);
		client->DeleteItemInInventory(EQ::invslot::slotCursor);
	}
}

// Retrieve mob the owner is trading with
// Done like this in case 'with' mob goes LD and Mob* becomes invalid
Mob* Trade::With()
{
	return entity_list.GetMob(with_id);
}

// Private Method: Send item data for trade item to other person involved in trade
void Trade::SendItemData(const EQ::ItemInstance* inst, int16 dest_slot_id)
{
	if (inst == nullptr)
		return;

	// @merth: This needs to be redone with new item classes
	Mob* mob = With();
	if (!mob->IsClient())
		return; // Not sending packets to NPCs!

	Client* with = mob->CastToClient();
	Client* trader = owner->CastToClient();
	if (with && with->IsClient()) {
		with->SendItemPacket(dest_slot_id - EQ::invslot::TRADE_BEGIN, inst, ItemPacketTradeView);
		if (inst->GetItem()->ItemClass == 1) {
			for (uint16 i = EQ::invbag::SLOT_BEGIN; i <= EQ::invbag::SLOT_END; i++) {
				uint16 bagslot_id = EQ::InventoryProfile::CalcSlotId(dest_slot_id, i);
				const EQ::ItemInstance* bagitem = trader->GetInv().GetItem(bagslot_id);
				if (bagitem) {
					with->SendItemPacket(bagslot_id - EQ::invslot::TRADE_BEGIN, bagitem, ItemPacketTradeView);
				}
			}
		}

		//safe_delete(outapp);
	}
}

Mob *Trade::GetOwner() const
{
	return owner;
}


void Client::ResetTrade() {
	AddMoneyToPP(trade->cp, trade->sp, trade->gp, trade->pp, true);

	// step 1: process bags
	for (int16 trade_slot = EQ::invslot::TRADE_BEGIN; trade_slot <= EQ::invslot::TRADE_END; ++trade_slot) {
		const EQ::ItemInstance* inst = m_inv[trade_slot];

		if (inst && inst->IsClassBag()) {
			int16 free_slot = m_inv.FindFreeSlotForTradeItem(inst);

			if (free_slot != INVALID_INDEX) {
				PutItemInInventory(free_slot, *inst);
				SendItemPacket(free_slot, inst, ItemPacketTrade);
			}
			else {
				DropInst(inst);
			}

			DeleteItemInInventory(trade_slot);
		}
	}

	// step 2a: process stackables
	for (int16 trade_slot = EQ::invslot::TRADE_BEGIN; trade_slot <= EQ::invslot::TRADE_END; ++trade_slot) {
		EQ::ItemInstance* inst = GetInv().GetItem(trade_slot);

		if (inst && inst->IsStackable()) {
			while (true) {
				// there's no built-in safety check against an infinite loop..but, it should break on one of the conditional checks
				int16 free_slot = m_inv.FindFreeSlotForTradeItem(inst);

				if ((free_slot == EQ::invslot::slotCursor) || (free_slot == INVALID_INDEX))
					break;

				EQ::ItemInstance* partial_inst = GetInv().GetItem(free_slot);

				if (!partial_inst)
					break;

				if (partial_inst->GetID() != inst->GetID()) {
					LogDebug("[CLIENT] Client::ResetTrade() - an incompatible location reference was returned by Inventory::FindFreeSlotForTradeItem()");

					break;
				}

				if ((partial_inst->GetCharges() + inst->GetCharges()) > partial_inst->GetItem()->StackSize) {
					int16 new_charges = (partial_inst->GetCharges() + inst->GetCharges()) - partial_inst->GetItem()->StackSize;

					partial_inst->SetCharges(partial_inst->GetItem()->StackSize);
					inst->SetCharges(new_charges);
				}
				else {
					partial_inst->SetCharges(partial_inst->GetCharges() + inst->GetCharges());
					inst->SetCharges(0);
				}

				PutItemInInventory(free_slot, *partial_inst);
				SendItemPacket(free_slot, partial_inst, ItemPacketTrade);

				if (inst->GetCharges() == 0) {
					DeleteItemInInventory(trade_slot);

					break;
				}
			}
		}
	}

	// step 2b: adjust trade stack bias
	// (if any partial stacks exist before the final stack, FindFreeSlotForTradeItem() will return that slot in step 3 and an overwrite will occur)
	for (int16 trade_slot = EQ::invslot::TRADE_END; trade_slot >= EQ::invslot::TRADE_BEGIN; --trade_slot) {
		EQ::ItemInstance* inst = GetInv().GetItem(trade_slot);

		if (inst && inst->IsStackable()) {
			for (int16 bias_slot = EQ::invslot::TRADE_BEGIN; bias_slot <= EQ::invslot::TRADE_END; ++bias_slot) {
				if (bias_slot >= trade_slot)
					break;

				EQ::ItemInstance* bias_inst = GetInv().GetItem(bias_slot);

				if (!bias_inst || (bias_inst->GetID() != inst->GetID()) || (bias_inst->GetCharges() >= bias_inst->GetItem()->StackSize))
					continue;

				if ((bias_inst->GetCharges() + inst->GetCharges()) > bias_inst->GetItem()->StackSize) {
					int16 new_charges = (bias_inst->GetCharges() + inst->GetCharges()) - bias_inst->GetItem()->StackSize;

					bias_inst->SetCharges(bias_inst->GetItem()->StackSize);
					inst->SetCharges(new_charges);
				}
				else {
					bias_inst->SetCharges(bias_inst->GetCharges() + inst->GetCharges());
					inst->SetCharges(0);
				}

				if (inst->GetCharges() == 0) {
					DeleteItemInInventory(trade_slot);

					break;
				}
			}
		}
	}

	// step 3: process everything else
	for (int16 trade_slot = EQ::invslot::TRADE_BEGIN; trade_slot <= EQ::invslot::TRADE_END; ++trade_slot) {
		const EQ::ItemInstance* inst = m_inv[trade_slot];

		if (inst) {
			int16 free_slot = m_inv.FindFreeSlotForTradeItem(inst);

			if (free_slot != INVALID_INDEX) {
				PutItemInInventory(free_slot, *inst);
				SendItemPacket(free_slot, inst, ItemPacketTrade);
			}
			else {
				DropInst(inst);
			}

			DeleteItemInInventory(trade_slot);
		}
	}
}

void Client::FinishTrade(Mob* tradingWith, bool finalizer, void* event_entry, std::list<void*>* event_details) {
	if (!tradingWith) {
		return;
	}

	if (tradingWith->IsClient()) {
		Client                * other    = tradingWith->CastToClient();

		if(other) {
			LogTrading("Finishing trade with client [{}]", other->GetName());

			AddMoneyToPP(other->trade->cp, other->trade->sp, other->trade->gp, other->trade->pp, true);

			// step 1: process bags
			for (int16 trade_slot = EQ::invslot::TRADE_BEGIN; trade_slot <= EQ::invslot::TRADE_END; ++trade_slot) {
				const EQ::ItemInstance* inst = m_inv[trade_slot];

				if (inst && inst->IsClassBag()) {
					LogTrading("Giving container [{}] ([{}]) in slot [{}] to [{}]", inst->GetItem()->Name, inst->GetItem()->ID, trade_slot, other->GetName());

					// TODO: need to check bag items/augments for no drop..everything for attuned...
					if (
						inst->GetItem()->NoDrop != 0 ||
						CanTradeFVNoDropItem() ||
						other == this
						) {
						int16 free_slot = other->GetInv().FindFreeSlotForTradeItem(inst);

						if (free_slot != INVALID_INDEX) {
							if (other->PutItemInInventory(free_slot, *inst, true)) {
								inst->TransferOwnership(database, other->CharacterID());
								LogTrading("Container [{}] ([{}]) successfully transferred, deleting from trade slot", inst->GetItem()->Name, inst->GetItem()->ID);
							}
							else {
								LogTrading("Transfer of container [{}] ([{}]) to [{}] failed, returning to giver", inst->GetItem()->Name, inst->GetItem()->ID, other->GetName());
								PushItemOnCursor(*inst, true);
							}
						}
						else {
							LogTrading("[{}]'s inventory is full, returning container [{}] ([{}]) to giver", other->GetName(), inst->GetItem()->Name, inst->GetItem()->ID);
							PushItemOnCursor(*inst, true);
						}
					}
					else {
						LogTrading("Container [{}] ([{}]) is NoDrop, returning to giver", inst->GetItem()->Name, inst->GetItem()->ID);
						PushItemOnCursor(*inst, true);
					}

					DeleteItemInInventory(trade_slot);
				}
			}

			// step 2a: process stackables
			for (int16 trade_slot = EQ::invslot::TRADE_BEGIN; trade_slot <= EQ::invslot::TRADE_END; ++trade_slot) {
				EQ::ItemInstance* inst = GetInv().GetItem(trade_slot);

				if (inst && inst->IsStackable()) {
					while (true) {
						// there's no built-in safety check against an infinite loop..but, it should break on one of the conditional checks
						int16 partial_slot = other->GetInv().FindFreeSlotForTradeItem(inst);

						if ((partial_slot == EQ::invslot::slotCursor) || (partial_slot == INVALID_INDEX))
							break;

						EQ::ItemInstance* partial_inst = other->GetInv().GetItem(partial_slot);

						if (!partial_inst)
							break;

						if (partial_inst->GetID() != inst->GetID()) {
							LogTrading("[CLIENT] Client::ResetTrade() - an incompatible location reference was returned by Inventory::FindFreeSlotForTradeItem()");
							break;
						}

						int16 old_charges = inst->GetCharges();
						int16 partial_charges = partial_inst->GetCharges();

						if ((partial_inst->GetCharges() + inst->GetCharges()) > partial_inst->GetItem()->StackSize) {
							int16 new_charges = (partial_inst->GetCharges() + inst->GetCharges()) - partial_inst->GetItem()->StackSize;

							partial_inst->SetCharges(partial_inst->GetItem()->StackSize);
							inst->SetCharges(new_charges);
						}
						else {
							partial_inst->SetCharges(partial_inst->GetCharges() + inst->GetCharges());
							inst->SetCharges(0);
						}

						LogTrading("Transferring partial stack [{}] ([{}]) in slot [{}] to [{}]", inst->GetItem()->Name, inst->GetItem()->ID, trade_slot, other->GetName());

						if (other->PutItemInInventory(partial_slot, *partial_inst, true)) {
							LogTrading(
								"Partial stack [{}] ([{}]) successfully transferred, deleting [{}] charges from trade slot",
								inst->GetItem()->Name,
								inst->GetItem()->ID,
								(old_charges - inst->GetCharges())
							);
							inst->TransferOwnership(database, other->CharacterID());
						}
						else {
							LogTrading("Transfer of partial stack [{}] ([{}]) to [{}] failed, returning [{}] charges to trade slot",
									   inst->GetItem()->Name, inst->GetItem()->ID, other->GetName(), (old_charges - inst->GetCharges()));

							inst->SetCharges(old_charges);
							partial_inst->SetCharges(partial_charges);
							break;
						}

						if (inst->GetCharges() == 0) {
							DeleteItemInInventory(trade_slot);
							break;
						}
					}
				}
			}

			// step 2b: adjust trade stack bias
			// (if any partial stacks exist before the final stack, FindFreeSlotForTradeItem() will return that slot in step 3 and an overwrite will occur)
			for (int16 trade_slot = EQ::invslot::TRADE_END; trade_slot >= EQ::invslot::TRADE_BEGIN; --trade_slot) {
				EQ::ItemInstance* inst = GetInv().GetItem(trade_slot);

				if (inst && inst->IsStackable()) {
					for (int16 bias_slot = EQ::invslot::TRADE_BEGIN; bias_slot <= EQ::invslot::TRADE_END; ++bias_slot) {
						if (bias_slot >= trade_slot)
							break;

						EQ::ItemInstance* bias_inst = GetInv().GetItem(bias_slot);

						if (!bias_inst || (bias_inst->GetID() != inst->GetID()) || (bias_inst->GetCharges() >= bias_inst->GetItem()->StackSize))
							continue;

						int16 old_charges = inst->GetCharges();

						if ((bias_inst->GetCharges() + inst->GetCharges()) > bias_inst->GetItem()->StackSize) {
							int16 new_charges = (bias_inst->GetCharges() + inst->GetCharges()) - bias_inst->GetItem()->StackSize;

							bias_inst->SetCharges(bias_inst->GetItem()->StackSize);
							inst->SetCharges(new_charges);
						}
						else {
							bias_inst->SetCharges(bias_inst->GetCharges() + inst->GetCharges());
							inst->SetCharges(0);
						}

						if (inst->GetCharges() == 0) {
							DeleteItemInInventory(trade_slot);
							break;
						}
					}
				}
			}

			// step 3: process everything else
			for (int16 trade_slot = EQ::invslot::TRADE_BEGIN; trade_slot <= EQ::invslot::TRADE_END; ++trade_slot) {
				const EQ::ItemInstance* inst = m_inv[trade_slot];

				if (inst) {
					LogTrading("Giving item [{}] ([{}]) in slot [{}] to [{}]", inst->GetItem()->Name, inst->GetItem()->ID, trade_slot, other->GetName());

					// TODO: need to check bag items/augments for no drop..everything for attuned...
					if (inst->GetItem()->NoDrop != 0 || CanTradeFVNoDropItem() || other == this) {
						int16 free_slot = other->GetInv().FindFreeSlotForTradeItem(inst);

						if (free_slot != INVALID_INDEX) {
							if (other->PutItemInInventory(free_slot, *inst, true)) {
								inst->TransferOwnership(database, other->CharacterID());
								LogTrading("Item [{}] ([{}]) successfully transferred, deleting from trade slot", inst->GetItem()->Name, inst->GetItem()->ID);
							}
							else {
								LogTrading("Transfer of Item [{}] ([{}]) to [{}] failed, returning to giver", inst->GetItem()->Name, inst->GetItem()->ID, other->GetName());
								PushItemOnCursor(*inst, true);
							}
						}
						else {
							LogTrading("[{}]'s inventory is full, returning item [{}] ([{}]) to giver", other->GetName(), inst->GetItem()->Name, inst->GetItem()->ID);
							PushItemOnCursor(*inst, true);
						}
					}
					else {
						LogTrading("Item [{}] ([{}]) is NoDrop, returning to giver", inst->GetItem()->Name, inst->GetItem()->ID);
						PushItemOnCursor(*inst, true);
					}

					DeleteItemInInventory(trade_slot);
				}
			}

			//Do not reset the trade here, done by the caller.
		}
	}
	else if(tradingWith->IsNPC()) {

		bool quest_npc = false;
		if (parse->HasQuestSub(tradingWith->GetNPCTypeID(), EVENT_TRADE)) {
			quest_npc = true;
		}

		// take ownership of all trade slot items
		EQ::ItemInstance* insts[4] = { 0 };
		for (int i = EQ::invslot::TRADE_BEGIN; i <= EQ::invslot::TRADE_NPC_END; ++i) {
			insts[i - EQ::invslot::TRADE_BEGIN] = m_inv.PopItem(i);
			database.SaveInventory(CharacterID(), nullptr, i);
		}

		// copy to be filtered by task updates, null trade slots preserved for quest event arg
		std::vector<EQ::ItemInstance*> items(insts, insts + std::size(insts));

		if (RuleB(TaskSystem, EnableTaskSystem)) {
			if (UpdateTasksOnDeliver(items, *trade, tradingWith->CastToNPC())) {
				if (!tradingWith->IsMoving()) {
					tradingWith->FaceTarget(this);
				}
			}
		}

		if (!quest_npc) {
			for (auto &inst: items) {
				if (!inst || !inst->GetItem()) {
					continue;
				}

				// remove delivered task items
				if (RuleB(TaskSystem, EnableTaskSystem) && inst->GetTaskDeliveredCount() > 0) {
					int remaining = inst->RemoveTaskDeliveredItems();
					if (remaining <= 0) {
						inst = nullptr;
						continue; // all items in trade slot consumed by task update
					}
				}

				auto               with   = tradingWith->CastToNPC();
				const EQ::ItemData *item  = inst->GetItem();
				const bool         is_pet = with->IsPetOwnerOfClientBot() || with->IsCharmedPet();
				if (is_pet && with->CanPetTakeItem(inst)) {
					// pets need to look inside bags and try to equip items found there
					if (item->IsClassBag() && item->BagSlots > 0) {
						// if an item inside the bag can't be given to the pet, keep the bag
						bool       keep_bag   = false;
						int        item_count = 0;
						for (int16 bslot      = EQ::invbag::SLOT_BEGIN; bslot < item->BagSlots; bslot++) {
							const EQ::ItemInstance *baginst = inst->GetItem(bslot);
							if (baginst && baginst->GetItem() && with->CanPetTakeItem(baginst)) {
								// add item to pet's inventory
								auto lde = LootdropEntriesRepository::NewNpcEntity();
								lde.equip_item   = 1;
								lde.item_charges = static_cast<int8>(baginst->GetCharges());
								with->AddLootDrop(baginst->GetItem(), lde, true);
								inst->DeleteItem(bslot);
								item_count++;
							}
							else {
								keep_bag = true;
							}
						}

						// add item to pet's inventory
						if (!keep_bag || item_count == 0) {
							auto lde = LootdropEntriesRepository::NewNpcEntity();
							lde.equip_item   = 1;
							lde.item_charges = static_cast<int8>(inst->GetCharges());
							with->AddLootDrop(item, lde, true);
							inst = nullptr;
						}
					}
					else {
						// add item to pet's inventory
						auto lde = LootdropEntriesRepository::NewNpcEntity();
						lde.equip_item   = 1;
						lde.item_charges = static_cast<int8>(inst->GetCharges());
						with->AddLootDrop(item, lde, true);
						inst = nullptr;
					}
				}
			}
		}

		std::string currencies[] = {"copper", "silver", "gold", "platinum"};
		int32       amounts[]    = {trade->cp, trade->sp, trade->gp, trade->pp};

		for (int i = 0; i < 4; ++i) {
			parse->AddVar(
				fmt::format("{}.{}", currencies[i], tradingWith->GetNPCTypeID()),
				fmt::format("{}", amounts[i])
			);
		}

		if (tradingWith->GetAppearance() != eaDead) {
			tradingWith->FaceTarget(this);
		}

		// we cast to any to pass through the quest event system
		std::vector<std::any> item_list(items.begin(), items.end());
		for (EQ::ItemInstance *inst: items) {
			if (!inst || !inst->GetItem()) {
				continue;
			}
			item_list.emplace_back(inst);
		}

		auto handin_npc = tradingWith->CastToNPC();

		m_external_handin_money_returned = {};
		m_external_handin_items_returned = {};
		bool has_aggro = tradingWith->CheckAggro(this);
		if (parse->HasQuestSub(tradingWith->GetNPCTypeID(), EVENT_TRADE) && !has_aggro) {
			// This CheckHandin call enables eq.handin and quest::handin to recognize the hand-in context.
			// It initializes the first hand-in bucket, which is then reused for the EVENT_TRADE subroutine.
			std::map<std::string, uint32> handin = {
				{"copper",   trade->cp},
				{"silver",   trade->sp},
				{"gold",     trade->gp},
				{"platinum", trade->pp}
			};

			for (EQ::ItemInstance *inst: items) {
				if (!inst || !inst->GetItem()) {
					continue;
				}

				std::string item_id = fmt::format("{}", inst->GetItem()->ID);
				handin[item_id] += inst->GetCharges();
			}

			handin_npc->CheckHandin(this, handin, {}, items);

			parse->EventNPC(EVENT_TRADE, tradingWith->CastToNPC(), this, "", 0, &item_list);
			LogNpcHandinDetail("EVENT_TRADE triggered for NPC [{}]", tradingWith->GetNPCTypeID());
		}

		// this is a catch-all return for items that weren't consumed by the EVENT_TRADE subroutine
		// it's possible we have a quest NPC that doesn't have an EVENT_TRADE subroutine
		// we can't double fire the ReturnHandinItems() event, so we need to check if it's already been processed from EVENT_TRADE
		if (!handin_npc->HasProcessedHandinReturn()) {
			if (!handin_npc->HandinStarted()) {
				LogNpcHandinDetail("EVENT_TRADE did not process handin, calling ReturnHandinItems() for NPC [{}]", tradingWith->GetNPCTypeID());
				std::map<std::string, uint32> handin = {
					{"copper",   trade->cp},
					{"silver",   trade->sp},
					{"gold",     trade->gp},
					{"platinum", trade->pp}
				};

				for (EQ::ItemInstance *inst: items) {
					if (!inst || !inst->GetItem()) {
						continue;
					}

					std::string item_id = fmt::format("{}", inst->GetItem()->ID);
					handin[item_id] += inst->GetCharges();
				}

				handin_npc->CheckHandin(this, handin, {}, items);
			}

			if (RuleB(Items, AlwaysReturnHandins)) {
				handin_npc->ReturnHandinItems(this);
				LogNpcHandin("ReturnHandinItems called for NPC [{}]", handin_npc->GetNPCTypeID());
			}
		}

		handin_npc->ResetHandin();

		for (auto &inst: insts) {
			if (inst) {
				safe_delete(inst);
			}
		}
	}
}

bool Client::CheckTradeLoreConflict(Client* other)
{
	if (!other) {
		return true;
	}

	bool has_lore_item = false;
	std::vector<uint32> lore_item_ids;

	for (int16 index = EQ::invslot::TRADE_BEGIN; index <= EQ::invslot::TRADE_END; ++index) {
		const auto inst = m_inv[index];
		if (!inst || !inst->GetItem()) {
			continue;
		}

		if (other->CheckLoreConflict(inst->GetItem())) {
			lore_item_ids.emplace_back(inst->GetItem()->ID);

			has_lore_item = true;
		}
	}

	for (int16 index = EQ::invbag::TRADE_BAGS_BEGIN; index <= EQ::invbag::TRADE_BAGS_END; ++index) {
		const auto inst = m_inv[index];
		if (!inst || !inst->GetItem()) {
			continue;
		}

		if (other->CheckLoreConflict(inst->GetItem())) {
			lore_item_ids.emplace_back(inst->GetItem()->ID);

			has_lore_item = true;
		}
	}

	if (has_lore_item && RuleB(Character, PlayerTradingLoreFeedback)) {
		for (const uint32 lore_item_id : lore_item_ids) {
			Message(
				Chat::Red,
				fmt::format(
					"{} already has a lore {} in their inventory.",
					other->GetCleanName(),
					database.CreateItemLink(lore_item_id)
				).c_str()
			);
		}
	}

	return has_lore_item;
}

bool Client::CheckTradeNonDroppable()
{
	for (int16 index = EQ::invslot::TRADE_BEGIN; index <= EQ::invslot::TRADE_END; ++index){
		const EQ::ItemInstance* inst = m_inv[index];
		if (!inst)
			continue;

		if (!inst->IsDroppable())
			return true;
	}

	return false;
}

void Client::TraderShowItems()
{
	std::stringstream           ss{};
	cereal::BinaryOutputArchive ar(ss);

	auto trader_items = TraderRepository::GetWhere(database, fmt::format("`character_id` = {}", CharacterID()));

	TraderClientMessaging_Struct tcm{};
	tcm.action = ListTraderItems;

	for (auto const &t: trader_items) {
		TraderItems_Struct items{};
		items.item_unique_id = t.item_unique_id;
		items.item_id        = t.item_id;
		items.item_cost      = t.item_cost;

		tcm.items.push_back(items);
	}

	{ ar(tcm); }

	uint32 packet_size = ss.str().length();
	auto   outapp      = new EQApplicationPacket(OP_Trader, packet_size);

	memcpy(outapp->pBuffer, ss.str().data(), packet_size);

	QueuePacket(outapp);
	safe_delete(outapp);
}

void Client::SendTraderPacket(Client* Trader, uint32 Unknown72)
{
	if(!Trader)
		return;

	auto outapp = new EQApplicationPacket(OP_BecomeTrader, sizeof(BecomeTrader_Struct));

	BecomeTrader_Struct* bts = (BecomeTrader_Struct*)outapp->pBuffer;

	bts->action = BazaarTrader_StartTraderMode;

	bts->trader_id = Trader->CharacterID();
	bts->entity_id = Trader->GetID();
	strn0cpy(bts->trader_name, Trader->GetName(), sizeof(bts->trader_name));

	QueuePacket(outapp);


	safe_delete(outapp);
}

void Client::Trader_CustomerBrowsing(Client *Customer)
{

	auto outapp = new EQApplicationPacket(OP_Trader, sizeof(Trader_ShowItems_Struct));
	auto sis    = (Trader_ShowItems_Struct *) outapp->pBuffer;

	sis->action    = CustomerBrowsing;
	sis->entity_id = Customer->GetID();

	QueuePacket(outapp);
	safe_delete(outapp);
}

void Client::TraderStartTrader(const EQApplicationPacket *app)
{
	bool                                  trade_items_valid = true;
	std::vector<TraderRepository::Trader> trader_items{};
	ClickTraderNew_Struct                 in;
	const auto                            max_items = GetInv().GetLookup()->InventoryTypeSize.Bazaar;

	EQ::Util::MemoryStreamReader ss(reinterpret_cast<char *>(app->pBuffer), app->size);
	cereal::BinaryInputArchive   ar(ss);
	{
		ar(in);
	}

	struct TraderSatchelItem {
		int16             slot_id;
		EQ::ItemInstance *inst;
		std::string       container_name;
	};

	auto is_placeholder_unique_id = [](const std::string &item_unique_id) {
		return item_unique_id.empty() || item_unique_id == "0000000000000000";
	};

	auto get_trader_container_name = [](EQ::ItemInstance *item) {
		if (item && item->GetItem() && item->GetItem()->Name[0]) {
			return std::string(item->GetItem()->Name);
		}

		return std::string("a trader container");
	};

	std::vector<TraderSatchelItem> satchel_items{};
	satchel_items.reserve(max_items);

	for (int16 i = EQ::invslot::GENERAL_BEGIN; i <= EQ::invslot::GENERAL_END; i++) {
		if (satchel_items.size() >= max_items) {
			break;
		}

		auto item = GetInv().GetItem(i);
		if (item && item->GetItem()->BagType == EQ::item::BagTypeTradersSatchel) {
			const auto container_name = get_trader_container_name(item);
			for (int x = EQ::invbag::SLOT_BEGIN; x <= EQ::invbag::SLOT_END; x++) {
				if (satchel_items.size() >= max_items) {
					break;
				}

				const int16 slot_id = EQ::InventoryProfile::CalcSlotId(i, x);
				auto        inst    = GetInv().GetItem(slot_id);
				if (inst) {
					satchel_items.push_back({ slot_id, inst, container_name });
				}
			}
		}
	}

	std::unordered_map<std::string, uint32> explicit_prices_by_unique_id{};
	std::unordered_map<int16, uint32>       explicit_prices_by_slot_id{};
	for (auto const &i: in.items) {
		if (!is_placeholder_unique_id(i.unique_id)) {
			explicit_prices_by_unique_id[i.unique_id] = static_cast<uint32>(i.cost);
		}
		else if (i.serial_number < satchel_items.size()) {
			explicit_prices_by_slot_id[satchel_items[i.serial_number].slot_id] = static_cast<uint32>(i.cost);
		}
	}

	std::unordered_set<int16>       listed_slots{};
	std::unordered_set<std::string> listed_unique_ids{};
	std::unordered_set<uint32>      expanded_non_stackable_item_ids{};

	auto ensure_unique_id = [this, &is_placeholder_unique_id, &listed_unique_ids](TraderSatchelItem &item) {
		auto item_unique_id = item.inst->GetUniqueID();
		if (
			is_placeholder_unique_id(item_unique_id) ||
			listed_unique_ids.contains(item_unique_id)
		) {
			item_unique_id = database.ReserveNewItemUniqueId();
			if (item_unique_id.empty()) {
				LogError(
					"Failed to reserve item_unique_id while starting trader mode for client [{}] character [{}] item [{}]",
					GetCleanName(),
					CharacterID(),
					item.inst->GetID()
				);
				return false;
			}

			item.inst->SetUniqueID(item_unique_id);
			if (!database.SaveInventory(CharacterID(), item.inst, item.slot_id)) {
				LogError(
					"Failed to save generated item_unique_id [{}] while starting trader mode for client [{}] character [{}] slot [{}]",
					item_unique_id,
					GetCleanName(),
					CharacterID(),
					item.slot_id
				);
				return false;
			}
		}
		else if (!database.ReserveItemUniqueId(item_unique_id)) {
			LogError(
				"Failed to reserve existing item_unique_id [{}] while starting trader mode for client [{}] character [{}] item [{}]",
				item_unique_id,
				GetCleanName(),
				CharacterID(),
				item.inst->GetID()
			);
			return false;
		}

		listed_unique_ids.insert(item.inst->GetUniqueID());
		return true;
	};

	auto add_trader_item = [this, max_items, &trader_items, &listed_slots, &ensure_unique_id](TraderSatchelItem &item, uint32 cost) {
		if (!item.inst || listed_slots.contains(item.slot_id)) {
			return true;
		}

		if (trader_items.size() >= max_items) {
			return true;
		}

		if (item.inst->GetItem() && item.inst->GetItem()->NoDrop == 0) {
			const auto message = fmt::format(
				"Item: {} is NODROP and found in {}. Please remove and restart trader mode",
				item.inst->GetItem()->Name,
				item.container_name
			);
			Message(Chat::Red, "%s", message.c_str());
			TraderEndTrader();
			return false;
		}

		if (!ensure_unique_id(item)) {
			return false;
		}

		item.inst->SetPrice(cost);

		TraderRepository::Trader trader_item{};

		trader_item.id                    = 0;
		trader_item.char_entity_id        = GetID();
		trader_item.character_id          = CharacterID();
		trader_item.char_zone_id          = GetZoneID();
		trader_item.char_zone_instance_id = GetInstanceID();
		trader_item.item_charges          = item.inst->GetCharges();
		trader_item.item_cost             = cost;
		trader_item.item_id               = item.inst->GetID();
		trader_item.item_unique_id        = item.inst->GetUniqueID();
		trader_item.slot_id               = static_cast<uint8>(trader_items.size() + 1);
		trader_item.listing_date          = time(nullptr);
		if (item.inst->IsAugmented()) {
			auto augs                 = item.inst->GetAugmentIDs();
			trader_item.augment_one   = augs.at(0);
			trader_item.augment_two   = augs.at(1);
			trader_item.augment_three = augs.at(2);
			trader_item.augment_four  = augs.at(3);
			trader_item.augment_five  = augs.at(4);
			trader_item.augment_six   = augs.at(5);
		}

		trader_items.emplace_back(trader_item);
		listed_slots.insert(item.slot_id);
		return true;
	};

	auto find_satchel_item = [&satchel_items, &is_placeholder_unique_id](const BazaarTraderDetails &trader_item) -> TraderSatchelItem* {
		if (is_placeholder_unique_id(trader_item.unique_id)) {
			if (trader_item.serial_number < satchel_items.size()) {
				return &satchel_items[trader_item.serial_number];
			}

			return nullptr;
		}

		for (auto &item: satchel_items) {
			if (item.inst && item.inst->GetUniqueID() == trader_item.unique_id) {
				return &item;
			}

			if (item.inst && fmt::format("{:016}", item.inst->GetSerialNumber()) == trader_item.unique_id) {
				return &item;
			}
		}

		return nullptr;
	};

	for (auto &i: in.items) {
		auto item = find_satchel_item(i);
		if (!item || !item->inst) {
			trade_items_valid = false;
			break;
		}

		if (item->inst->IsStackable()) {
			trade_items_valid = add_trader_item(*item, static_cast<uint32>(i.cost));
			if (!trade_items_valid) {
				break;
			}
			continue;
		}

		const uint32 item_id = item->inst->GetID();
		if (expanded_non_stackable_item_ids.contains(item_id)) {
			continue;
		}

		for (auto &candidate: satchel_items) {
			if (!candidate.inst || candidate.inst->GetID() != item_id || candidate.inst->IsStackable()) {
				continue;
			}

			const auto current_unique_id = candidate.inst->GetUniqueID();
			uint32     cost              = static_cast<uint32>(i.cost);
			if (explicit_prices_by_slot_id.contains(candidate.slot_id)) {
				cost = explicit_prices_by_slot_id[candidate.slot_id];
			}
			else if (!is_placeholder_unique_id(current_unique_id) && explicit_prices_by_unique_id.contains(current_unique_id)) {
				cost = explicit_prices_by_unique_id[current_unique_id];
			}

			trade_items_valid = add_trader_item(candidate, cost);
			if (!trade_items_valid) {
				break;
			}
		}

		expanded_non_stackable_item_ids.insert(item_id);
		if (!trade_items_valid) {
			break;
		}
	}

	if (!trade_items_valid || trader_items.empty()) {
		Message(Chat::Red, "You are not able to become a trader at this time.  Invalid item found.");
		TraderEndTrader();
		return;
	}

	const auto begin_result = database.TransactionBegin();
	if (!begin_result.Success()) {
		LogError(
			"Failed to begin trader row rebuild transaction while starting trader mode for client [{}] character [{}]: error [{}]",
			GetCleanName(),
			CharacterID(),
			begin_result.ErrorMessage()
		);
		Message(Chat::Red, "You are not able to become a trader at this time. Trader item save failed.");
		TraderEndTrader();
		return;
	}

	const auto delete_result = database.QueryDatabase(
		fmt::format(
			"DELETE FROM {} WHERE `character_id` = {}",
			TraderRepository::TableName(),
			CharacterID()
		)
	);
	const auto replaced_rows = delete_result.Success() ? TraderRepository::ReplaceMany(database, trader_items) : 0;

	if (!delete_result.Success() || static_cast<size_t>(replaced_rows) < trader_items.size()) {
		database.TransactionRollback();
		LogError(
			"Failed to rebuild trader rows while starting trader mode for client [{}] character [{}]: delete_success [{}] replaced_rows [{}] expected_rows [{}] error [{}]",
			GetCleanName(),
			CharacterID(),
			delete_result.Success(),
			replaced_rows,
			trader_items.size(),
			delete_result.ErrorMessage()
		);
		Message(Chat::Red, "You are not able to become a trader at this time. Trader item save failed.");
		TraderEndTrader();
		return;
	}

	const auto commit_result = database.TransactionCommit();
	if (!commit_result.Success()) {
		database.TransactionRollback();
		LogError(
			"Failed to commit trader row rebuild while starting trader mode for client [{}] character [{}]: error [{}]",
			GetCleanName(),
			CharacterID(),
			commit_result.ErrorMessage()
		);
		Message(Chat::Red, "You are not able to become a trader at this time. Trader item save failed.");
		TraderEndTrader();
		return;
	}

	// This refreshes the Trader window to display the End Trader button
	if (ClientVersion() >= EQ::versions::ClientVersion::RoF) {
		LogTrading(
			"Sending TraderAck2 to client [{}] account [{}] character [{}] zone [{}] instance [{}] entity [{}]",
			GetCleanName(),
			AccountID(),
			CharacterID(),
			GetZoneID(),
			GetInstanceID(),
			GetID()
		);
		auto outapp = new EQApplicationPacket(OP_Trader, sizeof(TraderStatus_Struct));
		auto data   = (TraderStatus_Struct *) outapp->pBuffer;
		data->Code  = TraderAck2;
		QueuePacket(outapp);
		safe_delete(outapp);
	}

	MessageString(Chat::Yellow, TRADER_MODE_ON);
	SetTrader(true);
	SendTraderMode(TraderOn);
	SendBecomeTraderToWorld(this, TraderOn);
	UpdateWho();
	LogTrading("Trader Mode ON for Player [{}] with client version {}.", GetCleanName(), (uint32) ClientVersion());
}

void Client::TraderEndTrader()
{
	if (IsThereACustomer()) {
		auto customer = entity_list.GetClientByID(GetCustomerID());
		if (customer) {
			customer->CancelTraderTradeWindow();
			customer->SetTraderID(0);
			customer->ClearTraderMerchantList();
		}
	}

	TraderRepository::DeleteWhere(database, fmt::format("`character_id` = {}", CharacterID()));

	SendBecomeTraderToWorld(this, TraderOff);
	SendTraderMode(TraderOff);

	WithCustomer(0);
	SetTrader(false);
	UpdateWho();
}

void Client::SendTraderItem(uint32 ItemID, uint16 Quantity, TraderRepository::Trader &t) {

	std::string Packet;
	int16 FreeSlotID=0;

	const EQ::ItemData* item = database.GetItem(ItemID);

	if(!item){
		LogTrading("Bogus item deleted in Client::SendTraderItem!\n");
		return;
	}

	std::unique_ptr<EQ::ItemInstance> inst(
		database.CreateItem(
			item,
			Quantity,
			t.augment_one,
			t.augment_two,
			t.augment_three,
			t.augment_four,
			t.augment_five,
			t.augment_six
		)
	);

	if (inst)
	{
		bool is_arrow = (inst->GetItem()->ItemType == EQ::item::ItemTypeArrow) ? true : false;
		FreeSlotID = m_inv.FindFreeSlot(false, true, inst->GetItem()->Size, is_arrow);

		if (TryStacking(inst.get(), ItemPacketTrade, true, false)) {
		}
		else {
			PutItemInInventory(FreeSlotID, *inst);
			SendItemPacket(FreeSlotID, inst.get(), ItemPacketTrade);
		}
		Save();
	}
}

void Client::SendSingleTraderItem(uint32 character_id, const std::string &serial_number)
{
	auto inst = database.LoadSingleTraderItem(character_id, serial_number);
	if (inst) {
		SendItemPacket(EQ::invslot::slotCursor, inst.get(), ItemPacketMerchant); // MainCursor?
	}
}

void Client::BulkSendTraderInventory(uint32 character_id)
{
	const EQ::ItemData *item;

	auto   trader_items = TraderRepository::GetWhere(database, fmt::format("`character_id` = {}", character_id));
	uint32 item_limit   = trader_items.size() >= GetInv().GetLookup()->InventoryTypeSize.Bazaar ?
		GetInv().GetLookup()->InventoryTypeSize.Bazaar :
		trader_items.size();

	for (int16 i = 0; i < item_limit; i++) {
		if (trader_items.at(i).item_id == 0 || trader_items.at(i).item_cost == 0) {
			continue;
		}

		item = database.GetItem(trader_items.at(i).item_id);

		if (item && (item->NoDrop != 0)) {
			std::unique_ptr<EQ::ItemInstance> inst(
				database.CreateItem(
					trader_items.at(i).item_id,
					trader_items.at(i).item_charges,
					trader_items.at(i).augment_one,
					trader_items.at(i).augment_two,
					trader_items.at(i).augment_three,
					trader_items.at(i).augment_four,
					trader_items.at(i).augment_five,
					trader_items.at(i).augment_six
				)
			);
			if (inst) {
				inst->SetUniqueID(trader_items.at(i).item_unique_id);
				inst->SetMerchantCount(inst->IsStackable() ? inst->GetCharges() : 1);
				inst->SetMerchantSlot(i + 1);
				inst->SetPrice(trader_items.at(i).item_cost);
				AddDataToMerchantList(i + 1, inst->GetID(), inst->GetMerchantCount(), inst->GetUniqueID());
				SendItemPacket(i + 1, inst.get(), ItemPacketMerchant);
			}
			else
				LogTrading("Client::BulkSendTraderInventory nullptr inst pointer");
		}
	}
}

EQ::ItemInstance *Client::FindTraderItemByUniqueID(std::string &unique_id)
{
	EQ::ItemInstance *item   = nullptr;
	int16            slot_id = 0;

	for (int16 i = EQ::invslot::GENERAL_BEGIN; i <= EQ::invslot::GENERAL_END; i++) {
		item = GetInv().GetItem(i);
		if (item && item->GetItem()->BagType == EQ::item::BagTypeTradersSatchel) {
			for (int16 x = EQ::invbag::SLOT_BEGIN; x <= EQ::invbag::SLOT_END; x++) {
				// we already have the parent bag and a contents iterator..why not just iterate the bag!??
				slot_id = EQ::InventoryProfile::CalcSlotId(i, x);
				item    = GetInv().GetItem(slot_id);
				if (item && item->GetUniqueID().compare(unique_id) == 0) {
					return item;
				}
			}
		}
	}

	LogTrading("Couldn't find item! item_unique_id was [{}]", unique_id);
	return nullptr;
}

EQ::ItemInstance *Client::FindTraderItemByUniqueID(const char* unique_id)
{
	EQ::ItemInstance *item    = nullptr;
	int16             slot_id = 0;

	for (int16 i = EQ::invslot::GENERAL_BEGIN; i <= EQ::invslot::GENERAL_END; i++) {
		item = GetInv().GetItem(i);
		if (item && item->GetItem()->BagType == EQ::item::BagTypeTradersSatchel) {
			for (int16 x = EQ::invbag::SLOT_BEGIN; x <= EQ::invbag::SLOT_END; x++) {
				// we already have the parent bag and a contents iterator..why not just iterate the bag!??
				slot_id = EQ::InventoryProfile::CalcSlotId(i, x);
				item    = GetInv().GetItem(slot_id);
				if (item) {
					if (item->GetUniqueID().compare(unique_id) == 0) {
						return item;
					}
				}
			}
		}
	}

	LogTrading("Couldn't find item! item_unique_id was [{}]", unique_id);
	return nullptr;
}

std::vector<EQ::ItemInstance *> Client::FindTraderItemsByUniqueID(const char* unique_id)
{
	std::vector<EQ::ItemInstance *> items{};
	EQ::ItemInstance *item    = nullptr;
	int16             slot_id = 0;

	for (int16 i = EQ::invslot::GENERAL_BEGIN; i <= EQ::invslot::GENERAL_END; i++) {
		item = GetInv().GetItem(i);
		if (item && item->GetItem()->BagType == EQ::item::BagTypeTradersSatchel) {
			for (int16 x = EQ::invbag::SLOT_BEGIN; x <= EQ::invbag::SLOT_END; x++) {
				// we already have the parent bag and a contents iterator..why not just iterate the bag!??
				slot_id = EQ::InventoryProfile::CalcSlotId(i, x);
				item    = GetInv().GetItem(slot_id);
				if (item && item->GetUniqueID().compare(unique_id) == 0) {
					items.push_back(item);
				}
			}
		}
	}

	LogTrading("Couldn't find item! item_unique_id was [{}]", unique_id);
	return items;
}

GetBazaarItems_Struct *Client::GetTraderItems()
{
	const EQ::ItemInstance *item   = nullptr;
	int16                  slot_id = INVALID_INDEX;
	auto                   gis     = new GetBazaarItems_Struct{0};
	uint8                  ndx     = 0;

	for (int16 i = EQ::invslot::GENERAL_BEGIN; i <= EQ::invslot::GENERAL_END; i++) {
		if (ndx >= GetInv().GetLookup()->InventoryTypeSize.Bazaar) {
			break;
		}
		item = GetInv().GetItem(i);
		if (item && item->GetItem()->BagType == EQ::item::BagTypeTradersSatchel) {
			for (int x = EQ::invbag::SLOT_BEGIN; x <= EQ::invbag::SLOT_END; x++) {
				if (ndx >= GetInv().GetLookup()->InventoryTypeSize.Bazaar) {
					break;
				}

				slot_id = EQ::InventoryProfile::CalcSlotId(i, x);
				item    = GetInv().GetItem(slot_id);

				if (item) {
					gis->items[ndx]         = item->GetID();
					gis->serial_number[ndx] = item->GetUniqueID();
					gis->charges[ndx]       = item->GetCharges() == 0 ? 1 : item->GetCharges();
					ndx++;
				}
			}
		}
	}
	return gis;
}

uint16 Client::FindTraderItem(std::string &serial_number, uint16 Quantity){

	const EQ::ItemInstance* item= nullptr;
	uint16 SlotID = 0;
	for (int i = EQ::invslot::GENERAL_BEGIN; i <= EQ::invslot::GENERAL_END; i++) {
		item = GetInv().GetItem(i);
		if (item && item->GetItem()->BagType == EQ::item::BagTypeTradersSatchel){
			for (int x = EQ::invbag::SLOT_BEGIN; x <= EQ::invbag::SLOT_END; x++){
				SlotID = EQ::InventoryProfile::CalcSlotId(i, x);

				item = GetInv().GetItem(SlotID);

				if (item && item->GetUniqueID().compare(serial_number) == 0 &&
					(item->GetCharges() >= Quantity || (item->GetCharges() <= 0 && Quantity == 1)))
				{
					return SlotID;
				}
			}
		}
	}
	LogTrading("Could NOT find a match for Item: [{}] with a quantity of: [{}] on Trader: [{}]\n",
					serial_number , Quantity, GetName());

	return 0;
}

void Client::NukeTraderItem(
	uint16 slot,
	int16 charges,
	int16 quantity,
	Client *customer,
	uint16 trader_slot,
	const std::string &serial_number,
	int32 item_id
)
{
	if (!customer) {
		return;
	}

	LogTrading("NukeTraderItem(Slot <green>[{}] Charges <green>[{}] Quantity <green>[{}]", slot, charges, quantity);
	if (quantity < charges) {
		customer->SendSingleTraderItem(CharacterID(), serial_number);
		m_inv.DeleteItem(slot, quantity);
	}
	else {
		auto outapp = new EQApplicationPacket(OP_TraderDelItem, sizeof(TraderDelItem_Struct));
		auto tdis   = (TraderDelItem_Struct *) outapp->pBuffer;

		tdis->unknown_000 = 0;
		tdis->trader_id   = customer->GetID();
		tdis->item_id     = Strings::ToUnsignedBigInt(serial_number);
		strn0cpy(tdis->item_unique_id, serial_number.c_str(), sizeof(tdis->item_unique_id));
		tdis->unknown_012 = 0;
		customer->QueuePacket(outapp);
		safe_delete(outapp);

		m_inv.DeleteItem(slot);
	}
	// This updates the trader. Removes it from his trading bags.
	//
	const EQ::ItemInstance *Inst = m_inv[slot];
	database.SaveInventory(CharacterID(), Inst, slot);

	EQApplicationPacket *outapp2;

	if (quantity < charges) {
		outapp2 = new EQApplicationPacket(OP_DeleteItem, sizeof(MoveItem_Struct));
	}
	else {
		outapp2 = new EQApplicationPacket(OP_MoveItem, sizeof(MoveItem_Struct));
	}

	auto mis = (MoveItem_Struct *) outapp2->pBuffer;
	mis->from_slot       = slot;
	mis->to_slot         = 0xFFFFFFFF;
	mis->number_in_stack = 0xFFFFFFFF;

	if (quantity >= charges) {
		quantity = 1;
	}

	for (int i = 0; i < quantity; i++) {
		QueuePacket(outapp2);
	}

	safe_delete(outapp2);
}

void Client::FindAndNukeTraderItem(std::string &item_unique_id, int16 quantity, Client *customer, uint16 trader_slot)
{
	const EQ::ItemInstance *item      = nullptr;
	bool                    stackable = false;
	int16                   charges   = 0;
	uint16                  slot_id   = FindTraderItem(item_unique_id, quantity);


	if (slot_id > 0) {
		item = GetInv().GetItem(slot_id);
		if (!item) {
			LogTrading("Could not find Item: [{}] on Trader: [{}]", item_unique_id, quantity, GetName());
			return;
		}

		charges   = GetInv().GetItem(slot_id)->GetCharges();
		stackable = item->IsStackable();
		if (!stackable) {
			quantity = (charges > 0) ? charges : 1;
		}

		LogTrading("FindAndNuke <green>[{}] charges <green>[{}] quantity <green>[{}]",
				   item->GetItem()->Name,
				   charges,
				   quantity
		);

		if (charges <= quantity || (charges <= 0 && quantity == 1) || !stackable) {
			DeleteItemInInventory(slot_id, quantity);
			auto   trader_items = TraderRepository::GetWhere(database, fmt::format("`character_id` = {}", CharacterID()));
			uint32 item_limit   = trader_items.size() >= GetInv().GetLookup()->InventoryTypeSize.Bazaar ?
				GetInv().GetLookup()->InventoryTypeSize.Bazaar :
				trader_items.size();
			uint8  count        = 0;
			bool   test_slot    = true;

			std::vector<TraderRepository::Trader> delete_queue{};
			for (int i = 0; i < item_limit; i++) {
				if (test_slot && i < trader_items.size() && trader_items.at(i).item_unique_id.compare(item_unique_id) == 0) {
					delete_queue.push_back(trader_items.at(i));
					NukeTraderItem(
						slot_id,
						charges,
						quantity,
						customer,
						trader_slot,
						trader_items.at(i).item_unique_id,
						trader_items.at(i).item_id
					);
					test_slot = false;
				}
				else if (i < trader_items.size() && trader_items.at(i).item_id > 0) {
					count++;
				}
			}

			TraderRepository::DeleteMany(database, delete_queue);
			if (count == 0) {
				TraderEndTrader();
			}

			return;
		}
		else {
			NukeTraderItem(slot_id, charges, quantity, customer, trader_slot, item->GetUniqueID(), item->GetID());
			return;
		}
	}
	LogTrading("Could NOT find a match for Item: <red>[{}] with a quantity of: <red>[{}] on Trader: <red>[{}]\n",
			   item_unique_id,
			   quantity,
			   GetName()
	);
}

void Client::ReturnTraderReq(const EQApplicationPacket *app, int16 trader_item_charges, uint32 item_id)
{
	auto tbs    = (TraderBuy_Struct *) app->pBuffer;
	auto outapp = new EQApplicationPacket(OP_TraderBuy, sizeof(TraderBuy_Struct));
	auto outtbs = (TraderBuy_Struct *) outapp->pBuffer;

	memcpy(outtbs, tbs, app->size);
	if (ClientVersion() >= EQ::versions::ClientVersion::RoF) {
		// Convert Serial Number back to Item ID for RoF+
		outtbs->item_id = item_id;
	}
	else {
		// RoF+ requires individual price, but older clients require total price
		outtbs->price = (tbs->price * static_cast<uint32>(trader_item_charges));
	}

	outtbs->quantity     = trader_item_charges;
	// This should probably be trader ID, not customer ID as it is below.
	outtbs->trader_id    = GetID();
	outtbs->already_sold = 0;

	QueuePacket(outapp);
	safe_delete(outapp);
}

void Client::TradeRequestFailed(const EQApplicationPacket *app)
{
	auto tbs    = (TraderBuy_Struct *) app->pBuffer;
	auto outapp = new EQApplicationPacket(OP_TraderBuy, sizeof(TraderBuy_Struct));
	auto outtbs = (TraderBuy_Struct *) outapp->pBuffer;

	memcpy(outtbs, tbs, app->size);
	outtbs->sub_action   = Bazaar::ResolvePurchaseFailureSubAction(tbs->sub_action);
	outtbs->already_sold = 0xFFFFFFFF;
	outtbs->trader_id    = 0xFFFFFFFF;

	QueuePacket(outapp);
	safe_delete(outapp);
}

void Client::TradeRequestFailed(TraderBuy_Struct &in)
{
	auto outapp = EQApplicationPacket(OP_TraderBuy, sizeof(TraderBuy_Struct));
	auto data   = reinterpret_cast<TraderBuy_Struct *>(outapp.pBuffer);

	data->method       = in.method;
	data->action       = in.action;
	data->sub_action   = Failed;
	data->already_sold = 0xFFFFFFFF;
	data->item_id      = in.item_id;
	data->price        = in.price;
	data->quantity     = in.quantity;
	data->trader_id    = 0xFFFFFFFF;
	strn0cpy(data->buyer_name, in.buyer_name, sizeof(data->buyer_name));
	strn0cpy(data->item_name, in.item_name, sizeof(data->item_name));
	strn0cpy(data->item_unique_id, in.item_unique_id, sizeof(data->item_unique_id));
	strn0cpy(data->seller_name, in.seller_name, sizeof(data->seller_name));

	QueuePacket(&outapp);
}

void Client::BuyTraderItem(const EQApplicationPacket *app)
{
	auto   in     = reinterpret_cast<TraderBuy_Struct *>(app->pBuffer);
	auto   trader = entity_list.GetClientByID(in->trader_id);

	if (!trader || !trader->IsTrader()) {
		Message(Chat::Red, "The trader could not be found.");
		TradeRequestFailed(app);
		return;
	}

	auto trader_packet = std::make_unique<EQApplicationPacket>(OP_Trader, static_cast<uint32>(sizeof(TraderBuy_Struct)));
	auto data          = reinterpret_cast<TraderBuy_Struct*>(trader_packet->pBuffer);

	auto buy_inst = trader->FindTraderItemByUniqueID(in->item_unique_id);
	std::unique_ptr<EQ::ItemInstance> inst_copy(buy_inst ? buy_inst->Clone() : nullptr);

	if (!buy_inst || !inst_copy) {
		LogTrading("Unable to find item id <red>[{}] item_sn <red>[{}] on trader", in->item_id, in->item_unique_id);
		Message(Chat::Red, "The trader no longer has the item for sale.  Please refresh the merchant window.");
		TradeRequestFailed(app);
		return;
	}

	auto quantity_validation = Bazaar::ValidatePurchaseQuantity(
		in->quantity,
		buy_inst->IsStackable(),
		buy_inst->GetCharges()
	);
	if (!quantity_validation.is_valid) {
		LogTrading(
			"Rejecting direct bazaar purchase with invalid quantity [{}] for item [{}]",
			in->quantity,
			buy_inst->GetItem()->Name
		);
		TradeRequestFailed(app);
		return;
	}

	auto quantity = quantity_validation.quantity;
	in->quantity  = quantity;
	inst_copy->SetCharges(
		Bazaar::ResolvePurchaseItemCharges(
			quantity,
			inst_copy->IsStackable(),
			inst_copy->GetItem()->MaxCharges,
			buy_inst->GetCharges()
		)
	);

	if (inst_copy->IsStackable() && quantity != buy_inst->GetCharges()) {
		auto item_unique_id = database.ReserveNewItemUniqueId();
		if (item_unique_id.empty()) {
			Message(Chat::Red, "Internal error. Failed to allocate a unique item id for this purchase.");
			TradeRequestFailed(app);
			return;
		}

		inst_copy->SetUniqueID(item_unique_id);
	}

	LogTrading(
		"Name: <green>[{}] IsStackable: <green>[{}] Requested Quantity: <green>[{}]",
		buy_inst->GetItem()->Name,
		buy_inst->IsStackable(),
		quantity
	);

	if (CheckLoreConflict(inst_copy->GetItem())) {
		MessageString(Chat::Red, DUPLICATE_LORE);
		TradeRequestFailed(app);
		return;
	}

	if (in->price == 0 || quantity == 0) {
        Message(Chat::Red, "Internal error. Aborting trade. Please report this to the ServerOP. Error code is 1");
        trader->Message(Chat::Red, "Internal error. Aborting trade. Please report this to the ServerOP. Error code is 1");
        LogError(
            "Bazaar: Zero price transaction between <red>[{}] and <red>[{}] aborted. Item: <red>[{}] Charges: "
            "<red>[{}] Qty <red>[{}] Price: <red>[{}]",
            GetCleanName(),
            trader->GetCleanName(),
            buy_inst->GetItem()->Name,
            buy_inst->GetCharges(),
            quantity,
            in->price
        );
        TradeRequestFailed(app);
        return;
    }

	const uint64 max_transaction_value = EQ::constants::StaticLookup(ClientVersion())->BazaarMaxTransaction;
	uint64 total_cost = static_cast<uint64>(in->price) * static_cast<uint64>(quantity);
	if (total_cost > max_transaction_value) {
		const auto max_transaction_amount = Strings::Money(max_transaction_value / 1000);
		Message(Chat::Red, fmt::format(
			"That would exceed the single transaction limit of {}.",
			max_transaction_amount
		).c_str());
		TradeRequestFailed(app);
		return;
	}

	if (!TakeMoneyFromPP(total_cost)) {
		MessageString(Chat::Red, INSUFFICIENT_FUNDS);
        TradeRequestFailed(app);
        return;
    }

	if (!trader->RemoveItemByItemUniqueId(buy_inst->GetUniqueID(), quantity)) {
		AddMoneyToPP(total_cost, true);
		Message(Chat::Red, "The Trader no longer has the item.  Please refresh the merchant window.");
		TradeRequestFailed(app);
		return;
	}

	trader->AddMoneyToPP(total_cost, true);

	if (!PutItemInInventoryWithStacking(inst_copy.get())) {
		AddMoneyToPP(total_cost, true);
		trader->TakeMoneyFromPP(total_cost, true);
		trader->PutItemInInventoryWithStacking(buy_inst);
		MessageString(Chat::Red, HOW_CAN_YOU_BUY_MORE, trader->GetCleanName());
		TradeRequestFailed(app);
		return;
	}

	auto [slot_id, merchant_data]                     = GetDataFromMerchantListByItemUniqueId(buy_inst->GetUniqueID());
	auto [item_id, merchant_quantity, item_unique_id] = merchant_data;

	data->action    = BazaarBuyItem;
	data->price     = in->price;
	data->quantity  = quantity;
	data->trader_id = trader->GetID();
	strn0cpy(data->seller_name, trader->GetCleanName(), sizeof(data->seller_name));
	strn0cpy(data->buyer_name, GetCleanName(), sizeof(data->buyer_name));
	strn0cpy(data->item_name, buy_inst->GetItem()->Name, sizeof(data->item_name));
	strn0cpy(data->item_unique_id, buy_inst->GetUniqueID().data(), sizeof(data->item_unique_id));
	trader->QueuePacket(trader_packet.get());

	QueuePacket(app);

	LogTrading("Customer Paid:     [{}] to {}", DetermineMoneyString(total_cost), trader->GetCleanName());
	LogTrading("Customer Received: [{}] {} {} with unique_id of {}",
		quantity,
		in->item_name,
		inst_copy->GetItem()->MaxCharges > 0 ? fmt::format("with {} charges ", inst_copy->GetCharges()).c_str() : std::string(""),
		inst_copy->GetUniqueID()
	);
	LogTrading("Trader Received:   [{}] from {}", DetermineMoneyString(total_cost), GetCleanName());
	LogTrading("Trader Sent:       [{}] {} {} with unique_id of {}",
		quantity,
		in->item_name,
		buy_inst->GetItem()->MaxCharges > 0 ? fmt::format("with {} charges ", buy_inst->GetCharges()).c_str() : std::string(""),
		buy_inst->GetUniqueID()
	);

	if (RuleB(Bazaar, AuditTrail)) {
		Bazaar::RecordAuditTrail(
			database,
			trader->GetCleanName(),
			GetCleanName(),
			buy_inst->GetID(),
			buy_inst->GetItem()->Name,
			quantity,
			total_cost,
			0
		);
	}

	if (merchant_quantity > quantity) {
		std::unique_ptr<EQ::ItemInstance> vendor_inst(buy_inst ? buy_inst->Clone() : nullptr);
		vendor_inst->SetMerchantCount(merchant_quantity - quantity);
		vendor_inst->SetMerchantSlot(slot_id);
		vendor_inst->SetPrice(in->price);

		auto list = GetTraderMerchantList();
		std::get<1>(list->at(slot_id)) -= quantity;

		TraderRepository::UpdateQuantity(database, item_unique_id, merchant_quantity - quantity);
		SendItemPacket(slot_id, vendor_inst.get(), ItemPacketMerchant);
	}
	else {
		auto client_packet = new EQApplicationPacket(OP_ShopDelItem, static_cast<uint32>(sizeof(Merchant_DelItem_Struct)));
		auto client_data   = reinterpret_cast<struct Merchant_DelItem_Struct *>(client_packet->pBuffer);

		client_data->npcid    = trader->GetID();
		client_data->playerid = GetID();
		client_data->itemslot = slot_id;

		QueuePacket(client_packet);
		safe_delete(client_packet);

		auto list = GetTraderMerchantList();
		list->erase(slot_id);

		TraderRepository::DeleteWhere(database, fmt::format("`item_unique_id` = '{}'", item_unique_id));
	}

	if (buy_inst && PlayerEventLogs::Instance()->IsEventEnabled(PlayerEvent::TRADER_PURCHASE)) {
		auto e = PlayerEvent::TraderPurchaseEvent{
			.item_id              = buy_inst->GetID(),
			.augment_1_id         = buy_inst->GetAugmentItemID(0),
			.augment_2_id         = buy_inst->GetAugmentItemID(1),
			.augment_3_id         = buy_inst->GetAugmentItemID(2),
			.augment_4_id         = buy_inst->GetAugmentItemID(3),
			.augment_5_id         = buy_inst->GetAugmentItemID(4),
			.augment_6_id         = buy_inst->GetAugmentItemID(5),
			.item_name            = buy_inst->GetItem()->Name,
			.trader_id            = trader->CharacterID(),
			.trader_name          = trader->GetCleanName(),
			.price                = in->price,
			.quantity             = quantity,
			.charges              = buy_inst->GetCharges(),
			.total_cost           = total_cost,
			.player_money_balance = GetCarriedMoney(),
			.offline_purchase     = trader->IsOffline(),
		};

		RecordPlayerEventLog(PlayerEvent::TRADER_PURCHASE, e);
	}

	if (buy_inst && PlayerEventLogs::Instance()->IsEventEnabled(PlayerEvent::TRADER_SELL)) {
		auto e = PlayerEvent::TraderSellEvent{
			.item_id              = buy_inst->GetID(),
			.augment_1_id         = buy_inst->GetAugmentItemID(0),
			.augment_2_id         = buy_inst->GetAugmentItemID(1),
			.augment_3_id         = buy_inst->GetAugmentItemID(2),
			.augment_4_id         = buy_inst->GetAugmentItemID(3),
			.augment_5_id         = buy_inst->GetAugmentItemID(4),
			.augment_6_id         = buy_inst->GetAugmentItemID(5),
			.item_name            = buy_inst->GetItem()->Name,
			.buyer_id             = CharacterID(),
			.buyer_name           = GetCleanName(),
			.price                = in->price,
			.quantity             = quantity,
			.charges              = buy_inst->GetCharges(),
			.total_cost           = total_cost,
			.player_money_balance = trader->GetCarriedMoney(),
			.offline_purchase     = trader->IsOffline(),
		};

		RecordPlayerEventLogWithClient(trader, PlayerEvent::TRADER_SELL, e);

		if (trader->IsOffline()) {
			auto e         = CharacterOfflineTransactionsRepository::NewEntity();
			e.character_id = trader->CharacterID();
			e.item_id      = buy_inst->GetID();
			e.item_name    = buy_inst->GetItem()->Name;
			e.price        = total_cost;
			e.quantity     = quantity;
			e.type         = TRADER_TRANSACTION;
			e.buyer_name   = GetCleanName();

			CharacterOfflineTransactionsRepository::InsertOne(database, e);
		}
	}
}

void Client::SendBazaarWelcome()
{
	const auto          results = TraderRepository::GetWelcomeData(database);
	EQApplicationPacket outapp(OP_BazaarSearch, static_cast<uint32>(sizeof(BazaarWelcome_Struct)));
	auto                data = (BazaarWelcome_Struct *) outapp.pBuffer;

	data->action             = BazaarWelcome;
	data->traders            = results.count_of_traders;
	data->items              = results.count_of_items;

	LogTrading(
		"Sending BazaarWelcome to client [{}] account [{}] character [{}] traders [{}] items [{}] zone [{}] instance [{}]",
		GetCleanName(),
		AccountID(),
		CharacterID(),
		data->traders,
		data->items,
		GetZoneID(),
		GetInstanceID()
	);

	QueuePacket(&outapp);
}

void Client::SendBarterWelcome()
{
	const auto results = BuyerBuyLinesRepository::GetWelcomeData(database);
	MessageString(Chat::White, BUYER_WELCOME, std::to_string(results.count_of_buyers).c_str());
}

void Client::DoBazaarSearch(BazaarSearchCriteria_Struct search_criteria)
{
	std::vector<BazaarSearchResultsFromDB_Struct> results = Bazaar::GetSearchResults(
		database,
		content_db,
		search_criteria,
		GetZoneID(),
		GetInstanceID()
	);
	if (results.empty()) {
		SendBazaarDone(GetID());
		return;
	}

	SetTraderTransactionDate();
	std::stringstream           ss{};
	cereal::BinaryOutputArchive ar(ss);
	ar(results);

	uint32 packet_size = ss.str().length() + sizeof(BazaarSearchMessaging_Struct);
	auto   out         = new EQApplicationPacket(OP_BazaarSearch, packet_size);
	auto   data        = (BazaarSearchMessaging_Struct *) out->pBuffer;

	data->action = BazaarSearch;
	memcpy(data->payload, ss.str().data(), ss.str().length());
	FastQueuePacket(&out);

	SendBazaarDone(GetID());
	SendBazaarDeliveryCosts();
}

static void UpdateTraderCustomerItemsAdded(
	uint32 customer_id,
	std::vector<BaseTraderRepository::Trader> trader_items,
	uint32 item_id,
	uint32 item_limit
)
{
	// Send Item packets to the customer to update the Merchant window with the
	// new items for sale, and give them a message in their chat window.
	auto customer = entity_list.GetClientByID(customer_id);
	if (!customer) {
		return;
	}

	const EQ::ItemData *item = database.GetItem(item_id);
	if (!item) {
		return;
	}

	customer->Message(Chat::Red, "The Trader has put up %s for sale.", item->Name);

	for (auto const &i: trader_items) {
		if (i.item_id == item_id) {
			std::unique_ptr<EQ::ItemInstance> inst(
				database.CreateItem(
					i.item_id,
					i.item_charges,
					i.augment_one,
					i.augment_two,
					i.augment_three,
					i.augment_four,
					i.augment_five,
					i.augment_six
				)
			);
			if (!inst) {
				return;
			}

			inst->SetCharges(i.item_charges);
			inst->SetPrice(i.item_cost);
			inst->SetUniqueID(i.item_unique_id);
			if (inst->IsStackable()) {
				inst->SetMerchantCount(i.item_charges);
			}

			customer->SendItemPacket(EQ::invslot::slotCursor, inst.get(), ItemPacketMerchant); // MainCursor?
			LogTrading("Sending price update for [{}], Serial No. [{}] with [{}] charges",
					   item->Name, i.item_unique_id, i.item_charges);
		}
	}
}

static void UpdateTraderCustomerPriceChanged(
	uint32 customer_id,
	std::vector<BaseTraderRepository::Trader> trader_items,
	uint32 item_id,
	int32 charges,
	uint32 new_price,
	uint32 item_limit
)
{
	// Send ItemPackets to update the customer's Merchant window with the new price (or remove the item if
	// the new price is 0) and inform them with a chat message.
	auto customer = entity_list.GetClientByID(customer_id);

	if (!customer) {
		return;
	}

	const EQ::ItemData *item = database.GetItem(item_id);

	if (!item) {
		return;
	}

	if (new_price == 0) {
		// If the new price is 0, remove the item(s) from the window.
		auto outapp = new EQApplicationPacket(OP_TraderDelItem, sizeof(TraderDelItem_Struct));
		auto tdis   = (TraderDelItem_Struct *) outapp->pBuffer;

		tdis->unknown_000 = 0;
		tdis->trader_id   = customer->GetID();
		tdis->unknown_012 = 0;
		customer->Message(Chat::Red, "The Trader has withdrawn the %s from sale.", item->Name);

		for (int i = 0; i < item_limit; i++) {
			if (trader_items.at(i).item_id == item_id) {
				if (customer->ClientVersion() >= EQ::versions::ClientVersion::RoF) {
					// RoF+ use Item IDs for now
					tdis->item_id = trader_items.at(i).item_id;
				}
				LogTrading("Telling customer to remove item [{}] with [{}] charges and S/N [{}]",
						   item_id, charges, trader_items.at(i).item_unique_id);

				customer->QueuePacket(outapp);
			}
		}

		safe_delete(outapp);
		return;
	}

	LogTrading("Sending price updates to customer [{}]", customer->GetName());

	auto it = std::find_if(
		trader_items.begin(),
		trader_items.end(),
		[&](TraderRepository::Trader x) {
			return x.item_id == item->ID;
		}
	);
	std::unique_ptr<EQ::ItemInstance> inst(
		database.CreateItem(
			it->item_id,
			it->item_charges,
			it->augment_one,
			it->augment_two,
			it->augment_three,
			it->augment_four,
			it->augment_five,
			it->augment_six
		)
	);
	if (!inst) {
		return;
	}

	if (charges > 0) {
		inst->SetCharges(charges);
	}

	inst->SetPrice(new_price);
	if (inst->IsStackable()) {
		inst->SetMerchantCount(charges);
	}

	// Let the customer know the price in the window has suddenly just changed on them.
	customer->Message(Chat::Red, "The Trader has changed the price of %s.", item->Name);

	for (int i = 0; i < item_limit; i++) {
		if ((trader_items.at(i).item_id != item_id) ||
			((!item->Stackable) && (trader_items.at(i).item_charges != charges))) {
			continue;
		}

		inst->SetUniqueID(trader_items.at(i).item_unique_id);

		LogTrading("Sending price update for [{}], Serial No. [{}] with [{}] charges",
				   item->Name, trader_items.at(i).item_unique_id, trader_items.at(i).item_charges);

		customer->SendItemPacket(EQ::invslot::slotCursor, inst.get(), ItemPacketMerchant); // MainCursor??
	}
}

void Client::SendBuyerResults(BarterSearchRequest_Struct& bsr)
{
	if (ClientVersion() >= EQ::versions::ClientVersion::RoF) {
		std::string search_string(bsr.search_string);
		BuyerLineSearch_Struct results{};

		SetBarterTime();

		if (bsr.search_scope == 1) {
			// Local Buyers
			results = BuyerBuyLinesRepository::SearchBuyLines(database, search_string, 0, GetZoneID(), GetInstanceID());
		}
		else if (bsr.buyer_id) {
			// Specific Buyer
			results = BuyerBuyLinesRepository::SearchBuyLines(database, search_string, bsr.buyer_id);
		} else {
			// All Buyers
			results = BuyerBuyLinesRepository::SearchBuyLines(database, search_string);
		}

		if (results.buy_line.empty()) {
			Message(Chat::White, "No buylines could be found.");
			return;
		}

		std::string buyer_name = "ID {} not in zone.";
		if (search_string.empty()) {
			search_string = "*";
		}

		results.search_string  = std::move(search_string);
		results.transaction_id = bsr.transaction_id;
		std::stringstream ss{};
		cereal::BinaryOutputArchive ar(ss);

		{ ar(results); }

		auto packet = std::make_unique<EQApplicationPacket>(
			OP_BuyerItems,
			static_cast<uint32>(ss.str().length()) + static_cast<uint32>(sizeof(BuyerGeneric_Struct))
		);
		auto emu    = (BuyerGeneric_Struct *) packet->pBuffer;

		emu->action = Barter_BuyerSearch;
		memcpy(emu->payload, ss.str().data(), ss.str().length());

		QueuePacket(packet.get());

		ss.str("");
		ss.clear();

	}
}

void Client::ShowBuyLines(const EQApplicationPacket *app)
{
	auto bir   = (BuyerInspectRequest_Struct *) app->pBuffer;
	auto buyer = entity_list.GetClientByID(bir->buyer_id);

	if (!buyer || buyer->GetCustomerID()) {
		bir->approval = 0; // Tell the client that the Buyer is unavailable
		QueuePacket(app);
		MessageString(Chat::Yellow, TRADER_BUSY);
		return;
	}

	if (ClientVersion() >= EQ::versions::ClientVersion::RoF) {
		SetBarterTime();
		bir->approval = buyer->WithCustomer(GetID());
		QueuePacket(app);

		auto results  = BuyerBuyLinesRepository::GetBuyLines(database, buyer->CharacterID());
		auto greeting = BuyerRepository::GetWelcomeMessage(database, buyer->GetBuyerID());

		if (greeting.length() == 0) {
			greeting = "Welcome!";
		}

		MessageString(Chat::NPCQuestSay, BUYER_GREETING, buyer->GetName(), greeting.c_str());
		const std::string name(GetName());
		buyer->SendSellerBrowsing(name);

		std::stringstream           ss{};
		cereal::BinaryOutputArchive ar(ss);

		for (auto l : results) {
			const EQ::ItemData *item = database.GetItem(l.item_id);
			l.enabled     = 1;
			l.item_icon   = item->Icon;
			l.item_toggle = 1;

			{ ar(l); }

			auto packet = std::make_unique<EQApplicationPacket>(
				OP_BuyerItems,
				static_cast<uint32>(ss.str().length()) + static_cast<uint32>(sizeof(BuyerGeneric_Struct))
			);
			auto emu    = (BuyerGeneric_Struct *) packet->pBuffer;

			emu->action = Barter_BuyerInspectBegin;
			memcpy(emu->payload, ss.str().data(), ss.str().length());

			QueuePacket(packet.get());

			ss.str("");
			ss.clear();
		}

		return;
	}
}

void Client::SellToBuyer(const EQApplicationPacket *app)
{
	if (ClientVersion() >= EQ::versions::ClientVersion::RoF) {
		BuyerLineSellItem_Struct     sell_line{};
		auto                         in = (BuyerGeneric_Struct *) app->pBuffer;
		EQ::Util::MemoryStreamReader ss_in(
			reinterpret_cast<char *>(in->payload),
			app->size - sizeof(BuyerGeneric_Struct));
		cereal::BinaryInputArchive   ar(ss_in);
		ar(sell_line);

		sell_line.seller_name = GetCleanName();

		if (!Bazaar::ValidateBarterSellQuantity(sell_line.seller_quantity, sell_line.item_quantity)) {
			LogTrading(
				"Rejecting buyer sale with invalid quantity [{}] for buy line quantity [{}] item [{}] seller [{}] buyer [{}]",
				sell_line.seller_quantity,
				sell_line.item_quantity,
				sell_line.item_name,
				GetCleanName(),
				sell_line.buyer_name
			);
			SendBarterBuyerClientMessage(
				sell_line,
				Barter_SellerTransactionComplete,
				Barter_Failure,
				Barter_Failure
			);
			return;
		}

		const uint64 max_transaction_value =
			EQ::constants::StaticLookup(ClientVersion())->BazaarMaxTransaction;
		const auto transaction_value = Bazaar::ValidateTransactionValue(
			sell_line.item_cost,
			sell_line.seller_quantity,
			max_transaction_value
		);
		if (!transaction_value.is_valid) {
			LogTrading(
				"Rejecting buyer sale over transaction limit [{}] item_cost [{}] quantity [{}] item [{}] seller [{}] buyer [{}]",
				max_transaction_value,
				sell_line.item_cost,
				sell_line.seller_quantity,
				sell_line.item_name,
				GetCleanName(),
				sell_line.buyer_name
			);
			Message(
				Chat::Red,
				"That would exceed the single transaction limit of %u platinum.",
				static_cast<uint32>(max_transaction_value / 1000)
			);
			SendBarterBuyerClientMessage(
				sell_line,
				Barter_SellerTransactionComplete,
				Barter_Failure,
				Barter_Failure
			);
			return;
		}

		switch (sell_line.purchase_method) {
			case BarterInBazaar:
			case BarterByVendor: {
				auto buyer = entity_list.GetClientByID(sell_line.buyer_entity_id);
				if (!buyer) {
					SendBarterBuyerClientMessage(
						sell_line,
						Barter_SellerTransactionComplete,
						Barter_Failure,
						Barter_Failure
					);
					break;
				}

				if (sell_line.purchase_method == BarterInBazaar && buyer->IsThereACustomer()) {
					auto customer = entity_list.GetClientByID(buyer->GetCustomerID());
					if (customer) {
						customer->CancelBuyerTradeWindow();
					}
				}

				if (!DoBarterBuyerChecks(sell_line)) {
					SendBarterBuyerClientMessage(
						sell_line, Barter_SellerTransactionComplete, Barter_Failure, Barter_Failure
					);
					return;
				}

				if (!DoBarterSellerChecks(sell_line)) {
					SendBarterBuyerClientMessage(
						sell_line, Barter_SellerTransactionComplete, Barter_Failure, Barter_Failure
					);
					return;
				}

				BuyerRepository::UpdateTransactionDate(database, sell_line.buyer_id, time(nullptr));

				if (!FindNumberOfFreeInventorySlotsWithSizeCheck(sell_line.trade_items)) {
					LogTradingDetail("Seller {} has insufficient inventory space for {} compensation items.",
									 GetCleanName(),
									 sell_line.trade_items.size()
					);
					Message(Chat::Red, "Insufficient inventory space for the compensation items.");
					SendBarterBuyerClientMessage(
						sell_line,
						Barter_SellerTransactionComplete,
						Barter_Failure,
						Barter_Failure
					);
					return;
				}

				for (auto const &ti: sell_line.trade_items) {
					std::unique_ptr<EQ::ItemInstance> inst(
						database.CreateItem(
							ti.item_id,
							ti.item_quantity *
							sell_line.seller_quantity
						)
					);

					if (inst.get()->GetItem()) {
						buyer->RemoveItem(ti.item_id, ti.item_quantity * sell_line.seller_quantity);
						if (!PutItemInInventoryWithStacking(inst.get())) {
							Message(Chat::Red, "Error putting item in your inventory.");
							buyer->PutItemInInventoryWithStacking(inst.get());
							SendBarterBuyerClientMessage(
								sell_line,
								Barter_SellerTransactionComplete,
								Barter_Failure,
								Barter_Failure
							);
							return;
						}
					}
				}

				if (!buyer->PutBarterPurchaseItems(sell_line.item_id, sell_line.seller_quantity)) {
					buyer->Message(Chat::Red, "Unable to place the purchased item in your inventory.");
					SendBarterBuyerClientMessage(
						sell_line,
						Barter_SellerTransactionComplete,
						Barter_Failure,
						Barter_Failure
					);
					return;
				}

				RemoveItem(sell_line.item_id, sell_line.seller_quantity);

				const uint64 total_cost = transaction_value.total_cost;
				AddMoneyToPP(total_cost, false);
				buyer->TakeMoneyFromPP(total_cost, false);

				if (RuleB(Bazaar, AuditTrail)) {
					Bazaar::RecordAuditTrail(
						database,
						GetCleanName(),
						buyer->GetCleanName(),
						sell_line.item_id,
						sell_line.item_name,
						sell_line.seller_quantity,
						total_cost,
						1
					);
				}

				if (PlayerEventLogs::Instance()->IsEventEnabled(PlayerEvent::BARTER_TRANSACTION)) {
					PlayerEvent::BarterTransaction e{};
					e.status        = "Successful Barter Transaction";
					e.item_id       = sell_line.item_id;
					e.item_quantity = sell_line.seller_quantity;
					e.item_name     = sell_line.item_name;
					e.trade_items   = sell_line.trade_items;
					for (auto &t: e.trade_items) {
						t *= sell_line.seller_quantity;
					}
					e.total_cost  = total_cost;
					e.buyer_name  = buyer->GetCleanName();
					e.seller_name = GetCleanName();
					RecordPlayerEventLog(PlayerEvent::BARTER_TRANSACTION, e);
				}

				if (buyer->IsOffline()) {
					auto e         = CharacterOfflineTransactionsRepository::NewEntity();
					e.character_id = buyer->CharacterID();
					e.item_id      = sell_line.item_id;
					e.item_name    = sell_line.item_name;
					e.price        = total_cost;
					e.quantity     = sell_line.seller_quantity;
					e.type         = BARTER_TRANSACTION;
					e.buyer_name   = GetCleanName();

					CharacterOfflineTransactionsRepository::InsertOne(database, e);
				}

				SendWindowUpdatesToSellerAndBuyer(sell_line);
				SendBarterBuyerClientMessage(
					sell_line,
					Barter_SellerTransactionComplete,
					Barter_Success,
					Barter_Success
				);
				buyer->SendBarterBuyerClientMessage(
					sell_line,
					Barter_BuyerTransactionComplete,
					Barter_Success,
					Barter_Success
				);
				break;
			}
			case BarterOutsideBazaar: {
				bool seller_error = false;
				auto buyer_time   = BuyerRepository::GetTransactionDate(database, sell_line.buyer_id);

				if (buyer_time > GetBarterTime()) {
					SendBarterBuyerClientMessage(
						sell_line,
						Barter_SellerTransactionComplete,
						Barter_Failure,
						Barter_DataOutOfDate
					);
					return;
				}

				if (sell_line.trade_items.size() > 0) {
					Message(Chat::Red, "You must visit the buyer directly when receiving compensation items.");
					seller_error = true;
				}

				auto buy_item_slot_id = GetInv().HasItem(
					sell_line.item_id,
					sell_line.seller_quantity,
					invWherePersonal
				);
				auto buy_item = buy_item_slot_id == INVALID_INDEX ? nullptr : GetInv().GetItem(buy_item_slot_id);
				if (!buy_item) {
					SendBarterBuyerClientMessage(
						sell_line,
						Barter_SellerTransactionComplete,
						Barter_Failure,
						Barter_SellerDoesNotHaveItem
					);
					break;
				}

				if (seller_error) {
					LogTradingDetail("Seller Error <red>[{}]  Sell/Buy Transaction Failed.",
									 seller_error
					);
					SendBarterBuyerClientMessage(
						sell_line,
						Barter_SellerTransactionComplete,
						Barter_Failure,
						Barter_Failure
					);
					return;
				}

				BuyerRepository::UpdateTransactionDate(database, sell_line.buyer_id, time(nullptr));

				auto server_packet = std::make_unique<ServerPacket>(
					ServerOP_BuyerMessaging,
					static_cast<uint32>(sizeof(BuyerMessaging_Struct))
				);

				auto data = (BuyerMessaging_Struct *) server_packet->pBuffer;

				data->action           = Barter_SellItem;
				data->buyer_entity_id  = sell_line.buyer_entity_id;
				data->buyer_id         = sell_line.buyer_id;
				data->seller_entity_id = GetID();
				data->buy_item_id      = sell_line.item_id;
				data->buy_item_qty     = sell_line.item_quantity;
				data->buy_item_cost    = sell_line.item_cost;
				data->buy_item_icon    = sell_line.item_icon;
				data->zone_id          = GetZoneID();
				data->slot             = sell_line.slot;
				data->seller_quantity  = sell_line.seller_quantity;
				data->purchase_method  = sell_line.purchase_method;
				strn0cpy(data->item_name, sell_line.item_name, sizeof(data->item_name));
				strn0cpy(data->buyer_name, sell_line.buyer_name.c_str(), sizeof(data->buyer_name));
				strn0cpy(data->seller_name, GetCleanName(), sizeof(data->seller_name));

				worldserver.SendPacket(server_packet.get());

				break;
			}
		}
	}
}

bool Client::PutBarterPurchaseItems(uint32 item_id, uint32 quantity)
{
	const auto *item = database.GetItem(item_id);
	if (!item || quantity == 0 || quantity > static_cast<uint32>(std::numeric_limits<int16>::max())) {
		LogTrading(
			"Unable to create barter purchase item [{}] quantity [{}] for buyer [{}]",
			item_id,
			quantity,
			GetCleanName()
		);
		return false;
	}

	if (!GetInv().HasSpaceForItem(item, static_cast<int16>(quantity))) {
		LogTrading(
			"Buyer [{}] has insufficient inventory space for item [{}] quantity [{}]",
			GetCleanName(),
			item_id,
			quantity
		);
		return false;
	}

	if (item->Stackable) {
		auto inst = std::unique_ptr<EQ::ItemInstance>(
			database.CreateItem(item, static_cast<int16>(quantity))
		);
		return inst && PutItemInInventoryWithStacking(inst.get());
	}

	auto items = Bazaar::CreateBarterPurchaseItems(database, item, quantity);
	if (items.size() != quantity) {
		LogTrading(
			"Failed to create supported, distinct barter purchase items [{}] quantity [{}] for buyer [{}]",
			item_id,
			quantity,
			GetCleanName()
		);
		return false;
	}

	std::vector<std::string> placed_item_ids;
	placed_item_ids.reserve(items.size());
	for (auto &inst : items) {
		if (!PutItemInInventoryWithStacking(inst.get())) {
			LogTrading(
				"Failed to place barter purchase item [{}] for buyer [{}]",
				item_id,
				GetCleanName()
			);

			if (!inst->GetUniqueID().empty()) {
				placed_item_ids.emplace_back(inst->GetUniqueID());
			}

			for (const auto &item_unique_id : placed_item_ids) {
				if (!RemoveItemByItemUniqueId(item_unique_id)) {
					LogError(
						"Failed to roll back barter purchase item [{}] unique_id [{}] for buyer [{}]",
						item_id,
						item_unique_id,
						GetCleanName()
					);
				}
			}

			return false;
		}

		placed_item_ids.emplace_back(inst->GetUniqueID());
	}

	return true;
}

void Client::SendBuyerPacket(Client* Buyer) {

	// This is the Buyer Appearance packet. This method is called for each Buyer when a Client connects to the zone.
	//
	auto outapp = new EQApplicationPacket(OP_Barter, 13 + strlen(Buyer->GetName()));

	char* Buf = (char*)outapp->pBuffer;

	VARSTRUCT_ENCODE_TYPE(uint32, Buf, Barter_BuyerAppearance);
	VARSTRUCT_ENCODE_TYPE(uint32, Buf, Buyer->GetID());
	VARSTRUCT_ENCODE_TYPE(uint32, Buf, 0x01);
	VARSTRUCT_ENCODE_STRING(Buf, Buyer->GetName());

	QueuePacket(outapp);
	safe_delete(outapp);
}

void Client::ToggleBuyerMode(bool status)
{
	auto outapp = std::make_unique<EQApplicationPacket>(
		OP_Barter,
		static_cast<uint32>(sizeof(BuyerSetAppearance_Struct))
	);
	auto data   = (BuyerSetAppearance_Struct *) outapp->pBuffer;

	data->action    = Barter_BuyerAppearance;
	data->entity_id = GetID();

	if (status && IsInBuyerSpace()) {
		SetBuyerID(CharacterID());

		BuyerRepository::Buyer b{};
		b.id                    = 0;
		b.char_id               = GetBuyerID();
		b.char_entity_id        = GetID();
		b.char_zone_id          = GetZoneID();
		b.char_zone_instance_id = GetInstanceID();
		b.char_name             = GetCleanName();
		b.transaction_date      = time(nullptr);
		BuyerRepository::DeleteBuyer(database, GetBuyerID());
		BuyerRepository::InsertOne(database, b);

		data->status = BuyerBarter::On;
		SetCustomerID(0);
		SendBuyerMode(true);
		SendBuyerToBarterWindow(this, Barter_AddToBarterWindow);
		UpdateWho();
		Message(Chat::Yellow, "Barter Mode ON.");
	}
	else {
		data->status = BuyerBarter::Off;
		BuyerRepository::DeleteBuyer(database, GetBuyerID());
		SetCustomerID(0);
		SendBuyerToBarterWindow(this, Barter_RemoveFromBarterWindow);
		SendBuyerMode(false);
		SetBuyerID(0);
		if (!IsInBuyerSpace()) {
			Message(Chat::Red, "You must be in a Barter Stall to start Barter Mode.");
		}

		UpdateWho();
		Message(Chat::Yellow, fmt::format("Barter Mode OFF. Buy lines deactivated.").c_str());
	}

	entity_list.QueueClients(this, outapp.get(), false);
}

void Client::ModifyBuyLine(const EQApplicationPacket *app)
{
	if (ClientVersion() >= EQ::versions::ClientVersion::RoF) {
		BuyerBuyLines_Struct         bl{};
		auto                         in = (BuyerGeneric_Struct *) app->pBuffer;
		EQ::Util::MemoryStreamReader ss_in(
			reinterpret_cast<char *>(in->payload),
			app->size - sizeof(BuyerGeneric_Struct)
		);
		cereal::BinaryInputArchive   ar(ss_in);
		ar(bl);

		if (bl.buy_lines.empty()) {
			return;
		}

		int64 current_total_cost = 0;
		bool  pass               = false;

		auto current_buy_lines = BuyerBuyLinesRepository::GetBuyLines(database, CharacterID());

		std::map<uint32, BuylineItemDetails_Struct> item_map;
		BuildBuyLineMapFromVector(item_map, current_buy_lines);

		auto buy_line = bl.buy_lines.front();
		auto it       = std::find_if(
			current_buy_lines.cbegin(),
			current_buy_lines.cend(),
			[&](BuyerLineItems_Struct bl) {
				return bl.slot == buy_line.slot;
			}
		);

		if (buy_line.item_toggle) {
			const uint64 max_transaction_value =
				EQ::constants::StaticLookup(ClientVersion())->BazaarMaxTransaction;
			const auto transaction_value = Bazaar::ValidateBuyLinePrice(
				buy_line.item_cost,
				max_transaction_value
			);
			if (!transaction_value.is_valid) {
				LogTrading(
					"Rejecting buy line modification over transaction limit [{}] item_cost [{}] quantity [{}] item [{}] buyer [{}]",
					max_transaction_value,
					buy_line.item_cost,
					buy_line.item_quantity,
					buy_line.item_name,
					GetCleanName()
				);
				Message(
					Chat::Red,
					"That would exceed the single transaction limit of %u platinum.",
					static_cast<uint32>(max_transaction_value / 1000)
				);

				if (it != std::end(current_buy_lines)) {
					buy_line = *it;
				}
				else {
					buy_line.item_toggle = 0;
				}

				SendBuyLineUpdate(buy_line);
				return;
			}
		}

		current_total_cost = ValidateBuyLineCost(item_map);
		BuyerRepository::UpdateTransactionDate(database, GetBuyerID(), time(nullptr));

		if (buy_line.item_toggle) {
			current_total_cost +=
				static_cast<int64>(buy_line.item_cost) * static_cast<int64>(buy_line.item_quantity);
			if (it != std::end(current_buy_lines)) {
				current_total_cost -=
					static_cast<int64>(it->item_cost) * static_cast<int64>(it->item_quantity);
				if (current_total_cost > GetCarriedMoney()) {
					buy_line.item_cost     = it->item_cost;
					buy_line.item_quantity = it->item_quantity;
					Message(
						Chat::Red,
						fmt::format(
							"You currently do not have sufficient funds to support your buy lines. You have {} and need {}",
							DetermineMoneyString(GetCarriedMoney()),
							DetermineMoneyString(current_total_cost)).c_str()
					);
					SendBuyLineUpdate(buy_line);
					return;
				}
				else {
					RemoveItemFromBuyLineMap(item_map, *it);
					BuildBuyLineMapFromVector(item_map, bl.buy_lines);
				}
			}
			else {
				BuildBuyLineMapFromVector(item_map, bl.buy_lines);
			}
		}
		else {
			current_total_cost -= static_cast<int64>(buy_line.item_cost) * static_cast<int64>(buy_line.item_quantity);
			std::map<uint32, BuylineItemDetails_Struct> item_map_tmp;
			BuildBuyLineMapFromVector(item_map_tmp, bl.buy_lines);
			if (ValidateBuyLineItems(item_map_tmp)) {
				pass = true;
			}
		}

		if (current_total_cost > static_cast<int64>(GetCarriedMoney())) {
			Message(
				Chat::Red,
				fmt::format(
					"You currently do not have sufficient funds to support your buy lines. You have {} and need {}",
					DetermineMoneyString(GetCarriedMoney()),
					DetermineMoneyString(current_total_cost)).c_str()
			);
			buy_line.item_toggle = 0;
			SendBuyLineUpdate(buy_line);
			return;
		}

		bool buyer_error = false;

		if (!ValidateBuyLineItems(item_map)) {
			buy_line.item_toggle = 0;
		}

		buy_line.item_icon = database.GetItem(buy_line.item_id)->Icon;
		if ((buy_line.item_toggle && it != std::end(current_buy_lines)) || pass) {
			BuyerBuyLinesRepository::ModifyBuyLine(database, buy_line, GetBuyerID());
			Message(Chat::Yellow, fmt::format("Buy line for {} modified.", buy_line.item_name).c_str());
		}
		else if (buy_line.item_toggle && it == std::end(current_buy_lines)) {
			BuyerBuyLinesRepository::CreateBuyLine(database, buy_line, GetBuyerID());
			Message(Chat::Yellow, fmt::format("Buy line for {} enabled.", buy_line.item_name).c_str());
		}
		else if (!buy_line.item_toggle) {
			BuyerBuyLinesRepository::DeleteBuyLine(database, GetBuyerID(), buy_line.slot);
			Message(Chat::Yellow, fmt::format("Buy line for {} disabled.", buy_line.item_name).c_str());
		}
		else {
			BuyerBuyLinesRepository::DeleteBuyLine(database, GetBuyerID(), buy_line.slot);
			Message(
				Chat::Yellow,
				fmt::format("Unhandled modification.  Buy line for {} disabled.", buy_line.item_name).c_str());
		}

		SendBuyLineUpdate(buy_line);

		if (IsThereACustomer()) {
			auto customer = entity_list.GetClientByID(GetCustomerID());
			if (!customer) {
				return;
			}

			auto it = std::find_if(
				current_buy_lines.cbegin(),
				current_buy_lines.cend(),
				[&](BuyerLineItems_Struct bl) {
					return bl.slot == buy_line.slot;
				}
			);
			if (it == std::end(current_buy_lines) && !buy_line.item_toggle) {
				return;
			}

			std::stringstream           ss_customer{};
			cereal::BinaryOutputArchive ar_customer(ss_customer);

			BuyerLineItems_Struct blis{};
			blis.enabled       = buy_line.enabled;
			blis.item_cost     = buy_line.item_cost;
			blis.item_icon     = buy_line.item_icon;
			blis.item_id       = buy_line.item_id;
			blis.item_quantity = buy_line.item_quantity;
			blis.item_toggle   = buy_line.item_toggle;
			blis.slot          = buy_line.slot;
			blis.item_name     = buy_line.item_name;
			for (auto const &i: buy_line.trade_items) {
				BuyerLineTradeItems_Struct bltis{};
				bltis.item_icon     = i.item_icon;
				bltis.item_id       = i.item_id;
				bltis.item_quantity = i.item_quantity;
				bltis.item_name     = i.item_name;
				blis.trade_items.push_back(bltis);
			}

			{ ar_customer(blis); }

			auto packet = std::make_unique<EQApplicationPacket>(
				OP_BuyerItems,
				static_cast<uint32>(ss_customer.str().length()) + static_cast<uint32>(sizeof(BuyerGeneric_Struct))
			);
			auto emu    = (BuyerGeneric_Struct *) packet->pBuffer;

			emu->action = Barter_BuyerInspectBegin;
			memcpy(emu->payload, ss_customer.str().data(), ss_customer.str().length());

			customer->QueuePacket(packet.get());

			ss_customer.str("");
			ss_customer.clear();
		}
	}
	return;
}

void Client::BuyerItemSearch(const EQApplicationPacket *app)
{
	auto               bis   = (BuyerItemSearch_Struct *) app->pBuffer;
	const EQ::ItemData *item = 0;
	uint32             it    = 0;

	BuyerItemSearchResults_Struct bisr{};
	const std::string             search_string = Strings::ToLower(bis->search_string);
	const bool                    filter_discovered_items = RuleB(Character, EnableDiscoveredItems);

	std::unordered_set<uint32_t> discovered_item_ids;
	if (filter_discovered_items) {
		discovered_item_ids = DiscoveredItemsRepository::GetAllItemIDs(database);
	}

	while ((item = database.IterateItems(&it)) && bisr.results.size() < RuleI(Bazaar, MaxBuyerInventorySearchResults)) {
		if (!item->NoDrop) {
			continue;
		}

		if (filter_discovered_items && !discovered_item_ids.contains(item->ID)) {
			continue;
		}

		auto item_name_match = std::strstr(
			Strings::ToLower(item->Name).c_str(),
			search_string.c_str()
		);

		if (item_name_match) {
			BuyerItemSearchResultEntry_Struct bisre{};
			bisre.item_id   = item->ID;
			bisre.item_icon = item->Icon;
			strn0cpy(bisre.item_name, item->Name, sizeof(bisre.item_name));
			bisr.results.push_back(bisre);
		}
	}

	bisr.action       = Barter_BuyerSearchResults;
	bisr.result_count = bisr.results.size();

	std::stringstream           ss{};
	cereal::BinaryOutputArchive ar(ss);
	{ ar(bisr); }

	uint32 packet_size = sizeof(BuyerGeneric_Struct) + ss.str().length();
	auto   outapp      = std::make_unique<EQApplicationPacket>(OP_Barter, packet_size);
	auto   emu         = (BuyerGeneric_Struct *) outapp->pBuffer;

	emu->action = Barter_BuyerSearchResults;
	memcpy(emu->payload, ss.str().data(), ss.str().length());

	QueuePacket(outapp.get());

	ss.str("");
	ss.clear();
}

const std::string &Client::GetMailKeyFull() const
{
	return m_mail_key_full;
}

const std::string &Client::GetMailKey() const
{
	return m_mail_key;
}

void Client::SendBecomeTraderToWorld(Client *trader, BazaarTraderBarterActions action)
{
	auto outapp = new ServerPacket(ServerOP_TraderMessaging, sizeof(TraderMessaging_Struct));
	auto data   = (TraderMessaging_Struct *) outapp->pBuffer;

	data->action      = action;
	data->entity_id   = trader->GetID();
	data->trader_id   = trader->CharacterID();
	data->zone_id     = trader->GetZoneID();
	data->instance_id = trader->GetInstanceID();
	strn0cpy(data->trader_name, trader->GetName(), sizeof(data->trader_name));

	worldserver.SendPacket(outapp);
	safe_delete(outapp);
}

void Client::SendBecomeTrader(BazaarTraderBarterActions action, uint32 entity_id)
{
	if (entity_id <= 0) {
		return;
	}

	auto trader = entity_list.GetClientByID(entity_id);
	if (!trader) {
		return;
	}

	auto outapp = new EQApplicationPacket(OP_BecomeTrader, sizeof(BecomeTrader_Struct));
	auto data   = (BecomeTrader_Struct *) outapp->pBuffer;

	data->action           = action;
	data->entity_id        = trader->GetID();
	data->trader_id        = trader->CharacterID();
	data->zone_id          = trader->GetZoneID();
	data->zone_instance_id = trader->GetInstanceID();
	strn0cpy(data->trader_name, trader->GetCleanName(), sizeof(data->trader_name));

	LogTrading(
		"Sending OP_BecomeTrader to client [{}] account [{}] character [{}] action [{}] trader_entity [{}] trader_character [{}] trader_zone [{}] trader_instance [{}]",
		GetCleanName(),
		AccountID(),
		CharacterID(),
		static_cast<uint32>(action),
		data->entity_id,
		data->trader_id,
		data->zone_id,
		data->zone_instance_id
	);

	QueuePacket(outapp);
	safe_delete(outapp);
}

void Client::SendTraderMode(BazaarTraderBarterActions status)
{
	auto outapp = new EQApplicationPacket(OP_Trader, sizeof(Trader_ShowItems_Struct));
	auto data   = (Trader_ShowItems_Struct *) outapp->pBuffer;

	data->action    = status;
	data->entity_id = GetID();

	LogTrading(
		"Sending OP_Trader mode packet to client [{}] account [{}] character [{}] status [{}] entity [{}] zone [{}] instance [{}]",
		GetCleanName(),
		AccountID(),
		CharacterID(),
		static_cast<uint32>(status),
		data->entity_id,
		GetZoneID(),
		GetInstanceID()
	);

	QueuePacket(outapp);
	safe_delete(outapp);
}

static bool IsTraderPlaceholderUniqueID(const std::string &item_unique_id)
{
	return item_unique_id.empty() || item_unique_id == "0000000000000000";
}

static std::vector<EQ::ItemInstance *> FindTraderPriceUpdateItems(Client *trader, EQ::ItemInstance *selected_item)
{
	std::vector<EQ::ItemInstance *> items{};
	if (!trader || !selected_item) {
		return items;
	}

	const uint32 selected_item_id      = selected_item->GetID();
	const auto   selected_unique_id    = selected_item->GetUniqueID();
	const bool   update_matching_items = !selected_item->IsStackable();
	const auto   max_items             = trader->GetInv().GetLookup()->InventoryTypeSize.Bazaar;
	size_t       scanned_items         = 0;

	for (int16 i = EQ::invslot::GENERAL_BEGIN; i <= EQ::invslot::GENERAL_END; i++) {
		if (scanned_items >= max_items) {
			break;
		}

		auto container = trader->GetInv().GetItem(i);
		if (!container || !container->GetItem() || container->GetItem()->BagType != EQ::item::BagTypeTradersSatchel) {
			continue;
		}

		for (int16 x = EQ::invbag::SLOT_BEGIN; x <= EQ::invbag::SLOT_END; x++) {
			if (scanned_items >= max_items) {
				break;
			}

			const int16 slot_id = EQ::InventoryProfile::CalcSlotId(i, x);
			auto        item    = trader->GetInv().GetItem(slot_id);
			if (!item) {
				continue;
			}

			scanned_items++;
			if (
				(update_matching_items && !item->IsStackable() && item->GetID() == selected_item_id) ||
				(!update_matching_items && item->GetUniqueID() == selected_unique_id)
			) {
				items.push_back(item);
			}
		}
	}

	return items;
}

static TraderRepository::Trader BuildTraderItemRow(
	Client *trader,
	EQ::ItemInstance *item,
	uint32 price,
	uint8 slot_id,
	const TraderRepository::Trader *existing_entry = nullptr
)
{
	TraderRepository::Trader entry = existing_entry ? *existing_entry : TraderRepository::Trader{};
	if (!trader || !item) {
		return entry;
	}

	if (!existing_entry) {
		entry.id = 0;
	}

	entry.char_entity_id        = trader->GetID();
	entry.character_id          = trader->CharacterID();
	entry.char_zone_id          = trader->GetZoneID();
	entry.char_zone_instance_id = trader->GetInstanceID();
	entry.item_charges          = item->GetCharges();
	entry.item_cost             = price;
	entry.item_id               = item->GetID();
	entry.item_unique_id        = item->GetUniqueID();
	entry.slot_id               = slot_id;
	entry.listing_date          = time(nullptr);
	entry.augment_one           = 0;
	entry.augment_two           = 0;
	entry.augment_three         = 0;
	entry.augment_four          = 0;
	entry.augment_five          = 0;
	entry.augment_six           = 0;
	if (item->IsAugmented()) {
		auto augs           = item->GetAugmentIDs();
		entry.augment_one   = augs.at(0);
		entry.augment_two   = augs.at(1);
		entry.augment_three = augs.at(2);
		entry.augment_four  = augs.at(3);
		entry.augment_five  = augs.at(4);
		entry.augment_six   = augs.at(5);
	}

	return entry;
}

static bool DeleteTraderRows(
	Database &db,
	const std::string &where_filter,
	size_t expected_rows,
	std::string &error_message
)
{
	const auto result = db.QueryDatabase(
		fmt::format(
			"DELETE FROM {} WHERE {}",
			TraderRepository::TableName(),
			where_filter
		)
	);

	if (!result.Success()) {
		error_message = result.ErrorMessage();
		return false;
	}

	if (static_cast<size_t>(result.RowsAffected()) != expected_rows) {
		error_message = fmt::format(
			"deleted [{}] rows, expected [{}]",
			result.RowsAffected(),
			expected_rows
		);
		return false;
	}

	return true;
}

static EQ::ItemInstance *FindMatchingTraderItem(
	const std::vector<EQ::ItemInstance *> &items,
	const std::string &item_unique_id
)
{
	auto iter = std::find_if(
		items.begin(),
		items.end(),
		[&item_unique_id](const EQ::ItemInstance *item) {
			return item && item->GetUniqueID() == item_unique_id;
		}
	);

	return iter != items.end() ? *iter : nullptr;
}

void Client::TraderUpdateItem(const EQApplicationPacket *app)
{
	auto   in        = reinterpret_cast<TraderPriceUpdate_Struct *>(app->pBuffer);
	uint32 new_price = in->new_price;
	auto   inst      = FindTraderItemByUniqueID(in->item_unique_id);
	auto   customer  = entity_list.GetClientByID(GetCustomerID());

	if (!inst) {
		LogError("Trader {} attempted to update missing item_unique_id {}", CharacterID(), in->item_unique_id);
		in->sub_action = BazaarPriceChange_Fail;
		QueuePacket(app);
		return;
	}

	auto target_items = FindTraderPriceUpdateItems(this, inst);
	if (target_items.empty()) {
		target_items.push_back(inst);
	}

	std::unordered_set<std::string> target_unique_ids{};
	target_unique_ids.reserve(target_items.size());
	for (auto *item: target_items) {
		if (!item) {
			continue;
		}

		const auto item_unique_id = item->GetUniqueID();
		if (IsTraderPlaceholderUniqueID(item_unique_id)) {
			LogError(
				"Trader {} attempted to update item {} with an invalid unique_id [{}]",
				CharacterID(),
				item->GetID(),
				item_unique_id
			);
			in->sub_action = BazaarPriceChange_Fail;
			QueuePacket(app);
			return;
		}

		if (!target_unique_ids.insert(item_unique_id).second) {
			LogError(
				"Trader {} attempted to update item {} with duplicate unique_id [{}]",
				CharacterID(),
				item->GetID(),
				item_unique_id
			);
			in->sub_action = BazaarPriceChange_Fail;
			QueuePacket(app);
			return;
		}
	}

	const bool update_matching_items = !inst->IsStackable();
	const auto where_filter = update_matching_items ?
		fmt::format(
			"`character_id` = {} AND `item_id` = {}",
			CharacterID(),
			inst->GetID()
		) :
		fmt::format(
			"`character_id` = {} AND `item_unique_id` = '{}'",
			CharacterID(),
			Strings::Escape(inst->GetUniqueID())
		);

	auto existing_entries = TraderRepository::GetWhere(database, where_filter);
	auto has_active_transaction = std::any_of(
		existing_entries.begin(),
		existing_entries.end(),
		[](const TraderRepository::Trader &entry) {
			return entry.active_transaction != TraderRepository::ACTIVE_TRANSACTION_NONE;
		}
	);
	if (has_active_transaction) {
		LogTrading(
			"Trader {} attempted to update item {} while a matching trader row has an active transaction",
			CharacterID(),
			inst->GetID()
		);
		Message(Chat::Red, "You cannot change this trader listing while it is part of an active transaction.");
		in->sub_action = BazaarPriceChange_Fail;
		QueuePacket(app);
		return;
	}

	const auto delete_filter = fmt::format(
		"({}) AND `active_transaction` = {}",
		where_filter,
		TraderRepository::ACTIVE_TRANSACTION_NONE
	);

	if (new_price == 0) {
		const auto begin_result = database.TransactionBegin();
		if (!begin_result.Success()) {
			LogError(
				"Trader {} failed to begin price removal transaction for item {}: {}",
				CharacterID(),
				inst->GetID(),
				begin_result.ErrorMessage()
			);
			in->sub_action = BazaarPriceChange_Fail;
			QueuePacket(app);
			return;
		}

		std::string delete_error_message;
		if (!DeleteTraderRows(database, delete_filter, existing_entries.size(), delete_error_message)) {
			database.TransactionRollback();
			LogError(
				"Trader {} failed to remove trader rows for item {}: {}",
				CharacterID(),
				inst->GetID(),
				delete_error_message
			);
			in->sub_action = BazaarPriceChange_Fail;
			QueuePacket(app);
			return;
		}

		const auto commit_result = database.TransactionCommit();
		if (!commit_result.Success()) {
			database.TransactionRollback();
			LogError(
				"Trader {} failed to commit price removal transaction for item {}: {}",
				CharacterID(),
				inst->GetID(),
				commit_result.ErrorMessage()
			);
			in->sub_action = BazaarPriceChange_Fail;
			QueuePacket(app);
			return;
		}

		for (auto *item: target_items) {
			if (item) {
				item->SetPrice(0);
			}
		}

		in->sub_action = BazaarPriceChange_RemoveItem;
		QueuePacket(app);

		if (customer) {
			auto list          = customer->GetTraderMerchantList();
			auto client_packet =
				new EQApplicationPacket(OP_ShopDelItem, static_cast<uint32>(sizeof(Merchant_DelItem_Struct)));

			auto client_data      = reinterpret_cast<struct Merchant_DelItem_Struct *>(client_packet->pBuffer);
			client_data->npcid    = GetID();
			client_data->playerid = customer->GetID();

			for (auto const [slot_id, merchant_data]: *list) {
				auto const [item_id, merchant_quantity, item_unique_id] = merchant_data;
				if (
					(update_matching_items && item_id == inst->GetID()) ||
					(!update_matching_items && item_unique_id == inst->GetUniqueID())
				) {
					client_data->itemslot = slot_id;
					customer->QueuePacket(client_packet);
					(*list)[slot_id] = std::make_tuple(0, 0, "0000000000000000");
				}
			}
			safe_delete(client_packet);

			customer->Message(
				Chat::Red,
				fmt::format(
					"Trader {} removed item {} from the bazaar.  Item no longer available.",
					GetCleanName(),
					inst->GetItem()->Name
					).c_str()
			);
			LogTrading("Trader removed item from trader list with item_unique_id {}", in->item_unique_id);
		}

		TraderShowItems();
		return;
	}

	std::unordered_map<std::string, TraderRepository::Trader> existing_entries_by_unique_id{};
	existing_entries_by_unique_id.reserve(existing_entries.size());
	std::unordered_set<uint64_t> replacing_entry_ids{};
	replacing_entry_ids.reserve(existing_entries.size());
	for (auto const &entry: existing_entries) {
		existing_entries_by_unique_id[entry.item_unique_id] = entry;
		if (entry.id) {
			replacing_entry_ids.insert(entry.id);
		}
	}

	const auto all_trader_entries = TraderRepository::GetWhere(
		database,
		fmt::format("`character_id` = {}", CharacterID())
	);
	std::unordered_set<uint8> used_slot_ids{};
	for (auto const &entry: all_trader_entries) {
		if (!entry.slot_id || replacing_entry_ids.contains(entry.id)) {
			continue;
		}

		used_slot_ids.insert(entry.slot_id);
	}

	for (auto const &entry: existing_entries) {
		if (entry.slot_id && target_unique_ids.contains(entry.item_unique_id)) {
			used_slot_ids.insert(entry.slot_id);
		}
	}

	auto next_slot_id = [&used_slot_ids, this]() -> uint8 {
		const auto max_items = GetInv().GetLookup()->InventoryTypeSize.Bazaar;
		for (uint16 slot_id = 1; slot_id <= max_items && slot_id <= UINT8_MAX; slot_id++) {
			if (!used_slot_ids.contains(static_cast<uint8>(slot_id))) {
				used_slot_ids.insert(static_cast<uint8>(slot_id));
				return static_cast<uint8>(slot_id);
			}
		}

		return 0;
	};

	std::vector<TraderRepository::Trader> queue{};
	queue.reserve(target_items.size());
	for (auto *item: target_items) {
		if (!item) {
			continue;
		}

		auto existing_entry = existing_entries_by_unique_id.find(item->GetUniqueID());
		uint8 slot_id = existing_entry != existing_entries_by_unique_id.end() ? existing_entry->second.slot_id : 0;
		if (!slot_id) {
			slot_id = next_slot_id();
			if (!slot_id) {
				LogError(
					"Trader {} could not allocate a trader slot while updating price for item {} unique_id {}",
					CharacterID(),
					item->GetID(),
					item->GetUniqueID()
				);
				in->sub_action = BazaarPriceChange_Fail;
				QueuePacket(app);
				return;
			}
		}

		queue.push_back(
			BuildTraderItemRow(
				this,
				item,
				new_price,
				slot_id,
				existing_entry != existing_entries_by_unique_id.end() ? &existing_entry->second : nullptr
			)
		);
	}

	std::unordered_set<std::string> queued_unique_ids{};
	queued_unique_ids.reserve(queue.size());
	for (auto const &i: queue) {
		queued_unique_ids.insert(i.item_unique_id);
	}

	auto is_affected_merchant_slot = [update_matching_items, inst](uint32 item_id, const std::string &item_unique_id) {
		return (
			(update_matching_items && item_id == inst->GetID()) ||
			(!update_matching_items && item_unique_id == inst->GetUniqueID())
		);
	};

	std::unordered_map<std::string, int16> customer_merchant_slots_by_unique_id{};
	if (customer) {
		auto list = customer->GetTraderMerchantList();
		std::unordered_set<int16> reserved_merchant_slots{};
		std::unordered_set<int16> reusable_merchant_slots{};
		for (auto const &[slot_id, merchant_data]: *list) {
			const auto [item_id, quantity, item_unique_id] = merchant_data;
			if (!item_id) {
				continue;
			}

			if (is_affected_merchant_slot(item_id, item_unique_id) && !queued_unique_ids.contains(item_unique_id)) {
				reusable_merchant_slots.insert(slot_id);
				continue;
			}

			reserved_merchant_slots.insert(slot_id);
		}

		auto next_merchant_slot = [customer, list, &reserved_merchant_slots, &reusable_merchant_slots]() -> int16 {
			for (auto const &[slot_id, merchant_data]: *list) {
				const auto [item_id, quantity, item_unique_id] = merchant_data;
				if ((!item_id || reusable_merchant_slots.contains(slot_id)) && !reserved_merchant_slots.contains(slot_id)) {
					reserved_merchant_slots.insert(slot_id);
					return slot_id;
				}
			}

			const auto max_items = customer->GetInv().GetLookup()->InventoryTypeSize.Bazaar;
			for (int16 slot_id = 1; slot_id <= max_items; slot_id++) {
				if (!list->contains(slot_id) && !reserved_merchant_slots.contains(slot_id)) {
					reserved_merchant_slots.insert(slot_id);
					return slot_id;
				}
			}

			return INVALID_INDEX;
		};

		for (auto const &entry: queue) {
			auto [slot_id, merchant_data] = customer->GetDataFromMerchantListByItemUniqueId(entry.item_unique_id);
			if (slot_id == INVALID_INDEX) {
				slot_id = next_merchant_slot();
			}
			else {
				reserved_merchant_slots.insert(slot_id);
			}

			if (slot_id == INVALID_INDEX) {
				LogError(
					"Trader {} could not allocate a customer merchant slot while updating price for item {} unique_id {}",
					CharacterID(),
					entry.item_id,
					entry.item_unique_id
				);
				in->sub_action = BazaarPriceChange_Fail;
				QueuePacket(app);
				return;
			}

			customer_merchant_slots_by_unique_id[entry.item_unique_id] = slot_id;
		}
	}

	const auto begin_result = database.TransactionBegin();
	if (!begin_result.Success()) {
		LogError(
			"Trader {} failed to begin price update transaction for item {} price {}: {}",
			CharacterID(),
			inst->GetID(),
			new_price,
			begin_result.ErrorMessage()
		);
		in->sub_action = BazaarPriceChange_Fail;
		QueuePacket(app);
		return;
	}

	std::string delete_error_message;
	if (!DeleteTraderRows(database, delete_filter, existing_entries.size(), delete_error_message)) {
		database.TransactionRollback();
		LogError(
			"Trader {} failed to delete old trader rows for item {} price {}: {}",
			CharacterID(),
			inst->GetID(),
			new_price,
			delete_error_message
		);
		in->sub_action = BazaarPriceChange_Fail;
		QueuePacket(app);
		return;
	}

	if (!queue.empty()) {
		const int replaced_rows = TraderRepository::ReplaceMany(database, queue);
		if (replaced_rows < static_cast<int>(queue.size())) {
			database.TransactionRollback();
			LogError(
				"Trader {} failed to save all price updates for item {} price {} replaced_rows {} expected {}",
				CharacterID(),
				inst->GetID(),
				new_price,
				replaced_rows,
				queue.size()
			);
			in->sub_action = BazaarPriceChange_Fail;
			QueuePacket(app);
			return;
		}
	}

	const auto commit_result = database.TransactionCommit();
	if (!commit_result.Success()) {
		database.TransactionRollback();
		LogError(
			"Trader {} failed to commit price update transaction for item {} price {}: {}",
			CharacterID(),
			inst->GetID(),
			new_price,
			commit_result.ErrorMessage()
		);
		in->sub_action = BazaarPriceChange_Fail;
		QueuePacket(app);
		return;
	}

	for (auto *item: target_items) {
		if (item) {
			item->SetPrice(new_price);
		}
	}

	if (customer) {
		auto list       = customer->GetTraderMerchantList();
		auto del_packet = new EQApplicationPacket(
			OP_ShopDelItem,
			static_cast<uint32>(sizeof(Merchant_DelItem_Struct))
		);

		auto del_data      = reinterpret_cast<Merchant_DelItem_Struct *>(del_packet->pBuffer);
		del_data->npcid    = GetID();
		del_data->playerid = customer->GetID();

		for (auto const &[slot_id, merchant_data]: *list) {
			const auto [item_id, merchant_quantity, item_unique_id] = merchant_data;
			const bool affected_slot = is_affected_merchant_slot(item_id, item_unique_id);

			if (affected_slot && !queued_unique_ids.contains(item_unique_id)) {
				del_data->itemslot = slot_id;
				customer->QueuePacket(del_packet);
				(*list)[slot_id] = std::make_tuple(0, 0, "0000000000000000");
			}
		}

		safe_delete(del_packet);

		for (auto const &i: queue) {
			auto source_item = FindMatchingTraderItem(target_items, i.item_unique_id);
			if (!source_item) {
				continue;
			}

			auto merchant_slot = customer_merchant_slots_by_unique_id.find(i.item_unique_id);
			if (merchant_slot == customer_merchant_slots_by_unique_id.end()) {
				LogError(
					"Trader {} missing preflighted customer merchant slot for item {} unique_id {}",
					CharacterID(),
					i.item_id,
					i.item_unique_id
				);
				continue;
			}

			const auto slot_id = merchant_slot->second;
			(*list)[slot_id] = std::make_tuple(
				i.item_id,
				source_item->IsStackable() ? i.item_charges : 1,
				i.item_unique_id
			);

			std::unique_ptr<EQ::ItemInstance> vendor_inst_copy(source_item->Clone());
			if (!vendor_inst_copy) {
				continue;
			}

			vendor_inst_copy->SetUniqueID(i.item_unique_id);
			vendor_inst_copy->SetMerchantCount(source_item->IsStackable() ? i.item_charges : 1);
			vendor_inst_copy->SetMerchantSlot(slot_id);
			vendor_inst_copy->SetPrice(new_price);
			customer->SendItemPacket(slot_id, vendor_inst_copy.get(), ItemPacketMerchant);
		}

		customer->Message(
			Chat::Red,
			fmt::format("Trader {} updated the price of item {}", GetCleanName(), inst->GetItem()->Name).c_str()
		);
	}

	in->sub_action = BazaarPriceChange_UpdatePrice;
	QueuePacket(app);
	TraderShowItems();
}

void Client::SendBazaarDone(uint32 trader_id)
{
	auto outapp2 = new EQApplicationPacket(OP_BazaarSearch, sizeof(BazaarReturnDone_Struct));
	auto brds    = (BazaarReturnDone_Struct *) outapp2->pBuffer;

	brds->TraderID   = trader_id;
	brds->Type       = BazaarSearchDone;
	brds->Unknown008 = 0xFFFFFFFF;
	brds->Unknown012 = 0xFFFFFFFF;
	brds->Unknown016 = 0xFFFFFFFF;

	QueuePacket(outapp2);
	safe_delete(outapp2);
}

void Client::SendBulkBazaarTraders()
{
	if (ClientVersion() < EQ::versions::ClientVersion::RoF2) {
		return;
	}

	TraderRepository::BulkTraders_Struct results{};

	if (RuleB(Bazaar, UseAlternateBazaarSearch))
	{
		if (GetZoneID() == Zones::BAZAAR) {
			results = TraderRepository::GetDistinctTraders(database, GetInstanceID());
		}

		uint32 number = 1;
		auto   shards = CharacterDataRepository::GetInstanceZonePlayerCounts(database, Zones::BAZAAR);
		for (auto const &shard: shards) {
			if (GetZoneID() != Zones::BAZAAR || (GetZoneID() == Zones::BAZAAR && GetInstanceID() != shard.instance_id)) {

				TraderRepository::DistinctTraders_Struct t{};
				t.entity_id        = 0;
				t.trader_id        = TraderRepository::TRADER_CONVERT_ID + shard.instance_id;
				t.trader_name      = fmt::format("Bazaar Shard {}", number);
				t.zone_id          = Zones::BAZAAR;
				t.zone_instance_id = shard.instance_id;
				results.count += 1;
				results.name_length += t.trader_name.length() + 1;
				results.traders.push_back(t);
			}

			number++;
		}
	}
	else {
		results = TraderRepository::GetDistinctTraders(
			database,
			GetInstanceID(),
			EQ::constants::StaticLookup(ClientVersion())->BazaarTraderLimit
		);
	}

	SetTraderCount(results.count);

	auto  p_size  = 4 + 12 * results.count + results.name_length;
	auto  buffer  = std::make_unique<char[]>(p_size);
	memset(buffer.get(), 0, p_size);
	char *bufptr  = buffer.get();

	VARSTRUCT_ENCODE_TYPE(uint32, bufptr, results.count);

	for (auto t : results.traders) {
		VARSTRUCT_ENCODE_TYPE(uint16, bufptr, t.zone_id);
		VARSTRUCT_ENCODE_TYPE(uint16, bufptr, t.zone_instance_id);
		VARSTRUCT_ENCODE_TYPE(uint32, bufptr, t.trader_id);
		VARSTRUCT_ENCODE_TYPE(uint32, bufptr, t.entity_id);
		VARSTRUCT_ENCODE_STRING(bufptr, t.trader_name.c_str());
	}

	auto outapp = std::make_unique<EQApplicationPacket>(OP_TraderBulkSend, p_size);
	memcpy(outapp->pBuffer, buffer.get(), p_size);

	QueuePacket(outapp.get());
}

void Client::DoBazaarInspect(BazaarInspect_Struct &in)
{
	auto items = TraderRepository::GetWhere(
		database, fmt::format("`item_unique_id` = '{}'", in.item_unique_id)
	);

	if (items.empty()) {
		LogTrading("Failed to find item with serial number [{}]", in.item_unique_id);
		return;
	}

	auto &item = items.front();

	std::unique_ptr<EQ::ItemInstance> inst(
		database.CreateItem(
			item.item_id,
			item.item_charges,
			item.augment_one,
			item.augment_two,
			item.augment_three,
			item.augment_four,
			item.augment_five,
			item.augment_six
		)
	);

	if (inst) {
		SendItemPacket(0, inst.get(), ItemPacketViewLink);
	}
}

void Client::SendBazaarDeliveryCosts()
{
	auto outapp = std::make_unique<EQApplicationPacket>(
		OP_BazaarSearch,
		static_cast<uint32>(sizeof(BazaarDeliveryCost_Struct))
	);
	auto data   = (BazaarDeliveryCost_Struct *) outapp->pBuffer;

	data->action                = DeliveryCostUpdate;
	data->voucher_delivery_cost = RuleI(Bazaar, VoucherDeliveryCost);
	data->parcel_deliver_cost   = RuleR(Bazaar, ParcelDeliveryCostMod);

	QueuePacket(outapp.get());
}

std::string Client::DetermineMoneyString(uint64 cp)
{
	uint32 plat   = cp / 1000;
	uint32 gold   = (cp - plat * 1000) / 100;
	uint32 silver = (cp - plat * 1000 - gold * 100) / 10;
	uint32 copper = (cp - plat * 1000 - gold * 100 - silver * 10);

	if (!plat && !gold && !silver && !copper) {
		return std::string("No Money");
	}

	std::string money {};
	if (plat) {
		money += fmt::format("{}p ", plat);
	}
	if (gold) {
		money += fmt::format("{}g ", gold);
	}
	if (silver) {
		money += fmt::format("{}s ", silver);
	}
	if (copper) {
		money += fmt::format("{}c", copper);
	}

	return fmt::format("{}", money);
}

void Client::BuyTraderItemFromBazaarWindow(const EQApplicationPacket *app)
{
	auto in          = reinterpret_cast<TraderBuy_Struct *>(app->pBuffer);
	auto trader_item = TraderRepository::GetItemByItemUniqueNumber(database, in->item_unique_id);

	LogTradingDetail(
		"Packet details: \n"
		"Action         :{}\n"
		"Method         :{}\n"
		"SubAction      :{}\n"
		"Unknown_012    :{}\n"
		"Trader ID      :{}\n"
		"Buyer Name     :{}\n"
		"Seller Name    :{}\n"
		"Unknown_148    :{}\n"
		"Item Name      :{}\n"
		"Item Unique ID :{}\n"
		"Unknown_261    :{}\n"
		"Item ID        :{}\n"
		"Price          :{}\n"
		"Already Sold   :{}\n"
		"Unknown_276    :{}\n"
		"Quantity       :{}\n",
		in->action,
		in->method,
		in->sub_action,
		in->unknown_012,
		in->trader_id,
		in->buyer_name,
		in->seller_name,
		in->unknown_148,
		in->item_name,
		in->item_unique_id,
		in->unknown_261,
		in->item_id,
		in->price,
		in->already_sold,
		in->unknown_276,
		in->quantity
	);

	if (!trader_item.id || GetTraderTransactionDate() < trader_item.listing_date) {
		LogTrading("Attempt to purchase an item outside of the Bazaar trader_id [{}] item unique_id "
				   "[{}] The Traders data was outdated.",
				   in->trader_id,
				   in->item_unique_id
		);
		in->method     = BazaarByParcel;
		in->sub_action = DataOutDated;
		TradeRequestFailed(app);
		return;
	}

	if (trader_item.active_transaction) {
		LogTrading("Attempt to purchase an item outside of the Bazaar trader_id [{}] item serial_number "
				   "[{}] The item is already within an active transaction.",
				   in->trader_id,
				   in->item_unique_id
		);
		in->method     = BazaarByParcel;
		in->sub_action = DataOutDated;
		TradeRequestFailed(app);
		return;
	}

	auto item = database.GetItem(trader_item.item_id);
	if (!item) {
		LogTrading("Unable to find item id [{}] item unique_id [{}] for bazaar purchase", trader_item.item_id, in->item_unique_id);
		in->method     = BazaarByParcel;
		in->sub_action = Failed;
		TradeRequestFailed(app);
		return;
	}

	auto quantity_validation = Bazaar::ValidatePurchaseQuantity(in->quantity, item->Stackable, trader_item.item_charges);
	if (!quantity_validation.is_valid) {
		LogTrading(
			"Rejecting bazaar purchase with invalid quantity [{}] for item [{}]",
			in->quantity,
			item->Name
		);
		in->method     = BazaarByParcel;
		in->sub_action = Failed;
		TradeRequestFailed(app);
		return;
	}

	uint32 quantity = quantity_validation.quantity;
	in->quantity = quantity;

	if (!Bazaar::ValidatePurchasePrice(in->price, trader_item.item_cost)) {
		LogTrading(
			"Rejecting bazaar purchase with invalid price [{}] listed price [{}] for item [{}]",
			in->price,
			trader_item.item_cost,
			item->Name
		);
		in->method     = BazaarByParcel;
		in->sub_action = Failed;
		TradeRequestFailed(app);
		return;
	}

	uint32 price = trader_item.item_cost;
	in->price = price;

	auto next_slot = FindNextFreeParcelSlot(CharacterID());
	if (next_slot == INVALID_INDEX) {
		LogTrading(
			"{} attempted to purchase {} from the bazaar with parcel delivery.  Unfortunately their parcel limit was "
			"reached. Purchase unsuccessful.",
			GetCleanName(),
			in->item_name
		);
		in->method     = BazaarByParcel;
		in->sub_action = TooManyParcels;
		TraderRepository::UpdateActiveTransaction(database, trader_item.id, false);
		TradeRequestFailed(app);
		return;
	}

	if (!TraderRepository::StartActiveTransaction(database, trader_item.id, in->item_unique_id)) {
		LogTrading(
			"Rejecting bazaar parcel purchase for item unique_id [{}] because the listing is already in an active transaction",
			in->item_unique_id
		);
		in->method     = BazaarByParcel;
		in->sub_action = TransactionInProgress;
		TradeRequestFailed(app);
		return;
	}

	int16 charges   = 1;
	if (trader_item.item_charges > 0 || item->Stackable || item->MaxCharges > 0) {
		charges = trader_item.item_charges;
	}

	LogTradingDetail(
		"Step 1:Bazaar Purchase.  Buyer [{}] Seller [{}] Quantity [{}] Charges [{}] Item_Unique_ID [{}]",
		CharacterID(),
		in->trader_id,
		quantity,
		charges,
		in->item_unique_id
	);

	const uint64 max_transaction_value = EQ::constants::StaticLookup(ClientVersion())->BazaarMaxTransaction;
	uint64 total_cost = static_cast<uint64>(price) * static_cast<uint64>(quantity);
	if (total_cost > max_transaction_value) {
		const auto max_transaction_amount = Strings::Money(max_transaction_value / 1000);
		Message(Chat::Red, fmt::format(
			"That would exceed the single transaction limit of {}.",
			max_transaction_amount
		).c_str());
		TraderRepository::UpdateActiveTransaction(database, trader_item.id, false);
		TradeRequestFailed(app);
		return;
	}

	uint64 fee = std::round(total_cost * RuleR(Bazaar, ParcelDeliveryCostMod));
	if (!TakeMoneyFromPP(total_cost + fee, false)) {
		in->method     = BazaarByParcel;
		in->sub_action = InsufficientFunds;
		TraderRepository::UpdateActiveTransaction(database, trader_item.id, false);
		TradeRequestFailed(app);
		return;
	}

	Message(Chat::Red, fmt::format("You paid {} for the parcel delivery.", DetermineMoneyString(fee)).c_str());
	SendMoneyUpdate();

	LogTradingDetail("Step 2:Bazaar Purchase.  Took [{}] {}from Buyer [{}] for purchase of [{}] {}{}",
		DetermineMoneyString(total_cost),
		fee > 0 ? fmt::format("plus a fee of [{}] ", fee) : std::string(""),
		CharacterID(),
		quantity,
		quantity > 1 ? fmt::format("{}s", in->item_name) : in->item_name,
		item->MaxCharges > 0 ? fmt::format(" with charges of [{}]", charges) : std::string("")
	);

	if (RuleB(Bazaar, AuditTrail)) {
		Bazaar::RecordAuditTrail(
			database,
			in->seller_name,
			GetCleanName(),
			item->ID,
			in->item_name,
			quantity,
			total_cost,
			0
		);
	}

	auto out_server = std::make_unique<ServerPacket>(ServerOP_BazaarPurchase, sizeof(BazaarPurchaseMessaging_Struct));
	auto out_data   = reinterpret_cast<BazaarPurchaseMessaging_Struct *>(out_server->pBuffer);

	out_data->transaction_status             = BazaarPurchaseBuyerCompleteSendToSeller;
	out_data->trader_buy_struct.action       = in->action;
	out_data->trader_buy_struct.method       = in->method;
	out_data->trader_buy_struct.already_sold = in->already_sold;
	out_data->trader_buy_struct.item_id      = item->ID;
	out_data->trader_buy_struct.price        = price;
	out_data->trader_buy_struct.quantity     = quantity;
	out_data->trader_buy_struct.sub_action   = in->sub_action;
	out_data->trader_buy_struct.trader_id    = trader_item.character_id;
	out_data->buyer_id                       = CharacterID();
	out_data->item_aug_1                     = trader_item.augment_one;
	out_data->item_aug_2                     = trader_item.augment_two;
	out_data->item_aug_3                     = trader_item.augment_three;
	out_data->item_aug_4                     = trader_item.augment_four;
	out_data->item_aug_5                     = trader_item.augment_five;
	out_data->item_aug_6                     = trader_item.augment_six;
	out_data->item_quantity                  = quantity;
	out_data->item_charges                   = charges;
	out_data->id                             = trader_item.id;
	out_data->trader_zone_id                 = trader_item.char_zone_id;
	out_data->trader_zone_instance_id        = trader_item.char_zone_instance_id;
	out_data->buyer_zone_id                  = GetZoneID();
	out_data->buyer_zone_instance_id         = GetInstanceID();
	strn0cpy(out_data->trader_buy_struct.buyer_name, GetCleanName(), sizeof(out_data->trader_buy_struct.buyer_name));
	strn0cpy(out_data->trader_buy_struct.seller_name, in->seller_name, sizeof(out_data->trader_buy_struct.seller_name));
	strn0cpy(out_data->trader_buy_struct.item_name, in->item_name, sizeof(out_data->trader_buy_struct.item_name));
	strn0cpy(
		out_data->trader_buy_struct.item_unique_id,
		in->item_unique_id,
		sizeof(out_data->trader_buy_struct.item_unique_id)
	);

	worldserver.SendPacket(out_server.get());
	LogTradingDetail("Step 3:Bazaar Purchase.  Buyer checks passed, sending bazaar messaging data to trader via world.\n"
	"Action:                  {} \n"
	"Sub Action:              {} \n"
	"Method:                  {} \n"
	"Item ID:                 {} \n"
	"Item Unique ID:          {} \n"
	"Item Name:               {} \n"
	"Price:                   {} \n"
	"Quantity:                {} \n"
	"Charges:                 {} \n"
	"Augment One:             {} \n"
	"Augment Two:             {} \n"
	"Augment Three:           {} \n"
	"Augment Four:            {} \n"
	"Augment Five:            {} \n"
	"Augment Six:             {} \n"
	"Already Sold:            {} \n"
	"DB ID:                   {} \n"
	"Trader ID:               {} \n"
	"Trader:                  {} \n"
	"Trader Zone ID           {} \n"
	"Trader Zone Instance ID  {} \n"
	"Buyer ID:                {} \n"
	"Buyer:	                  {} \n",
	out_data->trader_buy_struct.action,
	out_data->trader_buy_struct.sub_action,
	out_data->trader_buy_struct.method,
	out_data->trader_buy_struct.item_id,
	out_data->trader_buy_struct.item_unique_id,
	out_data->trader_buy_struct.item_name,
	out_data->trader_buy_struct.price,
	out_data->trader_buy_struct.quantity,
	out_data->item_charges,
	out_data->item_aug_1,
	out_data->item_aug_2,
	out_data->item_aug_3,
	out_data->item_aug_4,
	out_data->item_aug_5,
	out_data->item_aug_6,
	out_data->trader_buy_struct.already_sold,
	out_data->id,
	out_data->trader_buy_struct.trader_id,
	out_data->trader_buy_struct.seller_name,
	out_data->trader_zone_id,
	out_data->trader_zone_instance_id,
	out_data->buyer_id,
	out_data->trader_buy_struct.buyer_name);
}

void Client::SetBuyerWelcomeMessage(const char *welcome_message)
{
	BuyerRepository::UpdateWelcomeMessage(database, CharacterID(), welcome_message);
}

void Client::SendBuyerGreeting(uint32 buyer_id)
{
	auto buyer = BuyerRepository::GetWhere(database, fmt::format("`char_id` = '{}'", buyer_id));
	if (buyer.empty()) {
		Message(Chat::White, "Welcome!");
		return;
	}
	Message(Chat::White, buyer.front().welcome_message.c_str());
}

void Client::SendSellerBrowsing(const std::string &browser)
{
	auto outapp = std::make_unique<EQApplicationPacket>(OP_Barter, static_cast<uint32>(sizeof(BuyerBrowsing_Struct)));
	auto eq     = (BuyerBrowsing_Struct *) outapp->pBuffer;

	eq->action = Barter_SellerBrowsing;
	strn0cpy(eq->char_name, browser.c_str(), sizeof(eq->char_name));

	QueuePacket(outapp.get());
}

void Client::SendBuyerMode(bool status)
{
	auto outapp = std::make_unique<EQApplicationPacket>(OP_Barter, 4);
	auto emu    = (BuyerGeneric_Struct *) outapp->pBuffer;

	emu->action = status ? Barter_BuyerModeOn : Barter_BuyerModeOff;

	QueuePacket(outapp.get());
}

bool Client::IsInBuyerSpace()
{
#define BUYER_DOOR_ARC_RADIUS_HIGH    91
#define BUYER_DOOR_ARC_RADIUS_LOW     71
#define BUYER_DOOR_OPEN_TYPE         155
#define TRADER_DOOR_OPEN_TYPE        153

	struct BuyerDoorDataStruct {
		uint32 door_id;
		uint32 arc_offset;
	};

	std::vector<BuyerDoorDataStruct> buyer_door_data = {
		{.door_id = 2}, {.arc_offset = 90},{.door_id = 3} ,{.arc_offset = 0} ,{.door_id = 4},  {.arc_offset = 0},
		{.door_id = 5}, {.arc_offset = 0} ,{.door_id = 6} ,{.arc_offset = 90},{.door_id = 7},  {.arc_offset = 0},
		{.door_id = 8}, {.arc_offset = 0} ,{.door_id = 9} ,{.arc_offset = 0} ,{.door_id = 10}, {.arc_offset = 0},
		{.door_id = 11},{.arc_offset = 0} ,{.door_id = 12},{.arc_offset = 0} ,{.door_id = 13}, {.arc_offset = 0},
		{.door_id = 14},{.arc_offset = 0} ,{.door_id = 15},{.arc_offset = 0} ,{.door_id = 16}, {.arc_offset = 90},
		{.door_id = 17},{.arc_offset = 0} ,{.door_id = 18},{.arc_offset = 0} ,{.door_id = 19}, {.arc_offset = 0},
		{.door_id = 20},{.arc_offset = 0} ,{.door_id = 21},{.arc_offset = 0} ,{.door_id = 22}, {.arc_offset = 0},
		{.door_id = 23},{.arc_offset = 0} ,{.door_id = 24},{.arc_offset = 0} ,{.door_id = 25}, {.arc_offset = 0},
		{.door_id = 26},{.arc_offset = 0} ,{.door_id = 27},{.arc_offset = 0} ,{.door_id = 28}, {.arc_offset = 0},
		{.door_id = 29},{.arc_offset = 90},{.door_id = 30},{.arc_offset = 0} ,{.door_id = 31}, {.arc_offset = 0},
		{.door_id = 32},{.arc_offset = 0} ,{.door_id = 33},{.arc_offset = 0} ,{.door_id = 34}, {.arc_offset = 0},
		{.door_id = 35},{.arc_offset = 0} ,{.door_id = 36},{.arc_offset = 90},{.door_id = 37}, {.arc_offset = 0},
		{.door_id = 38},{.arc_offset = 0} ,{.door_id = 39},{.arc_offset = 0} ,{.door_id = 40}, {.arc_offset = 0},
		{.door_id = 41},{.arc_offset = 0} ,{.door_id = 42},{.arc_offset = 0} ,{.door_id = 43}, {.arc_offset = 90},
		{.door_id = 44},{.arc_offset = 0} ,{.door_id = 45},{.arc_offset = 0} ,{.door_id = 46}, {.arc_offset = 0},
		{.door_id = 47},{.arc_offset = 0} ,{.door_id = 48},{.arc_offset = 0} ,{.door_id = 49}, {.arc_offset = 0},
		{.door_id = 50},{.arc_offset = 90},{.door_id = 51},{.arc_offset = 90},{.door_id = 52}, {.arc_offset = 0},
		{.door_id = 53},{.arc_offset = 0} ,{.door_id = 54},{.arc_offset = 0}, {.door_id = 55}, {.arc_offset = 0},
		{.door_id = 56},{.arc_offset = 0} ,{.door_id = 57},{.arc_offset = 0}, {.door_id = 122},{.arc_offset = 0}
	};

	auto m_location = GetPosition();

	for (auto const &d: buyer_door_data) {
		auto door = entity_list.GetDoorsByDoorID(d.door_id);
		if (door && IsWithinCircularArc(
			door->GetPosition(),
			m_location,
			d.arc_offset,
			BUYER_DOOR_ARC_RADIUS_HIGH,
			BUYER_DOOR_ARC_RADIUS_LOW
		)
			) {
			return true;
		}
	}

	for (auto const& d:entity_list.GetDoorsList()) {
		if (d.second->GetOpenType() == DoorType::BuyerStall) {
			if (IsWithinSquare(d.second->GetPosition(), d.second->GetSize(), GetPosition())) {
				return true;
			}
		}
	}

	return false;
}

void Client::CreateStartingBuyLines(const EQApplicationPacket *app)
{
	if (ClientVersion() >= EQ::versions::ClientVersion::RoF) {
		BuyerBuyLines_Struct         bl{};
		auto                         in = (BuyerGeneric_Struct *) app->pBuffer;
		EQ::Util::MemoryStreamReader ss_in(
			reinterpret_cast<char *>(in->payload),
			app->size - sizeof(BuyerGeneric_Struct));
		cereal::BinaryInputArchive   ar(ss_in);
		ar(bl);

		if (bl.buy_lines.empty()) {
			return;
		}

		const uint64 max_transaction_value =
			EQ::constants::StaticLookup(ClientVersion())->BazaarMaxTransaction;
		for (const auto &buy_line : bl.buy_lines) {
			const auto transaction_value = Bazaar::ValidateBuyLinePrice(
				buy_line.item_cost,
				max_transaction_value
			);
			if (!transaction_value.is_valid) {
				LogTrading(
					"Rejecting initial buy lines over transaction limit [{}] item_cost [{}] quantity [{}] item [{}] buyer [{}]",
					max_transaction_value,
					buy_line.item_cost,
					buy_line.item_quantity,
					buy_line.item_name,
					GetCleanName()
				);
				Message(
					Chat::Red,
					"That would exceed the single transaction limit of %u platinum.",
					static_cast<uint32>(max_transaction_value / 1000)
				);
				return;
			}
		}

		std::map<uint32, BuylineItemDetails_Struct> item_map{};

		if (!BuildBuyLineMap(item_map, bl)) {
			ToggleBuyerMode(false);
			return;
		}

		auto proposed_total_cost = ValidateBuyLineCost(item_map);
		if (proposed_total_cost == 0) {
			ToggleBuyerMode(false);
			return;
		}

		if (!ValidateBuyLineItems(item_map)) {
			ToggleBuyerMode(false);
			return;
		}

		std::stringstream           ss_out{};
		cereal::BinaryOutputArchive ar_out(ss_out);

		for (auto &b: bl.buy_lines) {
			BuyerBuyLinesRepository::CreateBuyLine(database, b, CharacterID());

			{ ar_out(b); }

			uint32 packet_size = ss_out.str().length() + sizeof(BuyerGeneric_Struct);
			auto   out         = std::make_unique<EQApplicationPacket>(OP_BuyerItems, packet_size);
			auto   data        = (BazaarSearchMessaging_Struct *) out->pBuffer;

			data->action = Barter_BuyerItemUpdate;
			memcpy(data->payload, ss_out.str().data(), ss_out.str().length());
			QueuePacket(out.get());

			ss_out.str("");
			ss_out.clear();
		}

		Message(Chat::Yellow, fmt::format("{} buy lines enabled.", bl.buy_lines.size()).c_str());
	}
}

void Client::SendBuyLineUpdate(const BuyerLineItems_Struct &buy_line)
{
	std::stringstream           ss_out{};
	cereal::BinaryOutputArchive ar_out(ss_out);

	{ ar_out(buy_line); }

	uint32 packet_size = ss_out.str().length() + sizeof(BuyerGeneric_Struct);
	auto   out         = std::make_unique<EQApplicationPacket>(OP_BuyerItems, packet_size);
	auto   data        = (BazaarSearchMessaging_Struct *) out->pBuffer;

	data->action = Barter_BuyerItemUpdate;
	memcpy(data->payload, ss_out.str().data(), ss_out.str().length());
	QueuePacket(out.get());

	ss_out.str("");
	ss_out.clear();
}

void Client::CheckIfMovedItemIsPartOfBuyLines(uint32 item_id)
{
	auto b_trade_items = BuyerTradeItemsRepository::GetTradeItems(database, GetBuyerID());
	if (b_trade_items.empty()) {
		return;
	}

	auto it = std::find_if(
		b_trade_items.cbegin(),
		b_trade_items.cend(),
		[&](const BaseBuyerTradeItemsRepository::BuyerTradeItems bti) {
			return bti.item_id == item_id;
		}
	);
	if (it != std::end(b_trade_items)) {
		auto item = GetInv().GetItem(GetInv().HasItem(item_id, 1, invWherePersonal));
		if (!item) {
			return;
		}

		Message(
			Chat::Red,
			fmt::format(
				"You moved an item ({}) that is part of an active buy line.",
				item->GetItem()->Name
			).c_str()
		);
		ToggleBuyerMode(false);
	}
}

void Client::SendWindowUpdatesToSellerAndBuyer(BuyerLineSellItem_Struct &blsi)
{
	auto buyer  = entity_list.GetClientByID(blsi.buyer_entity_id);
	auto seller = this;
	if (!buyer || !seller) {
		return;
	}

	if (blsi.item_quantity - blsi.seller_quantity <= 0) {
		auto outapp = std::make_unique<EQApplicationPacket>(
			OP_BuyerItems,
			static_cast<uint32>(sizeof(BuyerRemoveItemFromMerchantWindow_Struct))
		);
		auto data   = (BuyerRemoveItemFromMerchantWindow_Struct *) outapp->pBuffer;

		data->action      = Barter_RemoveFromMerchantWindow;
		data->buy_slot_id = blsi.slot;
		QueuePacket(outapp.get());

		std::stringstream           ss{};
		cereal::BinaryOutputArchive ar(ss);

		BuyerLineItems_Struct bl{};
		bl.enabled       = 0;
		bl.item_cost     = blsi.item_cost;
		bl.item_icon     = blsi.item_icon;
		bl.item_id       = blsi.item_id;
		bl.item_quantity = blsi.item_quantity - blsi.seller_quantity;
		bl.item_name     = blsi.item_name;
		bl.item_toggle   = 0;
		bl.slot          = blsi.slot;

		for (auto const &b: blsi.trade_items) {
			BuyerLineTradeItems_Struct blti{};
			blti.item_icon     = b.item_icon;
			blti.item_id       = b.item_id;
			blti.item_quantity = b.item_quantity;
			blti.item_name     = b.item_name;
			bl.trade_items.push_back(blti);
		}

		{ ar(bl); }

		uint32 packet_size = ss.str().length() + sizeof(BuyerGeneric_Struct);
		outapp = std::make_unique<EQApplicationPacket>(OP_BuyerItems, packet_size);
		auto emu = (BuyerGeneric_Struct *) outapp->pBuffer;

		emu->action = Barter_BuyerItemUpdate;
		memcpy(emu->payload, ss.str().data(), ss.str().length());

		buyer->QueuePacket(outapp.get());
		BuyerBuyLinesRepository::DeleteBuyLine(database, buyer->CharacterID(), blsi.slot);
	}
	else {
		std::stringstream           ss{};
		cereal::BinaryOutputArchive ar(ss);

		BuyerLineItems_Struct bli{};
		bli.enabled       = 1;
		bli.item_cost     = blsi.item_cost;
		bli.item_icon     = blsi.item_icon;
		bli.item_id       = blsi.item_id;
		bli.item_quantity = blsi.item_quantity - blsi.seller_quantity;
		bli.item_toggle   = 1;
		bli.slot          = blsi.slot;
		bli.item_name     = blsi.item_name;
		for (auto const &b: blsi.trade_items) {
			BuyerLineTradeItems_Struct blti{};
			blti.item_id       = b.item_id;
			blti.item_icon     = b.item_icon;
			blti.item_quantity = b.item_quantity;
			blti.item_name     = b.item_name;
			bli.trade_items.push_back(blti);
		}
		{ ar(bli); }

		uint32 packet_size = ss.str().length() + sizeof(BuyerGeneric_Struct);
		auto   outapp      = std::make_unique<EQApplicationPacket>(OP_BuyerItems, packet_size);
		auto   emu         = (BuyerGeneric_Struct *) outapp->pBuffer;

		emu->action = Barter_BuyerInspectBegin;
		memcpy(emu->payload, ss.str().data(), ss.str().length());

		QueuePacket(outapp.get());

		outapp = std::make_unique<EQApplicationPacket>(OP_BuyerItems, packet_size);
		emu    = (BuyerGeneric_Struct *) outapp->pBuffer;

		emu->action = Barter_BuyerItemUpdate;
		memcpy(emu->payload, ss.str().data(), ss.str().length());

		buyer->QueuePacket(outapp.get());

		BuyerBuyLinesRepository::ModifyBuyLine(database, bli, buyer->GetBuyerID());
	}
}

void Client::SendBuyerToBarterWindow(Client *buyer, uint32 action)
{
	auto server_packet = std::make_unique<ServerPacket>(
		ServerOP_BuyerMessaging,
		static_cast<uint32>(sizeof(BuyerMessaging_Struct))
	);
	auto data          = (BuyerMessaging_Struct *) server_packet->pBuffer;

	data->action          = action;
	data->zone_id         = buyer->GetZoneID();
	data->buyer_id        = buyer->GetBuyerID();
	data->buyer_entity_id = buyer->GetID();
	strn0cpy(data->buyer_name, buyer->GetCleanName(), sizeof(data->buyer_name));

	worldserver.SendPacket(server_packet.get());
}

void Client::SendBulkBazaarBuyers()
{
	auto results = BuyerRepository::All(database);

	if (results.empty()) {
		return;
	}

	auto outapp = std::make_unique<EQApplicationPacket>(
		OP_Barter,
		static_cast<uint32>(sizeof(BuyerAddBuyertoBarterWindow_Struct))
	);
	auto emu    = (BuyerAddBuyertoBarterWindow_Struct *) outapp->pBuffer;

	for (auto const &b: results) {
		auto buyer = entity_list.GetClientByCharID(b.char_id);
		emu->action          = Barter_AddToBarterWindow;
		emu->buyer_id        = b.char_id;
		emu->buyer_entity_id = buyer ? buyer->GetID() : 0;
		emu->zone_id         = buyer ? buyer->GetZoneID() : 0;
		strn0cpy(emu->buyer_name, b.char_name.c_str(), sizeof(emu->buyer_name));

		QueuePacket(outapp.get());
	}
}

void Client::SendBarterBuyerClientMessage(
	BuyerLineSellItem_Struct &blsi,
	BarterBuyerActions action,
	BarterBuyerSubActions sub_action,
	BarterBuyerSubActions error_code
)
{
	std::stringstream           ss{};
	cereal::BinaryOutputArchive ar(ss);

	blsi.sub_action = sub_action;
	blsi.error_code = error_code;

	{ ar(blsi); }

	uint32 packet_size = ss.str().length() + sizeof(BuyerGeneric_Struct);
	auto   outapp      = std::make_unique<EQApplicationPacket>(OP_BuyerItems, packet_size);
	auto   emu         = (BuyerGeneric_Struct *) outapp->pBuffer;

	emu->action = action;
	memcpy(emu->payload, ss.str().data(), ss.str().length());

	QueuePacket(outapp.get());
}

bool Client::BuildBuyLineMap(std::map<uint32, BuylineItemDetails_Struct> &item_map, BuyerBuyLines_Struct &bl)
{
	bool buyer_error = false;

	for (auto const &b: bl.buy_lines) {
		if (item_map.contains(b.item_id) && item_map[b.item_id].item_cost > 0) {
			Message(
				Chat::Red,
				fmt::format(
					"You cannot have two buy lines for the same item {}. Buy line not possible.",
					b.item_name
				).c_str()
			);
			buyer_error = true;
			break;
		}
		BuylineItemDetails_Struct t = {
			static_cast<uint64>(b.item_quantity) * static_cast<uint64>(b.item_cost),
			b.item_quantity
		};
		item_map.emplace(b.item_id, t);
		for (auto const &i: b.trade_items) {
			if (item_map.contains(i.item_id) && item_map[i.item_id].item_cost > 0) {
				Message(
					Chat::Red,
					fmt::format(
						"You cannot buy {} and offer the same item as compensation. Buy line not possible.",
						i.item_name
					).c_str()
				);
				buyer_error = true;
				break;
			}
			if (item_map.contains(i.item_id)) {
				item_map[i.item_id].item_quantity += i.item_quantity * b.item_quantity;
				continue;
			}
			t = {0, i.item_quantity * b.item_quantity};
			item_map.emplace(i.item_id, t);
		}
	}

	if (buyer_error) {
		return false;
	}

	return true;
}

bool Client::BuildBuyLineMapFromVector(
	std::map<uint32, BuylineItemDetails_Struct> &item_map,
	std::vector<BuyerLineItems_Struct> &bl
)
{

	bool buyer_error = false;

	for (auto const &b: bl) {
		if (item_map.contains(b.item_id) && item_map[b.item_id].item_cost > 0) {
			Message(
				Chat::Red,
				fmt::format(
					"You cannot have two buy lines for the same item {}. Buy line not possible.",
					b.item_name
				).c_str()
			);
			buyer_error = true;
			break;
		}
		BuylineItemDetails_Struct t = {
			static_cast<uint64>(b.item_quantity) * static_cast<uint64>(b.item_cost),
			b.item_quantity
		};
		item_map.emplace(b.item_id, t);
		for (auto const &i: b.trade_items) {
			if (item_map.contains(i.item_id) && item_map[i.item_id].item_cost > 0) {
				Message(
					Chat::Red,
					fmt::format(
						"You cannot buy {} and offer the same item as compensation. Buy line not possible.",
						i.item_name
					).c_str()
				);
				buyer_error = true;
				break;
			}
			if (item_map.contains(i.item_id)) {
				item_map[i.item_id].item_quantity += i.item_quantity * b.item_quantity;
				continue;
			}
			t = {0, i.item_quantity * b.item_quantity};
			item_map.emplace(i.item_id, t);
		}
	}

	if (buyer_error) {
		return false;
	}

	return true;
}

void
Client::RemoveItemFromBuyLineMap(std::map<uint32, BuylineItemDetails_Struct> &item_map, const BuyerLineItems_Struct &bl)
{
	if (item_map.contains(bl.item_id) && item_map[bl.item_id].item_cost > 0) {
		item_map.erase(bl.item_id);
	}

	for (auto const &i: bl.trade_items) {
		if (item_map.contains(i.item_id) &&
			(item_map[i.item_id].item_quantity - (i.item_quantity * bl.item_quantity)) == 0) {
			item_map.erase(i.item_id);
		}
		else if (item_map.contains(i.item_id)) {
			item_map[i.item_id].item_quantity -= i.item_quantity * bl.item_quantity;
		}
	}
}

bool Client::ValidateBuyLineItems(std::map<uint32, BuylineItemDetails_Struct> &item_map)
{
	bool buyer_error = false;

	for (auto const &i: item_map) {
		auto item = database.GetItem(i.first);
		if (!item) {
			buyer_error = true;
			break;
		}

		if (i.second.item_cost > 0) {
			auto buy_item_slot_id = GetInv().HasItem(i.first, i.second.item_quantity, invWherePersonal);
			auto buy_item         = buy_item_slot_id == INVALID_INDEX ? nullptr : GetInv().GetItem(buy_item_slot_id);
			if (buy_item && CheckLoreConflict(buy_item->GetItem())) {
				Message(
					Chat::Red,
					fmt::format(
						"You already have a {}. Purchasing another will cause a lore conflict. Buy line not possible.",
						buy_item->GetItem()->Name
					).c_str()
				);
				buyer_error = true;
				break;
			}
		}
		if (i.second.item_cost == 0) {
			if (i.second.item_quantity > 1 && CheckLoreConflict(item)) {
				Message(
					Chat::Red,
					fmt::format(
						"Your buy line requires {} {}s however the item is LORE. Buy line not possible.",
						i.second.item_quantity,
						item->Name
					).c_str()
				);
				buyer_error = true;
				break;
			}

			auto buy_item_slot_id = GetInv().HasItem(i.first, i.second.item_quantity, invWherePersonal);
			auto buy_item         = buy_item_slot_id == INVALID_INDEX ? nullptr : GetInv().GetItem(buy_item_slot_id);

			if (!buy_item) {
				Message(
					Chat::Red,
					fmt::format(
						"Your buy line(s) require a total of {} {}{} which could not be found. Buy line not possible.",
						i.second.item_quantity,
						item->Name,
						i.second.item_quantity > 1 ? "s" : ""
					).c_str()
				);
				buyer_error = true;
				break;
			}

			if (buy_item->IsAugmentable() && buy_item->IsAugmented()) {
				Message(
					Chat::Red,
					fmt::format(
						"You cannot offer {} because it is augmented. Buy line not possible.",
						buy_item->GetItem()->Name
					).c_str()
				);
				buyer_error = true;
				break;
			}

			if (!buy_item->IsDroppable()) {
				Message(
					Chat::Red,
					fmt::format(
						"You cannot offer {} because it is NoTrade. Buy line not possible.",
						buy_item->GetItem()->Name
					).c_str());
				buyer_error = true;
				break;
			}

			buyer_error = false;
		}
	}

	return !buyer_error;
}

int64 Client::ValidateBuyLineCost(std::map<uint32, BuylineItemDetails_Struct> &item_map)
{
	uint64 proposed_total_cost = std::accumulate(
		item_map.cbegin(),
		item_map.cend(),
		static_cast<uint64>(0),
		[](uint64 prev_sum, const std::pair<uint32, BuylineItemDetails_Struct> &x) {
			return prev_sum + x.second.item_cost;
		}
	);

	if (proposed_total_cost > GetCarriedMoney()) {
		Message(
			Chat::Red,
			fmt::format(
				"You currently do not have sufficient funds to support your buy lines. You have {} and need {}",
				DetermineMoneyString(GetCarriedMoney()),
				DetermineMoneyString(proposed_total_cost)).c_str()
		);
		return 0;
	}

	return proposed_total_cost;
}

bool Client::DoBarterBuyerChecks(BuyerLineSellItem_Struct &sell_line)
{
	bool buyer_error = false;
	auto buyer       = entity_list.GetClientByID(sell_line.buyer_entity_id);

	if (!buyer) {
		return false;
	}

	const uint64 max_transaction_value =
		EQ::constants::StaticLookup(buyer->ClientVersion())->BazaarMaxTransaction;
	const auto transaction_value = Bazaar::ValidateTransactionValue(
		sell_line.item_cost,
		sell_line.seller_quantity,
		max_transaction_value
	);
	if (!transaction_value.is_valid) {
		LogTrading(
			"Rejecting buyer sale over buyer transaction limit [{}] item_cost [{}] quantity [{}] item [{}] seller [{}] buyer [{}]",
			max_transaction_value,
			sell_line.item_cost,
			sell_line.seller_quantity,
			sell_line.item_name,
			sell_line.seller_name,
			buyer->GetCleanName()
		);
		buyer->Message(
			Chat::Red,
			"That transaction would exceed the single transaction limit of %u platinum.",
			static_cast<uint32>(max_transaction_value / 1000)
		);
		return false;
	}

	auto buyer_time = BuyerRepository::GetTransactionDate(database, buyer->CharacterID());
	if (buyer_time > GetBarterTime()) {
		if (sell_line.purchase_method == BarterByVendor) {
			SendBarterBuyerClientMessage(
				sell_line,
				Barter_SellerTransactionComplete,
				Barter_Success,
				Barter_DataOutOfDate
			);
			return false;
		}
		SendBarterBuyerClientMessage(sell_line, Barter_SellerTransactionComplete, Barter_Failure, Barter_DataOutOfDate);
		return false;
	}

	for (auto const &ti: sell_line.trade_items) {
		auto ti_slot_id = buyer->GetInv().HasItem(
			ti.item_id,
			ti.item_quantity * sell_line.seller_quantity,
			invWherePersonal
		);
		if (ti_slot_id == INVALID_INDEX) {
			LogTradingDetail(
				"Seller attempting to sell item <green>[{}] to buyer <green>[{}] though buyer no longer has compensation item <red>[{}]",
				sell_line.item_name,
				buyer->GetCleanName(),
				ti.item_name
			);
			buyer->Message(
				Chat::Red,
				fmt::format(
					"{} wanted to sell you {} however you no longer have compensation item {}",
					sell_line.seller_name,
					sell_line.item_name,
					ti.item_name
				).c_str());
			buyer_error = true;
			break;
		}
	}

	const uint64 total_cost = transaction_value.total_cost;
	if (!buyer->HasMoney(total_cost)) {
		LogTradingDetail(
			"Seller attempting to sell item <green>[{}] to buyer <green>[{}] though buyer does not have enough money <red>[{}]",
			sell_line.item_name,
			buyer->GetCleanName(),
			total_cost
		);
		buyer->Message(
			Chat::Red,
			fmt::format(
				"{} wanted to sell you {} however you have insufficient funds.",
				sell_line.seller_name,
				sell_line.item_name
			).c_str()
		);
		buyer_error = true;
	}

	const auto *buy_item = database.GetItem(sell_line.item_id);
	if (buy_item && buyer->CheckLoreConflict(buy_item)) {
		LogTradingDetail(
			"Seller attempting to sell item <green>[{}] to buyer <green>[{}] though buyer already has the item which is LORE.",
			sell_line.item_name,
			buyer->GetCleanName()
		);
		buyer->Message(
			Chat::Red,
			fmt::format(
				"{} wanted to sell you {} however you already have the LORE item.",
				sell_line.seller_name,
				sell_line.item_name
			).c_str()
		);
		buyer_error = true;
	}

	if (buyer_error) {
		LogTradingDetail("Buyer error <red>[{}] Barter Sell/Buy Transaction Failed.", buyer_error);
		SendBarterBuyerClientMessage(sell_line, Barter_SellerTransactionComplete, Barter_Failure, Barter_Failure);
		return false;
	}

	return true;
}

bool Client::DoBarterSellerChecks(BuyerLineSellItem_Struct &sell_line)
{
	bool seller_error = false;
	auto sell_item_slot_id = GetInv().HasItem(sell_line.item_id, sell_line.seller_quantity, invWherePersonal);
	auto sell_item = sell_item_slot_id == INVALID_INDEX ? nullptr : GetInv().GetItem(sell_item_slot_id);
	if (!sell_item) {
		seller_error = true;
		LogTradingDetail("Seller no longer has item <red>[{}] to sell to buyer <red>[{}]",
						 sell_line.item_name,
						 sell_line.buyer_name
		);
		SendBarterBuyerClientMessage(
			sell_line,
			Barter_SellerTransactionComplete,
			Barter_Failure,
			Barter_SellerDoesNotHaveItem
		);
	}

	if (sell_item && sell_item->IsAugmentable() && sell_item->IsAugmented()) {
		seller_error = true;
		LogTradingDetail("Seller item <red>[{}] is augmented therefore cannot be sold.",
						 sell_line.item_name
		);
		Message(Chat::Red, "The item that you are trying to sell is augmented. Please remove augments first");
	}

	if (sell_item && !sell_item->IsDroppable()) {
		seller_error = true;
		LogTradingDetail("Seller item <red>[{}] is non-tradeable therefore cannot be sold.",
						 sell_line.item_name
		);
		Message(Chat::Red, "The item that you are trying to sell is non-tradeable and therefore cannot be sold.");
	}

	if (sell_item && !sell_item->IsStackable() && sell_item->GetItem()->MaxCharges > 0) {
		seller_error = true;
		LogTradingDetail(
			"Seller item <red>[{}] has charges that cannot be preserved by buyer transactions.",
			sell_line.item_name
		);
		Message(Chat::Red, "Charged non-stackable items cannot be sold to a buyer.");
	}

	if (
		sell_item &&
		!sell_item->IsStackable() &&
		sell_item->GetItem()->LoreFlag &&
		sell_line.seller_quantity > 1
	) {
		seller_error = true;
		LogTradingDetail(
			"Seller item <red>[{}] is LORE and cannot be delivered in quantity [{}] by a buyer transaction.",
			sell_line.item_name,
			sell_line.seller_quantity
		);
		Message(Chat::Red, "Multiple copies of a LORE item cannot be sold to a buyer in one transaction.");
	}

	if (seller_error) {
		LogTradingDetail("Seller Error <red>[{}]  Barter Sell/Buy Transaction Failed.", seller_error);
		SendBarterBuyerClientMessage(sell_line, Barter_SellerTransactionComplete, Barter_Failure, Barter_Failure);
		return false;
	}

	return true;
}

void Client::CancelBuyerTradeWindow()
{
	auto end_session = new EQApplicationPacket(OP_Barter, sizeof(BuyerRemoveItemFromMerchantWindow_Struct));
	auto data        = reinterpret_cast<BuyerRemoveItemFromMerchantWindow_Struct *>(end_session->pBuffer);
	data->action     = Barter_BuyerInspectBegin;

	FastQueuePacket(&end_session);
}

void Client::CancelTraderTradeWindow()
{
	auto end_session = new EQApplicationPacket(OP_ShopEnd);
	FastQueuePacket(&end_session);
}

void Client::AddDataToMerchantList(int16 slot_id, uint32 item_id, int32 quantity, const std::string &item_unique_id)
{
	auto list = GetTraderMerchantList();
	list->emplace(std::pair(slot_id, std::make_tuple(item_id, quantity, item_unique_id)));
}

int16 Client::GetNextFreeSlotFromMerchantList()
{
	auto list = GetTraderMerchantList();
	for (auto const &[slot_id, merchant_data] : *list) {
		auto [item_id, quantity, item_unique_id] = merchant_data;
		if (item_id == 0) {
			return slot_id;
		}
	}

	if (list->size() == GetInv().GetLookup()->InventoryTypeSize.Bazaar) {
		return INVALID_INDEX;
	}

	return list->size() + 1;
}

std::tuple<uint32, int32, std::string> Client::GetDataFromMerchantListByMerchantSlotId(int16 slot_id)
{
	auto list = GetTraderMerchantList();
	return list->contains(slot_id) ? list->at(slot_id) : std::make_tuple(0, 0, "0000000000000000");
}

int16 Client::GetSlotFromMerchantListByItemUniqueId(const std::string &unique_id)
{
	auto list = GetTraderMerchantList();

	for (auto [slot_id, merchant_data] : *list) {
		auto [item_id, quantity, item_unique_id] = merchant_data;
		if (item_unique_id == unique_id) {
			return slot_id;
		}
	}

	return INVALID_INDEX;
}

std::pair<int16, std::tuple<uint32, int32, std::string>> Client::GetDataFromMerchantListByItemUniqueId(const std::string &unique_id)
{
	auto list = GetTraderMerchantList();

	for (auto [slot_id, merchant_data] : *list) {
		auto [item_id, quantity, item_unique_id] = merchant_data;
		if (item_unique_id == unique_id) {
			return { slot_id, merchant_data };
		}
	}

	return std::make_pair(INVALID_INDEX, std::make_tuple(0, 0, "0000000000000000"));
}
