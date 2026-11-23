local receipt = require("rof2_dodh_scene_receipts").read_one
local M = {}
local blockers = {
    redfang = { npc = 351015, spawn = 101429, code = "01",
        offering = "Bring me the Congealed Blood of Redfang and we can speak of the Master.",
        choices = {"strength", "beauty", "control or destroy", "mere accident"} },
    graniteclaw = { npc = 351030, spawn = 101475, code = "02",
        offering = "Show me the Rune-Etched Stone. Its marks will tell me what you have seen.",
        choices = {"furious", "sorrowful", "disgusted", "apathetic"} },
    hatchet = { npc = 351072, spawn = 101584, code = "03",
        offering = "Bring Ur-Koraag the Shrunken Head, and I will tell you how they treat the living here.",
        choices = {"mortals is food", "forget", "superiority", "angry"} },
    sisters = { npc = 351087, spawn = 101623, code = "04",
        offering = "If one of the sisters left you her handkerchief, let me see it.",
        choices = {"glimpse into the future", "grew tired", "killed her ability to love", "feared retribution"} },
}

local sql = [[
SELECT COUNT(DISTINCT HEX(recipe_context))
FROM kithicor_poison_custody
WHERE character_id=? AND account_id=? AND recipe_kind=4
AND recipe_context IN (X'444F4448010601',X'444F4448010602',X'444F4448010603',X'444F4448010604')
AND shared_task_id=0 AND instance_id=0 AND phase=0 AND chest=0
AND physical=1 AND settled=1 AND abort_only=0
AND (npc_type_id,npc_spawn_id,HEX(recipe_context)) IN (
 (351015,101429,'444F4448010601'),(351030,101475,'444F4448010602'),
 (351072,101584,'444F4448010603'),(351087,101623,'444F4448010604'))
]]
local single = sql .. " AND HEX(recipe_context)=?"

function M.count(client)
    local count = receipt(sql, {client:CharacterID(), client:AccountID()})
    return count and tonumber(count[1]) or 0
end

function M.has(client, name)
    local def = blockers[name]
    if not def then return false end
    local owned = receipt(single, {client:CharacterID(), client:AccountID(), "444F44480106" .. def.code})
    return owned and tonumber(owned[1]) == 1
end

function M.say(e, name)
    local def, npc, client = blockers[name], e.self, e.other
    local zone = eq.get_zone()
    if zone:GetZoneID() ~= 351 or zone:GetInstanceVersion() ~= 0 or zone:GetInstanceID() ~= 0
        or npc:GetNPCTypeID() ~= def.npc or npc:GetSpawnPointID() ~= def.spawn then return false end
    local words = e.message:lower():match("^%s*(.-)%s*$")
    if words == "hail" then
        if M.has(client, name) then
            local choices = {}
            for index, choice in ipairs(def.choices) do choices[index] = eq.say_link(choice) end
            npc:Say("Your offering was accepted. What say you of " .. table.concat(choices, ", ") .. "?")
        else
            npc:Say(def.offering)
        end
        return true
    end
    for _, choice in ipairs(def.choices) do
        if words == choice then
            if M.has(client, name) then
                local key = "dodh_demi:answer:" .. name
                client:SetBucket(key, choice)
                if client:GetBucket(key) == choice then npc:Say("Your answer will be judged.") end
            else
                npc:Say(def.offering)
            end
            return true
        end
    end
    return false
end

return M
