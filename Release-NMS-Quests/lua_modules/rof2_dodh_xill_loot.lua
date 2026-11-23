local scope_api = require("rof2_dodh_scene_scope")
local drops = require("rof2_dodh_xill_loot_data")
local M = {}

local bindings = {
    [920236] = {task = 920236, zone_id = 358, version = 1},
    [920238] = {task = 920238, zone_id = 358, version = 2},
}
local checked_run
local drop_by_spawn
local added
local modulus = 2147483647

local function run_seed(occurrence, item)
    local seed = item
    for i = 1, #occurrence do seed = (seed * 131 + occurrence:byte(i)) % modulus end
    return seed
end

local function choose_drops(task, scope)
    local key = scope.occurrence .. ":" .. scope.instance
    if checked_run == key then return end
    checked_run, drop_by_spawn, added = key, {}, {}
    for _, group in ipairs(drops[task]) do
        local seed = run_seed(scope.occurrence, group.item)
        local eligible = {}
        for spawn, npc in pairs(group.placements) do
            local score = (seed + spawn * 104729) % modulus
            score = (score * 48271) % modulus
            score = (score * 48271) % modulus
            eligible[#eligible + 1] = {spawn = spawn, npc = npc, score = score}
        end
        table.sort(eligible, function(a, b)
            return a.score < b.score or (a.score == b.score and a.spawn < b.spawn)
        end)
        for i = 1, group.drops do
            local actor = eligible[i]
            drop_by_spawn[actor.spawn] = {npc = actor.npc, item = group.item}
        end
    end
end

function M.death(event, task)
    local source, npc, corpse = event.other, event.killed, event.corpse
    if not source or not source.valid or not source:IsClient()
        or not npc or not npc.valid or not corpse or not corpse.valid or not corpse:IsNPCCorpse()
        or corpse:GetID() ~= event.killed_entity_id then
        return
    end
    local client = source:CastToClient()
    local scope = scope_api.bind(bindings[task], client)
    if not scope then return end

    choose_drops(task, scope)
    local spawn = npc:GetSpawnPointID()
    local drop = drop_by_spawn[spawn]
    if not drop or drop.npc ~= npc:GetNPCTypeID() or added[spawn] then return end
    if corpse:CountItem(drop.item) == 0 then
        corpse:AddItem(drop.item, 1)
        if corpse:CountItem(drop.item) == 1 then corpse:ResetDecayTimer() end
    end
    added[spawn] = corpse:CountItem(drop.item) == 1
end

return M
