-- Vayla_the_Magus (491251) -- Convorteum v1, stage 6 (second sister).
-- Tracked source: Release-NMS-Quests/convorteum/491251.lua.
-- Rasper: miscRaidProg.html.
--
-- Vayla works the cold: every 20s an icelance on a random raider (6k) and
-- every 45s a frost ring (5k AE, 200 range). Signals the controller (2006).

local prog = require("uf_progression")

local CTRL = prog.NPC.conv_ctrl

local engaged = false

local function engage(e)
	if engaged then return end
	engaged = true
	eq.set_timer("icelance", 20000)
	eq.set_timer("ring", 45000)
	eq.zone_emote(15, "Vayla breathes out winter. 'We sing in three parts.'")
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
			for _, t in ipairs({ "icelance", "ring" }) do eq.stop_timer(t) end
			e.self:Heal()
			eq.zone_emote(15, "Vayla's winter melts away. The event has reset.")
		end
		return
	end
	if not engaged then return end
	local x, y = e.self:GetX(), e.self:GetY()

	if e.timer == "icelance" then
		local targets = prog.alive_clients(x, y, 300)
		if #targets > 0 then
			local victim = targets[math.random(#targets)]
			eq.zone_emote(13, "Vayla's icelance impales " .. victim:GetCleanName() .. "!")
			victim:Damage(e.self, 6000, 0, 8)
		end
	elseif e.timer == "ring" then
		eq.zone_emote(13, "Vayla spins a ring of frost!")
		for _, c in ipairs(prog.alive_clients(x, y, 200)) do
			c:Damage(e.self, 5000, 0, 8)
		end
	end
end

function event_death_complete(e)
	for _, t in ipairs({ "icelance", "ring" }) do eq.stop_timer(t) end
	eq.zone_emote(15, "Vayla shatters. One voice remains.")
	eq.signal(CTRL, 2006)
end
