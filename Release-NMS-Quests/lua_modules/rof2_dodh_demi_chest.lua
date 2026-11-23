local admission = require("rof2_dodh_demi_admission")
local progress = require("rof2_dodh_raid_progress")
local runtime = require("rof2_dodh_raid_runtime")
local rewards = require("rof2_dodh_demi_rewards")
local M = {}
local outstanding = {}
local standard_chest = 303120
local expiry = 5 * 24 * 60 * 60

function M.prepare(dz, event, point, chest_type)
    local reward = rewards[event]
    if not reward or not dz or not dz.valid then return nil end
    local mark = dz:GetUUID() .. ":" .. event
    local npc = runtime.spawn_owned(chest_type or standard_chest, point, mark)
    if not npc then return nil end
    npc:SetLDoNTrapType(1)
    npc:SetLDoNTrapSpellID(8241)
    npc:SetLDoNTrapped(true)
    npc:SetLDoNLockedSkill(240)
    npc:SetLDoNLocked(true)
    npc:SetEntityVariable("dodh_demi:locked_chest", dz:GetUUID())
    runtime.protect(npc, true)
    local staged = {npc = npc, event = event, mark = mark, dz = dz, type = npc:GetNPCTypeID()}
    outstanding[npc:GetID()] = staged
    return staged
end

function M.cancel(staged)
    if not staged or not staged.npc.valid then return end
    outstanding[staged.npc:GetID()] = nil
    staged.npc:Depop(false)
end

function M.finish(staged)
    if not staged or not staged.npc.valid then return false end
    local event, dz = staged.event, staged.dz
    local reward = rewards[event]
    if event == "mayong" then
        if not admission.mayong_open(dz) then return false end
        dz:AddLockout("Demi-Plane: mayong", expiry)
        for client in eq.get_entity_list():GetClientList().entries do
            local current = admission.expedition(client)
            if current and current:GetUUID() == dz:GetUUID() then
                client:SetBucket("dodh_blood:mayong", "1")
                progress.sync_aa(client)
            end
        end
    elseif not progress.commit_tier(dz, event, reward.tier) then
        return false
    end
    staged.complete = true
    return true
end

local function add_blockers(corpse, id)
    for _ = 1, 6 do corpse:AddItem(id, 1) end
end

function M.blocker(event, corpse)
    local id = rewards[event].blocker
    if corpse and id ~= 0 then
        add_blockers(corpse, id)
        corpse:ResetDecayTimer()
    end
end

function M.opened(e)
    local staged = outstanding[e.killed_entity_id]
    if not staged or not staged.complete or not e.killed.valid or e.killed:GetNPCTypeID() ~= staged.type
        or e.killed:GetEntityVariable("dodh_raid:occurrence") ~= staged.mark then return end
    local client = runtime.owner(e.other)
    local dz = admission.expedition(client)
    if not dz or dz:GetUUID() ~= staged.dz:GetUUID()
        or e.killed:GetEntityVariable("dodh_demi:opened") ~= tostring(client:CharacterID()) then return end
    local corpse = runtime.corpse(e)
    if not corpse then return end
    local reward = rewards[staged.event]
    outstanding[e.killed_entity_id] = nil
    if reward.backflag then
        corpse:SetEntityVariable("dodh_demi:backflag", dz:GetUUID())
        corpse:AddItem(88036, 1)
    end
    if staged.event == "sisters" then add_blockers(corpse, reward.blocker) end
    for _ = 1, reward.tier == 3 and 3 or 2 do corpse:AddItem(77938, 1) end
    runtime.add_gear(corpse, reward.gear, 3)
    corpse:ResetDecayTimer()
end

return M
