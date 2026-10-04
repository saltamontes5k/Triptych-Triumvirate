-- uf_progression.lua -- shared state and helpers for the Underfoot
-- raid progression (Rasper: miscRaidProg.html). Used by the war camp
-- scripts in brellsrest/ and by the encounter scripts in the raid zones.
--
-- Structure (SQL emitted by uf_content/gen_uf_*.py, 20260930_uf_*.sql):
--   * five zone group missions (tasks 304000-304004) are the request
--     gates for the T6/T7 raids;
--   * the three T6 open raids are world events with a 72h global
--     cooldown (data bucket "uf.open.<key>" holding the expiry epoch);
--   * keyed raids are gated by mission completion + one Coin/Emblem/
--     Amulet of Brell handed to the requester (consumed);
--   * Convorteum is seven sequential stages driven by its controller.

local M = {}

-- ---------------------------------------------------------------- tasks
M.TASK_FOUNDATION = 304000     -- Clogging the Foundations
M.TASK_QUARRY = 304001         -- Breaking the Quarry
M.TASK_HIVE = 304002           -- Venting the Hive
M.TASK_CREEP = 304003          -- Clearing the Creep
M.TASK_FUNGAL = 304004         -- Spore and Loathing

-- ---------------------------------------------------------------- items
M.ITEM = {
    coin = 88391,     -- Coin of Brell (open raid drops)
    emblem = 88392,   -- Emblem of Brell (T6 keyed drops)
    amulet = 88393,   -- Amulet of Brell (T7 drops / T8 backflag)
}

-- ---------------------------------------------------------------- flags
M.FLG = {
    hive_guardians = "uf.prog.hive_guardians",
    trial_decon = "uf.prog.trial_deconstruction",
    trial_creation = "uf.prog.trial_creation",
    brell_audience = "uf.prog.brell_audience",
}
M.STAGE_FLG = {
    [1] = "uf.prog.stage1",
    [2] = "uf.prog.stage2",
    [3] = "uf.prog.stage3",
    [4] = "uf.prog.stage4",
    [5] = "uf.prog.stage5",
    [6] = "uf.prog.stage6",
    [7] = "uf.prog.stage7",
}

-- ---------------------------------------------------------------- npcs
M.NPC = {
    -- war camp (brellsrest v0)
    grave_watcher = 480200,     -- Fippy trigger
    foreman = 486200,           -- Bagrinhold: foundation mission + Masked
    quarrymaster = 482400,      -- Torbjorn: quarry mission + Brath
    brindel = 485210,           -- Brindel: hive mission + Guardians/Queen
    odele = 487100,             -- Odele: creep mission + Cunning Plan
    fenna = 481200,             -- Fenna: fungal mission + Corruption
    halgrim = 490100,           -- Halgrim: three temple raids
    dagna = 480260,             -- Dagna: Convorteum
    -- open raid bosses
    fippy = 480210,
    unburrowing = 488210,
    beast = 483110,
    -- T6 keyed bosses
    hierarch = 486230,
    brath = 482420,
    queen = 485230,
    hive_ctrl = 485290,
    -- T7 bosses
    vzarn = 487120,
    corruption = 481220,
    deconstructor = 490120,
    creation = 490130,
    brell = 490041,
    -- T8
    conv_ctrl = 491290,
    stages = { 491200, 491210, 491220, 491230, 491240, 491250, 491260 },
    sisters = { 491250, 491251, 491252 },
}

M.CHEST = {
    fippy = 480250, unburrowing = 488250, beast = 483150,
    masked = 486260, brath = 482460,
    guardians = 485260, queen = 485261,
    cunning = 487160, fungal = 481260,
    decon = 490160, creation = 490161, audience = 490162,
    conv = { 491270, 491271, 491272, 491273, 491274, 491275, 491276 },
}

