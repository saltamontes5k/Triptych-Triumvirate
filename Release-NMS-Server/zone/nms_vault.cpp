#include "../common/global_define.h"
#include "nms_vault.h"

#include "../common/eqemu_logsys.h"
#include "../common/features.h"
#include "../common/rulesys.h"
#include "../common/strings.h"
#include "../common/eq_packet_structs.h"
#include "../common/emu_constants.h"
#include "../common/eq_constants.h"
#include "../common/item_instance.h"
#include "../common/item_data.h"
#include "../common/spdat.h"
#include "client.h"
#include "entity.h"
#include "npc.h"
#include "zonedb.h"
#include "string_ids.h"

#include <fmt/format.h>
#include <unordered_map>
#include <vector>

extern ZoneDatabase database;
extern ZoneDatabase content_db;

namespace {
	bool tables_checked = false;
	bool tables_ready = false;

	struct LockerCache {
		uint32 primary = 0;
		uint32 primary_aug[6] = {0, 0, 0, 0, 0, 0};
		uint32 secondary = 0;
		uint32 secondary_aug[6] = {0, 0, 0, 0, 0, 0};
		int16  secondary_charges = 1;
		bool   secondary_is_shield = false;
		uint32 ranged = 0;
		uint32 ranged_aug[6] = {0, 0, 0, 0, 0, 0};
	};

	std::unordered_map<uint32, LockerCache> locker_cache;

	// Where the player stood when they opened the vault bank. The vault bank exists so a
	// player does not need a banker NPC nearby (feature F6) - it was never meant to let them
	// bank from anywhere for the rest of the zone session, which is what an unbounded flag
	// did: one #vault_bank suppressed the distance check, and its POSSIBLE_HACK player
	// event, on every banker handler until they changed zones. Anchoring the session to the
	// spot it was opened keeps the feature (no NPC required) while restoring the property
	// stock relies on - you bank where you opened the window, and walking away ends it.
	struct BankAnchor {
		float x = 0.0f;
		float y = 0.0f;
		float z = 0.0f;
	};

	std::unordered_map<uint32, BankAnchor> bank_anchor;

	std::string SanitizeField(const std::string &in)
	{
		std::string out;
		out.reserve(in.size());
		for (char ch : in) {
			if (ch == '|' || ch == '~' || ch == ':') {
				out.push_back(' ');
			}
			else {
				out.push_back(ch);
			}
		}
		return out;
	}

	bool EnsureTables()
	{
		if (tables_checked) {
			return tables_ready;
		}
		auto results = database.QueryDatabase("SHOW TABLES LIKE 'character_nms_vault'");
		// A failed QUERY is not a failed SCHEMA. Latching tables_checked before knowing the
		// answer meant one transient DB error at first vault use disabled the vault for the
		// entire life of the zone process, and made a schema fix applied to a running server
		// invisible until restart. Only cache a definitive answer; retry on the next call.
		if (!results.Success()) {
			LogError("NmsVault: table check query failed; will retry on next use");
			return false;
		}
		if (results.RowCount() == 0) {
			tables_checked = true;
			tables_ready   = false;
			return tables_ready;
		}
		auto primary_key = database.QueryDatabase(
			"SELECT "
			"SUM(CASE WHEN column_name IN ('character_id', 'slot', 'bag_slot') THEN 1 ELSE 0 END) AS named_cols, "
			"COUNT(*) AS total_cols "
			"FROM information_schema.statistics "
			"WHERE table_schema = DATABASE() "
			"AND table_name = 'character_nms_vault' "
			"AND index_name = 'PRIMARY'"
		);
		auto unique_indexes = database.QueryDatabase(
			"SELECT COUNT(DISTINCT index_name) FROM information_schema.statistics "
			"WHERE table_schema = DATABASE() "
			"AND table_name = 'character_nms_vault' "
			"AND non_unique = 0"
		);
		// Custom manifest v41 added the per-instance state columns. Without them every
		// SELECT and REPLACE in this file references a column that does not exist, so an
		// un-migrated server must fail closed here rather than erroring on every operation.
		auto instance_columns = database.QueryDatabase(
			"SELECT COUNT(*) FROM information_schema.columns "
			"WHERE table_schema = DATABASE() "
			"AND table_name = 'character_nms_vault' "
			"AND column_name IN ('instnodrop', 'custom_data', 'ornament_icon', "
			"'ornament_idfile', 'ornament_hero_model', 'guid')"
		);

		if (!primary_key.Success() || !unique_indexes.Success() || !instance_columns.Success()) {
			LogError("NmsVault: schema check query failed; will retry on next use");
			return false;
		}

		tables_checked = true;
		tables_ready   = false;
		if (primary_key.RowCount() > 0 && unique_indexes.RowCount() > 0
			&& instance_columns.RowCount() > 0) {
			auto row = primary_key.begin();
			auto unique_row = unique_indexes.begin();
			auto columns_row = instance_columns.begin();
			tables_ready = Strings::ToInt(row[0]) == 3
				&& Strings::ToInt(row[1]) == 3
				&& Strings::ToInt(unique_row[0]) == 1
				&& Strings::ToInt(columns_row[0]) == 6;
			if (!tables_ready && Strings::ToInt(columns_row[0]) != 6) {
				LogError(
					"NmsVault: character_nms_vault is missing the v41 instance-state columns; "
					"the vault stays disabled until the custom migration manifest is applied"
				);
			}
		}
		return tables_ready;
	}

	EQ::ItemInstance *MakeInstance(const NmsVaultItem &row)
	{
		auto *inst = database.CreateItem(
			row.item_id,
			row.charges,
			row.aug[0],
			row.aug[1],
			row.aug[2],
			row.aug[3],
			row.aug[4],
			row.aug[5],
			row.attuned,
			row.custom_data,
			row.ornament_icon,
			row.ornament_idfile,
			row.ornament_hero_model
		);
		if (!inst) {
			return nullptr;
		}
		// Restore the instance's identity the same way the inventory load does
		// (shareddb.cpp:816-817): re-register the serial so Bazaar and anything else keyed
		// on it still recognises the item. AddGUIDToMap inserts into a set, so re-adding a
		// serial that is still registered is a no-op.
		if (row.guid != 0) {
			inst->SetSerialNumber(static_cast<int32>(row.guid));
			EQ::ItemInstance::AddGUIDToMap(row.guid);
		}
		return inst;
	}

	NmsVaultItem FromInstance(int slot, int bag_slot, const EQ::ItemInstance *inst)
	{
		NmsVaultItem row;
		row.slot = slot;
		row.bag_slot = bag_slot;
		if (!inst || !inst->GetItem()) {
			return row;
		}
		row.item_id = inst->GetItem()->ID;
		row.charges = inst->GetCharges();
		for (int i = 0; i < 6; ++i) {
			row.aug[i] = inst->GetAugmentItemID(static_cast<uint8>(i));
		}
		row.attuned             = inst->IsAttuned();
		row.custom_data         = inst->GetCustomDataString();
		row.ornament_icon       = inst->GetOrnamentationIcon();
		row.ornament_idfile     = inst->GetOrnamentationIDFile();
		row.ornament_hero_model = inst->GetOrnamentHeroModel();
		row.guid                = static_cast<uint64>(inst->GetSerialNumber());
		return row;
	}

	std::string BagContentsField(const std::vector<NmsVaultItem> &all, int slot)
	{
		std::string out;
		for (const auto &row : all) {
			if (row.slot != slot || row.bag_slot <= 0) {
				continue;
			}
			const auto *item = database.GetItem(row.item_id);
			if (!item) {
				continue;
			}
			if (!out.empty()) {
				out.append("~");
			}
			out.append(fmt::format(
				"{}:{}:{}:{}",
				row.item_id,
				SanitizeField(item->Name),
				row.charges,
				item->Icon
			));
		}
		return out;
	}

	void SendLine(Client *c, const std::string &line)
	{
		c->Message(Chat::White, "%s", line.c_str());
	}

