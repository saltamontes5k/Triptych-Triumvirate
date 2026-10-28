-- powar: a slaver captain — wears the Narikor Guardian's Ring, loses it loudly.
local P = require("powar_shared")

function event_death(e)
  local top = P.top_client(e)
  if top then
    top:SummonItem(97490) -- Narikor Guardian's Ring
    top:Message(MT.NPCQuestSay, "The captain's hand comes free of the corpse it was claiming - with the ring still on it.")
  end
end

function event_spawn(e)
  e.self:Shout("BACK TO WORK! THIS CORPSE IS COMPANY PROPERTY!")
end
