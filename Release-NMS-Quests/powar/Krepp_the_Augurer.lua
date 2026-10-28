-- powar: Krepp the Augurer — reads the ore, tags the delver
-- (PoP-ized: instead of dragging a wounded kobold across the tunnels, prove
-- the delving with five Narikor Tin Ore — the worthless ore the mines cough
-- up on everyone.)
local P = require("powar_shared")
local item_lib = require("items")

local GEM = 67996
local TIN = 97485        -- Narikor Tin Ore
local MARKER = 86232     -- Krepp's Tagging Marker
local MARK = 67999       -- Mark of Rallos Zek

function event_say(e)
  local c = e.other
  if e.message:findi("hail") then
    if P.flagged(c, "dyrg_mark") then
      P.say(e, "The augury stands. Return to Dyrginal — say 'challenge' to him when you dare.")
    elseif P.flagged(c, "dyrg_symbol") then
      P.say(e, "New tunnels, new scars. Dyrginal sends you? Then show me the gems, and I will show you what the war writes in stone. Say 'augur' when you carry three Shining Gems of Striking.")
    else
      P.say(e, "I augur nothing for strangers. Dyrginal's work, Dyrginal's word.")
    end
  elseif e.message:findi("augur") and P.flagged(c, "dyrg_symbol") and not P.flagged(c, "dyrg_mark") then
    P.say(e, "The gems will find the seams. But first prove the delve: five Narikor Tin Ore, the worthless grit the mines spit at every digger. Bring it and I will tag you with the Mark's token.")
  end
end

function event_trade(e)
  local c = e.other
  if item_lib.check_turn_in(e.trade, { item1 = GEM, item2 = GEM, item3 = GEM }) then
    if P.flagged(c, "dyrg_symbol") then
      e.other:SummonItem(MARKER)
      P.set(c, "dyrg_tagged", "1")
      P.say(e, "The gems sing of the seam below. Here — Krepp's Tagging Marker. Now the tin: five chunks of the worthless ore. The mines mock everyone; show me you were mocked enough to persist.")
    end
  elseif P.flagged(c, "dyrg_tagged") and item_lib.check_turn_in(e.trade, { item1 = TIN, item2 = TIN, item3 = TIN, item4 = TIN, item5 = TIN }) then
    e.other:SummonItem(MARK)
    P.set(c, "dyrg_mark", "1")
    P.say(e, "Five mockings, five marks. You delve like the old ones delved. Take the Mark of Rallos Zek back to Dyrginal — but do not click it until you are ready to meet what answers.")
  else
    item_lib.return_items(e.self, e.other, e.trade)
  end
end
