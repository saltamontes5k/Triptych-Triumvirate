local scene = require("rof2_dodh_demi_controller")
local admission = require("rof2_dodh_demi_admission")
local runtime = require("rof2_dodh_raid_runtime")
local M = {}

local Granite = {}
M.graniteclaw = Granite
local retreats = {0.55, 0.50, 0.45}

function Granite.trash(e, dz, client)
    local id = scene.bindings.DEMI_ZI_THUULI
    local victim = e.killed
    if not id or not victim.valid or victim:GetLevel() < 73 or victim:GetSpawnPointID() <= 0
        or victim:GetNPCTypeID() == scene.layout.hatchet.boss.npc then return end
    local state = scene.begin("graniteclaw", dz)
    if not state or scene.actor(state, "granite") or state.recorded[e.killed_entity_id] then return end
    state.recorded[e.killed_entity_id] = true
    if math.random(3) ~= 1 then return end
    state.wave = (state.wave or 0) + 1
    state.ambush = scene.position(victim)
    local actor = scene.add(state, id, "granite", state.ambush, client)
    if not actor then scene.fail(state); return end
    actor:ModifyNPCStat("max_hit", "7000")
    actor:SetSpecialAbility(3, 1)
    actor:Shout("The stone above you cracks.")
    state.last = os.time()
end

function Granite.damage(state, role, e)
    if role ~= "granite" then return 0 end
    local actor = e.self
    local threshold = retreats[state.wave]
    if not threshold then return 0 end
    if actor:GetHP() - e.damage <= math.ceil(actor:GetMaxHP() * threshold) then
        state.retreat = true
        return -1
    end
    return 0
end

function Granite.tick(state, now)
    local boss = scene.actor(state, "granite")
    if not boss then return now - state.last < 600 end
    if state.retreat then
        scene.remove(state, "granite")
        state.retreat = nil
        state.last = now
        return true
    end
    if math.abs(boss:GetZ() - state.ambush[3]) > 38 or now - state.last > 120 then return false end
    local target = boss:GetHateTop()
    scene.cast(state, "pin", now, 23, boss, 7305, target)
    scene.cast(state, "stone", now, 37, boss, 7096, target)
    scene.cast(state, "wings", now, 56, boss, 7304, target)
    local members = scene.members(state, boss, 140)
    if #members > 0 then scene.cast(state, "spread", now, 61, boss, 7917, members[math.random(#members)]) end
    return true
end

function Granite.death(state, role, e)
    if role == "granite" and state.wave == 4 and not state.retreat then
        local corpse = runtime.corpse(e)
        if corpse then scene.finish(state, scene.position(e.killed, 6, 0), corpse) end
    end
end

local Redfang = {}
M.redfang = Redfang

function Redfang.trash(e, dz)
    local layout, ids = scene.layout.redfang, scene.bindings
    if not layout.window or not ids.DEMI_REDFANG or not ids.DEMI_BLOODDRINKER_BAT
        or not ids.DEMI_VORACIOUS_BAT or e.killed:GetNPCTypeID() ~= 351183 then return end
    local spid = e.killed:GetSpawnPointID()
    local exact = false
    for _, spawn in ipairs(layout.screechers) do if spid == spawn then exact = true; break end end
    if not exact then return end
    local state = scene.begin("redfang", dz)
    if not state or state.recorded[spid] then return end
    state.recorded[spid] = true
    if state.phase then return end
    for _, spawn in ipairs(layout.screechers) do if not state.recorded[spawn] then return end end
    Redfang.return_boss(state, os.time())
end

function Redfang.return_boss(state, now)
    local boss = scene.add(state, scene.bindings.DEMI_REDFANG, "redfang", scene.layout.redfang.window)
    if not boss then scene.fail(state); return end
    boss:ModifyNPCStat("max_hit", "5000")
    boss:SetSpecialAbility(3, 1)
    if state.hp then boss:SetHP(math.min(state.hp, boss:GetMaxHP())) end
    state.phase, state.retreat, state.last = "boss", now + 240, now
end

function Redfang.damage(state, role, e)
    if role == "redfang" then state.first = state.first or os.time() end
    return 0
end

local function spawn_drinker(state, boss, target)
    local bat = scene.add(state, scene.bindings.DEMI_BLOODDRINKER_BAT,
        "drinker", scene.position(boss, 10, 8), target)
    if not bat then return false end
    bat:ModifyNPCStat("max_hit", "2200")
    bat:SetSpecialAbility(13, 1)
    return true
end

