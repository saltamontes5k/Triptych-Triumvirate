#pragma once
#include "wire.h"
#include "../json/json.hpp"
#include <algorithm>
#include <cmath>
#include <set>
namespace SpiritShroud {
inline void Validate(const Template& t)
{
 if (!t.id || t.id > INT32_MAX || !t.content_version || !t.progression || !t.branch ||
     !t.race || t.race > UINT16_MAX || !t.level || t.level > 100 ||
     !t.class_id || t.class_id > 16 || t.gender > 2 ||
     t.hp > 1000000 || t.mana > 1000000 || t.endurance > 1000000 ||
     t.monster_points > 1000000 || t.entitlement_key.size() > 63 ||
     t.abilities.size() > 300 || t.abilities.size() != t.ability_names.size())
  throw std::invalid_argument("invalid shroud definition");
 if(!std::isfinite(t.model_size) || t.model_size<0 || t.model_size>100)throw std::invalid_argument("invalid shroud model size");
 for (auto v : t.attributes) if (v > 1000) throw std::invalid_argument("invalid shroud attribute");
 for (auto v : t.native_stats) if (v > 1000000) throw std::invalid_argument("invalid shroud baseline");
 if(t.equipment.size()>50)throw std::invalid_argument("too many shroud equipment previews");
 std::set<uint32_t> equipment;
 for(const auto& item:t.equipment)if(!item.item_id || !equipment.insert(item.item_id).second || item.name.empty() || item.name.size()>63)
  throw std::invalid_argument("invalid shroud equipment preview");
 std::set<uint32_t> available;
 for (auto id : t.abilities)
  if (!id || id > UINT16_MAX || !available.insert(id).second)
   throw std::invalid_argument("invalid shroud ability set");
 std::set<uint32_t> free;
 for (auto id : t.free_abilities)
  if (!available.count(id) || !free.insert(id).second) throw std::invalid_argument("invalid free rank set");
 std::set<uint32_t> presentations;
 for(const auto& rank:t.rank_presentations)
  if(!free.count(rank.rank_id) || !presentations.insert(rank.rank_id).second ||
     !rank.current || rank.current>1000 || rank.current!=rank.maximum || rank.total_cost>1000000)
   throw std::invalid_argument("invalid free shroud rank presentation");
 if (t.verified && (t.test_only || t.evidence_ref.empty() || (!t.has_native_stats && !t.has_native_resources)))
  throw std::invalid_argument("incomplete verified shroud definition");
}
inline std::string Snapshot(const Template& t)
{
 Validate(t);
 nlohmann::json j;
 j["id"] = t.id;
 j["progression"] = t.progression;
 j["branch"] = t.branch;
 j["level"] = t.level;
 j["race"] = t.race;
 j["class_id"] = t.class_id;
 j["gender"] = t.gender;
 j["hp"] = t.hp;
 j["mana"] = t.mana;
 j["endurance"] = t.endurance;
 j["stat"] = t.stat;
 j["unlock_xp"] = t.unlock_xp;
 j["name"] = t.name;
 j["description"] = t.description;
 j["progression_name"] = t.progression_name;
 j["branch_name"] = t.branch_name;
 j["content_version"] = t.content_version;
 j["monster_points"] = t.monster_points;
 j["verified"] = t.verified;
 j["test_only"] = t.test_only;
 j["evidence_ref"] = t.evidence_ref;
 j["entitlement_key"] = t.entitlement_key;
 j["attributes"] = t.attributes;
 j["native_stats"] = t.native_stats;
 j["has_native_stats"] = t.has_native_stats;
 j["has_native_resources"] = t.has_native_resources;
 j["resource_maxima"] = t.resource_maxima;
 j["model_size"] = t.model_size;
 j["equipment"]=nlohmann::json::array();
 for(const auto& item:t.equipment)j["equipment"].push_back({{"item_id",item.item_id},{"name",item.name}});
 j["abilities"] = t.abilities;
 j["ability_names"] = t.ability_names;
 j["free_abilities"] = t.free_abilities;
 j["rank_presentations"]=nlohmann::json::array();
 for(const auto& rank:t.rank_presentations)j["rank_presentations"].push_back({{"rank_id",rank.rank_id},{"current",rank.current},{"maximum",rank.maximum},{"total_cost",rank.total_cost}});
 return j.dump();
}
inline Template RestoreSnapshot(const std::string& text)
{
 if (text.size() > 262144) throw std::length_error("shroud definition too large");
 const auto j = nlohmann::json::parse(text);
 Template t;
 j.at("id").get_to(t.id);
 j.at("progression").get_to(t.progression);
 j.at("branch").get_to(t.branch);
 j.at("level").get_to(t.level);
 j.at("race").get_to(t.race);
 j.at("class_id").get_to(t.class_id);
 j.at("gender").get_to(t.gender);
 j.at("hp").get_to(t.hp);
 j.at("mana").get_to(t.mana);
 j.at("endurance").get_to(t.endurance);
 j.at("stat").get_to(t.stat);
 j.at("unlock_xp").get_to(t.unlock_xp);
 j.at("name").get_to(t.name);
 j.at("description").get_to(t.description);
 j.at("progression_name").get_to(t.progression_name);
 j.at("branch_name").get_to(t.branch_name);
 j.at("content_version").get_to(t.content_version);
 j.at("monster_points").get_to(t.monster_points);
 j.at("verified").get_to(t.verified);
 j.at("test_only").get_to(t.test_only);
 j.at("evidence_ref").get_to(t.evidence_ref);
 j.at("entitlement_key").get_to(t.entitlement_key);
 j.at("attributes").get_to(t.attributes);
 j.at("native_stats").get_to(t.native_stats);
 j.at("has_native_stats").get_to(t.has_native_stats);
 t.has_native_resources=j.value("has_native_resources",t.has_native_stats);
 t.resource_maxima=j.value("resource_maxima",false);
 t.model_size=j.value("model_size",0.0f);
 if(j.contains("equipment"))for(const auto& item:j.at("equipment"))t.equipment.push_back({item.at("item_id").get<uint32_t>(),item.at("name").get<std::string>()});
 j.at("abilities").get_to(t.abilities);
 j.at("ability_names").get_to(t.ability_names);
 j.at("free_abilities").get_to(t.free_abilities);
 if(j.contains("rank_presentations"))for(const auto& rank:j.at("rank_presentations"))t.rank_presentations.push_back({rank.at("rank_id").get<uint32_t>(),rank.at("current").get<uint32_t>(),rank.at("maximum").get<uint32_t>(),rank.at("total_cost").get<uint32_t>()});
 Validate(t);
 return t;
}
inline bool Offered(const Template& t, bool allow_test)
{
 // Entry is denied for undisplayable content; retained snapshots remain recoverable.
 return std::all_of(t.abilities.begin(),t.abilities.end(),EnumerableRank) &&
  ((t.verified && !t.test_only) || (allow_test && t.test_only));
}
}
