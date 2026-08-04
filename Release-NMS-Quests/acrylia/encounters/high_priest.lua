-- High Priest Gakkernog

-- NPCs used in event
local shackles				= 154309;
local gakkernog				= 154390;
local fake_gakkernog		= 154308;
local grimling_high_priest	= 154307;
local grimlings				= {
	154353,	-- lvl 50 warrior
	154354,	-- lvl 50 SK
	154355,	-- lvl 55 warrior
	154356,	-- lvl 55 SK
	154363,	-- lvl 55 cleric
	154402	-- lvl 55 wiz
};

-- Vars
local sacrifice				= nil;
local boss					= nil;
local started				= false;
local ghp_combat			= false;
local gak_combat			= false
local gak_trigger			= false
local initial				= 30;		-- Initial time to check if player is in proximity for event start (30sec default)
local wave_timer			= 30; 	-- Set in seconds for total wave timer  (3 min default)
local delay					= 15		-- Set in seconds to provide delay between HP dialogue between waves and minions spawning (15 seconds default)
local wave					= 0;
local shackle_failure_dist	= 50;		-- Normally this is 10, but for NMS we are making it a var for adjustments
local shackle_timer_check	= 1;		-- Time between location/failure checks, Default: 1s

-- HP_Shackles
function evt_shackles_spawn(e)
	EventReset();
end

function evt_shackles_enter(e)
	if not started and eq.get_entity_list():IsMobSpawnedByNpcTypeID(grimling_high_priest) then
		sacrifice = e.other:CharacterID();
		eq.set_timer("player_check",initial*1000); 	-- Initial player check to start event is longer
	elseif started then
		if eq.get_entity_list():IsMobSpawnedByNpcTypeID(gakkernog) then
			eq.signal(gakkernog,2);				-- Depop named HP if active
		else
			eq.signal(grimling_high_priest,2);	-- Deactivate HP if active
		end
		HPShout(true); -- Announce resetting of ring
		EventReset();
	end
end

function evt_shackles_timer(e)
	if e.timer == "player_check" then
		if wave == -1 then
			eq.stop_timer("player_check");
		elseif not player_check() then
			eq.stop_timer(e.timer);
			HPShout(true);							-- Announce resetting of ring
			EventReset();
		elseif not started then						-- Start Event
			eq.stop_timer("player_check");
			eq.set_timer("player_check",shackle_timer_check * 1000);
			eq.set_timer("waves",15 * 1000);		-- First timer is short
			started = true
			HPShout();								-- Initial shout for event start
			eq.clear_proximity();
			eq.set_proximity(100, 125, -640, -615);
		end
	elseif e.timer == "waves" then
		wave = wave + 1;
		if wave == 1 then
			eq.stop_timer(e.timer);
			eq.set_timer("waves", wave_timer * 1000);
		end

		if wave == -1 then
			eq.stop_timer(e.timer)
			return false;
		elseif wave <= 5 then
			spawn_mob(grimlings[1],1);
			spawn_mob(grimlings[2],2);
		elseif wave == 6 then
			HPShout();
			eq.set_timer("waves", delay * 1000);
		elseif wave <= 11 then
			eq.set_timer("waves", wave_timer * 1000);
			spawn_mob(grimlings[math.random(3,6)],1);
			spawn_mob(grimlings[math.random(3,6)],2);
		elseif wave == 12 then
			HPShout();
			eq.set_timer("waves", delay * 1000);
		elseif wave <= 17 then
			eq.set_timer("waves", wave_timer * 1000);
			spawn_mob(grimlings[math.random(3,6)],1);
			spawn_mob(grimlings[math.random(3,6)],2);
			spawn_mob(grimlings[math.random(3,6)],3);
		elseif wave == 18 then
			eq.stop_timer(e.timer);
			HPShout();
			wave = -1;
			eq.set_timer("HP",delay*1000);
		end
	elseif e.timer == "HP" then
		eq.stop_timer(e.timer);	
		player = eq.get_entity_list():GetClientByCharID(sacrifice);
		local instance_id = eq.get_zone_instance_id();

		-- Random roll to see if named HP will spawn.  
		local roll = math.random(1,10);
		if roll >= 7 then
			boss = gakkernog;
			eq.depop_with_timer(grimling_high_priest);
			eq.unique_spawn(gakkernog,0,0,142,-690,2.3,130);
		else
			boss = grimling_high_priest;
		end

		eq.stop_timer("player_check");
		player:MovePCInstance(154, instance_id, 150, -690, 2, 384);
		player:Message(MT.Yellow,"You have been summoned!");
		eq.signal(boss,sacrifice);	-- Signal to hp to aggro the assigned PC sacrifice after summon
	end
