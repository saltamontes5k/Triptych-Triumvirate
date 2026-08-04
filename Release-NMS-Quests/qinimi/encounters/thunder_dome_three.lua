-- Thunderdome Three Event

local player_limit					=	18;
local zone_id						=	eq.get_zone_id();
-- Mob IDs
local thunderdome_controller		=	281185; --
local mass_of_stone					=	281041; --
local sacrafice_npc					=	281186; --
local chamber_guardian				=	281187; --
local ukun							=	281188; --
local noc							=	281189; --
local ratuk1						=	281190; --
local ratuk2						=	281191; --
local ratuk3						=	281192; --
local kabeka						=	281193; --
local dummy_krvne					=	281194; --
local fake_krvne					=	281195; --
local real_krvne					=	281196; --
local final_krvne					=	281197; --
local sislono						=	281051;
-- Adjust for location
local min_x							= -75.30;	-- East
local max_x							= 122.9;	-- West
local min_y							= 1540.80;	-- South
local max_y							= 1739.20;	-- North

-- Locs
local entry_loc = {-66.72, 1639.5, -18.12, 133};
local center_loc					=	{23,1640,-4.88,377};
local dummy_krvne_loc				=	{dummy_krvne,0,0,23,1640,31.88,128};
local sacrafice_loc					=	{
	[1]	=	{sacrafice_npc,0,0,24.03, 1613.32, -18.12,256.0},	-- South
	[2]	=	{sacrafice_npc,0,0,50.57, 1640.48, -18.12,128.0},	-- West
	[3]	=	{sacrafice_npc,0,0,23.79, 1666.66, -18.12,512.0}	-- North
};

local non_combat_ikkav_locations	=	{
	[1]	=	{281198,0,0,-11.81, 1604.69, -16.87,63.8},	-- Rkolok_Kekek --
	[2]	=	{281199,0,0,23.08, 1590.29, -16.87,0},		-- Triket_Korhek --
	[3]	=	{281200,0,0,59.18, 1604.94, -16.87,443.0},	-- Krikov_Tkork --
	[4]	=	{281201,0,0,73.53, 1639.87, -16.87,384.5},	-- Reken_Trekrik --
	[5]	=	{281202,0,0,59.11, 1674.77, -16.87,322.0},	-- Rexxek_Ukranik --
	[6]	=	{281203,0,0,23.41, 1690.02, -16.87,255.5},	-- Rkor_Ekret --
	[7]	=	{281204,0,0,-11.52, 1675.69, -16.87,193.0},	-- Korev_Rike --
	[8]	=	{281205,0,0,-26.74, 1639.97, -16.87,128.8}	-- Kriknek_Rekik --
};

local wave_one_mobs					=	{
	[1]	=	{chamber_guardian,0,0,3.31, 1549.91, -18.12,508.0},		-- chamber_guardian
	[2]	=	{chamber_guardian,0,0,44.15, 1550.32, -18.12,0},		-- chamber_guardian
	[3]	=	{chamber_guardian,0,0,114.61, 1619.53, -18.12,385.0},	-- chamber_guardian
	[4]	=	{chamber_guardian,0,0,114.52, 1658.93, -18.12,383.8},	-- chamber_guardian
	[5]	=	{chamber_guardian,0,0,45.67, 1731.93, -18.12,257.8},	-- chamber_guardian
	[6]	=	{chamber_guardian,0,0,4.39, 1730.92, -18.12,255.2}		-- chamber_guardian
};

local wave_two_mobs					=	{
	[1]	=	{noc,0,0,3.31, 1549.91, -18.12,508.0},		-- noc
	[2]	=	{ukun,0,0,44.15, 1550.32, -18.12,0},		-- ukun
	[3]	=	{noc,0,0,114.61, 1619.53, -18.12,385.0},	-- noc
	[4]	=	{ukun,0,0,114.52, 1658.93, -18.12,383.8},	-- ukun
	[5]	=	{noc,0,0,45.67, 1731.93, -18.12,257.8},		-- noc
	[6]	=	{ukun,0,0,4.39, 1730.92, -18.12,255.2}		-- ukun
};

