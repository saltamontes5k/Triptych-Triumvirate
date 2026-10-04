-- Guardian_of_Wax (485222) -- Arthicrex v1, Hive Guardians event.
-- Tracked source: Release-NMS-Quests/arthicrex/485222.lua.
-- Rasper: miscRaidProg.html.
--
-- Every 40s it waxes a random raider in place (root emote + 3k) and every
-- 30s throws a wax bolt (3k on random). Signals the controller (1103).

local prog = require("uf_progression")

local CTRL = prog.NPC.hive_ctrl

local engaged = false

local function engage(e)
	if engaged then return end
	engaged = true
	eq.set_timer("wax", 40000)
	eq.set_timer("bolt", 30000)
	eq.zone_emote(15, "The Guardian of_Wax slathers itself in hot hive wax!")
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
			for _, t in ipairs({ "wax", "bolt" }) do eq.stop_timer(t) end
			e.self:Heal()
			eq.zone_emote(15, "The Guardian of Wax cools and withdraws. The event has reset.")
		end
		return
	end
	if not engaged then return end
	local x, y = e.self:GetX(), e.self:GetY()

	if e.timer == "wax" then
		local targets = prog.alive_clients(x, y, 250)
		if #targets > 0 then
			local victim = targets[math.random(#targets)]
			eq.zone_emote(13, victim:GetCleanName() .. " is sealed in hardening hive wax!")
			victim:Damage(e.self, 3000, 0, 28)
			victim:Stun(5000)
		end
	elseif e.timer == "bolt" then
		local targets = prog.alive_clients(x, y, 250)
		if #targets > 0 then
			local victim = targets[math.random(#targets)]
			victim:Damage(e.self, 3000, 0, 28)
		end
	end
end

function event_death_complete(e)
	for _, t in ipairs({ "wax", "bolt" }) do eq.stop_timer(t) end
	eq.zone_emote(15, "The Guardian of Wax shatters into cooling shards.")
	eq.signal(CTRL, 1103)
end
