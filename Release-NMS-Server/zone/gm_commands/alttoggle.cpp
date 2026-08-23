#include "../client.h"
#include "../../common/repositories/aa_ability_repository.h"

void command_alt_toggle(Client *c, const Seperator *sep) {
    if (!c) {
        return;
    }

    if (sep->argnum < 1 || !sep->arg[1] || !sep->IsNumber(1)) {
        c->Message(Chat::White, "Usage: #alttoggle <ability_id>");
        return;
    }

    int ability_id = Strings::ToInt(sep->arg[1]);

    auto aa_ability = AaAbilityRepository::FindOne(content_db, ability_id);
    if (aa_ability.id == 0) {
        c->Message(Chat::White, fmt::format("AA ability with ID {} not found.", ability_id).c_str());
        return;
    }

    bool new_status = !c->GetToggleAAStatus(ability_id);
    c->SetToggleAAStatus(ability_id, new_status);

    c->Message(Chat::White, fmt::format("Toggled AA '{}' ({}) to: {}",
        aa_ability.name, ability_id, new_status ? "enabled" : "disabled").c_str());
}