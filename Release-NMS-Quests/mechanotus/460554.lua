-- [[
-- Patch (460554) -- MMM Bargangle chain, non-hostile steamsuit wrangler.
-- Rasper: raidMMM.html stage 5: while Patch lives he activates the steamsuits
-- around the room. Kill Patch (or burn Bargangle first) to stop them.
-- ]]

local mmm = require("sof_mmm_raid")

local MY_X, MY_Y, MY_Z = -90, 1650, 678.05

local SUITS = {
    "a steamwork firestorm -- mez or stun-lock it before it casts!",
    "an uncontrollable firestorm -- immune to mez, kill it now!",
    "a steamwork geargrinder -- snare or root it.",
    "an uncontrollable geargrinder -- immune to root -- it flurries!",
}

function event_spawn(e)
    eq.set_timer("suit", 30000)
end

function event_timer(e)
    if e.timer ~= "suit" then return end
    local m = eq.spawn2(mmm.NPC.steamsuit, 0, 0,
        MY_X + math.random(-45, 45), MY_Y + math.random(-25, 25), MY_Z, 0)
    if m then
        local t = mmm.alive_clients(MY_X, MY_Y, 350)
        if #t > 0 then m:AddToHateList(t[math.random(#t)], 1000, 10000) end
    end
    eq.zone_emote(15, "Patch twists a valve -- " .. SUITS[math.random(#SUITS)])
    eq.set_timer("suit", 30000)
end

function event_death_complete(e)
    eq.zone_emote(15, "Patch flutters down, spent. The steamsuits stop waking.")
end
