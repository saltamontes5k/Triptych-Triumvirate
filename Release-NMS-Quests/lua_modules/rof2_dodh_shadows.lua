local scope_api = require("rof2_dodh_scene_scope")
local read_one = require("rof2_dodh_scene_receipts").read_one
local M = {}

local binding = { task = 920245, zone_id = 364, version = 1 }
local cages = {
    [39234] = {
        id = 3, activity = 1, npc = 364022,
        points = {{-3.3066, 369.79, 74.645}, {1.6934, 369.79, 71.012}, {6.6934, 369.79, 75.265}},
    },
    [39233] = { id = 2, activity = 2, npc = 364900, points = {{-233.973, 166.054, 2.150}} },
    [39235] = { id = 4, activity = 3, npc = 364901, points = {{259.605, 185.516, 5.782}} },
}
local controlled_gates = {
    [39245] = { id = 13, requires = {1} }, [39246] = { id = 14, requires = {1} },
    [39241] = { id = 1, requires = {1, 2, 3} }, [39242] = { id = 10, requires = {1, 2, 3} },
}
local bosses = {
    [364015] = { spawn = 260662, activity = 4 },
    [364016] = { spawn = 260663, activity = 5 },
}
local watched_spells = {
    [364900] = {8381, 8382, 8383},
    [364901] = {8378, 8379, 8380},
}
local timer = "dodh_shadows_cast"
local escape_timer = "dodh_shadows_escape"
local escape_sql = [[
SELECT UNIX_TIMESTAMP(a.completed_time)
FROM shared_task_activity_state a
JOIN shared_tasks t ON t.id = a.shared_task_id
WHERE t.id = CAST(? AS UNSIGNED) AND t.task_id = 920245
  AND t.completion_time IS NULL AND a.activity_id = 5 AND a.done_count = 1
  AND a.completed_time IS NOT NULL
LIMIT 1
]]
local run

local function client_of(source)
    if not source or not source.valid then return nil end
    if source:IsClient() then return source:CastToClient() end
    local owner = source:GetOwner()
    return owner and owner.valid and owner:IsClient() and owner:CastToClient()
end

local function completed(activity)
    local required = activity == 1 and 3 or 1
    return eq.get_task_activity_done_count(binding.task, activity) >= required
end

local function open_gates(client)
    for door_id, gate in pairs(controlled_gates) do
        local ready = true
        for _, activity in ipairs(gate.requires) do
            if not completed(activity) then ready = false; break end
        end
        if ready then
            local door = eq.get_entity_list():FindDoor(gate.id)
            if door and door.valid and door:GetDoorDBID() == door_id then door:ForceOpen(client, true) end
        end
    end
end

local function make_actor(scope, cage, point, client)
    local x, y, z = point[1], point[2], point[3]
    local mob = eq.spawn2(cage.npc, 0, 0, x, y, z + 3, 0)
    if not mob or not mob.valid or not mob:IsNPC() then return nil end
    local npc = mob:CastToNPC()
    local ground = npc:FindGroundZ(x, y, 5)
    if ground ~= ground or math.abs(ground - z) > 4 then
        npc:Depop(false)
        return nil
    end
    local key = scope_api.register(scope, npc, cage.activity)
    if not key then
        npc:Depop(false)
        return nil
    end
    if watched_spells[cage.npc] then eq.set_timer(timer, 12000, npc) end
    npc:AddToHateList(client, 1, 0)
    return key
end

function M.click(event)
    local client, door = event.self, event.door
    local id = door:GetDoorDBID()
    local gate, cage = controlled_gates[id], cages[id]
    if not gate and not cage then return 0 end
    local scope = scope_api.bind(binding, client)
    if not scope then return 1 end

    if gate then
        if gate.id ~= door:GetDoorID() then return 1 end
        for _, activity in ipairs(gate.requires) do
            if not completed(activity) then return 1 end
        end
        return 0
    end
    if cage.id ~= door:GetDoorID() or not client:IsTaskActivityActive(binding.task, cage.activity) then
        return 1
    end
    if not run or run.scope.instance ~= scope.instance or run.scope.occurrence ~= scope.occurrence then
        run = { scope = scope, cages = {}, spell_slot = {} }
    end
    if run.cages[cage.activity] then return 1 end
    local keys = {}
    for _, point in ipairs(cage.points) do
        local key = make_actor(run.scope, cage, point, client)
        if not key then
            for _, previous in ipairs(keys) do
                local npc = scope_api.actor(run.scope, previous)
                if npc then npc:Depop(false) end
            end
            return 1
        end
        keys[#keys + 1] = key
    end
    run.cages[cage.activity] = { left = #keys, goal = #keys }
    return 1
end

local function owned_actor(npc)
    if not run then return nil end
    local key = npc:GetEntityVariable("rof2_dodh_scene_actor")
    local actor = key ~= "" and scope_api.actor(run.scope, key)
    if actor and actor:GetID() == npc:GetID() then return key end
end

function M.damage(event)
    local npc = event.self
    local client = client_of(event.other)
    local boss = bosses[npc:GetNPCTypeID()]
    if boss and boss.spawn == npc:GetSpawnPointID() then
        if not client or not client:IsTaskActivityActive(binding.task, boss.activity)
            or not scope_api.bind(binding, client) then
            return -1
        end
    elseif owned_actor(npc) and not scope_api.member(run.scope, client) then
        return -1
    end
    return 0
end

function M.cast(event)
    local npc = event.self
    local key = event.timer == timer and owned_actor(npc)
    local spells = key and watched_spells[npc:GetNPCTypeID()]
    local target = spells and npc:GetTarget()
    if not target or not target.valid or npc:IsCasting() then return end
    local slot = run.spell_slot[key] or 1
    npc:CastSpell(spells[slot], target:GetID())
    run.spell_slot[key] = slot % #spells + 1
end

function M.death(event)
    if not run then return end
    local client = client_of(event.other)
    if not scope_api.member(run.scope, client) then return end
    local key, activity = scope_api.death(run.scope, event)
    local phase = key and run.cages[activity]
    if not phase then return end
    phase.left = phase.left - 1
    if phase.left == 0 and client:IsTaskActivityActive(binding.task, activity) then
        client:UpdateTaskActivity(binding.task, activity, phase.goal)
    end
end

function M.watch_escape(client)
    if client:IsTaskActive(binding.task) then eq.set_timer(escape_timer, 2000, client) end
end

function M.escape(event)
    local client = event.self
    if event.timer ~= escape_timer then return end
    if not client:IsTaskActive(binding.task) then
        eq.stop_timer(escape_timer, client)
        return
    end
    local ready = client:IsTaskActivityActive(binding.task, 6)
    if not ready and not completed(6) then return end
    local scope = scope_api.bind(binding, client)
    if not scope then return end
    local row = read_one(escape_sql, {scope.occurrence})
    local finished = row and tonumber(row[1])
    if not finished or finished <= 0 or os.time() < finished + 120 then return end
    if ready then client:UpdateTaskActivity(binding.task, 6, 1) end
    client:MovePC(362, 719, -1031, 83.75, 214)
end

function M.stage(event)
    if event.task_id == binding.task and scope_api.bind(binding, event.self) then open_gates(event.self) end
end

return M
