-- Physical entrance candidates from the Normal mission actor handoff.
local M = {}

local illsalin_entrances = {
    [16607] = { door = 8, task = 920241, zone = 350, version = 3, point = {0, 0, -15} },
    [16599] = { door = 2, task = 920242, zone = 349, version = 4, point = {1, 2, -21} },
}
local xill_entrances = {
    [16289] = { door = 4, task = 920239, zone = 359, version = 2, point = {-1391, -727, 3} },
}

local function enter(event, public_zone, entrances)
    local client, door, zone = event.self, event.door, eq.get_zone()
    if zone:GetZoneID() ~= public_zone or zone:GetInstanceVersion() ~= 0
        or zone:GetInstanceID() ~= 0 or not client.valid or not door.valid then
        return 0
    end
    local route = entrances[door:GetDoorDBID()]
    if not route or route.door ~= door:GetDoorID() or not client:IsTaskActive(route.task) then
        return 0
    end
    local instance = client:GetSharedTaskInstanceID(route.task, route.zone, route.version)
    if not instance or instance <= 0 then
        return 0
    end
    local point = route.point
    client:MovePCInstance(route.zone, instance, point[1], point[2], point[3], 0)
    return 1
end

function M.illsalin(event)
    return enter(event, 347, illsalin_entrances)
end

function M.xill(event)
    return enter(event, 358, xill_entrances)
end

function M.praetorian_exit(event)
    local client, door, zone = event.self, event.door, eq.get_zone()
    local instance = zone:GetInstanceID()
    if not client.valid or not door.valid or instance <= 0 or zone:GetZoneID() ~= 349
        or zone:GetInstanceVersion() ~= 4 or door:GetDoorDBID() ~= 40010 or door:GetDoorID() ~= 1
        or client:GetSharedTaskInstanceID(920242, 349, 4) ~= instance then
        return 0
    end
    client:MovePC(347, -1195.75, -1193.0, 106, 54)
    return 1
end

return M
