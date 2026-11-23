local M = {}

local missions = {
    [920224] = { zone = 350, version = 1 },
    [920226] = { zone = 355, version = 2 },
    [920228] = { zone = 354, version = 4 },
    [920230] = { zone = 366, version = 2 },
    [920232] = { zone = 355, version = 3 },
    [920234] = { zone = 356, version = 1 },
    [920236] = { zone = 358, version = 1 },
    [920237] = { zone = 358, version = 3 },
    [920238] = { zone = 358, version = 2 },
    [920239] = { zone = 359, version = 2 },
    [920240] = { zone = 359, version = 1 },
    [920241] = { zone = 350, version = 3 },
    [920242] = { zone = 349, version = 4 },
    [920245] = { zone = 364, version = 1 },
}

function M.credit(client, task_id)
    if not client or not client.valid then
        return
    end
    local binding = missions[task_id]
    local zone = eq.get_zone()
    local instance_id = zone:GetInstanceID()
    if not binding or instance_id == 0 or zone:GetZoneID() ~= binding.zone
        or zone:GetInstanceVersion() ~= binding.version
        or not client:IsTaskActivityActive(task_id, 0) then
        return
    end
    if client:GetSharedTaskInstanceID(task_id, binding.zone, binding.version) == instance_id then
        client:UpdateTaskActivity(task_id, 0, 1)
    end
end

return M
