-- sof_fortress.lua -- shared helpers for the Fortress Mechanotus open
-- world content (raspersrealm openFortress.html). Companion to
-- sof_progression.lua; task ids 300027-300036 (faction arc) and
-- 301100-301114 (group missions).

local M = {}

-- faction-arc task ids (Clockwork Warmarshal)
M.TASK_ENDLESS = 300027
M.TASK_GEARS = 300028
M.TASK_HUNT_SPY = 300029
-- Gurtrude
M.TASK_RECYCLER = 300030
M.TASK_WORKSHOP = 300033
M.TASK_SPY_REPORTS = 300036
-- others
M.TASK_COMPETITION = 300031   -- Flizcog
M.TASK_PRODUCTION = 300032    -- Tavik
M.TASK_LUMPLING = 300034      -- Cogwittle
M.TASK_OILCANS = 300035       -- Tinmyn

-- mission task ids
M.MISSIONS_BEZA = { 301100, 301101, 301102, 301103, 301104 }
M.MISSIONS_ZEKA = { 301105, 301106, 301107, 301108, 301109 }
M.MISSIONS_SHIP = { 301110, 301111, 301112, 301113, 301114 }

-- key NPC ids
M.NPC = {
    warmarshal = 436010, gurtrude = 436003, cogwittle = 436000,
    tavik = 436004, flizcog = 436007, tinmyn = 436011, sparks = 436012,
    brinik = 436018, octa = 436133, huttle = 436175,
    spy_hunt = 436720, ambusher = 436721, guardian = 436722,
    wmd = 436723, skitter = 436724, pom = 436725, gearwhir = 436726,
    qcb = 436727, bloodwolf = 436728, ooze = 436729, gardener = 436730,
    aged_minotaur = 436731, musician_a = 436732, musician_b = 436733,
    veltar = 436734, jemi = 436735, hunter = 436736, spiderling = 436737,
    eradicator = 436738, security = 436739,
    deactivated = 438070, valve_inspector = 437167,
}

M.ITEM = {
    micro_cog = 36481, class_a_cog = 36476, tool_kit = 36577,
    tainted_crystal = 36622, incendiary = 35999,
    dirty_oil = 36641, warm_oil = 36642, unrefined_oil = 36644,
    hq_oil = 36645, blade = 36650, gear_saw = 36653, marauder_crystal = 36655,
    oil_can = 100085, black_badge = 100083, relocator = 100086,
    pouch = 88283, spirit_pouch = 88283, ring = 88284,
    black_box = 9920001, notes = 9920002, toolkit = 9920003,
    siege_notes = 9920004, driveshaft = 79601, calibration = 79602,
    screws = 79603, schematics = 79604, mis_driveshaft = 79605,
    schedule = 79606, plans = 79607,
    explosive = 72200, explosive2 = 88277,
    power_crystal = 9920008, microcog = 88275, metrognome = 88274,
}

-- bucket keys
M.BUCKET = {
    observe = "sof.fort.observe",      -- Huttle observation count + timestamp
    spy_stage = "sof.fort.spystage",   -- Hunt a Spy hail stage
}

M.task_done = function(client, task_id)
    return client:IsTaskCompleted(task_id)
end

M.task_active = function(client, task_id)
    return client:IsTaskActive(task_id)
end

M.task_state = function(client, task_id)
    return client:IsTaskActive(task_id) or client:IsTaskCompleted(task_id)
end

M.set = function(client, key, value)
    client:SetBucket(key, tostring(value))
end

M.get = function(client, key)
    local v = client:GetBucket(key)
    if v == nil or v == "" then return nil end
    return v
end

-- activity_done: true if the task's activity has been completed
M.activity_done = function(client, task_id, activity_id)
    if not client:IsTaskActive(task_id) then return false end
    return not client:IsTaskActivityActive(task_id, activity_id)
end

-- UpdateTaskActivity wrapper (script-driven activity 255 steps)
M.bump = function(client, task_id, activity_id, count)
    client:UpdateTaskActivity(task_id, activity_id, count or 1)
end

-- spawn one of our arc NPCs near a location and send it after someone
M.spawn_add = function(npc_id, x, y, z, target)
    local mob = eq.spawn2(npc_id, 0, 0, x + math.random(-30, 30),
        y + math.random(-30, 30), z, 0)
    if mob ~= nil and target ~= nil then
        mob:AddToHateList(target, 1)
    end
    return mob
end

return M
