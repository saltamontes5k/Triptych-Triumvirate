-- TSS Porter: sends proven adventurers to Blightfire Moors (The Serpent's Spine hub).
local prog = require("nms_progression")

function event_say(e)
  if not prog.gate_stage(e.other, "TSS", "The TSS Porter says, 'The Serpent's Spine is not for the unproven. Break the Deathknell first.'") then
    return
  end
  if e.message:findi("hail") then
    eq.get_entity_list():MessageClose(e.self, true, 100, MT.SayEcho, "The TSS Porter says, 'Blightfire Moors smolders beyond the barrier ridge, where the himodo huddle against the blackfog. I can send you there, if you are [" .. eq.say_link("ready") .. "].'")

  elseif e.message:findi("ready") then
    e.other:MovePC(395, 3263, -626, -20, 0) -- Zone: moors (Blightfire Moors)
  end
end
