local M = {}
local actor_marker = "rof2_dodh_scene_actor"

local function current(scope)
    local zone = eq.get_zone()
    return zone:GetInstanceID() == scope.instance
        and zone:GetZoneID() == scope.binding.zone_id
        and zone:GetInstanceVersion() == scope.binding.version
end

function M.member(scope, client)
    return current(scope) and client and client.valid
        and client:IsTaskActive(scope.binding.task)
        and client:GetSharedTaskIdentity() == scope.occurrence
        and client:GetSharedTaskInstanceID(scope.binding.task, scope.binding.zone_id, scope.binding.version)
            == scope.instance
end

function M.bind(binding, client)
    local zone = eq.get_zone()
    local instance = zone:GetInstanceID()
    if instance <= 0 or not client or not client.valid then
        return nil
    end
    local occurrence = client:GetSharedTaskIdentity()
    if type(occurrence) ~= "string" or not occurrence:match("^[1-9][0-9]*$") then
        return nil
    end
    local scope = {
        binding = binding, instance = instance, occurrence = occurrence,
        generation = 0, actors = {},
    }
    return M.member(scope, client) and scope or nil
end

function M.register(scope, npc, role)
    if not current(scope) or not npc or not npc.valid or npc:GetID() <= 0 then
        return nil
    end
    if npc:GetEntityVariable(actor_marker) ~= "" then
        return nil
    end
    scope.generation = scope.generation + 1
    local key = table.concat({scope.instance, scope.occurrence, scope.generation}, ":")
    npc:SetEntityVariable(actor_marker, key)
    scope.actors[key] = { id = npc:GetID(), npc_type = npc:GetNPCTypeID(), spawn = npc:GetSpawnPointID(),
        generation = scope.generation, role = role }
    return key
end

function M.register_placed(scope, npc_type, spawn_id, role)
    if not current(scope) or type(spawn_id) ~= "number" or spawn_id <= 0 then
        return nil
    end
    -- The legacy GetNPCBySpawnID API searches spawn groups, not spawn2 IDs.
    local placed
    for npc in eq.get_entity_list():GetNPCList().entries do
        if npc.valid and npc:GetSpawnPointID() == spawn_id and npc:GetNPCTypeID() == npc_type then
            if placed then return nil end
            placed = npc
        end
    end
    return M.register(scope, placed, role)
end

function M.actor(scope, key)
    local binding = scope.actors[key]
    if not current(scope) or not binding or binding.dead then
        return nil
    end
    local npc = eq.get_entity_list():GetNPCByID(binding.id)
    if not npc or not npc.valid or npc:GetNPCTypeID() ~= binding.npc_type
        or npc:GetEntityVariable(actor_marker) ~= key then
        return nil
    end
    return npc
end

function M.death(scope, event)
    local npc = event.killed
    if not current(scope) or not npc or not npc.valid then
        return nil
    end
    local key = npc:GetEntityVariable(actor_marker)
    local binding = scope.actors[key]
    if not binding or binding.dead or binding.id ~= event.killed_entity_id
        or binding.npc_type ~= npc:GetNPCTypeID() then
        return nil
    end
    binding.dead = true
    return key, binding.role
end

function M.living_at(scope, actor, point, radius, height)
    local npc = M.actor(scope, actor)
    if not npc or npc:GetHP() <= 0 or npc:IsEngaged() then
        return false
    end
    local dx, dy = npc:GetX() - point[1], npc:GetY() - point[2]
    return dx * dx + dy * dy <= radius * radius and math.abs(npc:GetZ() - point[3]) <= height
end

return M
