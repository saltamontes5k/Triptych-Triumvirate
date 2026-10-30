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
local MIN_LEVEL       = 40 -- shrouds only go down, never up

local POK_ID = 202 -- zoneidnumber (canonical), not zone.id
local MCKENZIE_HOME = { x = 263, y = 69, z = -125.375, h = 0 }
local OOT_ZONEIN    = { x = -9200, y = 390, z = 6, h = 0 } -- oot safe point, open water

local compass    = { zone = "poknowledge", x = MCKENZIE_HOME.x, y = MCKENZIE_HOME.y, z = MCKENZIE_HOME.z }
local safereturn = { zone = "poknowledge", x = MCKENZIE_HOME.x, y = MCKENZIE_HOME.y, z = MCKENZIE_HOME.z, h = MCKENZIE_HOME.h }
local zonein     = { x = OOT_ZONEIN.x, y = OOT_ZONEIN.y, z = OOT_ZONEIN.z, h = OOT_ZONEIN.h }

local boat_lesson = {
	expedition = { name = BOAT_EXPEDITION, min_players = 1, max_players = 6 },
	instance   = { zone = "oot", version = 29, duration = eq.seconds("2h") },
	compass    = compass,
	safereturn = safereturn,
	zonein     = zonein
}

-- Mission roster: task ids offered in the select window.
local MISSION_TASKS = { BOAT_TASK_ID }

local function on_boat_expedition(client)
	local dz = client:GetExpedition()
	return dz.valid and dz:GetName() == BOAT_EXPEDITION
end

function event_say(e)
	if e.message:findi("^ready$") and on_boat_expedition(e.other) then
		e.other:MovePCDynamicZone(e.other:GetExpedition():GetZoneID())
		return
	end
	if e.message:findi("hail") then
		e.self:Say(string.format(
			"Hmph. %s, is it? In my day the sight of a boat on the horizon stopped a war cold. " ..
			"Never mind an old man's grumbling -- the lessons are in the window.",
			e.other:GetCleanName()))
		e.other:TaskSelector(MISSION_TASKS)
	end
end

function event_task_accepted(e)
	local task_id = tonumber(e.task_id) or -1
	if task_id ~= BOAT_TASK_ID then
		return
	end
	if e.other:GetLevel() < MIN_LEVEL then
		e.other:Message(15, "Old Man McKenzie squints at you. 'Come back when you've seen 40 winters. The sea does not suffer children.'")
		return
	end
	if on_boat_expedition(e.other) then
		e.other:Message(15, "Your lesson is already assembled! Say '[" .. eq.say_link("ready") .. "]' to board.")
		return
	end
	local dz = e.other:CreateExpedition(boat_lesson)
	if dz.valid then
		e.self:Say("So you want to know what a boat was. Fine -- be one. Say [" .. eq.say_link("ready") .. "] and I'll drop you in the Ocean of Tears. Touch the docks of every island without sinking, and maybe you'll understand.")
	end
end
