local progression = require("rof2_dodh_raid_progress")
local runtime = require("rof2_dodh_raid_runtime")
local bindings = require("rof2_dodh_raid_npc_bindings")
local read_one = require("rof2_dodh_scene_receipts").read_one
local M = {}
local name = "Blood Raid: The Council of Nine"
local zone_id, version = 349, 1
local avatar_type, avatar_spawn = 349030, 261360
local council_type, first_spawn, count = 349031, 261361, 9
local conquered = "Darkhollow blood victory: council"
local timer = "dodh_council_cast"
local warband

local function expedition(client)
    return progression.same_instance(client, name, zone_id, version)
end

local function owner(mob)
    if not mob or not mob.valid then return nil end
    if mob:IsClient() then return mob:CastToClient() end
    local master = mob:GetOwner()
    return master and master.valid and master:IsClient() and master:CastToClient()
end

local function avatar(npc)
    return npc and npc.valid and npc:GetNPCTypeID() == avatar_type and npc:GetSpawnPointID() == avatar_spawn
end

local function council_slot(npc)
    if not npc or not npc.valid or npc:GetNPCTypeID() ~= council_type then return nil end
    local slot = npc:GetSpawnPointID() - first_spawn + 1
    if slot >= 1 and slot <= count then return slot end
end

local function activate(npc, attacker, dz)
    local found = {}
    for slot = 1, count do
        local actor = runtime.placed({npc = council_type, spawn = first_spawn + slot - 1}, dz)
        if council_slot(actor) ~= slot then return false end
        found[slot] = actor:GetID()
    end
    warband = {id = npc:GetID(), dz = dz, uuid = dz:GetUUID(), ids = found, active = 0,
               deaths = {}, dead_count = 0, terminal = false}
    npc:ModifyNPCStat("max_hit", "5000")
    npc:SetSpecialAbility(3, 1)
    npc:SetSpecialAbility(5, 1)
    npc:Shout("The Council watches through its Avatar.")
    return true
end

function M.spawn_member(e)
    local npc = e.self
    if council_slot(npc) then
        -- Keep the installed Council passive until each owned health threshold.
        npc:SetSpecialAbility(24, 1)
        npc:SetSpecialAbility(25, 1)
        npc:SetSpecialAbility(35, 1)
    end
end

function M.avatar_damage(e)
    local npc, attacker = e.self, owner(e.other)
    if not avatar(npc) then return -1 end
    local dz = expedition(attacker)
    if not dz or dz:HasLockout(conquered) then return -1 end
    if not warband and not activate(npc, attacker, dz) then return -1 end
    if warband.id ~= npc:GetID() or warband.uuid ~= dz:GetUUID() then return -1 end
    if e.damage <= 0 or warband.terminal then return 0 end
    local health = npc:GetHP()
    local proposed_health = health - e.damage
    local ratio = 100 * proposed_health / npc:GetMaxHP()
    while warband.active < count and ratio <= 90 - 10 * warband.active do
        local slot = warband.active + 1
        local actor = eq.get_entity_list():GetNPCByID(warband.ids[slot])
        if council_slot(actor) ~= slot then return -1 end
        warband.active = slot
        actor:SetSpecialAbility(24, 0)
        actor:SetSpecialAbility(25, 0)
        actor:SetSpecialAbility(35, 0)
        actor:AddToHateList(attacker, 1, 0)
        npc:Shout(string.format("Council member %d joins the fight.", slot))
    end
    if proposed_health <= 0 then
        if warband.dead_count < count then return health > 1 and health - 1 or -1 end
        warband.terminal = true
    end
    return 0
end

function M.member_damage(e)
    local slot = council_slot(e.self)
    local dz = expedition(owner(e.other))
    if not dz or not slot or not warband or warband.uuid ~= dz:GetUUID()
        or warband.ids[slot] ~= e.self:GetID() or slot > warband.active or warband.deaths[slot] then
        return -1
    end
    return 0
end

function M.combat(e)
    if not council_slot(e.self) then return end
    if e.joined then eq.set_timer(timer, 33000, e.self) else eq.stop_timer(timer, e.self) end
end

function M.tick(e)
    local slot = council_slot(e.self)
    if e.timer ~= timer or not slot or not warband or slot > warband.active
        or warband.ids[slot] ~= e.self:GetID() or warband.deaths[slot] then return end
    local target = e.self:GetTarget()
    if target and target.valid then e.self:CastSpell(7324, target:GetID()) end
end

function M.avatar_combat(e)
    if e.joined or not warband or warband.terminal or not avatar(e.self)
        or warband.id ~= e.self:GetID() or not runtime.in_instance(warband.dz) then return end
    -- Retire the incomplete occurrence generations, and let the exact installed
    -- spawn points reconstitute the board for a fresh attempt.
    for slot = 1, count do
        local spid = first_spawn + slot - 1
        local mob = runtime.placed({npc = council_type, spawn = spid}, warband.dz)
        if council_slot(mob) == slot then mob:Depop(false) end
        local spawn = eq.get_entity_list():GetSpawnByID(spid)
        if spawn.valid then
            spawn:Enable()
            spawn:Repop(1)
        end
    end
    warband = nil
    e.self:SetHP(e.self:GetMaxHP())
