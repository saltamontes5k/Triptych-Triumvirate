--The Fabled Talendor (1120002005, skyfire expedition version 2)
--FSoV tier (Boss Tuning sheet): L68, 1.3M HP, 300-1000 hit, AC 680.
--Signature mechanic (Mechanics sheet): a short resistable AE fear every
--40s (2657 Terrifying Darkness, telegraphed) plus the fire beam tank
--buster (42231). Counterplay: fear immunity/resist gear, healers
--pre-cast. Shared guards: lua_modules/nms_fabled_toolkit.lua.

local toolkit = require("nms_fabled_toolkit");

local phase = 1;

local BUSTER_SPELL  = 42231;  -- fire beam tank buster (Nagafen's beam)
local FEAR_SPELL    = 2657;   -- Terrifying Darkness: AE fear

function event_spawn(e)
	phase = 1;
	e.self:Emote(" wheels overhead, ash raining from her wings!");
	e.self:Shout("I am the flame that lit the Skyfire! Kneel, or learn what terror means!");
	eq.set_next_hp_event(50);
end

function event_combat(e)
	if (e.joined) then
		phase = 1;
		e.self:Emote(" roars, and the burning skies darken!");
		eq.set_timer("Buster", math.random(1000, 3000));
		eq.set_timer("FearWarn", 15000);
		eq.set_timer("Enrage", 60000);
		toolkit.apply_group_hp(e);
		toolkit.start_fight_clock(e);
		eq.stop_timer("reset");
	else
		eq.stop_timer("Buster");
		eq.stop_timer("FearWarn");
		eq.stop_timer("FearCast");
		eq.stop_timer("Enrage");
		eq.set_timer("reset", 10000);
	end
end

function event_timer(e)
	if (e.timer == "Buster") then
		eq.stop_timer(e.timer);
		eq.set_timer("Buster", 10000);
		local target = e.self:GetTarget();
		if (target) then
			e.self:CastSpell(BUSTER_SPELL, target:GetID());
		end

	elseif (e.timer == "FearWarn") then
		eq.stop_timer(e.timer);
		eq.zone_emote(MT.Emote, "Terror gathers behind Talendor's eyes... brace yourselves!");
		eq.set_timer("FearCast", 2500);

	elseif (e.timer == "FearCast") then
		eq.stop_timer(e.timer);
		eq.zone_emote(MT.Emote, "A wave of mind-breaking terror rolls across the burning sands!");
		e.self:CameraEffect(1000, 5);
		e.self:CastSpell(FEAR_SPELL, e.self:GetID());
		eq.set_timer("FearWarn", 40000);

	elseif (e.timer == "Enrage") then
		eq.set_timer("Enrage", 60000);
		toolkit.enrage_tick(e);

	elseif (e.timer == "reset") then
		eq.stop_timer(e.timer);
		e.self:SetHP(e.self:GetMaxHP());
		phase = 1;
		toolkit.reset_fight(e);
		eq.set_next_hp_event(50);
	end
end

function event_hp(e)
	if (e.hp_event <= 50 and phase == 1) then
		phase = 2;
		e.self:Shout("FEAR! Let me teach you what fear truly is!");
		eq.set_next_hp_event(25);
	elseif (e.hp_event <= 25 and phase == 2) then
		phase = 3;
		e.self:Shout("RUN! RUN LIKE THE COWARDS YOU ARE!");
	end
end

function event_death_complete(e)
	e.self:Shout("Even the flame gutters... but it remembers who snuffed it.");
	eq.stop_timer("Buster");
	eq.stop_timer("FearWarn");
	eq.stop_timer("FearCast");
	eq.stop_timer("Enrage");
	toolkit.flag_on_death(e, "fabled_talendor");
	eq.world_emote(15, "The Fabled Talendor memory has faded....for now.");
end
