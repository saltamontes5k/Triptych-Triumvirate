local loot = require("rof2_dodh_demi_chest")
local admission = require("rof2_dodh_demi_admission")
local runtime = require("rof2_dodh_raid_runtime")
local M = {}
local timer = "dodh_sisters_round"
local names = {"Althea", "Brenda", "Christine"}
local types = {351174, 351175, 351176}
local spawns = {260088, 260098, 260099}
local actions = {"counting silver", "reading a note", "hiding a key", "carrying a candle"}
local types_of_add = {351146, 351148, 351173}
local state

local function slot_of(npc)
    if not npc or not npc.valid then return nil end
    for index, npc_type in ipairs(types) do
        if npc:GetNPCTypeID() == npc_type and npc:GetSpawnPointID() == spawns[index] then return index end
    end
end

local function placed(index, dz)
    return runtime.placed({npc = types[index], spawn = spawns[index]}, dz)
end

local function owned(index)
    local npc = placed(index, state.dz)
    if slot_of(npc) == index and npc:GetID() == state.sisters[index] then return npc end
end

local function reset(success)
    local old = state
    state = nil
    if not runtime.in_instance(old.dz) then return end
    for id in pairs(old.adds) do
        local add = eq.get_entity_list():GetNPCByID(id)
        if add.valid and add:GetEntityVariable("dodh_sisters") == old.uuid then add:Depop(false) end
    end
    if success then return end
    for index, spid in ipairs(spawns) do
        local npc = placed(index, old.dz)
        if slot_of(npc) == index then
            local pose = old.poses[index]
            npc:GMMove(pose[1], pose[2], pose[3], pose[4])
        else
            local spawn = eq.get_entity_list():GetSpawnByID(spid)
            if spawn.valid then
                spawn:Enable()
                spawn:Repop(1)
            end
        end
    end
end

local function spawn_add(npc, target, npc_type, angle)
    local x = npc:GetX() + 8 * math.cos(angle)
    local y = npc:GetY() + 8 * math.sin(angle)
    local mob = eq.spawn2(npc_type, 0, 0, x, y, npc:GetZ(), npc:GetHeading())
    if not mob or not mob.valid or not mob:IsNPC() then return false end
    local add = mob:CastToNPC()
    add:SetEntityVariable("dodh_sisters", state.uuid)
    state.adds[add:GetID()] = true
    add:AddToHateList(target, 1, 0)
    return true
end

local function begin(dz, target, handbag_type)
    local sisters, poses = {}, {}
    for index in ipairs(spawns) do
        local npc = placed(index, dz)
        if slot_of(npc) ~= index then return false end
        sisters[index] = npc:GetID()
        poses[index] = {npc:GetX(), npc:GetY(), npc:GetZ(), npc:GetHeading()}
    end
    state = {dz = dz, uuid = dz:GetUUID(), sisters = sisters, poses = poses, handbag_type = handbag_type,
             expiry = os.time() + 1200, reported = {0, 0, 0}, pending = {},
             generation = 1, read = {}, act = {1, 2, 3}, adds = {}, removed = 0}
    for index = 1, 3 do
        local npc = owned(index)
        for add_index, npc_type in ipairs(types_of_add) do
            if not spawn_add(npc, target, npc_type, 2 * math.pi * add_index / 3) then
                reset()
                return false
            end
        end
    end
    return true
end

local function local_targets(dz)
    for client in eq.get_entity_list():GetClientList().entries do
        local current = admission.expedition(client)
        if current and current:GetUUID() == dz then return client end
    end
end

function M.spawn(e)
    if slot_of(e.self) then
        e.self:SetSpecialAbility(24, 1)
        e.self:SetSpecialAbility(35, 1)
        eq.set_timer(timer, 1000, e.self)
    end
end

function M.tick(e)
    if e.timer ~= timer or not state or not slot_of(e.self) then return end
    local stamp = os.time()
    if stamp >= state.expiry or not local_targets(state.uuid) then
        reset()
        return
    end
    if not state.next_move or stamp >= state.next_move then
        state.next_move = stamp + 38
        state.generation = state.generation + 1
        state.pending, state.read = {}, {}
        for index = 1, 3 do
            local npc = owned(index)
            if npc and state.reported[index] < 8 then
                state.act[index] = math.random(#actions)
                local pose = state.poses[(index + state.generation - 1) % 3 + 1]
                npc:GMMove(pose[1], pose[2], pose[3], pose[4])
            end
        end
    end
end

function M.say(e, handbag_type)
    local index, member = slot_of(e.self), e.other
    local dz = admission.expedition(member)
    -- Unbound release data cannot start an encounter with no native loot actor.
    if not index or not dz or not handbag_type or dz:HasLockout("Demi-Plane: sisters") then return end
    local phrase = e.message:lower()
    local is_hail = phrase == "hail" or phrase == "hail, " .. names[index]:lower()
    if not state and (not is_hail or not begin(dz, member, handbag_type)) then return end
    if state.uuid ~= dz:GetUUID() or state.reported[index] >= 8 then return end
    local cid = member:CharacterID()
    if is_hail then
        local action = actions[state.act[index]]
        state.read[index] = state.generation
        local other = index % 3 + 1
        if state.reported[other] >= 8 then other = other % 3 + 1 end
        state.pending[cid] = {asker = index, suspect = other, generation = state.generation}
        e.self:Say("I am " .. action .. ". Tell me what " .. names[other] .. " is doing.")
        if math.random(4) == 1 then e.self:SpellFinished(index == 2 and 8243 or 8242, member) end
        return
    end
    local note = state.pending[cid]
    if not note or note.asker ~= index or note.generation ~= state.generation
        or state.read[note.suspect] ~= state.generation
        or phrase ~= actions[state.act[note.suspect]] or state.reported[note.suspect] >= 8 then return end
    state.pending[cid] = nil
    -- Only one successful report per subject per room movement.
    state.read[note.suspect] = nil
    state.reported[note.suspect] = state.reported[note.suspect] + 1
    if state.reported[note.suspect] == 8 then
        state.removed = state.removed + 1
        local suspect = owned(note.suspect)
        if suspect then
            eq.disable_spawn2(spawns[note.suspect])
            suspect:Depop(false)
        end
    end
    if state.removed == 2 then
        local bag = loot.prepare(dz, "sisters", {370.8524, 2560.4766, 127.5, 0}, state.handbag_type)
        local complete = loot.finish(bag)
        if not complete then loot.cancel(bag) end
        reset(complete)
    end
end

return M
