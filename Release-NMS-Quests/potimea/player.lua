-- PoTimeA/B

local prog = require("nms_progression");

local expedition_info = {
    expedition = { name = "The Prison of the Forsaken", min_players = 1, max_players = 72 },
    instance   = { zone = "potimeb", version = 255, duration = 604800 }, -- 7 Days
    safereturn = { zone = "potimea", x = -37, y = -110, z = 6.08, h = 0.0 },
    zonein     = { x = -9, y = -2466, z = -79, h = 0 }
}

local POTIMEB_ZONEID = 223

-- Xebuxoruk, The Forsaken: the post-Quarm event runs in a dedicated potimea
-- version-9 expedition instead of the shared zone. The fight itself happens
-- on the clocktower top -- where Zebuxoruk has always dropped you -- and the
-- doors below stand at ground level so they are reachable without a teleport.
-- potimeb/Zebuxoruk.lua's [send you] disbands your Time B expedition and
-- ejects you into the garden; the entry door is an invisible trigger on the
-- zone's real sundial (the spot nods to Stormhaven).
local xeb_expedition_info = {
    expedition = { name = "The Forsaken Hourglass", min_players = 1, max_players = 72 },
    instance   = { zone = "potimea", version = 9, duration = 6 * 60 * 60 }, -- 6 Hours
    safereturn = { zone = "potimea", x = 298, y = 919, z = 8, h = 0.0 },
    zonein     = { x = 125, y = -12, z = 182, h = 0 }
}

local POTIMEA_ZONEID    = 219
local XEB_DOORID        = 44
-- The ground-level dial meshes in shared potimea. The zone's own little
-- dials stand at the zone-in spot (290, 915, 8) and at the courtyard
-- sundial (298, 919, 8) -- neither mesh is clickable (their baked door ids
-- are rowed far from here, and door-click events only fire within the
-- 100-unit script range), so the old-school zone-line pattern applies:
-- walk onto a dial and hail it (see event_say). The zone-in dial wakes for
-- players past the Quarm flag; the sundial keeps the xebuxoruk_unlock gate.
local XEB_ZONEIN_DIAL  = { x = 290, y = 915, z = 8 }
local XEB_DIAL_RADIUS  = 10
local XEB_EXPEDITION    = "The Forsaken Hourglass"
-- Must match the event string xebuxoruk_clone.lua passes to exp:AddLockout.
local XEB_LOCKOUT_EVENT = "Xebuxoruk the Forsaken"
-- Where Zebuxoruk has always dropped you: the clocktower top, Xebuxoruk's arena.
local XEB_TOWER_TOP     = { x = 125, y = -12, z = 182, h = 0 }
-- The zone's real sundial: the invisible entry door sits here, and exits and
-- expedition expiry land beside it.
local XEB_SUNDIAL       = { x = 298, y = 919, z = 8, h = 0 }

-- Shared entry into Xebuxoruk's arena: wipe recovery, lockout check,
-- expedition creation, and the move to the tower top. Callers gate access
-- (the sundial's xebuxoruk_unlock qglobal, the shortcut dial's Quarm flag)
-- before calling this.
local function enter_xeb_expedition(e)
    local expedition = e.self:GetExpedition()

    if expedition.valid then
        if expedition:GetZoneName() == "potimea" then
            -- Wipe recovery: your hourglass expedition is still running.
            local instance_id = tonumber(expedition:GetInstanceID()) or 0
            if instance_id == 0 then
                e.self:Message(MT.Red, "The tower reaches for you, but the way will not open. Yell at a GM.")
                return
            end

            e.self:Message(MT.Yellow, "The hourglass remembers you. The tower raises you back to its summit.")
            e.self:MovePCInstance(POTIMEA_ZONEID, instance_id, XEB_TOWER_TOP.x, XEB_TOWER_TOP.y, XEB_TOWER_TOP.z, XEB_TOWER_TOP.h)
        else
            e.self:Message(MT.Red, "You remain bound to another timeline. Release that claim before the tower will answer you.")
        end
        return
    end

    if e.self:HasExpeditionLockout(XEB_EXPEDITION, XEB_LOCKOUT_EVENT) then
        e.self:Message(MT.Red, "The hourglass is cold beneath your hand. You have already unmade the one who wears Zebuxoruk's face -- for now.")
        return
    end

    expedition = e.self:CreateExpedition(xeb_expedition_info)
    if not expedition.valid then
        e.self:Message(MT.Red, "The hourglass will not turn. (Instance creation failed -- tell a GM.)")
        return
    end

    e.self:Message(MT.Yellow, "The hourglass inverts. The clocktower rises through stolen time and Xebuxoruk's arena opens beneath you.")
    e.self:MovePCInstance(POTIMEA_ZONEID, tonumber(expedition:GetInstanceID()) or 0, XEB_TOWER_TOP.x, XEB_TOWER_TOP.y, XEB_TOWER_TOP.z, XEB_TOWER_TOP.h)
