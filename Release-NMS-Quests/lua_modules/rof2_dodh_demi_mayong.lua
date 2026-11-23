local admission = require("rof2_dodh_demi_admission")
local scene = require("rof2_dodh_demi_controller")
local runtime = require("rof2_dodh_raid_runtime")
local custody = require("rof2_dodh_public_blockers")
local M = {}
local answers = {
    ["strength|furious|mortals is food|glimpse into the future"] = true,
    ["beauty|sorrowful|mortals is food|glimpse into the future"] = true,
    ["strength|sorrowful|mortals is food|grew tired"] = true,
    ["control or destroy|disgusted|forget|killed her ability to love"] = true,
    ["control or destroy|furious|superiority|grew tired"] = true,
    ["beauty|disgusted|forget|glimpse into the future"] = true,
    ["strength|disgusted|forget|glimpse into the future"] = true,
    ["strength|furious|superiority|grew tired"] = true,
}
local blockers = {"redfang", "graniteclaw", "hatchet", "sisters"}
local guards = {
    {351178, 7917}, {351178, 7917}, {351178, 7917}, {351178, 7917},
    {351182, 8422}, {351143, 7757}, {351146, 7753},
}

local function ready()
    local layout = scene.layout.mayong
    return layout.throne and layout.guard_poses and #layout.guard_poses == #guards and scene.bindings.DEMI_VORACIOUS_BAT
end

local function start_answers(member)
    local response = {}
    for index, blocker in ipairs(blockers) do
        if not custody.has(member, blocker) then return nil end
        response[index] = member:GetBucket("dodh_demi:answer:" .. blocker)
        if not response[index] or response[index] == "" then return nil end
    end
    return answers[table.concat(response, "|")]
end

function M.present(dz)
    if not ready() or not admission.mayong_open(dz) then return end
    local state = scene.begin("mayong", dz)
    if not state or scene.actor(state, "master") then return end
    local master = scene.add(state, 351118, "master", scene.layout.mayong.throne)
    if not master then scene.fail(state); return end
    runtime.protect(master, true)
    master:ModifyNPCStat("max_hit", "5100")
    master:SetSpecialAbility(3, 1)
end

function M.say(state, role, e)
    if role ~= "master" or state.started or e.message:lower() ~= "hail" then return end
    if e.other:GetBucket("dodh_demi:mayong_starter") == "1" then return end
    if not start_answers(e.other) then
        e.self:Say("The answers you carry do not open this audience.")
        return
    end
    state.starter = e.other:CharacterID()
    state.started, state.next_guard = os.time(), os.time() + 10
    state.next_guard_index, state.killed_guards = 1, 0
    e.self:Shout("Enter, if you dare face the keep's guardians.")
end

function M.damage(state, role, e)
    if role ~= "master" then return 0 end
    if not state.fighting then return -1 end
    local starter = eq.get_entity_list():GetClientByCharID(state.starter)
    local current = starter.valid and admission.expedition(starter)
    return scene.final_hit(e.self, e.damage, state.killed_guards == 7 and current and current:GetUUID() == state.uuid)
end

local function guard_tick(state, now, boss, members)
    local index = state.next_guard_index
    if index <= #guards and now >= state.next_guard then
        local def = guards[index]
        local actor = scene.add(state, def[1], "guard", scene.layout.mayong.guard_poses[index], members[1])
        if not actor then return false end
        actor:SetEntityVariable("dodh_demi:bane_window", state.uuid)
        actor:ModifyNPCStat("max_hit", "4500")
        state.actors[actor:GetID()].spell = def[2]
        state.next_guard_index, state.next_guard = index + 1, now + 30
    end
    for _, record in pairs(state.actors) do
        if record.role == "guard" and record.npc.valid then
            local npc = record.npc
            scene.cast(state, "guard" .. record.id, now, 29, npc, record.spell, npc:GetHateTop())
            local spell = tonumber(npc:GetEntityVariable("dodh_demi:bane_landed"))
            if spell then
                npc:DeleteEntityVariable("dodh_demi:bane_landed")
                local mod = (spell == 8227 and record.kind == 351178 and 0.4)
                    or ((spell == 8225 and record.kind == 351178 or spell == 8226 and record.kind == 351143
                        or spell == 8231 and record.kind == 351146) and 0.10) or 0
                npc:SetHP(math.max(1, npc:GetHP() - math.floor(npc:GetMaxHP() * mod)))
            end
        end
    end
    return true
end

