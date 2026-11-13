--The Fabled Gorenaire (1120002003, dreadlands expedition version 2)
--FSoV tier (Boss Tuning sheet): L68, 1.3M HP, 300-1000 hit, AC 680.
--Signature mechanic (Mechanics sheet): an AE that dispels buffs every
--cycle (49 Nullify Magic on her target) + Frost Breath (862), and every
--45s she drags a random non-tank to her (GMMove + Root 230) -- the
--summoned player runs back out. Shared guards:
--lua_modules/nms_fabled_toolkit.lua.

local toolkit = require("nms_fabled_toolkit");

local phase = 1;

local BREATH_SPELL  = 862;   -- Frost Breath: AE cold DD + buff strip
local DISPEL_SPELL  = 49;    -- Nullify Magic: strips buffs off her target
local ROOT_SPELL    = 230;   -- Root, pins the dragged player

function event_spawn(e)
	phase = 1;
	e.self:Emote(" descends from the storm, lightning crackling between her horns!");
	e.self:Shout("The storm remembers my name... and it screams it for me!");
	eq.set_next_hp_event(50);
end

function event_combat(e)
	if (e.joined) then
		phase = 1;
		e.self:Emote(" roars, and the Dreadlands' storm turns on you!");
		eq.set_timer("BreathWarn", math.random(1000, 3000));
		eq.set_timer("Dispel", 15000);
		eq.set_timer("Drag", 20000);
		eq.set_timer("Enrage", 60000);
		toolkit.apply_group_hp(e);
		toolkit.start_fight_clock(e);
		eq.stop_timer("reset");
	else
		eq.stop_timer("BreathWarn");
		eq.stop_timer("BreathCast");
		eq.stop_timer("Dispel");
		eq.stop_timer("Drag");
		eq.stop_timer("Enrage");
		eq.set_timer("reset", 10000);
	end
end

function event_timer(e)
	if (e.timer == "BreathWarn") then
		eq.stop_timer(e.timer);
		eq.zone_emote(MT.Emote, "Frost crackles along Gorenaire's scales... take cover!");
		eq.set_timer("BreathCast", 2500);

	elseif (e.timer == "BreathCast") then
		eq.stop_timer(e.timer);
		eq.zone_emote(MT.Emote, "Gorenaire scours the field with frozen lightning!");
		e.self:CameraEffect(1000, 5);
		local target = e.self:GetTarget();
		if (target) then
			e.self:CastSpell(BREATH_SPELL, target:GetID());
		end
		if (e.self:GetHPRatio() < 25) then
			eq.set_timer("BreathWarn", 15000);
		else
			eq.set_timer("BreathWarn", 25000);
		end

	elseif (e.timer == "Dispel") then
		eq.stop_timer(e.timer);
		eq.set_timer("Dispel", 30000);
		local target = e.self:GetTarget();
		if (target) then
			eq.zone_emote(MT.Emote, "Gorenaire's storm washes away protective magic!");
			e.self:CastSpell(DISPEL_SPELL, target:GetID());
		end

	elseif (e.timer == "Drag") then
		eq.stop_timer(e.timer);
		eq.set_timer("Drag", 45000);
		--summon a random non-tank into her coils
		local victim = e.self:GetHateRandom();
		if (victim) then
			eq.zone_emote(MT.Emote, string.format("Gorenaire's storm drags %s into her coils!", victim:GetCleanName()));
			victim:GMMove(e.self:GetX() + 10, e.self:GetY() + 10, e.self:GetZ(), e.self:GetHeading());
			e.self:CastSpell(ROOT_SPELL, victim:GetID());
		end

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
		e.self:Shout("You cannot hold a storm! You cannot kill the rain!");
		eq.set_next_hp_event(25);
	elseif (e.hp_event <= 25 and phase == 2) then
		phase = 3;
		e.self:Shout("THE SKY ITSELF WILL BURY YOU!");
	end
end

function event_death_complete(e)
	e.self:Shout("The storm passes... but it always returns.");
	eq.stop_timer("BreathWarn");
	eq.stop_timer("BreathCast");
	eq.stop_timer("Dispel");
	eq.stop_timer("Drag");
	eq.stop_timer("Enrage");
	toolkit.flag_on_death(e, "fabled_gorenaire");
	eq.world_emote(15, "The Fabled Gorenaire memory has faded....for now.");
end
