#include "client.h"
#include "entity.h"
#include "zone.h"
#include "worldserver.h"
#include "fellowship_campfire.h"
#include "fellowship_campsite_materials.h"
#include "fellowship_campsite_bonuses.h"
#include "../common/fellowship/campsite_catalogue.h"
#include "../common/fellowship/service.h"
#include "../common/fellowship/rof2_wire.h"
#include "../common/rulesys.h"
#include <algorithm>
#include <cmath>
#include <ctime>
#include <cstring>

extern Zone* zone;
extern WorldServer worldserver;
namespace {
namespace Wire = Fellowship::RoF2;
namespace Camps = Fellowship::Campsites;
uint64_t Now() { return static_cast<uint64_t>(std::time(nullptr)); }
bool Ready(const Client& client) {
 if (!RuleB(Custom, Fellowships)) return false;
 return zone && client.CharacterID() && client.Connected() && client.ClientDataLoaded() &&
  client.ClientVersion() == EQ::versions::ClientVersion::RoF2;
}
void Send(Client& client, EmuOpcode opcode, const Wire::Bytes& bytes) {
 EQApplicationPacket packet(opcode, bytes.size());
 std::memcpy(packet.pBuffer, bytes.data(), bytes.size());
 client.QueuePacket(&packet);
}
void Changed() {
 // Other zones reload authoritative state; no client-provided identity travels
 // in the invalidation message.
 InvalidateFellowshipCampsites();
 ProcessFellowshipCampfires();
 for (const auto& entry : entity_list.GetClientList()) {
  auto* client = entry.second;
  client->RefreshFellowship();
 }
 if (worldserver.Connected()) {
  ServerPacket packet(ServerOP_FellowshipRefresh, 0);
  worldserver.SendPacket(&packet);
 }
}
void Failure(Client& client, Fellowship::Error error) {
 const char* message = "The fellowship request could not be completed. Please try again.";
 switch (error) {
 case Fellowship::Error::AlreadyMember: message = "That character already belongs to a fellowship."; break;
 case Fellowship::Error::NotMember: message = "That character is not a member of your fellowship."; break;
 case Fellowship::Error::NotLeader: message = "Only the fellowship leader may do that."; break;
 case Fellowship::Error::Full: message = "Your fellowship is full."; break;
 case Fellowship::Error::VitalityCapped: message = "Your vitality is full or you cannot gain normal experience. Use stored vitality before enabling sharing."; break;
 case Fellowship::Error::InvitationPending: message = "That character already has a pending fellowship invitation."; break;
 case Fellowship::Error::InvitationMissing: message = "That fellowship invitation has expired or is no longer valid."; break;
 case Fellowship::Error::LeaderMustTransfer: message = "Promote another member before leaving, or disband the fellowship."; break;
 default: break;
 }
 client.Message(Chat::Red, "%s", message);
}
void GiveInsignia(Client& client) {
 constexpr uint32_t Insignia = 34023;
 if (client.GetInv().HasItem(Insignia, 1) == INVALID_INDEX) client.SummonItem(Insignia);
}
bool CanCamp(Client& actor, const Fellowship::Snapshot& fellowship) {
 if (actor.GetHP() <= 0 || actor.IsEngaged()) return false;
 unsigned nearby = 0;
 for (const auto& member : fellowship.members) {
  auto* other = entity_list.GetClientByCharID(member.character_id);
  if (!other || !other->Connected() || other->GetHP() <= 0 || other->IsEngaged()) continue;
  const auto dx = actor.GetX() - other->GetX(), dy = actor.GetY() - other->GetY(), dz = actor.GetZ() - other->GetZ();
  if (dx*dx + dy*dy + dz*dz <= 100.0f*100.0f) ++nearby;
 }
 const int required = std::clamp(RuleI(Custom, FellowshipCampMembers), 1, 12);
 return static_cast<int>(nearby) >= required;
}
}

