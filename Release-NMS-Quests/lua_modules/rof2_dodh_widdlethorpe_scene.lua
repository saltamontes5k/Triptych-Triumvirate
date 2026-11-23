local routes = require("rof2_dodh_widdlethorpe_routes")
local scopes = require("rof2_dodh_scene_scope")
local receipts = require("rof2_dodh_scene_receipts")
local runtime = require("rof2_dodh_raid_runtime")
local M, run = {}, nil

local priest, coral_chest, young, vision, prellius = 260587, 260590, 260433, 260504, 260503
local secret_chest = 260200
local guards = {[260595]=361120, [260596]=361120, [260597]=361121,
    [260598]=361122, [260599]=361120, [260600]=361120}
local rites = {[260588]=361117, [260589]=361117}
local waves = {{489,1268,127.25,370}, {469,1230,121.625,408},
    {540,1265,120.25,373}, {523,1211,119.125,395}}
local protectors = {{-64,381,102.7,0}, {-43.875,406.75,109.06,0}, {1,336,77.1,0},
    {-97,329,78,0}, {6,354,79,0}, {47.125,784,43.5,0}, {30.875,791.125,49.25,0},
    {44.125,793.5,45,0}, {76.125,790.75,52,0}, {122.25,867.25,30.875,0},
    {201,1239,68.125,0}, {202,1215,67.375,0}}
local samples = {
    [361029]={1,85026}, [361030]={1,85026}, [361039]={3,85028},
    [361044]={3,85028}, [361045]={3,85028}, [361032]={2,85027},
    [361033]={2,85027}, [361034]={2,85027},
}
local drop_marker = "dodh_widdlethorpe:drop"

local function task()
    local zone = eq.get_zone()
    return zone:GetZoneID() == 361 and zone:GetInstanceID() > 0
        and routes.versions[zone:GetInstanceVersion()] or nil
end

local function participant()
    if not run then return nil end
    for c in eq.get_entity_list():GetClientList().entries do
        if scopes.member(run.scope, c) then return c end
    end
end

local function start(c)
    local id = task()
    if not id then return false end
    if run then return scopes.member(run.scope, c) end
    local scope = scopes.bind({task=id, zone_id=361, version=eq.get_zone():GetInstanceVersion()}, c)
    if not scope or not receipts.mapping(scope, c) then return false end
    run = {scope=scope, task=id, guards={}, rites={}, waves=0, wave_deaths=0, protectors=0, settled={}}
    run.mark = scope.instance .. ":" .. scope.occurrence
    run.credit = receipts.credit_adapter(scope, participant)
    return true
end

local function credit(activity, count)
    if run.settled[activity] or run.credit(activity, count) == "applied" then
        run.settled[activity] = true
        return true
    end
    return false
end

local function placed(kind, spawn)
    for npc in eq.get_entity_list():GetNPCList().entries do
        if npc.valid and npc:GetNPCTypeID() == kind and npc:GetSpawnPointID() == spawn then return npc end
    end
end

local function closed(npc, value)
    if not npc then return end
    runtime.protect(npc, value)
    if npc:GetClass() == 62 then
        npc:SetSpecialAbility(35, 1)
        npc:SetSpecialAbility(53, value and 1 or 0)
    end
    npc:SetTargetable(not value)
end

local function release(kind, spawn)
    local npc = placed(kind, spawn)
    if npc and npc:GetEntityVariable("dodh_widdlethorpe:open") == "" then
        closed(npc, false)
        npc:SetEntityVariable("dodh_widdlethorpe:open", run.mark)
    end
end

