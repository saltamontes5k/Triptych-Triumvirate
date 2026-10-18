-- achievement_flags.lua -- shared quest-side achievement hooks.
--
-- Call these only after the owning script has already committed the durable
-- success: the completed task, the killed target, the consumed turn-in. Every
-- call is idempotent and never rolls back quest state.
--
--   local ach = require("achievement_flags")
--   ach.set(e, achievement_id, component_type, component_id)        -- this client
--   ach.set_party(e, achievement_id, component_type, component_id)  -- in-zone members
--   ach.complete(e, achievement_id)                                 -- whole achievement
--
-- set_party only reaches group/raid members who are in the same zone. Members in
-- another zone, offline members, and shared-task completion must use the world
-- state-update path (AdvanceSharedTaskAchievementProgress / the durable task fact).

local M = {}

local function client_of(e)
  return e and e.self or nil
end

-- Push one component to count (default 1) for a single client.
function M.set(e, achievement_id, component_type, component_id, count)
  local self = client_of(e)
  if not self then return false end
  return self:SetAchievementProgress(achievement_id, component_type, component_id, count or 1)
end

-- Push one component for every client in the caller's raid, group, or self.
function M.set_party(e, achievement_id, component_type, component_id, count)
  local self = client_of(e)
  if not self then return 0 end
  local n = count or 1
  local pushed = 0
  for _, member in ipairs(self:GetRaidOrGroupOrSelf(true)) do
    local c = member:CastToClient()
    if c and c.valid
      and c:SetAchievementProgress(achievement_id, component_type, component_id, n) then
      pushed = pushed + 1
    end
  end
  return pushed
end

-- Push one component for every client in the current zone. Use this for instanced
-- raids, where the zone is the encounter and every client in it was credited.
function M.set_zone(achievement_id, component_type, component_id, count)
  local clients = eq.get_entity_list():GetClientList()
  if not clients then return 0 end
  local n = count or 1
  local pushed = 0
  for c in clients.entries do
    if c and c.valid and c:SetAchievementProgress(achievement_id, component_type, component_id, n) then
      pushed = pushed + 1
    end
  end
  return pushed
end

-- Complete a whole achievement for a single client (idempotent).
function M.complete(e, achievement_id)
  local self = client_of(e)
  if not self then return false end
  return self:CompleteAchievement(achievement_id)
end

return M
