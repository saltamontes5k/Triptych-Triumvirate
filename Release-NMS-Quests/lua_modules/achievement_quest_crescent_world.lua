-- Rune encounters and waterfall collection. Client task state owns all credit.
local M = {}
local world = require('achievement_quest_crescent_data').world
local sessions, idle = {}, {}
local function spirit(id)
    for _, rule in ipairs(world.spirits) do if rule.npc == id then return rule end end
end
local function controller(id)
    for _, rule in ipairs(world.spirits) do if rule.controller == id then return rule end end
end
local function near(c, npc, radius, height)
    local dx, dy = c:GetX()-npc:GetX(), c:GetY()-npc:GetY()
    return dx*dx+dy*dy <= radius*radius and math.abs(c:GetZ()-npc:GetZ()) <= height
end
function M.spawn(e)
    local id, entity = e.self:GetNPCTypeID(), e.self:GetID()
    local rule = controller(id)
    if rule or id == world.mist.controller then
        e.self:SetTargetable(false)
        local range = rule and 35 or world.mist.radius
        local height = rule and 20 or world.mist.height
        eq.set_proximity(e.self:GetX()-range,e.self:GetX()+range,
            e.self:GetY()-range,e.self:GetY()+range,e.self:GetZ()-height,e.self:GetZ()+height)
    elseif spirit(id) then
        sessions[entity], idle[entity] = {}, 0
        eq.set_timer('council_listen',1000)
    end
end
function M.enter(e)
    local id, c = e.self:GetNPCTypeID(), e.other
    local rule = controller(id)
    if rule and c:IsTaskActivityActive(world.task,rule.activity) then
        local existing = eq.get_entity_list():GetNPCByNPCTypeID(rule.npc)
        if not existing.valid then
            eq.spawn2(rule.npc,0,0,rule.loc_yxz[2],rule.loc_yxz[1],rule.loc_yxz[3],0)
        end
        return
    end
    local mist=world.mist
    if id ~= mist.controller or not near(c,e.self,mist.radius,mist.height) or
       not c:IsTaskActivityActive(mist.task,mist.activity) then return end
    -- SummonItem's Lua binding has no success return. Require an empty cursor
    -- and confirm the new persisted item before consuming its input or crediting.
    if c:GetItemIDAt(Slot.Cursor)>0 then c:Message(13,'Empty your item cursor, then enter the waterfall again.'); return end
    local before=c:CountItem(mist.input)
    if before<1 or c:CountItem(mist.output)>0 then return end
    c:SummonItem(mist.output,1)
    if c:CountItem(mist.output)<1 then return end
    c:RemoveItem(mist.input,1)
    if c:CountItem(mist.input) ~= before-1 then
        c:RemoveItem(mist.output,1)
        c:Message(13,'The mist could not be collected. Your empty jar has been retained.')
        return
    end
    c:UpdateTaskActivity(mist.task,mist.activity,1)
    c:Message(15,'The waterfall mist gathers inside the jar.')
end
function M.say(e)
    local rule=spirit(e.self:GetNPCTypeID())
    local c=e.other
    if not rule or not e.message:lower():find('hail',1,true) or
       not c:IsTaskActivityActive(world.task,rule.activity) or
       not near(c,e.self,world.listen_radius,world.listen_height) then return end
    local entity=e.self:GetID();sessions[entity]=sessions[entity] or {}
    local key=c:CharacterID()
    if sessions[entity][key] then return end -- Repeated hails do not restart/skip.
    sessions[entity][key]={next_line=2,ticks=0}
    c:Message(15,e.self:GetCleanName() .. ': ' .. rule.lines[1])
    idle[entity]=0
end
function M.timer(e)
    if e.timer~='council_listen' then return end
    local entity=e.self:GetID();local rule=spirit(e.self:GetNPCTypeID())
    if not rule then return end
    local listeners=sessions[entity] or {}
    for key,state in pairs(listeners) do
        local c=eq.get_entity_list():GetClientByCharID(key)
        if not c.valid or c:GetHP()<=0 or not c:IsTaskActivityActive(world.task,rule.activity) or
           not near(c,e.self,world.listen_radius,world.listen_height) then
            listeners[key]=nil -- Leaving, dying, zoning or abandoning cancels listening.
        else
            state.ticks=state.ticks+1
            if state.ticks>=world.speech_interval_seconds then
                state.ticks=0
                c:Message(15,e.self:GetCleanName() .. ': ' .. rule.lines[state.next_line])
                state.next_line=state.next_line+1
                if state.next_line>#rule.lines then
                    c:UpdateTaskActivity(world.task,rule.activity,1)
                    listeners[key]=nil
                end
            end
        end
    end
    if next(listeners) then idle[entity]=0 else idle[entity]=(idle[entity] or 0)+1 end
    if idle[entity]>=world.idle_despawn_seconds then
        sessions[entity],idle[entity]=nil,nil
        eq.depop()
    end
end
function M.despawn(e)
    local id=e.self:GetID();sessions[id],idle[id]=nil,nil
end
return M
