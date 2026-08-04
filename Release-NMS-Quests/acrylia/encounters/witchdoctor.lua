-- Witchdoctor Gnorgtarg Encounter

--[[ELEMENTAL IMMUNE SUMMONER LISTING BY NPC ID
MR:	154393
FR:	154394
CR:	154392
PR:	154395
]]

local controller			= 154404;
local fake_witchdoctor		= 154401;
local real_witchdoctor		= 154391;
local furious_apprentice	= 154123;
local grimling_apprentice	= 154115;
local enraged_apprentice	= 154406;

local cr_summoner			= 154392;
local mr_summoner			= 154393;
local fr_summoner			= 154394;
local pr_summoner			= 154395;
local summoners				= {154392,154393,154394,154395};

local spawnpoints			= {3387980, 3387981, 3387982, 3387984, 3387983, 3387985, 3387986};

-- Vars
local started				= false;
local boss_timer			= 10 * 60;
local wd_counter			= 0;
local overall_counter		= 0;

-- Controller
function evt_controller_spawn(e)
	eq.set_timer("reset", 5 * 1000);
end

function evt_controller_signal(e)
	if e.signal == 1 then
		EventReset();
	elseif e.signal == 10 then
		if not started then
			started = true;
			eq.set_timer("apprentices", 3 * 1000);
		end
	elseif e.signal == 20 then
		local WD = eq.get_entity_list():GetNPCByNPCTypeID(fake_witchdoctor);
		WD:Emote("staggers as elemental energies drain from his body.")
	elseif e.signal == 99 then	--signal for Khati Sha event start (removes witchdoctor related event mobs)
		eq.stop_all_timers();
		started = true;
		for i = 1, #summoners do
			eq.depop_all(summoners[i]);
		end
		DepopTrash();
		eq.set_timer("reset", 15 * 60 * 1000);
	end
end

function evt_controller_timer(e)
	if e.timer == "apprentices" then
		if not eq.get_entity_list():IsMobSpawnedByNpcTypeID(furious_apprentice) and not eq.get_entity_list():IsMobSpawnedByNpcTypeID(grimling_apprentice) then
			eq.stop_timer(e.timer);
			eq.set_timer("event_start", 60 * 1000);
		elseif overall_counter == 40 then
			eq.stop_timer(e.timer);
			EventReset();
		else
			overall_counter = overall_counter + 1;
		end
	elseif e.timer == "event_start" then
		eq.stop_timer(e.timer);
		eq.set_timer("boss", boss_timer * 1000);
		eq.set_timer("player_check", 30 * 1000);
		eq.set_timer("adds", 15 * 1000);
		local WD = eq.unique_spawn(fake_witchdoctor,0,0,432.2,-297,39,257.2);
		WD:Shout("Summoners!  Focus your elemental powers to me at once!  We have tresspassers that must be dealt with!");
		for i = 1, #summoners do
			eq.signal(summoners[i],10);
		end
	elseif e.timer == "player_check" then
		if started and not player_check(e.self, 100) then
			EventReset();
		end
	elseif e.timer == "adds" then
		eq.stop_timer(e.timer);
		eq.set_timer("adds", 3 * 60 * 1000);
		spawn_mob(enraged_apprentice,1);
		spawn_mob(enraged_apprentice,2);
		spawn_mob(enraged_apprentice,3);
	elseif e.timer == "boss" then
		eq.stop_timer(e.timer);
		eq.unique_spawn(real_witchdoctor,0,0,432.2,-297,39,257.2);
		eq.depop(fake_witchdoctor);
	elseif e.timer == "reset" then
		EventReset();
	end
end

-- Summoners
function evt_summoners_spawn(e)
	deactivate(e.self);
end

function evt_summoners_signal(e)
	if e.signal == 10 then
		activate(e.self);
	elseif e.signal == 99 then
		deactivate(e.self);
	end
end

function evt_summoners_death_complete(e)
	eq.signal(controller,20);
end

-- Furious / Grimlin Apprentice
function evt_apprentice_death_complete(e)
	eq.signal(controller,10);
end

-- An Enraged Apprentice
function evt_enraged_apprentice_spawn(e)
	eq.set_timer('depop', 60 * 1000);
end

function evt_enraged_apprentice_combat(e)
	if e.joined then
        eq.stop_timer('depop');
    else
        eq.set_timer('depop', 60 * 1000);
    end
end

function evt_enraged_apprentice_timer(e)
	if e.timer == 'depop' then
        e.self:Say("The tresspassers have been slain. Glory to the master!");
        eq.depop();
    end
end

