-- powar: Alchemist Veryon — draws the Potion of Valorous Battle
local P = require("powar_shared")
local item_lib = require("items")

local ALCHEMY_REQ = 97424
local POTION = 97425

function event_say(e)
  local c = e.other
  if e.message:findi("hail") then
    P.say(e, "Veryon the gnome does not look up from her mortar. 'If it bleeds, I can brew for it. Dulkot's requisitions go through me.'")
  end
end

function event_trade(e)
  local c = e.other
  if item_lib.check_turn_in(e.trade, { item1 = ALCHEMY_REQ }) then
    e.other:SummonItem(POTION)
    P.say(e, "One Potion of Valorous Battle - drink it in the field and the reports write themselves, or so the sergeants claim. Dulkot takes the pages; the ledger does the rest.")
  else
    item_lib.return_items(e.self, e.other, e.trade)
  end
end
