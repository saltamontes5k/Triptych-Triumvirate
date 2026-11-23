function event_spawn(e)
    local zone = eq.get_zone()
    if zone:GetZoneID() == 351 and zone:GetInstanceVersion() == 0 and zone:GetInstanceID() == 0 then
        e.self:SetSpecialAbility(24, 1)
        e.self:SetSpecialAbility(35, 1)
    end
end

function event_damage_taken(e)
    return -1
end
