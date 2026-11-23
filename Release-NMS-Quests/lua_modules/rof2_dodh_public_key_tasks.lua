local ids = require("rof2_dodh_public_key_bindings")
local receipt = require("rof2_dodh_scene_receipts").read_one
local runtime = require("rof2_dodh_raid_runtime")
local M = {}
local functionary = 505745
local misty_area = 351108
local misty_pose = {78, 56, -1292, 384}
local misty
local terminal = {library = {1, "01"}, eyes = {3, "02"}, memories = {2, "03"},
                  misty = {4, "04"}, eye_bound = {0, "05"}}
local keys = {
    library = "show the shard of mystical glass",
    eyes = "what special ingredients",
    memories = "memories lost",
    misty = "i am willing to prove it",
    eye_bound = "what lens of bound eyes",
}

local function public(zone)
    local instance = eq.get_zone()
    return instance:GetZoneID() == zone and instance:GetInstanceVersion() == 0 and instance:GetInstanceID() == 0
end

local function say_words(e)
    return e.message:lower():match("^%s*(.-)%s*$"):gsub("[%.%!%?]$", "")
end

local live_run = [[
SELECT st.id
FROM shared_tasks st JOIN shared_task_members sm ON sm.shared_task_id=st.id
WHERE st.id=CAST(? AS UNSIGNED) AND st.task_id=? AND sm.character_id=?
AND st.completion_time IS NULL AND (st.expire_time IS NULL OR st.expire_time>NOW())
]]

local settled = [[
SELECT COUNT(*) FROM kithicor_poison_custody
WHERE shared_task_id=CAST(? AS UNSIGNED) AND recipe_kind=4 AND HEX(recipe_context)=?
AND phase=0 AND chest=0 AND physical=1 AND settled=1 AND abort_only=0
AND (instance_id=0 OR (instance_id=1 AND npc_type_id=25414 AND npc_spawn_id=97602
    AND HEX(recipe_context) IN ('444F4448010504', '444F4448010505')))
]]

local function current(client, task)
    if not task or not client:IsTaskActive(task) then return nil end
    local occurrence = client:GetSharedTaskIdentity()
    if occurrence == "" then return nil end
    local row = receipt(live_run, {occurrence, task, client:CharacterID()})
    if row then return occurrence end
end

local function active(client, key, step)
    local task = ids[key]
    return task and client:IsTaskActivityActive(task, step) and current(client, task)
end

local function acknowledge(client, key)
    local def = terminal[key]
    local run = active(client, key, def[1])
    if not run then return false end
    local saved = receipt(settled, {run, "444F44480105" .. def[2]})
    if saved and tonumber(saved[1]) == 1 then
        client:UpdateTaskActivity(ids[key], def[1], 1)
        return true
    end
    return false
end

local function offer(e, task_key)
    if ids[task_key] then e.other:TaskSelectorFromNPC(e.self, {ids[task_key]}) end
end

