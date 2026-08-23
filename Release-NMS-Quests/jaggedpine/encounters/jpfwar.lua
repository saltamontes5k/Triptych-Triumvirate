-- Updated jpfwar.lua with reward refactor, safe entity list usage, wipe/reset logic, and full reward support - eldarian

local gnolls = {}
local assassins = {}
local jardor = nil

local gnollcount = 0
local villagedeathcount = 0

local setup_npc = 181192
local Sergeant_Caelin = 181328
local Sergeant_Trade = 181348
local Jardor_Darkpaw = 181349
local barduck = 181070
local gnoll_id = 181316
local assassin_id = 181347

local static_village_npcs = {181175,181205,181166,181103,181085,181086,181173,181195,181206,181090,181160,181180,181182,181203,181210,181165,181179,181099,181183,181163,181161}

local VILLAGE_WAR_SPAWN = {
	SHAYNA = 181319, KAITHYS = 181320, ANNOUS = 181321, DEIRA = 181323, NOLAN = 181324, CHEYLOH = 181325,
	FINEWINE = 181326, BOSSAMIR = 181327, JEREMY = 181329, DERICK = 181331, CATHLEEN = 181333,
	SELIA = 181334, MORGAN = 181335, TALLIEN = 181336, NERDALA = 181338, PERGAN = 181340, BANKER = 181341,
	RALLEFORD = 181342, DONNA = 181345, DIEDRA = 181346
}

local move_waypoints = {
	{1878,1086,-10,0}, {1840,1078,-10,0}, {1892,1053,-10,0}, {2059,1055,-11,0}, {2096,1072,-11,0},
	{2096,1079,-11,0}, {2013,1090,-11,0}, {2016,1108,-11,0}, {2049,1123,-11,0}, {1919,1259,-11,0},
	{1953,1329,-11,0}, {2048,1211,-12,0}, {1981,957,-12,0}, {1994,1084,-11,0}, {1994,1084,-11,0}
}

local spawn_points = {
	{732,1382,-29}, {354,-951,-28}, {913,688,-19}, {1562,1481,11}, {255,-823,-12},
	{434,998,-19}, {419,1288,-13}, {1171,-1292,14}, {260,436,-22}, {435,-1772,-12},
	{467,1841,-20}, {1028,-1872,25}, {684,950,-30}, {643,347,-21}, {1302,-1641,-13},
	{348,557,-18}, {772,220,-15}, {594,-391,29}, {1277,-117,-19}, {475,294,-18},
	{209,1522,-28}, {1285,-1646,-13}, {768,1113,-13}, {219,-796,-9}, {297,1660,-15},
	{630,-1867,40}, {217,1541,-28}, {1044,1595,-12}, {984,-1004,80}, {1652,1732,4},
	{398,445,-14}, {915,977,8}, {883,1150,-5}, {295,-71,-9}, {430,684,-26},
	{1697,-1335,7}, {723,-898,-24}, {678,-1725,21}, {822,-1741,68}, {153,620,-13}
}