local wave_three_mobs					=	{
	[1]	=	{noc,0,0,3.31, 1549.91, -18.12,508.0},		-- noc
	[2]	=	{ukun,0,0,44.15, 1550.32, -18.12,0},		-- ukun
	[3]	=	{ukun,0,0,23.91, 1556.85, -18.12,511.8},	-- ukun
	[4]	=	{noc,0,0,114.61, 1619.53, -18.12,385.0},	-- noc
	[5]	=	{ukun,0,0,114.52, 1658.93, -18.12,383.8},	-- ukun
	[6]	=	{ukun,0,0,107.62, 1640.51, -18.12,382.2},	-- ukun
	[7]	=	{noc,0,0,45.67, 1731.93, -18.12,257.8},		-- noc
	[8]	=	{noc,0,0,4.39, 1730.92, -18.12,255.2},		-- noc
	[9]	=	{ukun,0,0,23.93, 1724.20, -18.12,258.0}		-- ukun
}

local combat_ikkav_locations		=	{
	[1] = {0.16, 1617.17, -18.12,53.0},		-- South-East
	[2] = {48.09, 1614.28, -18.12,450.5},	-- South-West
	[3] = {47.89, 1664.29, -18.12,322.2},	-- North-West
	[4] = {1.63, 1663.39, -18.12,196.0}		-- North-East
};

local ratuk_locs					=	{
	[1]	=	{ratuk1,0,0,87.53, 1576.55, -18.12,447.5},	-- South-West Going to South
	[2]	=	{ratuk2,0,0,87.41, 1703.40, -18.12,321.2},	-- North-West Going to West
	[3]	=	{ratuk3,0,0,-39.76, 1703.48, -18.12,193.8}	-- North-East Going to North
};

local ratuk_path_loc				=	{
	[1]	=	{23.96, 1602.00, -18.12,5.0, true},
	[2]	=	{61.14, 1640.48, -18.12,384.2, true},
	[3]	=	{23.88, 1678.19, -18.12,256.5, true}
}

-- Script Variables
local phase				=	0;
local deaths			=	0;
local boss_counter		=	4;
local mass_entity		=	eq.get_entity_list():GetMobByNpcTypeID(mass_of_stone);


function init_event(e)
	phase			=	0;	-- Ensure phase is reset
	deaths			=	0;	-- Ensure deaths = 0
	boss_counter	=	4;	-- Ensure boss_counter = 4
	eq.spawn2(thunderdome_controller,0,0,unpack(center_loc));	-- TD_Status
	eq.signal(thunderdome_controller,10);
end

function td_signal(e)
	if(e.signal == 10) then
		eq.set_timer("fail_1", 10 * 60 * 1000);		-- 10 minute first phase fail timer
		eq.set_timer("fail_2", 27 * 60 * 1000);		-- 27 minute total fail timer
		eq.set_timer("Wave_1", 5 * 1000);			-- 5s to start event
		eq.set_timer("Wave_2", 60 * 1000);			-- 1 Minute to wave 2
		eq.set_timer("Wave_3", 3 * 60 * 1000);		-- 1 Minutes to wave 3
	elseif(e.signal == 20) then
		eq.set_timer("port_out", 5 * 60 * 1000);	-- How long until port out?
	elseif(e.signal == 99) then
		eq.stop_timer("fail_1");
	end
end

