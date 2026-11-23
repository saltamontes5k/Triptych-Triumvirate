local scope_api = require("rof2_dodh_scene_scope")
local M = {}

local bindings = {
    [920237] = { task = 920237, zone_id = 358, version = 3, npc = 358900,
        point = {-413, -1131, 102.32}, kill = 3, item = 85030,
        phases = {{80, 2050}, {60, 1750}, {40, 1500}, {20, 1200}}, flurry = 1 },
    [920238] = { task = 920238, zone_id = 358, version = 2, npc = 358901,
        point = {21, -1000, 70.22}, kill = 7, item = 85034,
        phases = {{80, 1450}, {60, 1850}, {40, 2250}, {20, 2750}, {10, 3500}}, flurry_at = 10 },
}

local timer = "dodh_xill_boss"
local run

local function client_of(source)
    if not source or not source.valid then return nil end
    if source:IsClient() then return source:CastToClient() end
    local owner = source:GetOwner()
    return owner and owner.valid and owner:IsClient() and owner:CastToClient()
end

function M.watch(client, task)
    if client:IsTaskActive(task) then eq.set_timer(timer, 1000, client) end
end

function M.tick(event, task)
    if event.timer ~= timer then return end
    local client, binding = event.self, bindings[task]
    if not client:IsTaskActive(task) then
        eq.stop_timer(timer, client)
        return
    end
    if not client:IsTaskActivityActive(task, binding.kill) then return end
    local scope = scope_api.bind(binding, client)
    if not scope then return end
    if run and run.scope.occurrence == scope.occurrence and run.scope.instance == scope.instance then
        return
    end

    local p = binding.point
    local mob = eq.spawn2(binding.npc, 0, 0, p[1], p[2], p[3] + 3, 0)
    if not mob or not mob.valid or not mob:IsNPC() then return end
    local npc = mob:CastToNPC()
    local floor = npc:FindGroundZ(p[1], p[2], 5)
    if floor ~= floor or math.abs(floor - p[3]) > 4 then
        npc:Depop(false)
        return
    end
    local actor = scope_api.register(scope, npc, "xill_boss")
    if not actor then
        npc:Depop(false)
        return
    end
    if binding.flurry then npc:SetSpecialAbility(5, binding.flurry) end
    run = { scope = scope, binding = binding, actor = actor, tier = 1 }
end

function M.damage(event)
    if not run then return 0 end
    local npc = scope_api.actor(run.scope, run.actor)
    if not npc or npc:GetID() ~= event.self:GetID() then return 0 end
    if not scope_api.member(run.scope, client_of(event.other)) then return -1 end
    if event.damage <= 0 then return 0 end

    local percent = (npc:GetHP() - event.damage) * 100 / npc:GetMaxHP()
    local phases = run.binding.phases
    while phases[run.tier] and percent <= phases[run.tier][1] do
        local phase = phases[run.tier]
        npc:ModifyNPCStat("max_hit", tostring(phase[2]))
        if phase[1] == run.binding.flurry_at then npc:SetSpecialAbility(5, 1) end
        run.tier = run.tier + 1
    end
    return 0
end

function M.death(event)
    if not run then return end
    local client, corpse = client_of(event.other), event.corpse
    if not scope_api.member(run.scope, client) or not corpse or not corpse.valid
        or not corpse:IsNPCCorpse() or corpse:GetID() ~= event.killed_entity_id then
        return
    end
    local actor = scope_api.death(run.scope, event)
    if actor ~= run.actor then return end
    if corpse:CountItem(run.binding.item) == 0 then
        corpse:AddItem(run.binding.item, 1)
        corpse:ResetDecayTimer()
    end
end

return M
