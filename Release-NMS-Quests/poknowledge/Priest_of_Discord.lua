-- Priest_of_Discord (npc id 202534) - The Plane of Knowledge
-- Stands watch over the way to the Omens of War front. Offers passage to
-- Dranik's Scar once the account has finished the Omens of War progression
-- (OoW stage: Tunat`Muram Cuu Vauax in Tacvi) - see lua_modules/nms_progression.lua.
-- GM bypass comes from prog.gate_stage().

local prog = require("nms_progression")

local DENY = "Priest of Discord says, 'The war beyond the portal is not yours to fight yet. Return when you have broken the Overlord's champion.'"

function event_say(e)
  if prog.gate_stage(e.other, "OoW", DENY) then
    if e.message:findi("hail") then
      eq.get_entity_list():MessageClose(e.self, true, 100, MT.SayEcho, "Priest of Discord says, 'You have felt it, haven't you? The discord that gnaws at the edges of this world. I keep the gate to Dranik's Scar. Shall I send you [" .. eq.say_link("through") .. "]?'")
    elseif e.message:findi("through") or e.message:findi("dranik") then
      eq.get_entity_list():MessageClose(e.self, true, 100, MT.SayEcho, "Priest of Discord says, 'Then go. The muram await, and they do not wait patiently.'")
      e.other:MovePC(302, -1440, -1400, 224, 0) -- Zone: draniksscar (Dranik's Scar)
    end
  else
    if e.message:findi("hail") then
      eq.get_entity_list():MessageClose(e.self, true, 100, MT.SayEcho, "Priest of Discord says, 'You are not ready for the discord. Grow stronger, and the gate may yet open for you.'")
    end
  end
end
