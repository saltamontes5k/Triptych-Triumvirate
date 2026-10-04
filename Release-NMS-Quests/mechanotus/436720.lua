-- a clockwork spy (436720) -- Hunt a Spy (300029) target.
-- Simplified live chain: hail 1 -> it plays dead and ambushers drop in;
-- after they fall, hail 2 -> two mez-immune guardians spawn; after they
-- fall, hail 3 -> "yikes!" and the spy fights. Kill it, loot the box.
local fort = require("sof_fortress")

local function stage(e)
	return tonumber(e.self:GetEntityVariable("stage") or "0") or 0
end

function event_say(e)
	if not e.other:IsTaskActive(fort.TASK_HUNT_SPY) then
		e.self:Say("*whirrr* ... nothing to see here. Just a clockwork. "
			.. "Idling. Lovingly.")
		return
	end
	local s = stage(e)
	if s == 0 then
		e.self:SetEntityVariable("stage", "1")
		e.self:Say("*click* RETINUH— *whirr* —guard protocol... declining. "
			.. "I know nothing of Meldrath's spy nets—")
		e.self:Emote("collapses, playing dead.")
		eq.zone_emote(15, "Ambushers drop from the scaffolding!")
		local x, y, z = e.self:GetX(), e.self:GetY(), e.self:GetZ()
		fort.spawn_add(fort.NPC.ambusher, x + 20, y, z, e.other)
		fort.spawn_add(fort.NPC.ambusher, x - 20, y, z, e.other)
	elseif s == 1 then
		e.self:SetEntityVariable("stage", "2")
		e.self:Emote("twitches back to life, calculating escape vectors.")
		e.self:Say("FIRE! FIRE IN THE WIRE! Guardians, tend to the guests!")
		local x, y, z = e.self:GetX(), e.self:GetY(), e.self:GetZ()
		fort.spawn_add(fort.NPC.guardian, x + 25, y + 10, z, e.other)
		fort.spawn_add(fort.NPC.guardian, x - 25, y - 10, z, e.other)
	else
		e.self:Say("YIKES!")
		e.self:AddToHateList(e.other, 1000)
	end
end

function event_combat(e)
	if e.joined then
		e.self:SetRunning(true)
	else
		e.self:SetEntityVariable("stage", "2") -- resettable, still hostile on re-hail
	end
end

function event_death_complete(e)
	eq.zone_emote(15, "The clockwork spy clatters apart, its black box skittering free.")
end
