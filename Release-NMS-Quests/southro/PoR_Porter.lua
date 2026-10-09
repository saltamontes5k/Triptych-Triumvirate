-- PoR Porter: sends proven adventurers to the Ruins of Takish-Hiz (Prophecy of Ro hub).
local prog = require("nms_progression")

function event_say(e)
  if not prog.gate_stage(e.other, "PoR", "The PoR Porter says, 'The sands of Ro bury their secrets deep, and not for the unproven. Earn your way past the Darkhollow first.'") then
    return
  end
  if e.message:findi("hail") then
    eq.get_entity_list():MessageClose(e.self, true, 100, MT.SayEcho, "The PoR Porter says, 'The buried ruins of Takish-Hiz stir beneath the Ro desert sands. I can send you there, if you are [" .. eq.say_link("ready") .. "].'")

  elseif e.message:findi("ready") then
    e.other:MovePC(376, -983, 269, 62, 0) -- Zone: takishruins (Ruins of Takish-Hiz)
  end
end
