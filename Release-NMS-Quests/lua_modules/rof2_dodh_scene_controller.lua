local M = {}

-- The adapter validates native receipts against this instance and occurrence.
-- Actor handles are opaque, generation-specific values supplied by the adapter.
local function new_scene(adapter)
    return { engine = adapter, phase = "initial", pending = nil }
end

local function fail(scene)
    if scene.phase == "failed" or scene.phase == "complete" then
        return false
    end
    scene.phase = "failed"
    scene.pending = nil
    scene.engine.fail()
    return false
end

local function enqueue(scene, activity, count, next_phase)
    if scene.pending then
        return false
    end
    scene.pending = { activity = activity, count = count, next_phase = next_phase }
    return true
end

local function flush(scene)
    local pending = scene.pending
    if not pending then
        return true
    end
    -- "waiting" means the adapter has not observed native acknowledgement yet.
    -- It must not submit this credit again while acknowledgement is pending.
    local result = scene.engine.credit(pending.activity, pending.count)
    if result == "waiting" then
        return false
    end
    if result ~= "applied" then
        return fail(scene)
    end
    scene.pending = nil
    if pending.next_phase then
        scene.phase = pending.next_phase
    end
    return true
end

local function event_is(scene, event, kind, actor)
    return event and event.kind == kind and (actor == nil or event.actor == actor)
        and scene.engine.valid(event)
end

local function spawn_group(engine, role, points)
    local actors = {}
    for _, point in ipairs(points) do
        local actor = engine.spawn(role, point)
        if not actor or actors[actor] then
            return nil
        end
        actors[actor] = true
    end
    return actors
end

