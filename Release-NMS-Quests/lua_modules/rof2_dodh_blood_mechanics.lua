local runtime = require("rof2_dodh_raid_runtime")
local bindings = require("rof2_dodh_raid_npc_bindings")
local M = {}

local function next_cast(state, key, now, seconds, npc, spell, target)
    if not state.pending[key] then state.pending[key] = now + seconds; return end
    if now >= state.pending[key] and target and target.valid then
        state.pending[key] = now + seconds
        npc:CastSpell(spell, target:GetID())
    end
end

local function add(state, symbol, at, role, target)
    local npc = runtime.spawn_owned(bindings[symbol], at, state.mark)
    if not npc then return nil end
    state.adds[npc:GetID()] = {role = role, npc = npc:GetNPCTypeID(), started = os.time()}
    if target and target.valid then npc:AddToHateList(target, 1, 0) end
    return npc
end

local function remove_adds(state, role)
    for id, record in pairs(state.adds) do
        if not role or record.role == role then
            local npc = runtime.owned(state.mark, id, record.npc)
            if npc then npc:Depop(false) end
            state.adds[id] = nil
        end
    end
end

local function take_add(state, e)
    local record = state.adds[e.killed_entity_id]
    if not record or not e.killed.valid or e.killed:GetNPCTypeID() ~= record.npc
        or e.killed:GetEntityVariable("dodh_raid:occurrence") ~= state.mark then return nil end
    state.adds[e.killed_entity_id] = nil
    return record
end

local function final_hit(npc, amount, allowed)
    if amount < npc:GetHP() then return 0 end
    if allowed then return 0 end
    return npc:GetHP() > 1 and npc:GetHP() - 1 or -1
end

local function active_actor(state, npc)
    return runtime.actor(npc, state.spec.boss) and npc:GetID() == state.boss
end

local function death_of_boss(state, e)
    return e.killed_entity_id == state.boss and runtime.actor(e.killed, state.spec.boss)
end

local function start_boss(state, actor)
    if not runtime.actor(actor, state.spec.boss) or actor:GetMaxHP() <= 1 then return false end
    state.boss = actor:GetID()
    return true
end

local Shyra = {}
M.shyra = Shyra

function Shyra.spawn(npc, spec)
    if runtime.actor(npc, spec.boss) then npc:ModifyNPCStat("max_hit", "4000") end
    for _, definition in ipairs(spec.guards) do
        if runtime.actor(npc, definition) then npc:ModifyNPCStat("max_hit", "3000") end
    end
end

function Shyra.start(state)
    local boss = runtime.placed(state.spec.boss, state.dz)
    if not boss or not start_boss(state, boss) then return false end
    state.guards = {}
    for index, definition in ipairs(state.spec.guards) do
        local guard = runtime.placed(definition, state.dz)
        if not guard or guard:GetMaxHP() <= 1 then return false end
        state.guards[index] = {id = guard:GetID()}
    end
    return true
end

function Shyra.damage(state, e)
    if not active_actor(state, e.self) then return 0 end
    return final_hit(e.self, e.damage, state.guards[1].dead and state.guards[2].dead)
end

function Shyra.tick(state, now)
    local boss = runtime.placed(state.spec.boss, state.dz)
    if not boss then return false end
    local engaged = boss:IsEngaged()
    if engaged then
        local target = boss:GetHateTop()
        next_cast(state, "fangs", now, 24, boss, 5690, target)
        next_cast(state, "silence", now, 39, boss, 7725, target)
    end
    for index, guard in ipairs(state.guards) do
        if not guard.dead then
            local npc = runtime.placed(state.spec.guards[index], state.dz)
            if not npc or npc:GetID() ~= guard.id then return false end
            if npc:IsEngaged() then
                engaged = true
                next_cast(state, "guard" .. index, now, 29, npc, index == 1 and 7724 or 7326, npc:GetHateTop())
            end
        end
    end
    return engaged or now - state.last < 45
end

function Shyra.death(state, e)
    for index, guard in ipairs(state.guards) do
        if guard.id == e.killed_entity_id and runtime.actor(e.killed, state.spec.guards[index]) then
            eq.disable_spawn2(state.spec.guards[index].spawn)
            guard.dead = true
            return
        end
    end
    if death_of_boss(state, e) and state.guards[1].dead and state.guards[2].dead then
        return runtime.corpse(e)
    end
