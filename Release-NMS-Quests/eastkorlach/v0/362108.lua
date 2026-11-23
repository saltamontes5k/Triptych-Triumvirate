local blood = require("rof2_dodh_blood_raids")

local council = require("rof2_dodh_council")

function event_say(e)
    local phrase = e.message:lower()
    if phrase == "hail" or phrase == "council of nine" then council.request(e) end
    if phrase == "hail" or phrase == "emperor draygun" then blood.request(e, "draygun") end
end
