-- Blightfire Moors reconstruction. Native tasks own kills, loot, deliveries,
-- completion, persistence, XP, item rewards, and achievement criteria.
local data = require('achievement_quest_blightfire_data')
local M = {}
local function yes(v) return v == true or v == 1 end
local function active(id) return yes(eq.is_task_active(id)) end
local function stage(id, index) return active(id) and yes(eq.is_task_activity_active(id,index)) end
local function contains(text,words)
 for _,word in ipairs(words or {}) do if text:find(word,1,true) then return true end end
 return false
end
local rotwood={3039809,3039810,3039811}
local rotwood_index={[3039809]=1,[3039810]=2,[3039811]=3}
local cycle_bucket='achievement.may2013.blightfire.rotwood.next'
local function next_rotwood(client)
 local index=tonumber(client:GetBucket(cycle_bucket))
 if index and index>=1 and index<=3 and index==math.floor(index) then return index end
 -- Existing completion history initializes players upgraded mid-chain.
 for i,id in ipairs(rotwood) do if not yes(eq.is_task_completed(id)) then return i end end
 return 1
end
local function choices(ids,client)
 local result={}
 for _,id in ipairs(ids or {}) do
  local task=data.tasks[id]
  if task and not active(id) and yes(eq.is_task_appropriate(id)) then
   local ready=true
   for _,prior in ipairs(task.prerequisites or {}) do
    if not yes(eq.is_task_completed(prior)) then ready=false end
   end
   -- Repeatability, level gates, and cooldowns remain native selector checks.
   if ready and (not rotwood_index[id] or rotwood_index[id]==next_rotwood(client)) then result[#result+1]=id end
  end
 end
 return result
end
function M.click_door(e)
 local rule=data.signs[e.door:GetDoorID()]
 if not rule then return nil end
 local giver=eq.get_entity_list():GetNPCByNPCTypeID(rule.npc)
 if not giver or not giver.valid then
  e.self:Message(13,'The job board is unavailable. Please report this to the server administrator.')
  return 1
 end
 local ids=choices(rule.tasks,e.self)
 if #ids>0 then
  if not e.self:TaskSelectorFromNPC(giver,ids) then
   e.self:Message(13,'Move closer to the job board and try again.')
  end
 end
 return 1
end
function M.say(e)
 local npc=e.self:GetNPCTypeID()
 local text=e.message:lower()
 -- EVENT_SAY runs before native SpeakWith progression. Reissue only while
 -- the supplies delivery remains pending; never grant task completion here.
 if npc==data.supply.npc and contains(text,{'hail','supplies'}) and
    (stage(data.supply.task,0) or stage(data.supply.task,1)) then
  if e.other:CountItem(data.supply.item)==0 then e.other:SummonItem(data.supply.item,1) end
 end
 local rule=data.givers[npc]
 if not rule then return end
 if contains(text,rule.keywords) then
  local ids=choices(rule.tasks,e.other)
  if #ids>0 then eq.task_selector(ids) end
 elseif contains(text,{'hail'}) then
  e.self:Say(rule.greeting)
 end
end
function M.task_complete(e)
 local index=rotwood_index[e.task_id]
 if index then
  -- This is the core's genuine whole-task completion event, not a hail or
  -- inventory-derived grant. Only chain routing is stored here; all rewards
  -- and achievement progression remain native.
  e.self:SetBucket(cycle_bucket,tostring(index==3 and 1 or index+1))
 end
end
function M.trade(e)
 -- The core has already marked native task-delivery consumption on each
 -- instance. Consume precisely those amounts and return all unrelated items
 -- and coins; do not convert inventory counts into loot-objective credit.
 local handin,required,items={},{},{}
 for slot=1,4 do
  local inst=e.trade['item'..slot]
  if inst and inst.valid then
   items[#items+1]=inst
   local id=tostring(inst:GetID())
   local count=inst:IsStackable() and inst:GetCharges() or 1
   handin[id]=(handin[id] or 0)+count
   local used=inst:GetTaskDeliveredCount()
   if used>0 then required[id]=(required[id] or 0)+used end
  end
 end
 for _,coin in ipairs({'copper','silver','gold','platinum'}) do
  if (e.trade[coin] or 0)>0 then handin[coin]=e.trade[coin] end
 end
 if next(required) then e.self:CheckHandin(e.other,handin,required,items) end
 e.self:ReturnHandinItems(e.other)
end
return M
