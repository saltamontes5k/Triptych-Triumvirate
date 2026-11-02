-- powar: Mickorn — bucket, pick and the third pledge
-- (PoP-ized: the ore-bucket fill is done here instead of clicking the pick
-- on rocks; the mines cough up plenty of iron.)
local P = require("powar_shared")
local item_lib = require("items")

local NOTE = 97476           -- Secret Note to Mickorn
local BUCKET = 97483         -- Narikor Ore Bucket
local PICK = 97482           -- Narikor Rock Pick
local ORE = 97484            -- Narikor Iron Ore
local FULL_BUCKET = 97486    -- Filled Narikor Ore Bucket
local CLOAK = 97487          -- Narikor Forge Insignia Cloak
local PLEDGE = 97488         -- Mickorn's Pledge of Support

function event_say(e)
  local c = e.other
  if e.message:findi("hail") then
    if P.flagged(c, "katka") then
      P.say(e, "Free hands, finally.")
    elseif P.get(c, "katka_started") then
      P.say(e, "Mickorn digs. Mickorn fills. Show me the note.")
    else
      P.say(e, "Mind the shaft. It minds no one.")
    end
  end
end

function event_trade(e)
  local c = e.other
  if item_lib.check_turn_in(e.trade, { item1 = NOTE }) then
    e.other:SummonItem(BUCKET)
    e.other:SummonItem(PICK)
    P.say(e, "A bucket and a pick — the overseers' own tools, slipped past their own eyes. Fill the bucket with Narikor iron, ten chunks of it, and bring both back. The iron goes to the forge, the pick goes to Katka.")
  elseif item_lib.check_turn_in(e.trade, { item1 = BUCKET, item2 = ORE, item3 = ORE, item4 = ORE }) then
    e.other:SummonItem(FULL_BUCKET)
    P.say(e, "Heavy enough to be honest. Take this filled bucket to Forgetender Bolgorn at the forges near the zone-in — he will know what a full bucket from me means.")
  elseif item_lib.check_turn_in(e.trade, { item1 = PICK, item2 = CLOAK }) then
    e.other:SummonItem(PLEDGE)
    e.other:SummonItem(CLOAK)
    P.say(e, "The pick is Katka's now, and so is my word. Take the cloak back — Bolgorn's colors are still wanted at the forges. Tell Katka: Mickorn digs with her.")
  else
    item_lib.return_items(e.self, e.other, e.trade)
  end
end
