-- powar: Cooper Jolris — barrel-maker of the Narikor mines
-- (PoP-ized: the anvil click that hoops Barrel Bones into an empty barrel
-- is done here at his crossroads post.)
local P = require("powar_shared")
local item_lib = require("items")

local JOLRIS_NOTE = 97491    -- Selynse's Note to Jolris
local BARREL_BONES = 97492   -- Barrel Bones
local EMPTY_BARREL = 97493   -- Empty Narikor Barrel

function event_say(e)
  local c = e.other
  if e.message:findi("hail") then
    if P.flagged(c, "katka") then
      P.say(e, "Staves and hoops, free hands. The cooper's trade improves.")
    else
      P.say(e, "Barrels, staves, hoops. The mines run on barrels, and I run the barrels.")
    end
  end
end

function event_trade(e)
  local c = e.other
  if item_lib.check_turn_in(e.trade, { item1 = JOLRIS_NOTE }) then
    e.other:SummonItem(BARREL_BONES)
    P.say(e, "Selynse's hand in this, I see. Here — the bones of a barrel, all staves and no spine. A hoop and a hammer make it honest, and I have neither to spare. Take it to the forges and have Forgetender Bolgorn hoop it on his anvil.")
  elseif item_lib.check_turn_in(e.trade, { item1 = BARREL_BONES }) then
    e.other:SummonItem(EMPTY_BARREL)
    P.say(e, "Hooped and tarred — borrowed the hoop off Bolgorn's anvil while his back was turned. Don't ask what the barrel smells of. Back to Selynse with it.")
  else
    item_lib.return_items(e.self, e.other, e.trade)
  end
end
