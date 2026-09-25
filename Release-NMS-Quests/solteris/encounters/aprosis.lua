--[[
Aprosis, the Fourth Confidant (Solteris event 2, island 1) -
#Ur-Floxiz_Lochmaul (421005) then #Aprosis_the_Fourth_Confidant (421006).

Core mechanics (Rasper's guide), permissively tuned:
  * Lochmaul is rooted (no grid), hits ~8k with flurry, cycles his four
    spells (Lochmaul Uppercut 11663 / Bash 11664 / Theft 11662 /
    Ground Punch 11666).
  * Add wave every 110s while Lochmaul is engaged; wave size scales with the
    expedition (solo floor 4, raid cap 10).
  * Aprosis activates on Lochmaul's death: hits ~9k, rampages, 40s AE burst,
    and every 100s gathers elemental energy - the raid must burn the
    gathered HP % inside a 10s window or someone is banished to Katta
    Castrum. Expeditions under 3 players take a Deadly Solar Winds torrent
    instead, so a solo player can never be locked out of the fight.
  * Waves stop at 73%; extra waves at 30% and 10%.

State lives on Aprosis entity variables (per-instance):
  aprosis_active = 1 once Lochmaul has fallen
]]

local CONTROLLER  = 421000;
local CHEST       = 421091;
local SIGNAL_KEY  = 1002;

local LOCHMAUL = 421005;
local APROSIS  = 421006;

local ADD_POOL = { 421080, 421084, 421080, 421082, 421084, 421080 };  -- magma/dervish/flame mix
local BANISH_ZONE = 416;   -- Katta Castrum safe spot
local BANISH_X, BANISH_Y, BANISH_Z = -2, -425, -20;

local ELEMENT_MSGS = {
	"Aprosis gathers together a ball of arcane energy and prepares to hurl it at his enemies",
	"Aprosis gathers together a ball of blazing energy and prepares to hurl it at his enemies",
	"Aprosis gathers together a ball of freezing energy and prepares to hurl it at his enemies",
}

function expedition_size()
	local expedition = eq.get_expedition();
	if expedition.valid then
		return math.max(1, expedition:GetMemberCount());
	end
	return 1;
end

function wave_size()
	local n = expedition_size();
	return math.max(4, math.min(10, n + 3));
end

function spawn_wave(center)
	local n = wave_size();
	for i = 1, n do
		local id = ADD_POOL[math.random(1, #ADD_POOL)];
		local ang = (i / n) * 6.283;
		eq.spawn2(id, 0, 0,
			center:GetX() + math.cos(ang) * 40,
			center:GetY() + math.sin(ang) * 40,
			center:GetZ(), 0);
	end
	eq.zone_emote(MT.Red, "Reinforcements answer Aprosis's call!");
end

function Lochmaul_Combat(e)
	if e.joined then
		e.self:SetTimerMS("spells", 12 * 1000);
		e.self:SetTimerMS("adds", 5 * 1000);          -- first wave comes fast
		e.self:Emote("roots itself and roars, daring you to approach!");
	else
		e.self:StopTimer("spells");
		e.self:StopTimer("adds");
	end
end

function Lochmaul_Timer(e)
	if e.timer == "spells" then
		local target = e.self:GetTarget();
		if target ~= nil then
			local which = math.random(1, 4);
			if which == 1 then
				e.self:CastSpell(11663, target:GetID());  -- Lochmaul Uppercut
			elseif which == 2 then
				e.self:CastSpell(11664, target:GetID());  -- Lochmaul Bash
			elseif which == 3 then
				e.self:CastSpell(11662, target:GetID());  -- Lochmaul Theft
			else
				e.self:CastSpell(11666, target:GetID());  -- Ground Punch
			end
		end
		e.self:SetTimerMS("spells", 14 * 1000);
	elseif e.timer == "adds" then
		spawn_wave(e.self);
		e.self:SetTimerMS("adds", 110 * 1000);
	end
end

function Lochmaul_Death(e)
	local aprosis = eq.get_entity_list():GetNPCByNPCTypeID(APROSIS);
	if aprosis ~= nil then
		aprosis:SetEntityVariable("aprosis_active", "1");
		aprosis:Emote("steps over Lochmaul's corpse. 'Was that meant to impress me?'");
		aprosis:SetSpecialAbility(SpecialAbility.rampage, 1);
		aprosis:SetSpecialAbilityParam(SpecialAbility.rampage, 0, 1);
		aprosis:SetTimerMS("burst", 40 * 1000);
		aprosis:SetTimerMS("element", 20 * 1000);
	end
end

function Aprosis_Combat(e)
	if e.joined then
		local active = e.self:GetEntityVariable("aprosis_active");
		if active == nil or active ~= "1" then
			-- cannot be fought before Lochmaul falls; shed hate
			e.self:Heal();
			if e.other ~= nil then
				e.self:RemoveFromHateList(e.other);
			end
			e.self:Say("Your quarrel is with my servant, mortal.");
		else
			e.self:SetTimerMS("phase", 3 * 1000);
		end
	else
		e.self:StopTimer("phase");
		e.self:StopTimer("burst");
		e.self:StopTimer("element");
		e.self:StopTimer("element_check");
	end
end

function Aprosis_Timer(e)
	if e.timer == "burst" then
		local target = e.self:GetTarget();
		if target ~= nil then
			e.self:CastSpell(11666, target:GetID());  -- Ground Punch (AE burst stand-in)
		end
		e.self:SetTimerMS("burst", 40 * 1000);
	elseif e.timer == "element" then
		eq.zone_emote(MT.Red, ELEMENT_MSGS[math.random(1, #ELEMENT_MSGS)]);
		e.self:SetEntityVariable("element_start", string.format("%.2f", e.self:GetHPRatio()));
		e.self:SetTimerMS("element_check", 10 * 1000);
	elseif e.timer == "element_check" then
		e.self:StopTimer("element_check");

		-- required burn % scales down with expedition size (solo = 4%)
		local need = 4 + math.floor(expedition_size() / 2);
		local start = tonumber(e.self:GetEntityVariable("element_start") or "100") or 100;
		local burned = start - e.self:GetHPRatio();

		if burned >= need then
			eq.zone_emote(MT.Red, "Aprosis's gathered energy is spent against him before it can be hurled!");
		else
			if expedition_size() < 3 then
				local target = e.self:GetTarget();
				if target ~= nil then
					eq.zone_emote(MT.Red, "Aprosis hurls a massive torrent of energy!");
					e.self:CastSpell(11681, target:GetID());  -- Deadly Solar Winds torrent
				end
			else
				local victim = eq.get_entity_list():GetRandomClient(
					e.self:GetX(), e.self:GetY(), e.self:GetZ(), 10000);
				if victim ~= nil then
					victim:Message(MT.Red, "Aprosis banishes you to Katta Castrum!");
					victim:MovePC(BANISH_ZONE, BANISH_X, BANISH_Y, BANISH_Z, 0);
				end
			end
		end
		e.self:SetTimerMS("element", 100 * 1000);
	elseif e.timer == "phase" then
		local pct = e.self:GetHPRatio();

		if pct <= 73 and (tonumber(e.self:GetEntityVariable("aprosis_adds_off") or "0") or 0) == 0 then
			e.self:SetEntityVariable("aprosis_adds_off", "1");
			eq.zone_emote(MT.Red, "The tide of reinforcements falters.");
			local lochmaul = eq.get_entity_list():GetNPCByNPCTypeID(LOCHMAUL);
			if lochmaul ~= nil then
				lochmaul:StopTimer("adds");
			end
		elseif pct <= 30 and (tonumber(e.self:GetEntityVariable("aprosis_wave30") or "0") or 0) == 0 then
			e.self:SetEntityVariable("aprosis_wave30", "1");
			spawn_wave(e.self);
		elseif pct <= 10 and (tonumber(e.self:GetEntityVariable("aprosis_wave10") or "0") or 0) == 0 then
			e.self:SetEntityVariable("aprosis_wave10", "1");
			spawn_wave(e.self);
		end

		e.self:SetTimerMS("phase", 3 * 1000);
	end
end

function Aprosis_Death(e)
	eq.depop_all(421080);  -- Liquid Magma
	eq.depop_all(421082);  -- a living flame
	eq.depop_all(421084);  -- dervishes

	local expedition = eq.get_expedition();
	local x, y, z = e.self:GetX(), e.self:GetY(), e.self:GetZ();
	if expedition.valid then
		local chest = eq.unique_spawn(CHEST, 0, 0, x, y, z + 5, 0);
		if chest ~= nil then
			expedition:SetLootEventBySpawnID(chest:GetID(), "Aprosis, the Fourth Confidant");
		end
	end
	eq.signal(CONTROLLER, SIGNAL_KEY);
end

function event_encounter_load(e)
	eq.register_npc_event('aprosis', Event.combat,         LOCHMAUL, Lochmaul_Combat);
	eq.register_npc_event('aprosis', Event.timer,          LOCHMAUL, Lochmaul_Timer);
	eq.register_npc_event('aprosis', Event.death_complete, LOCHMAUL, Lochmaul_Death);

	eq.register_npc_event('aprosis', Event.combat,         APROSIS, Aprosis_Combat);
	eq.register_npc_event('aprosis', Event.timer,          APROSIS, Aprosis_Timer);
	eq.register_npc_event('aprosis', Event.death_complete, APROSIS, Aprosis_Death);
end

function event_encounter_unload(e)
end
