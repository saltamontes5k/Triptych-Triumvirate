#pragma once
#include "wire.h"
#include <set>
#include <algorithm>

namespace SpiritShroud {
struct PreviewRankRange {
 bool valid{};
 int maximum{};
 int previous{-1};
 int next{-1};
};

// A normal character previews another class's form. Its own AA eligibility
// must neither truncate this chain nor expose ranks absent from that form.
template<class Rank>
PreviewRankRange PreviewRange(const Template& form, const Rank* requested)
{
 PreviewRankRange result;
 if (!requested || !requested->base_ability || form.class_id < 1 || form.class_id > 16) return result;
 const auto* ability = requested->base_ability;
 if ((ability->category != 3 && ability->category != 4) ||
     !(ability->classes & (1U << form.class_id))) return result;
 std::set<uint32_t> available(form.abilities.begin(), form.abilities.end());
 std::vector<const Rank*> chain;
 size_t selected = 0;
 for (const auto* rank = ability->first; rank && chain.size() < 300; rank = rank->next) {
  if (rank->base_ability != ability || rank->current_value != int(chain.size()) + 1 ||
      rank->level_req > int(form.level) || rank->cost < 0 || !available.count(rank->id)) break;
  if (rank == requested) { result.valid = true; selected = chain.size(); }
  chain.push_back(rank);
 }
 if (!result.valid) return result;
 result.maximum = int(chain.size());
 if (selected) result.previous = int(chain[selected - 1]->id);
 if (selected + 1 < chain.size()) result.next = int(chain[selected + 1]->id);
 return result;
}

// Omitting a definition does not remove a previously cached Monster AA.
// Refresh its class mask to zero when it is unavailable to this profile.
template<class Rank>
bool HideCachedRank(const Template* form, const Rank* rank)
{
 return rank && rank->base_ability && EnumerableRank(rank->id) &&
  (rank->base_ability->category==3 || rank->base_ability->category==4) &&
  (!form || !PreviewRange(*form,rank).valid);
}

// Only isolated, free, grant-only local adapters may use captured higher-rank
// presentation. No unknown predecessor, purchase cost, or unlock is inferred.
template<class Rank>
const RankPresentation* CapturedPresentation(const Template& form, const Rank* rank)
{
 if(!rank || !PreviewRange(form,rank).valid || rank->current_value!=1 || rank->prev || rank->next ||
    !rank->base_ability->grant_only ||
    std::find(form.free_abilities.begin(),form.free_abilities.end(),rank->id)==form.free_abilities.end())return nullptr;
 for(const auto& item:form.rank_presentations)if(item.rank_id==uint32_t(rank->id) &&
    item.current && item.current==item.maximum && item.current<=1000 && item.total_cost<=1000000)return &item;
 return nullptr;
}

// Definitions retain every purchasable rank. Selection lists show each
// ability once: its free entry rank, or its first rank when not granted.
template<class GetRank>
std::vector<PreviewAbility> SelectionAbilities(const Template& form, GetRank get_rank)
{
 std::vector<PreviewAbility> result;
 std::set<uint32_t> seen;
 std::set<uint32_t> free(form.free_abilities.begin(), form.free_abilities.end());
 for (auto id : form.abilities) {
  if (!EnumerableRank(id)) throw std::invalid_argument("shroud AA outside native list range");
  const auto* rank = get_rank(id);
  auto range = PreviewRange(form, rank);
  if (!range.valid) throw std::invalid_argument("invalid shroud preview rank");
  if (!seen.insert(rank->base_ability->id).second) continue;
  const auto* display = rank->base_ability->first;
  const auto* candidate = display;
  for (int i = 0; candidate && i < range.maximum; ++i, candidate = candidate->next)
   if (free.count(candidate->id)) display = candidate;
  result.push_back({display->id, uint32_t(display->title_sid)});
 }
 return result;
}
}
