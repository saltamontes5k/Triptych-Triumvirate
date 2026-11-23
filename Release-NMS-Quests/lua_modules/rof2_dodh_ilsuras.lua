local scope_api = require("rof2_dodh_scene_scope")
local M = {}

local binding = { task = 920239, zone_id = 359, version = 2 }
local roles = {
    renok = {359028, 259662}, hithrav = {359026, 259649},
    vrek = {359014, 259616}, iknar = {359015, 259617},
    prince = {359016, 259618}, prisoner = {359030, 259687},
}
local role_for = {[359028]="renok", [359026]="hithrav", [359014]="vrek",
    [359015]="iknar", [359016]="prince", [359030]="prisoner"}
local timer = "dodh_ilsuras_escort"
local disguise_race, being_aggro_immune = 461, 25
local dagger_chest, dagger = 358178, 87001
local run

local function count(activity)
    return eq.get_task_activity_done_count(binding.task, activity)
end

local function member(client)
    local scope = scope_api.bind(binding, client)
    if not scope then return false end
    if not run or run.scope.instance ~= scope.instance or run.scope.occurrence ~= scope.occurrence then
        run = {scope = scope, actors = {}, looks = {}, escorting = false,
            defenders_left = 0, protectors_left = 2}
    end
    return true
end

local function restore(client)
    local original = run and run.looks[client:CharacterID()]
    if not original then return end
    if client:GetRace() == disguise_race then client:SendIllusionPacket(original.look) end
    client:SetSpecialAbility(being_aggro_immune, original.immunity)
    run.looks[client:CharacterID()] = nil
end

local function placed(role)
    local key = run.actors[role]
    if not key then
        local serial = roles[role]
        key = scope_api.register_placed(run.scope, serial[1], serial[2], role)
        run.actors[role] = key
    end
    return key and scope_api.actor(run.scope, key)
end

local function actor_from(source)
    if not source or not source.valid then return nil end
    if source:IsClient() then return source:CastToClient() end
    local owner = source:GetOwner()
    return owner and owner.valid and owner:IsClient() and owner:CastToClient()
end

local function spawn(id, x, y, z, heading, role)
    local mob = eq.spawn2(id, 0, 0, x, y, z, heading)
    if not mob or not mob.valid or not mob:IsNPC() then return nil end
    local npc = mob:CastToNPC()
    local key = scope_api.register(run.scope, npc, role)
    if not key then npc:Depop(false); return nil end
    return npc
end

function M.enter(event)
    local client = event.self
    if not member(client) then return end
    eq.set_timer(timer, 1000, client)
    if count(2) > 0 or run.looks[client:CharacterID()] then return end
    run.looks[client:CharacterID()] = {
        look = {race=client:GetRace(), gender=client:GetGender(), texture=client:GetTexture(),
            helmtexture=client:GetHelmTexture(), size=client:GetSize()},
        immunity = client:GetSpecialAbility(being_aggro_immune),
    }
    client:SendIllusionPacket({race=disguise_race, gender=2, texture=0, helmtexture=0})
    client:SetSpecialAbility(being_aggro_immune, 1)
end

function M.leave(event)
    restore(event.self)
end

function M.hail(event)
    local client, npc = event.other, event.self
    if event.message:lower():match("^%s*hail") == nil or npc:GetSpawnPointID() ~= 259662
        or not member(client) or not client:IsTaskActivityActive(binding.task, 1) then return end
    local renok, hithrav = placed("renok"), placed("hithrav")
    if not renok or not hithrav then return end
    if not run.escorting then
        run.escorting = true
        renok:MoveTo(hithrav:GetX() - 7, hithrav:GetY(), hithrav:GetZ(), hithrav:GetHeading(), false)
    end
    client:UpdateTaskActivity(binding.task, 1, 1)
end

function M.tick(event)
    local client = event.self
    if event.timer ~= timer then return end
    if not run or not scope_api.member(run.scope, client) then
        restore(client)
        eq.stop_timer(timer, client)
        return
    end
    if not run.escorting or not client:IsTaskActivityActive(binding.task, 2) then return end
    local renok, commander = placed("renok"), placed("hithrav")
    if not renok or not commander then return end
    local function near(a, b)
        local x, y = a:GetX() - b:GetX(), a:GetY() - b:GetY()
        return x*x + y*y <= 24*24 and math.abs(a:GetZ() - b:GetZ()) <= 12
    end
    if not near(renok, commander) or not near(client, renok) then return end
    run.escorting = false
    for other in eq.get_entity_list():GetClientList().entries do
        if scope_api.member(run.scope, other) then restore(other) end
    end
    client:UpdateTaskActivity(binding.task, 2, 1)
    renok:AddToHateList(client, 1, 0)
    commander:AddToHateList(client, 1, 0)
    eq.stop_timer(timer, client)
