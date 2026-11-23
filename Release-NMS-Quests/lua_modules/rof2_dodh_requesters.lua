local read_one = require("rof2_dodh_scene_receipts").read_one
local travel = require("rof2_dodh_requester_travel")
local M = {}

local requesters = {
    [365284] = { spawn = 103431, zone = 365, taskset = 22 },
    [362117] = { spawn = 102626, zone = 362, taskset = 23 },
    [365268] = { spawn = 103397, zone = 365, taskset = 24 },
    [365274] = { spawn = 103413, zone = 365 },
}

local opener_sql = [[
SELECT EXISTS (
    SELECT 1
    FROM group_id requester
    JOIN group_id member ON member.group_id = requester.group_id
    JOIN character_data c ON c.id = member.character_id
    JOIN dodh_brovil_receipts receipt ON receipt.character_id = c.id
    WHERE requester.character_id = ? AND requester.group_id > 0
      AND requester.bot_id = 0 AND requester.merc_id = 0
      AND member.bot_id = 0 AND member.merc_id = 0
)
]]

local brovil_offers = {
    { task = 920228, phrase = "check" },
    { task = 920230, phrase = "gather" },
    { task = 920232, phrase = "start" },
    { task = 920234, phrase = "way to him" },
}

local function brovil_tasks(client, message)
    local tasks = {}
    local prerequisites_met = true
    for index, offer in ipairs(brovil_offers) do
        if not prerequisites_met then break end
        if message == "hail" or message == offer.phrase then
            local eligible = true
            if index == 1 then
                local receipt = read_one(opener_sql, {client:CharacterID()})
                eligible = receipt and tonumber(receipt[1]) == 1
            end
            if eligible then tasks[#tasks + 1] = offer.task end
        end
        prerequisites_met = client:IsTaskCompleted(offer.task)
    end
    return tasks
end

function M.say(event)
    local client, npc, zone = event.other, event.self, eq.get_zone()
    if not client or not client.valid then return end
    local route = requesters[npc:GetNPCTypeID()]
    if not route or npc:GetSpawnPointID() ~= route.spawn or zone:GetZoneID() ~= route.zone
        or zone:GetInstanceID() ~= 0 or zone:GetInstanceVersion() ~= 0 then return end

    local message = event.message:lower():match("^%s*(.-)%s*$")
    if message == "directions" then
        travel.say(event)
        return
    end
    if route.taskset then
        if message == "hail" then eq.task_set_selector(route.taskset) end
        return
    end

    local tasks = brovil_tasks(client, message)
    if #tasks > 0 then
        eq.task_selector(tasks)
    elseif message == "hail" or message == "check" then
        npc:Say("Bring the Torn Notebook to Model XG CVIII before asking about the lost notebook.")
    end
end

return M
