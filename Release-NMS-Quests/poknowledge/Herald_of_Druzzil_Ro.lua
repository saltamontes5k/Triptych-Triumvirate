-- Herald_of_Druzzil_Ro (npc id 202425) - The Plane of Knowledge
-- Keeper of the way into the Plane of Time. Offers passage once the account has
-- finished the Seeds of Destruction progression (SoD stage: Kerafyrm in
-- Sleeper's Tomb and Kerafyrm in Crystallos) - see lua_modules/nms_progression.lua.
-- Also requires the character's Plane of Time zone flag, matching upstream.
-- GM bypass comes from prog.gate_stage().

local prog = require("nms_progression")

local DENY = "Herald of Druzzil Ro says, 'Time is not yet yours to walk. The discord must be silenced before the hourglass turns for you.'"

function event_say(e)
  if prog.gate_stage(e.other, "SoD", DENY) then
    if e.message:findi("hail") then
      e.self:Say("Oh, yes, I'm still of one mind, for now. Time, time is all that matters. Would you like to see the [" .. eq.say_link("time", false, "time") .. "]?")
    elseif e.message:findi("time") then
      if e.other:HasZoneFlag(219) then
        e.self:Say("Then step through. Do not stray from the path that is given to you.")
        e.other:MovePC(219, 110, 0, 8, 0) -- Zone: potimea (The Plane of Time)
      else
        e.self:Say("Your name is not written on this hour. Walk the path of Time's flagging before you ask me again.")
      end
    end
  else
    if e.message:findi("hail") then
      e.self:Say("Oh, yes, I'm still of one mind, for now. Time, time is all that matters... but the door is shut to you. Come back when the discord is undone.")
    end
  end
end
