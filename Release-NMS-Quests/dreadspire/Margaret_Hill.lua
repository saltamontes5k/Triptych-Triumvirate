-- dreadspire/Margaret_Hill.lua
-- Depths of Darkhollow: requests the Master Vule the Silent Tear expedition
-- (Dreadspire Keep, version 2). The static version-0 Vule is retained for
-- open-world play; the instance is what records the raid lockout.
-- Requires the Doorman's "Memories Lost" task (dodh.tasks.memories_lost).
local raids = require("dod_raids")
local dodh  = require("dodh_helper")

function event_say(e)
	if not e.other:GetGM() and not e.other:IsTaskCompleted(dodh.tasks.memories_lost) then
		e.self:Say("The way down to Master Vule is not for wanderers. The Doorman guards the descent - help him find his lost memories, and then we will talk.");
		return
	end
	raids.entry(e, "vule")
end
