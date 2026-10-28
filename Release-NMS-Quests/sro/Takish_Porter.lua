-- Takish Porter: sends proven adventurers to the Ruins of Takish-Hiz (Prophecy of Ro)
local prog = require("nms_progression")

function event_say(e)
  if not prog.gate_stage(e.other, "PoR", "The Takish Porter says, 'The elven ruins of Takish-Hiz are sealed to those who have not walked the Prophetic path. Return when the prophecy calls you.'") then
    return
  end
  if e.message:findi("hail") then
    eq.get_entity_list():MessageClose(e.self, true, 100, MT.SayEcho, "The Takish Porter says, 'The ancient elven ruins lie buried in the far sands. I can send you to their [" .. eq.say_link("ruins") .. "], if you are ready.'")
  elseif e.message:findi("ruins") or e.message:findi("ready") then
    e.other:MovePC(376, -1030, 100, 42, 0) -- Zone: takishruins
  end
end
