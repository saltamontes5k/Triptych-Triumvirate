#ifndef EQEMU_FELLOWSHIP_ROF2_WIRE_H
#define EQEMU_FELLOWSHIP_ROF2_WIRE_H
#include "service.h"
#include <algorithm>
#include <cstring>
#include <limits>
namespace Fellowship { namespace RoF2 {
using Bytes = std::vector<uint8_t>;
constexpr size_t SnapshotSize = 0xa04;
constexpr size_t ActionSize = 0x434;
constexpr uint16_t UpdateOpcode = 0x6e4d, InviteOpcode = 0x62ab;
constexpr uint16_t ActionOpcode = 0x7121, KitRequestOpcode = 0x0c12, KitListOpcode = 0x074d;
struct Action { uint32_t action{}, target_id{}, fellowship_hint{}, kit{}; std::string motd; };
struct Kit { uint32_t id{}, description_id{}; std::string name; bool usable{}; };
// Native campfire presence requires a nonzero timestamp. Its clock origin and
// the second timestamp are not recovered; callers must supply proven native
// values rather than converting persisted epoch expiry by assumption.
struct NativeCampfireMetadata { uint32_t timestamp{}, second_timestamp{}; };
inline void Put32(Bytes& b, size_t offset, uint32_t value) {
 for (unsigned i = 0; i < 4; ++i) b[offset + i] = static_cast<uint8_t>(value >> (i * 8));
}
inline uint32_t Get32(const uint8_t* p) {
 return uint32_t(p[0]) | uint32_t(p[1]) << 8 | uint32_t(p[2]) << 16 | uint32_t(p[3]) << 24;
}
inline void PutFloat(Bytes& b, size_t offset, float value) {
 static_assert(sizeof(float) == sizeof(uint32_t), "native float width");
 uint32_t bits; std::memcpy(&bits, &value, sizeof(bits)); Put32(b, offset, bits);
}
inline void PutText(Bytes& b, size_t offset, size_t capacity, const std::string& text) {
 const size_t length = std::min(text.find('\0'), std::min(text.size(), capacity - 1));
 std::copy_n(text.begin(), length, b.begin() + offset);
}
inline std::optional<Action> DecodeAction(const void* data, size_t size) {
 if (!data || size != ActionSize) return std::nullopt;
 const auto* p = static_cast<const uint8_t*>(data);
 Action a; a.action = Get32(p);
 if (a.action < 1 || a.action > 12) return std::nullopt;
 a.target_id = Get32(p + 4); a.fellowship_hint = Get32(p + 0x10); a.kit = Get32(p + 0x428);
 if (a.action == 2) {
  // Exact outgoing stack accounting establishes +0x14, not +0x1c.
  const auto* text = p + 0x14;
  const auto* end = static_cast<const uint8_t*>(std::memchr(text, 0, 1024));
  if (!end) return std::nullopt;
  a.motd.assign(reinterpret_cast<const char*>(text), end - text);
 }
 return a;
}
inline Bytes Encode(const Snapshot& snapshot, uint32_t previous_fellowship_id = 0,
 uint64_t now = 0, NativeCampfireMetadata native_campfire = {}) {
 Bytes b(SnapshotSize, 0); Put32(b, 0, 5);
 Put32(b, 4, snapshot.id ? snapshot.id : previous_fellowship_id);
 PutText(b, 0x48, 1024, snapshot.motd);
 std::vector<const Member*> members;
 for (const auto& m : snapshot.members) if (m.character_id == snapshot.leader_id) { members.push_back(&m); break; }
 for (const auto& m : snapshot.members) if (m.character_id != snapshot.leader_id && members.size() < MaximumMembers) members.push_back(&m);
 Put32(b, 0x448, static_cast<uint32_t>(members.size()));
 for (size_t i = 0; i < members.size(); ++i) {
  const auto& m = *members[i]; const size_t o = 0x44c + i * 0x54;
  Put32(b, o, m.character_id); PutText(b, o + 4, 64, m.name);
  Put32(b, o + 0x44, m.zone_id); Put32(b, o + 0x48, m.level); Put32(b, o + 0x4c, m.class_id);
  Put32(b, o + 0x50, static_cast<uint32_t>(std::min<uint64_t>(m.last_on, UINT32_MAX)));
  b[0x9c0 + i] = m.share_experience ? 1 : 0;
  b[0x9cc + i] = m.shared_exp_capped ? 1 : 0;
 }
 // Constructor default is1. Revision is server metadata, not a proven wire Sync.
 Put32(b, 0x83c, 1);
 // Names/handles and offline flags are not fabricated. Capped XP bytes above
 // reflect authoritative admission caps and preserved bank balances.
 if (snapshot.campfire && snapshot.campfire->expires_at > now) {
  const auto& c = *snapshot.campfire;
  PutFloat(b, 0x9e4, c.y); PutFloat(b, 0x9e8, c.x); PutFloat(b, 0x9ec, c.z);
  Put32(b, 0x9f0, c.zone_id); Put32(b, 0x9f4, native_campfire.timestamp);
  Put32(b, 0x9f8, native_campfire.second_timestamp);
  // Source correspondence labels campfire+0x18 as CampType and +0x1c as bool.
  Put32(b, 0x9fc, c.type); b[0xa00] = 1;
 }
 return b;
}
inline Bytes EncodeInvite(uint32_t inviter_spawn_id) {
 Bytes b(ActionSize, 0); Put32(b, 0xc, inviter_spawn_id); return b;
}
inline Bytes EncodeKitList(const std::vector<Kit>& kits) {
 Bytes b(4, 0); Put32(b, 0, static_cast<uint32_t>(kits.size()));
 for (const auto& k : kits) {
  const size_t start = b.size(), length = std::min(k.name.size(), k.name.find('\0'));
  b.resize(start + 10 + length, 0); b[start] = k.usable ? 1 : 0;
  Put32(b, start + 1, k.id); Put32(b, start + 5, k.description_id);
  std::copy_n(k.name.begin(), length, b.begin() + start + 9);
 }
 return b;
}
} }
#endif
