-- powar: Forgetender Bolgorn — forge master of the Narikor forges
-- (PoP-ized: the anvil/forge click steps and the powder-bomb fuse live here.)
local P = require("powar_shared")
local item_lib = require("items")

local FULL_BUCKET = 97486    -- Filled Narikor Ore Bucket
local CLOAK = 97487          -- Narikor Forge Insignia Cloak
local EXPLOSIVE = 97499      -- Explosive Narikor Barrel
local SHADE = P.NPC.shade

local last_bomb = 0

function event_say(e)
  local c = e.other
  if e.message:findi("hail") then
    if P.flagged(c, "katka") then
      P.say(e, "The forges run hotter these days, and the overseers don't ask why. Good work, warbrand.")
    else
      P.say(e, "I forget what the overseers want forgotten. Bring iron and I will not forget you.")
    end
  end
end

function event_trade(e)
  local c = e.other
  if item_lib.check_turn_in(e.trade, { item1 = FULL_BUCKET }) then
    e.other:SummonItem(CLOAK)
    P.say(e, "Mickorn's iron, by the smell of the seam it came from. Here — the forge insignia cloak. Wear it back to him, and mind: the cloak gets around the forges, so keep it moving.")
  elseif item_lib.check_turn_in(e.trade, { item1 = EXPLOSIVE }) then
    if os.time() - last_bomb < 300 then
      item_lib.return_items(e.self, e.other, e.trade)
      P.say(e, "The forges are still shaking from the last barrel. Give the walls a few minutes to settle.")
      return
    end
    last_bomb = os.time()
    local x, y, z = e.self:GetX(), e.self:GetY(), e.self:GetZ()
    for i = 1, 4 do
      eq.unique_spawn(SHADE, 0, 0, x + (i % 2 == 0 and 15 or -15), y + (i > 2 and 15 or -15), z, 0)
    end
    eq.zone_emote(15, "The barrel cracks the forge-floor — four shades of judgment claw out of the stone!")
    P.say(e, "Stand back! When the shades come through, put them down — each one drops a token of reclaimed honor. Three of those tokens buy Katka's rebellion its omen. Take them to the Diviner by the zone-in.")
  else
    item_lib.return_items(e.self, e.other, e.trade)
  end
end