function td_event_timers(e)
	if (e.timer == "Wave_1") then
		eq.stop_timer("Wave_1");
		phase	=	1;
		eq.spawn2(unpack(dummy_krvne_loc));

		-- a_yun_sacrafice
		eq.spawn2(unpack(sacrafice_loc[1]));	-- South
		eq.spawn2(unpack(sacrafice_loc[2]));	-- West
		eq.spawn2(unpack(sacrafice_loc[3]));	-- North

		-- non-combat ikkav
		for i=1,8 do
			eq.spawn2(unpack(non_combat_ikkav_locations[i]));
		end

		for i=1,6 do
			eq.spawn2(unpack(wave_one_mobs[i]));
		end
	elseif (e.timer == "Wave_2") then
		eq.stop_timer("Wave_2");
		for i=1,6 do
			eq.spawn2(unpack(wave_two_mobs[i]));
		end
	elseif (e.timer == "Wave_3") then
		eq.stop_timer("Wave_3");
		for i=1,9 do
			eq.spawn2(unpack(wave_three_mobs[i]));
		end
	elseif (e.timer == "fail_1") then
		eq.stop_timer("fail_1");
		eq.stop_timer("fail_2");
		eq.set_timer("port_out", 5 * 60 * 1000);	-- How long until port out?
		eq.depop_all(mass_of_stone);
		eq.depop_all(sacrafice_npc);
		eq.depop_all(chamber_guardian);
		eq.depop_all(ukun);
		eq.depop_all(noc);
		eq.depop_all(ratuk1);
		eq.depop_all(ratuk2);
		eq.depop_all(ratuk3);
		eq.depop_all(kabeka);
		eq.depop_all(dummy_krvne);
		eq.depop_all(fake_krvne);
		eq.depop_all(real_krvne);
		eq.depop_all(final_krvne);
		for i=1,8 do
			eq.depop_all(non_combat_ikkav_locations[i][1]);
		end

		local mos_entity = eq.spawn2(mass_of_stone,0,0,unpack(center_loc));
		mos_entity:SetSpecialAbility(24, 0); -- Will Aggro
		mos_entity:SetSpecialAbility(35, 0); -- Harm From Players
	elseif (e.timer == "fail_2") then
		eq.stop_timer("fail_2");
		eq.set_timer("port_out", 5 * 60 * 1000);	-- How long until port out?
		---- flavor text
		KickPlayers(e);
		cleanup(e);
	elseif (e.timer == "port_out") then
		eq.stop_timer("port_out");
		KickPlayers(e);
		event_end(e);
	end
end

function death_check(e)
	if phase == 1 then
		deaths = deaths + 1;
		if deaths == 21 then
			start_phase_2(e);
		end
	elseif phase == 2 then
		deaths = deaths + 1;
		if deaths == 3 then
			start_phase_3(e);
		end
	end
end

function start_phase_2(e)
	deaths	=	0; -- Reset Counter
	phase	=	2;
	
	eq.spawn2(unpack(ratuk_locs[1]));
	eq.spawn2(unpack(ratuk_locs[2]));
	eq.spawn2(unpack(ratuk_locs[3]));
end

function ratuk1_spawn(e)
	e.self:SetSpecialAbility(24, 1); -- Will Not Aggro
	e.self:MoveTo(unpack(ratuk_path_loc[1]));
end

function ratuk2_spawn(e)
	e.self:SetSpecialAbility(24, 1); -- Will Not Aggro
	e.self:MoveTo(unpack(ratuk_path_loc[2]));
end

function ratuk3_spawn(e)
	e.self:SetSpecialAbility(24, 1); -- Will Not Aggro
	e.self:MoveTo(unpack(ratuk_path_loc[3]));
end

function ratuk_waypoint(e)
	e.self:SetSpecialAbility(24, 0); -- Will Aggro
	e.self:SetPseudoRoot(true);
end

function start_phase_3(e)
	eq.signal(thunderdome_controller, 99);
	deaths	=	0;
	phase	=	3;
	eq.depop_with_timer(mass_of_stone);
	eq.depop_all(sacrafice_npc);
	eq.unique_spawn(kabeka,0,0,unpack(center_loc));
end

function kabeka_spawn(e)
	eq.set_next_hp_event(5)
end

function kabeka_combat(e)
	if e.joined then
		eq.set_timer("casting", 20 * 1000)
	else
		eq.stop_timer("casting")
	end
end

function kabeka_event_hp(e)
	if (e.hp_event == 5) then
		e.self:CastSpell(4663,e.self:GetID()); -- Spell: Aura of the Hunter (4663)
		e.self:Emote("grins as its muscles twitch with power.")
		eq.set_next_inc_hp_event(5)
	elseif (e.inc_hp_event == 5) then
		eq.set_next_hp_event(5)
	end
end

