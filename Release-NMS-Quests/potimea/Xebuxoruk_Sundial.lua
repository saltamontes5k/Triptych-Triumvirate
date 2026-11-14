-- The hourglass zoner on the courtyard sundial (potimea, v405).
--
-- The dial the players pointed at is static potimea.s3d geometry: clicking it
-- sends no OP_ClickDoor at all, which is why every doors-row attempt on that
-- spot produced a dead click. The trigger therefore has to be an entity, and
-- they asked for invisible rather than another model: this is an invisible man
-- (race 127) standing on the dial with a +/-5 box. Step onto the dial and The
-- Forsaken Hourglass opens.
--
-- The entry block is a twin of potimea/player.lua's enter_xeb_expedition --
-- keep the expedition name, lockout event and tower-top spot in sync.
--
-- The box is deliberately small: the expedition's safereturn and the arena
-- exit door both land at (298, 919), just outside it, so leaving the arena
-- does not bounce the player straight back in.

local prog = require("nms_progression")

local POTIMEA_ZONEID    = 219
local XEB_EXPEDITION    = "The Forsaken Hourglass"
local XEB_LOCKOUT_EVENT = "Xebuxoruk the Forsaken"
-- Where Zebuxoruk has always dropped you: the clocktower top, Xebuxoruk's arena.
local XEB_TOWER_TOP     = { x = 125, y = -12, z = 182, h = 0 }

local xeb_expedition_info = {
    expedition = { name = XEB_EXPEDITION, min_players = 1, max_players = 72 },
    instance   = { zone = "potimea", version = 9, duration = 6 * 60 * 60 }, -- 6 Hours
    safereturn = { zone = "potimea", x = 298, y = 919, z = 8, h = 0.0 },
    zonein     = { x = 125, y = -12, z = 182, h = 0 }
}

local function enter_hourglass(client)
    local expedition = client:GetExpedition()

    if expedition.valid then
        if expedition:GetZoneName() == "potimea" then
            local instance_id = tonumber(expedition:GetInstanceID()) or 0
            -- A GM whose hourglass is already spent (defeat lockout) is not
            -- helped by wiping back into it: retire it and roll a fresh one.
            if client:GetGM() and client:HasExpeditionLockout(XEB_EXPEDITION, XEB_LOCKOUT_EVENT) then
                eq.debug("[hourglass] GM locked out of a spent expedition -- retiring it for a fresh one")
                expedition:RemoveAllMembers()
                expedition = nil
            elseif instance_id == 0 then
                client:Message(MT.Red, "The tower reaches for you, but the way will not open. Yell at a GM.")
                return
            else
                client:Message(MT.Yellow, "The hourglass remembers you. The tower raises you back to its summit.")
                client:MovePCInstance(POTIMEA_ZONEID, instance_id, XEB_TOWER_TOP.x, XEB_TOWER_TOP.y, XEB_TOWER_TOP.z, XEB_TOWER_TOP.h)
                return
            end
        else
            client:Message(MT.Red, "You remain bound to another timeline. Release that claim before the tower will answer you.")
            return
        end
    end

    -- GMs test the encounter; the 72h defeat lockout must not wall them out of
    -- creating a fresh hourglass.
    local is_gm = client:GetGM()
    if not is_gm and client:HasExpeditionLockout(XEB_EXPEDITION, XEB_LOCKOUT_EVENT) then
        client:Message(MT.Red, "The hourglass is cold beneath your hand. You have already unmade the one who wears Zebuxoruk's face -- for now.")
        return
    end

    expedition = client:CreateExpedition(xeb_expedition_info)
    if not expedition.valid then
        client:Message(MT.Red, "The hourglass will not turn. (Instance creation failed -- tell a GM.)")
        eq.debug("[hourglass] expedition creation FAILED for " .. tostring(client:GetCleanName()))
        return
    end

    local new_instance = tonumber(expedition:GetInstanceID()) or 0
    eq.debug(string.format("[hourglass] created for %s dz [%s] instance [%d]", tostring(client:GetCleanName()), tostring(expedition:GetID()), new_instance))
    if is_gm then
        client:Message(MT.DarkGray, string.format("[hourglass] new expedition dz %s, instance %d", tostring(expedition:GetID()), new_instance))
    end

    client:Message(MT.Yellow, "The sundial drinks the light and inverts. Xebuxoruk's arena opens on the clocktower top.")
    client:MovePCInstance(POTIMEA_ZONEID, new_instance, XEB_TOWER_TOP.x, XEB_TOWER_TOP.y, XEB_TOWER_TOP.z, XEB_TOWER_TOP.h)
end

function event_spawn(e)
    local x, y, z = e.self:GetX(), e.self:GetY(), e.self:GetZ()
    eq.set_proximity(x - 5, x + 5, y - 5, y + 5, z - 25, z + 25)
end

function event_enter(e)
    local who = e.other
    if not who or not who:IsClient() then
        return
    end

    -- Post-Quarm content: only an account that has finished Quarm (the
    -- FNagafen progression stage) or a GM may wake the hourglass. Everyone
    -- else gets one hint per hour and is left standing on the dial -- an
    -- unflagged walker must never be handed a version-9 instance, because
    -- Xebuxoruk is a raid boss waiting on the other side.
    if not who:GetGM() and not prog.stage_complete(who, "FNagafen") then
        local hint_key = "xeb-sundial-hint-" .. tostring(who:CharacterID())
        if not eq.get_data(hint_key) then
            eq.set_data(hint_key, "1", "1h")
            who:Message(MT.Red, "The sundial is still. Only one who has watched Quarm fall may wake the hourglass.")
        end
        return
    end

    enter_hourglass(who)
end
