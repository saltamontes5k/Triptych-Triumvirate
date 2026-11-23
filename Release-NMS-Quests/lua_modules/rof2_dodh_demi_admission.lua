local progress = require("rof2_dodh_raid_progress")
local routes = require("rof2_dodh_demi_instance_routes")
local blockers = require("rof2_dodh_public_blockers")
local M = {}
local name = "Dreadspire Keep: Demi-Plane of Blood"
local max_raid = 54
local config = {
    expedition = {name = name, min_players = 18, max_players = max_raid},
    instance = {zone = "dreadspire", version = 1, duration = 21600},
    zonein = {x = 1386, y = -1032, z = -574, h = 465},
    safereturn = {zone = "drachnidhive", x = 1116, y = 299, z = 455, h = 10},
}
local lock = "Demi-Plane: mayong"

function M.internal_door(e)
    local door = e.door:GetDoorDBID()
    local destination = routes[door]
    if not destination or e.door:GetDoorID() ~= destination.client_door then return 0 end
    local dz = M.expedition(e.self)
    if not dz or e.self:CalculateDistance(e.door:GetX(), e.door:GetY(), e.door:GetZ()) > 32 then
        return 1
    end
    local at = destination.pose
    e.self:MovePCInstance(351, eq.get_zone():GetInstanceID(), at[1], at[2], at[3], at[4])
    return 1
end

local function monocle(client)
    return client:CountItem(88013) > 0 or client:KeyRingCheck(88013)
end

local function eligible_raid(client)
    local raid = client:GetRaid()
    if not raid.valid or not raid:IsLeader(client) then return false end
    local size = raid:RaidCount()
    if size < 18 or size > max_raid then return false end
    local roster, blood = 0, 0
    -- Every member must be verifiable from the assembled public roster. Subsequent
    -- entry also checks the member's own Monocle, even for an invited member.
    for index = 0, 71 do
        local member = raid:GetClientByIndex(index)
        if member.valid then
            if not monocle(member) then return false end
            roster = roster + 1
            if progress.rank(member) >= 5 then blood = blood + 1 end
        end
    end
    return roster == size and blood >= math.ceil(size * 0.85)
end

-- The fixture ID is supplied by the owner only after wire/model confirmation.
function M.click(e, entrance_door)
    local zone = eq.get_zone()
    if zone:GetZoneID() ~= 351 or zone:GetInstanceVersion() ~= 0 or zone:GetInstanceID() ~= 0
        or entrance_door ~= 16285 or e.door:GetDoorDBID() ~= entrance_door
        or e.door:GetDoorID() ~= 48 then return 0 end
    local client = e.self
    if not monocle(client) then
        client:Message(MT.Yellow, "The statue remains still. You need the Monocle of Blood.")
        return 1
    end
    local current = client:GetExpedition()
    if current.valid then
        if current:GetName() == name and current:GetZoneID() == 351 and current:GetZoneVersion() == 1 then
            client:KeyRingAdd(88013)
            client:MovePCDynamicZone("dreadspire", 1, false)
        end
        return 1
    end
    if not eligible_raid(client) then
        client:Message(MT.Yellow, "Assemble your keyed raid before asking to enter.")
        return 1
    end
    local dz = client:CreateExpedition(config)
    if dz.valid then client:KeyRingAdd(88013) end
    return 1
end

function M.expedition(client)
    if not client or not client.valid or not monocle(client) then return nil end
    return progress.same_instance(client, name, 351, 1)
end

function M.enter(e)
    if eq.get_zone():GetZoneID() ~= 351 or eq.get_zone():GetInstanceVersion() ~= 1 then return end
    local client = e.self
    if not M.expedition(client) then
        client:MovePCInstance(354, 0, 1116, 299, 455, 10)
        return
    end
    M.apply_mists(client)
end

function M.apply_mists(client)
    if not M.expedition(client) then return end
    local blocker_count = blockers.count(client)
    local aura = blocker_count < 4 and 7023 + blocker_count
    local mire = blocker_count < 3 and 9119 + blocker_count
    for spell = 7023, 7026 do if spell ~= aura then client:BuffFadeBySpellID(spell) end end
    for spell = 9119, 9121 do if spell ~= mire then client:BuffFadeBySpellID(spell) end end
    if aura then client:SpellFinished(aura, client) end
    if mire then client:SpellFinished(mire, client) end
end

function M.can_loot(e)
    -- Native Lua loot callbacks run before inventory transfer. Backflag credit
    -- must be issued only by a successful native post-transfer path.
    if not e.corpse or not e.corpse.valid or not e.corpse:IsNPCCorpse() then return 0 end
    local client = e.other
    local dz = M.expedition(client)
    if not dz then return 1 end
    if progress.rank(client) == 5 then return 0 end
    if e.item and e.item.valid and e.item:GetID() == 88036
        and e.corpse:GetEntityVariable("dodh_demi:backflag") == dz:GetUUID() then
        return 0
    end
    return 1
end

function M.mayong_open(dz)
    return dz and dz.valid and progress.has_tier(dz, 1) and progress.has_tier(dz, 2)
        and not dz:HasLockout(lock)
end

return M
