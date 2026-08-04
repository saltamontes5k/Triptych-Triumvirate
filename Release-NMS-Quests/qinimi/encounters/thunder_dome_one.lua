-- Thunderdome One Event

local player_limit					=	18;
local zone_id						=	eq.get_zone_id();
-- Mob IDs
local thunderdome_controller		=	281145; --
local mass_of_stone					=	281146; --
local sacrafice_npc					=	281155; --
local chamber_guardian				=	281114; --
local ukun							=	281153; --
local noc							=	281152; --
local ratuk1						=	281154; -- 
local ratuk2						=	281147; --
local ratuk3						=	281148; --
local kabeka						=	281125; --
local dummy_krvne					=	281077; --
local fake_krvne					=	281149; --
local real_krvne					=	281150; --
local final_krvne					=	281151; --
local sislono						=	281051;
-- Adjust for location
local min_x							=	-1840;
local max_x							=	-1640;
local min_y							=	-1178;
local max_y							=	-978;

-- Locs
local entry_loc = {-1833.56, -1077.92, -16.07, 133};
local center_loc					=	{-1745.66,-1078.70,-16.50,128};
local dummy_krvne_loc				=	{dummy_krvne,0,0,-1745.66,-1078.70,31.88,128};
local sacrafice_loc					=	{
	[1]	=	{sacrafice_npc,0,0,-1740.31,-1104.52,-18.12,252.8},	-- South
	[2]	=	{sacrafice_npc,0,0,-1714.91,-1078.68,-18.12,128.2},	-- West
	[3]	=	{sacrafice_npc,0,0,-1740.48,-1052.79,18.12,3.8}		-- North
};

local non_combat_ikkav_locations	=	{
	[1]	=	{281156,0,0,-1775.44,-1115.38,-16.87,61.2},		-- Rkolok_Kekek --
	[2]	=	{281157,0,0,-1739.75,-1128.47,-16.87,510.8},	-- Triket_Korhek --
	[3]	=	{281158,0,0,-1704.89,-1114.01,-16.87,453.5},	-- Krikov_Tkork --
	[4]	=	{281159,0,0,-1690.56,-1078.77,-16.87,387.8},	-- Reken_Trekrik --
	[5]	=	{281160,0,0,-1704.80,-1043.35,-16.87,322.2},	-- Rexxek_Ukranik --
	[6]	=	{281161,0,0,-1740.20,-1028.48,-16.87,253.8},	-- Rkor_Ekret --
	[7]	=	{281162,0,0,-1775.27,-1043.12,-16.87,191.8},	-- Korev_Rike --
	[8]	=	{281163,0,0,-1790.33,-1078.64,-16.87,127.0}		-- Kriknek_Rekik --
};

local wave_one_mobs					=	{
	[1]	=	{chamber_guardian,0,0,-1753.03,-1173.84,-18.12,0},		-- chamber_guardian
	[2]	=	{chamber_guardian,0,0,-1723.03,-1173.84,-18.12,0},		-- chamber_guardian
	[3]	=	{chamber_guardian,0,0,-1644.02,-1096.11,-18.12,386.5},	-- chamber_guardian
	[4]	=	{chamber_guardian,0,0,-1644.02,-1066.11,-18.12,386.5},	-- chamber_guardian
	[5]	=	{chamber_guardian,0,0,-1759.90,-982.10,-18.12,252.5},	-- chamber_guardian
	[6]	=	{chamber_guardian,0,0,-1719.90,-982.10,-18.12,252.5}	-- chamber_guardian
};

local wave_two_mobs					=	{
	[1]	=	{noc,0,0,-1753.03,-1173.84,-18.12,0},		-- noc
	[2]	=	{ukun,0,0,-1723.03,-1173.84,-18.12,0},		-- ukun
	[3]	=	{noc,0,0,-1644.02,-1096.11,-18.12,386.5},	-- noc
	[4]	=	{ukun,0,0,-1644.02,-1066.11,-18.12,386.5},	-- ukun
	[5]	=	{noc,0,0,-1759.90,-982.10,-18.12,252.5},	-- noc
	[6]	=	{ukun,0,0,-1719.90,-982.10,-18.12,252.5}	-- ukun
};