function M.clues(engine, binding)
    local scene = new_scene(engine)
    scene.boss = assert(binding.boss)
    assert(#binding.guard_points == 2)
    scene.phase = "first"
    return {
        damage = function(event)
            if not event or event.actor ~= scene.boss then
                return 0
            end
            if not event_is(scene, event, "damage", scene.boss) then
                return -1
            end
            if scene.phase == "retreat" or scene.phase == "failed" then
                return -1
            end
            if scene.phase ~= "first" or event.damage <= 0 then
                return 0
            end
            local threshold = math.max(1, math.floor(event.max_hp / 2))
            local remaining = event.hp - threshold
            if event.damage < remaining then
                return 0
            end

            scene.phase = "retreat"
            -- Suspend/relocate the existing actor, never spawn another boss.
            if not engine.retreat_existing(scene.boss, binding.final_point) then
                fail(scene)
                return -1
            end
            scene.stand_in = engine.spawn("stand_in", binding.original_point)
            scene.guards = spawn_group(engine, "retreat_guard", binding.guard_points)
            if not scene.stand_in or not scene.guards then
                fail(scene)
                return -1
            end
            -- This result is returned to the native pre-HP damage callback.
            return remaining > 0 and remaining or -1
        end,

        death = function(event)
            if not event_is(scene, event, "death") then
                return
            end
            if event.actor == scene.boss then
                if scene.phase ~= "final" then
                    fail(scene)
                end
                -- The existing exact-corpse hook owns note placement and credit.
                return
            end
            if scene.phase ~= "retreat" or not scene.guards[event.actor] then
                return
            end
            scene.guards[event.actor] = nil
            if next(scene.guards) then
                return
            end
            if not engine.arm_final(scene.boss) then
                fail(scene)
                return
            end
            engine.remove(scene.stand_in)
            scene.phase = "final"
            if not engine.release_existing(scene.boss) then
                fail(scene)
            end
        end,
    }
end

function M.deserting(engine, binding)
    local scene = new_scene(engine)
    scene.index = 0
    assert(#binding.singles == 9 and #binding.guard_anchors == 2)
    return {
        phase_event = function(event)
            if scene.phase == "initial" and event_is(scene, event, "opened_keyed_gate", binding.pit_gate) then
                -- The adapter has verified actual successful opening with the existing key.
                if engine.prepare_chamber(binding.passive_anchors) then
                    scene.phase = "ready"
                else
                    fail(scene)
                end
            elseif scene.phase == "ready" and event_is(scene, event, "committed_handin")
                and event.item == 86018 and engine.passive_recipient(event.actor) then
                scene.due = event.time + 20
                scene.phase = "handin_credit"
                enqueue(scene, 1, 1, "waves")
            elseif scene.phase == "insignia" and event_is(scene, event, "death", scene.captain) then
                if engine.place_insignia(event, 86017) then
                    scene.phase = "native_loot"
                else
                    fail(scene)
                end
            end
        end,

        tick = function(now)
            if not flush(scene) or scene.phase ~= "waves" or now < scene.due then
                return
            end
            scene.index = scene.index + 1
            if scene.index <= #binding.singles then
                if not engine.reanimate("wave_guard", binding.singles[scene.index]) then
                    fail(scene)
                    return
                end
                scene.due = now + 20
                return
            end
            scene.captain = engine.reanimate("captain", binding.captain_anchor)
            local guard_a = engine.reanimate("wave_guard", binding.guard_anchors[1])
            local guard_b = engine.reanimate("wave_guard", binding.guard_anchors[2])
            if not scene.captain or not guard_a or not guard_b then
                fail(scene)
                return
            end
            scene.phase = "insignia"
            -- Native 86017 loot and Zahn delivery own activities 2 and 3.
        end,
    }
end

-- Use the exact decimal string: Lua builds that represent numbers as doubles
-- cannot round-trip every native shared occurrence ID as a number.
local function gnome_slot(occurrence)
    assert(type(occurrence) == "string" and occurrence:match("^[1-9][0-9]*$"),
        "a verified shared occurrence ID is required")
    local remainder = 0
    for i = 1, #occurrence do
        remainder = (remainder * 10 + occurrence:byte(i) - 48) % 4
    end
    return remainder + 1
end

function M.gnomes(engine, binding)
    local scene = new_scene(engine)
    local subjects = {}
    local survivors, resolved = 0, 0
    local ordered = {}
    for index, cocoon in ipairs(binding.cocoons) do
        assert(type(cocoon.spawn) == "number" and cocoon.spawn > 0)
        ordered[index] = cocoon
    end
    assert(#ordered == 4)
    table.sort(ordered, function(left, right) return left.spawn < right.spawn end)
    local slot = gnome_slot(binding.occurrence)
    for index, cocoon in ipairs(ordered) do
        assert(not subjects[cocoon.spawn])
        subjects[cocoon.spawn] = {
            outcome = "closed",
            binding = cocoon,
            transforms = index == slot,
        }
    end

    local function finish(subject, alive)
        subject.outcome = "resolved"
        resolved = resolved + 1
        survivors = survivors + (alive and 1 or 0)
        if resolved == 4 then
            if survivors < 2 then
                fail(scene)
                return
            end
            enqueue(scene, 1, 4, "complete")
        end
    end

    return {
        phase_event = function(event)
            if scene.phase == "failed" or scene.phase == "complete" or scene.pending then
                return
            end
            if event_is(scene, event, "opened_cocoon") then
                local subject = subjects[event.placement]
                if subject and subject.outcome == "closed" then
                    subject.actor = engine.release_occupant(subject.binding, event)
                    if not subject.actor then
                        fail(scene)
                        return
                    end
                    subject.outcome = "waiting"
                end
                return
            end
            for _, subject in pairs(subjects) do
                if subject.actor and event.actor == subject.actor then
                    if subject.outcome == "waiting" and event_is(scene, event, "follow_request") then
                        if engine.follow(subject.actor, event) then
                            subject.outcome = "following"
                        end
                    elseif (subject.outcome == "waiting" or subject.outcome == "following")
                        and event_is(scene, event, "escort_death") then
                        fail(scene)
                    elseif subject.outcome == "following"
                        and event_is(scene, event, "living_arrival") then
                        if subject.transforms then
                            local replacement = engine.transform(subject.actor, event)
                            if not replacement then
                                fail(scene)
                                return
                            end
                            subject.outcome = "transformed"
                            subject.actor = replacement
                        else
                            finish(subject, true)
                        end
                    elseif subject.outcome == "transformed" and event_is(scene, event, "death") then
                        finish(subject, false)
                    end
                    return
                end
            end
        end,
        tick = function() flush(scene) end,
    }
end

function M.rescue(engine, binding)
    local scene = new_scene(engine)
    scene.phase = "guardians"
    scene.stop = 1
    scene.guardians = {}
    for _, guardian in ipairs(binding.guardians) do
        scene.guardians[guardian] = true
    end
    assert(#binding.guardians == 2 and binding.guardians[1] ~= binding.guardians[2])
    assert(#binding.stops == 5)
    for index, count in ipairs({1, 2, 1, 1, 2}) do
        assert(#binding.stops[index].guard_points == count)
    end

    local function move_escort()
        local stop = binding.stops[scene.stop]
        local destination = stop and stop.point or binding.exit
        if not engine.move_escort(scene.escort, destination) then
            return fail(scene)
        end
        scene.phase = "moving"
    end

    return {
        phase_event = function(event)
            if scene.phase == "failed" or scene.phase == "complete" then
                return
            end
            if scene.escort and event_is(scene, event, "escort_death", scene.escort) then
                fail(scene)
                return
            end
            if scene.phase == "guardians" and event_is(scene, event, "death") and scene.guardians[event.actor] then
                scene.guardians[event.actor] = nil
                if not next(scene.guardians) then
                    scene.keeper = engine.spawn("keeper", binding.keeper_point)
                    if not scene.keeper then
                        fail(scene)
                        return
                    end
                    scene.phase = "keeper"
                end
            elseif scene.phase == "keeper" and event_is(scene, event, "engaged", scene.keeper) then
                -- Preserve engage -> kill order even if the next attack is lethal.
                scene.phase = "keeper_credit"
                enqueue(scene, 1, 1, "keeper_engaged")
            elseif (scene.phase == "keeper_credit" or scene.phase == "keeper_engaged")
                and event_is(scene, event, "death", scene.keeper) then
                scene.keeper_death = event
            elseif scene.phase == "keeper" and event_is(scene, event, "death", scene.keeper) then
                fail(scene)
            elseif scene.phase == "cocoon" and event_is(scene, event, "opened_cocoon", scene.cocoon) then
                scene.escort = engine.release_escort(scene.cocoon, event)
                if not scene.escort then
                    fail(scene)
                    return
                end
                scene.phase = "opening_credit"
                enqueue(scene, 3, 1, "move_start")
            elseif scene.phase == "moving" and event_is(scene, event, "living_arrival", scene.escort)
                and event.stop == scene.stop then
                local stop = binding.stops[scene.stop]
                if not stop then
                    scene.phase = "exit_credit"
                    enqueue(scene, 4, 1, "complete")
                    return
                end
                scene.ambush = spawn_group(engine, "escort_guard", stop.guard_points)
                if not scene.ambush or not next(scene.ambush) then
                    fail(scene)
                    return
                end
                scene.phase = "ambush"
            elseif scene.phase == "ambush" and event_is(scene, event, "death") and scene.ambush[event.actor] then
                scene.ambush[event.actor] = nil
                if not next(scene.ambush) then
                    scene.stop = scene.stop + 1
                    move_escort()
                end
            end
        end,

        tick = function()
            if not flush(scene) then
                return
            end
            if scene.phase == "keeper_engaged" and scene.keeper_death then
                scene.phase = "keeper_death_credit"
                enqueue(scene, 2, 1, "create_cocoon")
            elseif scene.phase == "create_cocoon" then
                scene.cocoon = engine.spawn("aged_cocoon", binding.cocoon_point)
                if not scene.cocoon then
                    fail(scene)
                    return
                end
                scene.phase = "cocoon"
            elseif scene.phase == "move_start" then
                move_escort()
            end
        end,
    }
end

return M
