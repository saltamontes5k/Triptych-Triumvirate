local scope_api = require("rof2_dodh_scene_scope")
local receipts = require("rof2_dodh_scene_receipts")
local M = {}

local binding = { task = 920254, zone_id = 362, version = 1 }
local run_marker = "rof2_dodh_longshadow_scene_run"
local end_marker = "rof2_dodh_tail_endpoint"
local informant_type = 362940
local endpoint = {885.37, 601.23, -42.066}
local stops = {
    {point={-858.705,-1514.819,183.859}, grounds={
        {-846.705,-1514.819,179.297}, {-876.705,-1514.819,190.799}}},
    {point={-562.796,-1385.397,-3.521}, grounds={
        {-574.796,-1385.397,-9.950}, {-562.796,-1373.397,-8.175}, {-574.796,-1397.397,-3.749}}},
    {point={-475,-965,-12.043}, grounds={
        {-463,-965,-14.857}, {-487,-965,-10.700}, {-475,-953,-13.100}}},
    {point={-473,-438,-11.533}, grounds={
        {-461,-438,-11.676}, {-485,-438,-11.002}, {-473,-426,-12.482}, {-473,-450,-10.511}}},
    {point={-177,-191,0.972}, grounds={
        {-165,-191,2.814}, {-189,-191,2.401}, {-177,-179,1.318}, {-177,-203,4.270}}},
    {point={48,7,4.566}, grounds={
        {60,7,2.156}, {36,7,2.847}, {48,19,1.677}, {48,-5,3.357}}},
    {point={193,318,4.793}, grounds={
        {205,318,4.741}, {181,318,4.875}, {193,330,5.869}, {193,306,5.917}}},
}
local minimum_wave_sizes = {2, 3, 2, 4, 3, 3, 4}

local tuning_sql = [[
SELECT near_radius, far_radius, lost_seconds, spotted_seconds FROM dodh_longshadow_tail_tuning WHERE id=1
]]
local wave_sql = [[
SELECT GROUP_CONCAT(w.npc_type_id ORDER BY w.ordinal SEPARATOR ','), COUNT(*)
FROM dodh_longshadow_tail_wave_types w JOIN npc_types n ON n.id=w.npc_type_id WHERE w.stop=?
]]
local informant_sql = [[
SELECT 1 FROM npc_types WHERE id=362940 AND level=72 AND race=461
]]
local informant_death_sql = [[
SELECT 1 FROM dodh_longshadow_travel_events
WHERE shared_task_id=CAST(? AS UNSIGNED) AND task_id=920254 AND activity_id=2 AND instance_id=? LIMIT 1
]]

local stage, arrived_at

