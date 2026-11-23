local progress = require("rof2_dodh_raid_progress")
local runtime = require("rof2_dodh_raid_runtime")
local specs = require("rof2_dodh_blood_definitions")
local mechanics = require("rof2_dodh_blood_mechanics")
local bindings = require("rof2_dodh_raid_npc_bindings")
local read_one = require("rof2_dodh_scene_receipts").read_one
local M = {}
local states = {}
local timer = "dodh_blood_raid"
local duration = 21600

local prophecy = [[
SELECT COUNT(DISTINCT t.task_id)
FROM completed_shared_tasks t
JOIN completed_shared_task_members m ON m.shared_task_id=t.id
WHERE m.character_id=? AND t.completion_time IS NOT NULL
  AND t.task_id IN (920241,920242,920243,920244,920245)
]]

local function event_name(key) return "Darkhollow blood victory: " .. key end

local function point(t)
    return {x = t[1], y = t[2], z = t[3], h = t[4]}
end

local function may_request(client, npc, request)
    if request.faction then
        local con = client:GetFactionLevel(client:CharacterID(), npc:GetNPCTypeID(),
            client:GetBaseRace(), client:GetClass(), client:GetDeity(), request.faction, npc)
        if con < Faction.Ally or con > Faction.Indifferent then return false end
    end
    if request.prophecy then
        local row = read_one(prophecy, {client:CharacterID()})
        return row and tonumber(row[1]) == 5
    end
    return true
end

function M.request(e, key)
    local spec = specs[key]
    local npc, client = e.self, e.other
    local request = spec.request
    local zone = eq.get_zone()
    if zone:GetZoneID() ~= request.zone or zone:GetInstanceVersion() ~= 0 or zone:GetInstanceID() ~= 0
        or not runtime.actor(npc, request.actor) then return end
    local phrase = e.message:lower()
    if phrase == "hail" then
        npc:Say("If your raid is ready, ask me about " .. eq.say_link(spec.label) .. ".")
        return
    end
    if phrase ~= spec.label:lower() then return end
    local active = client:GetExpedition()
    if active.valid then
        if active:GetName() == spec.name and active:GetZoneID() == spec.zone
            and active:GetZoneVersion() == spec.version then
            client:MovePCDynamicZone(spec.short, spec.version, false)
        end
        return
    end
    local raid = client:GetRaid()
    if not raid.valid or not raid:IsLeader(client) or not may_request(client, npc, request) then return end
    if mechanics[key].ready and not mechanics[key].ready() then
        npc:Say("The passage is sealed.")
        return
    end
    local return_point = point(runtime.pose(npc, 8, 0))
    return_point.zone = request.short
    client:CreateExpedition({
        expedition = {name = spec.name, min_players = 18, max_players = 54},
        instance = {zone = spec.short, version = spec.version, duration = duration},
        zonein = point(spec.entry),
        safereturn = return_point,
    })
end

function M.enter(e, key)
    local spec = specs[key]
    local dz = runtime.scope(e.self, spec)
    if not dz then return end
    if dz:HasLockout(event_name(key)) then runtime.disable(spec.boss, dz) end
    progress.sync_aa(e.self)
    local rank = progress.rank(e.self)
    if rank > 0 and not progress.blood_immune(e.self) then
        e.self:SpellFinished(spec.curse + rank - 1, e.self)
    end
end

function M.spawn(e, key)
    local spec = specs[key]
    if not runtime.in_scope(spec) then return end
    if runtime.actor(e.self, spec.presence) then eq.set_timer(timer, 1000, e.self) end
    mechanics[key].spawn(e.self, spec)
end

local function start(key, spec, client, dz, actor)
    local scene = mechanics[key]
    if scene.ready and not scene.ready() then return nil end
    local state = {
        key = key, spec = spec, dz = dz, uuid = dz:GetUUID(),
        mark = dz:GetUUID() .. ":" .. key .. ":" .. tostring(actor:GetID()),
        adds = {}, pending = {}, last = os.time(), given = 0,
    }
    if scene.start(state, actor, client) then
        states[key] = state
        return state
    end
    for id in pairs(state.adds) do
        local add = runtime.owned(state.mark, id)
        if add then add:Depop(false) end
    end
    if scene.reset then scene.reset(state) end
end

function M.damage(e, key)
    local spec, scene = specs[key], mechanics[key]
    if not runtime.in_scope(spec) then return 0 end
    local client = runtime.owner(e.other)
    local dz = runtime.scope(client, spec)
    if not dz or dz:HasLockout(event_name(key)) then return -1 end
    local state = states[key]
    if not state then
        if e.damage <= 0 then return -1 end
        state = start(key, spec, client, dz, e.self)
    end
    if not state or state.uuid ~= dz:GetUUID() then return -1 end
    state.last = os.time()
    return scene.damage(state, e, client)
end

-- Dynamic raid add types are shared visual donors. The zone death receipt
-- authenticates the exact spawned generation, never the donor's type alone.
function M.death(e, key)
    local state = states[key]
    if not state or not runtime.in_scope(state.spec) then return end
    local client = runtime.owner(e.other)
    local dz = runtime.scope(client, state.spec)
    if not dz or dz:GetUUID() ~= state.uuid or dz:HasLockout(event_name(key)) then return end
    local corpse = mechanics[key].death(state, e, client)
    if corpse and corpse.valid and corpse:IsNPCCorpse() and progress.commit_blood(dz, key, state.spec.zone, state.spec.version) then
        local spec = state.spec
        if spec.mixed_runes then
            for _ = 1, 2 do corpse:AddItem(spec.mixed_runes[math.random(#spec.mixed_runes)], 1) end
        else
            for _, rune in ipairs(spec.runes) do corpse:AddItem(rune, 1) end
        end
        runtime.add_gear(corpse, spec.gear, spec.draws)
        local rates = bindings.BLOOD_BAZU_CHANCE
        if key ~= "bloodeye" and rates and rates[key] and math.random() < rates[key] then
            corpse:AddItem(33316, 1)
        end
        corpse:ResetDecayTimer()
        runtime.disable(spec.boss, dz)
        if mechanics[key].finish then mechanics[key].finish(state) end
        states[key] = nil
    end
end

function M.tick(e, key)
    local spec, scene = specs[key], mechanics[key]
    if e.timer ~= timer or not runtime.in_scope(spec) or not runtime.actor(e.self, spec.presence) then return end
    local state = states[key]
    if not state then return end
    local now = os.time()
    local boss = runtime.placed(spec.boss, state.dz)
    if boss and runtime.member_target(state.dz, spec, boss) then
        state.empty_since = nil
    elseif not boss and state.final_corpse and runtime.member_target(state.dz, spec, e.self) then
        state.empty_since = nil
    else
        state.empty_since = state.empty_since or now
    end
    if (state.empty_since and now - state.empty_since >= 45) or not state.dz.valid or scene.tick(state, now) == false then
        for id in pairs(state.adds) do
            local add = runtime.owned(state.mark, id)
            if add then add:Depop(false) end
        end
        states[key] = nil
        scene.reset(state)
    end
end

function M.cast_on(e, key)
    local state = states[key]
    if state and mechanics[key].cast_on then mechanics[key].cast_on(state, e) end
end

return M
