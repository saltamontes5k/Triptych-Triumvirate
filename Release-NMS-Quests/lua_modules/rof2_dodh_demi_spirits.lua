local admission = require("rof2_dodh_demi_admission")
local runtime = require("rof2_dodh_raid_runtime")
local M = {}
local spirits = {}
local weapons = {
    devlin = { [1] = 52534, [4] = 52534, [2] = 52535, [3] = 52535 },
    tris = { [9] = 52540, [14] = 52540, [12] = 52541, [13] = 52541 },
    roley = { [7] = 52536, [11] = 52536 },
    adrianna = { [5] = 52537, [16] = 52537 },
    performer = { [8] = 52538, [15] = 52538, [6] = 52539, [10] = 52539 },
}

function M.spawn(dz, event, actor_type, point)
    if not actor_type or not weapons[event] then return end
    local uuid = dz:GetUUID()
    local marker = uuid .. ":spirit:" .. event
    local actor = runtime.spawn_owned(actor_type, point, marker)
    if not actor then return end
    runtime.protect(actor, true)
    spirits[actor:GetID()] = {event = event, id = actor_type, uuid = uuid, marker = marker}
end

function M.say(e)
    local at = spirits[e.self:GetID()]
    if not at or e.self:GetNPCTypeID() ~= at.id
        or e.self:GetEntityVariable("dodh_raid:occurrence") ~= at.marker then return false end
    local client = e.other
    local dz = admission.expedition(client)
    local event = at.event == "adrianna" and "roley" or at.event
    if e.message:lower() ~= "hail" or not dz or dz:GetUUID() ~= at.uuid
        or not dz:HasLockout("Demi-Plane: " .. event) then return true end
    local item = weapons[at.event][client:GetClass()]
    if item and client:CountItem(item) == 0 then
        local receipt = "dodh_demi:spirit:" .. at.event .. ":" .. at.uuid
        if client:GetBucket(receipt) ~= "1" then
            client:SummonItem(item)
            if client:CountItem(item) > 0 then client:SetBucket(receipt, "1", "21600") end
        end
    end
    return true
end

return M
