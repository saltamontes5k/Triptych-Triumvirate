-- poknowledge/Old_Man_McKenzie.lua
-- NMS mission hub: Old Man McKenzie offers his monster-mission lessons through
-- the stock task select window (client:TaskSelector); the rant lives in the
-- task descriptions, and accepting one fires event_task_accepted here, which
-- assembles the expedition. His Brew stock (merchantlist 202411, migration
-- v277) spends McKenzie's Special Brew (item 41408, alternate_currency 18) --
-- the same Brew the Boat Lesson pays out. New McKenzie missions slot into
-- MISSION_TASKS.

local BOAT_TASK_ID    = 800004
local BOAT_EXPEDITION = "Old Man McKenzie's Boat Lesson"
local SPACE_TASK_ID   = 800007
local SPACE_EXPEDITION = "Old Man McKenzie's Derelict Space Station"
local MIN_LEVEL       = 40 -- shrouds only go down, never up

local POK_ID = 202 -- zoneidnumber (canonical), not zone.id
local MCKENZIE_HOME = { x = 263, y = 69, z = -125.375, h = 0 }
local OOT_ZONEIN    = { x = -9200, y = 390, z = 6, h = 0 } -- oot safe point, open water
local STATION_ZONEIN = { x = 74, y = -696, z = 4.1, h = 2 } -- netherbian, the Dawnshroud arrival pocket

local compass    = { zone = "poknowledge", x = MCKENZIE_HOME.x, y = MCKENZIE_HOME.y, z = MCKENZIE_HOME.z }
local safereturn = { zone = "poknowledge", x = MCKENZIE_HOME.x, y = MCKENZIE_HOME.y, z = MCKENZIE_HOME.z, h = MCKENZIE_HOME.h }
local zonein     = { x = OOT_ZONEIN.x, y = OOT_ZONEIN.y, z = OOT_ZONEIN.z, h = OOT_ZONEIN.h }
local station_zonein = { x = STATION_ZONEIN.x, y = STATION_ZONEIN.y, z = STATION_ZONEIN.z, h = STATION_ZONEIN.h }

local boat_lesson = {
	expedition = { name = BOAT_EXPEDITION, min_players = 1, max_players = 6 },
	instance   = { zone = "oot", version = 29, duration = eq.seconds("2h") },
	compass    = compass,
	safereturn = safereturn,
	zonein     = zonein
}

-- The station takes a squad of Master Officers: group of 1-6.
local derelict_station = {
	expedition = { name = SPACE_EXPEDITION, min_players = 1, max_players = 6 },
	instance   = { zone = "netherbian", version = 66, duration = eq.seconds("2h") },
	compass    = compass,
	safereturn = safereturn,
	zonein     = station_zonein
}

-- Mission roster: task ids offered in the select window.
local MISSION_TASKS = { BOAT_TASK_ID, SPACE_TASK_ID }

local function on_boat_expedition(client)
	local dz = client:GetExpedition()
	return dz.valid and dz:GetName() == BOAT_EXPEDITION
end

local function on_space_expedition(client)
	local dz = client:GetExpedition()
	return dz.valid and dz:GetName() == SPACE_EXPEDITION
end

function event_say(e)
	if e.message:findi("^ready$") then
		if on_boat_expedition(e.other) or on_space_expedition(e.other) then
			e.other:MovePCDynamicZone(e.other:GetExpedition():GetZoneID())
		end
		return
	end
	if e.message:findi("space") then
		-- the Derelict Space Station monologue. He was there. He will not
		-- say what game it was, mostly because he does not know.
		e.self:Say("You want to hear about the deep of space. HA. Nobody wants to hear about the deep of space. It's mostly the same story as the maze, but with more armor and worse air.")
		e.self:Emote("pats the air like it's a large dog.")
		e.self:Say("There was a RING, kid. Great big Moon-Ring, hung in the sky. I worked on it. Fitted boots. You wouldn't know the shop. And on the ring there was a STATION -- a derlict one, out in the deep of space. DEEPER than the Deep. I was THERE. Who do you think taught the Watchful Spark to glow?")
		e.self:Emote("shakes the bottle. It does not agree with him.")
		e.self:Say("Then the Mildew got into the crew -- PWOOF -- zombies, the whole night shift, still on duty, ZERO work ethic. And the Leapers of the Dark in their fancy armor with their little capes. Never saw one until it was ON me. Woke up in the moon-tunnels three days later wearing someone else's boots. Both of them. Different feet.")
		e.self:Say("Say [" .. eq.say_link("ready") .. "] when the window is open. Purge the Mildew, silence the Leapers, cull the crew, and do NOT fire the station. We do not talk about who fired the station.")
		return
	end
	if e.message:findi("hail") then
		e.self:Say(string.format(
			"Hmph. %s, is it? In my day the sight of a boat on the horizon stopped a war cold. " ..
			"Never mind an old man's grumbling -- the lessons are in the window. And if you want to hear about the [" ..
			eq.say_link("space") .. "] story, well. Nobody wants to hear about the deep of space.",
			e.other:GetCleanName()))
		e.other:TaskSelector(MISSION_TASKS)
	end
end

function event_task_accepted(e)
	local task_id = tonumber(e.task_id) or -1
	if e.other:GetLevel() < MIN_LEVEL then
		e.other:Message(15, "Old Man McKenzie squints at you. 'Come back when you've seen 40 winters. Neither the sea, the moors, nor the deep of space suffer children.'")
		return
	end

	if task_id == BOAT_TASK_ID then
		if on_boat_expedition(e.other) then
			e.other:Message(15, "Your lesson is already assembled! Say '[" .. eq.say_link("ready") .. "]' to board.")
			return
		end
		local dz = e.other:CreateExpedition(boat_lesson)
		if dz.valid then
			e.self:Say("So you want to know what a boat was. Fine -- be one. Say [" .. eq.say_link("ready") .. "] and I'll drop you in the Ocean of Tears. Touch the docks of every island without sinking, and maybe you'll understand.")
		end
	elseif task_id == SPACE_TASK_ID then
		if on_space_expedition(e.other) then
			e.other:Message(15, "Your squad is already assembled! Say '[" .. eq.say_link("ready") .. "]' to return to the station.")
			return
		end
		local dz = e.other:CreateExpedition(derelict_station)
		if dz.valid then
			e.self:Say("So you'll wear the armor. Say [" .. eq.say_link("ready") .. "] and I'll drop your squad on the Derlict Station, out in the deep of space. Purge the Mildew, silence the Leapers of the Dark, cull the crew -- EVERY last one -- and whatever the little light tells you, do NOT fire the station.")
		end
	end
end
