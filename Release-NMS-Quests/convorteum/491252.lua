-- Sorrel_the_Magus (491252) -- Convorteum v1, stage 6 (third sister).
-- Tracked source: Release-NMS-Quests/convorteum/491252.lua.
-- Rasper: miscRaidProg.html.
--
-- Sorrel works the mind: every 20s a mindlance on a random raider (6k)
-- and every 45s a discord ring (5k AE, 200 range). When she dies the
-- stage completes (the controller has counted all three sisters).
-- Signals the controller (2006).

local prog = require("uf_progression")

local CTRL = prog.NPC.conv_ctrl

local engaged = false

local function engage(e)
	if engaged then return end
	engaged = true
	eq.set_timer("mindlance", 20000)
	eq.set_timer("ring", 45000)
	eq.zone_emote(15, "Sorrel hums a chord that bends the air. 'The last part is mine.'")
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
			for _, t in ipairs({ "mindlance", "ring" }) do eq.stop_timer(t) end
			e.self:Heal()
			eq.zone_emote(15, "Sorrel's chord dies away. The event has reset.")
		end
		return
	end
	if not engaged then return end
	local x, y = e.self:GetX(), e.self:GetY()

	if e.timer == "mindlance" then
		local targets = prog.alive_clients(x, y, 300)
		if #targets > 0 then
			local victim = targets[math.random(#targets)]
			eq.zone_emote(13, "Sorrel's mindlance pierces " .. victim:GetCleanName() .. "!")
			victim:Damage(e.self, 6000, 0, 28)
		end
	elseif e.timer == "ring" then
		eq.zone_emote(13, "Sorrel spins a ring of pure discord!")
		for _, c in ipairs(prog.alive_clients(x, y, 200)) do
			c:Damage(e.self, 5000, 0, 28)
		end
	end
end

function event_death_complete(e)
	for _, t in ipairs({ "mindlance", "ring" }) do eq.stop_timer(t) end
	eq.zone_emote(15, "Sorrel falls silent. The Magus Sisters sing no more.")
	eq.signal(CTRL, 2006)
end
