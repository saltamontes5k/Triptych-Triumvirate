-- powar: Lieutenant Ess Pekky — Castle Tamrel gate lieutenant
-- Tallon Captain Insignia turn-ins, the retreat dust, and the tactics book
-- that starts the Colonel's arc.
local P = require("powar_shared")
local item_lib = require("items")

local TALLON_CAPTAIN = 88466
local DUST = 88464          -- Tamrel's Tactical Retreat Dust
local TACTICS_BOOK = 88467  -- Ess Pekky's Tactics Book

function event_say(e)
  local c = e.other
  local standing, label = P.standing(c, "tamrel")
  if e.message:findi("hail") then
    if not P.flagged(c, "mines") then
      P.say(e, "The lieutenant does not look up. 'Tamrel ground. The wall decides.'")
    elseif standing >= 100 then
      if not c:HasItem(DUST) then
        P.say(e, "Rekkles' vouching reached me. Take this — Tamrel's Tactical Retreat Dust. Click it anywhere in the Plane of War and the dust will carry you back to my side. Do not lose it; the recipe died with its maker.")
        e.other:SummonItem(DUST)
      elseif P.flagged(c, "colonel") then
        P.say(e, "The new colonel's champion. Ugor chose well.")
      elseif P.flagged(c, "trials") and not P.get(c, "book_given") then
        P.say(e, "Flavis writes that you broke all three seals. Then you are ready for the Ogre tactics. Say 'ogre tactics' and take the book to General Ugor Gronno upstairs.")
      else
        P.say(e, "Dust in hand, soldier. Keep hunting the field.")
      end
    else
      P.say(e, "Lieutenant Ess Pekky, of the Tamrel gate. Captain insignias — from the field trash — are worth ten soldier trinkets to me. Your standing: " .. label .. ".")
    end
  elseif e.message:findi("ogre tactics") and standing >= 100 and P.flagged(c, "trials") and not P.get(c, "book_given") then
    P.set(c, "book_given", "1")
    e.other:SummonItem(TACTICS_BOOK)
    P.say(e, "The ogre tactics — Ugor's own, from before he crossed over. Take the book to him. What he does with it is his war to explain.")
  end
end

function event_trade(e)
  local c = e.other
  if not P.flagged(c, "mines") then
    item_lib.return_items(e.self, e.other, e.trade)
    return
  end
  if item_lib.check_turn_in(e.trade, { item1 = TALLON_CAPTAIN }) then
    local v = P.fac_up(c, "tamrel", 8)
    local _, label = P.standing(c, "tamrel")
    P.say(e, "A captain's rank, fallen. Tamrel notes it — standing: " .. label .. ".")
  else
    item_lib.return_items(e.self, e.other, e.trade)
  end
end
