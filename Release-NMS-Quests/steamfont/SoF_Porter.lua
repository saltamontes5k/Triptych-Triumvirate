-- SoF Porter: sends proven adventurers to Dragonscale Hills (Secrets of Faydwer hub).
local prog = require("nms_progression")

function event_say(e)
  if not prog.gate_stage(e.other, "SoF", "The SoF Porter says, 'Secrets of Faydwer are not for the unproven. Face Mayong Mistmoore and the Fire Lord first.'") then
    return
  end
  if e.message:findi("hail") then
    eq.get_entity_list():MessageClose(e.self, true, 100, MT.SayEcho, "The SoF Porter says, 'Dragonscale Hills hides its wondrous valley from plain sight. I can send you there, if you are [" .. eq.say_link("ready") .. "].'")

  elseif e.message:findi("ready") then
    e.other:MovePC(442, -1954, 3916, 19, 0) -- Zone: dragonscale (Dragonscale Hills)
  end
end
