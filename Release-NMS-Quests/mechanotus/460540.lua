-- [[
-- Krond the Longhorn (460540) -- MMM event 4 (mechanotus v1).
-- Rasper: raidMMM.html stage 4.
--   * slavers charm players (modelled as a stun + emote)
--   * henchotaurs charge the centre; blocking them maims one player, letting
--     them through is a Hoof Stomp AE + silence
--   * random weapon-rack swaps: the tank must counter the new setup
-- On death: Treasure_of_Krond (460583) + controller signal.
-- Simplification: the sleep-until-95% opening and weapon-type enforcement are
-- emoted rather than enforced; charm is a timed stun.
-- ]]

local mmm = require("sof_mmm_raid")

local SIG = 2004
local SLAVER, HENCH = mmm.NPC.slaver, mmm.NPC.henchotaur
local MY_X, MY_Y, MY_Z = -70, 1590, 678.05
local SPAWN_X, SPAWN_Y = -130, 1660

local SETUPS = {
    "Far West - Krond equips Swords - the tank needs 1HB + 1HS",
    "Center West - Krond equips Axes - the tank needs 2HS",
    "Center East - Krond equips Gears - the tank needs 1HS + 1HS",
    "Far East - Krond equips Spears - the tank needs 1H and a Shield",
}

local engaged, done = false, false
local adds = {}
local hench = {}

local function alive(r)
    return mmm.alive_clients(MY_X, MY_Y, r or 300)
end

function event_combat(e)
    if e.joined then
        if not engaged then
            engaged = true
            eq.set_timer("slaver", 40000)
            eq.set_timer("hench", 50000)
            eq.set_timer("swap", 45000)
            eq.zone_emote(15, "Krond the Longhorn snorts awake. 'Trample them beneath your hooves!'")
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
            mmm.clear_list(adds); adds = {}
            mmm.clear_list(hench); hench = {}
            for _, t in ipairs({ "slaver", "hench", "swap", "stomp" }) do eq.stop_timer(t) end
            e.self:Heal()
            eq.zone_emote(15, "Krond settles back into a doze. The pen resets.")
        end
        return
    end
    if not engaged or done then return end

    if e.timer == "slaver" then
        local t = alive(300)
        local m = eq.spawn2(SLAVER, 0, 0, SPAWN_X, SPAWN_Y, MY_Z, 0)
        if m then
            adds[#adds + 1] = m:GetID()
            if #t > 0 then
                local v = t[math.random(#t)]
                m:AddToHateList(v, 1000, 10000)
                eq.zone_emote(15, "A minotaur slaver seizes " .. v:GetCleanName() .. "! Kill the slaver or dispel the charm!")
                pcall(function() v:Stun(8000) end)
            end
        end
        eq.set_timer("slaver", 40000)
    elseif e.timer == "hench" then
        eq.zone_emote(15, "Henchotaurs charge these pests, trample them beneath your hooves, gore them with your horns, revel in their slaughter!")
        for _ = 1, 2 do
            local m = eq.spawn2(HENCH, 0, 0, SPAWN_X + math.random(-10, 10), SPAWN_Y + math.random(-10, 10), MY_Z, 0)
            if m then hench[#hench + 1] = m:GetID() end
        end
        eq.set_timer("stomp", 7000)
        eq.set_timer("hench", 50000)
    elseif e.timer == "stomp" then
        -- any henchotaur that survived to the centre triggers the stomp
        local el = eq.get_entity_list()
        local through = 0
        for _, id in ipairs(hench) do
            local m = el:GetNPCByID(id)
            if m and m.valid and m:GetHPRatio() > 0 then
                through = through + 1
                pcall(function()
                    if m:CalculateDistance(MY_X, MY_Y, MY_Z) < 60 then
                        m:Depop()
                    end
                end)
            end
        end
        if through > 0 then
            eq.zone_emote(15, "Henchotaurs break through -- Hoof Stomp! (silencing the raid)")
            mmm.raw_damage(e.self, alive(300), 4000, 28)
        end
        hench = {}
    elseif e.timer == "swap" then
        eq.zone_emote(15, "Krond moves to a weapon rack -- " .. SETUPS[math.random(#SETUPS)] .. "!")
        eq.set_timer("swap", 45000)
    end
end

function event_death_complete(e)
    engaged = false
    done = true
    mmm.clear_list(adds); adds = {}
    mmm.clear_list(hench); hench = {}
    for _, t in ipairs({ "slaver", "hench", "swap", "stomp" }) do eq.stop_timer(t) end
    mmm.spawn_chest(e.self, SIG)
    mmm.signal(SIG)
    eq.zone_emote(15, "Krond the Longhorn topples. His rack of weapons clatters down around the chest.")
end
