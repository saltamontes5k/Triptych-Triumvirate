local config = require("rof2_dodh_bound_scenes")
local scope_api = require("rof2_dodh_scene_scope")
local controllers = require("rof2_dodh_scene_controller")
local receipts = require("rof2_dodh_scene_receipts")
local lifecycle = require("rof2_dodh_scene_lifecycle")
local corpses = require("rof2_dodh_mission_corpse")

local M = {}
local run

local function participant(character)
    if not run then return nil end
    for client in eq.get_entity_list():GetClientList().entries do
        if (not character or client:CharacterID() == character) and scope_api.member(run.scope, client) then
            return client
        end
    end
end

local function actor(key)
    return scope_api.actor(run.scope, key)
end

local function clear_ready()
    eq.get_zone():DeleteVariable("dodh_deserting_triangle_ready")
    if run.passives then
        for _, key in pairs(run.passives) do
            local npc = actor(key)
            if npc then npc:SetEntityVariable("dodh_deserting_passive", "") end
        end
    end
end

local function fail()
    if run.held then return end
    run.held = true
    if run.binding.task == 920224 then
        clear_ready()
        lifecycle.end_deserting(run.scope, run.dz)
    else
        -- Synchronous live failure only, while the original member and DZ
        -- still match. No delayed character/task fallback on reconstruction.
        local client = participant()
        if client and receipts.mapping(run.scope, client) == run.dz then
            client:FailTask(run.binding.task)
        end
    end
end

local function spawn_exact(npc_type, point, role, point_is_origin)
    if not participant() then return nil end
    local z = point[3] + (point_is_origin and 0 or 3)
    local mob = eq.spawn2(npc_type, 0, 0, point[1], point[2], z, point[4] or 0)
    if not mob or not mob.valid or not mob:IsNPC() then return nil end
    local npc = mob:CastToNPC()
    if not point_is_origin then
        local floor = npc:FindGroundZ(point[1], point[2], z + 5 - npc:GetZ())
        if floor ~= floor or math.abs(floor - point[3]) > 4 then
            npc:Depop(false)
            return nil
        end
    end
    local key = scope_api.register(run.scope, npc, role)
    if not key then npc:Depop(false) end
    return key
end

local function set_passive(npc, enabled)
    npc:SetInvul(enabled)
    npc:SetDisableMelee(enabled)
    npc:WipeHateList()
end

