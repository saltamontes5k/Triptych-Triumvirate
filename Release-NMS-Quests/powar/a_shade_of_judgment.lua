-- powar: a shade of judgment (spawned by Bolgorn's powder bomb).
-- Drops a Token of Reclaimed Honor to whoever put it down.
local P = require("powar_shared")

function event_death(e)
  local top = P.top_client(e)
  if top then
    top:SummonItem(97500) -- Token of Reclaimed Honor
    top:Message(MT.NPCQuestSay, "The shade unravels, leaving a warm token on the stone.")
  end
end