void Client::RefreshFellowship() {
 if (!Ready(*this)) return;
 const auto now = Now();
 m_fellowship_refresh_at = now + 5;
 // Vitality survives leaving/disbanding and must continue refreshing even
 // when the character no longer has a fellowship roster.
 RefreshFellowshipVitality();
 Fellowship::Service service(database);
 auto result = service.GetByCharacter(CharacterID(), now);
 if (!result) return;
 auto snapshot = std::move(result.value);
 // Overlay connected local members; persisted rows remain authoritative for
 // membership, but saved zone/level fields may lag an active character.
 for (auto& member : snapshot.members) {
  auto* client = entity_list.GetClientByCharID(member.character_id);
  if (!client || !client->Connected()) continue;
  member.level = client->GetLevel(); member.class_id = client->GetClass();
  member.zone_id = zone->GetZoneID(); member.last_on = 0;
 }
 const uint32_t previous = m_fellowship_id;
 if (!snapshot.id && previous) {
  // The native removal branch clears only the fellowship ID. First clear the
  // campfire via a member-present update, then remove the receiving member.
  Fellowship::Snapshot clearing;
  clearing.id = previous; clearing.leader_id = CharacterID();
  Fellowship::Member self; self.character_id = CharacterID(); self.name = GetCleanName();
  clearing.members.push_back(std::move(self));
  Send(*this, OP_FellowshipUpdate, Wire::Encode(clearing, previous, now));
 }
 // The traced native consumer uses this value only as a nonzero presence
 // marker here. Server epoch expiry is intentional; its native clock origin
 // is not established and no native duration equivalence is claimed.
 const Wire::NativeCampfireMetadata fire_time{
  snapshot.campfire ? static_cast<uint32_t>(snapshot.campfire->expires_at) : 0, 0
 };
 auto bytes = Wire::Encode(snapshot, previous, now, fire_time);
 if ((snapshot.id || previous) && bytes != m_fellowship_snapshot) Send(*this, OP_FellowshipUpdate, bytes);
 m_fellowship_snapshot = std::move(bytes);
 m_fellowship_id = snapshot.id;
 if (snapshot.id) {
  m_fellowship_inviter = 0; m_fellowship_invite_expires = 0;
  return;
 }
 auto pending = service.GetInvitation(CharacterID(), now);
 if (!pending || !pending.value) { m_fellowship_inviter = 0; m_fellowship_invite_expires = 0; return; }
 const auto& invitation = *pending.value;
 if (m_fellowship_inviter == invitation.inviter_id && m_fellowship_invite_expires == invitation.expires_at) return;
 // Native invitation display resolves the inviter's spawn ID in this zone.
 // Invitations are issued only to a currently targeted, present character.
 auto* inviter = entity_list.GetClientByCharID(invitation.inviter_id);
 if (!inviter || !inviter->Connected()) return;
 Send(*this, OP_FellowshipInvite, Wire::EncodeInvite(inviter->GetID()));
 m_fellowship_inviter = invitation.inviter_id;
 m_fellowship_invite_expires = invitation.expires_at;
}

void Client::ProcessFellowship() {
 if (Ready(*this) && Now() >= m_fellowship_refresh_at) RefreshFellowship();
}

void Client::Handle_OP_FellowshipAction(const EQApplicationPacket* app) {
 if (!Ready(*this) || !app) return;
 auto action = Wire::DecodeAction(app->pBuffer, app->size);
 if (!action) return;
 // Limit packet floods without retaining any claimed actor/fellowship identity.
 const auto milliseconds = Timer::GetCurrentTime();
 if (m_fellowship_action_at && milliseconds - m_fellowship_action_at < 200) return;
 m_fellowship_action_at = milliseconds;
 const auto now = Now(); Fellowship::Service service(database);
 Fellowship::Result<Fellowship::Snapshot> result;
 switch (action->action) {
 case 1: result = service.Create(CharacterID(), now); break;
 case 2: result = service.SetMotd(CharacterID(), action->motd, now); break;
 case 3:
 case 4: {
  // The native response contains no inviter or nonce. Bind it to the exact
  // invitation previously displayed to this authenticated Client connection.
  auto pending = service.GetInvitation(CharacterID(), now);
  if (!m_fellowship_inviter || m_fellowship_invite_expires <= now ||
      !pending || !pending.value || pending.value->inviter_id != m_fellowship_inviter ||
      pending.value->expires_at != m_fellowship_invite_expires) {
   m_fellowship_inviter = 0; m_fellowship_invite_expires = 0;
   Failure(*this, Fellowship::Error::InvitationMissing);
   RefreshFellowship();
   return;
  }
  if (action->action == 4) {
   auto declined = service.Decline(CharacterID(), m_fellowship_inviter, m_fellowship_invite_expires);
   if (!declined) Failure(*this, declined.error);
   m_fellowship_inviter = 0; m_fellowship_invite_expires = 0;
   RefreshFellowship();
   return;
  }
  result = service.Accept(CharacterID(), m_fellowship_inviter, now, m_fellowship_invite_expires);
  break;
 }
 case 5: {
  if (!action->target_id || action->target_id > UINT16_MAX) return;
  auto* target = entity_list.GetMob(static_cast<uint16_t>(action->target_id));
  // Match the authenticated player's actual current target, not an arbitrary
  // character ID supplied in the packet or a recycled entity number.
  if (!target || target != GetTarget() || !target->IsClient() || !target->CastToClient()->Connected() || target == this) return;
  const auto dx = GetX()-target->GetX(), dy = GetY()-target->GetY(), dz = GetZ()-target->GetZ();
  const auto distance_squared = dx*dx + dy*dy + dz*dz;
  if (!std::isfinite(distance_squared) || distance_squared > 200.0f*200.0f) { Message(Chat::Red, "Move closer to that player before inviting them."); return; }
  result = service.Invite(CharacterID(), target->CastToClient()->CharacterID(), now); break;
 }
 case 6: result = service.Remove(CharacterID(), action->target_id, now); break;
 case 7: result = service.TransferLeader(CharacterID(), action->target_id, now); break;
 case 8: {
  if (!RuleB(Custom, FellowshipCamps)) { Message(Chat::Red, "Fellowship campsites are disabled on this server."); return; }
  const auto* definition=Camps::Lookup(action->kit);
  if(!definition || !definition->implemented || !FellowshipCampsiteNativeBuffSupported(*definition)) { Message(Chat::Red,"That campsite is not available.");return; }
  auto current=service.GetByCharacter(CharacterID(),now);
  if(!current || !current.value.id) { Failure(*this,Fellowship::Error::NotMember);return; }
  if(current.value.campfire) { Message(Chat::Red,"Destroy your existing campfire before creating another.");return; }
  if(!CanCamp(*this,current.value)) { Message(Chat::Red,"%d living fellowship members must be within 100 units and out of combat to create a campfire.", std::clamp(RuleI(Custom, FellowshipCampMembers),1,12));return; }
  if(!std::isfinite(GetX()) || !std::isfinite(GetY()) || !std::isfinite(GetZ()) || !std::isfinite(GetHeading()))return;
  Fellowship::Campfire fire;
  fire.zone_id=zone->GetZoneID();fire.instance_id=zone->GetInstanceID();fire.type=definition->id;
  fire.x=GetX();fire.y=GetY();fire.z=GetZ();fire.heading=GetHeading();fire.expires_at=now+Camps::LifetimeSeconds;
  if(definition->kit_item_id) {
   if(!HasFellowshipCampsiteMaterials(*this,*definition)) { Message(Chat::Red,"Carry the required fellowship kit and lumber bundle in your personal inventory.");return; }
   result=CreatePaidFellowshipCampsite(*this,*definition,fire,now,current.value.revision,current.value.id);
  } else result=service.SetCampfire(CharacterID(),fire,now,{},current.value.revision,current.value.id);
  if(!Connected())return;
  InvalidateFellowshipCampsites();
  break;
 }
 case 9: result = service.ClearCampfire(CharacterID(), now); break;
 case 10: result = service.Leave(CharacterID(), now); break;
 case 11: result = service.Disband(CharacterID()); break;
 case 12: {
  auto current = service.GetByCharacter(CharacterID(), now);
  if (!current) { Failure(*this, current.error); return; }
  auto member = std::find_if(current.value.members.begin(), current.value.members.end(), [&](const auto& m) { return m.character_id == action->target_id; });
  if (member == current.value.members.end()) { Failure(*this, Fellowship::Error::NotMember); return; }
  result = service.SetSharing(CharacterID(), member->character_id, !member->share_experience, now); break;
 }
 default: return;
 }
 if (!result) { Failure(*this, result.error); RefreshFellowship(); return; }
 if (action->action == 1 || action->action == 3) GiveInsignia(*this);
 Changed();
}

