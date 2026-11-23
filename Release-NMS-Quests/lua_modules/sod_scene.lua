-- sod_scene.lua -- SoD mission scene driver (v466).
-- Re-authors nightstalker's native-scene mission machinery on our quest
-- primitives: their SodSceneState/Draw native API becomes module state +
-- entity polling; their corpse-transfer kill crediting becomes the engine's
-- native kill-count task activities (npc_match_list on the mission task);
-- their per-run persistence becomes per-instance module state.
--
-- The controller NPC of each mission calls into this module from
-- EVENT_SPAWN / EVENT_TIMER. Everything is keyed by the instance id, so two
-- instances of the same zone never share state.

local missions = require("sod_missions")

local M = {}
M.RUN = {}   -- controller entity id -> run table (two controllers share
-- an oldkithicor instance, so the instance id alone cannot key them)

local function cfg_for_controller(controller_id)
    for _, cfg in pairs(missions.missions) do
        if cfg.controller == controller_id then return cfg end
    end
    return nil
end

local function is_troop(cfg, mob)
    local tid = mob:GetNPCTypeID()
    for _, t in ipairs(cfg.troops) do
        if t == tid then return true end
    end
    return false
end

local function alive_clients_near(x, y, r)
    local out = {}
    local clients = eq.get_entity_list():GetClientList()
    if not clients then return out end
    for client in clients.entries do
        if client and client:GetHPRatio() > 0
            and math.abs(client:GetX() - x) <= r
            and math.abs(client:GetY() - y) <= r then
            out[#out + 1] = client
        end
    end
    return out
end

local function guarded_npcs_alive(el, cfg)
    if not cfg.fail_guard then return true end
    local alive = 0
    for _, nid in ipairs(cfg.fail_guard.npcs) do
        if el:IsMobSpawnedByNpcTypeID(nid) then alive = alive + 1 end
    end
    return alive >= #cfg.fail_guard.npcs
end

-- interception: unengaged troops march for the escape point; battle/defend
-- modes push at the guarded position. They stop to fight when intercepted
-- (their "real native moving NPCs" behavior) and resume when disengaged.
local function march(e, run, mob)
    local cfg = run.cfg
    local tx, ty, tz
    if cfg.escape then
        tx, ty, tz = cfg.escape[1], cfg.escape[2], cfg.escape[3]
    elseif cfg.fail_guard then
        local gm = eq.get_entity_list():GetNPCByNPCTypeID(cfg.fail_guard.npcs[1])
        if not (gm and gm.valid) then return end
        tx, ty, tz = gm:GetX(), gm:GetY(), gm:GetZ()
    else
        return
    end
    pcall(function() mob:MoveTo(tx, ty, tz, 0, false) end)
end

local function spawn_wave(e, run)
    local cfg = run.cfg
    local sent = 0
    for _ = 1, cfg.wave_size do
        if run.pool_idx > cfg.pool then break end
        local tid = cfg.troops[((run.pool_idx - 1) % #cfg.troops) + 1]
        local o = run.origins[tid]
        local mob = eq.unique_spawn(tid, 0, 0, o[1], o[2], o[3], 0)
        run.spawned = run.spawned + 1
        sent = sent + 1
        if mob then
            march(e, run, mob)
        end
        run.pool_idx = run.pool_idx + 1
    end
    if sent > 0 then
        eq.zone_emote(15, "More " .. (cfg.wave_label or "reinforcements")
            .. " push into the field!")
    end
end


-- ---- phased missions (v472): their five FoS group-mission controllers ----
-- Static actors spawn at scene start; a boss stays invul until its gate set
-- is dead; Brood runs its wave sequence. Win = boss dead or waves exhausted;
-- kill/talk/loot credit rides the engine task activities.
local function actor_dead(el, ent_id)
    local mob = el:GetNPCByID(ent_id)
    return (not mob) or (not mob.valid) or (mob:GetHP() <= 0)
end

local function gates_cleared(run, el)
    for _, ent_id in ipairs(run.gate_ids or {}) do
        if not actor_dead(el, ent_id) then return false end
    end
    return (run.gate_ids and #run.gate_ids > 0) and true or false
end

function M.on_spawn_phased(e, cfg)
    local inst = e.self:GetID()
    local run = {
        key = "phased", cfg = cfg, done = false, started = false,
        gate_ids = {}, boss_id = nil, boss_released = false,
        wave_idx = 0, wave_alive = {}, wave_spawned = 0, waves_sent = 0,
    }
    for _, a in ipairs(cfg.static_actors or {}) do
        local pos = a.pos
        local mob = eq.unique_spawn(a.npc, 0, 0, pos[1], pos[2], pos[3],
                                    pos[4] or 0)
        if mob then
            if a.gate then run.gate_ids[#run.gate_ids + 1] = mob:GetID() end
            if a.beguiler then run.beguiler_ids = run.beguiler_ids or {}
                run.beguiler_ids[#run.beguiler_ids + 1] = mob:GetID() end
        end
    end
    if cfg.boss then
        local pos = cfg.boss.pos
        local mob = eq.unique_spawn(cfg.boss.npc, 0, 0, pos[1], pos[2],
                                    pos[3], pos[4] or 0)
        if mob then
            run.boss_id = mob:GetID()
            if #run.gate_ids > 0 then
                M.set_invul(mob, true)
                run.boss_released = false
            else
                run.boss_released = true
            end
        end
    end
    M.RUN[inst] = run
    e.self:SetEntityVariable("done", "0")
    eq.set_timer("startcheck", 5000)
end

function M.on_tick_phased(e)
    local run = M.RUN[e.self:GetID()]
    if not run or run.done then return end
    local cfg = run.cfg
    local el = eq.get_entity_list()

    if not run.started then
        local near = alive_clients_near(e.self:GetX(), e.self:GetY(), 600)
        if #near >= (cfg.start_players or 1) then
            run.started = true
            eq.set_timer("scene", 5000)
            eq.zone_emote(15, cfg.start_line)
        end
        return
    end

    -- boss release: all gate actors dead
    if cfg.boss and not run.boss_released and #run.gate_ids > 0
        and gates_cleared(run, el) then
        run.boss_released = true
        local mob = el:GetNPCByID(run.boss_id)
        if mob and mob.valid then
            M.set_invul(mob, false)
            eq.zone_emote(15, "The honor guard falls -- the true fight begins!")
        end
    end

    -- brood wave sequence: next wave when the field is clear of the last
    if cfg.waves and run.wave_idx <= #cfg.waves then
        local last_alive = false
        for _, ent_id in ipairs(run.wave_alive) do
            if not actor_dead(el, ent_id) then last_alive = true break end
        end
        if not last_alive and run.waves_sent > 0 then
            run.wave_idx = run.wave_idx + 1
            run.wave_alive = {}
        end
        if run.wave_idx <= #cfg.waves and not last_alive then
            for _, b in ipairs(cfg.waves[run.wave_idx]) do
                local pos = b.pos
                local mob = eq.unique_spawn(b.npc, 0, 0, pos[1], pos[2],
                                            pos[3], pos[4] or 0)
                if mob then
                    run.wave_alive[#run.wave_alive + 1] = mob:GetID()
                    run.wave_spawned = run.wave_spawned + 1
                end
            end
            run.waves_sent = run.waves_sent + 1
            eq.zone_emote(15, "A defender wave charges from the hatchery!")
        end
    end

    -- win: boss dead (phases with one) or the wave list exhausted
    local won = false
    if cfg.boss and run.boss_id then
        won = actor_dead(el, run.boss_id) and run.boss_released
    elseif cfg.waves then
        won = run.wave_idx > #cfg.waves
    end
    if won then
        run.done = true
        e.self:SetEntityVariable("done", "1")
        eq.stop_all_timers()
        eq.zone_emote(15, cfg.win_line)
        return
    end
end

function M.on_spawn(e, mission_key)
    local cfg = missions.missions[mission_key]
    if not cfg then return end
    if cfg.mode == "phased" then return M.on_spawn_phased(e, cfg) end
    local inst = e.self:GetID()
    local run = {
        key       = mission_key,
        cfg       = cfg,
        spawned   = 0,      -- total troops sent
        escaped   = 0,
        started   = false,
        done      = false,
        pool_idx  = 1,
        last_wave = nil,
        origins   = {},     -- troop npc id -> origin (per-troop z jitter)
    }
    -- their origins share (x, y) per troop with per-troop z variation
    for i, tid in ipairs(cfg.troops) do
        run.origins[tid] = { cfg.origins[1], cfg.origins[2],
                             cfg.origins[3] + ((i % 4) - 1) * 1.2 }
    end
    M.RUN[inst] = run
    e.self:SetEntityVariable("done", "0")
    -- spawn the guarded npcs (refugees / camp defenders / watchmen) at the
    -- controller; they are the fail condition, so they live with the run
    if cfg.fail_guard then
        for i, nid in ipairs(cfg.fail_guard.npcs) do
            eq.unique_spawn(nid, 0, 0,
                e.self:GetX() + (i - 1) * 15 - 15,
                e.self:GetY() + (i % 2 == 0 and 12 or -12),
                e.self:GetZ(), 0)
        end
    end
    eq.set_timer("startcheck", 5000)
end

-- the tick: start gate, waves, marching, escape accounting, win/fail
function M.on_tick(e)
    if M.RUN[e.self:GetID()] and M.RUN[e.self:GetID()].cfg
        and M.RUN[e.self:GetID()].cfg.mode == "phased" then
        return M.on_tick_phased(e)
    end
    local inst = e.self:GetID()
    local run = M.RUN[inst]
    if not run or run.done then return end
    local cfg = run.cfg
    local el = eq.get_entity_list()

    if not run.started then
        -- start gate: start_players real members at the field
        local near = alive_clients_near(e.self:GetX(), e.self:GetY(), 400)
        if #near >= cfg.start_players then
            run.started = true
            run.last_wave = os.time()
            eq.set_timer("scene", 5000)
            eq.zone_emote(15, cfg.start_line)
            spawn_wave(e, run)
        end
        return
    end

    -- spawn cadence: refill on interval, or immediately when the field empties
    if run.pool_idx <= cfg.pool then
        local any_alive = false
        local mobs = el:GetNPCList()
        for m in mobs.entries do
            if m and m.valid and is_troop(cfg, m) then any_alive = true break end
        end
        if not any_alive
            or os.time() - (run.last_wave or 0) >= cfg.interval_seconds then
            run.last_wave = os.time()
            spawn_wave(e, run)
        end
    end

    -- march unengaged troops
    local mobs = el:GetNPCList()
    for m in mobs.entries do
        if m and m.valid and is_troop(cfg, m) and not m:IsEngaged() then
            march(e, run, m)
        end
    end

    -- escape accounting (their escape_radius + vertical tolerance)
    if cfg.escape then
        for m in el:GetNPCList().entries do
            if m and m.valid and is_troop(cfg, m) and not m:IsEngaged()
                and math.abs(m:GetX() - cfg.escape[1]) <= cfg.escape_radius
                and math.abs(m:GetY() - cfg.escape[2]) <= cfg.escape_radius
                and math.abs(m:GetZ() - cfg.escape[3]) <= cfg.escape_tolerance then
                m:Depop()
                run.escaped = run.escaped + 1
                eq.zone_emote(15, "A Rallosian column reaches Murdunk's encampment!")
            end
        end
    end

    -- win: the engine's kill-count task activity is the credit of record;
    -- this counter drives the scene state (spawned - escaped - alive)
    local alive_n = 0
    for m in el:GetNPCList().entries do
        if m and m.valid and is_troop(cfg, m) then alive_n = alive_n + 1 end
    end
    local kills = run.spawned - run.escaped - alive_n
    if kills >= cfg.required_kills then
        run.done = true
        e.self:SetEntityVariable("done", "1")
        eq.stop_all_timers()
        eq.zone_emote(15, cfg.win_line)
        return
    end

    -- fail guards: too many escapees, or the protected npcs fall
    if cfg.escape and run.escaped >= cfg.max_escaped then
        run.done = true
        e.self:SetEntityVariable("done", "1")
        eq.stop_all_timers()
        eq.zone_emote(15, cfg.fail_line)
        return
    end
    if cfg.fail_guard and not guarded_npcs_alive(el, cfg) then
        run.done = true
        e.self:SetEntityVariable("done", "1")
        eq.stop_all_timers()
        eq.zone_emote(15, cfg.fail_line)
        return
    end
end

-- controller cleanup on despawn (instance boot)
function M.on_destroy(e)
    M.RUN[e.self:GetID()] = nil
end

return M
