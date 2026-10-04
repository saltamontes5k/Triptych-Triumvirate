-- Guardian_of_Venom (485220) -- Arthicrex v1, Hive Guardians event.
-- Tracked source: Release-NMS-Quests/arthicrex/485220.lua.
-- Rasper: miscRaidProg.html.
--
-- Poison breath every 30s (4k AE + poison DoT emote, 200 range). Signals
-- the Hive_Controller (1101) on death; the controller pays the lockout,
-- spawns the chest and flags the raid when all four guardians are dead.

local prog = require("uf_progression")

local CTRL = prog.NPC.hive_ctrl

local engaged = false

local function engage(e)
	if engaged then return end
	engaged = true
	eq.set_timer("venom", 30000)
	eq.zone_emote(15, "The Guardian of Venom rears, dripping corroding ichor!")
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
			eq.stop_timer("venom")
			e.self:Heal()
			eq.zone_emote(15, "The Guardian of Venom withdraws to its gallery. The event has reset.")
		end
		return
	end
	if not engaged then return end
	if e.timer == "venom" then
		eq.zone_emote(13, "The Guardian of Venom sprays corroding ichor!")
		for _, c in ipairs(prog.alive_clients(e.self:GetX(), e.self:GetY(), 200)) do
			c:Damage(e.self, 4000, 0, 12)
		end
	end
end

function event_death_complete(e)
	eq.stop_timer("venom")
	eq.zone_emote(15, "The Guardian of Venom bursts, ichor hissing into steam.")
	eq.signal(CTRL, 1101)
end
