-- Eriak Dechard (478716) -- SoD raid: Eriak's Downfall, phase 2.
-- Rasper: raidRathe3.html.
--
-- Simplified live encounter (Dirty Fighting blind, Caltrop snare and the
-- linked Brothers Zek instance are not modelled):
--   * Dormant until Xadrith the Voice dies (live: Xadrith + all adds).
--   * Potion chug -- every 10s he drinks a random potion (emote + 1% heal).
--   * Add waves    -- two ikaav every 60s (live: Brothers Zek waves).
--   * Caltrop      -- two random clients 5k every 45s.
-- On death: Treasure_of_Eriak chest + controller lockout.

local raid = require("sod_raids")

local engaged = false
local adds = {}

local POTIONS = {
	"a frothing mitigation draught",
	"a shimmering damage shield flask",
	"a vile regeneration tonic",
	"a crackling haste vial",
	"a berserker's fury brew",
}

local function clear_adds()
	local el = eq.get_entity_list()
	for _, id in ipairs(adds) do
		local mob = el:GetNPCByID(id)
		if mob and mob.valid then mob:Depop() end
	end
	adds = {}
end

local function reset(e)
	engaged = false
	clear_adds()
	for _, t in ipairs({ "potion", "adds", "caltrop", "resetcheck" }) do
		eq.stop_timer(t)
	end
	e.self:Heal()
	raid.set_invul(e.self, true) -- back to sleep until Xadrith falls again
	eq.zone_emote(15, "Eriak Dechard closes his eyes. The war will wait.")
end

function event_spawn(e)
	raid.set_invul(e.self, true) -- dormant until Xadrith the Voice dies
	e.self:SetEntityVariable("awake", "0")
end

function event_signal(e)
	-- Xadrith signals 1 on death
	if e.signal == 1 and e.self:GetEntityVariable("awake") ~= "1" then
		e.self:SetEntityVariable("awake", "1")
		raid.set_invul(e.self, false)
		eq.zone_emote(15, "Eriak Dechard bellows, 'Rallos watches! Show these intruders the price of trespass!'")
	end
end

function event_combat(e)
	if e.joined then
		if e.self:GetEntityVariable("awake") ~= "1" then
			eq.zone_emote(15, "Eriak Dechard does not stir while Xadrith the Voice lives.")
			return
		end
		if not engaged then
			engaged = true
			eq.set_timer("potion", 10000)
			eq.set_timer("adds", 60000)
			eq.set_timer("caltrop", 45000)
		end
		eq.stop_timer("resetcheck")
	else
		eq.set_timer("resetcheck", 60000)
	end
end

function event_timer(e)
	if e.timer == "resetcheck" then
		if not e.self:IsEngaged() and e.self:GetEntityVariable("awake") == "1" then
			reset(e)
		end
		return
	end
	if not engaged then return end

	if e.timer == "potion" then
		eq.zone_emote(15, "Eriak Dechard quaffs " .. POTIONS[math.random(#POTIONS)] .. ".")
		e.self:SetHP(e.self:GetHP() + math.floor(e.self:GetMaxHP() * 0.01))
	elseif e.timer == "adds" then
		for i = 1, 2 do
			local mob = raid.spawn_add(raid.ADD.ikaav, e.self, 50)
			if mob then
				adds[#adds + 1] = mob:GetID()
				local targets = raid.alive_clients(e.self:GetX(), e.self:GetY(), 300)
				if #targets > 0 then
					mob:AddToHateList(targets[math.random(#targets)], 1000, 10000)
				end
			end
		end
		eq.zone_emote(15, "Ikaav honor guards sweep into the chamber!")
	elseif e.timer == "caltrop" then
		for i = 1, 2 do
			local victim = raid.random_client(e.self:GetX(), e.self:GetY(), 300)
			if victim then
				eq.zone_emote(15, "Caltrops tear at " .. victim:GetCleanName() .. "!")
				raid.hit(e.self, victim, 5000)
			end
		end
	end
end

function event_death_complete(e)
	clear_adds()
	eq.zone_emote(15, "Eriak Dechard falls. The Rallosian Empire mourns its favored son.")
	raid.spawn_chest(e, raid.CHEST.ERIAK)
	eq.signal(raid.CTRL.ERIAK, 1)
end
