local key_tasks = require("rof2_dodh_public_key_tasks")

local vule = require("rof2_dodh_vule")
local keys = require("rof2_dodh_dreadspire_keys")
local admission = require("rof2_dodh_demi_admission")
local ids = require("rof2_dodh_raid_ids")

function event_click_door(e)
    if key_tasks.route(e) == 1 then return 1 end
    if keys.click(e) == 1 then return 1 end
    if admission.click(e, ids.demi_entry_door) == 1 then return 1 end
    vule.click(e)
    return 0
end

function event_enter_zone() key_tasks.enter() end
function event_enter_area(e) key_tasks.area(e) end
function event_combine_success(e) key_tasks.combine(e) end
