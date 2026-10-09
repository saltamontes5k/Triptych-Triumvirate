-- rivervale/player.lua
-- NMS test monster mission: the Fool's Gold Cake Defense (rivervale v202).
-- Expedition members who zone in get shrouded into immobile birthday cakes by
-- the zone controller (shrouds.id 500); the defense starts when a member says
-- "I am delicious" (the phrase deliberately has no timer -- cakes may take as
-- long as they need to prepare); any death fails the defense instantly and
-- unshrouds the victim for their bind release. Version 0 Rivervale (the world
-- zone) is untouched.

local CAKE_VERSION  = 202
local RIVERVALE_ID  = 19 -- zoneidnumber (canonical), not zone.id
local CONTROLLER_ID = 1520001801
local SIGNAL_START  = 1
local SIGNAL_FAIL   = 2
local READY_PHRASE  = "i am delicious"

local function in_cake_defense()
	return eq.get_zone_instance_version() == CAKE_VERSION
end

local function on_cake_expedition(client)
	local dz = client:GetExpedition()
	return dz.valid and dz:GetZoneID() == RIVERVALE_ID and dz:GetZoneVersion() == CAKE_VERSION
end

function event_say(e)
	if not in_cake_defense() then
		return
	end
	if not e.message:findi(READY_PHRASE) then
		return
	end
	if not on_cake_expedition(e.self) then
		return
	end
	-- /say only: this event set has no shout hook. Controller ignores the
	-- signal unless the defense is still waiting to start.
	eq.signal(CONTROLLER_ID, SIGNAL_START)
end

function event_death(e)
	if not in_cake_defense() then
		return
	end
	-- Silent unshroud so the bind release wakes the real character; no
	-- packets here (client is on the death UI). global_player.pl is the
	-- safety net for any other exit path.
	e.self:RemoveShroudSilent()
	eq.signal(CONTROLLER_ID, SIGNAL_FAIL)
end