	bool IsVaultClicky(const EQ::ItemData *item)
	{
		if (!item || !IsValidSpell(item->Click.Effect)) {
			return false;
		}
		return item->Click.Type == EQ::item::ItemEffectClick
			|| item->Click.Type == EQ::item::ItemEffectClick2
			|| item->Click.Type == EQ::item::ItemEffectEquipClick;
	}

	// The autoload previously cast every clicky in slots 61-80 with no checks at all, so a
	// level-1 character could park a bag of raid clickies and have them all re-applied on
	// every zone-in.
	//
	// The two gates are deliberately different, because EQ treats these item effects
	// differently and a blanket equip check would remove intended behaviour:
	//   - Required level applies to everything. Stock gates item clicks on Click.Level2
	//     (client_packet.cpp:4725-4727, :10048); a vault clicky is not a way around it.
	//   - Class/race equipability applies ONLY to EquipClick items, whose effect exists
	//     solely because the item is worn. A plain inventory clicky (Click / Click2) is
	//     usable from a bag by classes that could never equip it, which is normal EQ
	//     behaviour and stays allowed.
	bool CanUseVaultClicky(Client *c, const EQ::ItemData *item)
	{
		if (!c || !IsVaultClicky(item)) {
			return false;
		}
		if (item->Click.Level2 > 0 && c->GetLevel() < item->Click.Level2) {
			return false;
		}
		if (item->Click.Type == EQ::item::ItemEffectEquipClick
			&& !item->IsEquipable(c->GetBaseRace(), static_cast<uint16>(c->GetClassesBits()))) {
			return false;
		}
		return true;
	}

	void CollectClickySpells(const std::vector<NmsVaultItem> &items, int slot, std::vector<uint16> &out)
	{
		if (slot < NMS_VAULT_CLICKY_BEGIN || slot > NMS_VAULT_CLICKY_END) {
			return;
		}
		for (const auto &row : items) {
			if (row.slot != slot) {
				continue;
			}
			const auto *item = database.GetItem(row.item_id);
			if (IsVaultClicky(item)) {
				out.push_back(static_cast<uint16>(item->Click.Effect));
			}
		}
	}

	void FadeClickySpells(Client *c, const std::vector<uint16> &spells)
	{
		for (auto spell_id : spells) {
			c->BuffFadeBySpellID(spell_id);
		}
	}

	bool CursorPersisted(Client *c)
	{
		if (!c) {
			return false;
		}
		auto start = c->GetInv().cursor_cbegin();
		auto end = c->GetInv().cursor_cend();
		if (!database.SaveCursor(c->CharacterID(), start, end)) {
			return false;
		}
		// Count ONLY slot_id = slotCursor, and expect one row per non-empty queue.
		//
		// The old test COUNT(*)'d the whole cursor range and compared it to CursorSize().
		// Those two never had to agree: SaveCursor writes queue entries 1..N into
		// CURSOR_BAG_BEGIN..END, and UpdateInventorySlot ALSO writes the contents of a bag
		// sitting on the cursor into that same range via CalcSlotId(slotCursor, i)
		// (shareddb.cpp:444-458). One bag holding three items counted as four rows against a
		// CursorSize() of one, so deposits failed for anyone carrying a full bag. The two
		// kinds of row are indistinguishable by slot_id, so no count over that whole range
		// can be right - but slotCursor itself is never used for bag contents, so a count
		// restricted to it is unambiguous.
		//
		// The expected value is 0 or 1, not always 1: the caller (TakeCursorIfPersisted)
		// pops the deposited item BEFORE calling here, so the queue is legitimately empty in
		// the ordinary one-item case and SaveCursor correctly writes nothing.
		const int remaining = c->GetInv().CursorSize();
		auto results = database.QueryDatabase(fmt::format(
			"SELECT COUNT(*) FROM inventory WHERE character_id = {} AND slot_id = {}",
			c->CharacterID(),
			EQ::invslot::slotCursor
		));
		if (!results.Success() || results.RowCount() == 0) {
			return false;
		}
		auto row = results.begin();
		return Strings::ToInt(row[0]) == (remaining > 0 ? 1 : 0);
	}

	bool DeliverToPlayer(Client *c, EQ::ItemInstance *inst)
	{
		if (!c || !inst) {
			return false;
		}
		if (c->GetInv().CursorSize() >= EQ::invbag::CURSOR_BAG_COUNT) {
			return c->AutoPutLootInInventory(*inst, true, false);
		}

		// PushItemOnCursor returns SaveCursor's result - whether the cursor actually reached
		// the database. The old test compared CursorSize() before and after, but PushCursor
		// is a pure in-memory queue push, so it ALWAYS grew and a failed SaveCursor read as
		// success. On the withdraw path the vault row is deleted before this call, so the
		// item then existed in neither place after a relog. It also made the
		// AutoPutLootInInventory fallback below unreachable.
		const int before = c->GetInv().CursorSize();
		if (c->PushItemOnCursor(*inst, true)) {
			return true;
		}

		c->RollbackFailedItemPut(EQ::invslot::slotCursor, true);
		LogError(
			"NmsVault: cursor delivery for character {} did not persist (cursor held {} item(s) "
			"beforehand); the appended clone was rolled back and the item stays in the vault",
			c->CharacterID(),
			before
		);
		return false;
	}

	bool ParentIsBagWithSlot(const std::vector<NmsVaultItem> &items, int slot, int bag_slot)
	{
		const auto *parent = NmsVaultFind(items, slot, 0);
		if (!parent) {
			return false;
		}
		const auto *parent_item = database.GetItem(parent->item_id);
		return parent_item
			&& parent_item->IsClassBag()
			&& bag_slot >= 1
			&& bag_slot <= static_cast<int>(parent_item->BagSlots);
	}

	bool RestoreVaultSnapshot(uint32 character_id, const std::vector<NmsVaultItem> &snapshot)
	{
		bool ok = true;
		for (const auto &row : snapshot) {
			if (!NmsVaultSaveItem(character_id, row)) {
				ok = false;
			}
		}
		return ok;
	}

	bool VaultSlotOccupied(const std::vector<NmsVaultItem> &items, int slot)
	{
		for (const auto &item : items) {
			if (item.slot == slot) {
				return true;
			}
		}
		return false;
	}

	bool VaultSlotHasPersistedRows(uint32 character_id, int slot)
	{
		auto results = database.QueryDatabase(fmt::format(
			"SELECT COUNT(*) FROM character_nms_vault WHERE character_id = {} AND slot = {}",
			character_id,
			slot
		));
		if (!results.Success() || results.RowCount() == 0) {
			return true;
		}
		auto row = results.begin();
		return Strings::ToInt(row[0]) > 0;
	}

	enum class VaultRowState {
		Missing,
		Match,
		Mismatch,
		Unknown
	};

	VaultRowState ReadVaultRowState(uint32 character_id, const NmsVaultItem &item)
	{
		auto results = database.QueryDatabase(fmt::format(
			"SELECT item_id, charges, aug1, aug2, aug3, aug4, aug5, aug6, "
			"instnodrop, custom_data, ornament_icon, ornament_idfile, ornament_hero_model, guid "
			"FROM character_nms_vault WHERE character_id = {} AND slot = {} AND bag_slot = {} LIMIT 1",
			character_id,
			item.slot,
			item.bag_slot
		));
		if (!results.Success()) {
			return VaultRowState::Unknown;
		}
		if (results.RowCount() == 0) {
			return VaultRowState::Missing;
		}
		auto row = results.begin();
		// The per-instance state is part of the row's identity, not decoration. NmsVaultSaveItem
		// falls back to this after a failed REPLACE and treats Match as "saved" - so without
		// these fields a row still carrying the PREVIOUS instance's attunement or ornaments
		// would pass as the row we meant to write, silently keeping the old state.
		if (Strings::ToUnsignedInt(row[0]) != item.item_id
			|| static_cast<int16>(Strings::ToInt(row[1])) != item.charges
			|| Strings::ToUnsignedInt(row[2]) != item.aug[0]
			|| Strings::ToUnsignedInt(row[3]) != item.aug[1]
			|| Strings::ToUnsignedInt(row[4]) != item.aug[2]
			|| Strings::ToUnsignedInt(row[5]) != item.aug[3]
			|| Strings::ToUnsignedInt(row[6]) != item.aug[4]
			|| Strings::ToUnsignedInt(row[7]) != item.aug[5]
			|| (row[8] && Strings::ToInt(row[8]) != 0) != item.attuned
			|| std::string(row[9] ? row[9] : "") != item.custom_data
			|| (row[10] ? Strings::ToUnsignedInt(row[10]) : 0) != item.ornament_icon
			|| (row[11] ? Strings::ToUnsignedInt(row[11]) : 0) != item.ornament_idfile
			|| (row[12] ? Strings::ToUnsignedInt(row[12]) : 0) != item.ornament_hero_model
			|| (row[13] ? Strings::ToUnsignedBigInt(row[13]) : 0) != item.guid
		) {
			return VaultRowState::Mismatch;
		}
		return VaultRowState::Match;
	}

