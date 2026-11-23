local scope_api = require("rof2_dodh_scene_scope")

local binding = { task = 920240, zone_id = 359, version = 1 }
local timer = "dodh_drillien_mechanics"
local scope
local beat = 0

local function correct_actor(npc)
    return npc:GetNPCTypeID() == 359008 and npc:GetSpawnPointID() == 259610
end

local function client_of(source)
    if not source or not source.valid then return nil end
    if source:IsClient() then return source:CastToClient() end
    local owner = source:GetOwner()
    return owner and owner.valid and owner:IsClient() and owner:CastToClient()
end

function event_damage_taken(e)
    if not correct_actor(e.self) then return 0 end
    local client = client_of(e.other)
    if not scope or not scope_api.member(scope, client) then scope = scope_api.bind(binding, client) end
    if not scope then return -1 end
    if e.damage > 0 and client:IsTaskActivityActive(binding.task, 1) then
        client:UpdateTaskActivity(binding.task, 1, 1)
        if e.damage >= e.self:GetHP() then return -1 end
    end
    return 0
end

function event_combat(e)
    if not correct_actor(e.self) then return end
    if e.joined then
        e.self:ModifyNPCStat("max_hit", "2100")
        e.self:SetSpecialAbility(3, 1) -- Single-target rampage
        beat = 0
        eq.set_timer(timer, 24000)
    else
        eq.stop_timer(timer)
    end
end

-- Both mechanics act only on members in the actual encounter.
-- The guide describes the effects but gives no original cadence.
function event_timer(e)
    if e.timer ~= timer or not scope or not e.self:IsEngaged() then return end
    local npc = e.self
    beat = beat + 1
    if beat % 2 == 0 then
        npc:Emote("gathers power against summoned companions.")
        for client in eq.get_entity_list():GetClientList().entries do
            if scope_api.member(scope, client) and npc:GetHateAmount(client) > 0 then
                local pet = client:GetPet()
                if pet and pet.valid then pet:Kill() end
            end
        end
        return
    end

    local target = npc:GetHateTop()
    local candidates = {}
    for client in eq.get_entity_list():GetClientList().entries do
        if scope_api.member(scope, client) and npc:GetHateAmount(client) > 0
            and (not target.valid or client:GetID() ~= target:GetID()) then
            candidates[#candidates + 1] = client
        end
    end
    if #candidates > 0 then
        local next_target = candidates[math.random(#candidates)]
        npc:Emote("turns toward a new threat.")
        local maximum = target.valid and npc:GetHateAmount(target) or 0
        npc:SetHate(next_target, maximum + 1)
        npc:SetTarget(next_target)
    end
end
