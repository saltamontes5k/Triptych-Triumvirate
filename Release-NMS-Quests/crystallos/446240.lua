-- [[
-- Crystallos (446) -- raid zone controller (NPC 446240).
-- Crystallos, Lair of the Awakened -- the 54-person raid instance (v220).
-- Rasper: raidCrystallos.html. Entry via Laiyken (442036) "We are ready".
--
-- Solteris 421000.lua / Anguish zone_status.lua pattern:
--   * event_spawn (instance boot): register every chest NPC as a loot event
--     so unlocked chests pay raid loot only to the surviving raid;
--   * event_signal: an encounter completed -> add the 72h expedition lockout
--     for that wing and (for the finale) complete the raid flag.
--   * event_death_complete on the controller itself is never expected; the
--     controller is a passive non-combat NPC.
--
-- Signal keys (used by encounters via eq.signal(446240, key)):
--   1001 Halls of Fire (Entharr)          1002 Keepers of Stone
--   1003 Ice Constructs (Aar`Kol)         1004 Aerius/Air wing
--   1005 Brood Mother                     1006 Kerafyrm finale
--]]

local LOCKOUT = eq.seconds("72h")

local EVENTS = {
	[1001] = { name = "Crystallos: Halls of Fire",   chest = 446260 },
	[1002] = { name = "Crystallos: Keepers of Stone", chest = 446261 },
	[1003] = { name = "Crystallos: Ice Constructs",  chest = 446262 },
	[1004] = { name = "Crystallos: Aerius Windfury", chest = 446263 },
	[1005] = { name = "Crystallos: Brood Mother",    chest = 446268 },
	[1006] = { name = "Crystallos: Kerafyrm",        chest = 446269 },
}

-- wing bosses drop their own chest at the kill site; register them too so a
-- wing boss chest is not silently unprotected if a signal is missed.
local BOSS_CHESTS = {
	[1001] = 446260,  -- Entharr (minor) -> Treasure_of_Entharr
	[1002] = 446261,  -- Keeper
	[1003] = 446262,  -- Aar`Kol
	[1004] = 446263,  -- Aerius
	[1005] = 446268,  -- Brood Mother
	[1006] = 446269,  -- Kerafyrm
}

function setup_loot_events(expedition)
	for _, ev in pairs(EVENTS) do
		expedition:SetLootEventByNPCTypeID(ev.chest, ev.name)
	end
	-- the four wing bosses (Tjudawos/Kildrukaun/Zeixshi/Vyskudra) use the
	-- same chest ids as their wing's finale chest; keep them registered.
end

function event_spawn(e)
	local expedition = eq.get_expedition()
	if not expedition.valid then
		return
	end
	setup_loot_events(expedition)
	eq.zone_emote(13, "The crystal halls of the Awakened stir around you. Four wings await.")
end

function event_signal(e)
	local ev = EVENTS[e.signal]
	if not ev then
		return
	end
	local expedition = eq.get_expedition()
	if expedition.valid and not expedition:HasLockout(ev.name) then
		expedition:AddLockout(ev.name, LOCKOUT)
		eq.zone_emote(15, ev.name .. " has been defeated!")
	end
	-- if all five non-finale events are locked out, the raid has cleared the
	-- way to (or already beaten) Kerafyrm; the finale handles its own flag.
end