	bool CleanupVaultSlot(uint32 character_id, int slot)
	{
		auto results = database.QueryDatabase(fmt::format(
			"DELETE FROM character_nms_vault WHERE character_id = {} AND slot = {}",
			character_id,
			slot
		));
		const bool still_has = VaultSlotHasPersistedRows(character_id, slot);
		if (!results.Success() || still_has) {
			LogError(
				"NmsVault: failed to clean slot {} for character {}",
				slot,
				character_id
			);
			return false;
		}
		return true;
	}

	bool FinishFailedVaultSlotWrite(uint32 character_id, const NmsVaultItem &parent)
	{
		if (CleanupVaultSlot(character_id, parent.slot)) {
			return false;
		}
		const auto state = ReadVaultRowState(character_id, parent);
		// Only a POSITIVELY confirmed row counts as saved. Unknown means the verification
		// SELECT itself failed, so we do not know whether the row exists - and the caller
		// destroys the player's cursor item on a true return. Claiming a save we cannot
		// prove trades an unverified row for a guaranteed item loss; returning false hands
		// the item back instead. If a row did survive, the next REPLACE on the same primary
		// key collapses it, so the worst case here is a recoverable duplicate rather than
		// silently destroying something the player owned.
		if (state == VaultRowState::Match) {
			LogError(
				"NmsVault: slot {} for character {} remains after a failed write; treating the vault row as saved",
				parent.slot,
				character_id
			);
			return true;
		}
		if (state == VaultRowState::Unknown) {
			LogError(
				"NmsVault: could not verify slot {} for character {} after a failed write; "
				"returning the item to the player rather than assuming it was stored",
				parent.slot,
				character_id
			);
		}
		return false;
	}

	bool FinishFailedVaultChildWrite(uint32 character_id, const NmsVaultItem &item)
	{
		NmsVaultDeleteItem(character_id, item.slot, item.bag_slot);
		const auto state = ReadVaultRowState(character_id, item);
		// Same rule as FinishFailedVaultSlotWrite: an unverifiable row is not a saved row.
		if (state == VaultRowState::Match) {
			LogError(
				"NmsVault: child slot {} bag {} for character {} remains after a failed write; treating the vault row as saved",
				item.slot,
				item.bag_slot,
				character_id
			);
			return true;
		}
		if (state == VaultRowState::Unknown) {
			LogError(
				"NmsVault: could not verify child slot {} bag {} for character {} after a failed "
				"write; returning the item to the player rather than assuming it was stored",
				item.slot,
				item.bag_slot,
				character_id
			);
		}
		return false;
	}

	bool SaveVaultSlot(uint32 character_id, int slot, EQ::ItemInstance *inst)
	{
		if (!inst || !EnsureTables()) {
			return false;
		}

		auto parent = FromInstance(slot, 0, inst);
		if (inst->IsClassBag() && inst->IsNoneEmptyContainer()) {
			for (auto &content : *inst->GetContents()) {
				if (!content.second) {
					continue;
				}
				auto inner = FromInstance(slot, content.first + 1, content.second);
				if (!NmsVaultSaveItem(character_id, inner)) {
					return FinishFailedVaultSlotWrite(character_id, parent);
				}
			}
		}

		if (!NmsVaultSaveItem(character_id, parent)) {
			return FinishFailedVaultSlotWrite(character_id, parent);
		}
		return true;
	}

	bool DeletePersistedCursorRange(uint32 character_id)
	{
		auto results = database.QueryDatabase(fmt::format(
			"DELETE FROM inventory WHERE character_id = {} "
			"AND (slot_id = {} OR slot_id BETWEEN {} AND {})",
			character_id,
			EQ::invslot::slotCursor,
			EQ::invbag::CURSOR_BAG_BEGIN,
			EQ::invbag::CURSOR_BAG_END
		));
		return results.Success();
	}

	bool WipeThenPersistCursor(Client *c)
	{
		if (!DeletePersistedCursorRange(c->CharacterID())) {
			return false;
		}
		return CursorPersisted(c);
	}

	void RestoreTakenCursor(Client *c, EQ::ItemInstance *copy)
	{
		if (!c || !copy) {
			safe_delete(copy);
			return;
		}
		c->GetInv().PushCursorFront(*copy);
		c->SendItemPacket(EQ::invslot::slotCursor, copy, ItemPacketLimbo);
		CursorPersisted(c);
		safe_delete(copy);
	}

	EQ::ItemInstance *TakeCursorIfPersisted(Client *c)
	{
		auto *cursor = c->GetInv().GetItem(EQ::invslot::slotCursor);
		if (!cursor) {
			return nullptr;
		}
		auto *copy = cursor->Clone();
		if (!copy) {
			return nullptr;
		}
		c->DeleteItemInInventory(EQ::invslot::slotCursor, 0, true, false);
		if (WipeThenPersistCursor(c)) {
			return copy;
		}
		LogError(
			"NmsVault: cursor persist failed before vault write for character {}",
			c->CharacterID()
		);
		RestoreTakenCursor(c, copy);
		return nullptr;
	}

	void RestoreWithdrawOnFail(
		Client *c,
		EQ::ItemInstance *inst,
		int16 before,
		const NmsVaultItem &original,
		bool one_charge,
		const std::vector<NmsVaultItem> *snapshot
	)
	{
		const int16 left = inst->GetCharges();
		if (left < before) {
			if (left > 0) {
				NmsVaultItem leftover = original;
				leftover.charges = left;
				if (!NmsVaultSaveItem(c->CharacterID(), leftover)) {
					LogError(
						"NmsVault: leftover persist failed for character {} slot {} charges {}",
						c->CharacterID(),
						original.slot,
						left
					);
				}
			}
			return;
		}
		if (one_charge) {
			NmsVaultSaveItem(c->CharacterID(), original);
		}
		else if (snapshot) {
			RestoreVaultSnapshot(c->CharacterID(), *snapshot);
		}
		else {
			NmsVaultSaveItem(c->CharacterID(), original);
		}
	}

	void AfterVaultMutation(Client *c, int slot, const std::vector<uint16> &fade_spells)
	{
		NmsVaultRefreshCache(c);
		if (slot >= NMS_VAULT_PROC_PRIMARY && slot <= NMS_VAULT_PROC_RANGED) {
			c->CalcBonuses();
		}
		FadeClickySpells(c, fade_spells);
	}

	void DepopVaultMerchant(Client *c)
	{
		if (!c || !c->GetNmsVaultMerchantId()) {
			return;
		}
		if (auto *npc = entity_list.GetNPCByID(static_cast<uint16>(c->GetNmsVaultMerchantId()))) {
			npc->Depop();
		}
		c->SetNmsVaultMerchantId(0);
		c->SetNmsVaultMerchant(false);
	}

	enum class ArmoryPresence {
		Absent,
		Present,
		Unknown
	};

