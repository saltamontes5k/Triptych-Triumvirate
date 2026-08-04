-- Archmage Encounter
-- NOTE: Items missing from Archmage - Archmage's Sandals and Shiny Metallic Sash

-- NPCs used in event
local controller            = 154304;
local archmage_gorraferg    = 154388;
local grimling_archmage     = 154103;
local warder                = 154377;
local elite_guards          = 154099;
local grimlings             = {
    154381, -- NPC: a_grimling_alchemist
	154382, -- NPC: a_grimling_battlepriest 
	154383, -- NPC: a_grimling_cleanser
	154384, -- NPC: a_grimling_corpsemaster
	154385, -- NPC: a_grimling_deathdealer 
	154386, -- NPC: a_grimling_possessor
	154387  -- NPC: a_grimling_skullsplinterer
};

-- Spawns
local spawns            = {{228,11,-7,384}, {238,11,-7,384}, {248,11,-7,384},{258,11,-7,384}, {228,-21,-7,384}, {238,-21,-7,384}, {248,-21,-7,384}, {258,-21,-7,384}, {225,-7,-7,384}, {260,-7,-7,384}};

-- Vars
local started           = false;
local wave              = 0;
local wave_timer        = 15;   --initial wave time

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

-- Controller
function evt_controller_spawn(e)
    started = false;
end

function evt_controller_timer(e)
    if e.timer == "main" then
		wave_timer = process_wave();
		eq.set_timer("main", wave_timer * 1000);
		WaveShout(wave);
	end
end

function evt_controller_signal(e)
    if e.signal == 1 then		--signal from Archmage death
		EventReset();
		eq.stop_all_timers();
	elseif e.signal == 99 then
		wave        = 0;
		wave_timer  = 15;
		eq.set_timer("main", wave_timer * 1000);    -- 15 seconds for initial wave
		eq.spawn2(warder,0,0,208,-84,-7,510);       -- spawns grimling warder
	end
end

-- Archmage Gorraferg
function evt_archmage_gorraferg_spawn(e)
    e.self:Shout("Enough play! Now you die! You will regret disturbing my ritual!");
	eq.set_timer("depop", 10 * 60 * 1000);
end

function evt_archmage_gorraferg_timer(e)
    if e.timer == "depop" then
		eq.signal(controller,1);
		eq.depop();
	end
end

function evt_archmage_gorraferg_death_complete(e)
    eq.signal(controller,1);
end

-- the_grimling_archmage
function evt_grimling_archmage_spawn(e)
    started = false;
end

function evt_grimling_archmage_timer(e)
    if e.timer == "check" then
		if not started and player_check(e.self, 30) then
			eq.stop_timer(e.timer);
			eq.set_timer("check", 15 * 1000);
			started = true;
			eq.signal(controller,99);
			e.self:Shout("Master! The intruders have interrupted my sacred work! I beg, send minions to my aid!");
		elseif started and not player_check(e.self, 75) then
			eq.stop_timer(e.timer)
			eq.signal(controller,1);
			eq.depop_with_timer();
		end
	end
end

function evt_grimling_archmage_signal(e)
    if e.signal == 1 then
		eq.spawn2(archmage_gorraferg,0,0,e.self:GetX(),e.self:GetY(),e.self:GetZ(),e.self:GetHeading());
		eq.depop_with_timer();
	elseif e.signal == 99 then
		local npc = eq.get_entity_list():IsMobSpawnedByNpcTypeID(elite_guards);
		if not npc then
			eq.set_timer("check",500);
		end
	end
end

function evt_grimling_archmage_death_complete(e)
    eq.signal(controller,1);
end

