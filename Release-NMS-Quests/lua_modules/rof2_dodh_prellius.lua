local scope_api = require("rof2_dodh_scene_scope")
local M = {}

local function player(mob)
    if not mob or not mob.valid then return nil end
    if mob:IsClient() then return mob:CastToClient() end
    local owner = mob:GetOwner()
    if owner and owner.valid and owner:IsClient() then return owner:CastToClient() end
end

function M.damage_handler(binding)
    assert(type(binding.task) == "number" and binding.task > 0)
    assert(binding.zone_id == 361 and binding.version == 5)
    assert(binding.final_threshold == 0 or binding.final_threshold == 10)
    local thresholds = {80, 60, 40, 20, binding.final_threshold}
    assert(type(binding.heal_to) == "table" and #binding.heal_to == #thresholds)
    for phase, percent in ipairs(binding.heal_to) do
        assert(type(percent) == "number" and percent > thresholds[phase] and percent <= 100)
    end
    local actor_state = "rof2_dodh_prellius_heals"
    return function(event)
        local npc = event.self
        local zone = eq.get_zone()
        if zone:GetZoneID() ~= 361 or zone:GetInstanceVersion() ~= 5 or zone:GetInstanceID() <= 0
            or npc:GetNPCTypeID() ~= 361086 or npc:GetSpawnPointID() ~= 260503
            or event.damage <= 0 then
            return 0
        end
        local member = player(event.other)
        if not member or not member:IsTaskActivityActive(binding.task, 2) then return -1 end
        local scope = scope_api.bind(binding, member)
        if not scope then return -1 end

        -- Retain the counter on the live placed NPC across disengage, evac and
        -- quest script reload. A new run cannot adopt another run's phase.
        local state = npc:GetEntityVariable(actor_state)
        local phase = 1
        if state ~= "" then
            local occurrence, next_heal = state:match("^(%d+):(%d+)$")
            if occurrence ~= scope.occurrence then return -1 end
            phase = tonumber(next_heal)
        end
        if phase == 6 then return 0 end
        if not thresholds[phase] then return -1 end

        local maximum = npc:GetMaxHP()
        if maximum <= 0 then return -1 end
        local boundary = math.floor(maximum * thresholds[phase] / 100)
        if npc:GetHP() - event.damage > boundary then return 0 end
        local healed = math.max(1, math.floor(maximum * binding.heal_to[phase] / 100))
        npc:SetEntityVariable(actor_state, scope.occurrence .. ":" .. (phase + 1))
        npc:SetHP(healed)
        return -1 -- The native attack path handles this as zero residual damage.
    end
end

return M