local function actors(kind, points, role)
    local spawned = {}
    for _, point in ipairs(points) do
        local npc = runtime.spawn_owned(kind, point, run.mark)
        if not npc then
            for _, prior in ipairs(spawned) do prior:Depop(false) end
            return false
        end
        npc:SetEntityVariable("dodh_widdlethorpe:role", role)
        if role == "power_chest" then closed(npc, false) end
        spawned[#spawned + 1] = npc
    end
    return true
end

local function all_seen(seen, board)
    for spawn in pairs(board) do if not seen[spawn] then return false end end
    return true
end

local function near(c, x, y, z, radius)
    return c:CalculateDistance(x, y, z) <= radius
end

function M.spawn(e)
    local key = task()
    local npc, spawn = e.self, e.self:GetSpawnPointID()
    if key == 920275 and (spawn == priest or spawn == coral_chest or rites[spawn])
        or key == 920277 and spawn == secret_chest then
        closed(npc, true)
    end
    if key == 920278 and spawn == vision then runtime.protect(npc, true) end
end

function M.damage(e)
    local npc, c = e.self, runtime.owner(e.other)
    if not c or not start(c) then return -1 end
    local spawn = npc:GetSpawnPointID()
    if not all_seen(run.guards, guards) or not all_seen(run.rites, rites) then return -1 end
    if spawn ~= priest or e.damage <= 0 then return 0 end
    local health = npc:GetHP()
    if run.waves < 3 then
        local boundary = math.ceil(npc:GetMaxHP() * (75 - 25 * run.waves) / 100)
        if health - e.damage <= boundary then
            if not actors(361120, waves, "ritual_guardian") then return -1 end
            run.waves = run.waves + 1
            npc:Shout("The chest shakes as the ritual calls its guardians.")
            return health > boundary and health - boundary or -1
        end
    end
    return 0
end

local function real_death(e)
    local c = runtime.owner(e.other)
    if not c or not start(c) then return nil end
    return c, e.killed, runtime.corpse(e)
end

function M.death(e)
    local c, npc, corpse = real_death(e)
    if not c or not npc or not npc.valid or not corpse then return end
    local spawn, kind = npc:GetSpawnPointID(), npc:GetNPCTypeID()
    local role = npc:GetEntityVariable("dodh_widdlethorpe:role")
    local owned = spawn == 0 and npc:GetEntityVariable("dodh_raid:occurrence") == run.mark

    if run.task == 920275 then
        if guards[spawn] == kind then run.guards[spawn] = true
        elseif rites[spawn] == kind then run.rites[spawn] = true
        elseif spawn == priest and kind == 361116 and run.waves == 3 then run.priest_dead = true
        elseif owned and role == "ritual_guardian" and kind == 361120 then run.wave_deaths = run.wave_deaths + 1
        elseif spawn == coral_chest and kind == 361118 and run.coral_ready and e.dodh_cocoon_open and not run.rewarded then
            run.rewarded = true
            corpse:SetEntityVariable(drop_marker, run.mark)
            corpse:AddItem(85024, 1)
            corpse:ResetDecayTimer()
        end
    elseif run.task == 920276 then
        if owned and role == "witheran_protector" and kind == 361940 then
            run.protectors = run.protectors + 1
        elseif owned and role == "power_chest" and kind == 361031 and e.dodh_cocoon_open and not run.rewarded then
            run.rewarded = true
        end
    elseif run.task == 920277 then
        if spawn == secret_chest and kind == 361031 and run.secret_ready and e.dodh_cocoon_open and not run.rewarded then
            run.rewarded = true
        elseif spawn > 0 and samples[kind] and c:IsTaskActivityActive(run.task, samples[kind][1]) then
            local item = samples[kind][2]
            if corpse:CountItem(item) == 0 then
                corpse:SetEntityVariable(drop_marker, run.mark)
                corpse:AddItem(item, 1)
                corpse:ResetDecayTimer()
            end
        end
    elseif spawn == prellius and kind == 361086
        and npc:GetEntityVariable("rof2_dodh_prellius_heals") == run.scope.occurrence .. ":6" then
        run.prellius_dead = true
        run.leave_at = os.time() + 60
    end
end

function M.loot(e)
    local item = e.item and e.item.valid and e.item:GetID()
    if item ~= 85024 and item ~= 85026 and item ~= 85027 and item ~= 85028 then return 0 end
    if not task() then return 0 end
    if not run or not scopes.member(run.scope, e.other) or not e.corpse or not e.corpse.valid
        or not e.corpse:IsNPCCorpse() or e.corpse:GetEntityVariable(drop_marker) ~= run.mark then return 1 end
    return 0
end

local function leave(c)
    local p = routes.outside
    c:MovePCInstance(358, 0, p[1], p[2], p[3], p[4])
end

local function tick_member(c)
    if run.task == 920275 then
        if near(c, 37.875, 797.5, 67, 75) or near(c, 471, 1300, 126.5, 75) then
            run.coral_discovered = true
        end
        if run.coral_discovered then credit(1, 1) end
        if all_seen(run.guards, guards) then
            credit(2, 6)
            for spawn, kind in pairs(rites) do release(kind, spawn) end
            if all_seen(run.rites, rites) then release(361116, priest) end
        end
        if run.priest_dead and run.wave_deaths >= 12 then
            credit(3, 1)
            if c:IsTaskActivityActive(run.task, 4) then
                run.coral_ready = true
                release(361118, coral_chest)
            end
        end
    elseif run.task == 920276 then
        local npc = placed(361065, young)
        if npc and near(c, 112, 1647, 82.875, 28) then run.young_discovered = true end
        if run.young_discovered then credit(1, 1) end
        if npc and c:IsTaskActivityActive(run.task, 2) then
            npc:SetEntityVariable("dodh_learning:ready", run.scope.occurrence)
            if npc:GetEntityVariable("dodh_learning:charm") == run.scope.occurrence then run.charmed = true end
        end
        if run.charmed then
            credit(2, 1)
            if not run.protectors_spawned and c:IsTaskActivityActive(run.task, 3) then
                run.protectors_spawned = actors(361940, protectors, "witheran_protector")
            end
        end
        if run.protectors >= 4 then credit(3, 4) end
        if not run.power_chest and c:IsTaskActivityActive(run.task, 4) then
            run.power_chest = actors(361031, {{-42, 388, 104.5, 0}}, "power_chest")
        end
        if run.power_exit and credit(4, 1) and run.power_exit == c:CharacterID() then
            run.power_exit = nil
            leave(c)
        end
    elseif run.task == 920277 then
        if c:IsTaskActivityActive(run.task, 4) or c:IsTaskActivityActive(run.task, 5)
            or c:IsTaskActivityActive(run.task, 6) then
            run.secret_ready = true
            release(361031, secret_chest)
        end
    else
        if placed(361087, vision) and (near(c, -16, 1842, -3, 25) or near(c, -355, 1971, 88.625, 24)) then
            run.vision_seen = true
        end
        if run.vision_seen then credit(1, 1) end
        if run.prellius_dead then credit(2, 1) end
    end
end

function M.tick()
    local c = participant()
    if not c then return end
    credit(0, 1)
    for member in eq.get_entity_list():GetClientList().entries do
        if scopes.member(run.scope, member) then tick_member(member) end
    end
    if run.leave_at and os.time() >= run.leave_at then
        for member in eq.get_entity_list():GetClientList().entries do
            if scopes.member(run.scope, member) then
                member:Message(MT.Yellow, "The lair shakes as the Korlach awakens.")
                leave(member)
            end
        end
    end
end

function M.enter(e)
    if start(e.self) then
        eq.load_encounter("rof2_dodh_widdlethorpe_scene")
    end
end

function M.load(e)
    if not task() then return end
    eq.add_area(920276, 1, -80, -32, 153, 185, -2, 65)
    eq.set_timer("widdlethorpe_scene", 1000, e.encounter)
end

function M.area(e)
    if e.area_id ~= 920276 or not start(e.self) then return end
    if run.task == 920276 and e.self:IsTaskActivityActive(run.task, 4) then
        run.power_exit = run.power_exit or e.self:CharacterID()
        return
    end
    leave(e.self)
end

return M
