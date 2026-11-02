#ifndef EQEMU_FELLOWSHIP_CAMPSITE_MATERIALS_H
#define EQEMU_FELLOWSHIP_CAMPSITE_MATERIALS_H

#include "campsite_catalogue.h"

#include <array>
#include <cstdint>

class Database;

namespace Fellowship {
namespace Campsites {

// Exact-row material debit for paid campsites.
//
// This must execute inside the caller's already-open transaction, on the same
// connection as the campfire write, so that the kit/lumber debit and the camp
// commit or roll back together. The zone selects the two personal inventory
// slots; this layer re-verifies their durable identity (item, charges,
// augments, evolving payload) under FOR UPDATE before changing either row.
//
// Any failure returns false and must abort the camp transaction. It never
// touches runtime inventory: the zone applies the already-durable decrement to
// the client's in-memory inventory after COMMIT.
bool ConsumeMaterialsUnderTransaction(Database& database, uint32_t character_id,
                                      uint32_t campsite_id,
                                      const std::array<int16_t, 2>& slots);

}
}

#endif
