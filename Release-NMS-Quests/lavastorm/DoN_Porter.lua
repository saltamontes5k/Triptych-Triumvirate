-- DoN Porter: sends proven adventurers to the Broodlands (Dragons of Norrath hub).
-- The DoN-era Lavastorm camp shelf / Broodlands zone line does not exist on the
-- base client map, so this provides the access instead.
local prog = require("nms_progression")

function event_say(e)
  if not prog.gate_stage(e.other, "DoN", "The DoN Porter says, 'The Broodlands are not for the unproven. Topple the elemental gods of the planes first.'") then
    return
  end
  if e.message:findi("hail") then
    eq.get_entity_list():MessageClose(e.self, true, 100, MT.SayEcho, "The DoN Porter says, 'The dragons' broodlands lie beyond these burning hills. I can send you there, if you are [" .. eq.say_link("ready") .. "].'")
  elseif e.message:findi("ready") then
    e.other:MovePC(337, -1613, -1016, 99, 0) -- Zone: broodlands
  end
end
