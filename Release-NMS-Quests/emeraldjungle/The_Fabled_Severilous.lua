--The Fabled Severilous (1120002004, emeraldjungle expedition version 2)
--FSoV tier (Boss Tuning sheet): L68, 1.3M HP, 300-1000 hit, AC 680.
--Signature mechanic (Mechanics sheet): "Ancient Venom" (44038, authored
--in v357) -- a poison DoT that spreads to players within 15 units of the
--carrier each cycle; plus his classic AE Poison Breath (857). Counterplay:
--spread out; cure carriers. Shared guards:
--lua_modules/nms_fabled_toolkit.lua.

local toolkit = require("nms_fabled_toolkit");

local phase = 1;

local BREATH_SPELL  = 857;    -- Poison Breath: AE poison
local VENOM_SPELL   = 44041;  -- Ancient Venom (authored in v357)
local SPREAD_RADIUS = 15;

function event_spawn(e)
	phase = 1;
	e.self:Emote(" crashes through the canopy, vines withering where he steps!");
	e.self:Shout("The jungle remembers every footstep... yours will be its last!");
	eq.set_next_hp_event(50);
end

function event_combat(e)
	if (e.joined) then
		phase = 1;
		e.self:Emote(" hisses, and the jungle's poison finds you!");
		eq.set_timer("Venom", 12000);
		eq.set_timer("BreathWarn", 8000);
		eq.set_timer("Enrage", 60000);
		toolkit.apply_group_hp(e);
		toolkit.start_fight_clock(e);
		eq.stop_timer("reset");
	else
		eq.stop_timer("Venom");
		eq.stop_timer("BreathWarn");
		eq.stop_timer("BreathCast");
		eq.stop_timer("Enrage");
		eq.set_timer("reset", 10000);
	end
end

--Spread the venom: everyone within SPREAD_RADIUS of the current target
--inherits the DoT unless they move out (counterplay per the design).
function SpreadVenom(e)
	local target = e.self:GetTarget();
	if (not target) then
		return;
	end
	local tx = target:GetX();
	local ty = target:GetY();
	local tz = target:GetZ();
	local hate_list = e.self:GetHateList();
	for _, entry in ipairs(hate_list) do
		local mob = entry.entity;
		if (mob and mob.valid and mob:IsClient()) then
			if (mob:CalculateDistance(tx, ty, tz) <= SPREAD_RADIUS) then
				e.self:CastSpell(VENOM_SPELL, mob:GetID());
			end
		end
	end
end

function event_timer(e)
	if (e.timer == "Venom") then
		eq.stop_timer(e.timer);
		eq.set_timer("Venom", 20000);
		local target = e.self:GetTarget();
		if (target) then
			eq.zone_emote(MT.Emote, "Ancient venom drips from Severilous's fangs -- spread out or share it!");
			e.self:CastSpell(VENOM_SPELL, target:GetID());
			SpreadVenom(e);
		end

	elseif (e.timer == "BreathWarn") then
		eq.stop_timer(e.timer);
		eq.zone_emote(MT.Emote, "Severilous's throat swells with swamp bile... spread out!");
		eq.set_timer("BreathCast", 2500);

	elseif (e.timer == "BreathCast") then
		eq.stop_timer(e.timer);
		eq.zone_emote(MT.Emote, "Severilous floods the clearing with poison breath!");
		e.self:CameraEffect(1000, 5);
		e.self:CastSpell(BREATH_SPELL, e.self:GetID());
		eq.set_timer("BreathWarn", 40000);

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
		e.self:Shout("EVERY ROOT AND VINE WILL DRINK YOUR BLOOD!");
		eq.set_next_hp_event(25);
	elseif (e.hp_event <= 25 and phase == 2) then
		phase = 3;
		e.self:Shout("THE JUNGLE ITSELF WILL FEED ON YOU!");
	end
end

function event_death_complete(e)
	e.self:Shout("The jungle keeps its dead... I am only borrowing.");
	eq.stop_timer("Venom");
	eq.stop_timer("BreathWarn");
	eq.stop_timer("BreathCast");
	eq.stop_timer("Enrage");
	toolkit.flag_on_death(e, "fabled_severilous");
	eq.world_emote(15, "The Fabled Severilous memory has faded....for now.");
end