	bool InstanceIsArmory(const EQ::ItemInstance *inst)
	{
		if (!inst) {
			return false;
		}
		if (NmsVaultIsArmoryItem(inst->GetID())) {
			return true;
		}
		if (!inst->IsClassBag() || !inst->GetItem()) {
			return false;
		}
		for (uint8 bag_slot = EQ::invbag::SLOT_BEGIN; bag_slot < inst->GetItem()->BagSlots; ++bag_slot) {
			if (InstanceIsArmory(inst->GetItem(bag_slot))) {
				return true;
			}
		}
		return false;
	}

	bool CharacterHasArmory(Client *c)
	{
		if (!c) {
			return false;
		}
		for (const int16 &slot_id : c->GetInventorySlots()) {
			if (InstanceIsArmory(c->GetInv().GetItem(slot_id))) {
				return true;
			}
		}
		// GetItem(slotCursor) is only the visible head; a buried queue copy still owns the key.
		for (auto it = c->GetInv().cursor_cbegin(); it != c->GetInv().cursor_cend(); ++it) {
			if (InstanceIsArmory(*it)) {
				return true;
			}
		}
		return false;
	}

	std::string ArmoryItemSql()
	{
		return fmt::format(
			"item_id >= {} AND (item_id % 1000000) = {}",
			NMS_VAULT_ARMORY_ITEM_ID,
			NMS_VAULT_ARMORY_ITEM_ID % 1000000u
		);
	}

	ArmoryPresence QueryArmoryPresence(const std::string &sql, bool invalidate_vault_ready)
	{
		auto results = database.QueryDatabase(sql);
		if (!results.Success()) {
			if (invalidate_vault_ready) {
				tables_checked = false;
				tables_ready = false;
			}
			return ArmoryPresence::Unknown;
		}
		return results.RowCount() > 0 ? ArmoryPresence::Present : ArmoryPresence::Absent;
	}

	ArmoryPresence VaultHasArmory(uint32 character_id)
	{
		return QueryArmoryPresence(
			fmt::format(
				"SELECT 1 FROM character_nms_vault WHERE character_id = {} AND {} LIMIT 1",
				character_id,
				ArmoryItemSql()
			),
			true
		);
	}

	ArmoryPresence CorpseHasArmory(uint32 character_id)
	{
		return QueryArmoryPresence(
			fmt::format(
				"SELECT 1 FROM character_corpse_items i "
				"INNER JOIN character_corpses c ON c.id = i.corpse_id "
				"WHERE c.charid = {} AND {} LIMIT 1",
				character_id,
				ArmoryItemSql()
			),
			false
		);
	}

	bool SlotFitsArmoryGrant(int16 slot)
	{
		return (slot >= EQ::invslot::GENERAL_BEGIN && slot <= EQ::invslot::GENERAL_END)
			|| (slot >= EQ::invbag::GENERAL_BAGS_BEGIN && slot <= EQ::invbag::GENERAL_BAGS_END);
	}

	bool RefuseArmoryDeposit(Client *c, const EQ::ItemInstance *inst)
	{
		if (!inst || !InstanceIsArmory(inst)) {
			return false;
		}
		if (c) {
			c->Message(Chat::Red, "[NMS] The Nautilus Vault cannot be stored here.");
		}
		return true;
	}
}

void NmsVaultRefreshCache(Client *c)
{
	if (!c) {
		return;
	}

	locker_cache.erase(c->CharacterID());
	if (!NmsVaultEnabled() || !EnsureTables()) {
		return;
	}

	LockerCache cache;
	std::vector<NmsVaultItem> items;
	if (!NmsVaultLoad(c->CharacterID(), items)) {
		return;
	}
	if (const auto *row = NmsVaultFind(items, NMS_VAULT_PROC_PRIMARY, 0)) {
		cache.primary = row->item_id;
		for (int i = 0; i < 6; ++i) {
			cache.primary_aug[i] = row->aug[i];
		}
	}
	if (const auto *row = NmsVaultFind(items, NMS_VAULT_PROC_RANGED, 0)) {
		cache.ranged = row->item_id;
		for (int i = 0; i < 6; ++i) {
			cache.ranged_aug[i] = row->aug[i];
		}
	}
	if (const auto *row = NmsVaultFind(items, NMS_VAULT_PROC_SECONDARY, 0)) {
		cache.secondary = row->item_id;
		cache.secondary_charges = row->charges;
		for (int i = 0; i < 6; ++i) {
			cache.secondary_aug[i] = row->aug[i];
		}
		if (const auto *item = database.GetItem(row->item_id)) {
			cache.secondary_is_shield = item->ItemType == EQ::item::ItemTypeShield;
		}
	}
	locker_cache[c->CharacterID()] = cache;
}

bool NmsVaultEnabled()
{
	return RuleB(Custom, NautilusVault);
}

int NmsVaultPageForSlot(int slot)
{
	if (slot < NMS_VAULT_SLOT_MIN || slot > NMS_VAULT_SLOT_MAX) {
		return 1;
	}
	if (slot <= 60) {
		return ((slot - 1) / 10) + 1;
	}
	if (slot <= 70) {
		return 7;
	}
	if (slot <= 80) {
		return 8;
	}
	return 9;
}

bool NmsVaultSlotValid(int slot)
{
	return slot >= NMS_VAULT_SLOT_MIN && slot <= NMS_VAULT_SLOT_MAX;
}

bool NmsVaultTablesReady()
{
	return EnsureTables();
}

bool NmsVaultLoad(uint32 character_id, std::vector<NmsVaultItem> &items)
{
	items.clear();
	if (!EnsureTables()) {
		return false;
	}

	auto results = database.QueryDatabase(fmt::format(
		"SELECT slot, bag_slot, item_id, charges, aug1, aug2, aug3, aug4, aug5, aug6, "
		"instnodrop, custom_data, ornament_icon, ornament_idfile, ornament_hero_model, guid "
		"FROM character_nms_vault WHERE character_id = {} ORDER BY slot, bag_slot",
		character_id
	));
	if (!results.Success()) {
		return false;
	}

	for (auto row = results.begin(); row != results.end(); ++row) {
		NmsVaultItem item;
		item.slot = Strings::ToInt(row[0]);
		item.bag_slot = Strings::ToInt(row[1]);
		item.item_id = Strings::ToUnsignedInt(row[2]);
		item.charges = static_cast<int16>(Strings::ToInt(row[3]));
		for (int i = 0; i < 6; ++i) {
			item.aug[i] = Strings::ToUnsignedInt(row[4 + i]);
		}
		// custom_data is the only nullable column here; Strings::To*(nullptr) would build a
		// std::string from a null pointer, so every field is guarded rather than just that
		// one - a NULL from a hand-edited row must not be undefined behaviour.
		item.attuned             = row[10] && Strings::ToInt(row[10]) != 0;
		item.custom_data         = row[11] ? row[11] : "";
		item.ornament_icon       = row[12] ? Strings::ToUnsignedInt(row[12]) : 0;
		item.ornament_idfile     = row[13] ? Strings::ToUnsignedInt(row[13]) : 0;
		item.ornament_hero_model = row[14] ? Strings::ToUnsignedInt(row[14]) : 0;
		item.guid                = row[15] ? Strings::ToUnsignedBigInt(row[15]) : 0;
		items.push_back(item);
	}
	return true;
}

static bool LoadVaultForClient(Client *c, std::vector<NmsVaultItem> &items)
{
	if (!c || !NmsVaultLoad(c->CharacterID(), items)) {
		if (c) {
			c->Message(Chat::Red, "[NMS] Could not read your vault.");
		}
		return false;
	}
	return true;
}

const NmsVaultItem *NmsVaultFind(const std::vector<NmsVaultItem> &items, int slot, int bag_slot)
{
	for (const auto &item : items) {
		if (item.slot == slot && item.bag_slot == bag_slot) {
			return &item;
		}
	}
	return nullptr;
}

