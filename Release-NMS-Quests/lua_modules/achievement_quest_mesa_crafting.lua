-- Explicit, bounded NPC crafting. No cash-only task objective: the core's
-- GiveCash path records credit without consuming coins. Consume/refund through
-- one CheckHandin operation, while native Deliver counters own material state.
local rules=require('achievement_quest_mesa_crafting_data')
local I=require('achievement_quest_mesa_inventory')
local M={}
local coins={'copper','silver','gold','platinum'}
local worth={copper=1,silver=10,gold=100,platinum=1000}
local function yes(v)return v==true or v==1 end
local function active(c,t,a)return yes(c:IsTaskActive(t))and yes(c:IsTaskActivityActive(t,a))end
local function offer(e)
 local given,used,items={},{},{}
 for slot=1,4 do
  local i=e.trade['item'..slot]
  if i and i.valid then
   items[#items+1]=i
   local id=tostring(i:GetID());local n=i:IsStackable()and math.max(1,i:GetCharges())or 1
   given[id]=(given[id]or 0)+n
   local consumed=i:GetTaskDeliveredCount()
   if consumed>0 then used[id]=(used[id]or 0)+consumed end
  end
 end
 local total=0
 for _,coin in ipairs(coins)do
  local n=e.trade[coin]or 0
  if n>0 then given[coin]=n;total=total+n*worth[coin]end
 end
 return given,used,items,total
end
local function refund(c,given)
 c:AddMoneyToPP(given.copper or 0,given.silver or 0,given.gold or 0,given.platinum or 0,true)
end
function M.before_update(e)
 for _,r in ipairs(rules)do
  if r.task_id==e.task_id and #r.craft_activities>0 then
   local raw=false
   for _,p in ipairs(r.materials)do if p.activity==e.activity_id then raw=true end end
   if raw then
    local unfinished=false
    for _,a in ipairs(r.craft_activities)do if active(e.self,r.task_id,a.activity)then unfinished=true end end
    -- Native optional activities remain active in prior steps. Once a player
    -- finishes their own combines, reject optional deliveries before the core
    -- tags/consumes any raw material. The final gift hand-in is unaffected.
    if not unfinished then return 1 end
   end
  end
 end
 return 0
end
function M.matches(e)
 for _,r in ipairs(rules)do
  if r.zone_id==eq.get_zone_id()and r.npc_id==e.self:GetNPCTypeID()and active(e.other,r.task_id,r.fee_activity)then return true end
 end
 return false
end
function M.trade(e)
 if not M.matches(e)then return false end
 local c=e.other;local selected
 for _,r in ipairs(rules)do
  if r.zone_id==eq.get_zone_id()and r.npc_id==e.self:GetNPCTypeID()and active(c,r.task_id,r.fee_activity)then
   -- A repeated completed task has new native activity state, so no permanent
   -- per-character paid flag or shared NPC multiquest bucket is needed.
   local complete=true
   for _,p in ipairs(r.materials)do if eq.get_task_activity_done_count(r.task_id,p.activity)<p.count then complete=false;break end end
   if complete then selected=r;break end
  end
 end
 local given,used,items,total=offer(e)
 local ready=selected and total==selected.fee_copper
 if ready then
  local unfinished=#selected.craft_activities==0
  for _,a in ipairs(selected.craft_activities)do if active(c,selected.task_id,a.activity)then unfinished=true end end
  ready=unfinished and not c:GetInventory():GetItem(Slot.Cursor).valid
  -- CheckHandin rejects a money-only requirement when unrelated items are in
  -- the offer. Return the entire offer instead of consuming unrelated items.
  if not next(used)and #items>0 then ready=false end
 end
 if not next(used)and not ready then
  if selected and total>0 then c:Message(13,'Empty your cursor and pay the exact crafting fee after handing in all materials.')end
  e.self:ReturnHandinItems(c);return true
 end
 local required={}
 for id,n in pairs(used)do required[id]=n end
 -- Match the original denominations exactly. Early/incorrect money is
 -- immediately refunded; native material deposits still consume precisely
 -- GetTaskDeliveredCount, including excess-stack and unrelated-item returns.
 for _,coin in ipairs(coins)do if given[coin]then required[coin]=given[coin]end end
 local consumed=e.self:CheckHandin(c,given,required,items)
 if not consumed then e.self:ReturnHandinItems(c);return true end
 if not ready then
  if total>0 then refund(c,given)end
  e.self:ReturnHandinItems(c);return true
 end
 if not I.give(c,selected.output,1)then
  -- Deposits remain in the native journal and can be retried. Fee is returned
  -- if the actual item grant fails, including a banked lore-item conflict.
  refund(c,given);e.self:ReturnHandinItems(c);return true
 end
 c:UpdateTaskActivity(selected.task_id,selected.fee_activity,1)
 for _,a in ipairs(selected.craft_activities)do
  if active(c,selected.task_id,a.activity)then
   local remaining=a.goal-eq.get_task_activity_done_count(selected.task_id,a.activity)
   if remaining>0 then c:UpdateTaskActivity(selected.task_id,a.activity,remaining)end
  end
 end
 e.self:ReturnHandinItems(c);return true
end
return M
