-- Staged reconstruction: provenance and numerical defaults accompany this module.
-- Never install this file alone: tasks, recipes, hooks and item scripts are one batch.
local M = {}
local cfg = require('shards_partisan_config')
-- The May2013 Icescale objective names the existing Iceclaw/Chillclaw family.
local cold_wyvern_ids = {[752048]=true,[752050]=true,[752062]=true}
local function active(c,t,a) return c:IsTaskActivityActive(t,a) end
local function bump(c,t,a,n) if active(c,t,a) then c:UpdateTaskActivity(t,a,n or 1) end end
local function take(c,id,n)
    n=n or 1
    -- Personal inventory/cursor only. Never remove an identical item from bank or shared bank.
    for i=1,n do
        local slot=c:GetInventory():HasItem(id,1,34)
        if slot<0 then return false end
        c:DeleteItemInInventory(slot,1,true)
    end
    return true
end
local function carry(c,id,n)return c:GetInventory():HasItem(id,n or 1,34)>=0 end
local function give(c,id)if not carry(c,id)then c:SummonItem(id)end end
local function near(c,p,r) return c:CalculateDistance(p.x,p.y,p.z)<=(r or cfg.radius) end
local function key(c,t,k) return 'shard.partisan.'..t..'.'..c:GetBucket('shard.run.'..t)..'.'..k end
local function once(c,t,k)
    k=key(c,t,k)
    if c:GetBucket(k)=='1' then return false end
    c:SetBucket(k,'1');return true
end
local function owns_ambush(c,n)
    local gid=tonumber(n:GetEntityVariable('shard.ambush.group'))or 0
    if gid>0 then
        local group=c:GetGroup()
        return group.valid and group:GetID()==gid
    end
    return n:GetEntityVariable('shard.owner')==tostring(c:CharacterID())
end
local function shared_identity(c)
    return c:GetSharedTaskIdentity() -- Lossless native-instance identity; never taskID/groupID.
end
function M.request(c,npc,t)
    local d=cfg.tasks[t]
    if not d or c:GetLevel()<85 or(d.prereq>0 and not c:IsTaskCompleted(d.prereq))then return false end
    if c:IsTaskActive(t)then return true end
    if t==910027 and c:GetBucket('shard.attuned.eastwastesshard')=='1'then return true end
    c:AssignTask(t,npc:GetID())
    return true -- Shared acceptance is asynchronous; task-accepted callback owns epoch initialization.
end
function M.say(e)
    local c,n=e.other,e.self:GetNPCTypeID();local s=e.message:lower()
    if s:find('hail',1,true) then
        for t,d in pairs(cfg.tasks)do
            if n==d.giver and(d.prereq==0 or c:IsTaskCompleted(d.prereq))and not c:IsTaskActive(t)and(t==910020 or not c:IsTaskCompleted(t))then e.self:Say('Ask me about '..eq.say_link(d.keyword)..' to begin '..d.title..'.')end
        end
        -- Native SpeakTo updates happen after EVENT_SAY; stage callback supplies the next step.
        if n==752126 then
            if active(c,910021,12) then give(c,85985) end
        elseif n==752019 then
            if active(c,910023,3) then n=n end -- pelts must be hunted and delivered, not a free suspension.
        elseif n==752107 then
            if active(c,910023,11) and carry(c,86080) and carry(c,86081) and carry(c,86084) then give(c,86085) end
        elseif n==752124 then
            if active(c,910025,16) then give(c,86094) end
        end
        if c:IsTaskActive(910024) then
            local name=e.self:GetCleanName():lower()
            if name:find('shardtender',1,true) and active(c,910024,0) and once(c,910024,'hail'..n) then bump(c,910024,0) end
            if name:find('evoker',1,true) and active(c,910024,1) and once(c,910024,'hail'..n) then bump(c,910024,1) end
        end
    end
    for t,d in pairs(cfg.tasks)do
        if n==d.giver and s:find(d.keyword,1,true) then
            if not M.request(c,e.self,t) then e.self:Say('You must complete the preceding work before I can entrust this task to you.') end
        end
    end
    if n==752129 and s:find('attune',1,true)and active(c,910027,0)then give(c,50884)end
    if n==752124 and s:find('misplaced',1,true) and active(c,910025,16) then give(c,86094) end
