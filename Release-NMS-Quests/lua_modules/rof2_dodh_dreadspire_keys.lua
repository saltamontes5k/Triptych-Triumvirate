local M = {}

function M.click(e)
    local zone = eq.get_zone()
    if zone:GetZoneID() ~= 351 or zone:GetInstanceVersion() ~= 0 or zone:GetInstanceID() ~= 0
        or e.door:GetDoorDBID() ~= 16270 or e.door:GetDoorID() ~= 32 then return 0 end
    if not e.self:IsTaskCompleted(505745) then
        e.self:Message(MT.Yellow, "The book is bound in place.")
        return 1
    end
    local door = eq.get_entity_list():GetDoorsByDoorID(29)
    if door.valid and door:GetDoorDBID() == 16267 then door:ForceOpen(e.self) end
    return 1
end

return M
