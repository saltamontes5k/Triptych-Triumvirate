-- [[
-- a_password_enforcer (460534) -- MMM Brinda event password carrier.
-- Death signals Doctor Brinda Sprocket (460530) key 3001; three carriers
-- complete the event. Rasper: raidMMM.html stage 3.
-- ]]

local mmm = require("sof_mmm_raid")

function event_death_complete(e)
    eq.zone_emote(13, "A password enforcer spills a scrap of shell code.")
    eq.signal(mmm.NPC.brinda, 3001)
end
