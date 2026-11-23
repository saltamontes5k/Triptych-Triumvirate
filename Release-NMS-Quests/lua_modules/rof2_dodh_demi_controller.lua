local admission = require("rof2_dodh_demi_admission")
local progress = require("rof2_dodh_raid_progress")
local runtime = require("rof2_dodh_raid_runtime")
local loot = require("rof2_dodh_demi_chest")
local rewards = require("rof2_dodh_demi_rewards")
local layout = require("rof2_dodh_demi_layout")
local bindings = require("rof2_dodh_raid_npc_bindings")
local spirits = require("rof2_dodh_demi_spirits")
local hooks = {}
local M = { hooks = hooks, layout = layout, bindings = bindings }
local spec = {name = "Dreadspire Keep: Demi-Plane of Blood", zone = 351, version = 1}
local events = {}
local serial = 0

function M.add(state, id, role, where, target)
    local npc = runtime.spawn_owned(id, where, state.mark)
    if not npc then return nil end
    state.actors[npc:GetID()] = {id = npc:GetID(), kind = id, role = role, npc = npc}
    if target and target.valid then npc:AddToHateList(target, 1, 0) end
    return npc
end

function M.actor(state, role)
    for _, actor in pairs(state.actors) do
        if actor.role == role then
            local npc
            if actor.placed then
                npc = runtime.placed(actor.placed, state.dz)
            else
                npc = runtime.owned(state.mark, actor.id, actor.kind)
            end
            if npc and npc:GetID() == actor.id then return npc end
        end
    end
end

function M.remove(state, role)
    for id, actor in pairs(state.actors) do
        if not role or actor.role == role then
            local npc = not actor.placed and runtime.owned(state.mark, id, actor.kind)
            if npc then npc:Depop(false) end
            state.actors[id] = nil
        end
    end
end

function M.claim(state, npc, definition, role)
    if not runtime.actor(npc, definition) then return false end
    state.actors[npc:GetID()] = {id = npc:GetID(), kind = definition.npc, role = role, placed = definition}
    return true
end

function M.begin(key, dz)
    local selection = rewards[key]
    if not dz or not dz.valid or dz:HasLockout("Demi-Plane: " .. key) then return nil end
    if selection.tier >= 2 and not progress.has_tier(dz, 1) then return nil end
    if selection.tier == 3 and not admission.mayong_open(dz) then return nil end
    local state = events[key]
    if state and state.uuid == dz:GetUUID() then return state end
    serial = serial + 1
    state = {key = key, dz = dz, uuid = dz:GetUUID(), mark = dz:GetUUID() .. ":" .. key .. ":" .. serial,
             actors = {}, ticks = {}, recorded = {}, last = os.time()}
    events[key] = state
    return state
end