end

function Shyra.reset(state)
    runtime.restore(state.spec.boss, state.dz)
    for _, definition in ipairs(state.spec.guards) do runtime.restore(definition, state.dz) end
end

local Bloodeye = {}
M.bloodeye = Bloodeye
function Bloodeye.ready() return bindings.BLOODEYE_COMMANDER ~= nil end

function Bloodeye.spawn(npc, spec)
    if runtime.actor(npc, spec.boss) then npc:ModifyNPCStat("max_hit", "4500") end
end

function Bloodeye.start(state, actor)
    if not start_boss(state, actor) then return false end
    state.summon_at = os.time() + 8
    state.commanders = 0
    return true
end

function Bloodeye.damage(state, e)
    if not active_actor(state, e.self) then return -1 end
    return final_hit(e.self, e.damage, state.commanders == 2)
end

function Bloodeye.tick(state, now)
    local boss = runtime.placed(state.spec.boss, state.dz)
    if not boss or not active_actor(state, boss) then return false end
    local home = state.spec.anchor
    if (boss:GetX() - home[1]) ^ 2 + (boss:GetY() - home[2]) ^ 2 > 135 ^ 2 then return false end
    local target = runtime.member_target(state.dz, state.spec, boss)
    if now >= state.summon_at and not state.summoned and target then
        for _, offset in ipairs({-16, 16}) do
            if not add(state, "BLOODEYE_COMMANDER", {home[1], home[2] + offset, home[3], home[4]}, "commander", target) then
                return false
            end
        end
        state.summoned = true
    end
    if boss:IsEngaged() then
        next_cast(state, "bellow", now, 37, boss, 7728, boss:GetHateTop())
        next_cast(state, "curse", now, 52, boss, 7726, boss:GetHateTop())
    end
    return true
end

function Bloodeye.death(state, e)
    if death_of_boss(state, e) and state.commanders == 2 then return runtime.corpse(e) end
    local entry = take_add(state, e)
    if entry and entry.role == "commander" then
        state.commanders = state.commanders + 1
        state.last = os.time()
    end
end

function Bloodeye.reset(state) runtime.restore(state.spec.boss, state.dz) end

local Draygun = {}
M.draygun = Draygun
local inverse = "dodh_draygun:inverse"
local living_image = "dodh_draygun:living_image"
local living_thresholds = {85, 60, 35}

function Draygun.ready()
    return bindings.DRAYGUN_LOST_SOUL ~= nil and bindings.DRAYGUN_LIVING_EMPEROR ~= nil
end

function Draygun.spawn(npc, spec)
    if runtime.actor(npc, spec.boss) then npc:ModifyNPCStat("max_hit", "5500") end
end

function Draygun.start(state, actor)
    if not runtime.placed(state.spec.book, state.dz) or not start_boss(state, actor) then return false end
    state.threshold = 1
    state.souls_at = os.time() + 150
    state.damage = 5500
    return true
end

function Draygun.damage(state, e)
    local boss = e.self
    if not active_actor(state, boss) then return -1 end
    if e.damage <= 0 then return 0 end
    if state.living_until then
        boss:SetHP(math.min(boss:GetMaxHP(), boss:GetHP() + e.damage))
        return -1
    end
    local threshold = living_thresholds[state.threshold]
    if threshold then
        local floor = math.ceil(boss:GetMaxHP() * threshold / 100)
        if boss:GetHP() - e.damage <= floor then
            state.threshold = state.threshold + 1
            local echo = add(state, "DRAYGUN_LIVING_EMPEROR", runtime.pose(boss, 10, 0), "living")
            if not echo then
                state.failed = true
                return -1
            end
            runtime.protect(echo, true)
            state.living_until = os.time() + 24
            echo:SetEntityVariable(inverse, state.uuid)
            boss:SetEntityVariable(living_image, tostring(echo:GetID()))
            boss:SetEntityVariable(inverse, state.uuid)
            echo:Say("Hold your attacks! Heal the undead Emperor while I am here.")
            local dealt = boss:GetHP() - floor
            return dealt > 0 and dealt or -1
        end
    end
    return 0
