--[[
Solteris (421) - zone controller (NPC 421000, PEQ "Controller" static).

Anguish zone_status.lua pattern:
  * event_spawn (instance boot): register chest loot events, hide island-1
    statics whose event is already locked out, spawn the island 2-4 bosses
    whose events are not locked out.
  * event_signal: an encounter completed -> add the 4d12h expedition lockout.
    Chests are spawned by the encounter scripts at the kill site so they sit
    on the corpse location; loot is protected with SetLootEventByNPCTypeID.

Signal keys (used by encounters via eq.signal(421000, key)):
  1001 Mayong's Mistresses            1005 Irrissa the Seer
  1002 Aprosis, the Fourth Confidant  1006 Commodus, Solar Construct
  1003 Rear Guard Captain Balreth     1007 The Two Gods
  1004 Astire, the Lunar Eclipse
]]

local LOCKOUT_DURATION = eq.seconds("4d12h");

local EVENTS = {
	[1001] = { name = "Mayong's Mistresses",           chest = 421090 },
	[1002] = { name = "Aprosis, the Fourth Confidant", chest = 421091 },
	[1003] = { name = "Rear Guard Captain Balreth",    chest = 421092 },
	[1004] = { name = "Astire, the Lunar Eclipse",     chest = 421093 },
	[1005] = { name = "Irrissa the Seer",              chest = 421094 },
	[1006] = { name = "Commodus, Solar Construct",     chest = 421095 },
	[1007] = { name = "The Two Gods",                  chest = 421096 },
}

-- PEQ island-1 statics (sisters + invisible placeholders, Lochmaul + Aprosis
-- + their placeholders). Hidden per-instance when their event is locked out.
local MISTRESSES_STATICS = { 421001, 421002, 421003, 421004 };
local APROSIS_STATICS    = { 421005, 421006, 421007 };

-- Island 2-4 bosses: { npc_type_id, x, y, z, signal_key }
-- Coordinates = Brewall map POIs negated (see 20260921_tbs_solteris_raid.sql).
local SPAWNS = {
	{ 421040, -1499,  996, 1328, 1003 },  -- Rear Guard Captain Balreth
	{ 421045, -1832, 2644, 1328, 1004 },  -- Astire, the Lunar Eclipse
	{ 421055, -1121, 3255, 2659, 1005 },  -- Irrissa the Seer
	{ 421065, -1643, 4580, 2659, 1006 },  -- Commodus, Solar Construct
	{ 421098, -2500, 5560, 3914, 1007 },  -- Mayong Mistmoore (throne room)
	{ 421097, -2600, 5660, 3914, 1007 },  -- Solusek Ro (throne room)
}

function setup_lockouts(expedition)
	for _, ev in pairs(EVENTS) do
		expedition:SetLootEventByNPCTypeID(ev.chest, ev.name)
	end
end

function event_spawn(e)
	local expedition = eq.get_expedition()
	if not expedition.valid then
		return
	end

	setup_lockouts(expedition)

	-- island 1: statics are already in the instance; remove cleared events
	if expedition:HasLockout(EVENTS[1001].name) then
		for _, id in ipairs(MISTRESSES_STATICS) do
			eq.depop_all(id)
		end
	end
	if expedition:HasLockout(EVENTS[1002].name) then
		for _, id in ipairs(APROSIS_STATICS) do
			eq.depop_all(id)
		end
	end

	-- islands 2-4: spawn what this expedition has not yet cleared
	for _, s in ipairs(SPAWNS) do
		if not expedition:HasLockout(EVENTS[s[5]].name) then
			eq.unique_spawn(s[1], 0, 0, s[2], s[3], s[4], 0)
		end
	end
end

function event_signal(e)
	local ev = EVENTS[e.signal]
	if not ev then
		return
	end

	local expedition = eq.get_expedition()
	if expedition.valid and not expedition:HasLockout(ev.name) then
		expedition:AddLockout(ev.name, LOCKOUT_DURATION)
		eq.zone_emote(MT.Red, ev.name .. " has been defeated! The way onward is open.");
	end
end
