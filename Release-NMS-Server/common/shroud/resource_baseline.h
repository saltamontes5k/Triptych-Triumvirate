#pragma once
#include "native_stats.h"
#include <array>
#include <cmath>
#include <cstdint>
#include <stdexcept>

namespace SpiritShroud {
// Matching RoF2 0x442620: truncate the average and BOTH half-stat
// operations independently; a continuous piecewise curve loses these steps.
inline uint32_t EndurancePhysicalStat(uint32_t strength, uint32_t stamina,
 uint32_t dexterity, uint32_t agility)
{
 uint64_t physical = (static_cast<uint64_t>(strength)+stamina+dexterity+agility)/4;
 if(physical>100) {
  if(physical>200)physical-=(physical-200)/2;
  physical+=(3*physical-300)/2;
 }
 return static_cast<uint32_t>(physical);
}

// RoF2 multiplies the stored binary64 factor in x87 precision, then truncates
// that product before adding the integer alternate-profile contribution. A
// binary64 multiply can round a value just below an integer up to that integer.
// FMA retains the exact signed residual without a platform-dependent long double.
inline double HPStaminaContribution(int stamina, double hp_factor)
{
 const double product=hp_factor*stamina;
 const double integral=std::trunc(product);
 if(product==integral && std::fma(hp_factor,static_cast<double>(stamina),-product)<0)
  return integral-1;
 return integral;
}

// Translate observed unbuffed maxima to the additive alternate-profile terms
// expected by RoF2. Equipment, buffs and purchased passives apply afterward.
inline std::array<uint32_t,3> ResourceContributions(
 const std::array<uint32_t,7>& attributes, uint32_t hp, uint32_t mana,
 uint32_t endurance, uint32_t class_id, double hp_factor,
 double mana_factor, double endurance_factor)
{
 int stamina = attributes[1];
 if(stamina>255) stamina=255+(stamina-255)/2;
 int mind = (class_id==2 || class_id==3 || class_id==4 || class_id==6 || class_id==10 || class_id==15)
  ? attributes[6] : attributes[4];
 int converted=mind;
 if(mind>100){int over=mind;if(mind>200)over=(mind-200)/-2+mind;converted=(3*over-300)/2+over;}
 const auto physical=EndurancePhysicalStat(attributes[0],attributes[1],attributes[3],attributes[5]);
 const std::array<double,3> stat_terms{{HPStaminaContribution(stamina,hp_factor)+5,
  mana ? mana_factor*converted : 0, endurance_factor*static_cast<int>(physical)}};
 const std::array<uint32_t,3> totals{{hp,mana,endurance}};
 std::array<uint32_t,3> out{};
 for(unsigned i=0;i<out.size();++i){
  if(!std::isfinite(stat_terms[i]) || stat_terms[i]<0 || stat_terms[i]>totals[i])
   throw std::invalid_argument("shroud resource maximum below class stat contribution");
  out[i]=totals[i]-static_cast<uint32_t>(stat_terms[i]);
 }
 return out;
}
}