local function members(scope, activity)
    local list = {}
    for client in eq.get_entity_list():GetClientList().entries do
        if client.valid and client:GetHP() > 0 and client:IsTaskActivityActive(binding.task, activity)
            and (not scope or scope_api.member(scope, client)) then
            list[#list+1] = client
        end
    end
    return list
end

local function distance_squared(actor, x, y, z)
    local dx, dy, dz = actor:GetX()-x, actor:GetY()-y, actor:GetZ()-z
    return dx*dx + dy*dy + dz*dz
end

local function configuration()
    local cfg = receipts.read_one(tuning_sql, {})
    if not cfg or not receipts.read_one(informant_sql, {}) then return nil end
    local near, far, lost = tonumber(cfg[1]), tonumber(cfg[2]), tonumber(cfg[3])
    local spotted = tonumber(cfg[4])
    if not near or not far or not lost or not spotted or near <= 0 or far <= near
        or lost <= 0 or spotted <= 0 then return nil end
    local types = {}
    for index, stop in ipairs(stops) do
        local row = receipts.read_one(wave_sql, {index})
        if not row or not row[1] then return nil end
        local wave = {}
        for id in tostring(row[1]):gmatch("%d+") do wave[#wave+1] = tonumber(id) end
        if #wave < minimum_wave_sizes[index] or #wave > #stop.grounds or #wave ~= tonumber(row[2]) then
            return nil
        end
        types[index] = wave
    end
    return { near = near*near, far = far*far, lost = lost, spotted = spotted, types = types }
end

local function issue_navigation(elder, state)
    local stop = stops[state.index]
    local point = stop and stop.point or endpoint
    elder:NavigateTo(point[1], point[2], point[3])
end

local function deactivate(elder, state, client)
    state.failed = true
    elder:StopNavigation()
    elder:Emote("breaks off her journey.")
    for _, key in ipairs(state.ambush or {}) do
        local actor = scope_api.actor(state.scope, key)
        if actor then actor:Depop() end
    end
    client:FailTask(binding.task)
end

local function spawn_wave(state, target)
    state.ambush = {}
    for index, npc_type in ipairs(state.cfg.types[state.index]) do
        local point = stops[state.index].grounds[index]
        local mob = eq.spawn2(npc_type, 0, 0, point[1], point[2], point[3], 0)
        local npc = mob and mob.valid and mob:IsNPC() and mob:CastToNPC()
        local key = npc and scope_api.register(state.scope, npc, "ambusher")
        if not key then return false end
        npc:SetEntityVariable(run_marker, state.scope.occurrence)
        npc:AddToHateList(target, 1)
        state.ambush[#state.ambush+1] = key
    end
    return true
end

local function materialize_informant(elder, client)
    local scope = scope_api.bind(binding, client)
    if not scope or not receipts.mapping(scope, client) then return end
    local prior = receipts.read_one(informant_death_sql, {scope.occurrence, scope.instance})
    if prior ~= false then return end
    for npc in eq.get_entity_list():GetNPCList().entries do
        if npc.valid and npc:GetNPCTypeID() == informant_type then return end
    end
    local mob = eq.spawn2(informant_type, 0, 0, endpoint[1], endpoint[2], endpoint[3], 0)
    if not mob or not mob.valid or not mob:IsNPC() then return end
    local informant = mob:CastToNPC()
    if not scope_api.register(scope, informant, "informant") then
        informant:Depop()
        return
    end
    informant:SetEntityVariable(run_marker, scope.occurrence)
    informant:Emote("turns on the intruders.")
    informant:AddToHateList(client, 1)
    elder:Depop()
end

function M.tick(elder)
    local ready = members(nil, 2)
    if ready[1] then
        materialize_informant(elder, ready[1])
        return
    end
    if not stage then
        local active = members(nil, 1)
        local lead = active[1]
        local scope = lead and scope_api.bind(binding, lead)
        if not scope or not receipts.mapping(scope, lead) then return end
        arrived_at = arrived_at or os.time()
        if os.time() < arrived_at + 180 then return end
        local cfg = configuration()
        if not cfg then return end
        stage = { scope = scope, cfg = cfg, index = 1, near_since = {} }
        elder:SetInvul(true)
        -- The idle AI otherwise replaces the escort route with a return to spawn.
        elder:SaveGuardSpot(true)
        elder:Emote("begins to move.")
        issue_navigation(elder, stage)
    end
    if stage.failed or stage.endpoint then return end
    local active = members(stage.scope, 1)
    if not active[1] then return end
    local follower
    local now = os.time()
    local near_since = {}
    for _, member in ipairs(active) do
        local distance = distance_squared(member, elder:GetX(), elder:GetY(), elder:GetZ())
        if distance < stage.cfg.near then
            local character = member:CharacterID()
            local previous = stage.near_since[character]
            near_since[character] = previous or now
            if not previous then
                member:Message(15, "You are getting too close to Longshadow.")
            elseif now - previous >= stage.cfg.spotted then
                deactivate(elder, stage, member)
                return
            end
        elseif distance <= stage.cfg.far then
            follower = member
        end
    end
    stage.near_since = near_since
    if not follower then
        if not stage.lost_at then
            stage.lost_at = now
            for _, member in ipairs(active) do member:Message(15, "You are losing Longshadow's trail.") end
        elseif now - stage.lost_at >= stage.cfg.lost then
            deactivate(elder, stage, active[1])
        end
        return
    end
    stage.lost_at = nil
    if stage.ambush then
        for _, key in ipairs(stage.ambush) do
            if not stage.scope.actors[key].dead then
                if not scope_api.actor(stage.scope, key) then deactivate(elder, stage, follower) end
                return
            end
        end
        stage.ambush = nil
        stage.index = stage.index + 1
        issue_navigation(elder, stage)
        return
    end
    local stop = stops[stage.index]
    local point = stop and stop.point or endpoint
    if distance_squared(elder, point[1], point[2], point[3]) > 100 then return end
    elder:StopNavigation()
    if stop then
        if not spawn_wave(stage, follower) then deactivate(elder, stage, follower) end
    else
        stage.endpoint = true
        elder:SetEntityVariable(end_marker, stage.scope.occurrence)
    end
end

function M.death(event)
    if not stage or not stage.ambush or stage.failed then return end
    local source = event.other
    if source and source.valid and not source:IsClient() then source = source:GetUltimateOwner() end
    if not source or not source.valid or not source:IsClient()
        or not scope_api.member(stage.scope, source:CastToClient()) then return end
    scope_api.death(stage.scope, event)
end

return M