bool NmsVaultSaveItem(uint32 character_id, const NmsVaultItem &item)
{
	if (!EnsureTables()) {
		return false;
	}

	auto results = database.QueryDatabase(fmt::format(
		"REPLACE INTO character_nms_vault "
		"(character_id, slot, bag_slot, item_id, charges, aug1, aug2, aug3, aug4, aug5, aug6, "
		"instnodrop, custom_data, ornament_icon, ornament_idfile, ornament_hero_model, guid) "
		"VALUES ({}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, '{}', {}, {}, {}, {})",
		character_id,
		item.slot,
		item.bag_slot,
		item.item_id,
		item.charges,
		item.aug[0],
		item.aug[1],
		item.aug[2],
		item.aug[3],
		item.aug[4],
		item.aug[5],
		item.attuned ? 1 : 0,
		// custom_data is free-form text written by quest scripts - the only non-numeric
		// value in this statement, and the only one that must be escaped.
		Strings::Escape(item.custom_data),
		item.ornament_icon,
		item.ornament_idfile,
		item.ornament_hero_model,
		item.guid
	));
	if (results.Success()) {
		return true;
	}
	return ReadVaultRowState(character_id, item) == VaultRowState::Match;
}

bool NmsVaultDeleteItem(uint32 character_id, int slot, int bag_slot)
{
	if (!EnsureTables()) {
		return false;
	}

	if (bag_slot == 0) {
		auto results = database.QueryDatabase(fmt::format(
			"DELETE FROM character_nms_vault WHERE character_id = {} AND slot = {}",
			character_id,
			slot
		));
		return results.Success() && results.RowsAffected() > 0;
	}

	auto results = database.QueryDatabase(fmt::format(
		"DELETE FROM character_nms_vault WHERE character_id = {} AND slot = {} AND bag_slot = {}",
		character_id,
		slot,
		bag_slot
	));
	return results.Success() && results.RowsAffected() > 0;
}

void NmsVaultSendRefresh(Client *c, int open_page)
{
	if (!c || !NmsVaultEnabled() || !EnsureTables()) {
		return;
	}

	std::vector<NmsVaultItem> items;
	if (!NmsVaultLoad(c->CharacterID(), items)) {
		return;
	}

	SendLine(c, "VAULTDATA|CLEAR");
	for (const auto &row : items) {
		if (row.bag_slot != 0) {
			continue;
		}
		const auto *item = database.GetItem(row.item_id);
		if (!item) {
			continue;
		}

		const int page = NmsVaultPageForSlot(row.slot);
		const bool is_bag = item->IsClassBag();
		const int bag_slots = is_bag ? item->BagSlots : 0;
		const std::string bag_contents = is_bag ? BagContentsField(items, row.slot) : "";

		SendLine(c, fmt::format(
			"VAULTDATA|ADD|{}|{}|{}|{}|{}|{}|{}|{}|{}|{}|{}|{}|{}|{}|{}",
			page,
			row.slot,
			row.item_id,
			row.charges,
			item->Icon,
			SanitizeField(item->Name),
			bag_contents,
			row.aug[0],
			row.aug[1],
			row.aug[2],
			row.aug[3],
			row.aug[4],
			row.aug[5],
			item->NoDrop == 0 ? 1 : 0,
			bag_slots
		));
	}

	if (open_page < 1) {
		open_page = 1;
	}
	SendLine(c, fmt::format("VAULTDATA|OPEN|{}", open_page));
}

void NmsVaultHandlePage(Client *c, int page)
{
	if (!c || !NmsVaultEnabled() || !EnsureTables()) {
		return;
	}
	// Clamp both ends. The page set is fixed at 1-9 (NmsVaultPageForSlot), and this value is
	// player-supplied - it is formatted straight into VAULTDATA|OPEN|{} and handed to the
	// client add-on, whose parser is not in this repo.
	if (page < NMS_VAULT_PAGE_MIN) {
		page = NMS_VAULT_PAGE_MIN;
	}
	if (page > NMS_VAULT_PAGE_MAX) {
		page = NMS_VAULT_PAGE_MAX;
	}
	NmsVaultSendRefresh(c, page);
}

static EQ::ItemInstance *PeekCursor(Client *c)
{
	auto *cursor = c->GetInv().GetItem(EQ::invslot::slotCursor);
	if (!cursor) {
		c->Message(Chat::Red, "[NMS] Put an item on your cursor first.");
		return nullptr;
	}
	return cursor;
}

void NmsVaultHandleDeposit(Client *c, int slot)
{
	if (!c || !NmsVaultEnabled() || !EnsureTables() || !NmsVaultSlotValid(slot)) {
		return;
	}

	std::vector<NmsVaultItem> items;
	if (!LoadVaultForClient(c, items)) {
		return;
	}
	if (VaultSlotOccupied(items, slot)) {
		c->Message(Chat::Red, "[NMS] That vault slot is not empty.");
		return;
	}

	auto *cursor = PeekCursor(c);
	if (!cursor) {
		return;
	}
	if (RefuseArmoryDeposit(c, cursor)) {
		return;
	}

	auto *taken = TakeCursorIfPersisted(c);
	if (!taken) {
		c->Message(Chat::Red, "[NMS] Could not remove that item from your cursor.");
		return;
	}
	if (!SaveVaultSlot(c->CharacterID(), slot, taken)) {
		RestoreTakenCursor(c, taken);
		c->Message(Chat::Red, "[NMS] Could not save that item to the vault.");
		return;
	}
	safe_delete(taken);
	AfterVaultMutation(c, slot, {});
	NmsVaultSendRefresh(c, NmsVaultPageForSlot(slot));
}

void NmsVaultHandleWithdraw(Client *c, int slot, int quantity)
{
	if (!c || !NmsVaultEnabled() || !EnsureTables() || !NmsVaultSlotValid(slot)) {
		return;
	}

	std::vector<NmsVaultItem> items;
	if (!LoadVaultForClient(c, items)) {
		return;
	}
	const auto *row = NmsVaultFind(items, slot, 0);
	if (!row) {
		c->Message(Chat::Red, "[NMS] That vault slot is empty.");
		return;
	}

	auto *inst = MakeInstance(*row);
	if (!inst) {
		c->Message(Chat::Red, "[NMS] Could not recreate that vault item.");
		return;
	}

	std::vector<NmsVaultItem> snapshot;
	for (const auto &inner : items) {
		if (inner.slot != slot) {
			continue;
		}
		snapshot.push_back(inner);
		if (inner.bag_slot <= 0) {
			continue;
		}
		// Re-validate the DB-sourced bag slot. The deposit path checks this, but the whole
		// bag withdraw re-reads rows and trusted them: an index at or beyond the bag's
		// BagSlots is dropped by UpdateInventorySlot's `i < BagSlots` loop the next time the
		// bag is saved, so the item silently disappears. Reachable from a hand-edited row or
		// from an item whose BagSlots shrank in item data after the deposit.
		if (!ParentIsBagWithSlot(items, slot, inner.bag_slot)) {
			LogError(
				"NmsVault: character {} slot {} has an out-of-range bag_slot {}; refusing the withdraw",
				c->CharacterID(),
				slot,
				inner.bag_slot
			);
			safe_delete(inst);
			c->Message(Chat::Red, "[NMS] That vault bag has a damaged entry - contact a GM.");
			return;
		}

		auto *bag_item = MakeInstance(inner);
		if (!bag_item) {
			safe_delete(inst);
			c->Message(Chat::Red, "[NMS] Could not recreate that vault bag.");
			return;
		}
		const uint8 bag_index = static_cast<uint8>(inner.bag_slot - 1);
		inst->PutItem(bag_index, *bag_item);
		safe_delete(bag_item);
		if (!inst->GetItem(bag_index)) {
			safe_delete(inst);
			c->Message(Chat::Red, "[NMS] Could not recreate that vault bag.");
			return;
		}
	}

	const NmsVaultItem original = *row;
	// Only a STACKABLE item may be split: there, charges is the stack size and taking one
	// leaves the rest behind. On a non-stackable item charges is the charge count of a
	// single physical item (a 20-charge clicky), so splitting it would hand the player a
	// second physical item and leave the original in the vault - duplication, repeatable
	// once per charge. Stock uses this exact test for the same reason (corpse.cpp:1703:
	// `count = inst->IsStackable() ? inst->GetCharges() : 1`).
	const bool one_charge = quantity == 1 && original.charges > 1 && inst->IsStackable();
	if (one_charge) {
		inst->SetCharges(1);
		NmsVaultItem remain = original;
		remain.charges = static_cast<int16>(original.charges - 1);
		// The withdrawn instance keeps the original serial; the remainder must NOT, or the
		// two halves of the split would both be live with the same one. Serials are what the
		// Bazaar uses to tell otherwise-identical stacks apart (item_instance.cpp), so a
		// collision is the one thing they cannot have. Zero means "assign a fresh serial on
		// the next withdraw" - MakeInstance only restores a stored serial when guid != 0.
		remain.guid = 0;
		if (!NmsVaultSaveItem(c->CharacterID(), remain)) {
			c->Message(Chat::Red, "[NMS] Could not update that vault item.");
			safe_delete(inst);
			return;
		}
	}
	else if (!NmsVaultDeleteItem(c->CharacterID(), slot, 0)) {
		c->Message(Chat::Red, "[NMS] Could not update that vault item.");
		safe_delete(inst);
		return;
	}

	const int16 before = inst->GetCharges();
	if (!DeliverToPlayer(c, inst)) {
		const int16 left = inst->GetCharges();
		RestoreWithdrawOnFail(c, inst, before, original, one_charge, &snapshot);
		if (left >= before) {
			c->Message(Chat::Red, "[NMS] Your inventory is full.");
			safe_delete(inst);
			return;
		}
	}

	std::vector<uint16> fade_spells;
	CollectClickySpells(items, slot, fade_spells);

	safe_delete(inst);
	AfterVaultMutation(c, slot, fade_spells);
	NmsVaultSendRefresh(c, NmsVaultPageForSlot(slot));
}

