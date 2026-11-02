-- Quest-owned NPC behaviour. Native task events own achievement progression.
local M = {}
local data = require("achievement_quest_crescent_data")

local function active(id) return eq.is_task_active(id) end
-- lua_is_task_completed returns an int, unlike the bool active/stage APIs.
-- In Lua, numeric zero is truthy, so normalize the bridge explicitly.
local function done(id)
    local value=eq.is_task_completed(id)
    return value==1 or value==true
end
local function stage(id, index) return eq.is_task_activity_active(id, index) end
local function has(client, id) return client:CountItem(id) > 0 end
local function give_missing(client, items)
    for _, id in ipairs(items or {}) do
        if not has(client, id) then client:SummonItem(id, (data.item_charges or {})[tostring(id)] or 1) end
    end
end
local function eligible(task)
    for _, id in ipairs(task.prerequisites or {}) do
        if not done(id) then return false end
    end
    return not active(task.id) and (task.repeatable == 1 or not done(task.id))
end
local function contains(text, keywords)
    for _, word in ipairs(keywords or {}) do
        if text:find(word, 1, true) then return true end
    end
    return false
end

function M.accepted(e)
    for _, rule in ipairs(data.question_chains or {}) do
        if rule.task == e.task_id then e.other:DeleteBucket(rule.bucket) end
    end
    for _, task in ipairs(data.tasks) do
        if task.id == e.task_id and active(task.id) then
            give_missing(e.other, task.start_items)
            return
        end
    end
end

