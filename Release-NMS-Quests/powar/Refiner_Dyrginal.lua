-- powar: Refiner Dyrginal — the Mark of Rallos Zek chain
-- (PoP-ized: the Grungy Object/Symbol/Mark detour is collapsed; Krepp's
-- tagging trial uses Narikor Tin Ore as proof of delving.)
local P = require("powar_shared")
local item_lib = require("items")

local DIRT_ORE = 67994    -- Dirt Covered Ore (a greedy miner)
local GEM = 67996         -- Shining Gem of Striking (a mindless miner)
local MARKER = 86232      -- Krepp's Tagging Marker
local MARK = 67999        -- Mark of Rallos Zek

function event_say(e)
  local c = e.other
  if e.message:findi("hail") then
    if P.flagged(c, "dyrginal") then
      P.say(e, "The Mark's champion. War walks with you, friend.")
    elseif P.flagged(c, "dyrg_mark") then
      P.say(e, "Krepp holds your measure. When he has finished his auguries, bring me word of it.")
    elseif P.flagged(c, "dyrg_symbol") then
      P.say(e, "Krepp the Augurer delves deeper in the tunnels — take him what the mines have taught you. Three shining gems and a word from me: the tunnels south of here hide more than ore.")
    else
      P.say(e, "I refine what the mines tear loose. Say 'refine' if you would carry the Mark of Rallos Zek.")
    end
  elseif e.message:findi("refine") and not P.flagged(c, "dyrginal") then
    P.set(c, "dyrg_started", "1")
    P.say(e, "Then delve. A greedy miner squats deeper in these tunnels — kill him and bring me the ore on his cart.")
  elseif e.message:findi("challenge") and P.flagged(c, "dyrg_marked") and not P.flagged(c, "legion_up") then
    P.set(c, "legion_up", "1")
    local x, y, z = e.other:GetX(), e.other:GetY(), e.other:GetZ()
    eq.unique_spawn(P.NPC.legionnaire, 0, 0, x + 10, y + 10, z, 0)
    eq.zone_emote(15, "The Mark of Rallos Zek ignites in a furnace-wind. A furious legionnaire answers!")
  end
end

function event_trade(e)
  local c = e.other
  if item_lib.check_turn_in(e.trade, { item1 = DIRT_ORE }) then
    P.set(c, "dyrg_symbol", "1")
    P.say(e, "Dirty, heavy, real. Krepp the Augurer can read the seams in it — he camps the dead end down the south tunnel. Bring him three Shining Gems of Striking and what I have taught you; the mindless miners carry the gems.")
  elseif item_lib.check_turn_in(e.trade, { item1 = MARK }) then
    P.set(c, "dyrg_marked", "1")
    P.say(e, "So Krepp has weighed you. Very well — say 'challenge' when you are ready to meet what the Mark calls.")
  else
    item_lib.return_items(e.self, e.other, e.trade)
  end
end
