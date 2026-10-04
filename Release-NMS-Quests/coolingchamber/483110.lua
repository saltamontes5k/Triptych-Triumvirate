-- The_Beast_Below (483110) -- T6 open raid, Cooling Chamber (static zone).
-- Tracked source: Release-NMS-Quests/coolingchamber/483110.lua.
-- Rasper: miscRaidProg.html.
--
-- Simplified live encounter:
--   * every 45s a coolant spray (6k AE, 250 range);
--   * every 90s a coolant flood (8k AE, 300 range, warned);
--   * 60% -- freezing vents: three venting goos.
-- On death: Treasure_of_the_Beast_Below chest (9 Coins of Brell).

local prog = require("uf_progression")

local GOO = 483111
local CHEST = prog.CHEST.beast

local engaged = false
local vents_done = false
local adds = {}

local function engage(e)
	if engaged then return end
	engaged = true
	eq.set_timer("spray", 45000)
	eq.set_timer("flood", 90000)
	eq.zone_emote(15, "The Beast Below surfaces, coolant streaming off its bulk!")
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
			vents_done = false
			prog.clear_adds(adds)
			adds = {}
			for _, t in ipairs({ "spray", "flood" }) do eq.stop_timer(t) end
			e.self:Heal()
			eq.zone_emote(15, "The Beast Below sinks into the coolant. The event has reset.")
		end
		return
	end
	if not engaged then return end
	local x, y = e.self:GetX(), e.self:GetY()

	if e.timer == "spray" then
		eq.zone_emote(13, "The Beast sprays scalding coolant!")
		for _, c in ipairs(prog.alive_clients(x, y, 250)) do
			c:Damage(e.self, 6000, 0, 28)
		end
	elseif e.timer == "flood" then
		eq.zone_emote(13, "A COOLANT FLOOD races across the chamber floor!")
		for _, c in ipairs(prog.alive_clients(x, y, 300)) do
			c:Damage(e.self, 8000, 0, 28)
		end
	end

	if not vents_done and e.self:GetHPRatio() <= 60 then
		vents_done = true
		for i = 1, 3 do
			local m = eq.spawn2(GOO, 0, 0, x + math.random(-70, 70),
				y + math.random(-70, 70), e.self:GetZ(), 0)
			if m then adds[#adds + 1] = m:GetID() end
		end
		eq.zone_emote(15, "Freezing vents crack open -- venting goos pour out!")
	end
end

function event_death_complete(e)
	prog.clear_adds(adds)
	adds = {}
	for _, t in ipairs({ "spray", "flood" }) do eq.stop_timer(t) end
	eq.zone_emote(15, "The Beast Below sinks, and does not rise again.")
	prog.spawn_chest(e, CHEST, "The Beast Below")
end