local function options(e, list)
    local links = {}
    for _, key in ipairs(list) do
        if ids[key] then links[#links + 1] = eq.say_link(keys[key]) end
    end
    if #links > 0 then e.self:Say("Ask about " .. table.concat(links, " or ") .. ".") end
end

function M.treddle(e)
    if not public(365) or not runtime.actor(e.self, {npc=365284,spawn=103431}) then return false end
    local client, words = e.other, say_words(e)
    if acknowledge(client, "library") or acknowledge(client, "eyes") then return true end
    if active(client, "eyes", 1) and client:CountItem(88017) > 0 then
        client:UpdateTaskActivity(ids.eyes, 1, 1)
    end
    if words == "hail" then options(e, {"library", "eyes"}); return false end
    if words == keys.library and client:CountItem(88006) > 0 then
        offer(e, "library")
        return true
    end
    if words == keys.eyes and client:CountItem(88019) > 0 then
        offer(e, "eyes")
        return true
    end
    return false
end

function M.doorman(e)
    if not public(351) or not runtime.actor(e.self, {npc=351108,spawn=101696}) then return end
    if acknowledge(e.other, "memories") then return end
    local words = say_words(e)
    if words == "hail" then
        options(e, {"memories"})
    elseif words == keys.memories then
        offer(e, "memories")
    end
end

local functionary_receipts = [[
SELECT COUNT(DISTINCT SUBSTRING(j.recipe_context,7,1)), MAX(COALESCE(a.donecount,0))
FROM character_tasks t
JOIN kithicor_poison_custody j ON j.character_id=t.charid AND j.account_id=?
LEFT JOIN character_activities a ON a.charid=t.charid AND a.taskid=t.taskid AND a.activityid=?
WHERE t.charid=? AND t.taskid=505745 AND t.type=0 AND t.acceptedtime>0
AND j.recipe_kind=4 AND j.phase=0 AND j.chest=0 AND j.instance_id=0 AND j.shared_task_id=0
AND j.physical=1 AND j.settled=1 AND j.abort_only=0
AND LEFT(j.recipe_context,6)=X'444F44480107'
AND CAST(SUBSTRING(j.recipe_context,8) AS CHAR)=CAST(t.acceptedtime AS CHAR)
AND ORD(SUBSTRING(j.recipe_context,7,1)) BETWEEN ? AND ?
]]

local function reconcile_functionary(client)
    for _, stage in ipairs({{1,1,4},{2,5,5},{3,6,6}}) do
        if client:IsTaskActivityActive(functionary,stage[1]) then
            local row = receipt(functionary_receipts, {client:AccountID(),stage[1],client:CharacterID(),stage[2],stage[3]})
            local done = row and tonumber(row[1]) or 0
            local recorded = row and tonumber(row[2]) or 0
            if done > recorded then
                client:UpdateTaskActivity(functionary,stage[1],done-recorded)
                return true
            end
            return false
        end
    end
    return false
end

function M.orc(e)
    if not public(351) or not runtime.actor(e.self, {npc=351012,spawn=101410}) then return end
    if reconcile_functionary(e.other) then return end
    local words = say_words(e)
    if (words == "hail" or words == "shiny things" or words == "what do you know about a necklace")
        and e.other:IsTaskActivityActive(functionary,2) then
        e.self:Say("Two hundred and forty platinum, and the necklace is yours.")
    end
end

function M.route(e)
    if not public(351) then return 0 end
    local door, client = e.door, e.self
    local db_id, slot = door:GetDoorDBID(), door:GetDoorID()
    if db_id == 16260 and slot == 22 then
        if client:CountItem(88042) > 0 or client:KeyRingCheck(88042) then
            client:KeyRingAdd(88042)
            door:ForceOpen(client)
        else
            client:Message(MT.Yellow, "The hidden crypt door requires the Dreadspire Crest.")
        end
        return 1
    end
    -- The two study-door regions sit on disconnected collision components.
    -- Traverse to their floor-checked sides only as the keyed player.
    if ids.memories and ((db_id == 16247 and slot == 9) or (db_id == 16248 and slot == 10)) then
        if not client:IsTaskCompleted(ids.memories) then return 1 end
        if slot == 9 then
            client:MovePCInstance(351,0,70,56,-1292,384)
        else
            client:MovePCInstance(351,0,-84.694,-0.57,-1100,128)
        end
        return 1
    end
    return 0
end

function M.functionary(e)
    if not public(351) or not runtime.actor(e.self, {npc=351107,spawn=101695}) then return end
    if reconcile_functionary(e.other) then return end
    local words = say_words(e)
    if words == "hail" then e.self:Say("If you can assist with the " .. eq.say_link("errands") .. ", please do.")
    elseif words == "errands" then e.other:TaskSelectorFromNPC(e.self, {functionary}) end
end

function M.cataloguer(e)
    local client, words = e.other, say_words(e)
    if not public(351) or not runtime.actor(e.self, {npc=351096,spawn=101651})
        or not current(client, ids.library) or not client:IsTaskCompleted(functionary) then return end
    if acknowledge(client, "library") then return end
    if words == "hail" then
        e.self:Say("Tell me " .. eq.say_link("I seek a study of mystical vision") .. ".")
    elseif words == "i seek a study of mystical vision" then
        if client:CountItem(88007) == 0 then
            if client:GetItemIDAt(Slot.Cursor) > 0 then return end
            client:SummonItem(88007, 1)
        end
        if client:CountItem(88007) > 0 and client:IsTaskActivityActive(ids.library, 0) then
            client:UpdateTaskActivity(ids.library, 0, 1)
        end
    end
end

function M.coldwind(e)
    local zone = eq.get_zone()
    if zone:GetZoneID() ~= 25 then return end
    local version, instance = zone:GetInstanceVersion(), zone:GetInstanceID()
    if version == 0 and instance == 0 then
        if not runtime.actor(e.self, {npc=ids.coldwind_npc,spawn=ids.coldwind_spawn}) then return end
    elseif version == 1 and instance == 1 then
        if not runtime.actor(e.self, {npc=25414,spawn=97602}) then return end
    else
        return
    end
    local client, words = e.other, say_words(e)
    if acknowledge(client, "misty") or acknowledge(client, "eye_bound") then return end
    if words == "hail" then
        options(e, {"misty", "eye_bound"})
    elseif words == keys.misty and ids.memories and client:IsTaskCompleted(ids.memories) and client:CountItem(88020) > 0 then
        offer(e, "misty")
    elseif words == keys.eye_bound and client:CountItem(88021) > 0 then
        offer(e, "eye_bound")
    end
end

function M.combine(e)
    if public(351) and ids.slurry_recipe and e.recipe_id == ids.slurry_recipe
        and active(e.self, "eyes", 1) and e.self:CountItem(88017) > 0 then
        e.self:UpdateTaskActivity(ids.eyes, 1, 1)
    end
end

function M.enter()
    if not public(351) then return end
    eq.load_encounter("rof2_dodh_public_key_events")
end

function M.load(e)
    eq.add_area(misty_area, 1, 67, 92, 42, 71, -1301, -1284)
    if ids.misty_npc then
        eq.register_npc_event(Event.say, ids.misty_npc, M.misty_say)
        eq.register_npc_event(Event.damage_taken, ids.misty_npc, M.misty_damage)
    end
    eq.set_timer("dodh_misty", 1000, e.encounter)
end

local function spawn_misty(occurrence)
    if misty then return end
    local marker = "DODH:MISTY:" .. occurrence
    local npc = runtime.spawn_owned(ids.misty_npc, misty_pose, marker)
    if not npc then return end
    npc:ModifyNPCStat("max_hit", "4000")
    runtime.protect(npc, true)
    misty = {npc=npc, id=npc:GetID(), marker=marker, run=occurrence, expires=os.time()+720}
end

function M.area(e)
    if e.area_id ~= misty_area or not public(351) or not ids.misty_npc
        or not ids.memories or not e.self:IsTaskCompleted(ids.memories) then return end
    local run = current(e.self, ids.misty)
    if not run then return end
    if e.self:IsTaskActivityActive(ids.misty, 0) then e.self:UpdateTaskActivity(ids.misty, 0, 1) end
    if e.self:IsTaskActivityActive(ids.misty, 1) or e.self:IsTaskActivityActive(ids.misty, 2)
        or e.self:IsTaskActivityActive(ids.misty, 3) then
        spawn_misty(run)
        if misty and misty.run == run and e.self:IsTaskActivityActive(ids.misty, 1) then
            e.self:UpdateTaskActivity(ids.misty, 1, 1)
        end
    end
end

local function owns(npc, event_id)
    return misty and npc and npc.valid and npc:GetNPCTypeID() == ids.misty_npc
        and event_id == misty.id and npc:GetEntityVariable("dodh_raid:occurrence") == misty.marker
end

function M.misty_say(e)
    if not owns(e.self,e.self:GetID()) or current(e.other, ids.misty) ~= misty.run or misty.fight then return end
    local words = say_words(e)
    if words == "hail" then
        e.self:Say("Will you leave, or do you mean " .. eq.say_link("we will stay here") .. "?")
    elseif words == "we will stay here" and (e.other:IsTaskActivityActive(ids.misty, 2) or e.other:IsTaskActivityActive(ids.misty, 3)) then
        if e.other:IsTaskActivityActive(ids.misty, 2) then e.other:UpdateTaskActivity(ids.misty, 2, 1) end
        misty.fight, misty.cast_at = true, os.time()+23
        runtime.protect(e.self, false)
        e.self:SetSpecialAbility(3, 1)
        e.self:SetSpecialAbility(5, 1)
        e.self:AddToHateList(e.other, 1, 0)
    end
end

function M.misty_damage(e)
    if not owns(e.self, e.self:GetID()) then return 0 end
    local player = runtime.owner(e.other)
    if not misty.fight or not player or current(player, ids.misty) ~= misty.run then return -1 end
    if e.damage >= e.self:GetHP() and not player:IsTaskActivityActive(ids.misty, 3) then return -1 end
    return 0
end

function M.tick(e)
    if e.timer ~= "dodh_misty" then return end
    for player in eq.get_entity_list():GetClientList().entries do
        local x, y, z = player:GetX(), player:GetY(), player:GetZ()
        if x >= 67 and x <= 92 and y >= 42 and y <= 71 and z >= -1301 and z <= -1284 and player:GetHP() > 0
            and ids.misty and (player:IsTaskActivityActive(ids.misty,0) or player:IsTaskActivityActive(ids.misty,1)) then
            M.area({self=player, area_id=misty_area})
        end
    end
    if not misty then return end
    if not misty.npc.valid or os.time() >= misty.expires then
        if misty.npc.valid then misty.npc:Depop(false) end
        misty = nil
        return
    end
    if misty.fight and os.time() >= misty.cast_at then
        local target = misty.npc:GetHateTop()
        if target.valid then misty.npc:CastSpell(7162, target:GetID()) end
        misty.cast_at = os.time()+32
    end
end

function M.death(e)
    if not owns(e.killed,e.killed_entity_id) then return end
    local killer = runtime.owner(e.other)
    local corpse = runtime.corpse(e)
    if misty.fight and killer and current(killer, ids.misty) == misty.run
        and killer:IsTaskActivityActive(ids.misty, 3) and corpse then
        corpse:SetEntityVariable("dodh_public:misty_run", misty.run)
        corpse:AddItem(88022, 1)
        corpse:ResetDecayTimer()
        killer:UpdateTaskActivity(ids.misty, 3, 1)
    end
    misty = nil
end

function M.loot(e)
    if not e.corpse or not e.corpse.valid or not e.item or not e.item.valid or e.item:GetID() ~= 88022 then return 0 end
    local run = e.corpse:GetEntityVariable("dodh_public:misty_run")
    if run == "" then return 0 end
    return current(e.other, ids.misty) == run and 0 or 1
end

return M