end

function Draygun.tick(state, now)
    local boss, book = runtime.placed(state.spec.boss, state.dz), runtime.placed(state.spec.book, state.dz)
    if state.failed or not boss or not book or not active_actor(state, boss) then return false end
    if state.living_until and now >= state.living_until then
        boss:DeleteEntityVariable(inverse)
        boss:DeleteEntityVariable(living_image)
        remove_adds(state, "living")
        state.living_until = nil
    end
    local target = runtime.member_target(state.dz, state.spec, boss)
    if target and now >= state.souls_at then
        state.souls_at = now + 150
        for n = -2, 2 do
            local soul = add(state, "DRAYGUN_LOST_SOUL", runtime.pose(book, n * 5, 8), "soul", target)
            if not soul then return false end
            soul:ModifyNPCStat("max_hit", "1700")
        end
    end
    for id, record in pairs(state.adds) do
        if record.role == "soul" and now >= record.started + 50 then
            local soul = runtime.owned(state.mark, id, record.npc)
            if not soul then return false end
            soul:Depop(false)
            state.adds[id] = nil
            state.damage = state.damage + 250
            boss:ModifyNPCStat("max_hit", tostring(state.damage))
            boss:SetHP(math.min(boss:GetMaxHP(), boss:GetHP() + math.floor(boss:GetMaxHP() * 0.04)))
        end
    end
    if boss:IsEngaged() and not state.living_until then
        next_cast(state, "lich", now, 40, boss, 7462, boss:GetHateTop())
        next_cast(state, "touch", now, 25, boss, 7463, boss:GetHateTop())
    end
    return true
end

function Draygun.death(state, e)
    if death_of_boss(state, e) and state.threshold == 4 and not state.living_until then return runtime.corpse(e) end
    take_add(state, e)
end

function Draygun.finish(state) remove_adds(state) end
function Draygun.reset(state) runtime.restore(state.spec.boss, state.dz) end

local Sendaii = {}
M.sendaii = Sendaii
local drones = {"SENDAII_WARDED_DRONE", "SENDAII_VENOMOUS_DRONE", "SENDAII_ENCHANTED_DRONE"}
local royal = {"SENDAII_DEVOTED_ACOLYTE", "SENDAII_HANDMAIDEN", "SENDAII_DRACHNID_ADEPT",
               "SENDAII_ROYAL_DEFENDER", "SENDAII_ROYAL_GUARDIAN"}
local ancients = {"SENDAII_RISEN_ANCIENT", "SENDAII_VENGEFUL_ANCIENT", "SENDAII_ENRAGED_ANCIENT"}

local function bound(symbols)
    for _, symbol in ipairs(symbols) do
        if not bindings[symbol] then return false end
    end
    return true
end

function Sendaii.ready() return bound(drones) and bound(royal) and bound(ancients) end

function Sendaii.spawn(npc, spec)
    if runtime.actor(npc, spec.boss) then
        npc:ModifyNPCStat("max_hit", "5000")
        runtime.protect(npc, true)
    end
end

function Sendaii.start(state, actor)
    if not runtime.actor(actor, state.spec.egg) then return false end
    local boss = runtime.placed(state.spec.boss, state.dz)
    if not boss or not start_boss(state, boss) then return false end
    state.egg = actor:GetID()
    state.phase = "egg"
    return true
end

