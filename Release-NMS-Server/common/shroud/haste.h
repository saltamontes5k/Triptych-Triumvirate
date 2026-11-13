#pragma once

#include <algorithm>

namespace SpiritShroud {

// Current Live TotalEffect(11,true,0,true,true), PC branch, with no item haste.
// The supported shroud starter catalog has zero item haste; admission of such
// equipment requires a separately verified item-cache conversion. AA SPA11 is
// the captured raw factor (105..140), while spellbonuses stores signed percent.
// Do not replace the native sum of AA and spell factors with a maximum.
inline int HasteFactorWithoutItems(int level, int aa_factor, int spell_percent,
 int type2_percent, int type3_value, int inhibit, int gm_extra)
{
 int type1 = aa_factor + (spell_percent ? 100 + spell_percent : 0);
 if (inhibit) {
  if (!type1) type1 = 100 - inhibit;
  else if (type1 >= 100) type1 -= inhibit;
  else type1 = std::min(type1, 100 - inhibit);
  type1 = std::max(type1, 1);
 }
 // A native slow/inhibit result suppresses all other haste contributions.
 if (type1 > 0 && type1 <= 100) return type1;

 int total = type1;
 if (level > 49 && type2_percent > 0) {
  total = (total ? total - 100 : 0) + std::min(100 + type2_percent, 110);
 }
 int over = 0;
 if (type3_value > 0) {
  over = type3_value > 100 ? type3_value - 100 : type3_value;
  over = std::min(over, level < 51 ? 10 : 25);
 }
 const int cap = (level > 59 ? 200 : level > 50 ? 185 : level + 125) + over;
 if (!total) total = over ? 100 + over : 100;
 else total += over;
 return std::min(total, cap) + gm_extra;
}

} // namespace SpiritShroud
