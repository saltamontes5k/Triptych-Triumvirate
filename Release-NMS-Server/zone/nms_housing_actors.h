// nms_housing_actors.h -- housing world actors: the spawn half of the real-estate host.
//
// One NPC per placed estate row, bound to that row and published to the client with the
// spawn-to-item binding. This is the substrate the house guest NPCs will sit on (the pet/
// plushie actors and the bought service assistants). It decides nothing about *who* may
// have one -- eligibility stays with the caller, because that is where the estate, guild
// and item rules live.
//
// Wire (docs/rof2-opcode-harvest.md, 0x21ea OP_RealEstateBindSpawn, "canonical 32
// consumed-byte profile"):
//   32 bytes, little-endian: { u32 spawn_id, 16 x hex guid, u32 estate_id, u32 item_key }
//
// The guid is the client's per-item identity inside the estate. We derive it from the
// estate row id (nms_house_item.id) in 16 lowercase hex digits, which is the same shape
// the fork builds from its custody id, so the binding is stable across relogs and
// re-placements of the same row.
#pragma once

#include <cstddef>
#include <cstdint>
#include <string>

class Client;
class Seperator;

namespace NmsHousingActors {

// One published binding. row_id is the estate row the actor stands for; 0 means a test
// actor, spawned and bound but not owned by a row.
struct Published {
	uint32_t    estate_id   = 0; // lot door id the row lives on
	uint32_t    row_id      = 0; // nms_house_item.id (0 = unowned test actor)
	uint32_t    item_id     = 0; // item the actor renders (0 = the NPC type's own model)
	uint32_t    npc_type_id = 0;
	uint16_t    spawn_id    = 0;
	std::string guid;            // 16 lowercase hex, derived from row_id
};

// Spawn (or re-bind) one actor and send its binding to the requesting client.
bool Spawn(Client *c, uint32_t estate_id, uint32_t row_id, uint32_t npc_type_id, uint32_t item_id,
           float x, float y, float z, float heading);

// Despawn one actor. False when nothing was bound to that estate row.
bool Remove(uint32_t estate_id, uint32_t row_id);

// Re-send an existing binding (zone-in, window reopen, relog).
bool Republish(Client *c, uint32_t estate_id, uint32_t row_id);

// Send every binding this process holds for one estate to that client.
void PublishEstate(Client *c, uint32_t estate_id);

// Drop bindings whose NPC is gone. Cheap; safe to call every tick.
void Process();

// Zone shutdown / reload: depop everything we own.
void Clear();

std::size_t      Count();
const Published *Find(uint32_t estate_id, uint32_t row_id);

// "#housing actor ..." -- the GM surface for testing the substrate before any guest NPC
// has a reason to exist.
bool HandleCommand(Client *c, const Seperator *sep);

} // namespace NmsHousingActors
