-- kaladima/player.lua
-- NMS monster mission: the Dwarven Keg Wedding (kaladima v25).
-- Only active inside the version 25 expedition. The keg (race 377) starts the
-- ceremony by saying "pour the first round"; the controller then walks the
-- group through the five checkpoints. A keg death signals the controller and
-- silently drops the shroud so the bind release wakes the real character.
-- Version 0 South Kaladim (the world zone) is untouched.

local KEG_VERSION  = 25
local KALADIMA_ID  = 60 -- zoneidnumber (canonical), not zone.id
local CONTROLLER_ID = 1520001920
local SIGNAL_START = 10
local SIGNAL_DEATH = 98
local KEG_RACE     = 377
local START_PHRASE = "pour the first round"

local function in_wedding()
	return eq.get_zone_instance_version() == KEG_VERSION
end

local function on_wedding_expedition(client)
	local dz = client:GetExpedition()
	return dz.valid and dz:GetZoneID() == KALADIMA_ID and dz:GetZoneVersion() == KEG_VERSION
end

local function trimmed(msg)
	return msg:lower():gsub("^%s+", ""):gsub("%s+$", "")
end

function event_say(e)
	if not in_wedding() then
		return
	end
	if not trimmed(e.message):find(START_PHRASE) then
		return
	end
	if not on_wedding_expedition(e.self) then
		return
	end
	if e.self:GetRace() ~= KEG_RACE then
		e.self:Message(15, "You must be the keg first -- give the brew a moment to settle.")
		return
	end
	eq.signal(CONTROLLER_ID, SIGNAL_START)
end

function event_death(e)
	if not in_wedding() then
		return
	end
	-- Only expedition members fail the wedding; a GM or stray visitor dying
	-- inside the instance must not wipe the run.
	if not on_wedding_expedition(e.self) then
		return
	end
	e.self:RemoveShroudSilent()
	eq.signal(CONTROLLER_ID, SIGNAL_DEATH)
end