function Redfang.tick(state, now)
    if state.phase == "bats" then
        if now >= state.return_at then
            scene.remove(state, "voracious")
            Redfang.return_boss(state, now)
            return true
        end
        for _, actor in pairs(state.actors) do
            if actor.role == "voracious" and actor.npc.valid then
                if actor.npc:IsRooted() then
                    actor.root_at = actor.root_at or now
                    if now >= actor.root_at + 4 then
                        actor.npc:Depop(false)
                        state.actors[actor.id] = nil
                    end
                else
                    actor.root_at = nil
                end
            end
        end
        return true
    end
    if state.phase ~= "boss" then return true end
    local boss = scene.actor(state, "redfang")
    if not boss or now - state.last > 90 and not state.first then return false end
    local target = boss:GetHateTop()
    if state.first and target.valid then
        if (state.drinkers or 0) < 4 and now >= (state.next_drinker or state.first) then
            if not spawn_drinker(state, boss, target) then return false end
            state.drinkers = (state.drinkers or 0) + 1
            state.next_drinker = now + 4
        end
        scene.cast(state, "siphon", now, 27, boss, 6972, target)
        scene.cast(state, "screech", now, 34, boss, 6970, target)
    end
    if now >= state.retreat then
        local near = scene.members(state, boss, 180)
        if #near == 0 then return false end
        state.hp = boss:GetHP()
        scene.remove(state, "redfang")
        state.phase, state.return_at = "bats", now + 60
        for index = 1, 15 do
            local member = near[(index - 1) % #near + 1]
            local bat = scene.add(state, scene.bindings.DEMI_VORACIOUS_BAT, "voracious",
                scene.position(member, math.cos(index) * 9, math.sin(index) * 9), member)
            if not bat then return false end
            bat:ModifyNPCStat("max_hit", "1200")
            bat:SetSpecialAbility(5, 1)
        end
    end
    return true
end

function Redfang.death(state, role, e, client)
    if role == "redfang" and state.phase == "boss" then
        local corpse = runtime.corpse(e)
        if corpse then scene.finish(state, scene.position(e.killed, 6, 0), corpse) end
    elseif role == "drinker" then
        local boss = scene.actor(state, "redfang")
        if boss then
            if not spawn_drinker(state, boss, client) then scene.fail(state) end
        else
            state.drinkers = math.max(0, (state.drinkers or 0) - 1)
        end
    end
end

local Hatchet = {}
M.hatchet = Hatchet
local hatchet_layout = scene.layout.hatchet

function Hatchet.open(npc, dz)
    for client_door, pose in pairs(hatchet_layout.trap_doors) do
        local door = eq.get_entity_list():GetDoorsByDoorID(client_door)
        if not door.valid or math.abs(door:GetX() - pose[1]) > 1 or math.abs(door:GetY() - pose[2]) > 1 then
            return false
        end
    end
    local state = scene.begin("hatchet", dz)
    if not state then return false end
    state.knockdowns, state.next_cue = 0, os.time() + 16
    npc:ModifyNPCStat("max_hit", "6500")
    npc:SetPseudoRoot(true)
    npc:SpellFinished(7138, npc)
    return scene.claim(state, npc, hatchet_layout.boss, "hatchet")
end

function Hatchet.damage(state, _, e)
    if state.knockdowns >= 4 then return 0 end
    local hp = e.self:GetHP()
    local floor = math.floor(e.self:GetMaxHP() * (1 - state.knockdowns / 5))
    if hp - e.damage < floor then
        local limit = hp - floor
        return limit > 0 and limit or -1
    end
    return 0
end

function Hatchet.door(state, e)
    local door = e.door:GetDoorID()
    local trap = hatchet_layout.trap_doors[door]
    if not trap then return 0 end
    local dz = admission.expedition(e.self)
    local boss = scene.actor(state, "hatchet")
    if not dz or dz:GetUUID() ~= state.uuid or not boss then return 1 end
    if state.cue and state.cue.kind == "charge" and state.knockdowns < 4 and not state.used_trap
        and boss:CalculateDistance(trap[1], trap[2], trap[3]) <= 12 then
        state.knockdowns = state.knockdowns + 1
        state.used_trap = true
        boss:SetPseudoRoot(true)
        boss:Shout("The spring of the trap throws the torturer to the ground.")
        for index, point in ipairs(hatchet_layout.footholds) do
            if index > 3 then break end
            if not scene.add(state, 351148, "skeleton", point, e.self) then scene.fail(state); break end
        end
    end
    return 1
end

function Hatchet.tick(state, now)
    local boss = scene.actor(state, "hatchet")
    if not boss or now - state.last > 90 then return false end
    scene.cast(state, "arc", now, 29, boss, 7140, boss:GetHateTop())
    if state.cue then
        local cue = state.cue
        local target = eq.get_entity_list():GetClientByCharID(cue.client)
        if not target.valid then state.cue = nil; return true end
        local range = boss:CalculateDistance(target)
        if cue.kind == "charge" and not state.used_trap then
            boss:MoveTo(target:GetX(), target:GetY(), target:GetZ(), boss:GetHeading(), false)
        end
        local caught = cue.kind == "charge" and not state.used_trap and range < 9
        if caught or now >= cue.stop then
            local failed = caught or cue.kind == "duck" and target:GetAppearance() ~= 2
                or cue.kind == "close" and range > 8 or cue.kind == "far" and range < 55
            if failed then
                if cue.kind == "charge" then
                    for _, member in ipairs(scene.members(state, boss, 50)) do
                        member:Damage(boss, 100000, 65535, 28, false)
                    end
                else
                    target:Damage(boss, 100000, 65535, 28, false)
                end
            end
            boss:SetPseudoRoot(state.knockdowns < 4)
            state.cue = nil
            state.next_cue = now + 16
        end
    elseif now >= state.next_cue then
        local members = scene.members(state, boss, 110)
        if #members == 0 then return false end
        local target = members[math.random(#members)]
        local cues = {charge = "He lowers his horns. Run and lead him to a trap.",
                      duck = "He levels his axe. Duck.",
                      close = "He raises the axe above his head. Step under him.",
                      far = "He draws a throwing axe. Get away."}
        local kind = ({"charge", "duck", "close", "far"})[(state.sequence or 0) % 4 + 1]
        state.sequence = (state.sequence or 0) + 1
        target:Message(MT.Yellow, cues[kind])
        state.used_trap = false
        if kind == "charge" then boss:SetPseudoRoot(false) end
        state.cue = {kind = kind, stop = now + (kind == "charge" and 25 or 5), client = target:CharacterID()}
    end
    return true
end

function Hatchet.death(state, role, e)
    if role == "hatchet" and state.knockdowns >= 4 then
        local corpse = runtime.corpse(e)
        if corpse and scene.finish(state, scene.position(e.killed, 8, 0), corpse) then
            eq.disable_spawn2(hatchet_layout.boss.spawn)
        end
    end
end

function Hatchet.reset(state) runtime.restore(hatchet_layout.boss, state.dz) end

return M
