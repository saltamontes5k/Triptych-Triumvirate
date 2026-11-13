#pragma once
#include "aa_preview.h"
#include <optional>
namespace SpiritShroud {
// Preserve ordinary/shared spell minima. Only the unlearnable placeholder 255
// may be replaced by a validated Monster AA minimum.
inline uint32_t BuffMinimumLevel(uint32_t ordinary, std::optional<uint32_t> ability)
{
 return ordinary == 255 && ability ? *ability : ordinary;
}
// Monster spells commonly have class levels 255. Only an authenticated cast of
// an owned rank from the active form may use its AA level as the buff minimum.
// Failure leaves ordinary spell restrictions in force, including for item casts.
template<class Rank>
std::optional<uint32_t> AbilityMinimumLevel(const Template* form, const Rank* rank,
 uint32_t spell_id, uint32_t owned_rank, uint32_t caster_class, uint32_t caster_level,
 bool transition)
{
 if(!form || transition || !rank || !rank->base_ability ||
    rank->base_ability->category!=4 || rank->spell!=int(spell_id) ||
    form->class_id!=caster_class || form->level!=caster_level ||
    rank->level_req<0 || uint32_t(rank->level_req)>caster_level ||
    owned_rank<uint32_t(rank->current_value) || !PreviewRange(*form,rank).valid)
  return std::nullopt;
 return uint32_t(rank->level_req);
}
}
