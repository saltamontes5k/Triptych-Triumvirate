-- powar: Sorayn — strings the necklace of teeth, gives the second pledge
-- (PoP-ized: the necklace combine is done here instead of on a tradeskill,
-- and takes three teeth rather than ten — the hands are the same.)
local P = require("powar_shared")
local item_lib = require("items")

local NOTE = 97475           -- Secret Note to Sorayn
local CHAIN = 97478          -- Sorayn's Necklace Chain
local TOOTH = 97479          -- Narikor Guard's Tooth
local NECKLACE = 97480       -- Necklace of Narikor Teeth
local PLEDGE = 97481         -- Sorayn's Pledge of Support

function event_say(e)
  local c = e.other
  if e.message:findi("hail") then
    if P.flagged(c, "katka") then
      P.say(e, "Rebellion looks well on you.")
    elseif P.get(c, "katka_started") then
      P.say(e, "Sorayn watches. Sorayn measures. Bring the note Katka gave you and we will measure you too.")
    else
      P.say(e, "The dark is safer than the lamps. Remember that.")
    end
  end
end

function event_trade(e)
  local c = e.other
  if item_lib.check_turn_in(e.trade, { item1 = NOTE }) then
    e.other:SummonItem(CHAIN)
    P.say(e, "A chain for a trophy. The taskmasters and guardians wear the teeth I want — bring me three, and I will string them into a necklace the whole mine can see.")
  elseif item_lib.check_turn_in(e.trade, { item1 = CHAIN, item2 = TOOTH, item3 = TOOTH, item4 = TOOTH }) then
    e.other:SummonItem(NECKLACE)
    P.say(e, "Teeth on a chain. Wear it where the foremen can see it.")
  elseif item_lib.check_turn_in(e.trade, { item1 = NECKLACE }) then
    e.other:SummonItem(PLEDGE)
    P.say(e, "You strung the mine's hatred around your own neck. Sorayn stands with Katka — tell her so.")
  else
    item_lib.return_items(e.self, e.other, e.trade)
  end
end
