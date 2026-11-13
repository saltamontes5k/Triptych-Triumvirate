#pragma once
#include <cstdint>
#include <map>
#include <optional>
#include <set>
#include <stdexcept>
#include <string>
#include <utility>
#include <vector>
namespace SpiritShroud {
inline constexpr const char* StarterSessionKey="spirit_shroud_starter_session";
inline constexpr const char* StarterTokenKey="spirit_shroud_starter_token";
inline std::string StarterToken(uint64_t session,uint64_t issued_identity)
{
 if(!session||!issued_identity)throw std::runtime_error("invalid shroud starter identity");
 return "v1:"+std::to_string(session)+":"+std::to_string(issued_identity);
}
struct StarterMetadata {std::optional<std::string> session,token;};
inline StarterMetadata ReadStarterMetadata(const std::string& data)
{
 StarterMetadata fields;
 if(data.find(StarterSessionKey)==std::string::npos&&data.find(StarterTokenKey)==std::string::npos)return fields;
 size_t at=0;
 while(at<data.size()){
  auto end=data.find('^',at);if(end==std::string::npos||end==at)throw std::runtime_error("malformed shroud starter metadata");
  const auto key=data.substr(at,end-at);at=end+1;
  end=data.find('^',at);if(end==std::string::npos)end=data.size();
  const auto value=data.substr(at,end-at);at=end<data.size()?end+1:end;
  auto* field=key==StarterSessionKey?&fields.session:(key==StarterTokenKey?&fields.token:nullptr);
  if(field){if(field->has_value())throw std::runtime_error("duplicate shroud starter metadata");*field=value;}
  if(at<data.size()&&data[at]=='^')++at;
 }
 return fields;
}
inline std::string StarterSession(const std::string& data)
{
 try{return ReadStarterMetadata(data).session.value_or("");}catch(...){return {};}
}
struct StarterHeldItem { uint32_t slot{},item{};uint64_t guid{};bool bag{};std::string custom; };
struct StarterIssuedItem {
 // guid is the original issuance identity, not the ephemeral loaded serial.
 uint64_t guid{};uint32_t item{},issued_slot{UINT32_MAX};
 // SQL NULL identifies pre-token legacy issuance. Empty is invalid, not legacy.
 std::optional<std::string> token;
};
struct StarterRemoval {std::vector<uint32_t> discard;std::vector<std::pair<uint32_t,uint32_t>> promote;};
// Temporary containers disappear, while earned contents become independent
// bank roots. Capacity or provenance failure leaves restoration uncommitted.
template<class Children>
StarterRemoval PlanStarterRemoval(uint64_t session,const std::vector<StarterHeldItem>& held,
 const std::vector<StarterIssuedItem>& issued,uint32_t root_end,Children children)
{
 if(!session)throw std::runtime_error("invalid shroud starter session");
 StarterRemoval plan;std::map<std::string,const StarterIssuedItem*> grants;
 std::map<uint32_t,const StarterIssuedItem*> legacy;
 std::map<uint32_t,unsigned> issued_counts,held_counts;
 std::set<uint64_t> identities;std::set<uint32_t> issued_slots;
 for(const auto& item:issued){
  if(!item.guid||!item.item||item.issued_slot>=root_end||!identities.insert(item.guid).second||!issued_slots.insert(item.issued_slot).second)
   throw std::runtime_error("duplicate or invalid shroud starter issuance");
  ++issued_counts[item.item];
  if(item.token){
   if(*item.token!=StarterToken(session,item.guid)||!grants.emplace(*item.token,&item).second)
    throw std::runtime_error("invalid shroud starter token issuance");
  }else if(!legacy.emplace(item.item,&item).second)throw std::runtime_error("ambiguous legacy shroud starter issuance");
 }
 for(const auto& item:held)++held_counts[item.item];
 std::set<std::string> seen;std::set<uint32_t> temporary,occupied;
 std::map<uint32_t,const StarterHeldItem*> slots;
 for(const auto& item:held){
  if(!slots.emplace(item.slot,&item).second)throw std::runtime_error("duplicate shroud inventory slot");
  const auto marker=ReadStarterMetadata(item.custom);
  if(marker.session||marker.token){
   if(!marker.session||*marker.session!=std::to_string(session))throw std::runtime_error("shroud starter session changed");
   const StarterIssuedItem* grant=nullptr;
   if(marker.token){
    auto found=grants.find(*marker.token);if(found!=grants.end())grant=found->second;
   }else{
    // Legacy inventory serials were regenerated on load. Recover only the
    // unique, still unmoved item at its original issued slot, with its exact
    // session marker. New tokenized rows can never enter this fallback.
    auto found=legacy.find(item.item);
    if(found!=legacy.end()&&found->second->issued_slot==item.slot&&issued_counts[item.item]==1&&held_counts[item.item]==1)grant=found->second;
   }
   if(!grant||grant->item!=item.item||!seen.insert(StarterToken(session,grant->guid)).second)
    throw std::runtime_error("shroud starter provenance changed");
   temporary.insert(item.slot);plan.discard.push_back(item.slot);
  }else if(item.slot<root_end)occupied.insert(item.slot);
 }
 for(const auto& item:held)if(temporary.count(item.slot)&&item.bag){
  for(auto child:children(item.slot))if(slots.count(child)&&!temporary.count(child)){
   uint32_t destination=0;while(destination<root_end&&occupied.count(destination))++destination;
   if(destination==root_end)throw std::runtime_error("make room before restoring earned starter-bag contents");
   occupied.insert(destination);plan.promote.emplace_back(child,destination);
  }
 }
 return plan;
}
}
