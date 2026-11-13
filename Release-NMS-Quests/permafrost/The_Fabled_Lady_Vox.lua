--The Fabled Lady Vox (1120002001, permafrost expedition version 2)
--FRoK tier (Boss Tuning sheet): L67, 400k HP, 250-1000 hit, AC 520.
--Signature mechanic (Mechanics sheet): "Frozen Breath" AE (862 Frost
--Breath, telegraphed) and at 50% "Entombed in Ice" -- a random player is
--rooted (230 Root) and an ice block (1120002006) spawns on them; the
--raid must shatter it within 20s or it bursts (3029 Blizzard Wave AE).
--Shared guards come from lua_modules/nms_fabled_toolkit.lua.

local toolkit = require("nms_fabled_toolkit");

local phase = 1;
local block_entity_id = 0;

local ICE_BLOCK_NPC = 1120002006;
local BREATH_SPELL  = 862;   -- Frost Breath: AE cold DD + buff strip
local ROOT_SPELL    = 230;   -- Root, holds the entombed player
local BOOM_SPELL    = 3029;  -- Blizzard Wave: AE burst around the block

function event_spawn(e)
	phase = 1;
	block_entity_id = 0;
	e.self:Emote(" hisses, and the air itself begins to freeze!");
	e.self:Shout("The Ice Queen remembers... and she does not forgive!");
	eq.set_next_hp_event(50);
end

function event_combat(e)
	if (e.joined) then
		phase = 1;
		e.self:Emote(" roars, and a blizzard answers!");
		eq.set_timer("BreathWarn", math.random(1000, 3000));
		eq.set_timer("Enrage", 60000);
		toolkit.apply_group_hp(e);
		toolkit.start_fight_clock(e);
		eq.stop_timer("reset");
	else
		eq.stop_timer("BreathWarn");
		eq.stop_timer("BreathCast");
		eq.stop_timer("EntombBoom");
		eq.stop_timer("Enrage");
		eq.set_timer("reset", 10000);
	end
end

function event_timer(e)
	if (e.timer == "BreathWarn") then
		eq.stop_timer(e.timer);
		eq.zone_emote(MT.Emote, "A killing frost gathers in Vox's maw... take cover!");
		eq.set_timer("BreathCast", 2500);

	elseif (e.timer == "BreathCast") then
		eq.stop_timer(e.timer);
		eq.zone_emote(MT.Emote, "Vox exhales a frozen gale!");
		e.self:CameraEffect(1000, 5);
		local target = e.self:GetTarget();
		if (target) then
			e.self:CastSpell(BREATH_SPELL, target:GetID());
		end
		--the AE halves once she is below 25%
		if (e.self:GetHPRatio() < 25) then
			eq.set_timer("BreathWarn", 15000);
		else
			eq.set_timer("BreathWarn", 25000);
		end

	elseif (e.timer == "EntombBoom") then
		eq.stop_timer(e.timer);
		local block = eq.get_entity_list():GetNPCByID(block_entity_id);
		if (block and block.valid) then
			eq.zone_emote(MT.Emote, "The ice block bursts apart in a shower of frozen shards!");
			block:CastSpell(BOOM_SPELL, block:GetID());
			block:Depop();
		end
		block_entity_id = 0;

	elseif (e.timer == "Enrage") then
		eq.set_timer("Enrage", 60000);
		toolkit.enrage_tick(e);

	elseif (e.timer == "reset") then
		eq.stop_timer(e.timer);
		e.self:SetHP(e.self:GetMaxHP());
		phase = 1;
		block_entity_id = 0;
		toolkit.reset_fight(e);
		eq.depop_all(ICE_BLOCK_NPC);
		eq.set_next_hp_event(50);
	end
end

function event_hp(e)
	if (e.hp_event <= 50 and phase == 1) then
		phase = 2;
		e.self:Shout("WARMTH! You bring WARMTH into my hall! I will bury it in ice!");
		eq.set_next_hp_event(25);
		--entomb a random raider: root them and drop a block on their spot
		local victim = e.self:GetHateRandom();
		if (victim) then
			e.self:CastSpell(ROOT_SPELL, victim:GetID());
			block_entity_id = eq.spawn2(ICE_BLOCK_NPC, 0, 0, victim:GetX(), victim:GetY(), victim:GetZ(), victim:GetHeading());
			eq.zone_emote(MT.Emote, string.format("%s is entombed in ice! Shatter the block before it bursts!", victim:GetCleanName()));
			eq.set_timer("EntombBoom", 20000);
		end
	elseif (e.hp_event <= 25 and phase == 2) then
		phase = 3;
		e.self:Shout("The cold... the blessed cold... I REMEMBER IT ALL!");
	end
end

function event_death_complete(e)
	e.self:Shout("So the fire still burns hotter than the ice... until we meet again.");
	eq.stop_timer("BreathWarn");
	eq.stop_timer("BreathCast");
	eq.stop_timer("EntombBoom");
	eq.stop_timer("Enrage");
	eq.depop_all(ICE_BLOCK_NPC);
	toolkit.flag_on_death(e, "fabled_vox");
	eq.world_emote(15, "The Fabled Lady Vox memory has faded....for now.");
end