-- war camp anchor (Brell's Rest, by the Useful Automated Vendor)
M.CAMP = { x = 9.0, y = 466.0, z = 152.625 }

-- ---------------------------------------------------------------- flags
function M.set(client, key, value)
    client:SetBucket(key, tostring(value))
end

function M.get(client, key)
    local v = client:GetBucket(key)
    if v == nil or v == "" then
        return nil
    end
    return v
end

function M.has_flag(client, key)
    return M.get(client, key) == "1"
end

function M.task_done(client, task_id)
    return client:IsTaskCompleted(task_id)
end

-- ------------------------------------------------------ open raid cooldown
-- Global data buckets hold the expiry epoch; compare against os.time()
-- ourselves so a malformed expires column can never wedge the event.
function M.world_ready(key)
    local raw = eq.get_data(key)
    if raw == nil or raw == "" then
        return true, 0
    end
    local expiry = tonumber(raw) or 0
    return expiry <= os.time(), math.max(0, expiry - os.time())
end

function M.world_start(key, hours)
    eq.set_data(key, tostring(os.time() + hours * 3600))
end

-- ------------------------------------------------------ encounter helpers
function M.alive_clients(x, y, radius)
    local out = {}
    local list = eq.get_entity_list():GetClientList()
    if not list then
        return out
    end
    for c in list.entries do
        if c and c:GetHPRatio() > 0 and math.abs(c:GetX() - x) <= (radius or 300)
            and math.abs(c:GetY() - y) <= (radius or 300) then
            out[#out + 1] = c
        end
    end
    return out
end

function M.clear_adds(adds)
    local el = eq.get_entity_list()
    for _, id in ipairs(adds) do
        local m = el:GetNPCByID(id)
        if m and m.valid then
            m:Depop()
        end
    end
end

-- Spawn the Treasure chest at the boss's corpse. Inside an expedition the
-- chest is registered as a loot event (raid-locked); in the open world it
-- is a plain chest anyone may punch.
function M.spawn_chest(e, chest_id, event_name)
    local exp = eq.get_expedition()
    local chest = eq.unique_spawn(chest_id, 0, 0,
        e.self:GetX(), e.self:GetY(), e.self:GetZ() + 5, 0)
    if chest ~= nil and exp.valid then
        exp:SetLootEventBySpawnID(chest:GetID(), event_name)
    end
    return chest
end

-- ------------------------------------------------------ raid requesting
-- Build a CreateExpedition definition; compass/safereturn point at the
-- war camp so a wiped raid wakes up next to the requester.
function M.dz(name, zone, version, zonein, min_players, max_players)
    return {
        expedition = { name = name,
                       min_players = min_players or 1,
                       max_players = max_players or 54 },
        instance = { zone = zone, version = version,
                     duration = eq.seconds("8h") },
        compass = { zone = "brellsrest", x = M.CAMP.x, y = M.CAMP.y, z = M.CAMP.z },
        safereturn = { zone = "brellsrest", x = M.CAMP.x, y = M.CAMP.y,
                       z = M.CAMP.z, h = 0 },
        zonein = { x = zonein[1], y = zonein[2], z = zonein[3], h = 0 },
    }
end

-- Shared request flow: level gate -> caller's gate -> no active claim ->
-- CreateExpedition + replay lockout. Returns true when the raid was made.
function M.request_raid(e, dz_def, min_level, gate)
    if e.other:GetLevel() < (min_level or 80) then
        e.self:Say("Return at level " .. (min_level or 80) .. ", "
            .. e.other:GetCleanName() .. ".")
        return false
    end
    if gate then
        local ok, why = gate(e)
        if not ok then
            e.self:Say(why)
            return false
        end
    end
    local current = e.other:GetExpedition()
    if current.valid then
        e.self:Say("You already hold a claim to an expedition. Use it or let it lapse.")
        return false
    end
    local dz = e.other:CreateExpedition(dz_def)
    if dz.valid then
        dz:AddReplayLockout(eq.seconds("72h"))
        e.self:Say("It is settled. Tell me when you are [ready].")
        return true
    end
    e.self:Say("The way is cycling -- ask me again shortly.")
    return false
end

-- "ready" re-entry used by every war camp requester.
function M.ready(e)
    local dz = e.other:GetExpedition()
    if dz.valid then
        e.self:Say("Pass through, " .. e.other:GetCleanName() .. ".")
        e.other:MovePCDynamicZone(dz:GetZoneID())
    else
        e.self:Say("You belong to no expedition.")
    end
end

return M
