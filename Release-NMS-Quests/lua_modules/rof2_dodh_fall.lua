local scope_api = require("rof2_dodh_scene_scope")
local M = {}

local binding = {task = 920243, zone_id = 348, version = 1}
local draygun_type, draygun_spawn = 348005, 260192
local swarm_type, commander_type = 348900, 348901
local commander_point = {-45.8651, 8.241, -26.1245, 384}
local timer = "dodh_fall_recover"
local run

-- Local geometry candidates for isolated testing. The period account establishes
-- eleven first-wave kills and the commander arriving with a second wave.
local first_formation = {
    {-12, -12}, {-6, -12}, {0, -12}, {6, -12}, {12, -12},
    {-12, 0}, {-6, 0}, {0, 0}, {6, 0}, {12, 0}, {0, 12},
}
local second_formation = {{-12, -12}, {0, -12}, {12, -12}, {-12, 12}, {0, 12}, {12, 12}}

local function native_profile(client, scope)
    return client and client.valid and type(client.HasFallOfIllsalinProfile) == "function"
        and client:HasFallOfIllsalinProfile(scope.occurrence, scope.instance)
end

local function client_of(source)
    if not source or not source.valid then return nil end
    if source:IsClient() then return source:CastToClient() end
    local owner = source:GetOwner()
    return owner and owner.valid and owner:IsClient() and owner:CastToClient()
end

local function bind(client)
    local scope = scope_api.bind(binding, client)
    if not scope or not native_profile(client, scope) then return nil end
    if not run or run.scope.occurrence ~= scope.occurrence or run.scope.instance ~= scope.instance then
        run = {scope = scope, waves = {}, first_deaths = 0}
    end
    return run.scope
end

local function member(client)
    return run and scope_api.member(run.scope, client) and native_profile(client, run.scope)
end

local function add_actor(npc_type, xy, role)
    local p = commander_point
    local x, y = p[1] + xy[1], p[2] + xy[2]
    local mob = eq.spawn2(npc_type, 0, 0, x, y, p[3] + 5, p[4])
    if not mob or not mob.valid or not mob:IsNPC() then return nil end
    local npc = mob:CastToNPC()
    local ground = npc:FindGroundZ(x, y, 7)
    if ground ~= ground or math.abs(ground - p[3]) > 9 then
        npc:Depop(false)
        return nil
    end
    local key = scope_api.register(run.scope, npc, role)
    if not key then
        npc:Depop(false)
        return nil
    end
    return key
end

local function abort_spawn(keys)
    for _, key in ipairs(keys) do
        local npc = scope_api.actor(run.scope, key)
        if npc then npc:Depop(false) end
    end
end

