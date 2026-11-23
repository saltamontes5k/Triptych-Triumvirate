local progress = require("rof2_dodh_raid_progress")
local M = {}

function M.owner(mob)
    if not mob or not mob.valid then return nil end
    if mob:IsClient() then return mob:CastToClient() end
    local owner = mob:GetOwner()
    if owner and owner.valid and owner:IsClient() then return owner:CastToClient() end
end

function M.scope(client, raid)
    return progress.same_instance(client, raid.name, raid.zone, raid.version)
end

function M.actor(npc, definition)
    return npc and npc.valid and npc:GetNPCTypeID() == definition.npc
        and npc:GetSpawnPointID() == definition.spawn
end

function M.in_instance(dz)
    if not dz or not dz.valid then return false end
    local zone = eq.get_zone()
    local instance_id = zone:GetInstanceID()
    return instance_id > 0 and dz:GetInstanceID() == instance_id
        and zone:GetZoneID() == dz:GetZoneID() and zone:GetInstanceVersion() == dz:GetZoneVersion()
end

function M.placed(definition, dz)
    if not M.in_instance(dz) or definition.spawn <= 0 then return nil end
    -- The legacy NPC lookup takes a spawn group ID. Match the actual spawn2 instead.
    local match
    for npc in eq.get_entity_list():GetNPCList().entries do
        if M.actor(npc, definition) then
            if match then return nil end
            match = npc
        end
    end
    return match
end

function M.in_scope(raid)
    local zone = eq.get_zone()
    return zone:GetZoneID() == raid.zone and zone:GetInstanceVersion() == raid.version
        and zone:GetInstanceID() > 0
end

function M.protect(npc, protect)
    local value = protect and 1 or 0
    npc:SetSpecialAbility(24, value)
    npc:SetSpecialAbility(25, value)
    npc:SetSpecialAbility(35, value)
end

function M.spawn_owned(npc_type, point, mark)
    if not npc_type then return nil end
    local mob = eq.spawn2(npc_type, 0, 0, point[1], point[2], point[3], point[4])
    if mob and mob.valid and mob:IsNPC() then
        local npc = mob:CastToNPC()
        npc:SetEntityVariable("dodh_raid:occurrence", mark)
        return npc
    end
end

function M.owned(mark, id, npc_type)
    local npc = eq.get_entity_list():GetNPCByID(id)
    if npc.valid and (not npc_type or npc:GetNPCTypeID() == npc_type)
        and npc:GetEntityVariable("dodh_raid:occurrence") == mark then return npc end
end

function M.pose(npc, dx, dy)
    return { npc:GetX() + (dx or 0), npc:GetY() + (dy or 0), npc:GetZ(), npc:GetHeading() }
end

function M.member_target(dz, raid, npc)
    if not dz or not dz.valid then return nil end
    local top = npc:GetHateTop()
    local client = M.owner(top)
    local current = M.scope(client, raid)
    if current and current:GetUUID() == dz:GetUUID() and client:GetHP() > 0 then return top end
    for member in eq.get_entity_list():GetClientList().entries do
        local scope = M.scope(member, raid)
        if scope and scope:GetUUID() == dz:GetUUID() and member:GetHP() > 0 then return member end
    end
end

function M.add_gear(corpse, source, count)
    local pool = {}
    for index, item in ipairs(source) do pool[index] = item end
    for _ = 1, count do
        corpse:AddItem(table.remove(pool, math.random(#pool)), 1)
    end
end

function M.corpse(e)
    local corpse = e.corpse
    if corpse and corpse.valid and corpse:IsNPCCorpse() and corpse:GetID() == e.killed_entity_id then
        return corpse
    end
end

function M.disable(definition, dz)
    if not M.in_instance(dz) then return end
    eq.disable_spawn2(definition.spawn)
    local npc = M.placed(definition, dz)
    if npc then npc:Depop(false) end
end

function M.restore(definition, dz)
    if not M.in_instance(dz) then return end
    local npc = M.placed(definition, dz)
    if npc then npc:Depop(false) end
    local spawn = eq.get_entity_list():GetSpawnByID(definition.spawn)
    if spawn.valid then
        spawn:Enable()
        spawn:Repop(1)
    end
end

return M
