local scope_api = require("rof2_dodh_scene_scope")
local M = {}

local mapping_sql = [[
SELECT CAST(dz.id AS CHAR), st.completion_time
FROM shared_tasks st
JOIN shared_task_members m ON m.shared_task_id = st.id
JOIN shared_task_dynamic_zones z ON z.shared_task_id = st.id
JOIN dynamic_zones dz ON dz.id = z.dynamic_zone_id
JOIN instance_list i ON i.id = dz.instance_id
WHERE st.id = CAST(? AS UNSIGNED) AND st.task_id = ? AND m.character_id = ?
  AND dz.instance_id = ? AND i.zone = ? AND i.version = ?
  AND (st.expire_time IS NULL OR st.expire_time > NOW())
]]

local activity_sql = [[
SELECT a.done_count, UNIX_TIMESTAMP(a.completed_time)
FROM shared_tasks st
JOIN shared_task_members m ON m.shared_task_id = st.id
JOIN shared_task_dynamic_zones z ON z.shared_task_id = st.id
JOIN dynamic_zones dz ON dz.id = z.dynamic_zone_id
JOIN instance_list i ON i.id = dz.instance_id
LEFT JOIN shared_task_activity_state a ON a.shared_task_id = st.id AND a.activity_id = ?
WHERE st.id = CAST(? AS UNSIGNED) AND st.task_id = ? AND m.character_id = ?
  AND dz.id = CAST(? AS UNSIGNED) AND dz.instance_id = ? AND i.zone = ? AND i.version = ?
  AND (st.expire_time IS NULL OR st.expire_time > NOW())
]]

local archive_sql = [[
SELECT a.done_count, UNIX_TIMESTAMP(a.completed_time)
FROM completed_shared_tasks st
JOIN completed_shared_task_members m ON m.shared_task_id = st.id
JOIN completed_shared_task_activity_state a ON a.shared_task_id = st.id AND a.activity_id = ?
WHERE st.id = CAST(? AS UNSIGNED) AND st.task_id = ? AND m.character_id = ?
  AND st.completion_time IS NOT NULL
]]

local function read_one(sql, params)
    local db, stmt
    local ok, result = pcall(function()
        db = Database(Database.Default)
        stmt = db:prepare(sql)
        stmt:execute(params)
        local row = stmt:fetch_array()
        if row == nil then
            return false
        end
        -- The native statement reuses its result table on the next fetch.
        local result_row = {}
        for i = 1, stmt:num_fields() do result_row[i] = row[i] end
        if stmt:fetch_array() ~= nil then
            return nil
        end
        return result_row
    end)
    if stmt then
        stmt:close()
    end
    if db then
        db:close()
    end
    if ok then return result end
end

M.read_one = read_one

function M.mapping(scope, client)
    if not scope_api.member(scope, client) then
        return nil
    end
    local binding = scope.binding
    local row = read_one(mapping_sql, {
        scope.occurrence, binding.task, client:CharacterID(), scope.instance,
        binding.zone_id, binding.version,
    })
    if row and row[1] and row[2] == nil then
        return row[1]
    end
end

function M.triangle(scope, participant)
    if scope.binding.task ~= 920224 then
        return nil
    end
    local zone = eq.get_zone()
    local name = "dodh_triangle_keyed_open"
    local raw = zone:GetVariable(name)
    local run_id, dz_id, character_id = raw:match("^([1-9][0-9]*):([1-9][0-9]*):([1-9][0-9]*)$")
    if run_id ~= scope.occurrence then
        return nil
    end
    local member = participant(tonumber(character_id))
    if not member or M.mapping(scope, member) ~= dz_id then
        return nil
    end
    if not zone:DeleteVariable(name) then
        return nil
    end
    return { kind = "opened_keyed_gate", actor = 40096, member = member }
end

function M.cocoon(open_event, actor, placement, member)
    -- Call after scope validation of actor generation and opener membership.
    if open_event.dodh_cocoon_open ~= true or not open_event.corpse
        or not open_event.corpse.valid or not open_event.corpse:IsNPCCorpse()
        or open_event.corpse:GetID() ~= open_event.killed_entity_id then
        return nil
    end
    return { kind = "opened_cocoon", actor = actor, placement = placement, member = member }
end

function M.native_death(scope, event)
    local actor, role = scope_api.death(scope, event)
    if not actor then
        return nil
    end
    if role == "escort" or role == "gnome" then
        return { kind = "escort_death", actor = actor }
    end
    local source = event.other
    local member = source and source.valid and source:IsClient() and source:CastToClient()
    if not member or not scope_api.member(scope, member) then
        return { kind = "uncredited_death", actor = actor, role = role }
    end
    if role == "placed_cocoon" or role == "aged_cocoon" then
        local placement = event.killed:GetSpawnPointID()
        return M.cocoon(event, actor, placement, member)
            or { kind = "uncredited_death", actor = actor, role = role }
    end
    return { kind = "death", actor = actor, role = role, member = member, corpse = event.corpse }
end

function M.credit_adapter(scope, participant)
    local pending = {}
    local binding = scope.binding

    return function(activity, count)
        local sent = pending[activity]
        if not sent then
            local client = participant()
            local dz_id = client and M.mapping(scope, client)
            if not dz_id then
                return "waiting"
            end
            if not client:IsTaskActivityActive(binding.task, activity) then
                return "waiting"
            end
            sent = { character = client:CharacterID(), dz = dz_id, count = count }
            pending[activity] = sent
            client:UpdateTaskActivity(binding.task, activity, count)
        elseif sent.count ~= count then
            return "conflict"
        end

        local live = read_one(activity_sql, {
            activity, scope.occurrence, binding.task, sent.character, sent.dz, scope.instance,
            binding.zone_id, binding.version,
        })
        if live and tonumber(live[1]) == count and (tonumber(live[2]) or 0) > 0 then
            return "applied"
        end
        local archived = read_one(archive_sql, { activity, scope.occurrence, binding.task, sent.character })
        if archived and tonumber(archived[1]) == count and (tonumber(archived[2]) or 0) > 0 then
            return "applied"
        end
        return "waiting"
    end
end

return M