void NmsVaultHandleDepositBagItem(Client *c, int slot, int bag_slot)
{
	if (!c || !NmsVaultEnabled() || !EnsureTables() || !NmsVaultSlotValid(slot)) {
		return;
	}

	std::vector<NmsVaultItem> items;
	if (!LoadVaultForClient(c, items)) {
		return;
	}
	if (!ParentIsBagWithSlot(items, slot, bag_slot)) {
		c->Message(Chat::Red, "[NMS] There is no bag in that vault slot.");
		return;
	}
	if (NmsVaultFind(items, slot, bag_slot)) {
		c->Message(Chat::Red, "[NMS] That bag slot is not empty.");
		return;
	}

	auto *inst = PeekCursor(c);
	if (!inst) {
		return;
	}
	if (RefuseArmoryDeposit(c, inst)) {
		return;
	}
	if (inst->IsClassBag()) {
		c->Message(Chat::Red, "[NMS] Cannot deposit a container into a vault bag.");
		return;
	}

	auto *taken = TakeCursorIfPersisted(c);
	if (!taken) {
		c->Message(Chat::Red, "[NMS] Could not remove that item from your cursor.");
		return;
	}
	auto row = FromInstance(slot, bag_slot, taken);
	if (!NmsVaultSaveItem(c->CharacterID(), row)) {
		if (!FinishFailedVaultChildWrite(c->CharacterID(), row)) {
			RestoreTakenCursor(c, taken);
			c->Message(Chat::Red, "[NMS] Could not save that item to the vault.");
			return;
		}
	}
	safe_delete(taken);
	AfterVaultMutation(c, slot, {});
	NmsVaultSendRefresh(c, NmsVaultPageForSlot(slot));
}

void NmsVaultHandleWithdrawBagItem(Client *c, int slot, int bag_slot, int quantity)
{
	if (!c || !NmsVaultEnabled() || !EnsureTables() || !NmsVaultSlotValid(slot)) {
		return;
	}

	std::vector<NmsVaultItem> items;
	if (!LoadVaultForClient(c, items)) {
		return;
	}
	if (!ParentIsBagWithSlot(items, slot, bag_slot)) {
		c->Message(Chat::Red, "[NMS] There is no bag in that vault slot.");
		return;
	}

	const auto *row = NmsVaultFind(items, slot, bag_slot);
	if (!row) {
		c->Message(Chat::Red, "[NMS] That bag slot is empty.");
		return;
	}

	auto *inst = MakeInstance(*row);
	if (!inst) {
		return;
	}

	const NmsVaultItem original = *row;
	// Stackable-only split, and the remainder gets a fresh serial - see the identical block
	// in NmsVaultHandleWithdraw for why on both counts.
	const bool one_charge = quantity == 1 && original.charges > 1 && inst->IsStackable();
	if (one_charge) {
		inst->SetCharges(1);
		NmsVaultItem remain = original;
		remain.charges = static_cast<int16>(original.charges - 1);
		remain.guid = 0;
		if (!NmsVaultSaveItem(c->CharacterID(), remain)) {
			c->Message(Chat::Red, "[NMS] Could not update that vault item.");
			safe_delete(inst);
			return;
		}
	}
	else if (!NmsVaultDeleteItem(c->CharacterID(), slot, bag_slot)) {
		c->Message(Chat::Red, "[NMS] Could not update that vault item.");
		safe_delete(inst);
		return;
	}

	const int16 before = inst->GetCharges();
	if (!DeliverToPlayer(c, inst)) {
		const int16 left = inst->GetCharges();
		RestoreWithdrawOnFail(c, inst, before, original, one_charge, nullptr);
		if (left >= before) {
			c->Message(Chat::Red, "[NMS] Your inventory is full.");
			safe_delete(inst);
			return;
		}
	}

	std::vector<uint16> fade_spells;
	if (slot >= NMS_VAULT_CLICKY_BEGIN && slot <= NMS_VAULT_CLICKY_END) {
		const auto *item = database.GetItem(original.item_id);
		if (IsVaultClicky(item)) {
			fade_spells.push_back(static_cast<uint16>(item->Click.Effect));
		}
	}

	safe_delete(inst);
	AfterVaultMutation(c, slot, fade_spells);
	NmsVaultSendRefresh(c, NmsVaultPageForSlot(slot));
}

void NmsVaultHandleBank(Client *c)
{
	if (!c || !NmsVaultEnabled() || !EnsureTables()) {
		return;
	}

	c->SetNmsVaultBank(true);
	bank_anchor[c->CharacterID()] = BankAnchor{c->GetX(), c->GetY(), c->GetZ()};

	auto outapp = new EQApplicationPacket(OP_BankerChange, sizeof(BankerChange_Struct));
	auto *bc = reinterpret_cast<BankerChange_Struct *>(outapp->pBuffer);
	bc->copper = c->GetPP().copper;
	bc->silver = c->GetPP().silver;
	bc->gold = c->GetPP().gold;
	bc->platinum = c->GetPP().platinum;
	bc->copper_bank = c->GetPP().copper_bank;
	bc->silver_bank = c->GetPP().silver_bank;
	bc->gold_bank = c->GetPP().gold_bank;
	bc->platinum_bank = c->GetPP().platinum_bank;
	c->QueuePacket(outapp);
	safe_delete(outapp);

	// Inventory:LazyLoadBank keeps bank and shared-bank items from the client until they
	// stand near a real banker, so a vault bank opened anywhere else would show whatever
	// the client last had cached. Deliver both banks the same way BulkSendInventoryItems
	// does when the rule is off - one ItemPacketTrade per occupied slot.
	for (int16 slot_id = EQ::invslot::BANK_BEGIN; slot_id <= EQ::invslot::BANK_END; ++slot_id) {
		const EQ::ItemInstance *inst = c->GetInv().GetItem(slot_id);
		if (inst) {
			c->SendItemPacket(slot_id, inst, ItemPacketType::ItemPacketTrade);
		}
	}
	for (int16 slot_id = EQ::invslot::SHARED_BANK_BEGIN; slot_id <= EQ::invslot::SHARED_BANK_END; ++slot_id) {
		const EQ::ItemInstance *inst = c->GetInv().GetItem(slot_id);
		if (inst) {
			c->SendItemPacket(slot_id, inst, ItemPacketType::ItemPacketTrade);
		}
	}
}