local function ring(state, source, boss, count, role, target)
    for index = 1, count do
        local angle = 2 * math.pi * index / count
        local npc = add(state, source[math.random(#source)],
            runtime.pose(boss, 18 * math.cos(angle), 18 * math.sin(angle)), role, target)
        if not npc then return false end
    end
    return true
end

local function empower(state)
    for member in eq.get_entity_list():GetClientList().entries do
        local dz = runtime.scope(member, state.spec)
        if dz and dz:GetUUID() == state.uuid and member:GetHP() > 0 then
            member:SetMana(math.min(member:GetMaxMana(), member:GetMana() + 8000))
            member:SetEndurance(math.min(member:GetMaxEndurance(), member:GetEndurance() + 8000))
        end
    end
end

function Sendaii.damage(state, e, target)
    if runtime.actor(e.self, state.spec.egg) and e.self:GetID() == state.egg and state.phase == "egg" then return 0 end
    local boss = e.self
    if not active_actor(state, boss) or state.phase ~= "queen" then return -1 end
    local ratio = (boss:GetHP() - e.damage) / boss:GetMaxHP()
    if ratio <= 0.75 and not state.copies_spawned then
        state.copies_spawned = true
        for _, offset in ipairs({-18, 0, 18}) do
            local clone = runtime.spawn_owned(state.spec.boss.npc, runtime.pose(boss, offset, 14), state.mark)
            if not clone then state.failed = true; return -1 end
            clone:ModifyNPCStat("max_hit", "2900")
            clone:AddToHateList(target, 1, 0)
            state.adds[clone:GetID()] = {role = "clone", npc = state.spec.boss.npc}
        end
        local cap = boss:GetHP() - math.ceil(boss:GetMaxHP() * 0.75)
        return cap > 0 and cap or -1
    end
    if ratio <= 0.45 then remove_adds(state, "clone") end
    if ratio <= 0.25 and not state.final_wave then
        state.final_wave = ring(state, drones, boss, 32, "last", target)
        if not state.final_wave then state.failed = true; return -1 end
        local cap = boss:GetHP() - math.ceil(boss:GetMaxHP() * 0.25)
        return cap > 0 and cap or -1
    end
    return 0
end

function Sendaii.tick(state, now)
    if state.failed then return false end
    if state.phase == "aftermath" then return true end
    local boss = runtime.placed(state.spec.boss, state.dz)
    if not boss or not active_actor(state, boss) then return false end
    local target = runtime.member_target(state.dz, state.spec, boss)
    if not target then return true end
    if state.phase == "drones" and now >= state.next_phase then
        if not ring(state, royal, boss, 12, "royal", target) then return false end
        empower(state)
        state.phase, state.next_phase = "royal", now + 480
    elseif state.phase == "royal" and now >= state.next_phase then
        empower(state)
        state.phase, state.next_phase, state.risen = "ancients", now + 2700, 0
        state.next_risen = now
    elseif state.phase == "ancients" then
        if state.risen < 6 and now >= state.next_risen then
            local risen = add(state, ancients[1], runtime.pose(boss, state.risen * 4 - 12, 20), "risen", target)
            if not risen then return false end
            risen:ModifyNPCStat("max_hit", "2800")
            risen:SetSpecialAbility(3, 1)
            risen:SetSpecialAbility(12, 1)
            risen:SetSpecialAbility(16, 1)
            state.risen = state.risen + 1
            state.next_risen = now + 24
        end
        if state.charge and now >= state.charge.due then
            for member in eq.get_entity_list():GetClientList().entries do
                local dz = runtime.scope(member, state.spec)
                local at = state.charge.point
                if dz and dz:GetUUID() == state.uuid and member:CalculateDistance(at[1], at[2], at[3]) <= 50 then
                    member:Damage(boss, 11000, 65535, 28, false)
                end
            end
            state.charge = nil
        elseif not state.charge and now >= (state.next_charge or now + 40) then
            local candidates = {}
            for member in eq.get_entity_list():GetClientList().entries do
                local dz = runtime.scope(member, state.spec)
                if dz and dz:GetUUID() == state.uuid and member:GetHP() > 0 then candidates[#candidates + 1] = member end
            end
            if #candidates > 0 then
                local candidate = candidates[math.random(#candidates)]
                local at = runtime.pose(candidate)
                boss:MoveTo(at[1], at[2], at[3], boss:GetHeading(), false)
                state.charge, state.next_charge = {point = at, due = now + 6}, now + 42
            end
        else
            state.next_charge = state.next_charge or now + 40
        end
        for id, record in pairs(state.adds) do
            if record.role == "enraged" then
                local add_npc = runtime.owned(state.mark, id, record.npc)
                if add_npc then
                    local top = add_npc:GetHateTop()
                    next_cast(state, "puncture" .. id, now, 18, add_npc, 7057, top)
                    next_cast(state, "spider" .. id, now, 31, add_npc, 7313, top)
                    next_cast(state, "web" .. id, now, 26, add_npc, 7060, top)
                end
            end
        end
        if now >= state.next_phase then
            state.phase = "queen"
            runtime.protect(boss, false)
            boss:AddToHateList(target, 1, 0)
        end
    elseif state.phase == "queen" then
        next_cast(state, "fog", now, 48, boss, 7316, boss:GetHateTop())
        next_cast(state, "web", now, 33, boss, 7318, boss:GetHateTop())
        next_cast(state, "frontal", now, 42, boss, 8151, boss:GetHateTop())
        next_cast(state, "sweeping", now, 58, boss, 8152, boss:GetHateTop())
    end
    return true
end

local function sendaii_corpse(state)
    if not state.final_corpse then return end
    local corpse = eq.get_entity_list():GetCorpseByID(state.final_corpse)
    if corpse.valid and corpse:IsNPCCorpse()
        and corpse:GetEntityVariable("dodh_raid:sendaii_aftermath") == state.mark then return corpse end
end

local function release_sendaii_corpse(state)
    local corpse = sendaii_corpse(state)
    if corpse then
        if state.locked_final_corpse then corpse:UnLock() end
        corpse:DeleteEntityVariable("dodh_raid:sendaii_aftermath")
    end
    return corpse
end

function Sendaii.death(state, e, target)
    if e.killed_entity_id == state.egg and runtime.actor(e.killed, state.spec.egg) and state.phase == "egg" then
        eq.disable_spawn2(state.spec.egg.spawn)
        local boss = runtime.placed(state.spec.boss, state.dz)
        if not boss or not ring(state, drones, boss, 12, "drone", target) then state.failed = true; return end
        state.dz:SetLocked(true)
        state.phase, state.next_phase = "drones", os.time() + 300
        return
    end
    if death_of_boss(state, e) and state.phase == "queen" and state.final_wave then
        local corpse = runtime.corpse(e)
        state.phase = "aftermath"
        if not corpse then state.failed = true; return end
        state.final_corpse = corpse:GetID()
        corpse:SetEntityVariable("dodh_raid:sendaii_aftermath", state.mark)
        -- An empty corpse can expire or be removed by closing an empty loot window.
        -- Keep this native corpse until the remaining adds die or the expedition expires.
        corpse:SetDecayTimer(math.max(1, state.dz:GetSecondsRemaining()) * 1000)
        if not corpse:IsLocked() then
            corpse:Lock()
            state.locked_final_corpse = true
        end
        eq.disable_spawn2(state.spec.boss.spawn)
    else
        local dying = take_add(state, e)
        if not dying then return end
        local position = runtime.pose(e.killed)
        if dying.role == "risen" or dying.role == "vengeful" then
            e.killed:SpellFinished(dying.role == "risen" and 8420 or 5726, e.killed)
            local count = dying.role == "risen" and 2 or 3
            local child = dying.role == "risen" and "vengeful" or "enraged"
            for index = 1, count do
                local place = {position[1] + index * 4, position[2], position[3], position[4]}
                local spawn = add(state, ancients[dying.role == "risen" and 2 or 3], place, child, target)
                if not spawn then state.failed = true; return end
                spawn:ModifyNPCStat("max_hit", "2800")
                spawn:SetSpecialAbility(dying.role == "risen" and 5 or 3, 1)
            end
        elseif dying.role == "last" and state.phase == "queen" then
            if not add(state, drones[math.random(#drones)], position, "last", target) then state.failed = true end
        end
    end
    if state.phase == "aftermath" and not next(state.adds) then
        local corpse = sendaii_corpse(state)
        if not corpse then state.failed = true end
        return corpse
    end
end

function Sendaii.finish(state)
    release_sendaii_corpse(state)
end

function Sendaii.reset(state)
    local corpse = release_sendaii_corpse(state)
    if corpse then corpse:ResetDecayTimer() end
    if state.dz.valid and state.phase ~= "egg" then state.dz:SetLocked(false) end
    runtime.restore(state.spec.egg, state.dz)
    runtime.restore(state.spec.boss, state.dz)
end

return M