local function native_adapter(binding)
    local engine = {}
    engine.valid = function() return run ~= nil and not run.held end
    engine.fail = fail
    engine.credit = receipts.credit_adapter(run.scope, participant)
    engine.spawn = function(role, point)
        local key = spawn_exact(binding.roles[role], point, role, role == "stand_in" or role == "operator")
        local npc = key and actor(key)
        if npc then
            if role == "stand_in" or role == "operator" then set_passive(npc, true) end
            local client = participant()
            if client and (role == "retreat_guard" or role == "escort_guard") then
                npc:AddToHateList(client, 1, 0)
            end
        end
        return key
    end
    engine.remove = function(key)
        local npc = actor(key)
        if npc then npc:Depop(false) end
    end
    engine.retreat_existing = function(key, point)
        local npc = actor(key)
        if not npc then return false end
        local floor = npc:FindGroundZ(point[1], point[2], point[3] + 8 - npc:GetZ())
        if floor ~= floor or math.abs(floor - point[3]) > 4 then return false end
        set_passive(npc, true)
        npc:SetTargetable(false)
        npc:GMMove(point[1], point[2], point[3] + 3, npc:GetHeading(), true)
        return true
    end
    engine.release_existing = function(key)
        local npc = actor(key)
        if not npc then return false end
        npc:SetTargetable(true)
        set_passive(npc, false)
        return true
    end
    engine.arm_final = function(key)
        local client, npc = participant(), actor(key)
        return client and npc and corpses.arm_clues_final(client, npc)
    end
    engine.prepare_chamber = function(placements)
        for _, placement in ipairs(placements) do
            local pose = binding.body_poses[placement]
            local key = scope_api.register_placed(run.scope, pose.npc, placement, "passive")
            if not key then return false end
            run.passives[placement] = key
        end
        for _, key in pairs(run.passives) do
            local npc = actor(key)
            if not npc then return false end
            set_passive(npc, true)
            npc:SetAppearance(3)
            npc:SetEntityVariable("dodh_deserting_passive", key)
        end
        eq.get_zone():SetVariable("dodh_deserting_triangle_ready", run.scope.occurrence .. ":" .. run.dz)
        return true
    end
    engine.passive_recipient = function(key) return run.scope.actors[key] and run.scope.actors[key].role == "passive" end
    engine.reanimate = function(role, placement)
        local passive = actor(run.passives[placement])
        if not passive then return nil end
        passive:SetEntityVariable("dodh_deserting_passive", "")
        passive:Depop(false)
        return spawn_exact(binding.roles[role], binding.body_poses[placement].origin, role, true)
    end
    engine.place_insignia = function(event, item)
        local corpse = event.corpse
        if not corpse or not corpse.valid or not corpse:IsNPCCorpse()
            or corpse:GetID() ~= run.scope.actors[event.actor].id or corpse:CountItem(item) ~= 0 then
            return false
        end
        corpse:AddItem(item, 1)
        if corpse:CountItem(item) ~= 1 then
            return false
        end
        -- Apply the normal populated NPC corpse lifetime after adding the insignia.
        corpse:ResetDecayTimer()
        return true
    end
    engine.release_occupant = function(cocoon)
        return spawn_exact(cocoon.npc, cocoon.point, "gnome", true)
    end
    engine.follow = function(key, event)
        local npc = actor(key)
        if not npc or not scope_api.member(run.scope, event.member) then return false end
        npc:SetFollowID(event.member:GetID())
        npc:SetRunning(true)
        run.following[key] = true
        return true
    end
    engine.transform = function(key)
        local npc = actor(key)
        if not npc then return nil end
        local point = { npc:GetX(), npc:GetY(), npc:GetZ(), npc:GetHeading() }
        npc:Depop(false)
        return spawn_exact(binding.roles.replacement, point, "replacement", true)
    end
    engine.release_escort = function(_, event)
        if not event.corpse or not event.corpse.valid then return nil end
        local corpse = event.corpse
        local key = spawn_exact(binding.roles.escort, {corpse:GetX(), corpse:GetY(), corpse:GetZ()}, "escort", true)
        run.escort = key
        return key
    end
    engine.move_escort = function(key, point)
        local npc = actor(key)
        if not npc then return false end
        run.stop = (run.stop or 0) + 1
        run.destination = point
        -- A stop can keep its arrival anchor while avoiding an overlapping upper floor.
        local stop = binding.stops[run.stop]
        local approach = (stop and stop.approach) or point
        npc:SetRunning(true)
        npc:MoveTo(approach[1], approach[2], approach[3] + 3, npc:GetHeading(), true)
        return true
    end
    return engine
end

function M.enter(client, task)
    if run then return end
    local binding = config[task]
    local scope = binding and scope_api.bind(binding, client)
    local dz = scope and receipts.mapping(scope, client)
    if not dz then return end
    local state, key = lifecycle.start(scope, dz)
    if state == "hold" then return end
    run = {scope = scope, binding = binding, dz = dz, bucket = key, passives = {}, following = {}}
    if state == "interrupted" then
        run.held = true
        if task == 920224 then
            clear_ready()
            lifecycle.end_deserting(scope, dz)
        end
        return
    end
    local instance = {}
    for k, v in pairs(binding) do instance[k] = v end
    instance.occurrence = scope.occurrence
    if binding.scene == "clues" then
        instance.boss = scope_api.register_placed(scope, binding.npc, binding.spawn, "boss")
        if not instance.boss then fail(); return end
    elseif binding.scene == "gnomes" then
        for _, cocoon in ipairs(binding.cocoons) do
            if not scope_api.register_placed(scope, 355097, cocoon.spawn, "placed_cocoon") then fail(); return end
        end
    elseif binding.scene == "rescue" then
        instance.guardians = {}
        for _, pair in ipairs(binding.guardians) do
            local id = scope_api.register_placed(scope, pair[1], pair[2], "guardian")
            if not id then fail(); return end
            table.insert(instance.guardians, id)
        end
    end
    run.controller = controllers[binding.scene](native_adapter(binding), instance)
