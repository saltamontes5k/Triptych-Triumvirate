-- Native tasks own item consumption, objective counters, XP, choices and persistence.
local D=require('achievement_quest_stonehive_data')
local B=require('achievement_quest_blightfire')
local S=require('achievement_quest_stonehive_scenes')
local M={}
local function yes(v)return v==true or v==1 end
local function active(c,id,a)return yes(c:IsTaskActive(id))and(a==nil or yes(c:IsTaskActivityActive(id,a)))end
local function key(series,suffix)return'achievement.may2013.stonehive.'..series..'.'..suffix end
local function series_for(id)
 for name,ids in pairs(D.series)do for i,v in ipairs(ids)do if v==id then return name,ids,i end end end
end
local function position(c,name)
 local ids=D.series[name]
 for i,id in ipairs(ids)do if active(c,id)then return i end end
 local saved=tonumber(c:GetBucket(key(name,'next')))
 if saved and saved>=1 and saved<=#ids and saved==math.floor(saved)then
  -- Native abandonment does not fire TASK_FAIL. Detect a previously accepted,
  -- now absent stage when next talking to its giver; restart its whole series.
  if tonumber(c:GetBucket(key(name,'accepted')))==ids[saved]then
   c:SetBucket(key(name,'next'),'1');c:SetBucket(key(name,'accepted'),'0');return 1
  end
  return saved
 end
 for i,id in ipairs(ids)do if not yes(c:IsTaskCompleted(id))then return i end end
 return 1
end
local function supply(c,id)
 if c:CountItem(id)==0 then c:SummonItem(id,1)end
end
local function appropriate(c,t)
 if active(c,t.id)or not yes(eq.is_task_appropriate(t.id))then return false end
 for _,p in ipairs(t.prerequisites)do if not yes(c:IsTaskCompleted(p))then return false end end
 local name,ids,i=series_for(t.id)
 return not name or position(c,name)==i
end
-- Ground-object pickup callbacks precede the inventory transfer and can be vetoed.
-- Record a short-lived receipt, then credit only after the item actually arrives.
local pickups={[54641]=2,[54640]=3}
local function pickup_key(id)return key('pickup',tostring(id))end
local function settle_pickups(c)
 local pending=false
 for id,a in pairs(pickups)do
  local raw=c:GetBucket(pickup_key(id))or''
  local baseline,stamp=raw:match('^(%d+):(%d+)$')
  baseline,stamp=tonumber(baseline),tonumber(stamp)
  if baseline then
   if not active(c,3040304,a)or os.time()-stamp>15 then c:SetBucket(pickup_key(id),'')
   elseif c:CountItem(id)>baseline then
    c:SetBucket(pickup_key(id),'');c:UpdateTaskActivity(3040304,a,1)
   else pending=true end
  end
 end
 if not pending then c:StopTimer('achievement_stone_pickup')end
 return pending
end
function M.pickup(e)
 if eq.get_zone_id()~=396 or not e.item then return end
 local id=e.item:GetID();local a=pickups[id];local c=e.self
 if not a or not active(c,3040304,a)then return end
 -- Keep the earliest baseline if several callbacks precede the first timer.
 local raw=c:GetBucket(pickup_key(id))or''
 local stamp=tonumber(raw:match('^%d+:(%d+)$'))
 if not stamp or os.time()-stamp>15 then c:SetBucket(pickup_key(id),tostring(c:CountItem(id))..':'..tostring(os.time()))end
 c:SetTimer('achievement_stone_pickup',1)
end
local function arm(c)
 if settle_pickups(c)then c:SetTimer('achievement_stone_pickup',1)end
 if eq.get_zone_id()==396 and(active(c,3040304,0)or active(c,3040305))then c:SetTimer('achievement_stone_explore',2)end
 local pending=tonumber(c:GetBucket('achievement.may2013.stonehive.auto'))or 0
 if pending>0 then c:SetTimer('achievement_stone_auto',2)end
end
function M.accepted(e)
 local t=D.tasks[e.task_id];if not t then return end
 local name,ids,i=series_for(e.task_id)
 if name then e.self:SetBucket(key(name,'next'),tostring(i));e.self:SetBucket(key(name,'accepted'),tostring(e.task_id))end
 if e.task_id==3040301 then supply(e.self,54622)elseif e.task_id==3040303 then supply(e.self,54624)end
 if tonumber(e.self:GetBucket('achievement.may2013.stonehive.auto'))==e.task_id then e.self:SetBucket('achievement.may2013.stonehive.auto','0')end
 arm(e.self)
