local missions = { 920271, 920272, 920273 }

function event_say(e)
    local zone = eq.get_zone()
    if not e.other or not e.other.valid or not e.self or not e.self.valid
        or zone:GetZoneID() ~= 365 or zone:GetInstanceVersion() ~= 0
        or zone:GetInstanceID() ~= 0 or e.self:GetNPCTypeID() ~= 365286
        or e.self:GetSpawnPointID() ~= 103435
        or e.message:lower() ~= "hail" then
        return
    end

    if e.other:GetCharacterFactionLevel(1050) < 200 then
        return
    end

    local offers = {}
    if e.other:IsTaskCompleted(920271) then
        offers[#offers + 1] = 920270
    end
    for _, task in ipairs(missions) do
        offers[#offers + 1] = task
    end
    eq.task_selector(offers)
end
