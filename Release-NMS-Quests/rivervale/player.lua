-- rivervale/player.lua
-- NMS test monster mission: the Fool's Gold Cake Defense (rivervale v202).
-- Expedition members who zone in get shrouded into immobile birthday cakes by
-- the zone controller (shrouds.id 500). Every cake must declare "I am
-- delicious" before the defense starts; the controller only receives the start
-- signal once every shrouded cake in the instance has declared. Any member
-- death fails the defense instantly and unshrouds the victim for their bind
-- release. Version 0 Rivervale (the world zone) is untouched.

local CAKE_VERSION  = 202
local RIVERVALE_ID  = 19 -- zoneidnumber (canonical), not zone.id
local CONTROLLER_ID = 1520001801
local SIGNAL_START  = 1
local SIGNAL_FAIL   = 2
local READY_PHRASE  = "i am delicious"

local declared = {} -- char_id -> true (this zone session)

local function in_cake_defense()
	return eq.get_zone_instance_version() == CAKE_VERSION
end

local function on_cake_expedition(client)
	local dz = client:GetExpedition()
	return dz.valid and dz:GetZoneID() == RIVERVALE_ID and dz:GetZoneVersion() == CAKE_VERSION
end

-- Cakes currently in the instance = race 629 and on this expedition.
local function cake_counts()
	local total, ready = 0, 0
	local clients = eq.get_entity_list():GetClientList()
	for client in clients.entries do
		if client.valid and client:GetRace() == 629 and on_cake_expedition(client) then
			total = total + 1
			if declared[client:CharacterID()] then
				ready = ready + 1
			end
		end
	end
	return ready, total
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
	if e.self:GetRace() ~= 629 then
		e.self:Message(15, "You must be a cake before you can declare your deliciousness -- give the baker a moment to coat you.")
		return
	end

	local cid = e.self:CharacterID()
	if declared[cid] then
		e.self:Message(15, "You have already declared your deliciousness. Let the other cakes speak up.")
		return
	end

	declared[cid] = true
	local ready, total = cake_counts()
	eq.zone_emote(15, string.format("%s declares their deliciousness. %d of %d cakes are ready.", e.self:GetCleanName(), ready, total))

	-- Only the last cake to declare starts the feast.
	if total > 0 and ready >= total then
		declared = {}
		eq.signal(CONTROLLER_ID, SIGNAL_START)
	end
end

function event_death(e)
	if not in_cake_defense() then
		return
	end
	-- Only expedition members fail the defense; a GM or stray visitor dying
	-- inside the instance must not wipe the run.
	if not on_cake_expedition(e.self) then
		return
	end
	-- Silent unshroud so the bind release wakes the real character; no
	-- packets here (client is on the death UI). global_player.pl is the
	-- safety net for any other exit path.
	e.self:RemoveShroudSilent()
	eq.signal(CONTROLLER_ID, SIGNAL_FAIL)
end