function WarTimer(e)
	local el = eq.get_entity_list()
	if e.timer == "gnollspawn" then
		gnollcount = gnollcount + 1
		if gnollcount == 1 then
			VillageWarSpawn()
			StaticVillageDepop()
		elseif gnollcount <= #move_waypoints then
			local spn = GnollSpawnLocation()
			table.insert(gnolls, spn)
			if gnolls[#gnolls - 1] and el and el:IsMobSpawnedByEntityID(gnolls[#gnolls - 1]:GetID()) then
				gnolls[#gnolls - 1]:CastToNPC():MoveTo(unpack(move_waypoints[gnollcount]))
			end
		elseif gnollcount == #move_waypoints + 1 then
			eq.stop_timer("gnollspawn")
			eq.set_timer("assassins", 2000)
		elseif e.timer == "assassins" then
			for _, coords in ipairs({
				{2027,1140,-12,0}, {1852,1269,-12,0}, {1794,1042,-12,0}, {2031,1148,-12,0}
			}) do
				local assassin_spawn = eq.spawn2(assassin_id, 0, 0, unpack(coords))
				table.insert(assassins, assassin_spawn)
			end
			eq.stop_timer("assassins")
			if el and el:IsMobSpawnedByNpcTypeID(Sergeant_Caelin) and villagedeathcount == 0 then
				jardor = eq.spawn2(Jardor_Darkpaw, 0, 0, 1988,1084,-11,196)
				eq.zone_emote(15, "Jardor Darkpaw emerges onto the battlefield, bellowing with rage!")
			end
			eq.zone_emote(15, "An inhuman voice screams from the distance, 'Prepare yourselves, for you shall soon know my wrath!'")
			eq.set_timer("wipecheck", 60000)
	elseif e.timer == "wipecheck" then
		if #gnolls + #assassins == 0 then
			eq.stop_timer("wipecheck")
			if villagedeathcount == 0 then
				eq.zone_emote(15, "The gnoll forces have been defeated with no casualties! A flawless defense!")
			else
				eq.zone_emote(13, "The gnoll forces have been defeated but many lives were lost...")
			end
			-- Clean up any leftovers
			eq.depop_all(gnoll_id)
			eq.depop_all(assassin_id)
		end
	end
end

function GnollSpawnLocation()
	local loc = spawn_points[math.random(#spawn_points)]
	return eq.spawn2(gnoll_id, 0, 0, loc[1], loc[2], loc[3], 0)
end

function VillageWarSpawn()
	for name, id in pairs(VILLAGE_WAR_SPAWN) do
		local coords = {
			SHAYNA = {2083,1120,-11,104}, KAITHYS = {1895,1007,-11,127}, ANNOUS = {2074,1206,-12,208},
			DEIRA = {1970,1233,-11,126}, NOLAN = {1820,1064,-10,64}, CHEYLOH = {1967,1267,-11,126},
			FINEWINE = {1931,1225,-11,131}, BOSSAMIR = {1856,1000,-10,130}, JEREMY = {1981,957,-13,227},
			DERICK = {1953,1329,-11,132}, CATHLEEN = {1919,1259,-11,3}, SELIA = {2049,1115,-11,137},
			MORGAN = {2020,1108,-11,72}, TALLIEN = {2020,1090,-11,72}, NERDALA = {2088,1079,-11,197},
			PERGAN = {2088,1072,-11,197}, BANKER = {2059,1055,-11,6}, RALLEFORD = {1892,1053,-10,194},
			DONNA = {1840,1078,-10,10}, DIEDRA = {1878,1086,-10,137}
		}
		local pos = coords[name]
		if pos then
			eq.unique_spawn(id, 0, 0, unpack(pos))
		end
	end
	eq.unique_spawn(Sergeant_Caelin,0,0,1988,1084,-11,196)
end

function StaticVillageDepop()
	for _, id in ipairs(static_village_npcs) do
		eq.depop_with_timer(id)
	end
end

function AdjustFactions(e, jaggedpine, treefolk, protectors, qeynos)
	e.other:Faction(1597, jaggedpine)
	e.other:Faction(272, treefolk)
	e.other:Faction(302, protectors)
	e.other:Faction(262, qeynos)
end

function RewardPlayer(e)
	local item_lib = require("items")
	local rewards = {
		[8368] = {8392, 8384, 8376}, -- Runed Gnollish Tome
		[8369] = {8390, 8385, 8377}, -- Gnoll Warrior's Crest
		[8370] = {8394, 9174, 9174}, -- Book of Gnollish Hymns
		[8371] = {8395, 8386, 8386}, -- Gnoll Pitfighter Gloves
		[8372] = {8396, 8388, 8380}, -- Gnollish Holy Symbol
		[8373] = {8397, 8387, 8381}, -- Stolen Seeds
		[8374] = {8398, 9191, 8382}, -- Gnoll Oracle Medicine Bag
		[8375] = {8399, 9188, 8383}  -- Gnoll Dousing Rod
	}
	for item, reward_set in pairs(rewards) do
		if item_lib.check_turn_in(e.trade, {item1 = item}) then
			if villagedeathcount >= 5 then
				AdjustFactions(e, 10, 5, 5, 1)
				e.other:QuestReward(e.self, 0, 0, 0, 0, reward_set[1], 5000)
			elseif villagedeathcount > 0 then
				AdjustFactions(e, 25, 12, 12, 2)
				e.other:QuestReward(e.self, 0, 0, 0, 0, reward_set[2], 10000)
			else
				AdjustFactions(e, 50, 25, 25, 5)
				e.other:QuestReward(e.self, 0, 0, 0, 0, reward_set[3], 15000)
			end
			break
		end
	end
	item_lib.return_items(e.self, e.other, e.trade)
end

function event_encounter_load(e)
	eq.register_npc_event(Event.timer, setup_npc, WarTimer)
	eq.register_npc_event(Event.trade, Sergeant_Trade, RewardPlayer)
end
