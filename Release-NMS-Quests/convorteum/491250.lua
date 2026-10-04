-- Eldreth_the_Magus (491250) -- Convorteum v1, stage 6 (first sister).
-- Tracked source: Release-NMS-Quests/convorteum/491250.lua.
-- Rasper: miscRaidProg.html.
--
-- The Magus Sisters fight as three (491250/491251/491252); the stage
-- completes only when all three are dead. Eldreth hurls fire: every 20s
-- a firelance on a random raider (6k) and every 45s a fire ring (5k AE,
-- 200 range). Signals the controller (2006) on death.

local prog = require("uf_progression")

local CTRL = prog.NPC.conv_ctrl

local engaged = false

local function engage(e)
	if engaged then return end
	engaged = true
	eq.set_timer("firelance", 20000)
	eq.set_timer("ring", 45000)
	eq.zone_emote(15, "Eldreth smiles. 'Sisters -- they brought friends for us.'")
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
			for _, t in ipairs({ "firelance", "ring" }) do eq.stop_timer(t) end
			e.self:Heal()
			eq.zone_emote(15, "Eldreth draws her fire back in. The event has reset.")
		end
		return
	end
	if not engaged then return end
	local x, y = e.self:GetX(), e.self:GetY()

	if e.timer == "firelance" then
		local targets = prog.alive_clients(x, y, 300)
		if #targets > 0 then
			local victim = targets[math.random(#targets)]
			eq.zone_emote(13, "Eldreth's firelance skewers " .. victim:GetCleanName() .. "!")
			victim:Damage(e.self, 6000, 0, 2)
		end
	elseif e.timer == "ring" then
		eq.zone_emote(13, "Eldreth spins a ring of fire!")
		for _, c in ipairs(prog.alive_clients(x, y, 200)) do
			c:Damage(e.self, 5000, 0, 2)
		end
	end
end

function event_death_complete(e)
	for _, t in ipairs({ "firelance", "ring" }) do eq.stop_timer(t) end
	eq.zone_emote(15, "Eldreth falls. Her sisters' songs falter.")
	eq.signal(CTRL, 2006)
end
