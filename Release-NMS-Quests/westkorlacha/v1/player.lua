local arrival = require("rof2_dodh_arrival")
local scope_api = require("rof2_dodh_scene_scope")

local binding = {task = 920240, zone_id = 359, version = 1}
local orb = {id = 12, dbid = 304070112, model = "OBJ_SHILLWALLLAMPA"}
local portals = {[14]=39134, [15]=39135, [16]=39136, [17]=39137}
local open_scope

function event_enter_zone(e)
    arrival.credit(e.self, binding.task)
end

local function ready(client)
    return eq.get_task_activity_done_count(binding.task, 3) == 1
        and scope_api.bind(binding, client)
end

local function open_portals(scope, client)
    local native = {}
    for id = 14,17 do
        local candidate = eq.get_entity_list():FindDoor(id)
        if not candidate or not candidate.valid or candidate:GetDoorDBID() ~= portals[id]
            or candidate:GetDoorName() ~= "OBJ_MONOLITHB" or candidate:GetOpenType() ~= 59 then
            return
        end
        native[#native + 1] = candidate
    end
    for _, portal in ipairs(native) do
        portal:SetDisableTimer(true)
        portal:ForceOpen(client, true)
    end
    open_scope = scope
end

function event_click_door(e)
    local client, door = e.self, e.door
    local id, dbid = door:GetDoorID(), door:GetDoorDBID()
    if id == orb.id and dbid == orb.dbid and door:GetDoorName() == orb.model and door:GetOpenType() == 59 then
        local scope = ready(client)
        if scope then open_portals(scope, client) end
        return 1
    end
    if portals[id] ~= dbid then return 0 end
    if open_scope and door:IsDoorOpen() and scope_api.member(open_scope, client)
        and eq.get_task_activity_done_count(binding.task, 3) == 1 then
        client:MovePC(358, -1734, -207, 25.5, 170)
    end
    return 1
end
