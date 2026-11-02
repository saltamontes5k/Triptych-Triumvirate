-- powar: a Tamrelian infiltrator (spawned by Frellum's wine trap).
-- Drops a Tamrelian Spy Cloak to whoever put it down.
local P = require("powar_shared")

function event_death(e)
  local top = P.top_client(e)
  if top then
    top:SummonItem(97430) -- Tamrelian Spy Cloak
    top:Message(MT.NPCQuestSay, "The infiltrator drops, cloak and all.")
  end
end
