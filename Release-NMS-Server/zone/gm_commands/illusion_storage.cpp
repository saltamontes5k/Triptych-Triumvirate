/*
  Hacky custom illusion storage command
  Usage: #illusion help
	  #illusion store <spellid>
	  #illusion list
	  #illusion use <id>
*/

#include "../client.h"
#include "../command.h"
#include "../zonedb.h"
#include "../../common/say_link.h"
#include "../../common/spdat.h"
#include "fmt/format.h"

void command_illusion(Client *c, const Seperator *sep)
{
	if (SPDAT_RECORDS <= 0) {
		c->Message(Chat::White, "Spells not loaded.");
		return;
	}

	int args = sep->argnum;
	bool allowed = false;

	if (!args || !strcasecmp(sep->arg[1], "help")) {
		c->Message(Chat::White, "#illusion store - store an illusion from the item on your cursor (must be an illusion click effect)");
		c->Message(Chat::White, "#illusion list - view stored illusions");
		c->Message(Chat::White, "#illusion use <id> - cast a stored illusion by id (useful for macros)");
		return;
	}

	if (!strcasecmp(sep->arg[1], "store")) {
		uint32 spell_id = 0;
		uint32 item_id = 0;

		bool removed_from_cursor = false;
		const EQ::ItemInstance *cursor_inst = c->GetInv().GetItem(EQ::invslot::slotCursor);
		if (!cursor_inst || !cursor_inst->GetItem()) {
			c->Message(Chat::White, "Place an illusion item on your cursor and run: #illusion store");
			return;
		}

		item_id = cursor_inst->GetItem()->ID;
		const EQ::ItemData *item = database.GetItem(item_id);
		if (!item) {
			c->Message(Chat::White, "Invalid item on cursor.");
			return;
		}

		bool is_whitelisted = false;
		if (item->Click.Effect == 0 || !IsIllusionSpell(item->Click.Effect)) {
			for (auto &t : Strings::Split(RuleS(Items, IllusionStorageWhitelistItemIDs), ",")) {
				std::string s = Strings::Trim(t);
				if (s.empty())
					continue;
				if (Strings::ToUnsignedInt(s) == item_id) {
					is_whitelisted = true;
					break;
				}
			}

			if (!is_whitelisted) {
				c->Message(Chat::White, "Item on cursor does not contain an illusion click effect.");
				return;
			}
			LogInfo("Character [{}] storing whitelisted illusion item {}", c->GetName(), item_id);
		}
		spell_id = item->Click.Effect;
		removed_from_cursor = true;

		if (item->MaxCharges >= 1) {
			c->Message(Chat::Yellow, "Cannot store item with limited charges in illusion storage.");
			return;
		}

		// Prevent storing duplicate items in illusion storage for this character
		if (item_id) {
			std::vector<std::tuple<uint32, uint32, uint32>> existing;
			if (database.LoadCharacterIllusions(c->CharacterID(), existing)) {
				for (auto &t : existing) {
					uint32 eid, esid, eiid;
					std::tie(eid, esid, eiid) = t;
					if (eiid && eiid == item_id) {
						c->Message(Chat::Yellow, "That item is already stored in your illusion storage (id %u).", eid);
						return;
					}
				}
			}
		}

		uint32 new_id = 0;
		if (!database.SaveCharacterIllusion(c->CharacterID(), spell_id, item_id, new_id)) {
			c->Message(Chat::Yellow, "Failed to store illusion.");
			return;
		}

		// If we stored the cursor item, remove it entirely from the player's cursor (it's now in storage)
		if (removed_from_cursor && item_id) {
			// pass quantity 0 to fully delete the item rather than decrementing a charge
			c->DeleteItemInInventory(EQ::invslot::slotCursor, 0, true);
		}

		c->Message(Chat::Green, "Stored illusion id %u for spell %u (item %u).", new_id, spell_id, item_id);
		LogInfo("Character [{}] stored illusion record id={} item={}", c->GetName(), new_id, item_id);
		return;
	}

	if (!strcasecmp(sep->arg[1], "list")) {
		std::vector<std::tuple<uint32, uint32, uint32>> list;
		if (!database.LoadCharacterIllusions(c->CharacterID(), list)) {
			c->Message(Chat::Yellow, "Failed to load illusions.");
			return;
		}

		if (list.empty()) {
			c->Message(Chat::White, "No stored illusions.");
			return;
		}

		for (auto &t : list) {
			uint32 id, sid, iid;
			std::tie(id, sid, iid) = t;
			std::string retrieve_say = Saylink::Create(fmt::format("{} retrieve {}", sep->arg[0], id), true, "retrieve");
			std::string retrieve_bracket = fmt::format("[{}]", retrieve_say);
			std::string use_say = Saylink::Create(fmt::format("{} use {}", sep->arg[0], id), true, "use");
			std::string use_bracket = fmt::format("[{}]", use_say);

			if (iid) {
				const std::string &item_link = database.CreateItemLink(iid);
				c->Message(Chat::White, "id: %u %s %s %s", id, retrieve_bracket.c_str(), item_link.c_str(), use_bracket.c_str());
			} else {
				c->Message(Chat::White, "id: %u %s %s %s", id, retrieve_bracket.c_str(), GetSpellName(sid), use_bracket.c_str());
			}
		}

		return;
	}

	if (!strcasecmp(sep->arg[1], "use")) {
		// Usage: #illusion use <id>
		if (sep->argnum <= 1) {
			c->Message(Chat::White, "Usage: #illusion use <id>");
			return;
		}

		std::vector<std::tuple<uint32, uint32, uint32>> list;
		if (!database.LoadCharacterIllusions(c->CharacterID(), list)) {
			c->Message(Chat::Yellow, "Failed to load illusions.");
			return;
		}

		uint32 spell_id = 0;
		uint32 item_id = 0;

		if (!sep->IsNumber(2)) {
			c->Message(Chat::White, "Usage: #illusion use <id>");
			return;
		}

		uint32 want_id = Strings::ToUnsignedInt(sep->arg[2]);
		bool found = false;
		for (auto &t : list) {
			uint32 id, sid, iid;
			std::tie(id, sid, iid) = t;
			if (id == want_id) {
				spell_id = sid;
				item_id = iid;
				found = true;
				break;
			}
		}

		if (!found) {
			c->Message(Chat::Yellow, "No stored illusion with id %u.", want_id);
			return;
		}
		allowed = true;

		int32 cast_time = spells[spell_id].cast_time;
		const EQ::ItemData *item = nullptr;
		if (item_id) {
			item = database.GetItem(item_id);
			if (item) {
				cast_time = item->CastTime;
			}
		}

		if (!allowed) {
			c->Message(Chat::Yellow, "You may only use your own stored illusions.");
			return;
		}

		if (!c->CastSpell(spell_id, c->GetID(), EQ::spells::CastingSlot::Item, cast_time)) {
			c->Message(Chat::Yellow, "Failed to cast illusion %u.", spell_id);
			return;
		}

		LogInfo("Character [{}] used stored illusion id={} item={}", c->GetName(), want_id, item_id);

		if (item && item->RecastDelay > 0) {
			c->SetItemCooldown(item->ID, false, item->RecastDelay);
		}

		// c->Message(Chat::Green, "Casting illusion %s (%u).", GetSpellName(spell_id), spell_id);
		return;
	}

	if (!strcasecmp(sep->arg[1], "retrieve")) {
		if (!sep->IsNumber(2)) {
			c->Message(Chat::White, "Usage: #illusion retrieve <id>");
			return;
		}

		uint32 want_id = Strings::ToUnsignedInt(sep->arg[2]);

		std::vector<std::tuple<uint32, uint32, uint32>> list;
		if (!database.LoadCharacterIllusions(c->CharacterID(), list)) {
			c->Message(Chat::Yellow, "Failed to load illusions.");
			return;
		}

		uint32 item_id = 0;
		uint32 spell_id_for_record = 0;
		bool found = false;
		for (auto &t : list) {
			uint32 id, sid, iid;
			std::tie(id, sid, iid) = t;
			if (id == want_id) {
				item_id = iid;
				spell_id_for_record = sid;
				found = true;
				break;
			}
		}

		if (!found) {
			c->Message(Chat::Yellow, "No stored illusion with id %u.", want_id);
			return;
		}

		if (item_id) {
			const EQ::ItemData *item = database.GetItem(item_id);
			if (item) {
				if (item->LoreFlag || item->LoreGroup != 0) {
					const uint8 where_mask = invWherePersonal | invWhereBank | invWhereSharedBank | invWhereWorn | invWhereCursor;
					bool has = false;
					if (item->LoreFlag) {
						// look for the exact item id
						int16 slot_found = c->GetInv().HasItem(item_id, 1, where_mask);
						if (slot_found != INVALID_INDEX) {
							has = true;
							c->Message(Chat::Yellow, "Cannot retrieve stored illusion: you already possess the lore item in your inventory/bank (found in slot %d).", slot_found);
							return;
						}
					}

					if (!has && item->LoreGroup != 0) {
						if (item->LoreGroup == -1) {
							int16 slot_found = c->GetInv().HasItem(item_id, 1, ~invWhereSharedBank);
							if (slot_found != INVALID_INDEX) {
								has = true;
								c->Message(Chat::Yellow, "Cannot retrieve stored illusion: you already possess the lore item in your inventory/bank (found in slot %d).", slot_found);
								return;
							}
						} else {
							int16 slot_found = c->GetInv().HasItemByLoreGroup(item->LoreGroup, where_mask);
							if (slot_found != INVALID_INDEX) {
								has = true;
								c->Message(Chat::Yellow, "Cannot retrieve stored illusion: you already possess the lore group item in your inventory/bank (found in slot %d).", slot_found);
								return;
							}
						}
					}
				}
			}

			EQ::ItemInstance *test_inst = database.CreateItem(item_id);
			if (!test_inst) {
				c->Message(Chat::Yellow, "Failed to recreate stored item %u.", item_id);
				return;
			}

			int16 free_slot = c->GetInv().FindFirstFreeSlotThatFitsItemWithStacking(test_inst);
			if (free_slot == INVALID_INDEX) {
				delete test_inst;
				c->Message(Chat::Yellow, "No free inventory space to return stored item %u. Clear some space and try again.", item_id);
				return;
			}
			delete test_inst;
		}

		if (item_id) {
			EQ::ItemInstance *inst = database.CreateItem(item_id);
			if (!inst) {
				c->Message(Chat::Yellow, "Failed to recreate item %u for retrieval.", item_id);
				return;
			}

			if (!c->PutItemInInventoryWithStacking(inst)) {
				const EQ::ItemData *it = database.GetItem(item_id);
				const char *name = it ? it->Name : "<unknown item>";
				c->Message(Chat::Yellow, "Failed to place %s into your inventory. Try again.", name);
				delete inst;
				return;
			}

			if (!database.DeleteCharacterIllusion(c->CharacterID(), want_id)) {
				const EQ::ItemData *it = database.GetItem(item_id);
				const char *name = it ? it->Name : "<unknown item>";
				c->Message(Chat::Yellow, "Retrieved %s into inventory, but failed to remove storage record. Manual cleanup may be required.", name);
				LogInfo("Character [{}] failed to remove illusion record id={} item={} from storage", c->GetName(), want_id, item_id);
				return;
			}

			LogInfo("Character [{}] retrieved illusion id={} item={}", c->GetName(), want_id, item_id);
		} else {
			if (!database.DeleteCharacterIllusion(c->CharacterID(), want_id)) {
				c->Message(Chat::Yellow, "Failed to retrieve illusion %u.", want_id);
				LogInfo("Character [{}] failed to remove illusion record id={} from storage", c->GetName(), want_id);
				return;
			}
		}

		const EQ::ItemData *got_item = item_id ? database.GetItem(item_id) : nullptr;
		const char *got_name = got_item ? got_item->Name : GetSpellName(spell_id_for_record);
		c->Message(Chat::Green, "Retrieved from illusion storage - %s.", got_name);
		LogInfo("Character [{}] retrieved illusion id={} item={} name={}", c->GetName(), want_id, item_id, got_name);
		return;
	}

	c->Message(Chat::White, "Unknown subcommand, use %s help.", sep->arg[0]);
}