-- General Functions
function WaveShout(wav)
	AM = eq.get_entity_list():GetMobByNpcTypeID(grimling_archmage);

	if wav == 1 then
		AM:Shout("By the power of the master, I summon forth his minions to cleanse the realm of intruders...");
	elseif wav == 2 then
		AM:Shout("You tresspassers are still here? You will not interrupt my work! I will summon a legion of our kind if needed!");
	elseif wav == 3 then
		AM:Shout("Master! More of our people are needed to cleanse the sacred palace. I beg, make the intruders pay with their lives!");
	elseif wav == 4 then
		AM:Shout("You fools! You do not understand! Your efforts here are fruitless. You will die and your remains will live again to serve us!");
	elseif wav == 5 then
		AM:Shout("Master! The intruders persist! I beg, teach them humility through defeat!");
	elseif wav == 6 then
		AM:Shout("Your petty resistance will only make it worse for you in the end. Leave, or die!!");
	elseif wav == 7 then
		AM:Shout("Master, they are weakening! I beg, finish them!");
	elseif wav == 8 then
		AM:Shout("Master, the intruders persist! I beg, give me the power to overcome them. May their flesh burn on your sacred altar!");
	end
end

function EventReset()
	started = false;
	wave    = 0;
	eq.signal(warder,2)
end

function process_wave()
	wave = wave + 1;

	if wave <= 2 then
		spawn_mob(grimlings,spawns);
		return 8 * 6;  -- 8 ticks
	elseif wave == 3 then
		spawn_mob(grimlings,spawns);
		return 18 * 6;  -- 18 ticks
	elseif wave < 8 then
		spawn_mob(grimlings,spawns);
		return 8 * 6;  -- 8 ticks
	elseif wave == 8 then
		eq.stop_timer("main");
		eq.signal(grimling_archmage, 1, 12 * 1000);
		return -1;
	end
end

function spawn_mob(NPCID, loc)
	local s = math.random(7,10);
	for n = 1, s do
	eq.spawn2(NPCID[math.random(1,7)],0,0,unpack(loc[n]));
	end
end

function player_check(npc,dist)
	-- checks for players
	local player_list = eq.get_entity_list():GetClientList();
	if player_list ~= nil then
		for player in player_list.entries do
			if player:CalculateDistance(npc:GetX(),npc:GetY(),npc:GetZ()) <= dist and not player:GetFeigned() then
				return true; -- player is within triggering range of archmage and not FD
			end
		end
	end
	return false; -- if nothing checks out, returns false
end

-- Encounter Load
function event_encounter_load(e)
	eq.register_npc_event("archmage",		Event.spawn,			controller,				evt_controller_spawn);
	eq.register_npc_event("archmage",		Event.timer,			controller,				evt_controller_timer);
	eq.register_npc_event("archmage",		Event.signal,			controller,				evt_controller_signal);

    eq.register_npc_event("archmage",		Event.spawn,			archmage_gorraferg,		evt_archmage_gorraferg_spawn);
    eq.register_npc_event("archmage",		Event.timer,			archmage_gorraferg,     evt_archmage_gorraferg_timer);
    eq.register_npc_event("archmage",		Event.death_complete,	archmage_gorraferg,		evt_archmage_gorraferg_death_complete);

    -- grimling_archmage
    eq.register_npc_event("archmage",		Event.spawn,			grimling_archmage,		evt_grimling_archmage_spawn);
    eq.register_npc_event("archmage",		Event.timer,			grimling_archmage,      evt_grimling_archmage_timer);
    eq.register_npc_event("archmage",		Event.signal,			grimling_archmage,		evt_grimling_archmage_signal);
    eq.register_npc_event("archmage",		Event.death_complete,	grimling_archmage,		evt_grimling_archmage_death_complete)

	for i = 1, #grimlings do
		eq.register_npc_event("archmage",	Event.spawn,			grimlings[i],			evt_add_spawn);
		eq.register_npc_event("archmage",	Event.combat,			grimlings[i],			evt_add_combat);
		eq.register_npc_event("archmage",	Event.timer,			grimlings[i],			evt_add_timer);
	end
end
