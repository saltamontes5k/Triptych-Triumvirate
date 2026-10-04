-- Fippys_Revenge (480210) -- T6 open raid, Brell's Rest (static zone).
-- Tracked source: Release-NMS-Quests/brellsrest/480210.lua.
-- Rasper: miscRaidProg.html.
--
-- Simplified live encounter:
--   * every 45s a wave of three phantom gnolls (reavers, every other wave
--     a shaman) claws up around the grave;
--   * every 60s a wail of the fallen (5k AE, 200 range);
--   * 50% -- the grave itself answers: four reavers at once.
-- On death: punchable Treasure_of_Fippys_Revenge chest (9 Coins of Brell).
-- The 72h world cooldown was set by the trigger, not here.

local prog = require("uf_progression")

local REAVER = 480211
local SHAMAN = 480212
local CHEST = prog.CHEST.fippy

local engaged = false
local wave_odd = false
local adds50_done = false
local adds = {}

local function engage(e)
	if engaged then return end
	engaged = true
	eq.set_timer("waves", 45000)
	eq.set_timer("wail", 60000)
	eq.zone_emote(15, "Fippy Darkpaw howls for his fallen pack!")
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
			wave_odd = false
			adds50_done = false
			prog.clear_adds(adds)
			adds = {}
			for _, t in ipairs({ "waves", "wail" }) do eq.stop_timer(t) end
			e.self:Heal()
			eq.zone_emote(15, "Fippy sinks back into the grave mound. The event has reset.")
		end
		return
	end
	if not engaged then return end
	local x, y = e.self:GetX(), e.self:GetY()

	if e.timer == "waves" then
		wave_odd = not wave_odd
		local tpl = wave_odd and SHAMAN or REAVER
		for i = 1, 3 do
			local m = eq.spawn2(tpl, 0, 0, x + math.random(-60, 60),
				y + math.random(-60, 60), e.self:GetZ(), 0)
			if m then adds[#adds + 1] = m:GetID() end
		end
		eq.zone_emote(15, "Phantom gnolls claw up through the grave dirt!")
	elseif e.timer == "wail" then
		eq.zone_emote(13, "Fippy looses the wail of the fallen!")
		for _, c in ipairs(prog.alive_clients(x, y, 200)) do
			c:Damage(e.self, 5000, 0, 28)
		end
	end

	if not adds50_done and e.self:GetHPRatio() <= 50 then
		adds50_done = true
		for i = 1, 4 do
			local m = eq.spawn2(REAVER, 0, 0, x + math.random(-70, 70),
				y + math.random(-70, 70), e.self:GetZ(), 0)
			if m then adds[#adds + 1] = m:GetID() end
		end
		eq.zone_emote(15, "The grave itself answers its king -- more phantoms rise!")
	end
end

function event_death_complete(e)
	prog.clear_adds(adds)
	adds = {}
	for _, t in ipairs({ "waves", "wail" }) do eq.stop_timer(t) end
	eq.zone_emote(15, "Fippy Darkpaw collapses into dust. The grave is quiet again.")
	prog.spawn_chest(e, CHEST, "Fippy's Revenge")
end
