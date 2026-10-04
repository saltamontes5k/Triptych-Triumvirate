-- The_First_Creation (491260) -- Convorteum v1, stage 7 finale.
-- Tracked source: Release-NMS-Quests/convorteum/491260.lua.
-- Rasper: miscRaidProg.html.
--
-- Simplified live finale:
--   * every 30s creation remnant waves -- two remnants join;
--   * every 25s a primordial pulse (7k AE, 200 range);
--   * 50% -- it remembers every failure: two more remnants plus an 8k AE;
--   * 20% -- the heart of the Underfoot beats out of step: 10k AE.
-- On death: Treasure_of_The_First_Creation chest (Amulet backflag) +
-- 72h lockout; the controller pays the final stage flag.

local prog = require("uf_progression")

local CTRL = prog.NPC.conv_ctrl
local REM_A = 491266
local REM_B = 491267

local engaged = false
local wave = 0
local fail50_done = false
local heart20_done = false
local adds = {}

local function spawn_remnants(e, n)
	for i = 1, n do
		local tpl = (i % 2 == 1) and REM_A or REM_B
		local m = eq.spawn2(tpl, 0, 0, e.self:GetX() + math.random(-60, 60),
			e.self:GetY() + math.random(-60, 60), e.self:GetZ(), 0)
		if m then adds[#adds + 1] = m:GetID() end
	end
end

local function engage(e)
	if engaged then return end
	engaged = true
	wave = 0
	eq.set_timer("remnants", 1000)
	eq.set_timer("pulse", 25000)
	eq.zone_emote(15, "The First Creation unfolds -- the first thing the world ever made, and the last thing it will unmake.")
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
			wave = 0
			fail50_done = false
			heart20_done = false
			prog.clear_adds(adds)
			adds = {}
			for _, t in ipairs({ "remnants", "pulse" }) do eq.stop_timer(t) end
			e.self:Heal()
			eq.zone_emote(15, "The First Creation folds closed again. The event has reset.")
		end
		return
	end
	if not engaged then return end
	local x, y = e.self:GetX(), e.self:GetY()

	if e.timer == "remnants" then
		if wave >= 6 then
			eq.stop_timer("remnants")
			return
		end
		wave = wave + 1
		spawn_remnants(e, 2)
		eq.set_timer("remnants", 30000)
		eq.zone_emote(15, "Remnants of the first attempts crawl out to defend it!")
	elseif e.timer == "pulse" then
		eq.zone_emote(13, "A primordial pulse rolls out from the Creation!")
		for _, c in ipairs(prog.alive_clients(x, y, 200)) do
			c:Damage(e.self, 7000, 0, 28)
		end
	end

	if not fail50_done and e.self:GetHPRatio() <= 50 then
		fail50_done = true
		spawn_remnants(e, 2)
		eq.zone_emote(13, "The Creation remembers every failure, and grieves!")
		for _, c in ipairs(prog.alive_clients(x, y, 250)) do
			c:Damage(e.self, 8000, 0, 28)
		end
	end
	if not heart20_done and e.self:GetHPRatio() <= 20 then
		heart20_done = true
		eq.zone_emote(13, "The heart of the Underfoot beats out of step -- reality shudders!")
		for _, c in ipairs(prog.alive_clients(x, y, 300)) do
			c:Damage(e.self, 10000, 0, 28)
		end
	end
end

function event_death_complete(e)
	prog.clear_adds(adds)
	adds = {}
	for _, t in ipairs({ "remnants", "pulse" }) do eq.stop_timer(t) end
	eq.zone_emote(15, "The First Creation is ended. The Underfoot has new custodians.")
	eq.signal(CTRL, 2007)
end
