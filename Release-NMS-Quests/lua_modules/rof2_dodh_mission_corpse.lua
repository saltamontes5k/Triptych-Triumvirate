local M = {}

local notebook = { task = 920228, zone_id = 354, version = 4, first_item = 84041, last_item = 84049 }
local botany = { task = 920230, zone_id = 366, version = 2, first_item = 84063, last_item = 84067 }
local clues = { task = 920232, zone_id = 355, version = 3 }
local corpse_marker = "rof2_dodh_mission_corpse"
local final_actor_marker = "rof2_dodh_clues_final_run"
local outstanding
local sequence = 0

local function member_run(member, binding)
    if not member or not member.valid or not member:IsTaskActive(binding.task) then
        return nil
    end
    local zone = eq.get_zone()
    local instance = zone:GetInstanceID()
    if instance == 0 or zone:GetZoneID() ~= binding.zone_id
        or zone:GetInstanceVersion() ~= binding.version
        or member:GetSharedTaskInstanceID(binding.task, binding.zone_id, binding.version) ~= instance then
        return nil
    end
    local occurrence = member:GetSharedTaskIdentity()
    if type(occurrence) ~= "string" or occurrence == "" then
        return nil
    end
    return instance .. ":" .. occurrence
end

local function death_context(event, binding)
    local npc, corpse, source = event.killed, event.corpse, event.other
    if not npc or not npc.valid or not corpse or not corpse.valid
        or not corpse:IsNPCCorpse() or corpse:GetID() == 0
        or corpse:GetID() ~= event.killed_entity_id
        or not source or not source.valid or not source:IsClient() then
        return nil
    end
    if corpse:GetEntityVariable(corpse_marker) ~= "" then
        return nil
    end
    local member = source:CastToClient()
    return member_run(member, binding), member, npc, corpse
end

local function first_active_item(member, binding)
    for item = binding.first_item, binding.last_item do
        if member:IsTaskActivityActive(binding.task, item - binding.first_item + 1) then
            return item
        end
    end
end

local function same_item_still_available(run, item)
    if not outstanding or outstanding.run ~= run or outstanding.item ~= item then
        return false
    end
    local corpse = eq.get_entity_list():GetCorpseByID(outstanding.id)
    return corpse.valid and corpse:GetEntityVariable(corpse_marker) == outstanding.marker
        and corpse:CountItem(item) > 0
end

local function add_item(corpse, run, item)
    if corpse:CountItem(item) ~= 0 then
        return nil
    end
    corpse:AddItem(item, 1)
    if corpse:CountItem(item) ~= 1 then
        return nil
    end
    -- The native constructor chose its decay time before this quest added loot.
    corpse:ResetDecayTimer()
    sequence = sequence + 1
    local marker = run .. ":" .. sequence
    corpse:SetEntityVariable(corpse_marker, marker)
    return marker
end

local function collection_death(event, binding, eligible)
    local run, member, npc, corpse = death_context(event, binding)
    if not run or npc:GetSpawnPointID() <= 0 or not eligible(npc:GetNPCTypeID()) then
        return
    end
    local item = first_active_item(member, binding)
    if not item or same_item_still_available(run, item) then
        return
    end

    -- Only native loot can advance the objective. Availability and the
    -- acknowledged activity are re-read before selecting another item.
    local marker = add_item(corpse, run, item)
    if marker then
        outstanding = { run = run, item = item, id = corpse:GetID(), marker = marker }
    end
end

function M.notebook_death(event)
    collection_death(event, notebook, function(npc_type)
        return npc_type >= 354249 and npc_type <= 354303 and npc_type ~= 354266
    end)
end

function M.botany_death(event)
    collection_death(event, botany, function(npc_type)
        return npc_type >= 366030 and npc_type <= 366037
    end)
end

local function is_bound_wicyl(npc)
    return npc:GetNPCTypeID() == 355123 and npc:GetSpawnPointID() == 261934
end

-- Call only after the encounter controller has confirmed its final phase.
-- The marker belongs to this actor generation and the current shared occurrence.
function M.arm_clues_final(member, npc)
    local run = member_run(member, clues)
    if not run or not npc or not npc.valid or not is_bound_wicyl(npc)
        or not member:IsTaskActivityActive(clues.task, 1) then
        return false
    end
    npc:SetEntityVariable(final_actor_marker, run)
    return true
end

function M.clues_death(event)
    local run, member, npc, corpse = death_context(event, clues)
    if not run or not is_bound_wicyl(npc)
        or npc:GetEntityVariable(final_actor_marker) ~= run
        or not member:IsTaskActivityActive(clues.task, 1) then
        return
    end
    if add_item(corpse, run, 84061) then
        member:UpdateTaskActivity(clues.task, 1, 1)
    end
end

return M
