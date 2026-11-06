-- Native tasks own kills, loot, exploration, hand-ins, rewards and persistence.
-- This module supplies quest items and preserves researched transport access.
local D=require('achievement_quest_roost_data')
local I=require('achievement_quest_mesa_inventory')
local B=require('achievement_quest_blightfire')
local M={}
local timer='achievement_roost_inventory'
local prefix='achievement.may2013.roost.'
local function yes(v)return v==true or v==1 end
local function active(c,id,a)
 return yes(c:IsTaskActive(id))and(a==nil or yes(c:IsTaskActivityActive(id,a)))
end
local function cycle(c)
 local stage=tonumber(c:GetBucket(prefix..'cycle'))
 if stage and stage==math.floor(stage)and stage>=1 and stage<=6 then return stage end
 for index,id in ipairs(D.series)do if not yes(c:IsTaskCompleted(id))then return index end end
 return 1
end
local function access(c)
 local value=tonumber(c:GetBucket(prefix..'access'))or 0
 for index=1,5 do
  if yes(c:IsTaskCompleted(D.series[index]))then value=math.max(value,index)end
 end
 return math.min(5,math.max(0,math.floor(value)))
end
local function supply(c,id)
 if I.count(c,id)>0 then return true end
 return I.give(c,id)
end
local function arm(c)
 if eq.get_zone_id()==398 and active(c,D.feathers)then c:SetTimer(timer,1)
 else c:StopTimer(timer)end
end
function M.resume(e)arm(e.self)end
function M.accepted(e)
 local t=D.tasks[e.task_id];if not t then return end
 for _,item in ipairs(t.accept_items)do supply(e.self,item.item_id)end
 arm(e.self)
end
function M.complete(e)
 local t=D.tasks[e.task_id];if not t then return end
 if t.series_stage then
  local c=e.self
  if t.series_stage<=5 then c:SetBucket(prefix..'access',tostring(math.max(access(c),t.series_stage)))end
  c:SetBucket(prefix..'cycle',tostring(t.series_stage==6 and 1 or t.series_stage+1))
 end
 arm(e.self)
end
local function appropriate(c,t,n)
 if active(c,t.id)or not yes(eq.is_task_appropriate(t.id))then return false end
 if t.series_stage and cycle(c)~=t.series_stage then return false end
 if not t.series_stage then
  for _,id in ipairs(t.prerequisites)do if not yes(c:IsTaskCompleted(id))then return false end end
 end
 local f=c:GetFactionLevel(c:CharacterID(),n:GetNPCTypeID(),c:GetBaseRace(),c:GetClass(),c:GetDeity(),n:GetPrimaryFaction(),n)
 return f<Faction.Threatenly
end
function M.say(e)
 local ids=D.givers[e.self:GetNPCTypeID()];if not ids then return false end
 local text=e.message:lower();local c=e.other;local n=e.self:GetNPCTypeID()
 -- A lost item or full cursor must not strand an accepted quest. Recovery
 -- never advances an objective or consumes an unrelated item.
 for _,id in ipairs(ids)do
  local t=D.tasks[id]
  if active(c,id)then
   if text:find('supplies',1,true)then
    for _,item in ipairs(t.accept_items)do supply(c,item.item_id)end
   end
   for _,a in ipairs(t.activities)do
    if a.grant_item and(a.npc_id==n)and active(c,id,a.activity_id)then supply(c,a.grant_item)end
    if a.recovery_item and a.recovery_npc==n and active(c,id,a.activity_id)then supply(c,a.recovery_item)end
   end
  end
 end
 local wanted=text:find('hail',1,true)or text:find('help',1,true)or text:find('task',1,true)
 for _,word in ipairs(D.keywords[n]or{})do if text:find(word,1,true)then wanted=true end end
 if wanted then
  local choices={}
  for _,id in ipairs(ids)do if appropriate(c,D.tasks[id],e.self)then choices[#choices+1]=id end end
  if #choices>0 then eq.task_selector(choices)end
 end
 return true
end
function M.trade(e)B.trade(e)end
function M.before_update(e)
 local t=D.tasks[e.task_id];if not t then return 0 end
 local a=t.activities[e.activity_id+1]
 if not a or not a.anchor then return 0 end
 -- The core has already matched the real item and NPC type. Reject the
 -- wrong island before it credits or tags a handed-in item for consumption.
 local c=e.self;local p=a.anchor
 local dx,dy=c:GetX()-p.x,c:GetY()-p.y
 if eq.get_zone_id()~=398 or dx*dx+dy*dy>D.handin_reach*D.handin_reach or math.abs(c:GetZ()-p.z)>D.handin_vertical then
  c:Message(13,'This treat belongs to a different griffon.');return 1
 end
 return 0
end
function M.click_door(e)
 if eq.get_zone_id()~=398 or not e.door or not e.door.valid then return 0 end
 local gate=D.gates[e.door:GetDoorID()];if not gate then return 0 end
 if e.door:GetDoorDBID()~=gate.db_id or e.door:GetDoorName():upper()~='OBJ_GRIFFNEST'then return 0 end
 if access(e.self)<gate.stage then
  e.self:Message(13,'The griffon is not ready to carry you farther yet.');return 1
 end
 return 0
end
function M.timer(e)
 if e.timer~=timer then return false end
 local c=e.self
 if eq.get_zone_id()~=398 or not active(c,D.feathers)then c:StopTimer(timer);return true end
 local t=D.tasks[D.feathers]
 for _,a in ipairs(t.activities)do
  if a.inventory_item and active(c,t.id,a.activity_id)and I.count(c,a.inventory_item)>=1 then
   c:UpdateTaskActivity(t.id,a.activity_id,1)
  end
 end
 return true
end
return M
