#include "service.h"
#include "../database.h"
#include <cmath>
#include <limits>
#include <stdexcept>
#include <utility>
namespace Fellowship {
namespace {
struct Failure { Error error; };
MySQLRequestResult Query(Database& db, const std::string& sql) {
 if (db.GetStatus() != DBcore::Connected) throw Failure{Error::DatabaseFailure};
 auto result = db.QueryDatabase(sql, false);
 if (!result.Success()) throw Failure{Error::DatabaseFailure};
 return result;
}
uint64_t Number(const char* text) {
 if (!text) throw Failure{Error::DatabaseFailure};
 return std::stoull(text);
}
std::string Quote(Database& db, const std::string& value) {
 std::string out(value.size() * 2 + 1, '\0');
 out.resize(db.DoEscapeString(out.data(), value.data(), value.size()));
 return "'" + out + "'";
}
struct Transaction {
 Database& db; bool active = false; uint64_t connection = 0;
 explicit Transaction(Database& database) : db(database) {
  auto nested = Query(db, "SELECT @@in_transaction");
  if (nested.RowCount() != 1 || Number(nested.begin()[0])) throw Failure{Error::InvalidArgument};
  Query(db, "START TRANSACTION"); active = true;
  try {
   auto identity = Query(db, "SELECT CONNECTION_ID(),@@in_transaction");
   if (identity.RowCount()!=1 || !Number(identity.begin()[1])) throw Failure{Error::DatabaseFailure};
   connection=Number(identity.begin()[0]);
   auto guard = Query(db, "SELECT id FROM fellowship_guard WHERE id=1 FOR UPDATE");
   if (guard.RowCount() != 1) throw Failure{Error::DatabaseFailure};
  } catch (...) { Rollback(); throw; }
 }
 void Rollback() noexcept {
  if (!active) return;
  try {
   if (db.GetStatus()==DBcore::Connected) {
    auto identity=Query(db,"SELECT CONNECTION_ID(),@@in_transaction");
    if (identity.RowCount()==1 && (!connection || Number(identity.begin()[0])==connection) && Number(identity.begin()[1])) db.QueryDatabase(std::string("ROLLBACK"),false);
   }
  } catch (...) {}
  active=false;
 }
 ~Transaction() { Rollback(); }
 void Check() {
  auto identity=Query(db,"SELECT CONNECTION_ID(),@@in_transaction");
  if(identity.RowCount()!=1 || Number(identity.begin()[0])!=connection || !Number(identity.begin()[1]))throw Failure{Error::DatabaseFailure};
 }
 void Commit() {
  Check();
  if (!db.QueryDatabase(std::string("COMMIT"), false).Success()) throw Failure{Error::CommitUncertain};
  active = false;
 }
};
template<class T, class F> Result<T> Run(Database& db, F body) {
 try { Transaction transaction(db); auto value = body(); transaction.Commit(); return {std::move(value), Error::None}; }
 catch (const Failure& f) { return {{}, f.error}; }
 catch (...) { return {{}, Error::DatabaseFailure}; }
}
void ValidCharacter(Database& db, uint32_t id) {
 if (!id) throw Failure{Error::InvalidArgument};
 auto c = Query(db, "SELECT c.id FROM character_data c JOIN account a ON a.id=c.account_id WHERE c.id=" + std::to_string(id) + " AND c.deleted_at IS NULL");
 if (c.RowCount() != 1) throw Failure{Error::NotFound};
}
uint32_t Membership(Database& db, uint32_t id) {
 auto m = Query(db, "SELECT fellowship_id FROM fellowship_members WHERE character_id=" + std::to_string(id));
 if (m.RowCount() > 1) throw Failure{Error::DatabaseFailure};
 return m.RowCount() ? Number(m.begin()[0]) : 0;
}
Snapshot Load(Database& db, uint32_t id, uint64_t now) {
 if (!id) return {};
 auto f = Query(db, "SELECT id,leader_id,motd,revision,campfire_zone_id,campfire_instance_id,campfire_type,campfire_x,campfire_y,campfire_z,campfire_heading,campfire_expires_at FROM fellowships WHERE id=" + std::to_string(id));
 if (f.RowCount() != 1) throw Failure{Error::NotFound};
 auto row = f.begin(); Snapshot out;
 out.id = Number(row[0]); out.leader_id = Number(row[1]); out.motd = row[2] ? row[2] : ""; out.revision = Number(row[3]);
 if (Number(row[4]) && Number(row[11]) > now) {
  Campfire c; c.zone_id = Number(row[4]); c.instance_id = Number(row[5]); c.type = Number(row[6]);
  c.x = std::stof(row[7]); c.y = std::stof(row[8]); c.z = std::stof(row[9]); c.heading = std::stof(row[10]); c.expires_at = Number(row[11]); out.campfire = c;
 }
 auto m = Query(db, "SELECT m.character_id,c.name,c.level,c.class,c.zone_id,m.share_experience,m.joined_at,c.last_login,COALESCE((v.normal_cap=0 OR v.normal_pool>=v.normal_cap OR (v.aa_cap>0 AND v.aa_pool>=v.aa_cap)),0) FROM fellowship_members m JOIN character_data c ON c.id=m.character_id AND c.deleted_at IS NULL LEFT JOIN fellowship_vitality v ON v.character_id=m.character_id WHERE m.fellowship_id=" + std::to_string(id) + " ORDER BY m.joined_at,m.character_id");
 if (m.RowCount() > MaximumMembers) throw Failure{Error::DatabaseFailure};
 for (auto r = m.begin(); r.operator!=(m.end()); ++r) {
  Member member; member.character_id = Number(r[0]); member.name = r[1] ? r[1] : ""; member.level = Number(r[2]); member.class_id = Number(r[3]); member.zone_id = Number(r[4]); member.share_experience = Number(r[5]) != 0; member.joined_at = Number(r[6]); member.last_on = Number(r[7]); member.shared_exp_capped = Number(r[8]) != 0; out.members.push_back(std::move(member));
 }
 return out;
}
Snapshot Actor(Database& db, uint32_t actor, uint64_t now, bool leader = false) {
 ValidCharacter(db, actor); auto id = Membership(db, actor);
 if (!id) throw Failure{Error::NotMember};
 auto group = Load(db, id, now);
 if (leader && group.leader_id != actor) throw Failure{Error::NotLeader};
 return group;
}
void Bump(Database& db, uint32_t id) { Query(db, "UPDATE fellowships SET revision=revision+1 WHERE id=" + std::to_string(id)); }
void DropInvitations(Database& db, uint32_t character) { Query(db, "DELETE FROM fellowship_invitations WHERE target_id=" + std::to_string(character) + " OR inviter_id=" + std::to_string(character)); }
Snapshot RemoveMember(Database& db, const Snapshot& group, uint32_t target, uint64_t now) {
 if (Membership(db, target) != group.id) throw Failure{Error::NotMember};
 if (target == group.leader_id && group.members.size() > 1) throw Failure{Error::LeaderMustTransfer};
 if (group.members.size() == 1) { Query(db, "DELETE FROM fellowships WHERE id=" + std::to_string(group.id)); return {}; }
 Query(db, "DELETE FROM fellowship_members WHERE character_id=" + std::to_string(target)); DropInvitations(db, target); Bump(db, group.id); return Load(db, group.id, now);
}
}
Result<Snapshot> Service::GetByCharacter(uint32_t character, uint64_t now) {
 return Run<Snapshot>(database_, [&] { ValidCharacter(database_, character); return Load(database_, Membership(database_, character), now); });
}
Result<Snapshot> Service::Get(uint32_t id, uint64_t now) {
 return Run<Snapshot>(database_, [&] { if (!id) throw Failure{Error::InvalidArgument}; return Load(database_, id, now); });
}
Result<std::optional<Invitation>> Service::GetInvitation(uint32_t target, uint64_t now) {
 return Run<std::optional<Invitation>>(database_, [&]() -> std::optional<Invitation> {
  ValidCharacter(database_, target); if (Membership(database_, target)) return {};
  auto pending = Query(database_, "SELECT i.inviter_id,i.fellowship_id,c.name,i.expires_at FROM fellowship_invitations i JOIN fellowships f ON f.id=i.fellowship_id AND f.leader_id=i.inviter_id JOIN fellowship_members m ON m.character_id=i.inviter_id AND m.fellowship_id=i.fellowship_id JOIN character_data c ON c.id=i.inviter_id AND c.deleted_at IS NULL WHERE i.target_id=" + std::to_string(target) + " AND i.expires_at>" + std::to_string(now) + " ORDER BY i.expires_at DESC,i.inviter_id LIMIT 1");
  if (!pending.RowCount()) return {};
  auto r=pending.begin(); Invitation out; out.inviter_id=Number(r[0]);out.fellowship_id=Number(r[1]);out.inviter_name=r[2]?r[2]:"";out.expires_at=Number(r[3]);return out;
 });
}
Result<Snapshot> Service::Create(uint32_t actor, uint64_t now) {
 return Run<Snapshot>(database_, [&] {
  ValidCharacter(database_, actor); if (Membership(database_, actor)) throw Failure{Error::AlreadyMember};
  auto created = Query(database_, "INSERT INTO fellowships (leader_id,created_at) VALUES (" + std::to_string(actor) + "," + std::to_string(now) + ")"); auto id = created.LastInsertedID();
  Query(database_, "INSERT INTO fellowship_members (character_id,fellowship_id,joined_at) VALUES (" + std::to_string(actor) + "," + std::to_string(id) + "," + std::to_string(now) + ")"); DropInvitations(database_, actor); return Load(database_, id, now);
 });
}
Result<Snapshot> Service::Invite(uint32_t actor, uint32_t target, uint64_t now) {
 return Run<Snapshot>(database_, [&] {
  auto group = Actor(database_, actor, now, true); ValidCharacter(database_, target);
  if (actor == target) throw Failure{Error::InvalidArgument};
  if (Membership(database_, target)) throw Failure{Error::AlreadyMember};
  if (group.members.size() >= MaximumMembers) throw Failure{Error::Full};
  if (now > std::numeric_limits<uint64_t>::max() - InvitationLifetime) throw Failure{Error::InvalidArgument};
  // Native accept/decline packets carry no inviter or nonce. Never replace a
  // live invitation behind an already displayed confirmation dialog. Repeated
  // invitations from the same leader preserve the original expiry/token.
  auto existing = Query(database_, "SELECT inviter_id,fellowship_id,expires_at FROM fellowship_invitations WHERE target_id=" + std::to_string(target) + " AND expires_at>" + std::to_string(now));
  if (existing.RowCount()) {
   if (existing.RowCount() != 1) throw Failure{Error::DatabaseFailure};
   if (Number(existing.begin()[0]) == actor && Number(existing.begin()[1]) == group.id) return group;
   throw Failure{Error::InvitationPending};
  }
  Query(database_, "DELETE FROM fellowship_invitations WHERE target_id=" + std::to_string(target));
  Query(database_, "REPLACE INTO fellowship_invitations (target_id,fellowship_id,inviter_id,expires_at) VALUES (" + std::to_string(target) + "," + std::to_string(group.id) + "," + std::to_string(actor) + "," + std::to_string(now + InvitationLifetime) + ")"); return group;
 });
}
Result<Snapshot> Service::Accept(uint32_t target, uint32_t inviter, uint64_t now, uint64_t expected_expiry) {
 return Run<Snapshot>(database_, [&] {
  ValidCharacter(database_, target); ValidCharacter(database_, inviter);
  if (Membership(database_, target)) throw Failure{Error::AlreadyMember};
  auto pending = Query(database_, "SELECT fellowship_id,expires_at FROM fellowship_invitations WHERE target_id=" + std::to_string(target) + " AND inviter_id=" + std::to_string(inviter));
  if (pending.RowCount() != 1 || Number(pending.begin()[1]) <= now ||
      (expected_expiry && Number(pending.begin()[1]) != expected_expiry)) throw Failure{Error::InvitationMissing};
  auto group = Actor(database_, inviter, now, true);
  if (group.id != Number(pending.begin()[0])) throw Failure{Error::InvitationMissing};
  if (group.members.size() >= MaximumMembers) throw Failure{Error::Full};
  Query(database_, "INSERT INTO fellowship_members (character_id,fellowship_id,joined_at) VALUES (" + std::to_string(target) + "," + std::to_string(group.id) + "," + std::to_string(now) + ")"); DropInvitations(database_, target); Bump(database_, group.id); return Load(database_, group.id, now);
 });
}
Result<bool> Service::Decline(uint32_t target, uint32_t inviter, uint64_t expected_expiry) {
 return Run<bool>(database_, [&] {
  ValidCharacter(database_, target);
  const auto where = "target_id=" + std::to_string(target) + " AND inviter_id=" + std::to_string(inviter);
  if (expected_expiry) {
   auto pending = Query(database_, "SELECT expires_at FROM fellowship_invitations WHERE " + where);
   if (pending.RowCount() != 1 || Number(pending.begin()[0]) != expected_expiry) throw Failure{Error::InvitationMissing};
  }
  Query(database_, "DELETE FROM fellowship_invitations WHERE " + where);
  return true;
 });
}
Result<Snapshot> Service::Remove(uint32_t actor, uint32_t target, uint64_t now) {
 return Run<Snapshot>(database_, [&] { auto group = Actor(database_, actor, now, true); return RemoveMember(database_, group, target, now); });
}
Result<Snapshot> Service::Leave(uint32_t actor, uint64_t now) {
 return Run<Snapshot>(database_, [&] { auto group = Actor(database_, actor, now); return RemoveMember(database_, group, actor, now); });
}
Result<Snapshot> Service::Disband(uint32_t actor) {
 return Run<Snapshot>(database_, [&] { auto group = Actor(database_, actor, 0, true); Query(database_, "DELETE FROM fellowships WHERE id=" + std::to_string(group.id)); return Snapshot{}; });
}
Result<Snapshot> Service::CharacterDeleted(uint32_t character, uint64_t now) {
 return Run<Snapshot>(database_, [&] {
  if (!character) throw Failure{Error::InvalidArgument};
  auto group_id = Membership(database_, character);
  DropInvitations(database_, character);
  if (!group_id) return Snapshot{};
  auto group = Load(database_, group_id, now);
  Query(database_, "DELETE FROM fellowship_members WHERE character_id=" + std::to_string(character));
  uint32_t successor = 0;
  for (const auto& member : group.members) {
   if (member.character_id != character) { successor = member.character_id; break; }
  }
  if (!successor) {
   Query(database_, "DELETE FROM fellowships WHERE id=" + std::to_string(group_id));
   return Snapshot{};
  }
  if (group.leader_id == character) {
   Query(database_, "UPDATE fellowships SET leader_id=" + std::to_string(successor) + " WHERE id=" + std::to_string(group_id));
   Query(database_, "DELETE FROM fellowship_invitations WHERE fellowship_id=" + std::to_string(group_id));
  }
  Bump(database_, group_id);
  return Load(database_, group_id, now);
 });
}
Result<Snapshot> Service::TransferLeader(uint32_t actor, uint32_t target, uint64_t now) {
 return Run<Snapshot>(database_, [&] { auto group = Actor(database_, actor, now, true); ValidCharacter(database_, target); if (Membership(database_, target) != group.id) throw Failure{Error::NotMember}; Query(database_, "UPDATE fellowships SET leader_id=" + std::to_string(target) + ",revision=revision+1 WHERE id=" + std::to_string(group.id)); Query(database_, "DELETE FROM fellowship_invitations WHERE fellowship_id=" + std::to_string(group.id)); return Load(database_, group.id, now); });
}
Result<Snapshot> Service::SetMotd(uint32_t actor, const std::string& motd, uint64_t now) {
 return Run<Snapshot>(database_, [&] { auto group = Actor(database_, actor, now, true); if (motd.size() > 1023 || motd.find('\0') != std::string::npos) throw Failure{Error::InvalidArgument}; Query(database_, "UPDATE fellowships SET motd=" + Quote(database_, motd) + ",revision=revision+1 WHERE id=" + std::to_string(group.id)); return Load(database_, group.id, now); });
}
Result<Snapshot> Service::SetSharing(uint32_t actor, bool enabled, uint64_t now) { return SetSharing(actor,actor,enabled,now); }
Result<Snapshot> Service::SetSharing(uint32_t actor, uint32_t target, bool enabled, uint64_t now) {
 return Run<Snapshot>(database_, [&] {
  auto group = Actor(database_, actor, now); ValidCharacter(database_, target);
  if (actor != target && group.leader_id != actor) throw Failure{Error::NotLeader};
  if (Membership(database_, target) != group.id) throw Failure{Error::NotMember};
  if(enabled){
   auto full=Query(database_,"SELECT character_id FROM fellowship_vitality WHERE character_id="+std::to_string(target)+" AND (normal_cap=0 OR normal_pool>=normal_cap OR (aa_cap>0 AND aa_pool>=aa_cap))");
   if(full.RowCount())throw Failure{Error::VitalityCapped};
  }
  Query(database_, "UPDATE fellowship_members SET share_experience=" + std::to_string(enabled ? 1 : 0) + " WHERE character_id=" + std::to_string(target));
  Bump(database_, group.id); return Load(database_, group.id, now);
 });
}
Result<Snapshot> Service::SetCampfire(uint32_t actor, const Campfire& fire, uint64_t now, CampfireDebit debit, uint64_t expected_revision, uint32_t expected_fellowship_id) {
 return Run<Snapshot>(database_, [&] { auto group = Actor(database_, actor, now);
  // The zone performs proximity/item checks before entering the service, but
  // this locked check prevents two zones from replacing each other's new fire.
  if (group.campfire || (expected_revision && group.revision != expected_revision) || (expected_fellowship_id && group.id != expected_fellowship_id)) throw Failure{Error::InvalidArgument};
  if (!fire.zone_id || fire.instance_id > 65535 || !std::isfinite(fire.x) || !std::isfinite(fire.y) || !std::isfinite(fire.z) || !std::isfinite(fire.heading) || fire.expires_at <= now || fire.expires_at - now > MaximumCampfireLifetime) throw Failure{Error::InvalidArgument};
  auto identity=Query(database_,"SELECT CONNECTION_ID(),@@in_transaction");
  if(identity.RowCount()!=1 || !Number(identity.begin()[1]))throw Failure{Error::DatabaseFailure};
  const auto connection=Number(identity.begin()[0]);
  if (debit && !debit(database_)) throw Failure{Error::InvalidArgument};
  auto after=Query(database_,"SELECT CONNECTION_ID(),@@in_transaction");
  if(after.RowCount()!=1 || Number(after.begin()[0])!=connection || !Number(after.begin()[1]))throw Failure{Error::DatabaseFailure};
  Query(database_, "UPDATE fellowships SET campfire_zone_id=" + std::to_string(fire.zone_id) + ",campfire_instance_id=" + std::to_string(fire.instance_id) + ",campfire_type=" + std::to_string(fire.type) + ",campfire_x=" + std::to_string(fire.x) + ",campfire_y=" + std::to_string(fire.y) + ",campfire_z=" + std::to_string(fire.z) + ",campfire_heading=" + std::to_string(fire.heading) + ",campfire_expires_at=" + std::to_string(fire.expires_at) + ",revision=revision+1 WHERE id=" + std::to_string(group.id)); return Load(database_, group.id, now); });
}
Result<Snapshot> Service::ClearCampfire(uint32_t actor, uint64_t now) {
 return Run<Snapshot>(database_, [&] { auto group = Actor(database_, actor, now); Query(database_, "UPDATE fellowships SET campfire_zone_id=0,campfire_expires_at=0,revision=revision+1 WHERE id=" + std::to_string(group.id)); return Load(database_, group.id, now); });
}
}
