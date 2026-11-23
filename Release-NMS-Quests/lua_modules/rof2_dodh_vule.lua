-- Original open-world Vule. The Demi-Plane expedition never calls this module.
local M = {}

local zone_id, npc_type, spawn_id = 351, 351034, 101495
local relic_door, lever_door, eye_item = 16283, 16284, 88035
local timer = "dodh_vule_puzzle"
-- Clock positions run clockwise as seen from the entrance, starting on Vule's right.
local statues = {101491, 101487, 101484, 101480, 101479, 101482,
                 101486, 101490, 101492, 101493, 101496, 101494}
local spells = {
    {id = 7161, threshold = 100, interval = 24},
    {id = 7162, threshold = 75, interval = 38},
    {id = 7749, threshold = 60, interval = 32},
    {id = 7163, threshold = 35, interval = 44},
}
local run

local function public_dreadspire()
    local zone = eq.get_zone()
    return zone:GetZoneID() == zone_id and zone:GetInstanceVersion() == 0 and zone:GetInstanceID() == 0
end

local function vules_actor(npc)
    return npc and npc.valid and npc:GetNPCTypeID() == npc_type and npc:GetSpawnPointID() == spawn_id
end

local function placed_actors(expected_type)
    local by_spawn = {}
    -- The legacy NPC lookup uses spawn groups. Index these actors by spawn2.
    for npc in eq.get_entity_list():GetNPCList().entries do
        if npc.valid and npc:GetNPCTypeID() == expected_type then
            local point = npc:GetSpawnPointID()
            if point > 0 then
                if by_spawn[point] == nil then
                    by_spawn[point] = npc
                else
                    by_spawn[point] = false
                end
            end
        end
    end
    return by_spawn
end

local function client_of(mob)
    if not mob or not mob.valid then return nil end
    if mob:IsClient() then return mob:CastToClient() end
    local owner = mob:GetOwner()
    return owner and owner.valid and owner:IsClient() and owner:CastToClient()
end

local function raid_id(client)
    if not client then return nil end
    local raid = client:GetRaid()
    if raid and raid.valid then return raid:GetID() end
end

local function member(client)
    return client and run and raid_id(client) == run.raid_id
end

