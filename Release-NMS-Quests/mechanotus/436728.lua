-- Bloodwolf (436728) -- Lost Lumpling (300034) tracker spirit.
-- Simplified escort: staged hails. Hail 1 -> hunters and spiderlings fall
-- on the trail; hail 2 -> he sniffs out the truculent ooze's hut; hail 3
-- -> he marks the trail at an end (players continue via the gardener).
local fort = require("sof_fortress")

local function stage(e)
	return tonumber(e.self:GetEntityVariable("stage") or "0") or 0
end

function event_say(e)
	if not e.other:IsTaskActive(fort.TASK_LUMPLING) then
		e.self:Say("The wolf spirit tilts its head at you, uninterested.")
		return
	end
	local s = stage(e)
	if s == 0 then
		e.self:SetEntityVariable("stage", "1")
		e.self:Say("*snf* *snf* ... Be wary. I smell trouble.")
		eq.zone_emote(15, "Steamwork hunters crash through the hedges!")
		local x, y, z = e.self:GetX(), e.self:GetY(), e.self:GetZ()
		fort.spawn_add(fort.NPC.hunter, x + 30, y, z, e.other)
		fort.spawn_add(fort.NPC.hunter, x - 30, y, z, e.other)
	elseif s == 1 then
		e.self:SetEntityVariable("stage", "2")
		e.self:Say("*snf* ... The scent runs cold here. Something else "
			.. "overpowers it. That hut. The stink of the ooze.")
		eq.spawn2(fort.NPC.ooze, 0, 0, e.self:GetX() + 40, e.self:GetY(), e.self:GetZ(), 0)
		eq.zone_emote(15, "A truculent ooze heaves out of the muck!")
	else
		e.self:Say("The trail ends past the gardener's rounds. Ask his "
			.. "machines about Lumpling. *whines*")
	end
end