local function check_window(state, now, boss)
    local spell = tonumber(boss:GetEntityVariable("dodh_demi:bane_landed"))
    if state.bane and spell then
        boss:DeleteEntityVariable("dodh_demi:bane_landed")
        local vulnerable = state.bane.vulnerable
        local usable = spell == 8227 or spell == 8228 or spell == 8229 or spell == 8230 or spell == 8232
        if usable then state.bane.left = state.bane.left - 1 end
        if spell == 8232 then
            boss:SetHP(math.max(1, boss:GetHP() - math.floor(boss:GetMaxHP() * (vulnerable and 0.08 or 0.04))))
        elseif spell == 8229 then
            state.bats_at = state.bats_at + (vulnerable and 60 or 30)
        elseif spell == 8227 then
            state.bane_interval = math.max(25, state.bane_interval - 7)
        elseif spell == 8228 and vulnerable then
            state.weakened = math.min(3, (state.weakened or 0) + 1)
            boss:ModifyNPCStat("ac", tostring(math.floor(state.armor * (1 - 0.15 * state.weakened))))
        elseif spell == 8230 then
            boss:Stun(4000)
        end
    end
    if state.bane and (now >= state.bane.until_time or state.bane.left == 0) then
        state.bane = nil
        boss:DeleteEntityVariable("dodh_demi:bane_window")
        boss:DeleteEntityVariable("dodh_demi:bane_landed")
        state.bane_at = now + state.bane_interval
    elseif not state.bane and now >= state.bane_at then
        local vulnerable = math.random(2) == 1
        state.bane = {vulnerable = vulnerable, left = vulnerable and 1 or 3, until_time = now + 12}
        boss:SetEntityVariable("dodh_demi:bane_window", state.uuid)
        boss:Shout(vulnerable and "The Master is vulnerable." or "The Master is distracted.")
    end
end

function M.tick(state, now)
    local boss = scene.actor(state, "master")
    if not boss then return false end
    if not state.started then return true end
    local members = scene.members(state, boss, 200)
    if #members == 0 then return now - state.last < 80 end
    if not guard_tick(state, now, boss, members) then return false end
    if not state.fighting then
        if now >= state.started + 300 then
            state.fighting, state.bane_interval = true, 65
            state.bane_at, state.bats_at, state.trash_at = now + 65, now + 120, now + 45
            state.armor = boss:GetAC()
            runtime.protect(boss, false)
            boss:AddToHateList(members[1], 1, 0)
        end
        return true
    end
    check_window(state, now, boss)
    if now >= state.bats_at then
        state.bats_at = now + 120
        for index = 1, 15 do
            local member = members[(index - 1) % #members + 1]
            local bat = scene.add(state, scene.bindings.DEMI_VORACIOUS_BAT, "bat",
                scene.position(member, math.sin(index) * 12, math.cos(index) * 12), member)
            if not bat then return false end
            bat:ModifyNPCStat("max_hit", "1200")
        end
    end
    for id, record in pairs(state.actors) do
        if record.role == "bat" and record.npc.valid and record.npc:IsRooted() then
            record.npc:Depop(false)
            state.actors[id] = nil
        end
    end
    if now >= state.trash_at then
        state.trash_at = now + 45
        if not scene.add(state, 351146, "trash", scene.position(boss, 12, 10), members[1]) then return false end
    end
    scene.cast(state, "infusion", now, 67, boss, 7167, boss)
    local hp = boss:GetHPRatio()
    if hp <= 50 then
        if state.sword and now >= state.sword then
            local tank = runtime.owner(boss:GetHateTop())
            for _, member in ipairs(scene.members(state, boss, 80)) do
                if (not tank or tank:CharacterID() ~= member:CharacterID()) and boss:CheckLoS(member) then
                    member:Damage(boss, 100000, 65535, 28, false)
                end
            end
            state.sword = nil
            state.sword_again = now + 38
        elseif not state.sword and now >= (state.sword_again or now) then
            boss:Shout("The Master raises his sword. Break line of sight.")
            state.sword = now + 5
        end
    end
    if hp <= 20 then
        local member = members[math.random(#members)]
        scene.cast(state, "charm", now, 27, boss, 7164, member)
    end
    return true
end

function M.death(state, role, e)
    if role == "guard" then
        state.killed_guards = state.killed_guards + 1
    elseif role == "master" and state.fighting and state.killed_guards == #guards
        and runtime.corpse(e) and scene.finish(state, scene.position(e.killed, 8, 0)) then
        local starter = eq.get_entity_list():GetClientByCharID(state.starter)
        if starter.valid then
            starter:SetBucket("dodh_demi:mayong_starter", "1")
        end
    end
end

return M
