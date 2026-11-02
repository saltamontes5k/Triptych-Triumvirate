-- beholder/player.lua
-- Mudshoes' Pottery Trial (beholder v80): tradeskill shroud mission #2,
-- spun off the Fool's Gold Cake Defense (rivervale/player.lua). There is no
-- ready phrase here -- stage 1 (the escape) starts the moment the controller
-- shrouds the first golem. This script only reports member deaths so the
-- trial fails instantly and the victim is unshrouded for their bind release.
-- Version 0 beholder (the world zone) is untouched.

local TRIAL_VERSION = 80
local BEHOLDER_ID   = 16 -- zoneidnumber (canonical), not zone.id
local CONTROLLER_ID = 1520001991
local SIGNAL_FAIL   = 2

local function in_trial()
	return eq.get_zone_instance_version() == TRIAL_VERSION
end

local function on_pottery_expedition(client)
	local dz = client:GetExpedition()
	return dz.valid and dz:GetZoneID() == BEHOLDER_ID and dz:GetZoneVersion() == TRIAL_VERSION
end

function event_death(e)
	if not in_trial() then
		return
	end
	-- Only expedition members fail the trial; a GM or stray visitor dying
	-- inside the instance must not wipe the run.
	if not on_pottery_expedition(e.self) then
		return
	end
	-- Silent unshroud so the bind release wakes the real character; no
	-- packets here (client is on the death UI). global_player.pl is the
	-- safety net for any other exit path.
	e.self:RemoveShroudSilent()
	eq.signal(CONTROLLER_ID, SIGNAL_FAIL)
end