function M.say(e)
    local npc = e.self:GetNPCTypeID()
    local text = e.message:lower()
    for _, rule in ipairs(data.question_chains or {}) do
        if rule.npc == npc and active(rule.task) and stage(rule.task, rule.stage) then
            local ready = true
            for _, item in ipairs(rule.requires_items or {}) do
                if not has(e.other, item) then ready = false end
            end
            if rule.requires_see_invisible and e.other:SeeInvisible() < 1 then ready = false end
            if not ready then e.self:Say(rule.missing_text); return end
            local index = tonumber(e.other:GetBucket(rule.bucket)) or 1
            if index < 1 or index > #rule.questions then index = 1 end
            local question = rule.questions[index]
            if text:find(question.answer, 1, true) then
                if index == #rule.questions then
                    e.other:DeleteBucket(rule.bucket)
                    eq.update_task_activity(rule.task, rule.stage, 1)
                    e.self:Say("You have studied well. Carry this knowledge with you.")
                else
                    e.other:SetBucket(rule.bucket, tostring(index + 1))
                    e.self:Say(rule.questions[index + 1].prompt)
                end
            elseif text:find("hail", 1, true) or text:find("question", 1, true) or text:find("ready", 1, true) then
                e.self:Say(question.prompt)
            else
                e.other:DeleteBucket(rule.bucket)
                e.self:Say("Study the works again. " .. rule.questions[1].prompt)
            end
            return
        end
    end

    for _, rule in ipairs(data.custom_dialogue or {}) do
        if rule.npc == npc and active(rule.task) then
            if stage(rule.task, rule.stage) and text:find(rule.keyword, 1, true) then
                if not rule.requires_item or has(e.other, rule.requires_item) then
                    eq.update_task_activity(rule.task, rule.stage, 1)
                    give_missing(e.other, rule.items)
                    e.self:Say(rule.text)
                    return
                end
            elseif (stage(rule.task, 1) or stage(rule.task, 2)) and
                   contains(text, {"hail", "supplies", rule.keyword}) then
                give_missing(e.other, rule.items)
                if rule.reissue_input then give_missing(e.other,{rule.reissue_input}) end
                e.self:Say(rule.text)
                return
            end
        end
    end

    for _, rule in ipairs(data.supply_dialogue or {}) do
        if rule.npc == npc and active(rule.task) then
            local in_stage = stage(rule.task, rule.active_stage)
            if rule.stage_was_completed then
                in_stage = eq.get_task_activity_done_count(rule.task, rule.active_stage) > 0
            end
            if rule.next_stage then in_stage = in_stage or stage(rule.task, rule.next_stage) end
            -- NPC EVENT_SAY runs before native SpeakWith progression in this core.
            if rule.before_speak_stage then in_stage = in_stage or stage(rule.task,rule.before_speak_stage) end
            if rule.unless_done_stage and
               eq.get_task_activity_done_count(rule.task, rule.unless_done_stage) > 0 then
                in_stage = false
            end
            if in_stage and contains(text, {"hail", "supplies", "materials"}) then
                if not rule.output_item or not has(e.other, rule.output_item) then
                    give_missing(e.other, rule.items)
                end
                e.self:Say(rule.text)
                return
            end
        end
    end

    for _, rule in ipairs(data.dialogue or {}) do
        if rule.npc == npc and contains(text, rule.keywords) then
            e.self:Say(rule.text)
            return
        end
    end

    -- Reissue the zero-value intermediate banner if a player lost it while the
    -- actual native task is already waiting for its final delivery.
    if npc == 394114 and active(6022) and stage(6022, 3) and
       contains(text, {"hail", "supplies", "banner"}) then
        give_missing(e.other, {84230})
        e.self:Say("Bring the completed banner to a councilmember.")
        return
    end

    -- A lost quest parcel can be reissued only before its delivery. Ownership
    -- is checked to avoid filling the cursor with duplicate quest items.
    for _, task in ipairs(data.tasks) do
        if task.giver == npc and active(task.id) and stage(task.id, 0) and
           contains(text, {"hail", "supplies", "replacement"}) then
            give_missing(e.other, task.start_items)
        end
    end

    for _, task in ipairs(data.tasks) do
        if task.giver == npc and eligible(task) and contains(text, task.keywords) then
            eq.assign_task(task.id)
            if active(task.id) then
                give_missing(e.other, task.start_items)
                e.self:Say(task.description or "Follow the task instructions to show your allegiance to the city.")
            end
            return
        end
    end
    if text:find("hail", 1, true) then
        local offered = false
        for _, task in ipairs(data.tasks) do
            if task.giver == npc and eligible(task) then
                local words = task.keywords
                e.self:Say("I can guide you through " .. task.title .. ". Ask me about " .. eq.say_link(words[#words]) .. ".")
                offered = true
            end
        end
        if not offered then
            for _, task in ipairs(data.tasks) do
                if task.giver == npc then
                    for _, prerequisite in ipairs(task.prerequisites or {}) do
                        if not done(prerequisite) then
                            e.self:Say("Complete the earlier task in this quest chain before beginning " .. task.title .. ".")
                            return
                        end
                    end
                end
            end
        end
    end
end

function M.trade(e)
    local handin, required, items, delivered = {}, {}, {}, {}
    for i = 1, 4 do
        local inst = e.trade["item" .. i]
        if inst and inst.valid then
            items[#items + 1] = inst
            local id = inst:GetID()
            local count = inst:IsStackable() and inst:GetCharges() or 1
            handin[tostring(id)] = (handin[tostring(id)] or 0) + count
            local used = inst:GetTaskDeliveredCount()
            if used > 0 then
                required[tostring(id)] = (required[tostring(id)] or 0) + used
                delivered[id] = (delivered[id] or 0) + used
            end
        end
    end
    for _, coin in ipairs({"copper", "silver", "gold", "platinum"}) do
        if (e.trade[coin] or 0) > 0 then handin[coin] = e.trade[coin] end
    end
    if next(required) and e.self:CheckHandin(e.other, handin, required, items) then
        for _, rule in ipairs(data.intermediate_turnins or {}) do
            if rule.npc == e.self:GetNPCTypeID() and (delivered[rule.item] or 0) > 0 then
                give_missing(e.other, {rule.result})
                e.self:Say(rule.text)
            end
        end
    end
    e.self:ReturnHandinItems(e.other)
end

return M
