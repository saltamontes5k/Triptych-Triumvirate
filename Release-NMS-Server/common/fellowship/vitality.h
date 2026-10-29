#ifndef EQEMU_FELLOWSHIP_VITALITY_H
#define EQEMU_FELLOWSHIP_VITALITY_H
#include "service.h"
#include <functional>
#include <limits>
namespace Fellowship {
// Caller capacities also limit bonus redemption after retained original XP.
// Zone limits capacities by remaining normal/unused-AA progression room.
struct VitalityCaps {
 uint64_t normal{}; uint32_t aa{};
 // Ephemeral total-award limits (server per-kill caps), never persisted as bank caps.
 uint64_t normal_award=std::numeric_limits<uint64_t>::max();
 uint64_t aa_award=std::numeric_limits<uint64_t>::max();
};
struct VitalityPools { uint64_t normal{}; uint32_t aa{}; VitalityCaps caps; };
struct VitalityAward { uint64_t normal{}; uint64_t aa{}; VitalityPools pools; std::vector<uint32_t> changed_characters; };
// Bounded server policy for offline members whose current capacities are unknown.
constexpr uint64_t UnknownNormalVitalityCap = 1000000000000ULL;
constexpr uint32_t UnknownAAVitalityCap = 2000000000U;
class VitalityService {
public:
 explicit VitalityService(Database& database) : database_(database) {}
 // Refresh cached capacities on login and level/progression changes. Banks remain
 // character-owned when leaving/disbanding a fellowship, including while offline.
 Result<VitalityPools> Get(uint32_t character, VitalityCaps caps);
 // Call once for original combat-earned XP, before adding existing XP balances.
 // Bonus multipliers are additional XP (4 means 5x total). Bonus is never shared.
 // Dedicated DB connection required, outside any existing transaction. Never retry
 // CommitUncertain: commit may already have succeeded. The optional finalizer
 // persists authoritative gameplay XP on this same connection/transaction; it
 // must not commit/reconnect or perform independent external durable effects.
 Result<VitalityAward> ApplyCombat(uint32_t character, uint64_t normal, uint64_t aa,
  VitalityCaps caps, uint32_t normal_bonus_multiplier = 4, uint32_t aa_bonus_multiplier = 2,
  const std::function<bool(const VitalityAward&)>& finalizer = {});
 Result<bool> Clear(uint32_t character);
private:
 Database& database_;
};
}
#endif
