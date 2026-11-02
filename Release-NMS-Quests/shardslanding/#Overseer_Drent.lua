-- EQQuests 5978; server item 85971, task 910000. Allakhazam IDs are not server IDs.
function event_say(e)
    if e.message:lower():find("hail", 1, true) then
        if e.other:GetLevel() < 85 then
            e.self:Say("Return when you have reached level 85. These hills are dangerous.")
        elseif not e.other:IsTaskActive(910000) and not e.other:IsTaskCompleted(910000) then
            e.other:AssignTask(910000, e.self:GetID())
            e.self:Say("Welcome to the outpost. Explore our camp, speak with me and Master Hunter Jilare, then survey the landing.")
        elseif e.other:IsTaskCompleted(910000) then
            e.self:Say("You have earned our welcome. Master Hunter Jilare has further work for you.")
        else
            e.self:Say("Follow your survey objectives. If you find anything unusual in the Silent Hall, bring it to me.")
        end
    end
end

function event_trade(e)
    local item_lib = require("items")
    -- Native Deliver marks the matching instance before EVENT_TRADE. Consume only that shard.
    for slot = 1, 4 do
        local item = e.trade["item" .. slot]
        if item and item.valid and item:GetID() == 85971 and item:GetTaskDeliveredCount() > 0 then
            item_lib.check_turn_in(e.trade, {item1 = 85971})
            break
        end
    end
    item_lib.return_items(e.self, e.other, e.trade)
end

local shard_arc = require("shards_partisan")
local shard_previous_event_say = event_say
function event_say(e)
    if shard_previous_event_say then local old_result=shard_previous_event_say(e);if old_result and old_result ~= 0 then return old_result end end
    shard_arc.say(e)
end
