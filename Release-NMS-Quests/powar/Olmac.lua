-- powar: Olmac — Rulnavis blacksmith
local P = require("powar_shared")
local item_lib = require("items")

local BSMITH_WO = 97450
local ARMOR_BAG = 97452
local ARMOR_PIECES = 97453
local ARMOR_FILLED = 97454
local SWORD_BAG = 97455
local SWORD_PIECES = 97456
local SWORD_FILLED = 97457
local BSMITH_UPD = 97458
local REQUISITION = 97464
local HARDENED = 97501

function event_say(e)
  local c = e.other
  if e.message:findi("hail") then
    P.say(e, "Olmac the smith grunts without pausing at the grindstone. 'Work orders to Olmac. Everything else to everyone else.'")
  end
end

function event_trade(e)
  local c = e.other
  if item_lib.check_turn_in(e.trade, { item1 = BSMITH_WO }) then
    e.other:SummonItem(SWORD_BAG)
    e.other:SummonItem(ARMOR_BAG)
    P.say(e, "Galben's hand. Tamrelian steel and armor - the field trash sheds it by the pound. Ten pieces to a bag, sword pieces in the sword bag, armor pieces in the armor bag. Filled bags come back here.")
  elseif c:HasItem(SWORD_BAG) and item_lib.check_turn_in(e.trade, { item1 = SWORD_PIECES, item2 = SWORD_PIECES, item3 = SWORD_PIECES }) then
    local n = (tonumber(P.get(c, "olmac_sword")) or 0) + 3
    if n >= 10 then
      c:RemoveItem(SWORD_BAG, 1)
      P.set(c, "olmac_sword", "0")
      e.other:SummonItem(SWORD_FILLED)
      P.say(e, "Sword bag filled. The armor bag waits.")
    else
      P.set(c, "olmac_sword", tostring(n))
      P.say(e, "Sword pieces: " .. n .. " of 10.")
    end
  elseif c:HasItem(ARMOR_BAG) and item_lib.check_turn_in(e.trade, { item1 = ARMOR_PIECES, item2 = ARMOR_PIECES, item3 = ARMOR_PIECES }) then
    local n = (tonumber(P.get(c, "olmac_armor")) or 0) + 3
    if n >= 10 then
      c:RemoveItem(ARMOR_BAG, 1)
      P.set(c, "olmac_armor", "0")
      e.other:SummonItem(ARMOR_FILLED)
      P.say(e, "Armor bag filled. Both filled bags to me, and the order is updated.")
    else
      P.set(c, "olmac_armor", tostring(n))
      P.say(e, "Armor pieces: " .. n .. " of 10.")
    end
  elseif item_lib.check_turn_in(e.trade, { item1 = SWORD_FILLED, item2 = ARMOR_FILLED }) then
    e.other:SummonItem(BSMITH_UPD)
    P.say(e, "Ten swords' worth and ten suits' worth, remade honest. The Updated Blacksmith's Work Order - Galben's desk, then the blessing.")
  elseif item_lib.check_turn_in(e.trade, { item1 = REQUISITION }) then
    e.other:SummonItem(HARDENED)
    P.say(e, "The Hardened Rulnavian Sword - Rulnavis steel, Rulnavis temper. Bring it to Squelniss with the Blessed Entreaty and do not drop it in the fire.")
  else
    item_lib.return_items(e.self, e.other, e.trade)
  end
end