end
function M.trade(e)
    local handin,required,items={},{},{}
    for slot=1,4 do
        local inst=e.trade['item'..slot]
        if inst and inst.valid then
            items[#items+1]=inst
            local id=inst:GetID();local count=inst:IsStackable()and inst:GetCharges()or 1
            handin[tostring(id)]=(handin[tostring(id)]or 0)+count
            local used=inst:GetTaskDeliveredCount()
            if used>0 then required[tostring(id)]=(required[tostring(id)]or 0)+used end
        end
    end
    for _,coin in ipairs({'copper','silver','gold','platinum'})do if(e.trade[coin]or 0)>0 then handin[coin]=e.trade[coin]end end
    if next(required)then e.self:CheckHandin(e.other,handin,required,items)end
    e.self:ReturnHandinItems(e.other)
    if e.self:GetNPCTypeID()==752019 and active(e.other,910023,5)then give(e.other,86078)end
end
function M.pickup(e)
    local id=e.item:GetID()
    -- Ground pickup callbacks may precede final custody; the zone timer checks carried papers.
end
function M.combine_validate(e)
    local t=cfg.recipes[e.recipe_id]
    if not t then return 0 end
    if not e.self:IsTaskActive(t.task)or not active(e.self,t.task,t.activity)then return 1 end
    if e.self:GetItemIDAt(33)>0 then e.self:Message(13,'Please empty your cursor before this quest combine.');return 1 end
    return 0
end
function M.combine_success(e)
    local r=e.recipe_id;local c=e.self
    if r==30752001 then bump(c,910021,12)
    elseif r==30752002 then
        -- Period Dec1 2012: five language points below80, one thereafter, capped100.
        local lang=c:GetLanguageSkill(25)
        if lang<100 then
            c:SetLanguageSkill(25,math.min(100,lang+(lang<80 and 5 or 1)))
            return -- At less than100 the combine trains language and returns its inputs.
        end
        if lang==100 then
            if take(c,85986)then
                if take(c,85987)then c:SummonItem(85989);bump(c,910021,13)else c:SummonItem(85986)end
            end
        end
    elseif r==30752003 then bump(c,910023,9)
    elseif r==30752004 then bump(c,910023,11)
    elseif r==30752005 then bump(c,910025,16)end
end
local function autogift(c,t,a,item)
    if active(c,t,a)then c:SummonItem(item);bump(c,t,a)end
end
function M.killed(e)
    local c,n=e.other,e.self;local name=n:GetCleanName():lower();local z=eq.get_zone_id()
    if z==752 then
        if c:IsTaskActive(910020)then
            if active(c,910020,0)and(name:find('scarab')or name:find('clickshell'))then give(c,85973)end
            if active(c,910020,0)and(name:find('slitherer')or name:find('slatescale')or name:find('ivyscale'))then give(c,85972)end
            if active(c,910020,0)and carry(c,85972)and carry(c,85973)then
                if take(c,85972)and take(c,85973)then c:SummonItem(85974)end
                local k=key(c,910020,'potions');local count=(tonumber(c:GetBucket(k))or 0)+1;c:SetBucket(k,tostring(count))
                if count>=9 then bump(c,910020,0)end
            end
            local groups={'naeya','icescale','plainsdweller','PEST','icebeak','verdantbeak','worntooth','plainskeeper','frostcoat'}
            for a,g in ipairs(groups)do
                local match=(a==2 and cold_wyvern_ids[n:GetNPCTypeID()])or(a~=2 and name:find(g,1,true))or(g=='PEST'and(name:find('oashim')or name:find('devourer')or name:find('clickshell'))and n:GetX()<-1500)
                if match and active(c,910020,a)and take(c,85974)then bump(c,910020,a);break end
            end
        end
        if c:IsTaskActive(910022)then
            if owns_ambush(c,n)then
                if n:GetEntityVariable('shard.ambush')=='entry'then bump(c,910022,3)end
                if n:GetEntityVariable('shard.ambush')=='exit'then bump(c,910022,14)end
            end
        end
        if name:find('naeya')then autogift(c,910023,3,86079)end
        if name:find('coralspine')then autogift(c,910023,7,86082)end
        if name:find('prowler')and n:GetX()>300 and n:GetY()<-800 then autogift(c,910023,8,86083)end
        if active(c,910026,4)and n:GetRace()==695 and n:GetX()<-1400 then
            bump(c,910026,4)
            if not active(c,910026,4)then give(c,86096)end
        end
        if name:find('soulless attendee',1,true)or name:find('subjugated thrall',1,true)then bump(c,910026,6)end
        if name:find('conscripted')then bump(c,910026,7)end
        if name:find('clergyman')or name:find('calculating overseer')or name:find('ruthless overseer')then bump(c,910026,8)end
        if n:GetEntityVariable('shard.wayward')=='1'and active(c,910025,17)then
            local sid=shared_identity(c)
            if sid~=''and n:GetEntityVariable('shard.shared.identity')==sid and n:GetEntityVariable('shard.nightmare.credited')~='1'then
                n:SetEntityVariable('shard.nightmare.credited','1');bump(c,910025,17)
            end
        end
    end
    -- Multi-zone shared task: native kill objectives are explicitly classified, never every NPC.
    if c:IsTaskActive(910025)then
        for _,r in ipairs(cfg.fear_groups)do
            if r.zone==z and r.ids[n:GetNPCTypeID()]and active(c,910025,r.kill)then
                local sid=shared_identity(c)
                if sid~=''then
                    local marker='shard.shared.kill.'..sid
                    if n:GetEntityVariable(marker)~='1'then
                        n:SetEntityVariable(marker,'1');bump(c,910025,r.kill)
                    end
                end
            end
        end
    end
end
function M.container_open(e)
    -- /open invokes native class62 death. Each corpse receives its own real quest item.
    local id=e.self:GetNPCTypeID();local c=e.other
    if not c or not c.valid then return end
    if c:IsPet()then c=c:GetOwner()end
    if not c or not c.valid or not c:IsClient()then return end
    c=c:CastToClient()
    if (id==752105 or id==752113)and active(c,910023,0)then
        if math.random(100)<=cfg.extractor_chance then e.self:AddItem(86076,1)end
    elseif id==752225 and active(c,910023,1)then e.self:AddItem(86077,1)end
end
function M.spell(e)
    local c=eq.get_entity_list():GetClientByID(e.caster_id)
    if not c.valid then return 0 end
    local sp=e.spell_id
    if sp==23998 then
        local started=tonumber(c:GetEntityVariable('shard.dire.cast'))or 0
        if eq.get_zone_id()==755 and active(c,910027,0)and os.time()-started>=29 and os.time()-started<=45 then
            c:SetEntityVariable('shard.dire.cast','0');bump(c,910027,0)
        end
        return 0
    end
    if eq.get_zone_id()~=752 then return 0 end
    local t=e.target
    if sp==33562 and active(c,910023,5)and t.valid and t:IsNPC()and t:GetNPCTypeID()==752049 and c:CalculateDistance(t)<40 then give(c,86080);bump(c,910023,5)
    elseif sp==33563 and active(c,910023,6)and near(c,cfg.pond,100)then give(c,86081);bump(c,910023,6)
    elseif sp==33564 and active(c,910023,14)and t.valid and t:IsNPC()and cfg.soul_targets[t:GetNPCTypeID()]and t:GetHPRatio()<=25 and c:CalculateDistance(t)<=20 then
        if take(c,86086)then c:SummonItem(86087);bump(c,910023,14);t:Kill()end
    elseif sp==33565 and active(c,910025,17)and not near(c,cfg.camp,400)then
        local sid=shared_identity(c)
        if sid==''then return 0 end
        for other in eq.get_entity_list():GetNPCList().entries do
            if other:GetEntityVariable('shard.wayward')=='1'and other:GetEntityVariable('shard.shared.identity')==sid then return 0 end
        end
        if cfg.wayward_npc>0 then
            local n=eq.spawn2(cfg.wayward_npc,0,0,c:GetX()+10,c:GetY(),c:GetZ(),0)
            if n and n.valid then c:SetEntityVariable('shard.nightmare',tostring(n:GetID()));n:SetEntityVariable('shard.owner',tostring(c:CharacterID()));n:SetEntityVariable('shard.wayward','1');n:SetEntityVariable('shard.shared.identity',sid);n:AddToHateList(c,1)end
        end
    end
    return 0
end
function M.enter(c)
    local needed=false
    for t,_ in pairs(cfg.tasks)do if c:IsTaskActive(t)then needed=true;break end end
    if needed then eq.set_timer('shard_partisan',2000,c)end
    local z=eq.get_zone_id()
    if z==752 then bump(c,910027,1)end
    if z==755 then bump(c,910025,0)elseif z==756 then bump(c,910025,5)elseif z==754 then bump(c,910025,10)end
end
function M.tick(c)
    if eq.get_zone_id()~=752 then return end
    if c:GetBucket('shard.attuned.eastwastesshard')=='1'then bump(c,910024,3)end
    for id=85975,85984 do if carry(c,id)then bump(c,910021,id-85974)end end
    if near(c,cfg.city,100)then
        bump(c,910021,0);bump(c,910026,0)
        if active(c,910022,3)then M.ambush(c,'entry')end
    end
    if near(c,cfg.city_exit,100)and active(c,910022,14)then M.ambush(c,'exit')end
    if near(c,cfg.silent,60)then
        bump(c,910026,1)
        if carry(c,86096)then bump(c,910026,5)end
    end
    if active(c,910022,4)or active(c,910022,5)or active(c,910022,6)or active(c,910022,7)or active(c,910022,8)or active(c,910022,9)or active(c,910022,10)or active(c,910022,11)or active(c,910022,12)or active(c,910022,13)then
        for a,p in ipairs(cfg.points)do if near(c,p)and carry(c,85990,10)and carry(c,85991,5)and carry(c,85992)then bump(c,910022,a+3)end end
    end
    -- Stage transitions use actual location checks; timers never complete while outside/sitting is false.
    if near(c,cfg.crystal,60)then
        bump(c,910023,12)
        if active(c,910023,15)and take(c,86087)then c:SetFeigned(true);c:SetAppearance(3,false);bump(c,910023,15)end
    end
    if cfg.heart then
        local k='shard.meditation';local sec=tonumber(c:GetEntityVariable(k))or 0
        if active(c,910024,4)and near(c,cfg.heart,60)and c:IsSitting()then
            if once(c,910024,'meditation-vision')then c:SetHP(math.max(1,math.floor(c:GetHP()/2)))end
            sec=sec+2;c:SetEntityVariable(k,tostring(sec))
            if sec>=cfg.meditation_seconds then bump(c,910024,4)end
        else c:SetEntityVariable(k,'0')end
    end
    local k='shard.sermon';local sec=tonumber(c:GetEntityVariable(k))or 0
    if active(c,910026,2)and near(c,cfg.silent,60)and c:IsSitting()then
        sec=sec+2;c:SetEntityVariable(k,tostring(sec));if sec>=cfg.sermon_seconds then bump(c,910026,2)end
    else c:SetEntityVariable(k,'0')end
    if near(c,cfg.village,150)then bump(c,910026,3)end
    if active(c,910026,9)then
        if near(c,cfg.city_exit,100)then bump(c,910026,9)
        elseif carry(c,86096)then
            local k='shard.head.bite';local sec=(tonumber(c:GetEntityVariable(k))or 0)+2
            if sec>=6 then
                c:Message(13,'The severed head bites your hand!')
                c:Damage(c,math.max(1,math.ceil(c:GetMaxHP()*0.05)),0,0,false);sec=0
            end
            c:SetEntityVariable(k,tostring(sec))
        end
    end
end
function M.loot(e)
    -- Native Loot activities credit only after inventory insertion; never credit EVENT_LOOT.
end
function M.death(e)
    local c=e.other
    if not c or not c.valid then return 0 end
    if c:IsPet()then c=c:GetOwner()end
    if not c or not c.valid or not c:IsClient()then return 0 end
    c=c:CastToClient();local n=e.self;local name=n:GetCleanName():lower()
    if eq.get_zone_id()==752 and c:IsTaskActive(910022)then
        if active(c,910022,0)and n:GetX()<-1500 and(name:find('oashim')or name:find('devourer')or name:find('clickshell')or name:find('scarab'))then n:AddItem(85990,1)end
        if active(c,910022,1)and(name:find('icebeak')or name:find('verdantbeak')or name:find('plainskeeper'))then n:AddItem(85991,1)end
        if active(c,910022,2)and(name:find('wyvern')or name:find('icescale')or name:find('plainsdweller'))then n:AddItem(85992,1)end
    end
    for _,r in ipairs(cfg.fear_groups)do
        if r.zone==eq.get_zone_id()and r.ids[n:GetNPCTypeID()]and active(c,910025,r.kill)and eq.get_task_activity_done_count(910025,r.kill)==r.required-1 then n:AddItem(r.item,1)end
    end
    return 0
end
function M.stage(e)
    local c=e.self
    -- The native engine has already activated the next task stage before this callback.
    if e.task_id==910021 and active(c,910021,12)then give(c,85985)end
    if e.task_id==910023 then
        if active(c,910023,5)then give(c,86078)end
        if active(c,910023,11)and carry(c,86080)and carry(c,86081)and carry(c,86084)then give(c,86085)end
    end
    if e.task_id==910025 then
        if active(c,910025,16)then give(c,86094)end
        if active(c,910025,14)and carry(c,86093)then bump(c,910025,14)end
    end

end
function M.accepted(e)
    if cfg.tasks[e.task_id]then
        local k='shard.run.'..e.task_id
        e.self:SetBucket(k,tostring((tonumber(e.self:GetBucket(k))or 0)+1));M.enter(e.self)
        if e.task_id==910027 then give(e.self,50884)end
    end
end
function M.complete(e)
    if e.task_id==910020 and once(e.self,910020,'six-aa-reward')then e.self:AddAAPoints(6)end
    if e.task_id==910022 and once(e.self,910022,'completion-material-cleanup')then
        -- Reconstruction custody cleanup: keep16materials through both ambushes/locations,
        -- then consume at most the quest quantities from personal/cursor only, never bank.
        take(e.self,85990,10);take(e.self,85991,5);take(e.self,85992,1)
    end
    if e.task_id==910027 then e.self:SetBucket('shard.attuned.eastwastesshard','1');bump(e.self,910024,3)end
    if e.task_id==910026 and once(e.self,910026,'four-aa-reward')then e.self:AddAAPoints(4)end
    if e.task_id==910025 and once(e.self,910025,'six-aa-reward')then e.self:AddAAPoints(6)end
end
function M.ambush(c,kind)
    if cfg.apparition_npc<=0 or not(carry(c,85990,10)and carry(c,85991,5)and carry(c,85992))then return end
    local k='shard.ambush.'..kind
    -- Source5990 permits only one live apparition in the zone, regardless of owner.
    local old=eq.get_entity_list():GetNPCByNPCTypeID(cfg.apparition_npc)
    if old.valid then return end
    local n=eq.spawn2(cfg.apparition_npc,0,0,c:GetX()+10,c:GetY(),c:GetZ(),0)
    if n and n.valid then
        c:SetEntityVariable(k,tostring(n:GetID()))
        local group=c:GetGroup();if group.valid then n:SetEntityVariable('shard.ambush.group',tostring(group:GetID()))end
        n:CloneAppearance(c);n:SetEntityVariable('shard.owner',tostring(c:CharacterID()));n:SetEntityVariable('shard.ambush',kind);n:AddToHateList(c,1)
    end
end
function M.tuning_start(e)
    if e.self:GetID()~=50884 then return 0 end
    local c=e.owner
    if eq.get_zone_id()~=755 or not active(c,910027,0)then
        c:Message(13,"Use this crystal after entering East Wastes: Zeixshi-Kar's Awakening from old East Wastes.")
        return 1
    end
    c:SetEntityVariable('shard.dire.cast',tostring(os.time()))
    return 0
end
function M.door(e)
    if eq.get_zone_id()==752 and e.door:GetDoorID()==102 and e.self:GetBucket('shard.attuned.eastwastesshard')~='1'then
        e.self:Message(13,'Ask Leopold Crunchbasher about attune, then activate your Dire Tuning Crystal in the feartouched East Wastes.')
        return 1
    end
    return 0
end
return M
