-- [[
-- MMM_Zone_Controller (460590) -- Meldrath's Majestic Mansion raid, mechanotus v1.
-- Passive, factionless, non-combat.
--
--   * event_spawn: register every event chest as an expedition loot event so
--     an unlocked chest pays raid loot only to the surviving raid.
--   * event_signal: track the five event completions + Sixton, add the 72h
--     lockout for each, and when all six are done open the way to Meldrath
--     (signal 365034 key 5).
--
-- Signal map (eq.signal(460590, key) / eq.signal(460590, 2006)):
--   2001 Breakneck     2002 Battle Room   2003 Doctor Brinda
--   2004 Krond         2005 Bargangle     2006 Sixton Farqudot
--   out: 5 -> #Meldrath_The_Malignant (365034) gate opens
-- ]]

local mmm = require("sof_mmm_raid")
local LOCKOUT = eq.seconds("72h")

local KEYS = { 2001, 2002, 2003, 2004, 2005, 2006 }

function event_spawn(e)
    e.self:SetEntityVariable("ready", "0")
    for _, k in ipairs(KEYS) do
        e.self:SetEntityVariable("k" .. k, "0")
    end
    local exp = eq.get_expedition()
    if not exp.valid then return end
    for key, chest in pairs(mmm.CHEST) do
        exp:SetLootEventByNPCTypeID(chest, mmm.EVENT_NAME[key])
    end
end

function event_signal(e)
    local key = e.signal
    local has = false
    for _, k in ipairs(KEYS) do
        if k == key then has = true end
    end
    if not has then return end

    if e.self:GetEntityVariable("k" .. key) == "1" then
        return
    end
    e.self:SetEntityVariable("k" .. key, "1")

    local exp = eq.get_expedition()
    if exp.valid and mmm.EVENT_NAME[key] and not exp:HasLockout(mmm.EVENT_NAME[key]) then
        exp:AddLockout(mmm.EVENT_NAME[key], LOCKOUT)
    end

    local done = 0
    for _, k in ipairs(KEYS) do
        if e.self:GetEntityVariable("k" .. k) == "1" then done = done + 1 end
    end

    if done >= #KEYS and e.self:GetEntityVariable("ready") ~= "1" then
        e.self:SetEntityVariable("ready", "1")
        eq.zone_emote(15, "The mansion's inner doors grind open. Meldrath the Malignant awaits in the eastern hall.")
        eq.signal(365034, 5) -- open the Meldrath gate
    end
end
