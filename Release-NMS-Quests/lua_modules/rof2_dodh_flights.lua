local read_one = require("rof2_dodh_scene_receipts").read_one
local M = {}

local task, gather, objective, zone_id = 920244, 0, 1, 362
local hut = {694.625, -964.375, 80.28}
local intercept = {831, -1440, 92.70}
local marker = "dodh_flights_occurrence"
local timer = "dodh_flights_check"
local lookup = [[
SELECT 1
FROM shared_tasks t
JOIN shared_task_members m ON m.shared_task_id = t.id
WHERE t.id = CAST(? AS UNSIGNED) AND t.task_id = 920244 AND m.character_id = ?
  AND t.completion_time IS NULL AND (t.expire_time IS NULL OR t.expire_time > NOW())
LIMIT 1
]]
local run
local terminal

local function in_undershore()
    local zone = eq.get_zone()
    return zone:GetZoneID() == zone_id and zone:GetInstanceVersion() == 0 and zone:GetInstanceID() == 0
end

local function is_member(client, occurrence)
    return client and client.valid and client:IsTaskActive(task)
        and client:GetSharedTaskIdentity() == occurrence
end

local function near(mob, point, radius, height)
    local dx, dy = mob:GetX() - point[1], mob:GetY() - point[2]
    return dx * dx + dy * dy <= radius * radius and math.abs(mob:GetZ() - point[3]) <= height
end

local function client_of(source)
    if not source or not source.valid then return nil end
    if source:IsClient() then return source:CastToClient() end
    local owner = source:GetOwner()
    return owner and owner.valid and owner:IsClient() and owner:CastToClient()
end

local function active_member(occurrence)
    for client in eq.get_entity_list():GetClientList().entries do
        if is_member(client, occurrence) then return client end
    end
end

local function tagged_actor(id)
    if not run or not id then return nil end
    local npc = eq.get_entity_list():GetNPCByID(id)
    if npc and npc.valid and npc:GetEntityVariable(marker) == run.occurrence then return npc end
end

local function clean_up()
    for id in pairs(run.actors) do
        local npc = tagged_actor(id)
        if npc then npc:Depop(false) end
    end
    run = nil
end

local function spawn(npc_type, point, grounded, heading)
    local mob = eq.spawn2(npc_type, 0, 0, point[1], point[2], point[3] + (grounded and 3 or 0), heading)
    if not mob or not mob.valid or not mob:IsNPC() then return nil end
    local npc = mob:CastToNPC()
    if grounded then
        local floor = npc:FindGroundZ(point[1], point[2], 5)
        if floor ~= floor or math.abs(floor - point[3]) > 4 then
            npc:Depop(false)
            return nil
        end
    end
    npc:SetEntityVariable(marker, run.occurrence)
    run.actors[npc:GetID()] = true
    return npc
end

function M.watch(event)
    local client = event.self
    if in_undershore() and client and client.valid and client:IsTaskActive(task) then
        eq.set_timer(timer, 1000, client)
    end
end

-- Roles come from the bound database NPC definitions supplied by the release.
-- An absent exact binding leaves the public encounter dormant.
function M.observe(event, roles)
    local client = event.self
    if event.timer ~= timer or not in_undershore() then return end
    if not client:IsTaskActive(task) then
        eq.stop_timer(timer, client)
        return
    end
    if run and not tagged_actor(run.boss) then clean_up() end
    if run or not roles.seeker or not roles.stone or not roles.shattered or not near(client, hut, 42, 13) then
        return
    end
    local occurrence = client:GetSharedTaskIdentity()
    if type(occurrence) ~= "string" or not occurrence:match("^[1-9][0-9]*$") then return end
    if terminal and terminal.occurrence == occurrence and terminal.retry_after > os.time() then return end
    local gathered = 0
    for nearby in eq.get_entity_list():GetClientList().entries do
        if is_member(nearby, occurrence) and near(nearby, hut, 42, 13) then gathered = gathered + 1 end
    end
    if gathered < 3 or not read_one(lookup, {occurrence, client:CharacterID()}) then return end
    if client:IsTaskActivityActive(task, gather) then
        client:UpdateTaskActivity(task, gather, 1)
        return
    end
    if not client:IsTaskActivityActive(task, objective) then return end
    run = { occurrence = occurrence, roles = roles, actors = {}, pass = 1, idle = 0 }
    local seeker = spawn(roles.seeker, intercept, true, 0)
    if not seeker then
        run = nil
        return
    end
    run.boss = seeker:GetID()
    seeker:SetSpecialAbility(3, 1)
    seeker:MoveTo(hut[1], hut[2], hut[3] + 3, 0, false)
    eq.set_timer(timer, 1000, seeker)
end

function M.damage(event)
    local npc = event.self
    if not run or not in_undershore() or npc:GetID() ~= run.boss
        or npc:GetEntityVariable(marker) ~= run.occurrence then
        return 0
    end
    if run.pending then return -1 end
    local hit, current = event.damage, npc:GetHP()
    if hit <= 0 then return 0 end
    local client = client_of(event.other)
    local member = is_member(client, run.occurrence)
    if run.pass == 4 then
        if hit < current or (member and read_one(lookup, {run.occurrence, client:CharacterID()})) then return 0 end
        return current > 1 and current - 1 or -1
    end

    local threshold = math.max(1, math.floor(npc:GetMaxHP() * 0.15))
    if current - hit > threshold then return 0 end
    local allowed = current - threshold
    if member then
        run.pending = true
    else
        allowed = allowed - 1
    end
    return allowed > 0 and allowed or -1
end

function M.tick(event)
    local npc = event.self
    if event.timer ~= timer or not run or not in_undershore()
        or npc:GetID() ~= run.boss or npc:GetEntityVariable(marker) ~= run.occurrence then
        return
    end
    local member = active_member(run.occurrence)
    if not member then
        run.idle = run.idle + 1
        if run.idle >= 30 then clean_up() end
        return
    end
    run.idle = 0
    if not run.pending then return end

    local point = {npc:GetX(), npc:GetY(), npc:GetZ()}
    local heading = npc:GetHeading()
    if run.pass <= 2 then
        local stone = spawn(run.roles.stone, point, false, heading)
        if not stone then clean_up(); return end
        if near(member, point, 120, 30) then stone:AddToHateList(member, 1, 0) end
        npc:HealDamage(npc:GetMaxHP())
    else
        local shattered = spawn(run.roles.shattered, point, false, heading)
        if not shattered then clean_up(); return end
        local target = npc:GetTarget()
        if target and target.valid then shattered:AddToHateList(target, 1, 0) end
        run.actors[npc:GetID()] = nil
        run.boss = shattered:GetID()
        shattered:SetSpecialAbility(3, 1)
        eq.set_timer(timer, 1000, shattered)
        npc:Depop(false)
    end
    run.pass = run.pass + 1
    run.pending = false
end

function M.death(event)
    if not run or not in_undershore() or run.pass ~= 4 or not event.killed or not event.killed.valid
        or event.killed_entity_id ~= run.boss or event.killed:GetEntityVariable(marker) ~= run.occurrence then
        return
    end
    local member = client_of(event.other)
    if is_member(member, run.occurrence) and member:IsTaskActivityActive(task, objective)
        and read_one(lookup, {run.occurrence, member:CharacterID()}) then
        terminal = { occurrence = run.occurrence, retry_after = os.time() + 10 }
        member:UpdateTaskActivity(task, objective, 1)
    end
    run.actors[run.boss] = nil
    clean_up()
end

return M