function M.members(state, around, range)
    local active = {}
    for client in eq.get_entity_list():GetClientList().entries do
        local dz = admission.expedition(client)
        if dz and dz:GetUUID() == state.uuid and client:GetHP() > 0
            and (not around or around:CalculateDistance(client) <= range) then active[#active + 1] = client end
    end
    return active
end

function M.cast(state, key, now, delay, actor, spell, target)
    state.ticks[key] = state.ticks[key] or now + delay
    if now >= state.ticks[key] and target and target.valid then
        state.ticks[key] = now + delay
        actor:CastSpell(spell, target:GetID())
    end
end

function M.fail(state)
    if hooks[state.key].reset then hooks[state.key].reset(state) end
    M.remove(state)
    events[state.key] = nil
end

function M.finish(state, point, corpse)
    local staged = loot.prepare(state.dz, state.key, point)
    if not staged then return false end
    if not loot.finish(staged) then loot.cancel(staged); return false end
    loot.blocker(state.key, corpse)
    M.remove(state)
    events[state.key] = nil
    return true
end

function M.victory(state, point, guide, second_guide)
    if not M.finish(state, point) then return false end
    local dz, event = state.dz, state.key
    local spirit = layout[event].spirit or {point[1] + 8, point[2], point[3], point[4]}
    spirits.spawn(dz, event, bindings[guide], spirit)
    if second_guide then
        spirits.spawn(dz, "adrianna", bindings[second_guide], {point[1] - 8, point[2], point[3], point[4]})
    end
    return true
end

local function owned_event(npc, entity_id)
    for key, state in pairs(events) do
        local actor = state.actors[entity_id]
        if actor and npc.valid and npc:GetNPCTypeID() == actor.kind
            and (actor.placed and runtime.actor(npc, actor.placed)
                or not actor.placed and npc:GetEntityVariable("dodh_raid:occurrence") == state.mark) then
            return state, hooks[key], actor
        end
    end
end

function M.damage(e)
    if not runtime.in_scope(spec) then return 0 end
    local local_state, scene, actor = owned_event(e.self, e.self:GetID())
    local client = runtime.owner(e.other)
    local dz = admission.expedition(client)
    if not local_state then
        local hatchet = hooks.hatchet
        if runtime.actor(e.self, layout.hatchet.boss) then
            if not dz or not hatchet.open(e.self, dz) then return -1 end
            local_state, scene, actor = owned_event(e.self, e.self:GetID())
        else
            return 0
        end
    end
    if actor.role == "performer" then
        if e.other and e.other.valid and e.other:IsNPC() and local_state.actors[e.other:GetID()]
            and local_state.actors[e.other:GetID()].role == "performer_add"
            and e.other:GetEntityVariable("dodh_raid:occurrence") == local_state.mark then return 0 end
        return -1
    end
    if actor.role == "offer" or not dz or dz:GetUUID() ~= local_state.uuid then return -1 end
    local_state.last = os.time()
    if scene.damage then return scene.damage(local_state, actor.role, e, client) end
    return 0
end

function M.say(e)
    if spirits.say(e) then return end
    local dz = admission.expedition(e.other)
    if not dz then return end
    local state, scene, actor = owned_event(e.self, e.self:GetID())
    if not state or state.uuid ~= dz:GetUUID() then return end
    if actor.role == "offer" then
        if scene.offer then
            scene.offer(e, state)
        elseif scene.hail and e.message:lower() == "hail" then
            scene.hail(e, state)
        end
    elseif scene.say then
        scene.say(state, actor.role, e)
    end
end

function M.death(e)
    loot.opened(e)
    local state, hook, actor = owned_event(e.killed, e.killed_entity_id)
    local client = runtime.owner(e.other)
    local dz = admission.expedition(client)
    if state then
        local was_living_performer = actor.role == "performer"
        if not was_living_performer and (not dz or dz:GetUUID() ~= state.uuid) then return end
        state.actors[e.killed_entity_id] = nil
        if hook.death then hook.death(state, actor.role, e, client) end
    elseif dz then
        for key, scene in pairs(hooks) do
            if scene.trash then scene.trash(e, dz, client, key) end
        end
    end
end

function M.tick()
    local expedition = M.expedition
    if expedition and expedition.valid then
        for _, hook in pairs(hooks) do if hook.present then hook.present(expedition) end end
    end
    local now = os.time()
    for _, state in pairs(events) do
        if not state.dz.valid then
            M.fail(state)
        elseif #M.members(state) == 0 then
            state.empty = state.empty or now
            if now >= state.empty + 45 then M.fail(state) end
        else
            state.empty = nil
            if hooks[state.key].tick and hooks[state.key].tick(state, now) == false then M.fail(state) end
        end
    end
end

function M.enter(client)
    local dz = admission.expedition(client)
    if dz then
        M.expedition = dz
        progress.sync_aa(client)
        hooks.mayong.present(dz)
    end
end

function M.door(e)
    local state = events.hatchet
    if state and hooks.hatchet.door then return hooks.hatchet.door(state, e) end
    return 0
end

function M.position(npc, x, y)
    return runtime.pose(npc, x, y)
end

function M.final_hit(npc, damage, allowed)
    if not allowed and damage >= npc:GetHP() then return npc:GetHP() > 1 and npc:GetHP() - 1 or -1 end
    return 0
end

return M