-- Real Witchdoctor
function evt_witchdoctor_spawn(e)
	eq.set_timer("depop", 10 * 60 * 1000);

	if eq.get_entity_list():IsMobSpawnedByNpcTypeID(mr_summoner) then
		e.self:ModifyNPCStat("MR","1000");
		wd_counter = wd_counter + 1;
	end

	if eq.get_entity_list():IsMobSpawnedByNpcTypeID(pr_summoner) then
		e.self:ModifyNPCStat("PR","1000");
		wd_counter = wd_counter + 1;
	end

	if eq.get_entity_list():IsMobSpawnedByNpcTypeID(cr_summoner) then
		e.self:ModifyNPCStat("CR","1000");
		wd_counter = wd_counter + 1;
	end

	if eq.get_entity_list():IsMobSpawnedByNpcTypeID(fr_summoner) then
		e.self:ModifyNPCStat("FR","1000");
		wd_counter = wd_counter + 1;
	end

	if wd_counter == 4 then
		e.self:Shout("Tresspassers, you failed in preventing our ritual!  You do not stand a chance of defeating me!")
	elseif wd_counter > 0 then
		e.self:Shout("Enough of your futile interference!  The transfer of elements may have been interrupted, but I have enough power to destroy the likes of you!")
	elseif wd_counter == 0 then
		e.self:Shout("You may have defeated my summoners, but you will not defeat me!  Prepare to die in honor of the Master!")
	end
end

function evt_witchdoctor_timer(e)
	if e.timer == "depop" then
		eq.signal(controller,1);
		eq.depop();
	end
end

function evt_witchdoctor_death_complete(e)
	eq.signal(controller,1);
end

-- General Functions
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

function spawn_mob(NPCID, loc)

	local spawn_loc	= {[1] = {433,-338,36,0}, [2] = {393,-298,36,127}, [3] = {433,-258,36,256}};
	local count		= math.random(1,3);

	for n = 1,count do
		eq.spawn2(NPCID,0,0,spawn_loc[loc][1] + math.random(-10,10) ,spawn_loc[loc][2] + math.random(-10,10) ,spawn_loc[loc][3],spawn_loc[loc][4]);
	end
end

function EventReset()
	eq.stop_all_timers();
	started = false;
	SpawnSummoners();		--repops summoners if not already up
	for i = 1, #summoners do
		eq.signal(summoners[i],99);
	end
	wd_counter		= 0;
	overall_counter = 0;
	eq.depop(fake_witchdoctor);
end

function SpawnSummoners()
	local random_order = math.random(1,4)
	local summoner_order = {
		[1] = {154392, 154393, 154394, 154395},
		[2] = {154395, 154394, 154393, 154392},
		[3] = {154393, 154395, 154394, 154392},
		[4] = {154394, 154392, 154395, 154393}
	};

	eq.unique_spawn(summoner_order[random_order][1],0,0,442,-297,37,390);
	eq.unique_spawn(summoner_order[random_order][2],0,0,433,-306,37,0);
	eq.unique_spawn(summoner_order[random_order][3],0,0,425,-297,37,130);
	eq.unique_spawn(summoner_order[random_order][4],0,0,433,-289,37,260);
end

function RepopTrash()
	for _,spawns in pairs(spawnpoints) do
		local RoomSpawn = eq.get_entity_list():GetSpawnByID(spawns);
		RoomSpawn:Enable();
		RoomSpawn:Reset();
		RoomSpawn:Repop(5);
	end
end

function DepopTrash()
	for _,spawns in pairs(spawnpoints) do
		local npc_list = eq.get_entity_list():GetNPCList();

		if npc_list ~= nil then
			for npc in npc_list.entries do
				if npc:GetSpawnPointID() == spawns then
					npc:Depop(true);
				end
			end
		end
	end
end

function deactivate(mob)
	mob:SetBodyType(11, true);
	mob:WipeHateList();
end

function activate(mob)
	mob:SetBodyType(7, true);
end

-- Encounter Load
function event_encounter_load(e)
	eq.register_npc_event("witchdoctor",	Event.spawn,			controller,				evt_controller_spawn);
	eq.register_npc_event("witchdoctor",	Event.signal,			controller,				evt_controller_signal);
	eq.register_npc_event("witchdoctor",	Event.timer,			controller,				evt_controller_timer);

	eq.register_npc_event("witchdoctor",	Event.death_complete,	furious_apprentice,		evt_apprentice_death_complete);
	eq.register_npc_event("witchdoctor",	Event.death_complete,	grimling_apprentice,	evt_apprentice_death_complete);

	eq.register_npc_event("witchdoctor",	Event.spawn,			enraged_apprentice,		evt_enraged_apprentice_spawn);
	eq.register_npc_event("witchdoctor",	Event.combat,			enraged_apprentice,		evt_enraged_apprentice_combat);
	eq.register_npc_event("witchdoctor",	Event.timer,			enraged_apprentice,		evt_enraged_apprentice_timer);

	eq.register_npc_event("witchdoctor",	Event.spawn,			real_witchdoctor,		evt_witchdoctor_spawn);
	eq.register_npc_event("witchdoctor",	Event.timer,			real_witchdoctor,		evt_witchdoctor_timer);
	eq.register_npc_event("witchdoctor",	Event.death_complete,	real_witchdoctor,		evt_witchdoctor_death_complete);

	for i = 1, #summoners do
		eq.register_npc_event("witchdoctor",	Event.spawn,			summoners[i],		evt_summoners_spawn);
		eq.register_npc_event("witchdoctor",	Event.signal,			summoners[i],		evt_summoners_signal);
		eq.register_npc_event("witchdoctor",	Event.death_complete,	summoners[i],		evt_summoners_death_complete);
	end
end
