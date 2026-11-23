local scene = require("rof2_dodh_demi_controller")
local runtime = require("rof2_dodh_raid_runtime")
local M = {}

local function present(dz, event, room, symbol)
    local id = scene.bindings[symbol]
    if not id or not room then return end
    local pose = room.pose
    local state
    for _, client in ipairs(scene.members({uuid = dz:GetUUID()})) do
        if client:CalculateDistance(pose[1], pose[2], pose[3]) <= 120 then
            state = scene.begin(event, dz)
            break
        end
    end
    if not state or next(state.actors) then return end
    -- Zone-state wake restores these dynamic actors without their Lua event state.
    local prefix = state.uuid .. ":" .. event .. ":"
    for npc in eq.get_entity_list():GetNPCList().entries do
        if npc.valid and npc:GetNPCTypeID() == id and npc:GetSpawnPointID() == 0 then
            local mark = npc:GetEntityVariable("dodh_raid:occurrence")
            if mark:sub(1, #prefix) == prefix and mark:sub(#prefix + 1):match("^%d+$") then
                npc:Depop(false)
            end
        end
    end

    local npc = scene.add(state, id, "offer", pose)
    if not npc then scene.fail(state); return end
    runtime.protect(npc, true)
end

local function start(e, state, role, hostile)
    if state.started or e.other:CalculateDistance(e.self) > 36 then return nil end
    local entry = state.actors[e.self:GetID()]
    if not entry or entry.role ~= "offer" then return nil end
    entry.role = role
    state.started, state.last = os.time(), os.time()
    if hostile then
        runtime.protect(e.self, false)
        e.self:AddToHateList(e.other, 1, 0)
    end
    return e.self
end

local Devlin = {}
M.devlin = Devlin
local forms = {"daggers", "axe", "scepter", "whip"}

function Devlin.present(dz)
    local layout = scene.layout.devlin
    if layout.rack then present(dz, "devlin", layout.room, "DEMI_DEVLIN") end
end

function Devlin.hail(e, state)
    local boss = start(e, state, "devlin", true)
    if not boss then return end
    boss:ModifyNPCStat("max_hit", "5400")
    state.arm_at = os.time() + 5
end

function Devlin.damage(state, role, e, member)
    if role ~= "devlin" then return 0 end
    if state.arm_at then return -1 end
    if state.shield then
        local resist = eq.get_spell_resist_type(e.spell_id)
        local elemental = e.damage > 0 and not e.is_buff_tic and not e.is_damage_shield
            and (resist == 2 or resist == 3)
        if elemental then
            state.alternations = state.last_element and state.last_element ~= resist and state.alternations + 1 or 1
            state.last_element = resist
            if state.alternations >= 4 then
                state.shield = false
                e.self:Shout("The shield breaks under the clash of heat and cold.")
                return 0
            end
        end
        if e.damage > 0 and eq.is_valid_spell(e.spell_id) and not e.is_buff_tic and not e.is_damage_shield
            and member:CalculateDistance(e.self) <= 100 then
            e.self:SpellFinished(e.spell_id, member)
        end
        return -1
    end
    return 0
end

function Devlin.tick(state, now)
    if not state.started then return true end
    local boss = scene.actor(state, "devlin")
    if not boss or now - state.last > 130 then return false end
    local room = scene.layout.devlin.room
    local rack = scene.layout.devlin.rack
    if state.change_at and now >= state.change_at and not state.arm_at then
        state.arm_at = now + 8
        boss:Shout("Devlin discards his weapons and returns to the rack.")
        boss:MoveTo(rack[1], rack[2], rack[3], rack[4], false)
    end
    if state.arm_at and now >= state.arm_at then
        local form = forms[math.random(#forms)]
        state.form, state.arm_at, state.change_at = form, nil, now + 95
        state.shield, state.alternations, state.last_element = form ~= "daggers", 0, nil
        boss:SetSpecialAbility(5, form == "daggers" and 1 or 0)
        boss:SetSpecialAbility(4, form == "axe" and 1 or 0)
        boss:Shout("Devlin selects " .. form .. ".")
        if state.changed then boss:SpellFinished(7331, boss) end
        state.changed = true
    end
    local target = boss:GetHateTop()
    if state.form == "scepter" and not state.arm_at then
        scene.cast(state, "corruption", now, 32, boss, 7328, target)
        if now >= (state.vial_at or now + 20) then
            if target.valid then state.vial = {point = scene.position(target), until_time = now + 5} end
            state.vial_at = now + 32
        else
            state.vial_at = state.vial_at or now + 20
        end
        if state.vial and now >= state.vial.until_time then
            local at = state.vial.point
            for _, client in ipairs(scene.members(state)) do
                if client:CalculateDistance(at[1], at[2], at[3]) <= 25 then boss:SpellFinished(7328, client) end
            end
            state.vial = nil
        end
    elseif state.form == "whip" and not state.arm_at then
        if target.valid and now >= (state.next_whip or now + 5) then
            local member = runtime.owner(target)
            if member then
                local demand = (state.duck_next and "duck") or "remove your main-hand weapon"
                member:Message(MT.Yellow, "Devlin raises his whip. " .. demand .. ".")
                state.whip = {id = member:CharacterID(), due = now + 4, duck = state.duck_next}
                state.duck_next = not state.duck_next
            end
            state.next_whip = now + 24
        else
            state.next_whip = state.next_whip or now + 5
        end
        if state.whip and now >= state.whip.due then
            local member = eq.get_entity_list():GetClientByCharID(state.whip.id)
            if member.valid and (state.whip.duck and member:GetAppearance() ~= 2
                or not state.whip.duck and member:GetItemIDAt(13) > 0) then boss:SpellFinished(7327, member) end
            state.whip = nil
        end
    end
    if target.valid and room.hall and now >= (state.wave or state.started + 20) then
        state.wave = now + 45
        if not scene.add(state, 351148, "skeleton", room.hall, target)
            or not scene.add(state, 351146, "hallguard", room.hall, target) then return false end
    end
    return true
end

function Devlin.death(state, role, e)
    if role == "devlin" and not state.arm_at and not state.shield and runtime.corpse(e) then
        scene.victory(state, scene.position(e.killed, 8, 0), "DEMI_DEVLIN")
    end
end

local Tris = {}
M.tris = Tris

local function tris_form(state, actor, form, now)
    state.form, state.form_end = form, now + 45
    actor:DeleteEntityVariable("dodh_demi:tris_curable")
    if form == "sitting" then
        actor:WipeHateList()
        actor:SendIllusionPacket({race = 1, gender = 1, texture = 0, helmtexture = 0})
        actor:SetAppearance(Appearance.Sitting)
        actor:SetSpecialAbility(38, 1)
        actor:Shout("Tris becomes human and struggles to speak.")
        if state.weakened then actor:SetEntityVariable("dodh_demi:tris_curable", state.uuid) end
    else
        actor:SetAppearance(Appearance.Standing)
        actor:SetSpecialAbility(38, 0)
        local living = scene.members(state, actor, 100)
        if #living > 0 then actor:AddToHateList(living[1], 1, 0) end
        if form == "standing" then
            actor:SendIllusionPacket({race = 1, gender = 1, texture = 0, helmtexture = 0})
            actor:Shout("Tris rises, but the curse still holds her.")
        else
            actor:SendIllusionPacket({race = 454, gender = 2, texture = 0, helmtexture = 0})
            actor:Shout("Tris returns to her werewolf form.")
            if #living > 0 then
                for index, pose in ipairs(scene.layout.tris.wolves) do
                    if not scene.add(state, 351146, "wolf", pose, living[(index - 1) % #living + 1]) then
                        return false
                    end
                end
            end
        end
    end
    return true
end

function Tris.present(dz)
    present(dz, "tris", scene.layout.tris.room, "DEMI_TRIS")
end

function Tris.offer(e, state)
    local words = e.message:lower():match("^%s*(.-)%s*$"):gsub("[!.]$", "")
    if words == "hail" then
        e.self:Say("Can you break this curse? Tell me " .. eq.say_link("we will help you") .. ".")
        return
    end
    if words ~= "we will help you" then return end
    local boss = start(e, state, "tris", true)
    if not boss then return end
    state.cures, state.cycle = 0, 0
    boss:ModifyNPCStat("max_hit", "4500")
    boss:SetSpecialAbility(5, 1)
    boss:SetSpecialAbility(SpecialAbility.immune_fleeing, 1)
    if not tris_form(state, boss, "wolf", state.started) then scene.fail(state) end
end

function Tris.damage(state, role, e, member)
    if role ~= "tris" then return 0 end
    local actor = e.self
    if state.form ~= "wolf" then
        if e.damage > 0 and os.time() >= (state.extra_guard or 0) then
            state.extra_guard = os.time() + 12
            if not scene.add(state, 351182, "orc", scene.layout.tris.guard, member) then scene.fail(state) end
        end
        return -1
    end
    local floor = math.floor(actor:GetMaxHP() * 0.09)
    local hp = actor:GetHP()
    if hp - e.damage <= floor then
        state.weakened = true
        return hp > floor and hp - floor or -1
    end
    return 0
end

function Tris.tick(state, now)
    if not state.started then return true end
    local boss = scene.actor(state, "tris")
    if not boss then return false end
    local room = scene.layout.tris
    if boss:CalculateDistance(room.room.pose[1], room.room.pose[2], room.room.pose[3]) > 55 then
        return false
    end
    local native = boss:GetEntityVariable("dodh_demi:tris_cure_landed")
    if native ~= "" then
        boss:DeleteEntityVariable("dodh_demi:tris_cure_landed")
        if state.form == "sitting" and state.weakened and native == state.uuid and boss:GetHP() == boss:GetMaxHP() then
            state.cures = state.cures + 1
            if state.cures == 5 then
                return scene.victory(state, room.reward, "DEMI_TRIS")
            end
            boss:SetHP(math.floor(boss:GetMaxHP() * 0.9))
        end
    end
    if now >= state.form_end then
        local form = ({wolf = "sitting", sitting = "standing", standing = "wolf"})[state.form]
        if not tris_form(state, boss, form, now) then return false end
        if form == "wolf" then
            state.cycle = state.cycle + 1
            if state.cycle % 3 == 0 then
                local targets = scene.members(state, boss, 150)
                if #targets > 0 and not scene.add(state, 351182, "orc", scene.layout.tris.guard, targets[1]) then
                    return false
                end
            end
        end
    end
    local members = scene.members(state, boss, 130)
    if #members > 0 and state.form ~= "sitting" then
        if state.glance and now >= state.glance.due then
            local member = eq.get_entity_list():GetClientByCharID(state.glance.id)
            if member.valid then
                local radians = member:GetHeading() * 2 * math.pi / 512
                local dx, dy = boss:GetX() - member:GetX(), boss:GetY() - member:GetY()
                if math.sin(radians) * dx + math.cos(radians) * dy > 0 then
                    boss:SpellFinished(state.form == "wolf" and 7027 or 7028, member)
                end
            end
            state.glance = nil
        elseif not state.glance and now >= (state.next_glance or state.started + 19) then
            local member = members[math.random(#members)]
            member:Message(MT.Yellow, "Tris tries to catch your eye. Look away.")
            state.glance, state.next_glance = {id = member:CharacterID(), due = now + 4}, now + 23
        end
    end
    return true
end

local Roley = {}
M.roley = Roley
local oak_by_branch = {52532, 52531, 52533} -- Library, crypt, laboratory.

function Roley.trash(e, dz, member)
    local layout, ids = scene.layout.roley, scene.bindings
    if not layout.ballroom or not layout.dancers or not layout.branch_rooms or not layout.branch_exits
        or not ids.DEMI_ROLEY or not ids.DEMI_ADRIANNA then return end
    local spawn = e.killed:GetSpawnPointID()
    if layout.dancers[spawn] ~= e.killed:GetNPCTypeID() then return end
    local state = scene.begin("roley", dz)
    if not state or state.started or state.recorded[spawn] then return end
    state.recorded[spawn] = true
    for id in pairs(layout.dancers) do if not state.recorded[id] then return end end
    local roley = scene.add(state, ids.DEMI_ROLEY, "roley", layout.ballroom, member)
    local pair = scene.add(state, ids.DEMI_ADRIANNA, "adrianna",
        {layout.ballroom[1] + 14, layout.ballroom[2], layout.ballroom[3], layout.ballroom[4]}, member)
    if not roley or not pair then scene.fail(state); return end
    roley:ModifyNPCStat("max_hit", "5000")
    state.step, state.started = 0, os.time()
end

function Roley.damage(state, role, e)
    local actor = e.self
    if role == "adrianna" then
        local hp, floor = actor:GetHP(), math.floor(actor:GetMaxHP() * 0.30)
        if state.branch then return -1 end
        if hp - e.damage <= floor then
            state.branch = math.random(3)
            state.branch_open = os.time() + 100
            actor:WipeHateList()
            actor:Say("I know where an oak weapon is kept. Ask me to show you.")
            return hp > floor and hp - floor or -1
        end
    elseif role == "roley" and state.step < 10 then
        local hp = actor:GetHP()
        local floor = math.max(1, math.floor(actor:GetMaxHP() * (9 - state.step) / 10))
        if hp - e.damage <= floor then
            if not state.staking then
                state.staking = os.time() + 12
                actor:SetPseudoRoot(true)
                actor:SetEntityVariable("dodh_demi:roley_window", state.uuid)
                actor:Shout("Roley goes prone. Drive in an oak stake now.")
            end
            return hp > floor and hp - floor or -1
        end
    end
    return 0
end

function Roley.say(state, role, e)
    if role ~= "adrianna" or e.message:lower() ~= "show" or not state.branch then return end
    local room = scene.layout.roley.branch_rooms[state.branch]
    if not state.branch_loaded then
        for index, at in ipairs(room.anchors) do
            local kind, role = room.guard, "branchguard"
            if index == room.reward then
                kind, role = room.zombie or 303120, room.zombie and "oakzombie" or "oakcache"
            end
            local guard = scene.add(state, kind, role, at, e.other)
            if not guard then scene.fail(state); return end
            if role == "oakcache" then
                guard:SetEntityVariable("dodh_demi:locked_chest", state.uuid)
                guard:SetLDoNTrapType(1)
                guard:SetLDoNLockedSkill(240)
                guard:SetLDoNLocked(true)
                runtime.protect(guard, true)
            end
        end
        state.branch_loaded = true
    end
    state.travellers = state.travellers or {}
    state.travellers[e.other:CharacterID()] = true
    e.other:MovePCInstance(351, eq.get_zone():GetInstanceID(), room.entry[1], room.entry[2], room.entry[3], room.entry[4])
end

local function branch_corpse(state)
    if not state.oak_corpse_id then return nil, false end
    local corpse = eq.get_entity_list():GetCorpseByID(state.oak_corpse_id)
    if not corpse.valid then return nil, true end
    if corpse:IsNPCCorpse() and corpse:GetEntityVariable("dodh_demi:oak_branch") == state.mark then
        return corpse, false
    end
    return nil, false
end

local function close_branch(state)
    local at = scene.layout.roley.branch_exits[state.branch]
    for id in pairs(state.travellers or {}) do
        local client = eq.get_entity_list():GetClientByCharID(id)
        if client.valid then client:MovePCInstance(351, eq.get_zone():GetInstanceID(), at[1], at[2], at[3], at[4]) end
    end
    scene.remove(state, "branchguard")
    scene.remove(state, "oakcache")
    if scene.layout.roley.branch_rooms[state.branch].zombie then
        scene.remove(state, "oakzombie")
    end
    local corpse = branch_corpse(state)
    if corpse and corpse:HasItem(state.oak) then corpse:RemoveItemByID(state.oak, 1) end
    state.branch, state.branch_open, state.branch_loaded, state.travellers = nil, nil, nil, nil
    state.oak, state.oak_corpse_id = nil, nil
    local pair = scene.actor(state, "adrianna")
    if pair then pair:SetHP(pair:GetMaxHP()) end
end

function Roley.tick(state, now)
    if not state.started then return true end
    local boss = scene.actor(state, "roley")
    if not boss then return false end
    local landed = boss:GetEntityVariable("dodh_demi:stake_landed")
    if state.staking and landed == state.uuid then
        boss:DeleteEntityVariable("dodh_demi:stake_landed")
        boss:DeleteEntityVariable("dodh_demi:roley_window")
        state.staking = nil
        state.step = state.step + 1
    elseif state.staking and now >= state.staking then
        boss:DeleteEntityVariable("dodh_demi:roley_window")
        boss:SetHP(math.min(boss:GetMaxHP(), boss:GetHP() + math.floor(boss:GetMaxHP() / 10)))
        state.staking = nil
    end
    if state.branch then
        local corpse, gone = branch_corpse(state)
        -- Native EndLoot can delete an emptied corpse before the next tick.
        if gone or (corpse and not corpse:HasItem(state.oak)) or now >= state.branch_open then
            close_branch(state)
        end
    end
    local target = boss:GetHateTop()
    scene.cast(state, "bloodlick", now, 25, boss, 7161, target)
    scene.cast(state, "darkness", now, 39, boss, 7162, target)
    scene.cast(state, "allure", now, 56, boss, 7163, target)
    return now - state.last < 160
end

function Roley.death(state, role, e, member)
    if role == "roley" and state.step == 10 and runtime.corpse(e) then
        if state.branch then close_branch(state) end
        scene.victory(state, scene.position(e.killed, 8, 0), "DEMI_ROLEY", "DEMI_ADRIANNA")
    elseif role == "oakzombie" and state.branch and scene.layout.roley.branch_rooms[state.branch].zombie
        and state.branch_loaded and not state.oak_corpse_id and os.time() < state.branch_open then
        local corpse = runtime.corpse(e)
        if corpse then
            state.oak, state.oak_corpse_id = oak_by_branch[state.branch], corpse:GetID()
            corpse:SetEntityVariable("dodh_demi:oak_branch", state.mark)
            corpse:SetDecayTimer(120000)
            corpse:AddItem(state.oak, 1)
        end
    elseif role == "oakcache" and state.branch and not scene.layout.roley.branch_rooms[state.branch].zombie
        and state.branch_loaded and not state.oak_corpse_id and os.time() < state.branch_open
        and e.killed:GetEntityVariable("dodh_demi:opened") == tostring(member:CharacterID()) then
        local corpse = runtime.corpse(e)
        if corpse then
            state.oak, state.oak_corpse_id = oak_by_branch[state.branch], corpse:GetID()
            corpse:SetEntityVariable("dodh_demi:oak_branch", state.mark)
            corpse:AddItem(state.oak, 1)
            corpse:ResetDecayTimer()
        end
    end
end

function Roley.reset(state) if state.branch then close_branch(state) end end

local Performer = {}
M.performer = Performer
local songs = {
    {prompt = "Beyond the gate, the lantern fades.", answer = "Carry the light into the hall."},
    {prompt = "When the last bell wakes the stone.", answer = "We stand together through the night."},
    {prompt = "The old house keeps its secrets.", answer = "Let the song give them a voice."},
    {prompt = "The final chord is ours to play.", answer = "Play on until the morning."},
}

function Performer.present(dz)
    local layout, ids = scene.layout.performer, scene.bindings
    if not ids.DEMI_BLUEBLOOD or not ids.DEMI_SPINSTRESS then return end
    for _, fixture in ipairs(layout.doorway) do
        local door = eq.get_entity_list():GetDoorsByDoorID(fixture.slot)
        if not door.valid or door:GetDoorDBID() ~= fixture.row then return end
    end
    present(dz, "performer", layout.stage, "DEMI_PERFORMER")
end

function Performer.hail(e, state)
    local boss = start(e, state, "performer", true)
    if not boss then return end
    boss:WipeHateList()
    state.singers = {}
    for index, member in ipairs(scene.layout.performer.band) do
        local singer = scene.add(state, member.type, "singer", member.pose)
        if not singer then scene.fail(state); return end
        runtime.protect(singer, true)
        singer:TempName(member.name)
        state.singers[index] = singer:GetID()
    end
    state.next_song, state.next_wave, state.wave_count = state.started + 27, state.started + 60, 0
    boss:Shout("Keep the stage clear and answer when a singer calls for you.")
end

function Performer.say(state, _, e)
    local score = state.score
    if not score or score.id ~= e.other:CharacterID() or os.time() > score.due
        or score.actor ~= e.self:GetID() or e.other:CalculateDistance(e.self) > 35 then return end
    if e.message:lower() == score.answer:lower() then state.score = nil end
end

function Performer.tick(state, now)
    if not state.started then return true end
    local boss = scene.actor(state, "performer")
    if not boss then return false end
    local layout = scene.layout.performer
    local members = scene.members(state, boss, 120)
    if #members == 0 then
        state.last_empty = state.last_empty or now
        if now - state.last_empty >= 30 then return false end
    else
        state.last_empty = nil
    end
    if now >= state.started + 1080 and #members > 0 then
        return scene.victory(state, layout.reward, "DEMI_PERFORMER")
    end
    if now >= state.next_wave then
        state.wave_count, state.next_wave = state.wave_count + 1, now + 60
        local ids = scene.bindings
        local targets = {351182, 351146, 351143}
        if state.wave_count == 6 then targets[1] = ids.DEMI_BLUEBLOOD end
        if state.wave_count == 12 then targets[3] = ids.DEMI_SPINSTRESS end
        for index, target in ipairs(targets) do
            local actor = scene.add(state, target, "performer_add", layout.entrances[index], boss)
            if not actor then return false end
            if target == ids.DEMI_BLUEBLOOD or target == ids.DEMI_SPINSTRESS then
                actor:ModifyNPCStat("max_hit", "4500")
                if target == ids.DEMI_BLUEBLOOD then
                    actor:SetSpecialAbility(4, 1)
                else
                    state.spinstress_id = actor:GetID()
                end
            end
        end
        boss:Shout("A bell sounds beyond the stage.")
    end
    if state.spinstress_id then
        local spinner = runtime.owned(state.mark, state.spinstress_id, scene.bindings.DEMI_SPINSTRESS)
        if spinner and spinner:GetHP() > 0 then
            scene.cast(state, "spinner_cloud", now, 25, spinner, 7757, boss)
            scene.cast(state, "spinner_net", now, 37, spinner, 7754, boss)
        else
            state.spinstress_id = nil
        end
    end
    if state.score and now >= state.score.due then
        local client = eq.get_entity_list():GetClientByCharID(state.score.id)
        if client.valid then boss:SpellFinished(7756, client) end
        local penalty = math.floor(boss:GetMaxHP() * 0.12)
        if boss:GetHP() <= penalty then return false end
        boss:SetHP(boss:GetHP() - penalty)
        state.score = nil
    end
    if not state.score and now >= state.next_song then
        state.next_song = now + 36
        if #members > 0 then
            local number = math.random(#songs)
            local song, client = songs[number], members[math.random(#members)]
            local singer = layout.band[number].name:gsub("_", " ")
            client:Message(MT.Yellow, singer .. " beckons you to sing. " .. song.prompt)
            client:Message(MT.Yellow, "Reply to the singer with " .. song.answer)
            state.score = {id = client:CharacterID(), due = now + 15, actor = state.singers[number], answer = song.answer}
        end
    end
    return true
end

function Performer.death(state, role, e)
    if role == "performer" then
        scene.fail(state)
    elseif role == "performer_add" and state.spinstress_id == e.killed_entity_id then
        state.spinstress_id = nil
    end
end

return M
