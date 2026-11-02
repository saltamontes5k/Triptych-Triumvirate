-- Shard's Landing welcome task; existing global player events still run separately.
function event_enter_zone(e)
    if e.self:GetLevel() >= 85 and not e.self:IsTaskActive(910000) and not e.self:IsTaskCompleted(910000) then
        e.self:AssignTask(910000)
    end
end
function event_player_pickup(e)
    if e.item:GetID() == 85971 and e.self:IsTaskActivityActive(910000,17) then
        e.self:UpdateTaskActivity(910000,17,1)
    end
end
function event_task_stage_complete(e)
    if e.task_id == 910000 and e.self:IsTaskActivityActive(910000,17) and e.self:HasItem(85971) then
        e.self:UpdateTaskActivity(910000,17,1)
    end
end
function event_task_complete(e)
    if e.task_id == 910000 then
        e.self:AddAAPoints(3)
    end
end

local shard_arc = require("shards_partisan")
local shard_previous_event_enter_zone = event_enter_zone
function event_enter_zone(e)
    if shard_previous_event_enter_zone then local old_result=shard_previous_event_enter_zone(e);if old_result and old_result ~= 0 then return old_result end end
    shard_arc.enter(e.self)
end
local shard_previous_event_player_pickup = event_player_pickup
function event_player_pickup(e)
    if shard_previous_event_player_pickup then local old_result=shard_previous_event_player_pickup(e);if old_result and old_result ~= 0 then return old_result end end
    shard_arc.pickup(e)
end
local shard_previous_event_loot = event_loot
function event_loot(e)
    if shard_previous_event_loot then local old_result=shard_previous_event_loot(e);if old_result and old_result ~= 0 then return old_result end end
    shard_arc.loot(e)
end
local shard_previous_event_combine_validate = event_combine_validate
function event_combine_validate(e)
    if shard_previous_event_combine_validate then local old_result=shard_previous_event_combine_validate(e);if old_result and old_result ~= 0 then return old_result end end
    return shard_arc.combine_validate(e)
end
local shard_previous_event_combine_success = event_combine_success
function event_combine_success(e)
    if shard_previous_event_combine_success then local old_result=shard_previous_event_combine_success(e);if old_result and old_result ~= 0 then return old_result end end
    shard_arc.combine_success(e)
end
local shard_previous_event_timer = event_timer
function event_timer(e)
    if shard_previous_event_timer then local old_result=shard_previous_event_timer(e);if old_result and old_result ~= 0 then return old_result end end
    if e.timer == "shard_partisan" then shard_arc.tick(e.self) end
end
local shard_previous_event_task_stage_complete = event_task_stage_complete
function event_task_stage_complete(e)
    if shard_previous_event_task_stage_complete then local old_result=shard_previous_event_task_stage_complete(e);if old_result and old_result ~= 0 then return old_result end end
    shard_arc.stage(e)
end
local shard_previous_event_task_accepted = event_task_accepted
function event_task_accepted(e)
    if shard_previous_event_task_accepted then local old_result=shard_previous_event_task_accepted(e);if old_result and old_result ~= 0 then return old_result end end
    shard_arc.accepted(e)
end
local shard_previous_event_task_complete = event_task_complete
function event_task_complete(e)
    if shard_previous_event_task_complete then local old_result=shard_previous_event_task_complete(e);if old_result and old_result ~= 0 then return old_result end end
    shard_arc.complete(e)
end
local shard_previous_event_click_door = event_click_door
function event_click_door(e)
    if shard_previous_event_click_door then local old_result=shard_previous_event_click_door(e);if old_result and old_result ~= 0 then return old_result end end
    return shard_arc.door(e)
end