function kabeka_timer(e)
	if (e.timer == "casting") then
		local roll = math.random(100)
		if (roll >= 50) then
			e.self:Emote("releases a volley of arrows.");
			hate_list = e.self:CountHateList();
			if (hate_list ~= nil and tonumber(hate_list) == 1) then
				e.self:CastedSpellFinished(4664, e.self:GetHateRandom())
			elseif (hate_list ~= nil and tonumber(hate_list) == 2) then
				e.self:CastedSpellFinished(4664, e.self:GetHateRandom())
				e.self:CastedSpellFinished(4664, e.self:GetHateRandom())
			elseif (hate_list ~= nil and tonumber(hate_list) == 3) then
				e.self:CastedSpellFinished(4664, e.self:GetHateRandom())
				e.self:CastedSpellFinished(4664, e.self:GetHateRandom())
				e.self:CastedSpellFinished(4664, e.self:GetHateRandom())
			elseif (hate_list ~= nil and tonumber(hate_list) == 4) then
				e.self:CastedSpellFinished(4664, e.self:GetHateRandom())
				e.self:CastedSpellFinished(4664, e.self:GetHateRandom())
				e.self:CastedSpellFinished(4664, e.self:GetHateRandom())
				e.self:CastedSpellFinished(4664, e.self:GetHateRandom())
			elseif (hate_list ~= nil and tonumber(hate_list) == 5) then
				e.self:CastedSpellFinished(4664, e.self:GetHateRandom())
				e.self:CastedSpellFinished(4664, e.self:GetHateRandom())
				e.self:CastedSpellFinished(4664, e.self:GetHateRandom())
				e.self:CastedSpellFinished(4664, e.self:GetHateRandom())
				e.self:CastedSpellFinished(4664, e.self:GetHateRandom())
			elseif (hate_list ~= nil and tonumber(hate_list) == 6) then
				e.self:CastedSpellFinished(4664, e.self:GetHateRandom())
				e.self:CastedSpellFinished(4664, e.self:GetHateRandom())
				e.self:CastedSpellFinished(4664, e.self:GetHateRandom())
				e.self:CastedSpellFinished(4664, e.self:GetHateRandom())
				e.self:CastedSpellFinished(4664, e.self:GetHateRandom())
				e.self:CastedSpellFinished(4664, e.self:GetHateRandom())
			elseif (hate_list ~= nil and tonumber(hate_list) > 6) then --only fires on a max of 7 targets
				e.self:CastedSpellFinished(4664, e.self:GetHateRandom())
				e.self:CastedSpellFinished(4664, e.self:GetHateRandom())
				e.self:CastedSpellFinished(4664, e.self:GetHateRandom())
				e.self:CastedSpellFinished(4664, e.self:GetHateRandom())
				e.self:CastedSpellFinished(4664, e.self:GetHateRandom())
				e.self:CastedSpellFinished(4664, e.self:GetHateRandom())
				e.self:CastedSpellFinished(4664, e.self:GetHateRandom())
			end
		end
	end
end

function start_phase_4(e)
	deaths	=	0;
	phase	=	4;
	for i=1,8 do
		eq.depop_all(non_combat_ikkav_locations[i][1]);
	end
	---- Spawn 3 fake and 1 real
	phase4_spawn(e);
end

function krvne_spawn(e)
	eq.set_next_hp_event(90)
end

function krvne_hp_real(e)
	if (e.hp_event == 90) then
		start_phase_5(e);
	end
end

function krvne_hp_fake(e)
	if (e.hp_event == 90) then
		phase4_spawn(e);
	end
end

function phase4_spawn(e)
	-- Depop existing
	eq.depop_all(fake_krvne);
	eq.depop_all(real_krvne);

	spawns = {};
	local n = 1;
	-- get random locations and add in spawns table
	if boss_counter == 1 then
		start_phase_5(e);
	else
		while n <= boss_counter do
			local loc = math.random(1,4)
			if TableCheck(loc,spawns) then
				table.insert(spawns,n, loc);
				n = n + 1;
				if n == boss_counter - 1 then
					eq.unique_spawn(real_krvne,0,0,unpack(combat_ikkav_locations[loc]));
				else
					eq.spawn2(fake_krvne,0,0,unpack(combat_ikkav_locations[loc]));
				end
			end
		end
		boss_counter = boss_counter - 1;
	end
end

function start_phase_5(e)
	eq.depop_all(fake_krvne);
	eq.depop_all(real_krvne);
	eq.unique_spawn(final_krvne,0,0,unpack(center_loc));
end

function event_win(e)
	-- Any Flavor Text
	eq.stop_timer("fail_2");
	eq.signal(thunderdome_controller, 20); -- Event Win
	cleanup(e); -- Clear Trash
	eq.spawn2(sislono,0,0,unpack(entry_loc));
end

