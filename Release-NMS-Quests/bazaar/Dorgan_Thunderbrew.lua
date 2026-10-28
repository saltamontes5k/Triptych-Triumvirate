-- bazaar/Dorgan_Thunderbrew.lua
-- NMS monster mission: the Dwarven Keg Wedding (kaladima version 25).
-- Dorgan is a dwarven wedding guest standing beside Wendel Sweetcrumb, the
-- baking-mission halfling. He sends level 25+ players into an empty South
-- Kaladim instance where they are shrouded into the Dwarven Keg of Beer
-- (shrouds.id 501, race 377, the barrel/keg model) and must save the wedding.
--
-- IDs live in migration v227 (20261024_dwarven_keg_wedding.sql): shrouds.id
-- 501, kaladima v25, NPCs 1520001900-1930, controller 1520001920.

local EXPEDITION_NAME = "The Dwarven Keg Wedding"
local MIN_LEVEL       = 25 -- the shroud is level 25; shrouds only go down

local compass    = { zone = "bazaar", x = 170, y = -496, z = 3 }
local safereturn = { zone = "bazaar", x = 185, y = -835, z = 4, h = 390 }
local zonein     = { x = 396, y = 44, z = 9, h = 0 }

local keg_wedding = {
	expedition = { name = EXPEDITION_NAME, min_players = 1, max_players = 6 },
	instance   = { zone = "kaladima", version = 25, duration = eq.seconds("2h") },
	compass    = compass,
	safereturn = safereturn,
	zonein     = zonein
}

local function on_wedding_expedition(client)
	local dz = client:GetExpedition()
	return dz.valid and dz:GetName() == EXPEDITION_NAME
end

local function trimmed(msg)
	return msg:lower():gsub("^%s+", ""):gsub("%s+$", "")
end

function event_say(e)
	local msg = e.message:lower()
	if msg:find("hail") then
		e.self:Say(string.format(
			"Hail, %s! You have the look of someone who can hold his ale -- or at least stand next to one. I am Dorgan Thunderbrew, and my cousin's [%s] is in a right pickle.",
			e.other:GetCleanName(), eq.say_link("wedding")))
	elseif msg:find("wedding") then
		if e.other:GetLevel() < MIN_LEVEL then
			e.self:Say("Come back when you have seen 25 winters. A keg needs some age on it.")
			return
		end
		if on_wedding_expedition(e.other) then
			e.self:Say("Your wedding is already under way. Say 'ready' and I will show you back in.")
			return
		end
		e.self:Say("My cousin Hilda is marrying into the Ironforge clan in the Warrior's Guild Hall in South Kaladim. The guests are gathered, the priest is ready, and the ceremonial keg is missing. I need someone to *be* the keg. Are you [" .. eq.say_link("ready") .. "]?")
	elseif msg:find("keg") then
		e.self:Say("Aye, a living keg of beer. The shroud gives you the keg's own gifts: a bleary gaze, liquid courage, and a blast of beery wind. Buy them with the monster points the form grants. And mind what I say -- do not kill anyone. Alcohol kills, you know.")
	elseif trimmed(e.message) == "ready" then
		if e.other:GetLevel() < MIN_LEVEL then
			e.self:Say("The keg stays corked for you until you have seen 25 winters.")
			return
		end
		if on_wedding_expedition(e.other) then
			e.other:MovePCDynamicZone(e.other:GetExpedition():GetZoneID())
			return
		end
		local dz = e.other:CreateExpedition(keg_wedding)
		if dz.valid then
			e.self:Say("Into the barrel with you! Group members, say [" .. eq.say_link("ready") .. "] to follow. Once you are in and settled, say 'pour the first round' to begin. Buy your keg abilities first -- you will need Stale Brew, Beer Bubbles, Pass Out, Brewmaster's Bidding, and Keg Blast.")
		else
			e.self:Say("The wedding party is already assembled, or the hall is full. Try again in a moment.")
		end
	end
end
