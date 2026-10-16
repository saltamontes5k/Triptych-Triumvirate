-- PoTimeA/B

local expedition_info = {
    expedition = { name = "The Prison of the Forsaken", min_players = 1, max_players = 72 },
    instance   = { zone = "potimeb", version = 255, duration = 604800 }, -- 7 Days
    safereturn = { zone = "potimea", x = -37, y = -110, z = 6.08, h = 0.0 },
    zonein     = { x = -9, y = -2466, z = -79, h = 0 }
}

local POTIMEB_ZONEID = 223

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

    elseif door_id == 2 then -- OBJ_VOIDPORTAL: SoD void entry
        e.self:Message(MT.Yellow, "You step through the timeshear rift...")
        e.self:MovePC(Zone.thevoida, -79, -158, 33, 0)

    elseif door_id == 1 then
        e.self:Message(MT.Yellow, "You step through time in to a conflux of ages.")
        e.self:MovePC(Zone.potimea, 223, 140, 9, 94)
    end
end
