-- powar: Fletcher Forlen — Rulnavis bowyer
-- Sells the Stonewood Compound Bow (tithe-marked), fills the bowyer's work
-- order, and issues the Assault Bow.
local P = require("powar_shared")
local item_lib = require("items")

local BOWYER_WO = 97451
local WOODCUTTER = 97459
local TWINE = 97460
local KINDLING = 97461
local BUNDLE = 97462
local BOWYER_UPD = 97463
local BOW_REQ = 97471
local ASSAULT_BOW = 97473
local STONEWOOD_BOW = 29597

function event_say(e)
  local c = e.other
  if e.message:findi("hail") then
    P.say(e, "Fletcher Forlen, smallest soldier in the castle, best bowyer in the war. Work orders, requisitions - or, if you carry a sphinx's favor, I will string a Stonewood Compound Bow for three thousand platinum. Say 'stonewood'.")
  elseif e.message:findi("stonewood") then
    if P.flagged(c, "tithe_jus") then
      P.say(e, "Three thousand platinum, one Stonewood Compound Bow. Hand me the coin and mind the string - it bites.")
    else
      P.say(e, "The stonewood staves are spoken for, friend. Zayenaekk's favor - in the Plane of Justice - is the password.")
    end
  end
end

function event_trade(e)
  local c = e.other
  if item_lib.check_turn_in(e.trade, { platinum = 3000 }) and P.flagged(c, "tithe_jus") then
    e.other:SummonItem(STONEWOOD_BOW)
    P.say(e, "Paid. Stonewood, cams, string, spite - a bow worthy of the Field of Blood. The Zekarian Diamond does the rest, at Zayenaek's hands.")
  elseif item_lib.check_turn_in(e.trade, { item1 = BOWYER_WO }) then
    e.other:SummonItem(WOODCUTTER)
    e.other:SummonItem(TWINE)
    P.say(e, "The Rulnavian Woodcutter and the Kindling Twine. The Field of Blood grows strange trees - cut kindling from their trash by the fistful, ten chunks, twist them in the twine, and bring woodcutter and bundle back. Mind the Ykendan servants; they guard the trees.")
  elseif c:HasItem(TWINE) and item_lib.check_turn_in(e.trade, { item1 = KINDLING, item2 = KINDLING, item3 = KINDLING }) then
    local n = (tonumber(P.get(c, "forlen_kindling")) or 0) + 3
    if n >= 10 then
      c:RemoveItem(TWINE, 1)
      P.set(c, "forlen_kindling", "0")
      e.other:SummonItem(BUNDLE)
      P.say(e, "Ten chunks, one bundle. The woodcutter and the bundle come back to me together.")
    else
      P.set(c, "forlen_kindling", tostring(n))
      P.say(e, "Kindling: " .. n .. " of 10.")
    end
  elseif item_lib.check_turn_in(e.trade, { item1 = WOODCUTTER, item2 = BUNDLE }) then
    e.other:SummonItem(BOWYER_UPD)
    P.say(e, "Field of Blood kindling - burns green and angry, perfect for bow-curing. The Updated Bowyer's Work Order goes to Galben.")
  elseif item_lib.check_turn_in(e.trade, { item1 = BOW_REQ }) then
    e.other:SummonItem(ASSAULT_BOW)
    P.say(e, "The Assault Bow - Rulnavis' answer to walls. Click it at a Tamrelian wall defender and the arrow does the diplomacy. Eight defenders, Galben says. I say aim well.")
  else
    item_lib.return_items(e.self, e.other, e.trade)
  end
end
