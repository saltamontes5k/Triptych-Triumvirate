--The Fabled Trakanon (1120002002, sebilis expedition version 2)
--FSoV tier (Boss Tuning sheet): L68, 1.3M HP, 300-1000 hit, AC 680.
--Signature mechanic (Mechanics sheet): "Trakanon's Toxin" poison on the
--tank (44037, cure or tank-swap) + his classic AE Poison Breath (857)
--+ fire beam buster (42231); at 60% and 30% "the fallen rise" -- undead
--slaves (109042) pour out of the swamp. Shared guards:
--lua_modules/nms_fabled_toolkit.lua.

local toolkit = require("nms_fabled_toolkit");

local phase = 1;

local UNDEAD_NPC    = 109042;  -- an_undead_slave (sebilis)
local BREATH_SPELL  = 857;     -- Poison Breath: AE poison
local TOXIN_SPELL   = 44040;   -- Trakanon's Toxin (authored in v357)
local BUSTER_SPELL  = 42231;  -- fire beam tank buster (Nagafen's beam)

function event_spawn(e)
	phase = 1;
	e.self:Emote(" rises from the swamp, rotting scales sloughing off!");
	e.self:Shout("I remember dying... and I remember WHO fed me to the sewer!");
	eq.set_next_hp_event(60);
end

function event_combat(e)
	if (e.joined) then
		phase = 1;
		e.self:Emote(" bellows, and the swamp answers with the stench of the grave!");
		eq.set_timer("Buster", math.random(1000, 3000));
		eq.set_timer("BreathWarn", 8000);
		eq.set_timer("Toxin", 12000);
		eq.set_timer("Enrage", 60000);
		toolkit.apply_group_hp(e);
		toolkit.start_fight_clock(e);
		eq.stop_timer("reset");
	else
		eq.stop_timer("Buster");
		eq.stop_timer("BreathWarn");
		eq.stop_timer("BreathCast");
		eq.stop_timer("Toxin");
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

	elseif (e.timer == "BreathWarn") then
		eq.stop_timer(e.timer);
		eq.zone_emote(MT.Emote, "Trakanon's throat bulges with septic bile... spread out!");
		eq.set_timer("BreathCast", 2500);

	elseif (e.timer == "BreathCast") then
		eq.stop_timer(e.timer);
		eq.zone_emote(MT.Emote, "Trakanon floods the chamber with poison breath!");
		e.self:CameraEffect(1000, 5);
		e.self:CastSpell(BREATH_SPELL, e.self:GetID());
		eq.set_timer("BreathWarn", 30000);

	elseif (e.timer == "Toxin") then
		eq.stop_timer(e.timer);
		eq.set_timer("Toxin", 30000);
		local target = e.self:GetTarget();
		if (target) then
			--stacking poison on the tank: cure it or swap tanks
			e.self:CastSpell(TOXIN_SPELL, target:GetID());
		end

	elseif (e.timer == "Enrage") then
		eq.set_timer("Enrage", 60000);
		toolkit.enrage_tick(e);

	elseif (e.timer == "reset") then
		eq.stop_timer(e.timer);
		e.self:SetHP(e.self:GetMaxHP());
		phase = 1;
		toolkit.reset_fight(e);
		eq.depop_all(UNDEAD_NPC);
		eq.set_next_hp_event(60);
	end
end

function SpawnTheFallen(e)
	local xloc = e.self:GetX();
	local yloc = e.self:GetY();
	local zloc = e.self:GetZ();
	local heading = e.self:GetHeading();
	eq.depop_all(UNDEAD_NPC);
	eq.zone_emote(MT.Emote, "The fallen rise from the swamp to defend their devourer!");
	for _ = 1, 6 do
		eq.spawn2(UNDEAD_NPC, 0, 0, xloc + math.random(-45, 45), yloc + math.random(-45, 45), zloc, heading);
	end
end

function event_hp(e)
	if (e.hp_event <= 60 and phase == 1) then
		phase = 2;
		e.self:Shout("RISE! ALL OF YOU! The living trespass in the House of Death!");
		SpawnTheFallen(e);
		eq.set_next_hp_event(30);
	elseif (e.hp_event <= 30 and phase == 2) then
		phase = 3;
		e.self:Shout("DEATH IS NOT THE END HERE! RISE AGAIN!");
		SpawnTheFallen(e);
	end
end

function event_death_complete(e)
	e.self:Shout("Again I fall... but the sewer always keeps what it is given.");
	eq.stop_timer("Buster");
	eq.stop_timer("BreathWarn");
	eq.stop_timer("BreathCast");
	eq.stop_timer("Toxin");
	eq.stop_timer("Enrage");
	eq.depop_all(UNDEAD_NPC);
	toolkit.flag_on_death(e, "fabled_trakanon");
	eq.world_emote(15, "The Fabled Trakanon memory has faded....for now.");
end
