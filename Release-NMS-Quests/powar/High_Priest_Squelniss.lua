-- powar: High Priest Squelniss — blesses the Rulnavian blade
local P = require("powar_shared")
local item_lib = require("items")

local ENTREATY = 97465     -- Blessed Entreaty
local HARDENED = 97501     -- Hardened Rulnavian Sword
local BLESSED = 97466      -- Blessed Rulnavian Sword

function event_say(e)
  local c = e.other
  if e.message:findi("hail") then
    P.say(e, "Squelniss, High Priest of the Rulnavis war-rites, raises a finger for silence. 'Blessings are queued. Steel is not. Bring both and skip the queue.'")
  end
end

function event_trade(e)
  local c = e.other
  if item_lib.check_turn_in(e.trade, { item1 = ENTREATY, item2 = HARDENED }) then
    e.other:SummonItem(BLESSED)
    P.say(e, "The entreaty burns, the steel drinks it, and the sword wakes angry. The Blessed Rulnavian Sword - click it at a Zekarian Colossus in the Field of Blood and it will pick the fight for you. Kill the beast, keep the Body, and carry both to Troopmaster Gurkan.")
  else
    item_lib.return_items(e.self, e.other, e.trade)
  end
end
