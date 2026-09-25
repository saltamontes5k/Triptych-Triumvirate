-- Wayfarer Porter: sends proven adventurers to the South Ro (3.0) LDoN camp
local prog = require("nms_progression")

function event_say(e)
  if not prog.gate_stage(e.other, "DoN", "The Wayfarer Porter says, 'I cannot send you there yet. Prove yourself against the elemental gods of the planes first.'") then
    return
  end
  if e.message:findi("hail") then
    eq.get_entity_list():MessageClose(e.self, true, 100, MT.SayEcho, "The Wayfarer Porter says, 'The southern ruins hold an older camp. I can send you there, if you are [" .. eq.say_link("ready") .. "].'")
  elseif e.message:findi("ready") then
    e.other:MovePC(393, -273, -141, 107, 0) -- Zone: southro
  end
end
