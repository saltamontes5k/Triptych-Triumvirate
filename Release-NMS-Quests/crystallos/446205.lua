-- [[
-- Aerius Windfury (446205) -- Crystallos raid, Air wing (minor).
-- Rasper: raidCrystallos.html (Aerius Windfury).
--
-- The pre-clear "aery presence" adds hit ~7k and cast PBAE flux/spinstun +
-- reverse knockback; when all on one side die a portalpad sends the raid
-- across to the other. After the presences, Aerius engages: ~11k hits,
-- single+AE rampage, PBAE knockback + hate reducer, PBAE shadowstep.
-- After a time he may become untargetable -> reclear presences and repeat.
-- On death: Treasure_of_Aerius_Windfury (446263) + air-wing lockout.
--]]

local R = require("sof_crystallos_raid")
local CHEST = 446263
local AERY = 446221

local MY_X, MY_Y = 430, 1430

local engaged = false
local presences = {}

function event_combat(e)
	if e.joined then
		if not engaged then
			engaged = true
			eq.set_timer("flux", 20000)
			eq.set_timer("presences", 30000)
			eq.zone_emote(15, "Aerius Windfury howls into being, a cyclone given breath.")
		end
		eq.stop_timer("resetcheck")
	else
		eq.set_timer("resetcheck", 60000)
	end
end

function event_timer(e)
	if e.timer == "resetcheck" then
		if not e.self:IsEngaged() then
			engaged = false
			R.clear_list(presences)
			eq.stop_timer("flux")
			eq.stop_timer("presences")
			e.self:Heal()
		end
		return
	end
	if not engaged then return end

	if e.timer == "flux" then
		eq.zone_emote(13, "Aerius stirs the air, hurling the raid about with a violent flux!")
		for _, c in ipairs(R.alive_clients(MY_X, MY_Y, 300)) do
			c:MovePC(446, c:GetX() + math.random(-60, 60),
				c:GetY() + math.random(-60, 60), c:GetZ(), 0)
		end
		eq.set_timer("flux", 22000)
	elseif e.timer == "presences" then
		-- reclear cadence: if we are untargetable the raid must re-kill presences
		if not e.self:IsTargetable() then
			eq.zone_emote(13, "Aerius becomes incorporeal! Slay the aery presences to ground him again.")
			local new = R.spawn_adds(AERY, 3, MY_X, MY_Y, e.self:GetZ(), 90)
			for _, id in ipairs(new) do presences[#presences + 1] = id end
			e.self:SetTargetable(1)
		end
		eq.set_timer("presences", 30000)
	end
end

function event_death_complete(e)
	R.clear_list(presences)
	eq.stop_timer("flux")
	eq.stop_timer("presences")
	R.chest(e.self, CHEST, "Crystallos: Aerius Windfury")
	R.signal(R.SIG.air)
	eq.zone_emote(15, "The cyclonic fury disperses. The air wing falls to a whisper.")
end