end
function M.complete(e)
 if not D.tasks[e.task_id]then return end
 local name,ids,i=series_for(e.task_id)
 if name then
  e.self:SetBucket(key(name,'accepted'),'0');e.self:SetBucket(key(name,'next'),tostring(i==#ids and 1 or i+1))
  if name=='scout'and i<=3 then
   -- TASK_COMPLETE precedes removal of the current slot. Defer assignment so
   -- a full journal can free that slot before the next task is added.
   e.self:SetBucket('achievement.may2013.stonehive.auto',tostring(ids[i+1]));e.self:SetTimer('achievement_stone_auto',2)
  end
 end
end
function M.failed(e)
 local name=series_for(e.task_id);if not name then return end
 e.self:SetBucket(key(name,'next'),'1');e.self:SetBucket(key(name,'accepted'),'0')
 if name=='scout'then e.self:SetBucket('achievement.may2013.stonehive.auto','0');e.self:StopTimer('achievement_stone_auto')end
end
function M.enter(e)arm(e.self)end
function M.say(e)
 local c=e.other;local n=e.self:GetNPCTypeID();local text=e.message:lower()
 -- Preserve earlier Supply Runner and any other native task-delivery behavior.
 B.say(e)
 if n==396229 then
  if active(c,3040301,0)then supply(c,54622)end
  if active(c,3040303,0)then supply(c,54624)end
  return
 end
 if n==396123 and text:find('suit up',1,true)then
  if active(c,3040316)then c:SpellFinished(D.disguise.spell,c)end
  return
 end
 if not(text:find('hail',1,true)or text:find('flora',1,true)or text:find('wings',1,true)or text:find('antennae',1,true)or text:find('heads',1,true)or text:find('jumjum',1,true)or text:find('juzzulli',1,true)or text:find('safer',1,true)or text:find('plans',1,true)or text:find('numbers',1,true)or text:find('destroy',1,true))then return end
 if n==395211 and active(c,3040301,0)then supply(c,54622)end
 local ids={}
 for _,id in ipairs(D.givers[n]or{})do
  local t=D.tasks[id]
  if appropriate(c,t)then
   if id~=3040305 or text:find('juzzulli',1,true)then ids[#ids+1]=id end
  end
 end
 if #ids>0 then eq.task_selector(ids)
 elseif n==395211 and position(c,'scout')==5 and not active(c,3040305)then e.self:Say('Ask me about Juzzulli when you are ready to stop her research.')end
end
function M.trade(e)settle_pickups(e.other);B.trade(e)end
local function near(c,p)
 local dx,dy=c:GetX()-p.x,c:GetY()-p.y
 return dx*dx+dy*dy<=D.radii.horizontal*D.radii.horizontal and math.abs(c:GetZ()-p.z)<=D.radii.vertical
end
function M.timer(e)
 local c=e.self
 if e.timer=='achievement_stone_pickup'then
  settle_pickups(c)
 elseif e.timer=='achievement_stone_auto'then
  local id=tonumber(c:GetBucket('achievement.may2013.stonehive.auto'))or 0
  if id<3040302 or id>3040304 then c:StopTimer(e.timer);return end
  if active(c,id)then c:SetBucket('achievement.may2013.stonehive.auto','0');c:StopTimer(e.timer);return end
  c:AssignTask(id,0,true)
  if active(c,id)then c:SetBucket('achievement.may2013.stonehive.auto','0');c:StopTimer(e.timer)
  else c:Message(13,'The next scout task is waiting. Make room in your quest journal.');c:SetTimer(e.timer,30)end
 elseif e.timer=='achievement_stone_explore'then
  if eq.get_zone_id()~=396 then c:StopTimer(e.timer);return end
  local wanted=active(c,3040304,0)or active(c,3040305)
  if not wanted then c:StopTimer(e.timer);return end
  if active(c,3040304,0)and near(c,D.explore[3040304])then c:UpdateTaskActivity(3040304,0,1)end
  if active(c,3040305)and near(c,D.explore[3040305])then
   if S.ensure_juzz()and active(c,3040305,0)then c:UpdateTaskActivity(3040305,0,1)end
  end
 end
end
return M
