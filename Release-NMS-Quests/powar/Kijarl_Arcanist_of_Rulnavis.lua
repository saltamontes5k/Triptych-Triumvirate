-- powar: Kijarl, Arcanist of Rulnavis — lights the library
local P = require("powar_shared")
local item_lib = require("items")

local IGNITOR = 86230 -- Arcanist's Ignitor

function event_say(e)
  local c = e.other
  if e.message:findi("hail") then
    if tonumber(P.get(c, "ugor_stage")) == 4 or P.flagged(c, "colonel") then
      P.say(e, "The library burns blue and no one can prove whose spell it was. Araneae is furious — find her upstairs if you enjoy being clever at.")
    else
      P.say(e, "I am the arcanist of this castle. My spellbooks are in order, my lines are warded, and my opinions are my own.")
    end
  end
end

function event_trade(e)
  local c = e.other
  if item_lib.check_turn_in(e.trade, { item1 = IGNITOR }) then
    P.set(c, "ugor_stage", "4")
    e.other:SummonItem(IGNITOR) -- returns it; the ignition is the work
    e.self:Emote("turns the ignitor over, reads the ogre-script, and laughs for a long time.")
    P.say(e, "Ugor's hand in this, and Tamrel's wax on the seal. Very well - the library is lit. Araneae the Clever will be upstairs pretending it was her idea. Take your ignitor back; it has done its work.")
  else
    item_lib.return_items(e.self, e.other, e.trade)
  end
end