end

-- The Ring of Time -- five dials, one per trial wing. Clicking a dial sends you
-- to that wing's entrance in your Time B instance; the wing's trial trigger is
-- proximity based, so arriving starts the trial.
--
-- EQMacEmu gates this behind level 65 + a 7-person raid, caps each wing at 18
-- raiders / 60 total, and only the raid that opened the instance may use it.
-- This server is sized for one or two players, so those gates are gone: any
-- click creates or re-enters your instance, the dials are reusable, and you run
-- the five wings yourself. The trial difficulty itself is handled by the normal
-- instance NPC scaling.
local TRIAL_DIALS = {
    [8]  = { trial = "Air",    x = -36, y = 1352, z = 495, h = 128 },
    [9]  = { trial = "Water",  x = -51, y =  857, z = 495, h = 128 },
    [10] = { trial = "Earth",  x = -35, y = 1636, z = 495, h = 128 },
    [11] = { trial = "Fire",   x = -55, y =  569, z = 495, h = 128 },
    [12] = { trial = "Undead", x = -27, y = 1103, z = 495, h = 128 },
}

local DIAL_ORDER = { 8, 9, 10, 11, 12 }

local function attunement_key(self)
    return "potimea-dials-" .. self:CharacterID()
end

-- Which dials this character has already turned (flavour / progress feedback only).
local function attuned_dials(self)
    local out = {}
    local raw = eq.get_data(attunement_key(self))
    if raw then
        for n in tostring(raw):gmatch("%d+") do
            out[tonumber(n)] = true
        end
    end
    return out
end

