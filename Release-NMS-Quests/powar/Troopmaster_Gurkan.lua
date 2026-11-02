-- powar: Troopmaster Gurkan — issues the Strategic Colossus and closes
-- A Colossal Task.
local P = require("powar_shared")
local item_lib = require("items")

local BLESSED = 97466      -- Blessed Rulnavian Sword
local BODY = 97467         -- Body of the Colossus
local NOTE = 97468         -- Note for High Strategist Galben
local COLOSSUS_REQ = 97470
local STRATEGIC = 97472    -- Strategic Colossus

function event_say(e)
  local c = e.other
  if e.message:findi("hail") then
    P.say(e, "Troopmaster Gurkan counts under his breath, always. 'Requisitions to the troopmaster. Corpses to the wall.'")
  end
end

function event_trade(e)
  local c = e.other
  if item_lib.check_turn_in(e.trade, { item1 = BLESSED, item2 = BODY }) then
    e.other:SummonItem(NOTE)
    P.say(e, "The blade that cracked it and the body it cracked - matched and receipted. Take the note to High Strategist Galben; he signs for the whole war, and today he signs for you.")
  elseif item_lib.check_turn_in(e.trade, { item1 = COLOSSUS_REQ }) then
    e.other:SummonItem(STRATEGIC)
    P.say(e, "The Strategic Colossus: a dead colossus, hollowed, and filled with our best orcs. Carry it to the shamanic resonances inside Castle Tamrel and hand it in at one - the orcs will walk the rest. Do not name them. They like it.")
  else
    item_lib.return_items(e.self, e.other, e.trade)
  end
end
