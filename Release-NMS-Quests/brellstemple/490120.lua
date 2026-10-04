-- the_Deconstructor (490120) -- Brell's Temple v1, Trial of Deconstruction.
-- Tracked source: Release-NMS-Quests/brellstemple/490120.lua.
-- Rasper: miscRaidProg.html.
--
-- Simplified live trial:
--   * four construct waves, 45s apart -- two constructs each (mezzable);
--   * while constructs live the temple rebuilds its champion (2% heal
--     per pulse);
--   * 40% -- a deconstruct beam: 10k on a random raider.
-- On death: Treasure_of_Deconstruction chest (9 Amulets), 72h lockout,
-- and the trial_decon flag for surviving raiders.

local prog = require("uf_progression")

local CONSTRUCT_A = 490121
local CONSTRUCT_B = 490122
local CHEST = prog.CHEST.decon
local LOCKOUT = eq.seconds("72h")

local engaged = false
local wave = 0
local beam40_done = false
local adds = {}

local function spawn_wave(e)
	wave = wave + 1
	for i = 1, 2 do
		local tpl = (wave % 2 == 1) and CONSTRUCT_A or CONSTRUCT_B
		local m = eq.spawn2(tpl, 0, 0, e.self:GetX() + math.random(-50, 50),
			e.self:GetY() + math.random(-50, 50), e.self:GetZ(), 0)
		if m then adds[#adds + 1] = m:GetID() end
	end
end

local function engage(e)
	if engaged then return end
	engaged = true
	wave = 0
	eq.set_timer("wave", 1000)   -- first wave almost immediately
	eq.set_timer("rebuild", 6000)
	eq.zone_emote(15, "The temple stirs. 'UNMAKE, THAT YOU MAY BE REMADE.'")
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
			beam40_done = false
			prog.clear_adds(adds)
			adds = {}
			for _, t in ipairs({ "wave", "rebuild" }) do eq.stop_timer(t) end
			e.self:Heal()
			eq.zone_emote(15, "The trial resets. The temple rebuilds its champion.")
		end
		return
	end
	if not engaged then return end

	if e.timer == "wave" then
		if wave >= 4 then
			eq.stop_timer("wave")
			return
		end
		spawn_wave(e)
		eq.set_timer("wave", 45000)
		eq.zone_emote(15, "Constructs wake from the temple walls!")
	elseif e.timer == "rebuild" then
		local el = eq.get_entity_list()
		local alive = false
		for _, id in ipairs(adds) do
			local m = el:GetNPCByID(id)
			if m and m.valid then
				alive = true
				break
			end
		end
		if alive and e.self:GetHPRatio() < 100 then
			eq.zone_emote(13, "The temple rebuilds its Deconstructor while its constructs stand!")
			e.self:SetHP(e.self:GetHP() + math.floor(e.self:GetMaxHP() * 0.02))
		end
	end

	if not beam40_done and e.self:GetHPRatio() <= 40 then
		beam40_done = true
		local targets = prog.alive_clients(e.self:GetX(), e.self:GetY(), 300)
		if #targets > 0 then
			local victim = targets[math.random(#targets)]
			eq.zone_emote(13, "The deconstruct beam strips " .. victim:GetCleanName() .. " apart!")
			victim:Damage(e.self, 10000, 0, 28)
		end
	end
end

function event_death_complete(e)
	prog.clear_adds(adds)
	adds = {}
	for _, t in ipairs({ "wave", "rebuild" }) do eq.stop_timer(t) end
	eq.zone_emote(15, "The Deconstructor is unmade. The first trial is passed.")
	prog.spawn_chest(e, CHEST, "Trial of Deconstruction")
	local exp = eq.get_expedition()
	if exp.valid and not exp:HasLockout("Trial of Deconstruction") then
		exp:AddLockout("Trial of Deconstruction", LOCKOUT)
	end
	for _, c in ipairs(prog.alive_clients(e.self:GetX(), e.self:GetY(), 300)) do
		prog.set(c, prog.FLG.trial_decon, 1)
		c:Message(15, "You have passed the Trial of Deconstruction.")
	end
end
