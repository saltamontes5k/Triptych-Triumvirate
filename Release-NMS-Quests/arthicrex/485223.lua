-- Guardian_of_Eggs (485223) -- Arthicrex v1, Hive Guardians event.
-- Tracked source: Release-NMS-Quests/arthicrex/485223.lua.
-- Rasper: miscRaidProg.html.
--
-- Every 50s it spawns two broodlings (mezzable). Signals the controller
-- (1104) on death.

local prog = require("uf_progression")

local CTRL = prog.NPC.hive_ctrl
local BROODLING = 485231

local engaged = false
local adds = {}

local function engage(e)
	if engaged then return end
	engaged = true
	eq.set_timer("brood", 50000)
	eq.zone_emote(15, "The Guardian of Eggs settles over the clutch -- it means to hatch reinforcements!")
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
			eq.stop_timer("brood")
			prog.clear_adds(adds)
			adds = {}
			e.self:Heal()
			eq.zone_emote(15, "The Guardian of Eggs retreats to its clutch. The event has reset.")
		end
		return
	end
	if not engaged then return end

	if e.timer == "brood" then
		for i = 1, 2 do
			local m = eq.spawn2(BROODLING, 0, 0, e.self:GetX() + math.random(-40, 40),
				e.self:GetY() + math.random(-40, 40), e.self:GetZ(), 0)
			if m then adds[#adds + 1] = m:GetID() end
		end
		eq.zone_emote(15, "Broodlings hatch under the Guardian's watch!")
	end
end

function event_death_complete(e)
	eq.stop_timer("brood")
	prog.clear_adds(adds)
	adds = {}
	eq.zone_emote(15, "The Guardian of Eggs dies among its ruined clutch.")
	eq.signal(CTRL, 1104)
end