local function first_wave(client)
    if run.waves[1] then return true end
    local keys = {}
    for _, point in ipairs(first_formation) do
        local key = add_actor(swarm_type, point, "first_wave")
        if not key then abort_spawn(keys); return false end
        keys[#keys + 1] = key
    end
    run.waves[1] = keys
    for _, key in ipairs(keys) do
        local npc = scope_api.actor(run.scope, key)
        if npc then npc:AddToHateList(client, 1, 0) end
    end
    return true
end

local function commander_wave()
    if run.waves[2] then return true end
    local keys = {}
    for _, point in ipairs(second_formation) do
        local key = add_actor(swarm_type, point, "second_wave")
        if not key then abort_spawn(keys); return false end
        keys[#keys + 1] = key
    end
    local key = add_actor(commander_type, {0, 0}, "commander")
    if not key then abort_spawn(keys); return false end
    keys[#keys + 1] = key
    run.waves[2] = keys
    return true
end

local function settle_commander(client)
    local expected = run.commander_corpse
    if not expected or not client:IsTaskActivityActive(binding.task, 3)
        or type(client.RegisterFallOfIllsalinCommanderCorpse) ~= "function"
        or (run.reported_at and os.time() < run.reported_at + 5) then return end
    local corpse = eq.get_entity_list():GetCorpseByID(expected.id)
    if corpse and corpse.valid and corpse:IsNPCCorpse()
        and corpse:GetEntityVariable("dodh_fall_commander") == expected.marker
        and client:RegisterFallOfIllsalinCommanderCorpse(run.scope.occurrence, run.scope.instance, corpse) then
        run.reported_at = os.time()
        client:UpdateTaskActivity(binding.task, 3, 1)
    end
end

local function settle_first_wave(client)
    if run.first_deaths ~= #first_formation or not client:IsTaskActivityActive(binding.task, 2)
        or (run.first_reported_at and os.time() < run.first_reported_at + 5) then return end
    run.first_reported_at = os.time()
    client:UpdateTaskActivity(binding.task, 2, #first_formation)
end

function M.enter(event)
    local client = event.self
    if not bind(client) then return end
    if client:IsTaskActivityActive(binding.task, 0) then client:UpdateTaskActivity(binding.task, 0, 1) end
    eq.set_timer(timer, 1500, client)
end

function M.tick(event)
    if event.timer ~= timer then return end
    local client = event.self
    if not member(client) then
        eq.stop_timer(timer, client)
        return
    end
    settle_first_wave(client)
    if client:IsTaskActivityActive(binding.task, 3) then
        if run.commander_corpse then settle_commander(client) else commander_wave() end
    end
end

function M.draygun(event)
    local client, npc = event.other, event.self
    if npc:GetNPCTypeID() ~= draygun_type or npc:GetSpawnPointID() ~= draygun_spawn
        or event.message:lower():match("^%s*hail") == nil or not bind(client) then return end
    if client:IsTaskActivityActive(binding.task, 1) then
        if first_wave(client) then
            npc:Say("The drachnids are on us. Hold the Market.")
            client:UpdateTaskActivity(binding.task, 1, 1)
        end
    elseif client:IsTaskActivityActive(binding.task, 2) then
        first_wave(client)
    elseif (client:IsTaskActivityActive(binding.task, 4) or client:IsTaskActivityActive(binding.task, 5))
        and type(client.ExitFallOfIllsalin) == "function" then
        -- Zone owns the authenticated restore and the durable successful-exit
        -- receipt. It advances activity 4 upon a committed successful exit.
        if client:ExitFallOfIllsalin(run.scope.occurrence, run.scope.instance, npc) then
            npc:SendIllusionPacket({race=467, gender=2, texture=3})
        end
    end
end

function M.damage(event)
    local npc = event.self
    local actor = run and npc:GetEntityVariable("rof2_dodh_scene_actor")
    local expected = actor and run.scope.actors[actor]
    local active = expected and scope_api.actor(run.scope, actor)
    if not active or active:GetID() ~= npc:GetID() then return 0 end
    local client = client_of(event.other)
    if not member(client) then return -1 end
    if expected.role == "first_wave" and not client:IsTaskActivityActive(binding.task, 2) then return -1 end
    if expected.role == "commander" and not client:IsTaskActivityActive(binding.task, 3) then return -1 end
    return 0
end

function M.death(event)
    local client = client_of(event.other)
    if not member(client) then return end
    local key, role = scope_api.death(run.scope, event)
    if not key then return end
    if role == "first_wave" then
        run.first_deaths = run.first_deaths + 1
        settle_first_wave(client)
    elseif role == "commander" and client:IsTaskActivityActive(binding.task, 3) then
        local corpse = event.corpse
        if corpse and corpse.valid and corpse:IsNPCCorpse() and corpse:GetID() == event.killed_entity_id then
            local marker = run.scope.occurrence .. ":" .. run.scope.instance .. ":" .. key
            corpse:SetEntityVariable("dodh_fall_commander", marker)
            run.commander_corpse = {id=corpse:GetID(), marker=marker}
            settle_commander(client)
        end
    end
end

return M