end

function M.death(e)
    local dz = expedition(owner(e.other))
    if not dz or not warband or dz:GetUUID() ~= warband.uuid then return end
    local npc = e.killed
    local slot = council_slot(npc)
    if slot and e.killed_entity_id == warband.ids[slot] and slot <= warband.active and not warband.deaths[slot] then
        eq.disable_spawn2(npc:GetSpawnPointID())
        warband.deaths[slot] = true
        warband.dead_count = warband.dead_count + 1
        local active_avatar = runtime.placed({npc = avatar_type, spawn = avatar_spawn}, dz)
        if avatar(active_avatar) and active_avatar:GetID() == warband.id then
            active_avatar:ModifyNPCStat("max_hit", tostring(5000 - warband.dead_count * 275))
        end
    elseif avatar(npc) and e.killed_entity_id == warband.id and warband.terminal
        and warband.dead_count == count then
        if not e.corpse or not e.corpse.valid or not e.corpse:IsNPCCorpse()
            or e.corpse:GetID() ~= e.killed_entity_id then return end
        eq.disable_spawn2(avatar_spawn)
        if progression.commit_blood(dz, "council", zone_id, version) then
            -- Two glowing runes and two distinct draws from the eight confirmed items.
            -- Equal weight is provisional. The documented Bazu chance is unresolved.
            local gear = {83502, 83503, 83504, 83505, 83506, 83507, 83508, 83509}
            e.corpse:AddItem(77937, 1)
            e.corpse:AddItem(77937, 1)
            for _ = 1, 2 do
                e.corpse:AddItem(table.remove(gear, math.random(#gear)), 1)
            end
            local rates = bindings.BLOOD_BAZU_CHANCE
            if rates and rates.council and math.random() < rates.council then e.corpse:AddItem(33316, 1) end
        end
        warband = nil
    end
end

local requested_chain = [[
SELECT COUNT(DISTINCT t.task_id)
FROM completed_shared_tasks t
JOIN completed_shared_task_members m ON m.shared_task_id=t.id
WHERE m.character_id=? AND t.completion_time IS NOT NULL
  AND t.task_id IN (920241,920242,920243,920244,920245)
]]
local config = {
    expedition = {name = name, min_players = 18, max_players = 42},
    instance = {zone = "illsalinb", version = version, duration = 21600},
    zonein = {x = 1, y = 2, z = -21, h = 128},
    safereturn = {zone = "eastkorlach", x = 748, y = -980, z = 83.5, h = 157},
}

function M.request(e)
    local client = e.other
    local zone = eq.get_zone()
    if zone:GetZoneID() ~= 362 or zone:GetInstanceVersion() ~= 0 or zone:GetInstanceID() ~= 0
        or e.self:GetNPCTypeID() ~= 362108 or e.self:GetSpawnPointID() ~= 102606 then return end
    if e.message:lower() == "hail" then
        e.self:Say("Ask about the " .. eq.say_link("Council of Nine") .. " when your raid is assembled.")
        return
    end
    if e.message:lower() ~= "council of nine" then return end
    local current = client:GetExpedition()
    if current.valid then
        if current:GetName() == name and current:GetZoneID() == zone_id and current:GetZoneVersion() == version then
            client:MovePCDynamicZone("illsalinb", version, false)
        end
        return
    end
    local raid = client:GetRaid()
    if not raid.valid or not raid:IsLeader(client) then return end
    local complete = read_one(requested_chain, {client:CharacterID()})
    if not complete or tonumber(complete[1]) ~= 5 then
        e.self:Say("Fulfill Jarzarrad's prophecy before asking me to admit your raid.")
        return
    end
    -- Creation is native. Physical re-entry stays version-checked against the actual
    -- expedition. The request/entry actor is a local fallback pending the old entry fixture.
    client:CreateExpedition(config)
end

function M.enter(e)
    local dz = expedition(e.self)
    if not dz then return end
    progression.sync_aa(e.self)
    local rank = progression.rank(e.self)
    if rank > 0 and not progression.blood_immune(e.self) then
        e.self:SpellFinished(7804 + rank, e.self)
    end
    if dz:HasLockout(conquered) then
        for spid = avatar_spawn, first_spawn + count - 1 do
            eq.disable_spawn2(spid)
            local expected_type = spid == avatar_spawn and avatar_type or council_type
            local mob = runtime.placed({npc = expected_type, spawn = spid}, dz)
            if mob then mob:Depop(false) end
        end
    end
end

return M
