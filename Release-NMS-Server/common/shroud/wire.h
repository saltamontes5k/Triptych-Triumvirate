#pragma once
#include "native_stats.h"
#include <cstdint>
#include <array>
#include <string>
#include <vector>
#include <stdexcept>
namespace SpiritShroud {
// RoF2 AA window rebuild enumerates IDs [0,49999), unlike its unbounded cache.
inline constexpr uint32_t RoF2AAExclusiveMaximum = 49999;
inline bool EnumerableRank(uint32_t id) { return id && id < RoF2AAExclusiveMaximum; }
using Bytes = std::vector<uint8_t>;
inline uint32_t Read32(const uint8_t* p) { return uint32_t(p[0])|(uint32_t(p[1])<<8)|(uint32_t(p[2])<<16)|(uint32_t(p[3])<<24); }
inline void Put32(Bytes& out,uint32_t v) { for(unsigned i=0;i<4;++i) out.push_back(uint8_t(v>>(8*i))); }
inline void Put64(Bytes& out,uint64_t v) { for(unsigned i=0;i<8;++i) out.push_back(uint8_t(v>>(8*i))); }
inline void Text(Bytes& out,const std::string& text) { out.insert(out.end(),text.begin(),text.end());out.push_back(0); }
inline std::string Token(std::string text,char separator) {
 for(char& c:text)if(c==separator || c=='\0' || c=='\a' || c=='^')c=' ';
 return text+separator;
}
struct Equipment { uint32_t item_id{}; std::string name; };
struct RankPresentation { uint32_t rank_id{}, current{}, maximum{}, total_cost{}; };
struct Template {
 uint32_t id{},progression{},branch{},level{},race{},class_id{},gender{},hp{},mana{},endurance{},stat{},unlock_xp{};
 std::string name,description,progression_name,branch_name;
 uint32_t content_version{1}, monster_points{};
 bool verified{},test_only{true};
 std::string evidence_ref,entitlement_key;
 // Ordered STR,STA,CHA,DEX,INT,AGI,WIS. Legacy test definitions may use stat.
 std::array<uint32_t,7> attributes{};
 // Ordered by NativeStat; these are contributions, not displayed resource maxima.
 std::array<uint32_t,NativeStatCount> native_stats{};
 bool has_native_stats{},has_native_resources{},resource_maxima{};
 float model_size{};
 std::vector<uint32_t> abilities,ability_names,free_abilities;
 std::vector<Equipment> equipment;
 // Captured free highest ranks may have no evidenced predecessor chain.
 // Ownership remains a local ordinal; only native presentation uses these values.
 std::vector<RankPresentation> rank_presentations;
};
struct PreviewAbility { uint32_t rank_id, title_sid; };
inline Bytes Details(const Template& t, const std::vector<PreviewAbility>* preview = nullptr) {
 Bytes out;Put32(out,t.id);Put32(out,1);
 std::string s=Token(std::to_string(t.id),'^')+Token(t.name,'^')+Token(t.description,'^');
 for(auto n:{t.class_id,t.level,t.hp,t.mana,t.endurance})s+=Token(std::to_string(n),'^');
 for(auto n:t.attributes)s+=Token(std::to_string(n),'^');
 s+=Token(std::to_string(preview ? preview->size() : t.abilities.size()),'^');
 if (preview) {
  for (const auto& ability : *preview) s+=Token(std::to_string(ability.rank_id),'^')+Token(std::to_string(ability.title_sid),'^');
 } else {
  for(size_t i=0;i<t.abilities.size();++i)s+=Token(std::to_string(t.abilities[i]),'^')+Token(std::to_string(t.ability_names.at(i)),'^');
 }
 s+=Token(std::to_string(t.equipment.size()),'^');
 for(const auto& item:t.equipment)s+=Token(std::to_string(item.item_id),'^')+Token(item.name,'^');
 Text(out,s);return out;
}
}
