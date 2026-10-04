-- [[
-- Assistant Fudindle (460550) -- MMM Bargangle chain opener.
-- Rasper: raidMMM.html stage 5: engage Fudindle; he flees and dies; Geartop
-- storms out. On death Fudindle spawns Geartop (460551).
-- ]]

local mmm = require("sof_mmm_raid")

local MY_X, MY_Y, MY_Z = 0, 1650, 678.05

function event_combat(e)
    if e.joined then
        eq.zone_emote(15, "Assistant Fudindle yelps and scurries deeper into the room!")
    end
end

function event_death_complete(e)
    eq.zone_emote(15, "Assistant Fudindle crumples. 'Geartop! They've gone and done it!' Geartop storms out to avenge him.")
    eq.spawn2(mmm.NPC.geartop, 0, 0, MY_X, MY_Y, MY_Z, 0)
end
