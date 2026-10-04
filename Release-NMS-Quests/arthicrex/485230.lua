-- The_Cliknar_Queen (485230) -- Arthicrex v2 raid.
-- Tracked source: Release-NMS-Quests/arthicrex/485230.lua.
-- Rasper: miscRaidProg.html.
--
-- Simplified live encounter:
--   * every 30s a venom spray (poison 8k AE, 200 range);
--   * every 40s three broodlings;
--   * 60% -- two egg clutches; if a clutch lives 20s it hatches three
--     broodlings;
--   * if broodlings are alive the queen draws strength (heals 1%).
-- On death: Treasure_of_the_Cliknar_Queen chest (9 Emblems) + 72h lockout.

local prog = require("uf_progression")

local BROODLING = 485231
local EGG = 485233
local CHEST = prog.CHEST.queen
local LOCKOUT = eq.seconds("72h")

local engaged = false
local eggs60_done = false
local adds = {}
local eggs = {}

local function spawn_broodlings(e, n)
	for i = 1, n do
		local m = eq.spawn2(BROODLING, 0, 0, e.self:GetX() + math.random(-50, 50),
			e.self:GetY() + math.random(-50, 50), e.self:GetZ(), 0)
		if m then adds[#adds + 1] = m:GetID() end
	end
end

local function engage(e)
	if engaged then return end
	engaged = true
	eq.set_timer("venom", 30000)
	eq.set_timer("brood", 40000)
	eq.zone_emote(15, "THE CLKNAR QUEEN RISES FROM THE ROYAL Vats! SHE KNOWS WHY YOU HAVE COME.")
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
			eggs60_done = false
			prog.clear_adds(adds)
			prog.clear_adds(eggs)
			adds = {}
			eggs = {}
			for _, t in ipairs({ "venom", "brood", "hatch" }) do eq.stop_timer(t) end
			e.self:Heal()
			eq.zone_emote(15, "The Queen withdraws into her vats. The event has reset.")
		end
		return
	end
	if not engaged then return end
	local x, y = e.self:GetX(), e.self:GetY()

	if e.timer == "venom" then
		eq.zone_emote(13, "The Queen floods the chamber with royal venom!")
		for _, c in ipairs(prog.alive_clients(x, y, 200)) do
			c:Damage(e.self, 8000, 0, 12)
		end
	elseif e.timer == "brood" then
		spawn_broodlings(e, 3)
		eq.zone_emote(15, "Broodlings pour from the royal clutches!")
	elseif e.timer == "hatch" then
		local el = eq.get_entity_list()
		local alive = false
		for _, id in ipairs(eggs) do
			local m = el:GetNPCByID(id)
			if m and m.valid then
				alive = true
				break
			end
		end
		if alive then
			spawn_broodlings(e, 3)
			eq.zone_emote(15, "An egg clutch hatches -- more broodlings pour out!")
		end
		eggs = {}
	end

	-- queen draws strength from her brood
	local el = eq.get_entity_list()
	local brood_alive = false
	for _, id in ipairs(adds) do
		local m = el:GetNPCByID(id)
		if m and m.valid then
			brood_alive = true
			break
		end
	end
	if brood_alive and e.self:GetHPRatio() < 100 then
		e.self:SetHP(e.self:GetHP() + math.floor(e.self:GetMaxHP() * 0.01))
	end

	if not eggs60_done and e.self:GetHPRatio() <= 60 then
		eggs60_done = true
		for i = 1, 2 do
			local m = eq.spawn2(EGG, 0, 0, x + math.random(-60, 60),
				y + math.random(-60, 60), e.self:GetZ(), 0)
			if m then eggs[#eggs + 1] = m:GetID() end
		end
		eq.set_timer("hatch", 20000)
		eq.zone_emote(15, "The Queen deposits royal egg clutches -- destroy them before they hatch!")
	end
end

function event_death_complete(e)
	prog.clear_adds(adds)
	prog.clear_adds(eggs)
	adds = {}
	eggs = {}
	for _, t in ipairs({ "venom", "brood", "hatch" }) do eq.stop_timer(t) end
	eq.zone_emote(15, "The Cliknar Queen dies, and the hive falls silent with her.")
	prog.spawn_chest(e, CHEST, "The Cliknar Queen")
	local exp = eq.get_expedition()
	if exp.valid and not exp:HasLockout("The Cliknar Queen") then
		exp:AddLockout("The Cliknar Queen", LOCKOUT)
	end
end
