--[[
Astire, the Lunar Eclipse (Solteris event 4, island 2) - 421045, with his
four weapon Guardians (421046 Spear, 421047 Staff, 421048 Sword, 421049 Fist).

Core mechanics (Rasper's guide), permissively tuned:
  * The four Guardians stand with Astire; each death passes its melee
    mitigation to Astire (+ATK/+AC per fallen Guardian) - kill them or fight
    a harder Astire, both are valid.
  * Bite of the Lycanthrope (11728) lands on random targets and must be
    cured; it lands more often the lower Astire's health.
  * At 30% Astire cycles berserk emotes (AE rampage windows) and at 15%
    casts Fog of Night (11964) - a heavy PBAE.
  * Vampire/dervish adds pour from the building while he is engaged.
  * Killing Astire completes the event; Guardians are optional.

The guardians are spawned when Astire spawns (Event.spawn), which the zone
controller's unique_spawn triggers.
]]

local CONTROLLER = 421000;
local CHEST      = 421093;
local SIGNAL_KEY = 1004;

local ASTIRE    = 421045;
local G_SPEAR   = 421046;
local G_STAFF   = 421047;
local G_SWORD   = 421048;
local G_FIST    = 421049;
local GUARDIANS = { G_SPEAR, G_STAFF, G_SWORD, G_FIST };

local ADD_POOL = { 421084, 421035, 421084 };  -- dervish / vampire / dervish

-- guardian offsets from Astire's throne (map POIs negated)
local GUARDIAN_POS = {
	[G_SWORD] = { -1702, 2662, 1328 },
	[G_SPEAR] = { -1650, 2570, 1328 },
	[G_STAFF] = { -1760, 2570, 1328 },
	[G_FIST]  = { -1585, 2671, 1328 },
}

function expedition_size()
	local expedition = eq.get_expedition();
	if expedition.valid then
		return math.max(1, expedition:GetMemberCount());
	end
	return 1;
end

function Astire_Spawn(e)
	-- summon the four Guardians once
	for _, id in ipairs(GUARDIANS) do
		if not eq.get_entity_list():IsMobSpawnedByNpcTypeID(id) then
			local pos = GUARDIAN_POS[id];
			eq.spawn2(id, 0, 0, pos[1], pos[2], pos[3], 0);
		end
	end
end

function Astire_Combat(e)
	if e.joined then
		e.self:SetTimerMS("bite", 25 * 1000);
		e.self:SetTimerMS("adds", 60 * 1000);
		e.self:SetTimerMS("phase", 3 * 1000);
		e.self:Emote("rises beneath the blackened moon, 'The night belongs to me.'");
	else
		e.self:StopTimer("bite");
		e.self:StopTimer("adds");
		e.self:StopTimer("phase");
		e.self:StopTimer("fog");
	end
end

function Astire_Timer(e)
	if e.timer == "bite" then
		local victim = eq.get_entity_list():GetRandomClient(
			e.self:GetX(), e.self:GetY(), e.self:GetZ(), 300);
		if victim ~= nil then
			e.self:CastSpell(11728, victim:GetID());  -- Bite of the Lycanthrope
			victim:Message(MT.Red, "You have been bitten! Cure the corruption quickly!");
		end
		-- bites come faster the lower his health
		local interval = 25;
		if e.self:GetHPRatio() < 50 then
			interval = 18;
		end
		if e.self:GetHPRatio() < 25 then
			interval = 12;
		end
		e.self:SetTimerMS("bite", interval * 1000);
	elseif e.timer == "adds" then
		local n = math.random(1, 2) + math.floor(expedition_size() / 6);
		for i = 1, n do
			local id = ADD_POOL[math.random(1, #ADD_POOL)];
			eq.spawn2(id, 0, 0,
				e.self:GetX() + math.random(-40, 40),
				e.self:GetY() + math.random(-40, 40),
				e.self:GetZ(), 0);
		end
		e.self:SetTimerMS("adds", 60 * 1000);
	elseif e.timer == "fog" then
		e.self:CastSpell(11964, e.self:GetID());  -- Fog of Night (PBAE)
		e.self:SetTimerMS("fog", 20 * 1000);
	elseif e.timer == "phase" then
		local pct = e.self:GetHPRatio();

		if pct <= 30 then
			local roll = math.random(1, 3);
			if roll == 1 then
				eq.zone_emote(MT.Red, "Astire goes into a berserk frenzy!");
				e.self:SetSpecialAbility(SpecialAbility.area_rampage, 1);
				e.self:SetSpecialAbilityParam(SpecialAbility.area_rampage, 0, 100);
				e.self:SetTimerMS("rampage_off", 10 * 1000);
			else
				eq.zone_emote(MT.Red, "Astire takes note of the spells being used against him!");
				local target = e.self:GetTarget();
				if target ~= nil then
					e.self:CastSpell(11960, target:GetID());  -- Solar Strike (empowered nuke)
				end
			end
			e.self:SetTimerMS("phase", 10 * 1000);
		else
			e.self:SetTimerMS("phase", 3 * 1000);
		end

		if pct <= 15 and (tonumber(e.self:GetEntityVariable("fog_started") or "0") or 0) == 0 then
			e.self:SetEntityVariable("fog_started", "1");
			e.self:SetTimerMS("fog", 5 * 1000);
		end
	elseif e.timer == "rampage_off" then
		e.self:SetSpecialAbility(SpecialAbility.area_rampage, 0);
	end
end

function Astire_Death(e)
	-- chest + lockout (Guardians/adds intentionally persist per the guide)
	local expedition = eq.get_expedition();
	local x, y, z = e.self:GetX(), e.self:GetY(), e.self:GetZ();
	if expedition.valid then
		local chest = eq.unique_spawn(CHEST, 0, 0, x, y, z + 5, 0);
		if chest ~= nil then
			expedition:SetLootEventBySpawnID(chest:GetID(), "Astire, the Lunar Eclipse");
		end
	end
	eq.signal(CONTROLLER, SIGNAL_KEY);
end

function Guardian_Death(e)
	local astire = eq.get_entity_list():GetNPCByNPCTypeID(ASTIRE);
	if astire ~= nil and astire:IsEngaged() then
		-- the fallen Guardian's mitigation passes to Astire
		astire:SetATK(astire:GetATK() + 50);
		astire:Emote("absorbs its guardian's power, its hide hardening!");
	end
end

function event_encounter_load(e)
	eq.register_npc_event('astire', Event.spawn,          ASTIRE, Astire_Spawn);
	eq.register_npc_event('astire', Event.combat,         ASTIRE, Astire_Combat);
	eq.register_npc_event('astire', Event.timer,          ASTIRE, Astire_Timer);
	eq.register_npc_event('astire', Event.death_complete, ASTIRE, Astire_Death);

	for _, id in ipairs(GUARDIANS) do
		eq.register_npc_event('astire', Event.death_complete, id, Guardian_Death);
	end
end

function event_encounter_unload(e)
end
