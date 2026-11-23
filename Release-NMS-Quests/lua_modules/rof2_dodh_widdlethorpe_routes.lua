local receipts = require("rof2_dodh_scene_receipts")
local M = {}
M.versions = { [1] = 920277, [4] = 920276, [5] = 920278, [6] = 920275 }
M.landing = {-57, 197, 43, 0}
M.outside = {-1020, 872, -65, 0}
local entrance = 920275
local missions = {{920275, 6, 5}, {920276, 4, 5}, {920277, 1, 6}, {920278, 5, 3}}
local prior = [[
SELECT 1 FROM completed_shared_tasks t
JOIN completed_shared_task_members m ON m.shared_task_id=t.id
WHERE t.task_id=? AND m.character_id=? AND t.completion_time IS NOT NULL LIMIT 1
]]

local function public()
    local zone = eq.get_zone()
    return zone:GetZoneID() == 358 and zone:GetInstanceVersion() == 0 and zone:GetInstanceID() == 0
end

local function requester(e)
    local c, npc = e.other, e.self
    if public() and c and c.valid and npc:GetNPCTypeID() == 358051
        and npc:GetSpawnPointID() == 101854 and c:CalculateDistance(npc) <= 35 then return c end
end

local function give_coral(c)
    if c:IsTaskActive(920276) and c:GetSharedTaskInstanceID(920276, 361, 4) > 0
        and not c:IsTaskActivityActive(920276, 3) and not c:IsTaskActivityActive(920276, 4)
        and not c:IsTaskActivityActive(920276, 5) and c:CountItem(85025) == 0 then
        c:SummonItem(85025, 3)
    end
end

function M.accepted(e)
    local c = requester(e)
    if c and e.task_id == 920276 then give_coral(c) end
end

function M.say(e)
    local c = requester(e)
    if not c then return end
    local npc = e.self
    local words = e.message:lower():match("^%s*(.-)%s*$"):gsub("[%.!]$", "")
    if words == "we will practice on something smaller" then
        give_coral(c)
        return
    end
    if words ~= "hail" then return end
    for _, mission in ipairs(missions) do
        if c:IsTaskActive(mission[1]) then
            if c:IsTaskActivityActive(920276, 5) then
                c:UpdateTaskActivity(920276, 5, 1)
            elseif c:IsTaskActivityActive(920278, 3) then
                c:UpdateTaskActivity(920278, 3, 1)
            elseif mission[1] == 920276 and c:CountItem(85025) == 0 then
                npc:Say("If you need a coral, say " .. eq.say_link("we will practice on something smaller") .. ".")
            end
            return
        end
    end
    local offered = {}
    for _, mission in ipairs(missions) do
        offered[#offered + 1] = mission[1]
        if not receipts.read_one(prior, {mission[1], c:CharacterID()}) then break end
    end
    eq.task_selector(offered)
end

function M.load()
    if public() then eq.load_encounter("rof2_dodh_widdlethorpe_entrance") end
end

function M.entrance()
    if public() then eq.add_area(entrance, 1, -1042, -1024, 881, 899, -81, -63) end
end

function M.area(e)
    if not public() or e.area_id ~= entrance then return end
    local c = e.self
    for _, mission in ipairs(missions) do
        local task, v, terminal = mission[1], mission[2], mission[3]
        if c:IsTaskActive(task) and not c:IsTaskActivityActive(task, terminal)
            and not (task == 920277 and (c:IsTaskActivityActive(task, 4) or c:IsTaskActivityActive(task, 5))) then
            local instance = c:GetSharedTaskInstanceID(task, 361, v)
            if instance > 0 then
                local p = M.landing
                c:MovePCInstance(361, instance, p[1], p[2], p[3], p[4])
                return
            end
        end
    end
end

return M
