-- sof_progression.lua -- shared state for the Secrets of Faydwer
-- progression chain (zone + raid access). Used by the dragonscale,
-- mechanotus, mansion, crystallos, shipworkshop and global item scripts.
--
-- Flags are character data buckets (per-character, like live keys).

local M = {}

-- task ids (utils/sql/20260926_sof_progression.sql)
M.TASK_SEARCH = 301000          -- The Search for the Ultimate Story
M.TASK_DISRUPT = 301001         -- Disrupt the Workshop
M.TASK_BARRIER = 301002         -- Beyond the Barrier
M.TASK_FIND_I = 301003          -- ... through IV
M.TASK_RESTORE_I = 301007       -- ... through IV
M.TASK_EXPLORE_MANSION = 301011
M.TASK_EXPLORE_CRYSTALLOS = 301012

-- flag buckets
M.FLG = {
    mansion = "sof.prog.mansion_access",
    crystallos = "sof.prog.crystallos_access",
    mansion_raid = "sof.prog.mansion_raid",
    crystallos_raid = "sof.prog.crystallos_raid",
    disguise = "sof.prog.disguise",
    spy_report = "sof.prog.spy_report",
    key_akanon = "sof.prog.key_akanon",       -- Clockwork Key granted (to King)
    key_configured = "sof.prog.key_configured",
}

-- npc ids referenced by more than one script
M.NPC = {
    gimblefixx = 442097,
    warmarshal = 436010,
    gurtrude = 436003,
    king = 437600,
    laiyken = 442036,
    falrazim = 442086,
    plink = 436008,
}

-- item ids
M.ITEM = {
    key_mechanotus = 36444,   -- opens the King's chamber door
    key_configurable = 36445, -- the 8-tooth Mansion key
    seal = 36446,             -- Clockwork Seal of Ak'Anon
    spy_report = 29065,
    master_base = 36619,      -- Master Crystal Base (from Laiyken)
    charm = 36620,            -- Prismatic Crystal Charm
    oil_crystal = 36621,      -- Oil Stained Crystal (Meldrath raid)
    schedule = 36499,         -- Majestic Mansion Milestone and Meeting Schedule
}

-- The 8-tooth lock solution (fixed, like live).
M.LOCK_SECRET = { 3, 1, 7, 0, 5, 2, 6, 4 }
M.LOCK_BUCKET = "sof.prog.lockstate"   -- "p,p,p,p,p,p,p,p|tooth|lastclick"
M.LOCK_TOOTH_DELAY = 6                 -- seconds before the adjusted tooth advances

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

-- activity completed? (false while the task is not held)
function M.activity_done(client, task_id, activity_id)
    if not client:IsTaskActive(task_id) then
        return false
    end
    return not client:IsTaskActivityActive(task_id, activity_id)
end

function M.task_done(client, task_id)
    return client:IsTaskCompleted(task_id)
end

-- ---------------------------------------------------------------- lock state
function M.lock_load(client)
    local raw = M.get(client, M.LOCK_BUCKET)
    local teeth, tooth, last = {}, 0, 0
    if raw then
        local vals, t, ts = raw:match("^(.-)|(%d+)|(%d+)$")
        if vals then
            local i = 0
            for v in vals:gmatch("[^,]+") do
                i = i + 1
                teeth[i] = tonumber(v) or 0
            end
            tooth = tonumber(t) or 0
            last = tonumber(ts) or 0
        end
    end
    for i = 1, 8 do
        teeth[i] = teeth[i] or 0
    end
    return teeth, tooth, last
end

function M.lock_save(client, teeth, tooth, last)
    local vals = {}
    for i = 1, 8 do
        vals[i] = tostring(teeth[i] or 0)
    end
    M.set(client, M.LOCK_BUCKET,
        table.concat(vals, ",") .. "|" .. tostring(tooth) .. "|" .. tostring(last))
end

function M.lock_aligned(teeth)
    local n = 0
    for i = 1, 8 do
        if teeth[i] == M.LOCK_SECRET[i] then
            n = n + 1
        end
    end
    return n
end

local ORDINALS = { "first", "second", "third", "fourth", "fifth", "sixth",
    "seventh", "eighth" }

-- Slide the key: advances the active tooth, rolling to the next tooth when
-- more than LOCK_TOOTH_DELAY seconds passed since the previous slide.
function M.lock_slide(client)
    local teeth, tooth, last = M.lock_load(client)
    local now = os.time()
    if last > 0 and (now - last) >= M.LOCK_TOOTH_DELAY then
        tooth = tooth + 1
        if tooth > 8 then
            tooth = 1
        end
    elseif last == 0 then
        tooth = 1
    end
    teeth[tooth] = (teeth[tooth] + 1) % 8
    last = now
    M.lock_save(client, teeth, tooth, last)
    local aligned = M.lock_aligned(teeth)
    client:Message(15, string.format(
        "You carefully slide the %s tooth of the clockwork key into place. "
        .. "The key feels %s in your hand.", ORDINALS[tooth],
        aligned >= 5 and "almost ready" or "slightly different"))
    return aligned
end

return M
