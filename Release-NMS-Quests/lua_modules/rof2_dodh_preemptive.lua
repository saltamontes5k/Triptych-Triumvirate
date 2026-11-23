local scope_api = require("rof2_dodh_scene_scope")
local M = {}

local binding = { task = 920241, zone_id = 350, version = 3 }
local parents = {
    [263325] = 350071,
    [263326] = 350072,
    [263327] = 350071,
    [263328] = 350072,
    [263329] = 350071,
    [263330] = 350072,
    [263331] = 350071,
    [263332] = 350072,
    [263333] = 350071,
    [263334] = 350072,
}
local shade_type, shade_objective = 350902, 4
local run

local function client_of(source)
    if not source or not source.valid then return nil end
    if source:IsClient() then return source:CastToClient() end
    local owner = source:GetOwner()
    return owner and owner.valid and owner:IsClient() and owner:CastToClient()
end

function M.damage(event)
    local npc = event.self
    if parents[npc:GetSpawnPointID()] ~= npc:GetNPCTypeID() then return 0 end
    local client = client_of(event.other)
    if not client or not client:IsTaskActivityActive(binding.task, shade_objective)
        or not scope_api.bind(binding, client) then
        return -1
    end
    return 0
end

function M.death(event)
    local npc = event.killed
    if not npc or not npc.valid then return end
    local placement = npc:GetSpawnPointID()
    if parents[placement] ~= npc:GetNPCTypeID() or event.killed_entity_id <= 0 then return end
    local client = client_of(event.other)
    if not client or not client:IsTaskActivityActive(binding.task, shade_objective) then return end
    local scope = scope_api.bind(binding, client)
    if not scope then return end
    if not run or run.occurrence ~= scope.occurrence or run.instance ~= scope.instance then
        run = scope
        run.converted = {}
    end
    if run.converted[placement] then return end
    local mob = eq.spawn2(shade_type, 0, 0, npc:GetX(), npc:GetY(), npc:GetZ(), npc:GetHeading())
    if not mob or not mob.valid or not mob:IsNPC() then return end
    local shade = mob:CastToNPC()
    local key = scope_api.register(run, shade, "shilgrave_shade")
    if not key then
        shade:Depop(false)
        return
    end
    run.converted[placement] = key
    shade:AddToHateList(client, 1, 0)
end

return M
