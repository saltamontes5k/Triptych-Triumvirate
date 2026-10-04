-- Guardian_of_Vibration (485221) -- Arthicrex v1, Hive Guardians event.
-- Tracked source: Release-NMS-Quests/arthicrex/485221.lua.
-- Rasper: miscRaidProg.html.
--
-- Resonance pulse every 25s (5k AE, 200 range) and a hard stun pulse
-- every 60s (emote + 2k on random target). Signals the controller (1102).

local prog = require("uf_progression")

local CTRL = prog.NPC.hive_ctrl

local engaged = false

local function engage(e)
	if engaged then return end
	engaged = true
	eq.set_timer("pulse", 25000)
	eq.set_timer("resonance", 60000)
	eq.zone_emote(15, "The Guardian of Vibration begins to hum -- the walls shiver!")
end

function event_combat(e)
	if e.joined then
		engage(e)
		eq.stop_timer("resetcheck")
	else
		eq.set_timer("resetcheck", 60000)
	end
end

function event_timer(e)
	if e.timer == "resetcheck" then
		if not e.self:IsEngaged() then
			engaged = false
			for _, t in ipairs({ "pulse", "resonance" }) do eq.stop_timer(t) end
			e.self:Heal()
			eq.zone_emote(15, "The Guardian of Vibration stills. The event has reset.")
		end
		return
	end
	if not engaged then return end
	local x, y = e.self:GetX(), e.self:GetY()

	if e.timer == "pulse" then
		eq.zone_emote(13, "A resonance pulse shakes the brood galleries!")
		for _, c in ipairs(prog.alive_clients(x, y, 200)) do
			c:Damage(e.self, 5000, 0, 28)
		end
	elseif e.timer == "resonance" then
		local targets = prog.alive_clients(x, y, 250)
		if #targets > 0 then
			local victim = targets[math.random(#targets)]
			eq.zone_emote(13, victim:GetCleanName() .. " is caught by a hard resonance and stunned!")
			victim:Damage(e.self, 2000, 0, 28)
			victim:Stun(3000)
		end
	end
end

function event_death_complete(e)
	for _, t in ipairs({ "pulse", "resonance" }) do eq.stop_timer(t) end
	eq.zone_emote(15, "The Guardian of Vibration cracks and falls silent.")
	eq.signal(CTRL, 1102)
end
