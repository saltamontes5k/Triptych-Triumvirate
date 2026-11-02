-- powar: Captain Dulkot — Castle Rulnavis recruiter and quartermaster
-- Vallon Soldier Insignia turn-ins build Rulnavis standing; the Defending
-- the Castle requisition chain starts here.
local P = require("powar_shared")
local item_lib = require("items")

local VALLON_SOLDIER = 97422
local ALCHEMY_REQ = 97424
local LEDGER = 97423            -- Battle Report Ledger
local PAGE = 97426              -- Battle Report Page
local FILLED_LEDGER = 97427
local POTION = 97425            -- Potion of Valorous Battle
local FULL_BAG = 97433          -- Full Saboteur Evidence Bag
local LETTER = 97434            -- Letter to Gromluk

function event_say(e)
  local c = e.other
  local standing, label = P.standing(c, "rulnavis")
  if e.message:findi("hail") then
    if not P.flagged(c, "mines") then
      P.say(e, "Dulkot checks your hands for forge-grime. 'Rulnavis arms. The wall decides who enters its war.'")
    else
      P.say(e, "Captain Dulkot, of Castle Rulnavis. We fight the war the way it should be fought - with reports, requisitions, and powder. Your standing with Rulnavis: " .. label .. ". Insignias from the field trash earn it; say 'requisition' when you carry standing enough.")
    end
  elseif e.message:findi("requisition") then
    if standing >= 4 and not c:HasItem(ALCHEMY_REQ) and not c:HasItem(POTION) then
      e.other:SummonItem(ALCHEMY_REQ)
      P.say(e, "The alchemy requisition. Alchemist Veryon holds the south bend of the first floor - she will draw you the potion. Then fill the ledger: six Battle Report Pages fall from tamrelian and gindan trash out in the field. Bring me the filled ledger and the potion both.")
      if not c:HasItem(LEDGER) then e.other:SummonItem(LEDGER) end
    elseif standing < 4 then
      P.say(e, "Requisition lines are for soldiers. Earn standing first - insignias, from the field trash.")
    else
      P.say(e, "One requisition at a time, soldier.")
    end
  end
end

function event_trade(e)
  local c = e.other
  if not P.flagged(c, "mines") then
    item_lib.return_items(e.self, e.other, e.trade)
    return
  end
  if item_lib.check_turn_in(e.trade, { item1 = VALLON_SOLDIER }) then
    local v = P.fac_up(c, "rulnavis", 4)
    local _, lab = P.standing(c, "rulnavis")
    P.say(e, "Rulnavis notes the fallen. Standing: " .. lab .. ".")
  elseif item_lib.check_turn_in(e.trade, { item1 = PAGE, item2 = PAGE, item3 = PAGE }) and c:HasItem(LEDGER) then
    local n = (tonumber(P.get(c, "dulkot_pages")) or 0) + 3
    if n >= 6 then
      c:RemoveItem(LEDGER, 1)
      P.set(c, "dulkot_pages", "0")
      P.say(e, "Six pages, tucked and attested. The ledger fills itself in my hand - army magic, do not ask. Now: the potion and the filled ledger, together, when Veryon's brew is in your pack.")
    else
      P.set(c, "dulkot_pages", tostring(n))
      P.say(e, "Three more pages tucked into the ledger - " .. n .. " of 6. The field trash writes faster than they think.")
    end
  elseif item_lib.check_turn_in(e.trade, { item1 = FILLED_LEDGER, item2 = POTION }) then
    e.other:SummonItem(97428) -- Potion of Dubious Valor
    P.say(e, "Six pages of honest reporting and a potion to launder them through. Very well - take the Potion of Dubious Valor to Inquisitor Frellum, far southwest room. Sabotage is next, and sabotage is his parish.")
  elseif item_lib.check_turn_in(e.trade, { item1 = FULL_BAG }) then
    e.other:SummonItem(LETTER)
    P.say(e, "Four spy cloaks - enough saboteurs for anyone's parish. Take this letter to Strategist Gromluk, northwest room. The library is next, and the library is always next.")
  else
    item_lib.return_items(e.self, e.other, e.trade)
  end
end
