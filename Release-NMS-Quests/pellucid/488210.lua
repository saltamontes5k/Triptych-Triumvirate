-- The_Unburrowing (488210) -- T6 open raid, Pellucid Grotto (static zone).
-- Tracked source: Release-NMS-Quests/pellucid/488210.lua.
-- Rasper: miscRaidProg.html.
--
-- Simplified live encounter:
--   * every 30s an eruption of disturbed crystal (5k AE, 200 range);
--   * every 40s three swarmlings tunnel in at random offsets;
--   * 75/50/25% -- it burrows briefly: heals a little, four swarmlings.
-- On death: Treasure_of_the_Unburrowing chest (9 Coins of Brell).

local prog = require("uf_progression")

local SWARM = 488211
local CHEST = prog.CHEST.unburrowing

local engaged = false
local burrow_stage = 0
local adds = {}

local function engage(e)
	if engaged then return end
	engaged = true
	burrow_stage = 0
	eq.set_timer("eruption", 30000)
	eq.set_timer("swarm", 40000)
	eq.zone_emote(15, "The Unburrowing churns the crystal floor!")
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
			burrow_stage = 0
			prog.clear_adds(adds)
			adds = {}
			for _, t in ipairs({ "eruption", "swarm" }) do eq.stop_timer(t) end
			e.self:Heal()
			eq.zone_emote(15, "The Unburrowing sinks back into its burrow. The event has reset.")
		end
		return
	end
	if not engaged then return end
	local x, y = e.self:GetX(), e.self:GetY()

	if e.timer == "eruption" then
		eq.zone_emote(13, "Crystal shards erupt from the churned floor!")
		for _, c in ipairs(prog.alive_clients(x, y, 200)) do
			c:Damage(e.self, 5000, 0, 28)
		end
	elseif e.timer == "swarm" then
		for i = 1, 3 do
			local m = eq.spawn2(SWARM, 0, 0, x + math.random(-80, 80),
				y + math.random(-80, 80), e.self:GetZ(), 0)
			if m then adds[#adds + 1] = m:GetID() end
		end
		eq.zone_emote(15, "Swarmlings unburrow all around you!")
	end

	local ratio = e.self:GetHPRatio()
	local thresholds = { [1] = 75, [2] = 50, [3] = 25 }
	local stage = burrow_stage + 1
	if thresholds[stage] and ratio <= thresholds[stage] then
		burrow_stage = stage
		e.self:Heal()
		for i = 1, 4 do
			local m = eq.spawn2(SWARM, 0, 0, x + math.random(-80, 80),
				y + math.random(-80, 80), e.self:GetZ(), 0)
			if m then adds[#adds + 1] = m:GetID() end
		end
		eq.zone_emote(15, "The Unburrowing burrows, spilling swarmlings in its wake!")
	end
end

function event_death_complete(e)
	prog.clear_adds(adds)
	adds = {}
	for _, t in ipairs({ "eruption", "swarm" }) do eq.stop_timer(t) end
	eq.zone_emote(15, "The Unburrowing stills at last. Pellucid grows quiet.")
	prog.spawn_chest(e, CHEST, "The Unburrowing")
end
