#ifndef EQEMU_FELLOWSHIP_SERVICE_H
#define EQEMU_FELLOWSHIP_SERVICE_H
#include <cstdint>
#include <functional>
#include <optional>
#include <string>
#include <vector>
class Database;
namespace Fellowship {
constexpr uint32_t MaximumMembers = 12;
constexpr uint64_t InvitationLifetime = 300;
constexpr uint64_t MaximumCampfireLifetime = 14400;
enum class Error { None, InvalidArgument, DatabaseFailure, NotFound, AlreadyMember, NotMember, NotLeader, Full, InvitationMissing, InvitationPending, LeaderMustTransfer, VitalityCapped, CommitUncertain };
template<class T> struct Result { T value{}; Error error = Error::None; explicit operator bool() const { return error == Error::None; } };
struct Member { uint32_t character_id{}, level{}, class_id{}, zone_id{}; std::string name; bool share_experience{}, shared_exp_capped{}; uint64_t joined_at{}, last_on{}; };
struct Campfire { uint32_t zone_id{}, instance_id{}, type{}; float x{}, y{}, z{}, heading{}; uint64_t expires_at{}; };
struct Invitation { uint32_t inviter_id{}, fellowship_id{}; std::string inviter_name; uint64_t expires_at{}; };
struct Snapshot { uint32_t id{}, leader_id{}; std::string motd; std::vector<Member> members; std::optional<Campfire> campfire; uint64_t revision{}; };
// Actor IDs must come from the authenticated zone Client, never the packet body.
// Calls require a dedicated connection with no enclosing transaction. All domain
// operations lock one database guard row, serializing membership/capacity changes.
class Service {
public:
 explicit Service(Database& database) : database_(database) {}
 Result<Snapshot> GetByCharacter(uint32_t character_id, uint64_t now);
 Result<Snapshot> Get(uint32_t fellowship_id, uint64_t now);
 Result<std::optional<Invitation>> GetInvitation(uint32_t target, uint64_t now);
 Result<Snapshot> Create(uint32_t actor, uint64_t now);
 Result<Snapshot> Invite(uint32_t actor, uint32_t target, uint64_t now);
 Result<Snapshot> Accept(uint32_t target, uint32_t inviter, uint64_t now, uint64_t expected_expiry = 0);
 Result<bool> Decline(uint32_t target, uint32_t inviter, uint64_t expected_expiry = 0);
 Result<Snapshot> Remove(uint32_t actor, uint32_t target, uint64_t now);
 Result<Snapshot> Leave(uint32_t actor, uint64_t now);
 Result<Snapshot> Disband(uint32_t actor);
 // Server maintenance hook, never callable using client-supplied actor IDs.
 // Removes membership/invitations and promotes the earliest surviving member.
 Result<Snapshot> CharacterDeleted(uint32_t character_id, uint64_t now);
 Result<Snapshot> TransferLeader(uint32_t actor, uint32_t target, uint64_t now);
 Result<Snapshot> SetMotd(uint32_t actor, const std::string& motd, uint64_t now);
 Result<Snapshot> SetSharing(uint32_t actor, bool enabled, uint64_t now);
 Result<Snapshot> SetSharing(uint32_t actor, uint32_t target, bool enabled, uint64_t now);
 // Zone integration must validate native kit/nearby member requirements before
 // setting a campfire. Persistence enforces finite coordinates, lifetime and
 // current membership; movement/access restrictions belong to the zone layer.
 using CampfireDebit = std::function<bool(Database&)>;
 Result<Snapshot> SetCampfire(uint32_t actor, const Campfire& campfire, uint64_t now, CampfireDebit debit = {}, uint64_t expected_revision = 0, uint32_t expected_fellowship_id = 0);
 Result<Snapshot> ClearCampfire(uint32_t actor, uint64_t now);
private:
 Database& database_;
};
}
#endif
