local receipts = require("rof2_dodh_scene_receipts")
local M = {}
local bucket_sql = [[
SELECT value FROM data_buckets WHERE `key` = ?
  AND character_id = 0 AND account_id = 0 AND npc_id = 0 AND bot_id = 0
  AND zone_id = 0 AND instance_id = 0 AND expires = 0
]]
local outcome_sql = [[
SELECT
    (SELECT COUNT(*) FROM shared_tasks WHERE id = CAST(? AS UNSIGNED) AND task_id = ?),
    (SELECT COUNT(*) FROM completed_shared_tasks WHERE id = CAST(? AS UNSIGNED)
       AND task_id = ? AND completion_time IS NOT NULL)
]]
local trade_sql = [[
SELECT request_key, character_id, npc_type_id, npc_spawn_id, npc_entity_id,
       RIGHT(HEX(recipe_context), 8)
FROM kithicor_poison_custody
WHERE recipe_kind = 4 AND shared_task_id = CAST(? AS UNSIGNED)
  AND instance_id = ? AND phase = 0 AND chest = 0 AND physical = 1
  AND settled = 1 AND abort_only = 0 AND OCTET_LENGTH(recipe_context) = 26
  AND LEFT(recipe_context, 6) = UNHEX('444f44480102')
  AND SUBSTRING(recipe_context, 7, 8) = REVERSE(UNHEX(LPAD(HEX(CAST(? AS UNSIGNED)),16,'0')))
  AND SUBSTRING(recipe_context, 15, 4) = REVERSE(UNHEX(LPAD(HEX(CAST(? AS UNSIGNED)),8,'0')))
  AND SUBSTRING(recipe_context, 19, 4) = REVERSE(UNHEX(LPAD(HEX(npc_entity_id),8,'0')))
]]

function M.start(scope, dz_id)
    local key = "rof2_dodh_scene:" .. scope.binding.task .. ":" .. scope.occurrence
    local identity = scope.occurrence .. ":" .. dz_id .. ":" .. scope.instance
    local row = receipts.read_one(bucket_sql, {key})
    if row and row[1] == identity then
        return "interrupted", key
    end
    if row ~= false then
        return "hold"
    end
    eq.set_data(key, identity)
    local persisted = receipts.read_one(bucket_sql, {key})
    if persisted and persisted[1] == identity then
        return "started", key
    end
    return "hold"
end

function M.end_deserting(scope, dz_id)
    if scope.binding.task ~= 920224 then
        return false
    end
    return eq.get_zone():RequestDodhDesertingEnd(scope.occurrence, tonumber(dz_id))
end

function M.outcome(scope)
    local task = scope.binding.task
    local row = receipts.read_one(outcome_sql, {scope.occurrence, task, scope.occurrence, task})
    if not row or tonumber(row[1]) == nil or tonumber(row[2]) == nil then
        return "hold"
    end
    if tonumber(row[1]) ~= 0 then
        return "pending"
    end
    if tonumber(row[2]) == 1 then
        return "completed"
    end
    return tonumber(row[2]) == 0 and "ended" or "hold"
end

local function generation_hex(generation)
    return ("%02X%02X%02X%02X"):format(
        generation % 256, math.floor(generation / 256) % 256,
        math.floor(generation / 65536) % 256, math.floor(generation / 16777216) % 256)
end

function M.committed_guard(scope, dz_id)
    local row = receipts.read_one(trade_sql, {scope.occurrence, scope.instance, scope.occurrence, dz_id})
    if not row then
        return nil
    end
    for key, actor in pairs(scope.actors) do
        if actor.role == "passive" and tonumber(row[3]) == actor.npc_type
            and tonumber(row[4]) == actor.spawn and tonumber(row[5]) == actor.id
            and row[6] == generation_hex(actor.generation) then
            return { kind = "committed_handin", actor = key, item = 86018,
                time = os.time(), request_key = row[1], character_id = row[2] }
        end
    end
end

return M
