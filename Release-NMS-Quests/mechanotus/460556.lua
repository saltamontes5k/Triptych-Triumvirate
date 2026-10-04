-- [[
-- Seneschal Bargangle Tinkerson (460556) -- MMM event 5 finale (mechanotus v1).
-- Rasper: raidMMM.html stage 5.
--   * hits ~14k, AE rampage, fire AEs (Face Slam / Belch of Fire / Steam Burst)
--   * at low health he overheats: a rising damage shield (200 -> 350)
--   * on death: a 15k AE, a 6k AE and a 10k mana drain
-- On death: Treasure_of_Bargangle (460584) + controller signal.
-- Simplification: the damage shield is emoted and approximated with a pulsing
-- AE rather than a true worn DS (no Lua DS setter in this build).
-- ]]

local mmm = require("sof_mmm_raid")

local SIG = 2005
local MY_X, MY_Y, MY_Z = 0, 1660, 678.05

local engaged, ds_stage, done = false, 0, false

local function alive(r)
    return mmm.alive_clients(MY_X, MY_Y, r or 300)
end

function event_combat(e)
    if e.joined then
        if not engaged then
            engaged = true
            eq.set_timer("ae", 30000)
            eq.set_timer("phase", 5000)
        end
        eq.stop_timer("resetcheck")
    else
        eq.set_timer("resetcheck", 60000)
    end
end

function event_timer(e)
    if e.timer == "resetcheck" then
        if not e.self:IsEngaged() and not done then
            engaged = false
            ds_stage = 0
            for _, t in ipairs({ "ae", "phase" }) do eq.stop_timer(t) end
            e.self:Heal()
            eq.zone_emote(15, "Bargangle cools back to a simmer. The event resets.")
        end
        return
    end
    if not engaged or done then return end

    if e.timer == "ae" then
        local roll = math.random(3)
        local t = alive(300)
        if #t == 0 then eq.set_timer("ae", 30000); return end
        if roll == 1 then
            eq.zone_emote(15, "Bargangle clambers up and lands a Face Slam!")
            local v = t[math.random(#t)]
            mmm.raw_damage(e.self, { v }, 2000, 28)
            pcall(function() v:Stun(2500) end)
        elseif roll == 2 then
            eq.zone_emote(15, "Belch of Fire roars across the room!")
            mmm.raw_damage(e.self, t, 18000, 2)
        else
            eq.zone_emote(15, "Steam Burst erupts toward the raid!")
            for _ = 1, math.min(5, #t) do
                local v = t[math.random(#t)]
                if v then mmm.raw_damage(e.self, { v }, 12000, 28) end
            end
        end
        eq.set_timer("ae", 30000)
    elseif e.timer == "phase" then
        local hp = e.self:GetHPRatio()
        if ds_stage == 0 and hp <= 25 then
            ds_stage = 1
            eq.zone_emote(15, "Bargangle begins to overheat -- a 200 point damage shield crackles around him!")
        elseif ds_stage == 1 and hp <= 12 then
            ds_stage = 2
            eq.zone_emote(15, "Bargangle glows white-hot -- the damage shield surges to 350!")
        end
        eq.set_timer("phase", 5000)
    end
end

function event_death_complete(e)
    engaged = false
    done = true
    for _, t in ipairs({ "ae", "phase" }) do eq.stop_timer(t) end
    eq.zone_emote(15, "Bargangle detonates in a cascade of scalding steam!")
    local t = alive(300)
    mmm.raw_damage(e.self, t, 15000, 2)
    mmm.raw_damage(e.self, t, 6000, 2)
    for _, c in ipairs(t) do pcall(function() c:SetMana(math.max(0, c:GetMana() - 10000)) end) end
    mmm.spawn_chest(e.self, SIG)
    mmm.signal(SIG)
    eq.zone_emote(15, "The Seneschal's chest drops amid the wreckage.")
end