local function remember_dial(self, door_id)
    local used = attuned_dials(self)
    if used[door_id] then
        return used
    end

    used[door_id] = true

    local list = {}
    for id in pairs(used) do
        list[#list + 1] = tostring(id)
    end
    table.sort(list)
    eq.set_data(attunement_key(self), table.concat(list, ","), "7d")

    return used
end

local function unlit_dials(used)
    local names = {}
    for _, id in ipairs(DIAL_ORDER) do
        if not used[id] then
            names[#names + 1] = TRIAL_DIALS[id].trial
        end
    end
    return names
end

function event_click_door(e)
    local door_id = e.door:GetDoorID()

    -- GM-only click feedback: makes any dead click diagnosable instead of
    -- silent (it only appears when the click actually dispatched). The
    -- eq.debug twin lands in the zone log when QuestDebug logging is on.
    if e.self:GetGM() then
        local line = string.format("[dial] doorid %d -- you are at %.1f, %.1f, %.1f",
            door_id, e.self:GetX(), e.self:GetY(), e.self:GetZ())
        e.self:Message(MT.DarkGray, line)
        eq.debug(line)
    end

    local dial = TRIAL_DIALS[door_id]

    if dial then
        local expedition = e.self:GetExpedition()

        if not expedition.valid then
            if e.self:HasExpeditionLockout("The Prison of the Forsaken", "Plane of Time") then
                e.self:Message(MT.Red, "The dial is cold beneath your hand. You are still bound to a recent journey through Time.")
                return
            end

            expedition = e.self:CreateExpedition(expedition_info)
            if not expedition.valid then
                e.self:Message(MT.Red, "The ring of time does not answer. (Instance creation failed -- tell a GM.)")
                return
            end

            expedition:AddReplayLockout(14 * 60 * 60) -- 14 Hours

            local expedition_identifier = string.format("potime-%d-phase", expedition:GetID())
            eq.set_data(expedition_identifier, "0", "14H")
        end

        local instance_id = tonumber(expedition:GetInstanceID()) or 0
        if instance_id == 0 then
            e.self:Message(MT.Red, "The dial turns, but the instance will not answer. Yell at a GM.")
            return
        end

        local used = remember_dial(e.self, door_id)

        e.self:Message(MT.Yellow, string.format(
            "The %s dial turns beneath your hand. The ring of time shudders and the way to the %s trial opens.",
            dial.trial, dial.trial))
        e.self:MovePCInstance(POTIMEB_ZONEID, instance_id, dial.x, dial.y, dial.z, dial.h)

        local unlit = unlit_dials(used)
        if #unlit > 0 then
            e.self:Message(MT.DarkGray, "Dials still dark: " .. table.concat(unlit, ", ") .. ".")
        else
            e.self:Message(MT.DarkGray, "Every dial in the ring now answers you. The five trials of Time await.")
        end

    elseif door_id == XEB_DOORID then -- the clocktower doors: Xebuxoruk's arena
        -- Inside the version-9 arena the door is simply the way down and out.
        if eq.get_zone_instance_id() ~= 0 then
            e.self:Message(MT.Yellow, "You step back from the tower's edge and time lowers you gently to the sundial below.")
            e.self:MovePC(POTIMEA_ZONEID, XEB_SUNDIAL.x, XEB_SUNDIAL.y, XEB_SUNDIAL.z, XEB_SUNDIAL.h)
            return
        end

        -- The sundial is a portal, not a locked door: clicking it IS the
        -- deliberate act, so the click path asks for no flag. This is the
        -- shortcut entry the players asked for -- bring a friend and it
        -- opens for them too. The old-school hail walk-up below keeps the
        -- progression gates (Quarm at the zone-in dial, xebuxoruk_unlock at
        -- the courtyard sundial), so the "real" way in still honours flags.
        enter_xeb_expedition(e)

    elseif door_id == 2 then -- OBJ_VOIDPORTAL: SoD void entry
        e.self:Message(MT.Yellow, "You step through the timeshear rift...")
        e.self:MovePC(Zone.thevoida, -79, -158, 33, 0)

    elseif door_id == 1 then
        e.self:Message(MT.Yellow, "You step through time in to a conflux of ages.")
        e.self:MovePC(Zone.potimea, 223, 140, 9, 94)
    end
end

-- The dials are walk-up triggers (old-school zone lines): stand on one of the
-- zone's own dial meshes and hail it. The nearest dial within the trigger
-- radius answers, and each keeps its own gate. Fires on every public say in
-- the zone (client.cpp dispatches EVENT_SAY to the player script), so the
-- hail keyword keeps regular chatter from tripping it.
function event_say(e)
    if not e.message:findi("hail") then
        return
    end

    local spots = {
        { spot = XEB_ZONEIN_DIAL, gate = "shortcut" }, -- the zone-in dial: Quarm flag
        { spot = XEB_SUNDIAL,     gate = "sundial" },  -- the courtyard sundial: unlock
    }

    local best, best_dist
    for _, s in ipairs(spots) do
        local dx, dy = e.self:GetX() - s.spot.x, e.self:GetY() - s.spot.y
        local dist = math.sqrt(dx * dx + dy * dy)
        if dist <= XEB_DIAL_RADIUS and (not best_dist or dist < best_dist) then
            best, best_dist = s, dist
        end
    end
    if not best then
        return
    end

    -- GMs hail straight past the gates; players keep them.
    if best.gate == "shortcut" then
        if not e.self:GetGM() and not prog.stage_complete(e.self, "FNagafen") then
            e.self:Message(MT.Red, "The dial is dead beneath your hand. Only one who has watched Quarm fall may wake it.")
            return
        end
    else
        local qglobals = eq.get_qglobals()
        if not e.self:GetGM() and qglobals.xebuxoruk_unlock ~= "1" then
            e.self:Message(MT.Red, "The sundial is still. Whatever it guards has not yet slipped its moorings in time.")
            return
        end
    end

    e.self:Message(MT.Yellow, "You lay your hand on the dial and it drinks your hail.")
    enter_xeb_expedition(e)
end

-- The sundial zoner (v405) has a DB spawn, but a running zone only reads spawn
-- rows at boot: create it on zone-in when it is missing, so "#reload quests"
-- plus a re-zone is enough to light the walk-up entry without bouncing the
-- zone. Stepping onto the dial runs potimea/Xebuxoruk_Sundial.lua.
local XEB_ZONER_NPC   = 1120001423
local XEB_ZONER_SPOT  = { x = 290.65, y = 917.77, z = 9.2 }

function event_enter(e)
    if eq.get_zone_instance_id() ~= 0 then
        return
    end

    local zoner = eq.get_entity_list():GetNPCByNPCTypeID(XEB_ZONER_NPC)
    if zoner and zoner.valid then
        return
    end

    eq.spawn2(XEB_ZONER_NPC, 0, 0, XEB_ZONER_SPOT.x, XEB_ZONER_SPOT.y, XEB_ZONER_SPOT.z, 0)
end
