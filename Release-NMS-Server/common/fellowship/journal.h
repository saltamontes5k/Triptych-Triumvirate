#ifndef EQEMU_FELLOWSHIP_XP_JOURNAL_H
#define EQEMU_FELLOWSHIP_XP_JOURNAL_H
#include <cstdint>
class Database;
namespace Fellowship {
struct ExperienceState {
 uint64_t normal{}; uint32_t aa{},aa_points{},aa_spent{},level{},level2{},points{},percent_to_aa{};
};
constexpr uint32_t ExperienceReceiptRetention = 256;
// Must execute within the SAME transaction/connection as bank mutation. A false
// result requires rollback; never retry it independently. Receipts are audit-only
// and are bounded to the latest256 percharacter, not a pending replay queue.
bool PersistCombatExperience(Database& db,uint32_t character,uint64_t connection,
 const ExperienceState& before,const ExperienceState& after);
}
#endif
