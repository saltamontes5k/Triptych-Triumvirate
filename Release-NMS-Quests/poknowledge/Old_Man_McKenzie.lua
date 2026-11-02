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
local HUNT_TASK_ID    = 800005
local HUNT_EXPEDITION = "Old Man McKenzie's King of the Monsters"
local SNACK_TASK_ID   = 800006
local SNACK_EXPEDITION = "Old Man McKenzie's Midnight Snack"
local SPACE_TASK_ID   = 800007
local SPACE_EXPEDITION = "Old Man McKenzie's Derelict Space Station"
local MIN_LEVEL       = 40 -- shrouds only go down, never up

local POK_ID = 202 -- zoneidnumber (canonical), not zone.id
local MCKENZIE_HOME = { x = 263, y = 69, z = -125.375, h = 0 }
local OOT_ZONEIN    = { x = -9200, y = 390, z = 6, h = 0 } -- oot safe point, open water
local MOORS_ZONEIN  = { x = -1378, y = -612, z = 25, h = 0 } -- moors, beside the PoK stone the whelps race for
local SKYSHRINE_ZONEIN = { x = -669.7, y = 1068.2, z = 402.8, h = 0 } -- skyshrine maze level (z 373-409)
local STATION_ZONEIN = { x = 74, y = -696, z = 4.1, h = 2 } -- netherbian, the Dawnshroud arrival pocket

local compass    = { zone = "poknowledge", x = MCKENZIE_HOME.x, y = MCKENZIE_HOME.y, z = MCKENZIE_HOME.z }
local safereturn = { zone = "poknowledge", x = MCKENZIE_HOME.x, y = MCKENZIE_HOME.y, z = MCKENZIE_HOME.z, h = MCKENZIE_HOME.h }
local zonein     = { x = OOT_ZONEIN.x, y = OOT_ZONEIN.y, z = OOT_ZONEIN.z, h = OOT_ZONEIN.h }
local hunt_zonein = { x = MOORS_ZONEIN.x, y = MOORS_ZONEIN.y, z = MOORS_ZONEIN.z, h = MOORS_ZONEIN.h }
local station_zonein = { x = STATION_ZONEIN.x, y = STATION_ZONEIN.y, z = STATION_ZONEIN.z, h = STATION_ZONEIN.h }

local boat_lesson = {
	expedition = { name = BOAT_EXPEDITION, min_players = 1, max_players = 6 },
	instance   = { zone = "oot", version = 29, duration = eq.seconds("2h") },
	compass    = compass,
	safereturn = safereturn,
	zonein     = zonein
}

-- The hunt is McKenzie's alone: solo-only (the task is min/max players 1).
local king_of_monsters = {
	expedition = { name = HUNT_EXPEDITION, min_players = 1, max_players = 1 },
	instance   = { zone = "moors", version = 40, duration = eq.seconds("2h") },
	compass    = compass,
	safereturn = safereturn,
	zonein     = hunt_zonein
}

