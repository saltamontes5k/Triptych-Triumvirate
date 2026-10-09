-- DoD Porter: sends proven adventurers to the Corathus Creep (Depths of Darkhollow hub).
local prog = require("nms_progression")

function event_say(e)
  if not prog.gate_stage(e.other, "DoD", "The DoD Porter says, 'The Depths of Darkhollow are not for the unproven. Track the Warlord and end Vishimtar the Fallen first.'") then
    return
  end
  if e.message:findi("hail") then
    eq.get_entity_list():MessageClose(e.self, true, 100, MT.SayEcho, "The DoD Porter says, 'The shissar tunnels of the Corathus Creep wind beneath the fungal dark. I can send you there, if you are [" .. eq.say_link("ready") .. "].'")

  elseif e.message:findi("ready") then
    e.other:MovePC(365, 16, -337, -46, 0) -- Zone: corathus (Corathus Creep)
  end
end
