-- powar: Inquisitor Frellum — the wine-cask saboteur trap
-- (PoP-ized: hand the cask back to plant it; two infiltrators come to see
-- who is drinking Rulnavis wine on the enemy's coin.)
local P = require("powar_shared")
local item_lib = require("items")

local POTION = 97428          -- Potion of Dubious Valor
local CASK = 97429            -- Tempting Wine Cask
local BAG = 97432             -- Saboteur Evidence Bag
local CLOAK = 97430           -- Tamrelian Spy Cloak
local FULL_BAG = 97433

local last_plant = 0

function event_say(e)
  local c = e.other
  local standing, label = P.standing(c, "rulnavis")
  if e.message:findi("hail") then
    if standing >= 10 then
      P.say(e, "Frellum the ogre inquisitor smiles the way a portcullis smiles. 'Sabotage is honesty with better timing. Dulkot's potion bought you my ear - standing " .. label .. " - so here is the parish: the wine cask. Set it where the thirsty crawl.'")
    else
      P.say(e, "Frellum sniffs. 'Come back when Rulnavis knows your name.'")
    end
  end
end

function event_trade(e)
  local c = e.other
  local standing = (tonumber(P.get(c, "rulnavis_fac")) or 0)
  if item_lib.check_turn_in(e.trade, { item1 = POTION }) and standing >= 10 then
    e.other:SummonItem(CASK)
    e.other:SummonItem(BAG)
    P.say(e, "The Potion of Dubious Valor, and in exchange: a Tempting Wine Cask and an evidence bag. Hand the cask back to me when you are ready - I will plant it in the next room, and the Tamrel spies will come to drink. Kill them, take the spy cloaks; four cloaks in the bag and the parish is served.")
  elseif item_lib.check_turn_in(e.trade, { item1 = CASK }) and c:HasItem(BAG) then
    if os.time() - last_plant < 300 then
      item_lib.return_items(e.self, e.other, e.trade)
      P.say(e, "The last cask is still wet. Patience.")
      return
    end
    last_plant = os.time()
    local x, y, z = e.self:GetX(), e.self:GetY(), e.self:GetZ()
    eq.unique_spawn(P.NPC.infiltrator, 0, 0, x + 25, y, z, 0)
    eq.unique_spawn(P.NPC.infiltrator, 0, 0, x - 25, y, z, 0)
    e.self:Emote("plants the cask against the wall, taps it twice, and strolls away.")
    eq.zone_emote(15, "Somewhere near the castle, a Tamrelian spy smells free wine...")
    P.say(e, "Planted. Two usually come - kill them both, and if the walls cough up a third, the bag will not complain. Four cloaks to the bag, then back to Dulkot.")
  elseif item_lib.check_turn_in(e.trade, { item1 = CLOAK, item2 = CLOAK, item3 = CLOAK, item4 = CLOAK }) and c:HasItem(BAG) then
    c:RemoveItem(BAG, 1)
    e.other:SummonItem(FULL_BAG)
    P.say(e, "Four cloaks, four liars, one full bag. Dulkot pays for evidence - take it to him.")
  else
    item_lib.return_items(e.self, e.other, e.trade)
  end
end
