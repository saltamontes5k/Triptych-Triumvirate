-- powar: Edmuund the Bold — the final test of Edmuund's Plight.
-- Defeat credits the test's taker.
local P = require("powar_shared")

function event_death(e)
  local top = P.top_client(e)
  if top then
    P.set(top, "edmuund", "1")
    P.set(top, "edmuund_stage", "0")
    top:Message(MT.NPCQuestSay, "The Bold one kneels, laughing even as he falls. Somewhere, a giant names you worthy.")
    top:QuestReward(e.self, 0, 0, 0, 0, 0, 75000)
  end
end

function event_spawn(e)
  e.self:Shout("SO THIS IS THE WORTHY ONE! COME THEN — EDMEUND THE BOLD ACCEPTS!")
end
