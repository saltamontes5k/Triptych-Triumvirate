-- Native tasks own kills, loot custody, deliveries, rewards and persistence.
local D=require('achievement_quest_vergalid_data')
local B=require('achievement_quest_blightfire')
local A=require('vergalid_scene_native')
local M={}
local function yes(v)return v==true or v==1 end
local function active(c,id)return yes(c:IsTaskActive(id))end
local function inside(c,b)return c:GetX()>=b.minx and c:GetX()<=b.maxx and c:GetY()>=b.miny and c:GetY()<=b.maxy and c:GetZ()>=b.minz and c:GetZ()<=b.maxz end
function M.eligible(c,t)
 if not D.enabled or not t or not t.enabled or not t.min_level or c:GetLevel()<t.min_level or active(c,t.id)then return false end
 if not t.repeatable and yes(c:IsTaskCompleted(t.id))then return false end
 for _,id in ipairs(t.prerequisites)do if not yes(c:IsTaskCompleted(id))then return false end end
 return yes(eq.is_task_appropriate(t.id))
end
function M.say(e)
 if not D.enabled then return end
 local npc=e.self:GetNPCTypeID();local ids=D.givers[npc];if not ids then return end
 -- Let a genuine hail or quest-related response show the available selector.
 -- Opening that selector never issues supplies or kills the original giver.
 local text=e.message:lower();local requested=text:find('hail',1,true)or text:find('task',1,true)
 if not requested then for _,word in ipairs({'bonesnapper','services','vergalak','drakkin','disrupted','brother','valuable information','ancient creature','exploration','drudgeweed','saliva','eaten','artifacts','stone sentinel','tablet'})do
  if text:find(word,1,true)then requested=true;break end
 end end
 if not requested then return end
 if npc==D.gygun.npc then
  local key='achievement.may2013.vergalid.gygun.first_hail'
  if e.other:GetBucket(key)~='1'then
   e.other:SetBucket(key,'1');e.self:Say('I have been stranded here. Please hear my last request.');return
  end
 end
 local choices={};for _,id in ipairs(ids)do if M.eligible(e.other,D.tasks[id])then choices[#choices+1]=id end end
 if #choices>0 then eq.task_selector(choices)end
end
function M.accepted(e)
 if not D.enabled then return end
 local t=D.tasks[e.task_id];local c=e.other
 if not t or not t.enabled or not c or not c.valid or not active(c,t.id)or e.self:GetNPCTypeID()~=t.giver then return end
 A.accepted(c,t.id)
 local item=D.supply_items[t.id]
 if item and c:CountItem(item)==0 then c:SummonItem(item,1)end
 -- The actual accepted native task and successful note custody precede death.
 -- No dying actor on a mere hail, failed offer or opened selector.
 if t.id==D.gygun.task and c:CountItem(D.gygun.note)>0 then e.self:Kill()end
end
local function needs_timer(c)
 if A.needs_timer(c)then return true end
 for id,t in pairs(D.tasks)do if t.enabled and active(c,id)then
  for _,a in ipairs(t.activities)do if a.owner=='geometry'and yes(c:IsTaskActivityActive(id,a.activityid))then return true end end
 end end
 return false
end
function M.resume(e)
 if D.enabled and needs_timer(e.self)then e.self:SetTimer(D.timer,1)else e.self:StopTimer(D.timer)end
end
function M.timer(e)
 if e.timer~=D.timer then return false end
 if not D.enabled then e.self:StopTimer(D.timer);return true end
 local c=e.self
 for id,t in pairs(D.tasks)do if t.enabled and active(c,id)then
  for _,a in ipairs(t.activities)do
   if a.owner=='geometry'and a.zone==eq.get_zone_id()and yes(c:IsTaskActivityActive(id,a.activityid))and
      (a.geometry_mode=='zone'or(a.bounds and inside(c,a.bounds)))then
    c:UpdateTaskActivity(id,a.activityid,1)
   end
  end
 end end
 A.tick(c);M.resume(e);return true
end
function M.trade(e)
 if not D.enabled or not D.givers[e.self:GetNPCTypeID()]then return end
 -- Core marked GetTaskDeliveredCount; consume exactly that custody, returning
 -- unrelated items and excess stacks. Never count possession as a new loot.
 return B.trade(e)
end
return M
