#include "fellowship_campfire.h"
#include "fellowship_campsite_bonuses.h"
#include "entity.h"
#include "client.h"
#include "../common/fellowship/campsite_catalogue.h"
#include "npc.h"
#include "zone.h"
#include "zonedb.h"
#include "../common/rulesys.h"
#include <chrono>
#include <cmath>
#include <cstring>
#include <ctime>
#include <map>
#include <memory>
#include <string>
extern Zone* zone;
namespace {
struct Fire {
 uint32_t id{}, type{}; uint64_t expires{}; float x{}, y{}, z{}, heading{};
 uint16_t entity{}; NPC* owned{}; std::string token;
};
std::map<uint32_t, Fire> fires;
std::map<uint32_t, uint32_t> membership;
struct Applied { uint32_t type{}, entity{}; const Client* client{}; };
std::map<uint32_t, Applied> applied;
float effect_radius = Fellowship::Campsites::DefaultEffectRadius;
Zone* owner{};
uint32_t owner_zone{}, owner_instance{};
uint64_t generation{};
std::chrono::steady_clock::time_point next_poll{};
bool Same(const Fire& a, const Fire& b) {
 return a.id == b.id && a.type == b.type && a.expires == b.expires && a.x == b.x && a.y == b.y && a.z == b.z && a.heading == b.heading;
}
NPC* Live(const Fire& f) {
 auto* m = entity_list.GetMob(f.entity);
 // Pointer and token together protect against entity ID and allocator reuse.
 if (!m || m != f.owned || !m->IsNPC() || m->GetEntityVariable("fellowship_campfire_token") != f.token) return nullptr;
 auto* npc = m->CastToNPC();
 return npc->GetDepop() ? nullptr : npc;
}
void RemoveVisual(const Fire& f) { if (auto* npc = Live(f)) npc->Depop(false); }
bool Valid(const Fire& f) {
 return f.id && std::isfinite(f.x) && std::isfinite(f.y) && std::isfinite(f.z) && std::isfinite(f.heading)
  && std::abs(f.x) <= 65536 && std::abs(f.y) <= 65536 && std::abs(f.z) <= 65536 && f.heading >= 0 && f.heading < 512;
}
void Spawn(Fire& f) {
 auto type = std::make_unique<NPCType>();
 std::memset(type.get(), 0, sizeof(NPCType));
 std::strcpy(type->name, "Fellowship_Campfire");
 type->current_hp = type->max_hp = 1;
 type->race = 567; type->gender = 2; type->class_ = 1; type->level = 1;
 type->size = 3; type->bodytype = 11;
 type->untargetable = true; type->show_name = false;
 type->skip_global_loot = true; type->skip_auto_scale = true;
 type->trackable = false; type->findable = false;
 // Zeroed type supplies no spells, faction, loot, movement, aggro or services.
 auto npc = std::make_unique<NPC>(type.get(), nullptr, glm::vec4(f.x, f.y, f.z, f.heading), GravityBehavior::Flying);
 npc->GiveNPCTypeData(type.release());
 npc->AI_Stop(); npc->Mob::AI_Stop(); npc->SetInvul(true); npc->SetTargetable(false); npc->SaveGuardSpot();
 f.token = std::to_string(++generation);
 npc->SetEntityVariable("fellowship_campfire_token", f.token);
 npc->SetEntityVariable("fellowship_campfire_id", std::to_string(f.id));
 entity_list.AddNPC(npc.get(), true, true);
 f.entity = npc->GetID(); f.owned = npc.release();
}
}
void ClearFellowshipCampfires() {
 for (const auto& client : entity_list.GetClientList()) if (client.second && client.second->Connected()) ReconcileFellowshipCampsiteAppearance(*client.second, nullptr, nullptr);
 ClearFellowshipCampsiteAppearanceState();
 for (const auto& entry : fires) RemoveVisual(entry.second);
 fires.clear(); membership.clear(); applied.clear(); owner = nullptr; owner_zone = owner_instance = 0; next_poll = {};
}
const Fellowship::Campsites::Definition* GetFellowshipCampsiteEffect(const Client& client) {
 if (!zone || owner != zone || owner_zone != zone->GetZoneID() || owner_instance != zone->GetInstanceID() || !client.Connected() || client.GetHP() <= 0) return nullptr;
 auto member = membership.find(client.CharacterID());
 if (member == membership.end()) return nullptr;
 auto fire = fires.find(member->second);
 if (fire == fires.end() || fire->second.expires <= static_cast<uint64_t>(std::time(nullptr)) || !Live(fire->second)) return nullptr;
 const auto* definition = Fellowship::Campsites::Lookup(fire->second.type);
 if (!definition || !definition->implemented || definition->effect == Fellowship::Campsites::Effect::None) return nullptr;
 const double x = client.GetX() - fire->second.x, y = client.GetY() - fire->second.y, z = client.GetZ() - fire->second.z;
 if (!std::isfinite(x) || !std::isfinite(y) || !std::isfinite(z) || x*x+y*y+z*z > double(effect_radius)*effect_radius) return nullptr;
 return definition;
}
void InvalidateFellowshipCampsites() { next_poll = {}; }
void SetFellowshipCampsiteRadius(float radius) {
 if (std::isfinite(radius) && radius > 0 && radius <= 65536) { effect_radius = radius; InvalidateFellowshipCampsites(); }
}
namespace {
void RefreshEffects() {
 std::map<uint32_t, Applied> current;
 for (const auto& entry : entity_list.GetClientList()) {
  auto* client = entry.second;
  if (!client || !client->Connected()) continue;
  const auto* effect = GetFellowshipCampsiteEffect(*client);
  NPC* source=nullptr;
  if (effect) { auto member=membership.find(client->CharacterID()); if(member!=membership.end()){auto fire=fires.find(member->second);if(fire!=fires.end())source=Live(fire->second);} }
  ReconcileFellowshipCampsiteAppearance(*client, source, effect);
  const uint32_t type = effect ? effect->id : 0;
  const auto previous = applied.find(client->CharacterID());
  const bool changed = previous == applied.end() || previous->second.type != type || previous->second.client != client || previous->second.entity != client->GetID();
  current.emplace(client->CharacterID(), Applied{type, client->GetID(), client});
  if (changed) { client->CalcBonuses(); client->SendHPUpdate(); client->SendManaUpdate(); }
 }
 applied = std::move(current);
}
}
void ProcessFellowshipCampfires() {
 if (!RuleB(Custom, Fellowships) || !RuleB(Custom, FellowshipCamps)) { ClearFellowshipCampfires(); return; }
 if (!zone) { ClearFellowshipCampfires(); return; }
 if (owner != zone || owner_zone != zone->GetZoneID() || owner_instance != zone->GetInstanceID()) {
  ClearFellowshipCampfires(); owner = zone; owner_zone = zone->GetZoneID(); owner_instance = zone->GetInstanceID();
 }
 const auto clock = std::chrono::steady_clock::now();
 if (clock < next_poll) return;
 next_poll = clock + std::chrono::seconds(5);
 const auto now = static_cast<uint64_t>(std::time(nullptr));
 // Expire even if the database is temporarily unavailable.
 for (auto i = fires.begin(); i != fires.end();) {
  if (i->second.expires <= now) { RemoveVisual(i->second); i = fires.erase(i); } else ++i;
 }
 auto result = database.QueryDatabase("SELECT id,campfire_x,campfire_y,campfire_z,campfire_heading,campfire_expires_at,campfire_type FROM fellowships WHERE campfire_zone_id="
  + std::to_string(owner_zone) + " AND campfire_instance_id=" + std::to_string(owner_instance) + " AND campfire_expires_at>" + std::to_string(now));
 if (!result.Success()) { membership.clear(); RefreshEffects(); return; }
 std::map<uint32_t, Fire> wanted;
 for (auto row = result.begin(); row != result.end(); ++row) {
  try {
   if (!row[0] || !row[1] || !row[2] || !row[3] || !row[4] || !row[5] || !row[6]) continue;
   Fire f; f.id = std::stoul(row[0]); f.x = std::stof(row[1]); f.y = std::stof(row[2]); f.z = std::stof(row[3]); f.heading = std::stof(row[4]); f.expires = std::stoull(row[5]); f.type = std::stoul(row[6]);
   const auto* definition = Fellowship::Campsites::Lookup(f.type);
   if (Valid(f) && definition && definition->implemented) wanted.emplace(f.id, f);
  } catch (...) { /* A malformed durable row cannot create a world entity. */ }
 }
 for (auto i = fires.begin(); i != fires.end();) {
  auto match = wanted.find(i->first);
  if (match == wanted.end() || !Same(i->second, match->second) || !Live(i->second)) {
   RemoveVisual(i->second); i = fires.erase(i);
  } else ++i;
 }
 for (auto& entry : wanted) if (!fires.count(entry.first)) { Spawn(entry.second); fires.emplace(entry); }
 membership.clear();
 if (!fires.empty()) {
  std::string ids;
  for (const auto& fire : fires) { if (!ids.empty()) ids += ","; ids += std::to_string(fire.first); }
  auto members = database.QueryDatabase("SELECT character_id,fellowship_id FROM fellowship_members WHERE fellowship_id IN (" + ids + ")");
  if (members.Success()) for (auto row = members.begin(); row != members.end(); ++row) {
   try { if (row[0] && row[1]) membership.emplace(std::stoul(row[0]), std::stoul(row[1])); } catch (...) {}
  }
 }
 RefreshEffects();
}
