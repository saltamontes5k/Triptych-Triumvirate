#include "../client.h"
#include <regex>

using EQ::spells::CastingSlot;

void command_castspellnms(Client *c, const Seperator *sep)
{
    if (SPDAT_RECORDS <= 0) {
        c->Message(Chat::Red, "Spells not loaded.");
        return;
    }

    if (!sep->argnum || !sep->msg || sep->msg[0] == '\0') {
        c->Message(Chat::White, "This command may be used to cast non-Detrimental spells directly from your spellbook while out of combat.");
        c->Message(Chat::White, "Usage: /cast [Spell Name (quoted if necessary) or Spell ID]");
        return;
    }

    // Extract everything after the first word (/cast)
    std::string spell_string;
    {
        std::string full_msg(sep->msg);
        size_t pos = full_msg.find_first_of(" \t");
        if (pos != std::string::npos) {
            spell_string = full_msg.substr(pos + 1);
        }
    }

    if (spell_string.empty()) {
        c->Message(Chat::White, "Please specify a spell to cast.");
        return;
    }

    // Strip quotes if present
    if (spell_string.front() == '"' && spell_string.back() == '"' && spell_string.length() > 1) {
        spell_string = spell_string.substr(1, spell_string.length() - 2);
    }

    if (c->GetRestTimer()) {
        c->Message(Chat::SpellFailure, "You cannot cast spells from your spellbook while in combat.");
        return;
    }

    uint16 spell_id = 0;
    int spell_book_slot = -1;

    // Try numeric ID first
    if (std::all_of(spell_string.begin(), spell_string.end(), ::isdigit)) {
        spell_id = static_cast<uint16>(Strings::ToUnsignedInt(spell_string));
        spell_book_slot = c->FindSpellBookSlotBySpellID(spell_id);
    } else {
        // Try by name
        spell_book_slot = c->FindSpellBookSlotBySpellName(spell_string);
        if (spell_book_slot >= 0) {
            spell_id = c->GetSpellIDByBookSlot(spell_book_slot);
        }
    }

    if (spell_book_slot == -1 || spell_id == 0 || spell_id >= SPDAT_RECORDS) {
        c->Message(
            Chat::SpellFailure,
            fmt::format(
                "The spell '{}' was not found in your spellbook.",
                spell_string
            ).c_str()
        );
        return;
    }

	if (!c->CanCastSpell(spell_id)) {
		c->Message(Chat::SpellFailure, "You are not high enough level to cast that spell.");
        return;
	}

    if (IsBardSong(spell_id)) {
        c->Message(Chat::SpellFailure, "You may not sing bard songs directly from your spellbook.");
        return;
    }

    if (IsDetrimentalSpell(spell_id)) {
        c->Message(Chat::SpellFailure, "You cannot cast detrimental spells directly from your spellbook.");
        return;
    }

    Mob* target = c->GetTarget() ? c->GetTarget() : c;
    uint16 target_id = target->GetID();

    if (spells[spell_id].target_type == ST_Self) {
        target_id = c->GetID();
    }

	Mob* target_mob = entity_list.GetMob(target_id);
	std::string target_name = target_mob ? target_mob->GetCleanName() : "Unknown";

    c->Message(
        Chat::Spells,
        fmt::format(
            "Casting {} on {} from your Spellbook.",
            GetSpellName(spell_id),
            target_name
        ).c_str()
    );

    CastingSlot target_slot = CastingSlot::Gem1;
    //Checking to see if they actually had it memmed and using that gem if so
    for(uint32 slot = uint32(CastingSlot::Gem1); slot < uint32(CastingSlot::MaxGems) && slot < EQ::spells::SPELL_GEM_COUNT; slot++) {
	    int memmed_spell = c->GetPP().mem_spells[slot];
	    if (IsValidSpell(memmed_spell) && memmed_spell == spell_id) {
		    target_slot = CastingSlot(slot);
		    break;
	    }
    }

    c->CastSpell(spell_id, target_id, target_slot);
}