local wave_three_mobs					=	{
	[1]	=	{noc,0,0,-1753.03,-1173.84,-18.12,0},		-- noc
	[2]	=	{ukun,0,0,-1743.03,-1173.84,-18.12,0},		-- ukun
	[3]	=	{ukun,0,0,-1723.03,-1173.84,-18.12,0},		-- ukun
	[4]	=	{noc,0,0,-1644.02,-1096.11,-18.12,386.5},	-- noc
	[5]	=	{ukun,0,0,-1644.02,-1066.11,-18.12,386.5},	-- ukun
	[6]	=	{ukun,0,0,-1644.02,-1078.24,-18.12,386.5},	-- ukun
	[7]	=	{noc,0,0,-1759.90,-982.10,-18.12,252.5},	-- noc
	[8]	=	{noc,0,0,-1739.90,-982.10,-18.12,252.5},	-- noc
	[9]	=	{ukun,0,0,-1719.90,-982.10,-18.12,252.5}	-- ukun
}

local combat_ikkav_locations		=	{
	[1] = {-1761.54,-1100.42,-18.12,324.2},	-- South-East
	[2] = {-1719.44,-1098.31,-18.12,190.8},	-- South-West
	[3] = {-1719.00,-1057.73,-18.12,64.8},	-- North-West
	[4] = {-1759.43,-1060.12,-18.12,450.0}	-- North-East
};

local ratuk_locs					=	{
	[1]	=	{ratuk1,0,0,-1675.67,-1147.34,-18.12,451.2},	-- South-West Going to South
	[2]	=	{ratuk2,0,0,-1674.49,-1011.96,-18.12,318.2},	-- North-West Going to West
	[3]	=	{ratuk3,0,0,-1807.54,-1012.63,-18.12,190.8}		-- North-East Going to North
};

local ratuk_path_loc				=	{
	[1]	=	{-1740.10,-1115.80,-18.12,1.2, true},
	[2]	=	{-1701.08,-1078.61,-18.12,383, true},
	[3]	=	{-1739.74,-1040.67,-18.12,253.8, true}
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
	eq.spawn2(thunderdome_controller,0,0,unpack(center_loc));	-- TD_Status_One
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
	---- force depop all npc's involved with TD One
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
	eq.signal(281051,1);
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

	eq.register_npc_event('thunder_dome_one', Event.timer, thunderdome_controller, td_event_timers);
	eq.register_npc_event('thunder_dome_one', Event.signal, thunderdome_controller, td_signal);

	-- Phase 1
	eq.register_npc_event('thunder_dome_one', Event.death_complete, chamber_guardian, death_check);	-- count deaths
	eq.register_npc_event('thunder_dome_one', Event.death_complete, ukun, death_check);				-- count deaths
	eq.register_npc_event('thunder_dome_one', Event.death_complete, noc, death_check);				-- count deaths

	-- Phase 2
	eq.register_npc_event('thunder_dome_one', Event.spawn, ratuk1, ratuk1_spawn);
	eq.register_npc_event('thunder_dome_one', Event.spawn, ratuk2, ratuk2_spawn);
	eq.register_npc_event('thunder_dome_one', Event.spawn, ratuk3, ratuk3_spawn);
	eq.register_npc_event('thunder_dome_one', Event.waypoint_arrive, ratuk1, ratuk_waypoint);
	eq.register_npc_event('thunder_dome_one', Event.waypoint_arrive, ratuk2, ratuk_waypoint);
	eq.register_npc_event('thunder_dome_one', Event.waypoint_arrive, ratuk3, ratuk_waypoint);
	eq.register_npc_event('thunder_dome_one', Event.death_complete, ratuk1, death_check);			-- count deaths
	eq.register_npc_event('thunder_dome_one', Event.death_complete, ratuk2, death_check);			-- count deaths
	eq.register_npc_event('thunder_dome_one', Event.death_complete, ratuk3, death_check);			-- count deaths

	-- Phase 3
	eq.register_npc_event('thunder_dome_one', Event.spawn, kabeka, kabeka_spawn);
	eq.register_npc_event('thunder_dome_one', Event.combat, kabeka, kabeka_combat);
	eq.register_npc_event('thunder_dome_one', Event.hp, kabeka, kabeka_event_hp);
	eq.register_npc_event('thunder_dome_one', Event.timer, kabeka, kabeka_timer);
	eq.register_npc_event('thunder_dome_one', Event.death_complete, kabeka, start_phase_4);

	-- Phase 4
	eq.register_npc_event('thunder_dome_one', Event.spawn, fake_krvne, krvne_spawn);
	eq.register_npc_event('thunder_dome_one', Event.spawn, real_krvne, krvne_spawn);

	eq.register_npc_event('thunder_dome_one', Event.hp, fake_krvne, krvne_hp_fake);
	eq.register_npc_event('thunder_dome_one', Event.hp, real_krvne, krvne_hp_real);

	-- Phase 5
	eq.register_npc_event('thunder_dome_one', Event.death_complete, final_krvne, event_win);


	init_event(e);
end
