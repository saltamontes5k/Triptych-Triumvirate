--[[
The Two Gods (Solteris event 7, island 4 throne room) - Solusek Ro (421097)
and Mayong Mistmoore (421098).

SoF progression: the clones carry names that resolve to the existing
solteris/Solusek_Ro.pl and solteris/Mayong_Mistmoore.pl quest shims, whose
EVENT_DEATH_COMPLETE calls plugin::handle_death - the standard flag path.
handle_death matches the clean names ('solusek ro' / 'mayong mistmoore')
against the SoF stage subflags and spawns the 26000 hail mob on each corpse,
so killing both gods and hailing both memories unlocks the SoF stage.

Core mechanics (Rasper's guide), permissively tuned:
  * Phase 1 - Mayong first (hits ~6k): frontal AE Wrath of a New God (11682)
    and shade-bat waves; the Shard of Eternal Light from the throne trash
    still exists as loot flavor, but the wave clock is fixed (no clicks
    needed) so solo players are not gated on the clicky.
  * Phase 2 - at 5% Mayong "dies" and Solusek Ro rises (hits ~8.5k):
    Deadly Solar Winds (11681) on the tank and living-flame add waves.
  * Phase 3 - at 75% Mayong returns; keep the gods within 8% HP of each
    other or the healthier one empowers. Below 50% Mayong periodically
    "raises his sword" (Fog of Night 11964 PBAE stand-in).
  * Both gods truly dead: two-pool chest + lockout.

State lives on the per-instance controller entity variables:
  gods_phase, gods_mayong_dead, gods_solusek_dead
]]

local CONTROLLER = 421000;
local CHEST      = 421096;
local SIGNAL_KEY = 1007;

local SOLUSEK = 421097;
local MAYONG  = 421098;
local BAT     = 421083;   -- a_shade_bat (Mayong's waves)
local FLAME   = 421082;   -- a_living_flame (Solusek's waves)

local SOLUSEK_SPAWN = { -2600, 5660, 3914 };
local MAYONG_SPAWN  = { -2500, 5560, 3914 };

function expedition_size()
	local expedition = eq.get_expedition();
	if expedition.valid then
		return math.max(1, expedition:GetMemberCount());
	end
	return 1;
end

function controller_var(name, default)
	local ctrl = eq.get_entity_list():GetNPCByNPCTypeID(CONTROLLER);
	if ctrl ~= nil then
		return ctrl:GetEntityVariable(name) or default;
	end
	return default;
end

function set_controller_var(name, value)
	local ctrl = eq.get_entity_list():GetNPCByNPCTypeID(CONTROLLER);
	if ctrl ~= nil then
		ctrl:SetEntityVariable(name, value);
	end
end

function wave_count()
	return math.max(6, math.min(24, 6 + math.floor(expedition_size() * 0.6)));
end

function Mayong_Combat(e)
	if e.joined then
		if (tonumber(controller_var("gods_phase", "0")) or 0) == 0 then
			set_controller_var("gods_phase", "1");
			-- Solusek withdraws as Mayong steps forward
			eq.depop_all(SOLUSEK);
			eq.zone_emote(MT.Red, "Solusek Ro withdraws into shadow. Mayong Mistmoore smiles.");
		end

		e.self:SetTimerMS("wrath", 20 * 1000);
		e.self:SetTimerMS("bats", 10 * 1000);   -- first wave comes fast
		e.self:SetTimerMS("gods_phase_check", 5 * 1000);
	else
		e.self:StopTimer("wrath");
		e.self:StopTimer("bats");
		e.self:StopTimer("sword");
		e.self:StopTimer("gods_phase_check");
	end
end

function Mayong_Timer(e)
	if e.timer == "wrath" then
		local target = e.self:GetTarget();
		if target ~= nil then
			e.self:CastSpell(11682, target:GetID());  -- Wrath of a New God (frontal AE)
		end
		e.self:SetTimerMS("wrath", 20 * 1000);
	elseif e.timer == "bats" then
		local n = wave_count();
		for i = 1, n do
			local ang = (i / n) * 6.283;
			eq.spawn2(BAT, 0, 0,
				e.self:GetX() + math.cos(ang) * 45,
				e.self:GetY() + math.sin(ang) * 45,
				e.self:GetZ(), 0);
		end
		eq.zone_emote(MT.Red, "Mayong gathers the shadows - a swarm of bats boils out of the dark!");
		e.self:SetTimerMS("bats", 75 * 1000);
	elseif e.timer == "sword" then
		eq.zone_emote(MT.Red, "Mayong raises his sword!");
		e.self:CastSpell(11964, e.self:GetID());  -- Fog of Night (PBAE stand-in)
		e.self:SetTimerMS("sword", 45 * 1000);
	elseif e.timer == "gods_phase_check" then
		local phase = tonumber(controller_var("gods_phase", "1")) or 1;
		local pct = e.self:GetHPRatio();

		if phase == 1 and pct <= 5 then
			-- Mayong "dies" and the sun rises
			set_controller_var("gods_phase", "2");
			eq.zone_emote(MT.Red, "Mayong Mistmoore crumbles into shadow... and Solusek Ro blazes back into being!");
			eq.depop_all(BAT);
			e.self:Depop();
			local solusek = eq.spawn2(SOLUSEK, 0, 0,
				SOLUSEK_SPAWN[1], SOLUSEK_SPAWN[2], SOLUSEK_SPAWN[3], 0);
			if solusek ~= nil then
				local t = e.self:GetTarget();
				if t ~= nil then
					solusek:AddToHateList(t, 1);
				end
			end
			return;
		elseif phase == 3 then
			if pct <= 50 and (tonumber(e.self:GetEntityVariable("sword_on") or "0") or 0) == 0 then
				e.self:SetEntityVariable("sword_on", "1");
				e.self:SetTimerMS("sword", 5 * 1000);
			end

			-- balance: empower the healthier god
			local solusek = eq.get_entity_list():GetNPCByNPCTypeID(SOLUSEK);
			if solusek ~= nil and math.abs(solusek:GetHPRatio() - pct) > 8 then
				local healthier = solusek:GetHPRatio() > pct and solusek or e.self;
				healthier:SetATK(healthier:GetATK() + 25);
				healthier:Emote("draws strength from its waning rival!");
			end
		end

		e.self:SetTimerMS("gods_phase_check", 5 * 1000);
	end
end

function Solusek_Combat(e)
	if e.joined then
		local phase = tonumber(controller_var("gods_phase", "0")) or 0;

		if phase < 2 then
			-- cannot be fought until Mayong has fallen once
			e.self:Heal();
			if e.other ~= nil then
				e.self:RemoveFromHateList(e.other);
			end
			e.self:Say("You face the god of fire before his time. Your audacity is noted.");
			return;
		end

		e.self:SetTimerMS("winds", 18 * 1000);
		e.self:SetTimerMS("flames", 10 * 1000);
		e.self:SetTimerMS("torrent", 60 * 1000);
		e.self:SetTimerMS("gods_phase_check", 5 * 1000);

		if phase == 2 then
			eq.zone_emote(MT.Red, "Solusek Ro attacks! The god of fire will not be denied twice.");
		end
	else
		e.self:StopTimer("winds");
		e.self:StopTimer("flames");
		e.self:StopTimer("torrent");
		e.self:StopTimer("gods_phase_check");
	end
end

function Solusek_Timer(e)
	if e.timer == "winds" then
		local target = e.self:GetTarget();
		if target ~= nil then
			e.self:CastSpell(11681, target:GetID());  -- Deadly Solar Winds
		end
		e.self:SetTimerMS("winds", 18 * 1000);
	elseif e.timer == "flames" then
		local n = wave_count();
		for i = 1, n do
			local ang = (i / n) * 6.283;
			eq.spawn2(FLAME, 0, 0,
				e.self:GetX() + math.cos(ang) * 45,
				e.self:GetY() + math.sin(ang) * 45,
				e.self:GetZ(), 0);
		end
		eq.zone_emote(MT.Red, "Solusek Ro summons a legion of living flame!");
		e.self:SetTimerMS("flames", 60 * 1000);
	elseif e.timer == "torrent" then
		local victim = eq.get_entity_list():GetRandomClient(
			e.self:GetX(), e.self:GetY(), e.self:GetZ(), 500);
		if victim ~= nil then
			eq.zone_emote(MT.Red, "Solusek Ro gazes in anger and prepares a massive torrent of energy!");
			victim:Message(MT.Red, "RUN! The torrent is about to strike you!");
			e.self:SetTimerMS("torrent_blast", 8 * 1000);
		end
		e.self:SetTimerMS("torrent", 60 * 1000);
	elseif e.timer == "torrent_blast" then
		local victim = eq.get_entity_list():GetRandomClient(
			e.self:GetX(), e.self:GetY(), e.self:GetZ(), 500);
		if victim ~= nil then
			e.self:CastSpell(11960, victim:GetID());  -- Solar Strike as the torrent
		end
	elseif e.timer == "gods_phase_check" then
		local phase = tonumber(controller_var("gods_phase", "2")) or 2;
		local pct = e.self:GetHPRatio();

		if phase == 2 and pct <= 75 then
			-- Mayong returns; the final balance begins
			set_controller_var("gods_phase", "3");
			eq.zone_emote(MT.Red, "Mayong Mistmoore steps back out of shadow, whole again. Keep the gods balanced!");
			eq.depop_all(FLAME);
			local mayong = eq.spawn2(MAYONG, 0, 0,
				MAYONG_SPAWN[1], MAYONG_SPAWN[2], MAYONG_SPAWN[3], 0);
			if mayong ~= nil then
				mayong:SetHP(math.floor(mayong:GetMaxHP() * 0.70));
				local t = e.self:GetTarget();
				if t ~= nil then
					mayong:AddToHateList(t, 1);
				end
			end
		end

		e.self:SetTimerMS("gods_phase_check", 5 * 1000);
	end
end

function Mayong_Death(e)
	-- A true death in phase 1 means a burn skipped the 5% transition:
	-- treat it as the phase change instead of recording the flag, so the
	-- raid cannot softlock with Solusek still withdrawn.
	local phase = tonumber(controller_var("gods_phase", "1")) or 1;
	if phase == 1 then
		set_controller_var("gods_phase", "2");
		eq.zone_emote(MT.Red, "Mayong Mistmoore crumbles into shadow... and Solusek Ro blazes back into being!");
		eq.depop_all(BAT);
		local solusek = eq.spawn2(SOLUSEK, 0, 0,
			SOLUSEK_SPAWN[1], SOLUSEK_SPAWN[2], SOLUSEK_SPAWN[3], 0);
		if solusek ~= nil then
			local t = e.self:GetTarget();
			if t ~= nil then
				solusek:AddToHateList(t, 1);
			end
		end
		return;
	end

	set_controller_var("gods_mayong_dead", "1");
	eq.zone_emote(MT.Red, "Mayong Mistmoore falls! Hail the memory left in his wake to record your deed.");
	check_both_dead(e);
end

function Solusek_Death(e)
	-- A true death in phase 2 skips the 75% balance gate: restore both gods
	-- at phase 3 so both flags remain earnable.
	local phase = tonumber(controller_var("gods_phase", "2")) or 2;
	if phase == 2 then
		set_controller_var("gods_phase", "3");
		eq.zone_emote(MT.Red, "Solusek Ro reforms from the sun's fire as Mayong Mistmoore steps from shadow. Keep the gods balanced!");
		eq.depop_all(FLAME);
		local mayong = eq.spawn2(MAYONG, 0, 0,
			MAYONG_SPAWN[1], MAYONG_SPAWN[2], MAYONG_SPAWN[3], 0);
		if mayong ~= nil then
			mayong:SetHP(math.floor(mayong:GetMaxHP() * 0.70));
			local t = e.self:GetTarget();
			if t ~= nil then
				mayong:AddToHateList(t, 1);
			end
		end
		local solusek = eq.spawn2(SOLUSEK, 0, 0,
			SOLUSEK_SPAWN[1], SOLUSEK_SPAWN[2], SOLUSEK_SPAWN[3], 0);
		if solusek ~= nil then
			solusek:SetHP(math.floor(solusek:GetMaxHP() * 0.75));
			local t = e.self:GetTarget();
			if t ~= nil then
				solusek:AddToHateList(t, 1);
			end
		end
		return;
	end

	set_controller_var("gods_solusek_dead", "1");
	eq.zone_emote(MT.Red, "Solusek Ro falls! Hail the memory left in his wake to record your deed.");
	check_both_dead(e);
end

function check_both_dead(e)
	local mayong_dead = controller_var("gods_mayong_dead", "0") == "1";
	local solusek_dead = controller_var("gods_solusek_dead", "0") == "1";
	if not (mayong_dead and solusek_dead) then
		return;
	end

	-- the real Mayong body only "dies" in phase 3; in phase 1 he depops at
	-- 5% instead, so both flags can only be earned once both are truly slain
	eq.depop_all(BAT);
	eq.depop_all(FLAME);

	local expedition = eq.get_expedition();
	local x, y, z = e.self:GetX(), e.self:GetY(), e.self:GetZ();
	if expedition.valid then
		local chest = eq.unique_spawn(CHEST, 0, 0, x, y, z + 5, 0);
		if chest ~= nil then
			expedition:SetLootEventBySpawnID(chest:GetID(), "The Two Gods");
		end
	end
	eq.signal(CONTROLLER, SIGNAL_KEY);
end

function event_encounter_load(e)
	eq.register_npc_event('two_gods', Event.combat,         MAYONG,  Mayong_Combat);
	eq.register_npc_event('two_gods', Event.timer,          MAYONG,  Mayong_Timer);
	eq.register_npc_event('two_gods', Event.death_complete, MAYONG,  Mayong_Death);

	eq.register_npc_event('two_gods', Event.combat,         SOLUSEK, Solusek_Combat);
	eq.register_npc_event('two_gods', Event.timer,          SOLUSEK, Solusek_Timer);
	eq.register_npc_event('two_gods', Event.death_complete, SOLUSEK, Solusek_Death);
end

function event_encounter_unload(e)
end