end

function M.death(event)
    if not run or run.held or not run.controller then return end
    local receipt = receipts.native_death(run.scope, event)
    if not receipt then return end
    if receipt.kind == "uncredited_death" then fail(); return end
    if run.binding.scene == "clues" then
        run.controller.death(receipt)
        if receipt.role == "boss" and not run.held then corpses.clues_death(event) end
    else
        receipt.corpse = event.corpse
        run.controller.phase_event(receipt)
    end
end

function M.damage(event)
    local npc = event.self
    local key = npc:GetEntityVariable("rof2_dodh_scene_actor")
    if not run or run.held or not run.controller or actor(key) == nil then return 0 end
    local role = run.scope.actors[key].role
    if role == "aged_cocoon" or role == "placed_cocoon" or role == "passive" then return -1 end
    if role ~= "boss" then return 0 end
    local source = event.other
    local client = source and source.valid and source:IsClient() and source:CastToClient()
    if not client and source and source.valid then
        local owner = source:GetOwner()
        client = owner and owner.valid and owner:IsClient() and owner:CastToClient()
    end
    if not scope_api.member(run.scope, client) then return -1 end
    return run.controller.damage({kind = "damage", actor = key, damage = event.damage,
        hp = npc:GetHP(), max_hp = npc:GetMaxHP()})
end

function M.combat(event)
    if not run or run.held or not run.controller or not event.joined then return end
    local key = event.self:GetEntityVariable("rof2_dodh_scene_actor")
    if actor(key) and run.scope.actors[key].role == "keeper" then
        local source = event.other
        if source and source.valid and source:IsClient() and scope_api.member(run.scope, source:CastToClient()) then
            run.controller.phase_event({kind = "engaged", actor = key})
        end
    end
end

function M.say(event)
    if not run or run.held or run.binding.scene ~= "gnomes" or not run.controller then return end
    local key = event.self:GetEntityVariable("rof2_dodh_scene_actor")
    if actor(key) and run.scope.actors[key].role == "gnome" and event.message:lower() == "follow"
        and scope_api.member(run.scope, event.other) then
        run.controller.phase_event({kind = "follow_request", actor = key, member = event.other})
    end
end

function M.tick()
    if not run then return end
    local now = os.time()
    if run.last_tick == now then return end
    run.last_tick = now
    if run.held then
        if not run.outcome then
            local outcome = lifecycle.outcome(run.scope)
            if outcome == "completed" or outcome == "ended" then run.outcome = outcome end
        end
        return
    end
    if not run.controller then return end
    local scene = run.binding.scene
    if scene == "deserting" then
        local gate = receipts.triangle(run.scope, participant)
        if gate then run.controller.phase_event(gate) end
        local paid = not run.hand_in and lifecycle.committed_guard(run.scope, run.dz)
        if paid then
            run.hand_in = paid.request_key
            clear_ready()
            if not spawn_exact(run.binding.roles.operator, run.binding.operator, "operator", true) then
                fail()
                return
            end
            run.controller.phase_event(paid)
        end
    elseif scene == "gnomes" then
        for key in pairs(run.following) do
            if scope_api.living_at(run.scope, key, run.binding.exit, 12, 12) then
                run.following[key] = nil
                run.controller.phase_event({kind = "living_arrival", actor = key})
                local remaining = actor(key)
                if remaining then remaining:Depop(false) end
            end
        end
    elseif scene == "rescue" and run.destination
        and scope_api.living_at(run.scope, run.escort, run.destination, 12, 12) then
        run.destination = nil
        run.controller.phase_event({kind = "living_arrival", actor = run.escort, stop = run.stop})
    end
    if run.controller.tick then run.controller.tick(now) end
end

return M
