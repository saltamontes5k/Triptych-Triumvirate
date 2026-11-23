local scope_api = require("rof2_dodh_scene_scope")
local binding = {task = 920238, zone_id = 358, version = 2}

function event_say(event)
    local meldrek, client = event.self, event.other
    if meldrek:GetNPCTypeID() ~= 358198 or meldrek:GetSpawnPointID() ~= 261257
        or not scope_api.bind(binding, client) then return end
    if eq.get_task_activity_done_count(binding.task, 7) ~= 1
        or eq.get_task_activity_done_count(binding.task, 8) ~= 1 then return end

    local message = event.message:lower():match("^%s*(.-)%s*$"):gsub("[.!?]$", "")
    if message == "hail" then
        local ready = eq.say_link("ready to go", false, "ready to go")
        meldrek:Say("Tell me when you are " .. ready .. ".")
    elseif message == "ready to go" or message == "we are ready to go" then
        client:MovePC(358, -1734, -207, 25.5, 170)
    end
end
