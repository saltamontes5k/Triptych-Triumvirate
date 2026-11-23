// nms_housing_portal.h -- the guild-hall teleport pad: alignment from a handed-in stone.
//
// The loop this implements, in the order the original client's guild hall ran it:
//   1. buy a destination stone from the Guild Teleportation Assistant (item 66640 -> npc 345004,
//      merchant 345004 sells the 21 stones listed below);
//   2. hand one stone to that assistant -- it becomes the estate's alignment for 24 hours;
//   3. stand on the placed Guild Teleportation Device (item 66646) and confirm the destination.
//
// Step 2 lands here. Step 3 (pad proximity -> popup -> MovePC) is the next slice; the alignment
// row this writes is exactly what it will read.
//
// The destination table is the fork's own guild-portal service contract ("Destination names and
// coordinates match the deployed basic guildhall quests"), not a recovered wire opcode: this is a
// server-side service, so nothing here touches the opcode map.
#pragma once

#include <cstdint>

class Client;
class NPC;
class Seperator;

namespace NmsHousingPortal {

struct Destination {
	uint32_t    stone;
	const char *name;
	uint32_t    zone;
	float       x;
	float       y;
	float       z;
};

const Destination *Lookup(uint32_t stone);
bool               Purchasable(uint32_t stone);
const char        *Name(uint32_t stone);

// 24 hours, matching the live service contract.
constexpr uint64_t kAlignmentSeconds = 86400;

// Hand-in: exactly one purchasable stone, no coins. Removes the stone and writes the estate's
// alignment. Returns true when the stone was consumed; false leaves the trade untouched so the
// ordinary NPC hand-in path returns everything.
bool TryStoneHandIn(Client *c, NPC *npc);

// Current alignment for an estate (0 = none). Out-params are optional.
bool AlignmentFor(uint32_t door_id, uint32_t &stone, uint64_t &expires_epoch);

// Per-client tick (called from the housing client process): offers the destination when the
// client stands on an aligned pad, and cancels the offer when they walk away.
void ClientProcess(Client *c);

// Answer to the offer popup. Returns true when the popup was ours and has been handled.
bool HandlePopup(Client *c, const void *popup_response);

// "#housing portal ..." -- status for one estate, and the destination list.
bool HandleCommand(Client *c, const Seperator *sep);

} // namespace NmsHousingPortal
