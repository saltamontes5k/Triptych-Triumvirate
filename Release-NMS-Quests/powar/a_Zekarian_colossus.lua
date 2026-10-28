-- powar: a Zekarian colossus — drops the Body of the Colossus to its slayer
local P = require("powar_shared")

function event_death(e)
  local top = P.top_client(e)
  if top then
    top:SummonItem(97467) -- Body of the Colossus
    top:Message(MT.NPCQuestSay, "The colossus settles like a collapsing tower. Its body is yours - or the part that matters.")
  end
end
