local M = {}

local meldrek = {
    { task = 920236, zone = 358, version = 1, phrase = "we wish to continue", point = {-1730, -337, 4} },
    { task = 920237, zone = 358, version = 3, phrase = "i am ready", point = {-1730, -337, 4} },
    { task = 920238, zone = 358, version = 2, phrase = "i am ready", point = {-1730, -337, 4} },
    { task = 920240, zone = 359, version = 1, phrase = "i am ready to proceed", point = {-1549, 577, 4} },
}

local shadows = {
    { task = 920245, zone = 364, version = 1, phrase = "hail", point = {2, 408, 72} },
}

local function matches(event, zone_id, version, npc_id, spawn_id, public)
    local npc, player, zone = event.self, event.other, eq.get_zone()
    return player and player.valid and npc:GetNPCTypeID() == npc_id and npc:GetSpawnPointID() == spawn_id
        and zone:GetZoneID() == zone_id and zone:GetInstanceVersion() == version
        and ((zone:GetInstanceID() == 0) == public)
end

local function request(event, routes)
    local message = event.message:lower():match("^%s*(.-)%s*$"):gsub("[.!]$", "")
    for _, route in ipairs(routes) do
        if message == route.phrase and event.other:IsTaskActive(route.task) then
            local instance = event.other:GetSharedTaskInstanceID(route.task, route.zone, route.version)
            if instance and instance > 0 then
                local p = route.point
                event.other:MovePCInstance(route.zone, instance, p[1], p[2], p[3], 0)
                return
            end
        end
    end
end

function M.meldrek(event)
    if matches(event, 358, 0, 358031, 101793, true) then request(event, meldrek) end
end

function M.stillpool(event)
    if not matches(event, 362, 0, 362104, 102601, true) then return end
    local client = event.other
    if client:IsTaskActive(920243) then
        if event.message:lower():match("^%s*hail[.!]?%s*$")
            and type(client.EnterFallOfIllsalin) == "function" then
            client:EnterFallOfIllsalin(event.self)
        end
        return
    end
    request(event, shadows)
end

function M.rogue_exit(event)
    if not matches(event, 358, 1, 358159, 261109, false) then return end
    local player, zone = event.other, eq.get_zone()
    if event.message:lower():match("^%s*we are ready to go[.!]?%s*$")
        and player:GetSharedTaskInstanceID(920236, 358, 1) == zone:GetInstanceID() then
        player:MovePC(358, -1734, -207, 25.5, 0)
    end
end

return M
