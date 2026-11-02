-- povalor: Zayenaek, Emissary of War (second leg of the powar tithe chain)
-- Infuses the Stonewood Compound Bow with a Zekarian Diamond.
local P = require("powar_shared")
local item_lib = require("items")

local STONEWOOD_BOW = 29597
local DIAMOND = 127556
local SCHEMATIC = 127557
local TITHE_BOW = 127560

function event_say(e)
  local c = e.other
  if e.message:findi("blessing of your sister") or e.message:findi("hail") then
    if P.flagged(c, "tithe_val") then
      if P.flagged(c, "tithe_bow") then
        P.say(e, "Ets`in`thini`konar`ifet has your bow now. The tithe is settled — go pay the rest of it in blood.")
      else
        P.say(e, "Bring me a Stonewood Compound Bow and a Zekarian Diamond, warbrand. The diamonds fall from the named of the Field of Blood. Fletcher Forlen in Castle Rulnavis strings the bows — show him my favor and he will sell you one.")
      end
    elseif P.flagged(c, "tithe_jus") then
      P.set(c, "tithe_val", "1")
      e.other:SummonItem(SCHEMATIC)
      P.say(e, "You seek my blessing? Then it is given — scribe this schematic and never lose it. My diamonds fall from the named of the Field of Blood, beyond the wall. Bring a Stonewood Compound Bow — Fletcher Forlen in Castle Rulnavis will string one for my marked — and the diamond, and I will fuse the two.")
    else
      P.say(e, "My brother keeps the tithe's first door, in the Plane of Justice. Speak him first, little one.")
    end
  end
end

function event_trade(e)
  if item_lib.check_turn_in(e.trade, { item1 = STONEWOOD_BOW, item2 = DIAMOND }) then
    if P.flagged(e.other, "tithe_val") then
      e.other:SummonItem(TITHE_BOW)
      P.say(e, "War lives in this stone. Take the bow it has woken in — and give Ets`in`thini`konar`ifet no reason to regret the favor.")
    else
      item_lib.return_items(e.self, e.other, e.trade)
      P.say(e, "I do not fuse weapons for the unmarked. Speak my name through my brother first.")
    end
  else
    item_lib.return_items(e.self, e.other, e.trade)
  end
end