void NmsVaultHandleMerchant(Client *c)
{
	if (!c || !NmsVaultEnabled() || !EnsureTables()) {
		return;
	}

	if (c->GetNmsVaultMerchantId()) {
		if (auto *existing = entity_list.GetNPCByID(static_cast<uint16>(c->GetNmsVaultMerchantId()))) {
			c->SetNmsVaultMerchant(true);
			auto outapp = new EQApplicationPacket(OP_ShopRequest, sizeof(MerchantClick_Struct));
			auto *mco = reinterpret_cast<MerchantClick_Struct *>(outapp->pBuffer);
			mco->npc_id = existing->GetID();
			mco->player_id = 0;
			mco->command = MerchantActions::Open;
			mco->rate = 1.0f;
			mco->tab_display = 1;
			c->QueuePacket(outapp);
			safe_delete(outapp);
			c->SetMerchantSessionEntityID(existing->GetID());
			c->BulkSendMerchantInventory(existing->MerchantType, existing->GetNPCTypeID());
			return;
		}
		c->SetNmsVaultMerchantId(0);
		c->SetNmsVaultMerchant(false);
	}

	// The server's spell loremaster (the "AA spell banker"): reuse its template so the
	// vault merchant shows the same stock and look. Fall back to the generic pick if the
	// NPC is ever renamed or removed.
	auto pick = content_db.QueryDatabase(
		"SELECT id FROM npc_types WHERE name = 'Loremaster_Dorinan' AND merchant_id > 0 LIMIT 1"
	);
	if (!pick.Success() || pick.RowCount() == 0) {
		pick = content_db.QueryDatabase(
			"SELECT id FROM npc_types WHERE `class` = 41 AND merchant_id > 0 "
			"ORDER BY is_parcel_merchant DESC, id LIMIT 1"
		);
	}
	if (!pick.Success() || pick.RowCount() == 0) {
		c->Message(Chat::Red, "[NMS] No merchant template is available to open.");
		return;
	}

	const uint32 npc_id = Strings::ToUnsignedInt(pick.begin()[0]);
	const auto *npc_type = content_db.LoadNPCTypesData(npc_id);
	if (!npc_type) {
		c->Message(Chat::Red, "[NMS] Could not load a merchant template.");
		return;
	}

	auto *npc = new NPC(npc_type, nullptr, c->GetPosition(), GravityBehavior::Flying);
	entity_list.AddNPC(npc, true, true);
	npc->SetInvisible(1);
	c->SetNmsVaultMerchantId(npc->GetID());
	c->SetNmsVaultMerchant(true);

	auto outapp = new EQApplicationPacket(OP_ShopRequest, sizeof(MerchantClick_Struct));
	auto *mco = reinterpret_cast<MerchantClick_Struct *>(outapp->pBuffer);
	mco->npc_id = npc->GetID();
	mco->player_id = 0;
	mco->command = MerchantActions::Open;
	mco->rate = 1.0f;
	mco->tab_display = 1;
	c->QueuePacket(outapp);
	safe_delete(outapp);
	c->SetMerchantSessionEntityID(npc->GetID());
	c->BulkSendMerchantInventory(npc->MerchantType, npc->GetNPCTypeID());
}

bool NmsVaultBankAccess(Client *c)
{
	if (!c || !NmsVaultEnabled() || !EnsureTables() || !c->GetNmsVaultBank()) {
		return false;
	}

	// Bounded to where the window was opened, using the same range stock allows from a banker
	// NPC (USE_NPC_RANGE2). Deliberately a pure query: this is called from nine sites,
	// several of them inside OPMoveCoin's multi-step coin moves, so it must not mutate
	// session state part-way through an operation. Walking away therefore SUSPENDS vault
	// banking rather than ending it - which is also how a real banker behaves, since you can
	// walk back and resume. No anchor means no open session.
	auto it = bank_anchor.find(c->CharacterID());
	if (it == bank_anchor.end()) {
		return false;
	}

	const float dx = c->GetX() - it->second.x;
	const float dy = c->GetY() - it->second.y;
	const float dz = c->GetZ() - it->second.z;
	return ((dx * dx) + (dy * dy) + (dz * dz)) <= static_cast<float>(USE_NPC_RANGE2);
}

bool NmsVaultIsMerchant(Client *c, uint16 entity_id)
{
	return c
		&& NmsVaultEnabled()
		&& EnsureTables()
		&& c->GetNmsVaultMerchant()
		&& entity_id
		&& c->GetNmsVaultMerchantId() == entity_id;
}

int NmsVaultTryDepositInstance(Client *c, EQ::ItemInstance *inst)
{
	if (!c || !inst || !NmsVaultEnabled() || !EnsureTables()) {
		return 0;
	}
	if (RefuseArmoryDeposit(c, inst)) {
		return 0;
	}

	std::vector<NmsVaultItem> items;
	if (!NmsVaultLoad(c->CharacterID(), items)) {
		return 0;
	}
	int slot = 0;
	for (int candidate = NMS_VAULT_SLOT_MIN; candidate <= 60; ++candidate) {
		if (!VaultSlotOccupied(items, candidate)) {
			slot = candidate;
			break;
		}
	}
	if (!slot) {
		return 0;
	}

	if (!SaveVaultSlot(c->CharacterID(), slot, inst)) {
		return 0;
	}
	AfterVaultMutation(c, slot, {});
	NmsVaultSendRefresh(c, NmsVaultPageForSlot(slot));
	return slot;
}

void NmsVaultApplyClickies(Client *c)
{
	if (!c || !NmsVaultEnabled() || !EnsureTables()) {
		return;
	}

	std::vector<NmsVaultItem> items;
	if (!NmsVaultLoad(c->CharacterID(), items)) {
		return;
	}
	for (const auto &row : items) {
		if (row.bag_slot != 0
			|| row.slot < NMS_VAULT_CLICKY_BEGIN
			|| row.slot > NMS_VAULT_CLICKY_END) {
			continue;
		}
		const auto *item = database.GetItem(row.item_id);
		if (CanUseVaultClicky(c, item)) {
			c->SpellOnTarget(item->Click.Effect, c);
		}
		for (const auto &inner : items) {
			if (inner.slot != row.slot || inner.bag_slot <= 0) {
				continue;
			}
			const auto *bag_item = database.GetItem(inner.item_id);
			if (CanUseVaultClicky(c, bag_item)) {
				c->SpellOnTarget(bag_item->Click.Effect, c);
			}
		}
	}
}

void NmsVaultOnZoneIn(Client *c)
{
	if (!c) {
		return;
	}
	DepopVaultMerchant(c);
	c->SetNmsVaultBank(false);
	c->SetNmsVaultMerchant(false);
	c->SetNmsVaultMerchantId(0);
	bank_anchor.erase(c->CharacterID());
	NmsVaultRefreshCache(c);

	// The locker cache is populated here, but zone-in's own CalcBonuses has already run by
	// this point (Handle_Connect_OP_ZoneEntry precedes ClientReady in the connect sequence),
	// so without this the slot-82 bonuses were missing until some unrelated event - a buff
	// fade, an equipment change - happened to recalculate. Only worth a recalc when the
	// character actually has a locker item, since CalcBonuses is not cheap.
	// Only the SECONDARY locker slot feeds NmsVaultApplyLockerBonuses. Primary and ranged
	// feed NmsVaultProcItem, which is read live on each swing and needs no recalculation.
	auto cached = locker_cache.find(c->CharacterID());
	if (cached != locker_cache.end() && cached->second.secondary) {
		c->CalcBonuses();
	}

	NmsVaultApplyClickies(c);
	NmsVaultGrantArmory(c);
}

