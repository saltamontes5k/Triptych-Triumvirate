local scene = require("rof2_dodh_scene_scope")
local M = {}

-- Each real difficulty gets its own binding, including its own version and
-- placements. The retained Normal boss is 354311 at spawn2 262895 in 354 v5.
function M.bind(binding)
    local thresholds = { 75, 50, binding.run_at }
    local reset_timer = "rof2_poisonmaster_reset"
    local function actor(npc)
        local zone = eq.get_zone()
        return zone:GetZoneID() == binding.zone_id and zone:GetInstanceID() > 0
            and zone:GetInstanceVersion() == binding.version
            and npc:GetNPCTypeID() == binding.npc and npc:GetSpawnPointID() == binding.spawn
    end

    local run
    local function clear(npc)
        run = nil
        npc:DeleteEntityVariable("rof2_poisonmaster_terminal")
        eq.set_next_hp_event(-1)
        eq.stop_timer(reset_timer)
    end

    local function player(mob)
        if not mob or not mob.valid then return nil end
        if mob:IsClient() then return mob:CastToClient() end
        local owner = mob:GetOwner()
        if owner and owner.valid and owner:IsClient() then return owner:CastToClient() end
    end

    local function arm()
        -- EQEmu checks floor(percent) < next_hp. Add one to trigger at the
        -- documented integer boundary, including an exact threshold hit.
        local threshold = thresholds[run.phase]
        eq.set_next_hp_event(threshold and threshold + 1 or -1)
    end

    return {
        spawn = function(event)
            if actor(event.self) then clear(event.self) end
        end,
        damage = function(event)
            local npc = event.self
            if not actor(npc) or event.damage <= 0 then return 0 end
            local member = player(event.other)
            if not member or not member:IsTaskActivityActive(binding.task, binding.kill_activity) then
                return -1
            end
            if not run then
                run = scene.bind(binding, member)
                if not run then return -1 end
                run.entity = npc:GetID()
                run.phase = 1
                arm()
            end
            if run.entity ~= npc:GetID() or not scene.member(run, member) then return -1 end
            local threshold = thresholds[run.phase]
            if not threshold then return 0 end

            -- Apply at most enough damage for the current retreat event.
            local floor_hp = math.floor(npc:GetMaxHP() * threshold / 100)
            local remaining = npc:GetHP() - floor_hp
            if remaining <= 0 then return -1 end
            return event.damage > remaining and remaining or 0
        end,
        hp = function(event)
            local npc = event.self
            local threshold = run and thresholds[run.phase]
            if not threshold or not actor(npc) or run.entity ~= npc:GetID()
                or event.hp_event ~= threshold + 1 then
                return
            end
            local point = binding.retreat[run.phase]
            if run.phase == 1 then
                npc:BuffFadeDetrimental()
                npc:WipeHateList()
            end
            npc:SaveGuardSpot(point[1], point[2], point[3], point[4])
            if run.phase <= 2 then
                npc:GMMove(point[1], point[2], point[3], point[4], true)
            else
                -- Let the native NPC run towards this guard point until players
                -- engage again. The local retreat begins with a hate reset.
                npc:WipeHateList()
                npc:NavigateTo(point[1], point[2], point[3])
            end
            run.phase = run.phase + 1
            arm()
            if run.phase == 4 then
                npc:SetEntityVariable("rof2_poisonmaster_terminal", run.occurrence)
                eq.set_timer(reset_timer, 1000)
            end
        end,
        timer = function(event)
            local npc = event.self
            if event.timer ~= reset_timer or not actor(npc) or not run
                or run.entity ~= npc:GetID() or run.phase ~= 4 or npc:IsEngaged()
                or npc:GetHP() < npc:GetMaxHP() then
                return
            end
            local point = binding.origin
            npc:SaveGuardSpot(point[1], point[2], point[3], point[4])
            npc:GMMove(point[1], point[2], point[3], point[4], true)
            clear(npc)
        end,
    }
end

return M
