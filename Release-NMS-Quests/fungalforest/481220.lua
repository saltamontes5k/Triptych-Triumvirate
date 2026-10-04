-- the_Fungal_Corruption (481220) -- Fungal Forest v1 raid.
-- Tracked source: Release-NMS-Quests/fungalforest/481220.lua.
-- Rasper: miscRaidProg.html.
--
-- Simplified live encounter:
--   * every 35s a spore burst (poison 7k AE, 200 range);
--   * every 50s two spore pods -- a pod that lives 25s bursts for 5k;
--   * 60% -- three fungal creepers join.
-- On death: Treasure_of_the_Fungal_Corruption chest (6 Amulets) + lockout.

local prog = require("uf_progression")

local POD = 481221
local CREEPER = 481222
local CHEST = prog.CHEST.fungal
local LOCKOUT = eq.seconds("72h")

local engaged = false
local adds60_done = false
local adds = {}
local pods = {}

local function engage(e)
	if engaged then return end
	engaged = true
	eq.set_timer("burst", 35000)
	eq.set_timer("pods", 50000)
	eq.zone_emote(15, "The bloom bends toward you -- THE FUNGAL CORRUPTION WAKES!")
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
			adds60_done = false
			prog.clear_adds(adds)
			prog.clear_adds(pods)
			adds = {}
			pods = {}
			for _, t in ipairs({ "burst", "pods", "pod_boom" }) do eq.stop_timer(t) end
			e.self:Heal()
			eq.zone_emote(15, "The corruption folds back into the forest floor. The event has reset.")
		end
		return
	end
	if not engaged then return end
	local x, y = e.self:GetX(), e.self:GetY()

	if e.timer == "burst" then
		eq.zone_emote(13, "A spore burst erupts across the grove!")
		for _, c in ipairs(prog.alive_clients(x, y, 200)) do
			c:Damage(e.self, 7000, 0, 12)
		end
	elseif e.timer == "pods" then
		for i = 1, 2 do
			local m = eq.spawn2(POD, 0, 0, x + math.random(-50, 50),
				y + math.random(-50, 50), e.self:GetZ(), 0)
			if m then pods[#pods + 1] = m:GetID() end
		end
		eq.set_timer("pod_boom", 25000)
		eq.zone_emote(15, "Spore pods swell around the corruption!")
	elseif e.timer == "pod_boom" then
		local el = eq.get_entity_list()
		local alive = false
		for _, id in ipairs(pods) do
			local m = el:GetNPCByID(id)
			if m and m.valid then
				alive = true
				break
			end
		end
		if alive then
			eq.zone_emote(13, "A spore pod bursts -- the cloud is choking!")
			for _, c in ipairs(prog.alive_clients(x, y, 200)) do
				c:Damage(e.self, 5000, 0, 12)
			end
		end
		prog.clear_adds(pods)
		pods = {}
	end

	if not adds60_done and e.self:GetHPRatio() <= 60 then
		adds60_done = true
		for i = 1, 3 do
			local m = eq.spawn2(CREEPER, 0, 0, x + math.random(-60, 60),
				y + math.random(-60, 60), e.self:GetZ(), 0)
			if m then adds[#adds + 1] = m:GetID() end
		end
		eq.zone_emote(15, "Fungal creepers detach from the corruption's bulk!")
	end
end

function event_death_complete(e)
	prog.clear_adds(adds)
	prog.clear_adds(pods)
	adds = {}
	pods = {}
	for _, t in ipairs({ "burst", "pods", "pod_boom" }) do eq.stop_timer(t) end
	eq.zone_emote(15, "The corruption collapses into harmless rot.")
	prog.spawn_chest(e, CHEST, "The Fungal Corruption")
	local exp = eq.get_expedition()
	if exp.valid and not exp:HasLockout("The Fungal Corruption") then
		exp:AddLockout("The Fungal Corruption", LOCKOUT)
	end
end
