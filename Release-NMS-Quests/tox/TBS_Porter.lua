-- TBS Porter: sends proven adventurers to The Buried Sea (The Buried Sea hub).
local prog = require("nms_progression")

function event_say(e)
  if not prog.gate_stage(e.other, "TBS", "The TBS Porter says, 'The Buried Sea is not for the unproven. Cast down Dyn`leth first.'") then
    return
  end
  if e.message:findi("hail") then
    eq.get_entity_list():MessageClose(e.self, true, 100, MT.SayEcho, "The TBS Porter says, 'The drowned splendor of the Buried Sea waits beyond the mists of Toxxulia. I can send you there, if you are [" .. eq.say_link("ready") .. "].'")

  elseif e.message:findi("ready") then
    e.other:MovePC(423, 3130, -1721, 308, 0) -- Zone: buriedsea (The Buried Sea)
  end
end