function KickPlayers(e)
	local player_list = eq.get_entity_list():GetClientList();
	local count = 0;
	if(player_list ~= nil) then
		for pc in player_list.entries do
			if pc.valid and pc:GetX() >= min_x and pc:GetX() <= max_x and pc:GetY() >= min_y and pc:GetY() <= max_y and not pc:GetGM() then
				local instance_id = eq.get_zone_instance_id();
				pc:MovePCInstance(zone_id, instance_id, -1480.06, -300.73, -15.33, 42);	-- boot to zone in
			end
		end
	end
end

function cleanup(e)
	---- force depop all npc's involved with TD Three
	eq.depop_with_timer(mass_of_stone);
	eq.depop_all(sacrafice_npc);
	eq.depop_all(chamber_guardian);
	eq.depop_all(ukun);
	eq.depop_all(noc);
	eq.depop_all(ratuk1);
	eq.depop_all(ratuk2);
	eq.depop_all(ratuk3);
	eq.depop_all(kabeka);
	eq.depop_all(dummy_krvne);
	eq.depop_all(fake_krvne);
	eq.depop_all(real_krvne);
	eq.depop_all(final_krvne);
	for i=1,8 do
		eq.depop_all(non_combat_ikkav_locations[i][1]);
	end
	eq.depop_with_timer(sislono);
end

function event_end(e)
	eq.signal(281051,3);
end

function TableCheck(ran, tab)
	for i,v in pairs(tab) do
		if v == ran then
			return false;	--already have this value in the table - skip and roll again			
		end
	end
	return true;	-- not a duplicate value - OK to proceed
end

function event_encounter_load(e)

	eq.register_npc_event('thunder_dome_three', Event.timer, thunderdome_controller, td_event_timers);
	eq.register_npc_event('thunder_dome_three', Event.signal, thunderdome_controller, td_signal);

	-- Phase 1
	eq.register_npc_event('thunder_dome_three', Event.death_complete, chamber_guardian, death_check);	-- count deaths
	eq.register_npc_event('thunder_dome_three', Event.death_complete, ukun, death_check);				-- count deaths
	eq.register_npc_event('thunder_dome_three', Event.death_complete, noc, death_check);				-- count deaths

	-- Phase 2
	eq.register_npc_event('thunder_dome_three', Event.spawn, ratuk1, ratuk1_spawn);
	eq.register_npc_event('thunder_dome_three', Event.spawn, ratuk2, ratuk2_spawn);
	eq.register_npc_event('thunder_dome_three', Event.spawn, ratuk3, ratuk3_spawn);
	eq.register_npc_event('thunder_dome_three', Event.waypoint_arrive, ratuk1, ratuk_waypoint);
	eq.register_npc_event('thunder_dome_three', Event.waypoint_arrive, ratuk2, ratuk_waypoint);
	eq.register_npc_event('thunder_dome_three', Event.waypoint_arrive, ratuk3, ratuk_waypoint);
	eq.register_npc_event('thunder_dome_three', Event.death_complete, ratuk1, death_check);			-- count deaths
	eq.register_npc_event('thunder_dome_three', Event.death_complete, ratuk2, death_check);			-- count deaths
	eq.register_npc_event('thunder_dome_three', Event.death_complete, ratuk3, death_check);			-- count deaths

	-- Phase 3
	eq.register_npc_event('thunder_dome_three', Event.spawn, kabeka, kabeka_spawn);
	eq.register_npc_event('thunder_dome_three', Event.combat, kabeka, kabeka_combat);
	eq.register_npc_event('thunder_dome_three', Event.hp, kabeka, kabeka_event_hp);
	eq.register_npc_event('thunder_dome_three', Event.timer, kabeka, kabeka_timer);
	eq.register_npc_event('thunder_dome_three', Event.death_complete, kabeka, start_phase_4);

	-- Phase 4
	eq.register_npc_event('thunder_dome_three', Event.spawn, fake_krvne, krvne_spawn);
	eq.register_npc_event('thunder_dome_three', Event.spawn, real_krvne, krvne_spawn);

	eq.register_npc_event('thunder_dome_three', Event.hp, fake_krvne, krvne_hp_fake);
	eq.register_npc_event('thunder_dome_three', Event.hp, real_krvne, krvne_hp_real);

	-- Phase 5
	eq.register_npc_event('thunder_dome_three', Event.death_complete, final_krvne, event_win);


	init_event(e);
end
