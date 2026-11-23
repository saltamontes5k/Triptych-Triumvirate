local M = {}

local entries = {
    [920224] = { zone = 350, version = 1, location = {0.0, 0.0, -15.0, 0.0} },
    [920228] = { zone = 354, version = 4, location = {499.86, -1273.8, 47.0, 0.0} },
    [920232] = { zone = 355, version = 3, location = {-23.4781, -55.5385, -12.480121322698368, 0.0} },
}

local requesters = {
    [362117] = { spawn = 102626, zone = 362, tasks = {920224} },
    [365274] = { spawn = 103413, zone = 365, tasks = {920228, 920232} },
}

function M.say(event)
    local npc, client, zone = event.self, event.other, eq.get_zone()
    if not client or not client.valid then return end
    local route = requesters[npc:GetNPCTypeID()]
    if not route or npc:GetSpawnPointID() ~= route.spawn or zone:GetZoneID() ~= route.zone
        or zone:GetInstanceID() ~= 0 or zone:GetInstanceVersion() ~= 0
        or event.message:lower() ~= "directions" then return end
    for _, task in ipairs(route.tasks) do
        local entry = entries[task]
        local instance = client:GetSharedTaskInstanceID(task, entry.zone, entry.version)
        if instance and instance > 0 then
            local p = entry.location
            client:MovePCInstance(entry.zone, instance, p[1], p[2], p[3], p[4])
            return
        end
    end
end

return M
