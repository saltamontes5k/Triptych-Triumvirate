-- [[
-- Geartop (460551) -- MMM Bargangle chain, first boss.
-- Rasper: raidMMM.html stage 5: Geartop flurries and spawns tiny tops; at
-- 80% he wakes one Autonomic Battle System, at 60% the meaner second one.
-- On death: a 10k heal + mana refresh to the raid, then Patch (460554) and
-- Seneschal Bargangle Tinkerson (460556) arrive.
-- ]]

local mmm = require("sof_mmm_raid")

local ABS, TINY = mmm.NPC.abs, mmm.NPC.tiny_top
local MY_X, MY_Y, MY_Z = 0, 1650, 678.05

local engaged, abs1, abs2, done = false, false, false, false
local adds = {}

local function alive(r)
    return mmm.alive_clients(MY_X, MY_Y, r or 300)
end

function event_combat(e)
    if e.joined then
        if not engaged then
            engaged = true
            eq.set_timer("tiny", 30000)
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
            abs1, abs2 = false, false
            mmm.clear_list(adds); adds = {}
            for _, t in ipairs({ "tiny", "phase" }) do eq.stop_timer(t) end
            e.self:Heal()
            eq.zone_emote(15, "Geartop winds back down. The workshop resets.")
        end
        return
    end
    if not engaged or done then return end

    if e.timer == "tiny" then
        eq.zone_emote(15, "Geartop kicks out spinning tiny tops! They grow stronger the longer they live.")
        for _ = 1, 2 do
            local m = eq.spawn2(TINY, 0, 0, MY_X + math.random(-35, 35), MY_Y + math.random(-35, 35), MY_Z, 0)
            if m then
                adds[#adds + 1] = m:GetID()
                local t = alive(300)
                if #t > 0 then m:AddToHateList(t[math.random(#t)], 1000, 10000) end
            end
        end
        eq.set_timer("tiny", 30000)
    elseif e.timer == "phase" then
        local hp = e.self:GetHPRatio()
        if not abs1 and hp <= 80 then
            abs1 = true
            local m = eq.spawn2(ABS, 0, 0, MY_X + 40, MY_Y, MY_Z, 0)
            if m then adds[#adds + 1] = m:GetID() end
            eq.zone_emote(15, "Geartop howls -- an Autonomic Battle System powers up!")
        end
        if not abs2 and hp <= 60 then
            abs2 = true
            local m = eq.spawn2(ABS, 0, 0, MY_X - 40, MY_Y, MY_Z, 0)
            if m then adds[#adds + 1] = m:GetID() end
            eq.zone_emote(15, "A second, meaner Autonomic Battle System stomps into the room!")
        end
        eq.set_timer("phase", 5000)
    end
end

function event_death_complete(e)
    engaged = false
    done = true
    for _, t in ipairs({ "tiny", "phase" }) do eq.stop_timer(t) end
    eq.zone_emote(15, "Geartop bursts like a boiler. A surge of steam heals and refreshes the raid.")
    for _, c in ipairs(alive(400)) do
        pcall(function() c:SetHP(c:GetMaxHP()); c:SetMana(c:GetMaxMana()) end)
    end
    mmm.clear_list(adds); adds = {}
    -- Patch + Bargangle arrive
    eq.spawn2(mmm.NPC.patch, 0, 0, MY_X + 25, MY_Y + 25, MY_Z, 0)
    eq.spawn2(mmm.NPC.bargangle, 0, 0, MY_X, MY_Y + 40, MY_Z, 0)
    eq.zone_emote(15, "Patch the brownie flutters in, and Seneschal Bargangle Tinkerson makes his entrance.")
end