-- The snack is McKenzie's alone too: solo-only (the task is min/max 1).
local midnight_snack = {
	expedition = { name = SNACK_EXPEDITION, min_players = 1, max_players = 1 },
	instance   = { zone = "skyshrine", version = 41, duration = eq.seconds("2h") },
	compass    = compass,
	safereturn = safereturn,
	zonein     = { x = SKYSHRINE_ZONEIN.x, y = SKYSHRINE_ZONEIN.y, z = SKYSHRINE_ZONEIN.z, h = SKYSHRINE_ZONEIN.h }
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
local MISSION_TASKS = { BOAT_TASK_ID, HUNT_TASK_ID, SNACK_TASK_ID, SPACE_TASK_ID }

local function on_boat_expedition(client)
	local dz = client:GetExpedition()
	return dz.valid and dz:GetName() == BOAT_EXPEDITION
end

local function on_hunt_expedition(client)
	local dz = client:GetExpedition()
	return dz.valid and dz:GetName() == HUNT_EXPEDITION
end

local function on_snack_expedition(client)
	local dz = client:GetExpedition()
	return dz.valid and dz:GetName() == SNACK_EXPEDITION
end

local function on_space_expedition(client)
	local dz = client:GetExpedition()
	return dz.valid and dz:GetName() == SPACE_EXPEDITION
end

function event_say(e)
	if e.message:findi("^ready$") then
		if on_boat_expedition(e.other) or on_hunt_expedition(e.other) or on_snack_expedition(e.other) or on_space_expedition(e.other) then
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
	if e.message:findi("maze") then
		-- the Midnight Snack monologue. He does not tell this story so much
		-- as it leaks out of him.
		e.self:Say("You want to hear about the maze. Nobody wants to hear about the maze. They want the bottle and the story without the drinking part, and the drinking part IS the story.")
		e.self:Emote("stares through you at a hallway that isn't there.")
		e.self:Say("There was this shrine of dragons, way north. Top floor there's a maze -- winding little stone gut, walls like teeth. I went in sober once. ONCE. Worst decision of my life. Everything looks different sober. Smaller. The cakes looked like CAKES, if you can imagine.")
		e.self:Emote("turns his empty bottle over like it owes him money.")
		e.self:Say("I learned two things in that maze. One: the walls don't hate you. The walls don't do ANYTHING. It's the colored ones that get you -- the sad blue one, the mad red one, the glad yellow one, the little bad one. Always hungry, all four. Like me. Like you. Two: everything is food if you're sad enough. EVERYTHING. The eating doesn't fill the hole, kid. But the eating is good.")
		e.self:Say("Say [" .. eq.say_link("ready") .. "] when the window is open, and don't come back crying about the golem. The golem is the honest part.")
		return
	end
	if e.message:findi("hail") then
		e.self:Say(string.format(
			"Hmph. %s, is it? In my day the sight of a boat on the horizon stopped a war cold. " ..
			"Never mind an old man's grumbling -- the lessons are in the window. And if you want to hear about the [" ..
			eq.say_link("maze") .. "], ask me about the maze. Everyone asks eventually. The [" ..
			eq.say_link("space") .. "] story is extra.",
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
	elseif task_id == HUNT_TASK_ID then
		if e.other:IsGrouped() then
			-- The hunt is McKenzie's alone. No expedition is assembled and
			-- nothing is locked out; abandon the task in the window and
			-- come back ungrouped.
			e.other:Message(15, "Old Man McKenzie slams the vial shut. 'ALONE, I said! This hunt is mine, and you'll not drag a circus of helpers into my moors. Lose the group and ask me again.'")
			return
		end
		if on_hunt_expedition(e.other) then
			e.other:Message(15, "Your hunt is already assembled! Say '[" .. eq.say_link("ready") .. "]' to return to the moors.")
			return
		end
		local dz = e.other:CreateExpedition(king_of_monsters)
		if dz.valid then
			e.self:Say("So you'll wear his shape. Say [" .. eq.say_link("ready") .. "] and I'll drop you in the Blightfire Moors, beside the stone those wretched whelps are waddling toward. Devour twelve -- two of every color -- in five minutes, touch nothing froglok-shaped, and let ONE reach the stone and it's over.")
		end
	elseif task_id == SNACK_TASK_ID then
		if e.other:IsGrouped() then
			-- The snack is McKenzie's alone, same as the hunt.
			e.other:Message(15, "Old Man McKenzie laughs, and it is not a nice sound. 'Bring friends into THAT maze? Into the place where the colored ones live? They'd eat your friends first, kid, and then I'd owe the drakes a debt. ALONE. Lose the group and ask me again.'")
			return
		end
		if on_snack_expedition(e.other) then
			e.other:Message(15, "Your snack is already assembled! Say '[" .. eq.say_link("ready") .. "]' to return to the maze.")
			return
		end
		local dz = e.other:CreateExpedition(midnight_snack)
		if dz.valid then
			e.self:Say("So you'll be the ghost. Say [" .. eq.say_link("ready") .. "] and I'll drop you on the maze level of the dragon shrine. Eat all twenty-four cakes. Run from the colored ones -- every fourth cake brings the Sugar Rage up out of the floor, and while it rages, the colored ones are soft. Eat them too. All four. Every last cake.")
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
