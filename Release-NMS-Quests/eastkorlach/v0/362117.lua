local requesters = require("rof2_dodh_requesters")
local read_one = require("rof2_dodh_scene_receipts").read_one

local task_id = 920224
local shoulder_guard = 86018
local requester_acceptance_sql = [[
SELECT st.id
FROM shared_tasks st
JOIN shared_task_members sm ON sm.shared_task_id = st.id
JOIN character_tasks ct ON ct.charid = sm.character_id
WHERE sm.character_id = ? AND sm.is_leader = 1
  AND st.task_id = 920224 AND st.completion_time IS NULL AND st.expire_time > NOW()
  AND ct.taskid = st.task_id AND ct.type = 1 AND ct.slot = 0
  AND ct.acceptedtime = UNIX_TIMESTAMP(st.accepted_time)
LIMIT 2
]]

local function is_public_zahn(npc)
    local zone = eq.get_zone()
    return npc:GetNPCTypeID() == 362117 and npc:GetSpawnPointID() == 102626
        and zone:GetZoneID() == 362 and zone:GetInstanceID() == 0 and zone:GetInstanceVersion() == 0
end

function event_say(e)
    if e.message:lower():match("^%s*group%s*$") then
        if is_public_zahn(e.self) then
            eq.task_set_selector(23)
        end
        return
    end
    requesters.say(e)
end

function event_task_accepted(e)
    local requester = e.other
    if e.task_id ~= task_id or not is_public_zahn(e.self)
        or not requester or not requester.valid or not requester:IsTaskActive(task_id) then
        return
    end
    -- World gives the NPC context only to the original requester.
    if read_one(requester_acceptance_sql, {requester:CharacterID()}) then
        requester:SummonItem(shoulder_guard)
    end
end