end

function evt_shackles_signal(e)
	if e.signal == 1 then		--signal from HP death
		EventReset();
		cleanup();
	end
end

-- #a_grimling_high_priest
function evt_grimling_high_priest_spawn(e)
	deactivate(e.self)
end

function evt_grimling_high_priest_combat(e)
	if not e.joined then
		ghp_combat = false;
	else
		ghp_combat = true;
		eq.stop_timer("deactivate");
		eq.set_timer("combat_check",1*1000);
	end
end

function evt_grimling_high_priest_timer(e)
	if e.timer == "combat_check" then
		if not ghp_combat then
			eq.stop_timer("combat_check");
			eq.set_timer("deactivate", 3 * 60 * 1000);
		end
	elseif e.timer == "deactivate" then
		if not ghp_combat then
			eq.stop_timer("combat_check");
			eq.signal(shackles,1);
			deactivate(e.self);
		end
	end
end

function evt_grimling_high_priest_signal(e)
	if e.signal == 2 then
		deactivate(e.self);
	else -- Signal from event trigger to attack designated PC after summon
		activate(e.self);
		e.self:AddToHateList(eq.get_entity_list():GetClientByCharID(e.signal));
	end
end

function evt_grimling_high_priest_death_complete(e)
	eq.signal(shackles,1);
end

-- High Priest Gakkernog
function evt_gakkernog_spawn(e)
	e.self:Shout("Enough play! Now you die! You will regret disturbing my ritual!");
end

function evt_gakkernog_combat(e)
	if not e.joined then
		gak_combat = false;
	else
		gak_combat = true;
		eq.stop_timer("depop");
		eq.set_timer("combat_check", 1 * 1000);
	end
end

function evt_gakkernog_timer(e)
	if e.timer == "combat_check" then
		if not gak_combat then
			eq.stop_timer("combat_check");
			eq.set_timer("depop", 3 * 60 * 1000);
		end
	elseif e.timer == "depop" then
		if not gak_combat and gak_trigger then
			eq.stop_timer("combat_check");
			eq.get_entity_list():GetSpawnByID(3387942):Repop(5); -- Repop HP trigger if event fails
			eq.signal(shackles,1)
			eq.depop();
		end
	end
end

function evt_gakkernog_signal(e)
	if e.signal == 2 then
		e.self:Shout("The tresspassers have ruined our sacred ritual!  We must restart!");
		eq.depop();
	else
		e.self:AddToHateList(eq.get_entity_list():GetClientByCharID(e.signal));
		gak_trigger = true;
	end
end

function evt_gakkernog_death_complete(e)
	eq.signal(shackles,1)
end

-- Add Logic
function evt_add_spawn(e)
    eq.set_timer('depop', 60 * 1000);
end

function evt_add_combat(e)
    if e.joined then
        eq.stop_timer('depop');
    else
        eq.set_timer('depop', 60 * 1000);
    end
end

function evt_add_timer(e)
    if e.timer == 'depop' then
        e.self:Say("The tresspassers have been slain. Glory to the master!");
        eq.depop();
    end
end

-- General Functions
function EventReset()
	wave		= 0;
	started		= false;
	ghp_combat	= false;
	gak_combat	= false;
	gak_trigger	= false;
	sacrifice	= nil;
	boss		= nil;
	eq.clear_proximity();
	eq.set_proximity(36, 45, -730, -720);
	cleanup();
end

function cleanup()
	eq.stop_all_timers();
end