void Client::Handle_OP_FellowshipCampRequest(const EQApplicationPacket* app) {
 if (!Ready(*this) || !app || app->size != 8) return;
 const auto* p = app->pBuffer;
 const auto usable_only = Wire::Get32(p), category = Wire::Get32(p+4);
 if (usable_only > 1) return;
 Fellowship::Service service(database); const auto current = service.GetByCharacter(CharacterID(), Now());
 std::vector<Wire::Kit> kits;
 if(current && current.value.id) {
  const bool can_create=!current.value.campfire && CanCamp(*this,current.value);
  for(size_t i=0;i<Camps::Count();++i) {
   const auto& definition=Camps::All()[i];
   // Category IDs come from matching Resources/campsitecategories.txt.
   const uint32_t bit=1u<<Camps::Category(definition);
   if(category!=UINT32_MAX && !(category&bit))continue;
   const bool materials=!definition.kit_item_id || HasFellowshipCampsiteMaterials(*this,definition);
   const bool usable=definition.implemented && FellowshipCampsiteNativeBuffSupported(definition) && can_create && materials;
   if(!usable_only || usable)kits.push_back({definition.id,definition.description_id,definition.name,usable});
  }
 }
 Send(*this, OP_FellowshipCampList, Wire::EncodeKitList(kits));
}

bool Client::TryFellowshipCalling() {
 if (!Ready(*this) || GetHP() <= 0 || IsEngaged()) { Message(Chat::Red, "You cannot travel to your campfire right now."); return false; }
 Fellowship::Service service(database); auto current = service.GetByCharacter(CharacterID(), Now());
 if (!current || !current.value.id || !current.value.campfire) { Message(Chat::Red, "Your fellowship does not have an active campsite."); return false; }
 const auto& fire = *current.value.campfire;
 // Never grant access to an instance through a campfire. Ordinary zone and
 // instance entrance checks still run in MovePC.
 if (fire.instance_id && !database.CheckInstanceByCharID(fire.instance_id, CharacterID())) {
  Message(Chat::Red, "You do not have access to the campsite's instance."); return false;
 }
 MovePC(fire.zone_id, fire.instance_id, fire.x, fire.y, fire.z, fire.heading);
 return true;
}