end

function M.click(event)
    local client, clicked = event.self, event.door
    local id = clicked:GetDoorDBID()
    if id ~= 39141 and id ~= 39144 and id ~= 39142 and (id < 39145 or id > 39149) then return 0 end
    if not member(client) then return 1 end

    if id == 39141 and clicked:GetDoorID() == 3 and client:IsTaskActivityActive(binding.task, 4) then
        if run.defenders_left ~= 0 then return 1 end
        local guards = {}
        for i = 1, 2 do
            local npc = spawn(359012, client:GetX() + i * 4, client:GetY(), client:GetZ(), 0, "monolith")
            if not npc then
                for _, guard in ipairs(guards) do guard:Depop(false) end
                return 1
            end
            guards[#guards+1] = npc
        end
        run.defenders_left = #guards
        client:UpdateTaskActivity(binding.task, 4, 1)
        for _, guard in ipairs(guards) do guard:AddToHateList(client, 1, 0) end
    elseif id == 39144 and clicked:GetDoorID() == 6 and client:IsTaskActivityActive(binding.task, 6) then
        client:Message(0, "A cold current stirs beyond the jail.")
        client:UpdateTaskActivity(binding.task, 6, 1)
    elseif id == 39142 and clicked:GetDoorID() == 4 and count(6) >= 1 then
        local prince, prisoner, vrek, iknar = placed("prince"), placed("prisoner"), placed("vrek"), placed("iknar")
        if prince and prisoner and vrek and iknar and not run.protectors_released then
            run.protectors_released = true
            prince:Say("Protectors, deal with the intruders.")
            prisoner:Kill()
            prince:Depop(false)
            vrek:AddToHateList(client, 1, 0)
            iknar:AddToHateList(client, 1, 0)
        end
        return 0
    elseif id == 39145 and clicked:GetDoorID() == 12 and client:IsTaskActivityActive(binding.task, 9) then
        local portals = {}
        for offset = 0, 3 do
            local portal = eq.get_entity_list():FindDoor(14 + offset)
            if not portal or not portal.valid or portal:GetDoorDBID() ~= 39146 + offset then return 1 end
            portals[#portals + 1] = portal
        end
        for _, portal in ipairs(portals) do
            portal:SetDisableTimer(true)
            portal:ForceOpen(client, true)
        end
        run.exit_open = true
    elseif id >= 39146 and id <= 39149 and clicked:GetDoorID() == id - 39132
        and run.exit_open and clicked:IsDoorOpen() then
        local awaiting_credit = client:IsTaskActivityActive(binding.task, 9)
        if not awaiting_credit and count(9) < 1 then return 1 end
        if awaiting_credit then client:UpdateTaskActivity(binding.task, 9, 1) end
        restore(client)
        client:MovePC(358, 43.3, -1005.8, 71, 29)
    end
    return 1
end

function M.damage(event)
    local npc = event.self
    local role = role_for[npc:GetNPCTypeID()]
    if not role or roles[role][2] ~= npc:GetSpawnPointID() then return 0 end
    if role == "prince" or role == "prisoner" then return -1 end
    local client = actor_from(event.other)
    if not run or not scope_api.member(run.scope, client) then return -1 end
    local objective = (role == "vrek" or role == "iknar") and 7 or 3
    if not client:IsTaskActivityActive(binding.task, objective) then return -1 end
    if objective == 7 and not run.protectors_released then return -1 end
    return 0
end

function M.death(event)
    local client = actor_from(event.other)
    if not run or not scope_api.member(run.scope, client) then return end
    local key, role = scope_api.death(run.scope, event)
    if not key then return end
    if role == "monolith" then
        run.defenders_left = run.defenders_left - 1
        if run.defenders_left == 0 and client:IsTaskActivityActive(binding.task, 5) then
            client:UpdateTaskActivity(binding.task, 5, 2)
        end
    elseif role == "vrek" or role == "iknar" then
        run.protectors_left = run.protectors_left - 1
        if run.protectors_left == 0 then spawn(dagger_chest, -1451, 219, -0.375, 192, "dagger_chest") end
    elseif role == "dagger_chest" then
        local corpse = event.corpse
        if corpse and corpse.valid and corpse:IsNPCCorpse() and corpse:GetID() == event.killed_entity_id
            and corpse:CountItem(dagger) == 0 then
            corpse:AddItem(dagger, 1)
            corpse:ResetDecayTimer()
        end
    end
end

return M
