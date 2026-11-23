local read_one = require("rof2_dodh_scene_receipts").read_one
local M = {}

local kelliad = { zone = 358, npc = 358020, spawn = 101765 }
local jarzarrad = { zone = 362, npc = 362092, spawn = 102581 }
local prior_sql = [[
SELECT DISTINCT st.task_id
FROM completed_shared_tasks st
JOIN completed_shared_task_members member ON member.shared_task_id = st.id
WHERE member.character_id = ? AND st.completion_time IS NOT NULL
  AND st.task_id = ?
LIMIT 1
]]

local function actor_matches(npc, actor)
    local zone = eq.get_zone()
    return npc:GetNPCTypeID() == actor.npc and npc:GetSpawnPointID() == actor.spawn
        and zone:GetZoneID() == actor.zone and zone:GetInstanceVersion() == 0
        and zone:GetInstanceID() == 0
end

local function phrase(message)
    return message:lower():match("^%s*(.-)%s*$")
end

function M.kelliad(event)
    local player, npc = event.other, event.self
    if not player or not player.valid or not actor_matches(npc, kelliad) then return end
    local request = phrase(event.message)
    if request ~= "hail" and request ~= "trust me" then return end
    local minimum = tonumber(eq.get_rule("Faction:ApprehensivelyFactionMinimum"))
    local tasks = {920237, 920238, 920239, 920240}
    if minimum and player:GetModCharacterFactionLevel(1055) >= minimum then
        table.insert(tasks, 1, 920236)
    end
    eq.task_selector(tasks)
end

function M.jarzarrad(event)
    local player, npc = event.other, event.self
    if not player or not player.valid or not actor_matches(npc, jarzarrad) then return end
    local request = phrase(event.message)
    if request ~= "hail" and request ~= "i am ready" and request ~= "i am ready." then return end
    local tasks = {920241}
    for prior = 920241, 920244 do
        if not read_one(prior_sql, {player:CharacterID(), prior}) then break end
        tasks[#tasks + 1] = prior + 1
    end
    eq.task_selector(tasks)
end

return M