void NmsVaultGrantArmory(Client *c)
{
	if (!c || !NmsVaultEnabled() || !EnsureTables()) {
		return;
	}
	const auto *item = database.GetItem(NMS_VAULT_ARMORY_ITEM_ID);
	if (!item) {
		return;
	}
	if (CharacterHasArmory(c)) {
		return;
	}
	if (VaultHasArmory(c->CharacterID()) != ArmoryPresence::Absent) {
		return;
	}
	if (CorpseHasArmory(c->CharacterID()) != ArmoryPresence::Absent) {
		return;
	}

	int16 slot = c->GetInv().FindFirstFreeSlotThatFitsItem(item);
	if (!SlotFitsArmoryGrant(slot)) {
		// SaveCursor persists at most CURSOR_BAG_COUNT entries and still returns true
		// when it drops the rest. Do not append a 201st in-memory ghost.
		if (c->GetInv().CursorSize() >= EQ::invbag::CURSOR_BAG_COUNT) {
			return;
		}
		slot = EQ::invslot::slotCursor;
	}

	auto *inst = database.CreateItem(item, item->MaxCharges);
	if (!inst) {
		return;
	}
	const bool saved = c->PutItemInInventory(slot, *inst, true);
	safe_delete(inst);
	if (!saved) {
		if (slot != EQ::invslot::slotCursor) {
			c->DeleteItemInInventory(slot, 0, true);
		}
		return;
	}
	if (slot == EQ::invslot::slotCursor && !CursorPersisted(c)) {
		return;
	}
	if (!CharacterHasArmory(c)) {
		return;
	}

	c->Message(
		Chat::Yellow,
		"[NMS] The Nautilus Vault has been bound to you. Right-click it to open storage, bank, merchant, Proc Locker, and clickies."
	);
}

bool NmsVaultTryOpenFromItem(Client *c, uint32 item_id)
{
	if (!c || !NmsVaultIsArmoryItem(item_id)) {
		return false;
	}
	if (!NmsVaultEnabled() || !EnsureTables()) {
		c->Message(Chat::Red, "[NMS] The Nautilus Vault is sealed.");
		return true;
	}
	NmsVaultHandlePage(c, 1);
	return true;
}

void NmsVaultOnClientDestroy(Client *c)
{
	if (!c) {
		return;
	}

	// Logout and link-death both land here. DepopVaultMerchant was previously reachable only
	// from zone-in and SendMerchantEnd, so camping with the vault shop open left a real NPC
	// entity spawned at the player's position for the life of the zone process, one per
	// occurrence. The cache entries are keyed by character id with no tie to a live Client,
	// so they also have to go: left behind, a re-login into the same zone process would read
	// the previous session's locker state at CalcBonuses time.
	DepopVaultMerchant(c);
	locker_cache.erase(c->CharacterID());
	bank_anchor.erase(c->CharacterID());
}

void NmsVaultOnMerchantEnd(Client *c)
{
	DepopVaultMerchant(c);
}

const EQ::ItemData *NmsVaultProcItem(Client *c, uint16 hand)
{
	if (!c || !NmsVaultEnabled()) {
		return nullptr;
	}

	auto it = locker_cache.find(c->CharacterID());
	if (it == locker_cache.end()) {
		return nullptr;
	}

	uint32 item_id = 0;
	if (hand == EQ::invslot::slotPrimary) {
		item_id = it->second.primary;
	}
	else if (hand == EQ::invslot::slotSecondary) {
		item_id = it->second.secondary;
	}
	else if (hand == EQ::invslot::slotRange) {
		item_id = it->second.ranged;
	}

	if (!item_id) {
		return nullptr;
	}

	const auto *item = database.GetItem(item_id);
	if (!item) {
		return nullptr;
	}

	// Same rule as the slot-82 bonuses: a locker item does nothing for a character who is
	// not permitted to wear it, so the locker cannot lend one class another class's proc.
	// Two bitmask tests on the per-swing path - IsEquipable is Races & ... && Classes & ...
	// and nothing more (item_data.cpp), so this costs nothing measurable. Item TYPE is
	// deliberately not restricted here: any permitted locker item overrides the held
	// weapon's proc, which is the intended behaviour.
	if (!item->IsEquipable(c->GetBaseRace(), static_cast<uint16>(c->GetClassesBits()))) {
		return nullptr;
	}
	return item;
}

// Fills out_augs with the equipped locker item's augment ItemData for the hand's locker
// slot (up to max_augs) so TryWeaponProc can roll locker-side aug procs. Read-only on
// the cache: this is called from the per-swing path and must not mutate shared state.
int NmsVaultProcAugs(Client *c, uint16 hand, const EQ::ItemData **out_augs, int max_augs)
{
	if (!c || !out_augs || max_augs <= 0 || !NmsVaultEnabled()) {
		return 0;
	}

	auto it = locker_cache.find(c->CharacterID());
	if (it == locker_cache.end()) {
		return 0;
	}

	const uint32 *aug_ids = nullptr;
	if (hand == EQ::invslot::slotPrimary) {
		aug_ids = it->second.primary_aug;
	}
	else if (hand == EQ::invslot::slotSecondary) {
		aug_ids = it->second.secondary_aug;
	}
	else if (hand == EQ::invslot::slotRange) {
		aug_ids = it->second.ranged_aug;
	}
	if (!aug_ids) {
		return 0;
	}

	int count = 0;
	for (int i = 0; i < 6 && count < max_augs; ++i) {
		if (aug_ids[i] == 0) {
			continue;
		}
		const auto *aug = database.GetItem(aug_ids[i]);
		if (aug) {
			out_augs[count++] = aug;
		}
	}
	return count;
}

void NmsVaultApplyLockerBonuses(Client *c, StatBonuses *b)
{
	if (!c || !b || !NmsVaultEnabled()) {
		return;
	}

	auto it = locker_cache.find(c->CharacterID());
	if (it == locker_cache.end() || !it->second.secondary) {
		return;
	}

	if (!it->second.secondary_is_shield) {
		return;
	}
	if (const auto *worn = c->GetInv().GetItem(EQ::invslot::slotSecondary)) {
		if (worn->GetItem() && worn->GetItem()->ItemType == EQ::item::ItemTypeShield) {
			return;
		}
	}

	auto *inst = database.CreateItem(
		it->second.secondary,
		it->second.secondary_charges,
		it->second.secondary_aug[0],
		it->second.secondary_aug[1],
		it->second.secondary_aug[2],
		it->second.secondary_aug[3],
		it->second.secondary_aug[4],
		it->second.secondary_aug[5]
	);
	if (!inst) {
		return;
	}

	// A locker item grants nothing to a character who could not wear it. The vault is
	// storage, not a way around the class/race gate: this call previously passed
	// is_tribute = true, whose ONLY effect in AddItemBonuses is to skip exactly this check
	// (bonuses.cpp:277), so a Wizard could park a Warrior-only shield in slot 82 and collect
	// its AC, HP, heroics and shield block. Checked here as well as in AddItemBonuses so the
	// SetShieldEquipped() below is covered too - that flag is not gated by the bonus call.
	// IsEquipable takes the multiclass bitmask, so a character holding several classes is
	// judged on all of them (CODEBASE.md 3.1 - never branch on GetClass()).
	// Cast is lossless: player classes run 1..16 and GetPlayerClassBit returns uint16
	// (classes.h), so the whole mask fits. Explicit only to keep MSVC quiet on new code.
	if (!inst->IsEquipable(c->GetBaseRace(), static_cast<uint16>(c->GetClassesBits()))) {
		safe_delete(inst);
		return;
	}

	c->AddItemBonuses(inst, b, false, false, 0, false);
	if (inst->GetItem() && inst->GetItem()->ItemType == EQ::item::ItemTypeShield) {
		c->SetShieldEquipped(true);
	}
	safe_delete(inst);
}