function spawn_mob(NPCID, loc)
	local xloc	= { 156,  156,  152};
	local yloc	= {-737, -719, -728};
	local zloc	= {   2,    2,    2};
	local hloc	= { 194,  194,  194};
	local mobz	= eq.spawn2(NPCID,0,0,xloc[loc] ,yloc[loc] ,zloc[loc],hloc[loc]);

	mobz:AddToHateList(eq.get_entity_list():GetClientByCharID(sacrifice));
end

function HPShout(restart)
	local hp = eq.get_entity_list():GetMobByNpcTypeID(grimling_high_priest);

	if restart then
		hp:Shout("Master! The tresspassers have interrupted our sacred ritual.  We must restart!");
	elseif wave == 0 then
		hp:Shout("Master, intruders have wandered into our sacred altar! I beg, grant me power to make them a worthy sacrifice!");
	elseif wave == 6 then
		hp:Shout("Master, the intruders are powerful. I beg, send stronger minions!");
	elseif wave == 12 then
		hp:Shout("Master, the tresspassers persist. I beg, make them pay for their foolishness!");
	elseif wave == 18 then
		hp:Shout("Master! The minions have failed. I beg, empower me to rid the realm of the vile unbelievers!");
	end
end

function player_check(e)
	-- checks for players
	local player_list = eq.get_entity_list():GetClientList();

	if player_list ~= nil then
		for player in player_list.entries do
			if player:CalculateDistance(40, -726, 11) <= shackle_failure_dist and player:CharacterID() == sacrifice then
				if not player:CastToMob():IsRooted() then
					eq.get_entity_list():GetMobByNpcTypeID(grimling_high_priest):CastSpell(2860, player:GetID(),0,0,0,0,0,0,-2000);  --#High Priest Gakkernog casting animation
				end
				return true; -- if player within 1 and not FD, return true
			end
		end
	end
	return false; -- if nothing checks out, returns false
end

function deactivate(mob)
	mob:SetHeading(130);
	mob:SetBodyType(11, true);
	mob:SetSpecialAbility(24, 1);
	mob:WipeHateList();
end

function activate(mob)
	mob:SetBodyType(1, true);
	mob:SetSpecialAbility(24, 0);
end

-- Encounter Load
function event_encounter_load(e)
	eq.register_npc_event("high_priest",		Event.spawn,			shackles,				evt_shackles_spawn);
	eq.register_npc_event("high_priest",		Event.enter,			shackles,				evt_shackles_enter);
	eq.register_npc_event("high_priest",		Event.timer,			shackles,				evt_shackles_timer);
	eq.register_npc_event("high_priest",		Event.signal,			shackles,				evt_shackles_signal);

	eq.register_npc_event("high_priest",		Event.spawn,			grimling_high_priest,	evt_grimling_high_priest_spawn);
	eq.register_npc_event("high_priest",		Event.combat,			grimling_high_priest,	evt_grimling_high_priest_combat);
	eq.register_npc_event("high_priest",		Event.timer,			grimling_high_priest,	evt_grimling_high_priest_timer);
	eq.register_npc_event("high_priest",		Event.signal,			grimling_high_priest,	evt_grimling_high_priest_signal);
	eq.register_npc_event("high_priest",		Event.death_complete,	grimling_high_priest,	evt_grimling_high_priest_death_complete);

	eq.register_npc_event("high_priest",		Event.spawn,			gakkernog,				evt_gakkernog_spawn);
	eq.register_npc_event("high_priest",		Event.combat,			gakkernog,				evt_gakkernog_combat);
	eq.register_npc_event("high_priest",		Event.timer,			gakkernog,				evt_gakkernog_timer);
	eq.register_npc_event("high_priest",		Event.signal,			gakkernog,				evt_gakkernog_signal);
	eq.register_npc_event("high_priest",		Event.death_complete,	gakkernog,				evt_gakkernog_death_complete);

	for i = 1, #grimlings do
		eq.register_npc_event("high_priest",	Event.spawn,			grimlings[i],			evt_add_spawn);
		eq.register_npc_event("high_priest",	Event.combat,			grimlings[i],			evt_add_combat);
		eq.register_npc_event("high_priest",	Event.timer,			grimlings[i],			evt_add_timer);
	end
end
