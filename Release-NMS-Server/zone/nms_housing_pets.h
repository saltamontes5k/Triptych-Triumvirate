// nms_housing_pets.h -- RoF2 housing pets (interior-only v1).
//
// A placed interior furniture row whose nms_housing_placeable profile carries a pet_race
// spawns a transient noncombat NPC bound to that row -- no npc_types record, no spell.
// The actor is published with the 0x21ea spawn-to-item binding (the row-id GUID the
// furniture actors use), and the native item menu offers the five RoF2 pet commands
// (action9 / 0x51e3, params = dbstr category-28 label ids 16175-16179):
// Stay, Walk Around, Run Around, Follow Me, Play Dead.
//
// Port of nightstalker6669/EQEmu develop (housing_pets.cpp) onto the nms_housing
// substrate, with the adaptations the v466 review settled:
//   * containment is the interior zone bound itself -- the zone IS the property, so the
//     per-plot region volumes upstream checks do not exist here (Walk/Run ground + LoS
//     checks still reject unreachable targets);
//   * authority is owner presence: the entry revalidates every 5s that a connected
//     client with the plot owner's character id is in the zone, and drops otherwise;
//   * the pet GUID is the 16-hex nms_house_item row id (NmsHousingActors::GuidForRow).
// Behavior numbers are upstream's: 20-unit command range, 5s authority revalidation,
// 250ms movement tick, golden-angle spiral (radius 4..12) around the placed pose,
// 0.5/1.5 walk/run step, appearance-only Play Dead, Follow reverts to Stay when the
// follower leaves the zone.
//
// Gate: RuleB(Custom, HousingPets) -- fail-closed; 0x51e3 stays log-only when off.

#ifndef EQS_NMS_HOUSING_PETS_H
#define EQS_NMS_HOUSING_PETS_H

#include <cstdint>

class Client;

namespace NmsHousingPets {

// True when the running zone is a housing interior (phinterior* / plhogrinteriors*).
bool IsInteriorZone();

// Per-client tick (rides HousingClientProcess in nms_housing.cpp): after a short settle
// it reconciles the zone's placed pet rows into actors and publishes the bindings, and
// it drives the shared 250ms movement/authority tick. Cheap when the zone has no pets.
void ClientProcess(Client *c);

// 0x51e3 body handler: estate id + estate-item id (= nms_house_item row id) + menu
// parameter (16175..16179). Gate chain: rule, interior, known pet, owner, range <= 20.
bool Command(Client *c, uint32_t estate_id, uint32_t row_id, uint32_t parameter);

// The row left placement (pickup, Store All): despawn the actor immediately.
void OnRowRemoved(uint32_t estate_id, uint32_t row_id);

} // namespace NmsHousingPets

#endif // EQS_NMS_HOUSING_PETS_H
