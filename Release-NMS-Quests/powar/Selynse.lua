-- powar: Selynse — black powder, barrels and the last pledge
local P = require("powar_shared")
local item_lib = require("items")

local NOTE = 97477            -- Secret Note to Selynse
local POWDER = 97489          -- Selynse's Black Powder
local RING = 97490            -- Narikor Guardian's Ring
local JOLRIS_NOTE = 97491     -- Selynse's Note to Jolris
local CLOAK = 97487           -- Narikor Forge Insignia Cloak
local EMPTY_BARREL = 97493    -- Empty Narikor Barrel
local PLEDGE = 97494          -- Selynse's Pledge of Support
local CALL_TO_ARMS = 97498    -- Katka's Call to Arms
local EXPLOSIVE = 97499       -- Explosive Narikor Barrel

function event_say(e)
  local c = e.other
  if e.message:findi("hail") then
    if P.flagged(c, "katka") then
      P.say(e, "The powder worked. The wall between the mines rang like a bell, they say.")
    elseif P.get(c, "katka_started") then
      P.say(e, "Katka's notes travel fast. Show me what you carry, surface-dweller, and we will see what you are worth.")
    else
      P.say(e, "Keep your voice down. The foremen listen.")
    end
  end
end

function event_trade(e)
  local c = e.other
  if item_lib.check_turn_in(e.trade, { item1 = NOTE }) then
    e.other:SummonItem(POWDER)
    P.say(e, "Black powder, kept dry through three beatings. It has one purpose. A slaver captain wears a ring worth more than his rank — dust a guardian or taskmaster with the powder and the captain will come running to claim the corpse.")
  elseif item_lib.check_turn_in(e.trade, { item1 = POWDER, item2 = RING }) then
    e.other:SummonItem(JOLRIS_NOTE)
    P.say(e, "The captain's ring — that buys a barrel. Cooper Jolris works the first crossroads down from the zone-in; my note will open his mouth.")
  elseif item_lib.check_turn_in(e.trade, { item1 = CLOAK, item2 = EMPTY_BARREL }) then
    e.other:SummonItem(PLEDGE)
    P.say(e, "A forge cloak and a dry barrel — Bolgorn trusts you, so I do. Tell Katka the mines of Narikor stand with her.")
  elseif item_lib.check_turn_in(e.trade, { item1 = CALL_TO_ARMS }) then
    e.other:SummonItem(EXPLOSIVE)
    P.say(e, "This barrel is mostly powder and spite. Take it to Bolgorn at the forges near the zone-in — stand clear when he lights it, and take the tokens of honor from whatever the blast drags out of the walls.")
  else
    item_lib.return_items(e.self, e.other, e.trade)
  end
end
