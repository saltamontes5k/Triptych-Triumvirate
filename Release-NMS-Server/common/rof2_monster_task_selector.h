#pragma once

#include "rof2_monster_task_wire.h"

#include <algorithm>

// Only a RoF2 client on Fall of Illsalin can reach this adapter. The Zone
// provider reads the committed membership and must revalidate it before an
// atomic role selection. This header does not register any live opcode.
namespace Rof2MonsterTaskSelector {

inline constexpr uint32_t FallOfIllsalin = 920243;

template <typename Provider, typename Send>
bool SendCatalogue(Provider& provider, Send send)
{
    const auto view = provider.CurrentEligibleView();
    if (!view || view->task_id != FallOfIllsalin || !view->occurrence || !view->character_id) {
        return false;
    }
    const auto body = Rof2MonsterTaskWire::EncodeCatalogue(
        {view->task_id, view->catalogue_opaque_fields, view->selection_locked}, view->roles);
    if (!body) {
        return false;
    }
    send(Rof2MonsterTaskWire::CatalogueOpcode, *body);
    return true;
}

template <typename Provider, typename Send>
bool Dispatch(uint16_t opcode, const uint8_t* data, std::size_t size, Provider& provider, Send send)
{
    using namespace Rof2MonsterTaskWire;

    if (opcode == CatalogueOpcode) {
        return IsCatalogueRequest(data, size) && SendCatalogue(provider, send);
    }
    if (opcode != TemplateDetailsOpcode && opcode != SelectRoleOpcode) {
        return false;
    }
    const auto template_id = opcode == TemplateDetailsOpcode
        ? DecodeDetailsRequest(data, size) : DecodeSelection(data, size);
    if (!template_id) {
        return false;
    }
    const auto view = provider.CurrentEligibleView();
    if (!view || view->task_id != FallOfIllsalin || !view->occurrence || !view->character_id) {
        return false;
    }

    const auto role = std::find_if(view->roles.begin(), view->roles.end(),
        [&](const Role& row) { return row.template_id == *template_id; });
    if (role == view->roles.end()) {
        return false;
    }
    if (opcode == TemplateDetailsOpcode) {
        const auto details = provider.GetTemplateDetails(*view, role->template_id);
        if (!details || details->prefix[2] != role->template_id) {
            return false;
        }
        const auto result = EncodeTemplateDetails(details->prefix, details->text);
        if (!result) {
            return false;
        }
        send(TemplateDetailsOpcode, *result);
        return true;
    }

    // The provider checks class eligibility, quotas, lock, and idempotency
    // under the native occurrence and member locks, then returns the status.
    const auto result = provider.SelectRole(*view, role->template_id);
    send(SelectionResultOpcode, EncodeSelectionResult(role->template_id, result, view->result_opaque_fields));
    return true;
}

} // namespace Rof2MonsterTaskSelector
