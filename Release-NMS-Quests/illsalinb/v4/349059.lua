-- Four of the five upper locations and both tunnel locations are active
-- in any Normal occurrence. Keep all five upper locations available.
local upper = {261475, 261476, 261477, 261478, 261479}

function event_spawn(e)
    local zone = eq.get_zone()
    local instance = zone:GetInstanceID()
    if zone:GetZoneID() ~= 349 or zone:GetInstanceVersion() ~= 4 or instance <= 0 then return end
    local excluded = upper[(instance % #upper) + 1]
    if e.self:GetSpawnPointID() == excluded then
        eq.disable_spawn2(excluded)
        e.self:Depop(false)
    end
end
