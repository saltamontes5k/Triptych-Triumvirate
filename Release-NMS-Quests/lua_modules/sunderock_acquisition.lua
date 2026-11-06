-- Acquisition and physical exploration only. Core owns task completion/rewards.
local D=require('achievement_quest_sunderock_data')
local M={}
local timer='achievement_sunderock'
local note_key='achievement.may2013.sunderock.note_receipt'
local egg_marker='achievement.may2013.sunderock.egg_created'
local function yes(v)return v==true or v==1 end
local function active(c,t,a)return yes(c:IsTaskActive(t))and(a==nil or yes(c:IsTaskActivityActive(t,a)))end
local function inside(c,b)return c:GetX()>=b.minx and c:GetX()<=b.maxx and c:GetY()>=b.miny and c:GetY()<=b.maxy and c:GetZ()>=b.minz and c:GetZ()<=b.maxz end
local function needs_timer(c)
 if c:GetBucket(note_key)~=''then return true end
 for id,t in pairs(D.tasks)do if active(c,id)then for _,a in ipairs(t.activities)do if a.owner=='geometry'and active(c,id,a.activityid)then return true end end end end
 return false
end
local function arm(c)if D.enabled and needs_timer(c)then c:SetTimer(timer,1)else c:StopTimer(timer)end end
function M.egg(tender)
 if not D.enabled or eq.get_zone_id()~=398 or not tender or not tender.valid then return end
 local e=D.acquisition.egg
 if tender:GetNPCTypeID()~=e.tender_npc or tender:GetSpawnPointID()~=e.tender_spawn or tender:GetEntityVariable(egg_marker)=='2'then return end
 for o in eq.get_entity_list():GetObjectList().entries do
  if o.valid and o:GetItemID()==e.item then tender:SetEntityVariable(egg_marker,'1');return end
 end
 local p=e.position
 -- A zero decay time retains the actual ground item until pickup/zone shutdown.
 -- It returns only with a new original tender spawn, not a free-running timer.
 local id=eq.create_ground_object(e.item,p.x,p.y,p.z,p.heading,0)
 if id and id~=0 then tender:SetEntityVariable(egg_marker,'1')end
end
function M.resume(e)
 if not D.enabled then return end
 if eq.get_zone_id()==398 then
  local r=D.acquisition.egg
  local tender=eq.get_entity_list():GetNPCByNPCTypeID(r.tender_npc)
  -- State saves retain NPC variables, but one-shot ground objects disappear
  -- on zone shutdown. Restore an uncollected egg; only a native loot update
  -- after actual inventory custody marks this tender's egg as collected.
  if tender.valid and tender:GetSpawnPointID()==r.tender_spawn
   and tonumber(e.task_id)==r.task and tonumber(e.activity_id)==r.loot_activity
   and (tonumber(e.count)or 0)>0 and e.self:CountItem(r.item)>0 then
   tender:SetEntityVariable(egg_marker,'2')
  end
  M.egg(tender)
 end
 arm(e.self)
end
function M.pickup(e)
 if not D.enabled or not e.item or not e.item.valid then return 0 end
 local r=D.acquisition.egg
 if e.item:GetID()~=r.item then return 0 end
 if eq.get_zone_id()~=398 or not active(e.self,r.task,r.loot_activity)then
  e.self:Message(13,'You must first complete the nesting-site objectives before taking this egg.')
  return 1 -- Native pre-transfer veto leaves the actual ground item in place.
 end
 return 0 -- Successful custody and loot credit remain entirely native.
end
function M.loot(e)
 if not D.enabled or eq.get_zone_id()~=403 or not e.item or not e.item.valid or not e.corpse or not e.corpse.valid then return 0 end
 local n=D.acquisition.note
 if e.item:GetID()~=n.item or e.corpse:GetNPCTypeID()~=n.npc or active(e.self,n.task)then return 0 end
 -- EVENT_LOOT precedes transfer and can still be vetoed elsewhere. Offer only
 -- after a later observation proves the actual note entered possessions.
 e.self:SetBucket(note_key,tostring(e.self:CountItem(n.item))..':'..os.time())
 arm(e.self)
 return 0
end
function M.timer(e)
 if e.timer~=timer then return false end
 if not D.enabled then e.self:StopTimer(timer);return true end
 local c=e.self;local raw=c:GetBucket(note_key)
 local before,stamp=raw:match('^(%d+):(%d+)$');before,stamp=tonumber(before),tonumber(stamp)
 if before then
  local n=D.acquisition.note
  if active(c,n.task)or os.time()-stamp>15 then c:SetBucket(note_key,'')
  elseif c:CountItem(n.item)>before then
   c:SetBucket(note_key,'')
   if c:GetLevel()>=D.tasks[n.task].min_level then c:TaskSelector({n.task})end
  end
 elseif raw~=''then c:SetBucket(note_key,'')end
 for id,t in pairs(D.tasks)do
  if t.enabled and active(c,id)then
   for _,a in ipairs(t.activities)do
    if a.owner=='geometry'and a.bounds and eq.get_zone_id()==a.zone and active(c,id,a.activityid)and inside(c,a.bounds)then c:UpdateTaskActivity(id,a.activityid,1)end
   end
  end
 end
 arm(c);return true
end
function M.actor_spawn(e)
 if not D.enabled then return end
 local id=e.self:GetNPCTypeID();local cfg=D.acquisition
 if id==cfg.egg.tender_npc and eq.get_zone_id()==398 then M.egg(e.self)end
 if eq.get_zone_id()==403 then
  for _,spawn in ipairs(cfg.courier.guard_spawns)do if e.self:GetSpawnPointID()==spawn then eq.set_timer('sunderock_courier_follow',2000);break end end
 end
end
function M.actor_timer(e)
 if e.timer~='sunderock_courier_follow'then return false end
 if not D.enabled then eq.stop_timer(e.timer);return true end
 local cfg=D.acquisition.courier;local distance
 for i,id in ipairs(cfg.guard_spawns)do if e.self:GetSpawnPointID()==id then distance=cfg.follow_distances[i];break end end
 if not distance then eq.stop_timer(e.timer);return true end
 local lead=eq.get_entity_list():GetNPCByNPCTypeID(cfg.npc)
 if lead.valid and lead:GetSpawnPointID()==cfg.spawn and not e.self:IsEngaged()then
  local dx,dy=lead:GetX()-e.self:GetX(),lead:GetY()-e.self:GetY()
  if dx*dx+dy*dy<=10000 or e.self:GetFollowID()==lead:GetID()then
   e.self:SetFollowDistance(distance);e.self:SetFollowCanRun(true);e.self:SetFollowID(lead:GetID())
  end
 elseif not lead.valid then e.self:SetFollowID(0)end
 return true
end
function M.pod_death(e)
 if not D.enabled or eq.get_zone_id()~=403 or e.self:GetNPCTypeID()~=D.acquisition.pod.npc then return end
 local key='achievement.may2013.sunderock.pod_budded'
 if e.self:GetEntityVariable(key)=='1'then return end
 e.self:SetEntityVariable(key,'1')
 local p=D.acquisition.pod;local killer=eq.get_entity_list():GetMobID(e.killer_id or 0)
 for i=1,math.random(p.minimum,p.maximum)do
  local angle=i*2.3999632297
  local n=eq.spawn2(p.bud_npc,0,0,e.self:GetX()+math.cos(angle)*p.spawn_radius,e.self:GetY()+math.sin(angle)*p.spawn_radius,e.self:GetZ(),0)
  if n and n.valid and killer and killer.valid then n:AddToHateList(killer,1)end
 end
end
return M