local function clients_on_hate(npc)
    local clients, seen = {}, {}
    for entry in npc:GetHateList().entries do
        local client = client_of(entry.ent)
        if member(client) and not seen[client:CharacterID()] then
            clients[#clients + 1] = client
            seen[client:CharacterID()] = true
        end
    end
    return clients
end

local function within_room(mob, limit)
    local dx, dy = mob:GetX(), mob:GetY() - 57
    local dz = mob:GetZ() + 1358.75
    return dx * dx + dy * dy <= limit * limit and math.abs(dz) < 22
end

local function clear(npc)
    eq.stop_timer(timer, npc)
    run = nil
end

local function begin(npc, attacker)
    local raid = raid_id(attacker)
    if not raid or not within_room(attacker, 110) or not within_room(npc, 110) then return end
    local placed_statues = placed_actors(351033)
    for _, spid in ipairs(statues) do
        if not placed_statues[spid] then return end
    end
    local stamp = os.time()
    run = {raid_id = raid, boss_id = npc:GetID(), dial = 0, active = {},
           cleansed = 0, fatigue = {}, next_red = stamp + 8, cast = {}, terminal = false}
    for _, spell in ipairs(spells) do run.cast[spell.id] = stamp + spell.interval end
    eq.set_timer(timer, 1000, npc)
    npc:Shout("The moon relic stirs. Watch the gargoyles.")
end

function M.damage(e)
    local npc = e.self
    if not public_dreadspire() or not vules_actor(npc) then return 0 end
    local attacker = client_of(e.other)
    if not run then begin(npc, attacker) end
    if not run or npc:GetID() ~= run.boss_id or not member(attacker) then return -1 end
    if run.terminal or e.damage <= 0 then return 0 end
    if e.damage < npc:GetHP() then return 0 end
    -- Require a demonstrated relic cycle and resolve remaining red statues.
    if run.cleansed == 0 or next(run.active) ~= nil then
        if run.cleansed == 0 then run.next_red = math.min(run.next_red, os.time() + 1) end
        local allowed = npc:GetHP() - 1
        return allowed > 0 and allowed or -1
    end
    run.terminal = true
    return 0
end

function M.combat(e)
    if not e.joined and run and vules_actor(e.self) and run.boss_id == e.self:GetID()
        and not run.terminal then
        clear(e.self)
    end
end

local function glance(npc, clients)
    if #clients > 0 then
        npc:SpellFinished(7599, clients[math.random(#clients)])
    end
end

function M.tick(e)
    local npc = e.self
    if e.timer ~= timer or not run or run.terminal or not vules_actor(npc) or run.boss_id ~= npc:GetID() then return end
    local clients = clients_on_hate(npc)
    if #clients == 0 or not within_room(npc, 110) then
        npc:WipeHateList()
        npc:SetHP(npc:GetMaxHP())
        clear(npc)
        return
    end
    if #clients > 24 then
        local tank = client_of(npc:GetHateTop())
        if member(tank) then
            -- Existing public return destination from Dreadspire zone point 1484.
            tank:MovePC(358, 1504, 857, 50, 0)
        end
    end
    local stamp = os.time()
    for position, deadline in pairs(run.active) do
        if deadline <= stamp then
            glance(npc, clients)
            run.active[position] = stamp + 18
        end
    end
    if run.next_red <= stamp then
        local candidates = {}
        for i = 1, #statues do
            if not run.active[i] then candidates[#candidates + 1] = i end
        end
        if #candidates > 0 then
            local position = candidates[math.random(#candidates)]
            run.active[position] = stamp + 18
            -- Local text telegraph until the red/blue texture binding is verified.
            npc:Shout(string.format("Gargoyle %d glows red.", position))
        end
        run.next_red = stamp + 30
    end
    local target = npc:GetTarget()
    if target and target.valid then
        for _, spell in ipairs(spells) do
            if npc:GetHPRatio() <= spell.threshold and run.cast[spell.id] <= stamp then
                npc:CastSpell(spell.id, target:GetID())
                run.cast[spell.id] = stamp + spell.interval
                break
            end
        end
    end
end

function M.click(e)
    if not public_dreadspire() or not run or run.terminal or not member(e.self) then return end
    local door = e.door:GetDoorDBID()
    if door ~= relic_door and door ~= lever_door then return end
    local dx = e.self:GetX()
    local dy = e.self:GetY() - 48
    if dx * dx + dy * dy > 25 * 25 or math.abs(e.self:GetZ() + 1359) > 16 then return end
    if door == relic_door then
        run.dial = run.dial % #statues + 1
        e.self:Message(MT.Yellow, string.format("The relic illuminates gargoyle %d.", run.dial))
        return
    end
    local character = e.self:CharacterID()
    local stamp = os.time()
    if (run.fatigue[character] or 0) > stamp then
        e.self:Message(MT.Yellow, "You are too fatigued to pull the lever.")
        return
    end
    local npc = placed_actors(npc_type)[spawn_id]
    if not vules_actor(npc) or npc:GetID() ~= run.boss_id then return end
    run.fatigue[character] = stamp + 70
    if run.active[run.dial] then
        run.active[run.dial] = nil
        run.cleansed = run.cleansed + 1
        npc:Shout("The red light fades and the chamber shakes.")
    else
        glance(npc, clients_on_hate(npc))
    end
end

function M.death(e)
    if not public_dreadspire() or not run or not run.terminal or not vules_actor(e.killed)
        or e.killed_entity_id ~= run.boss_id or not member(client_of(e.other)) then return end
    local corpse = e.corpse
    local finished_id = run.boss_id
    clear(e.killed)
    if not corpse or not corpse.valid or not corpse:IsNPCCorpse() or corpse:GetID() ~= finished_id then return end
    -- SQL detaches the legacy chance-based Vule eye link. Conserve unrelated loot.
    if corpse:CountItem(eye_item) ~= 0 then return end
    corpse:AddItem(eye_item, 1)
    corpse:AddItem(eye_item, 1)
end

return M
