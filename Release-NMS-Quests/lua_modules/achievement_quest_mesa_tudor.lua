local D=require('achievement_quest_mesa_tudor_data')
local I=require('achievement_quest_mesa_inventory')
local M={}
local function yes(v)return v==true or v==1 end
local function active(c,r,a)return yes(c:IsTaskActive(r))and(a==nil or yes(c:IsTaskActivityActive(r,a)))end
local timer='achievement_mesa_tudor_gather'
local function poll(c)
 if eq.get_zone_id()~=397 or c:IsDead()then return false end
 local any=false
 for _,r in ipairs(D.rules)do
  if active(c,r.task_id)then
   any=true
   for _,p in ipairs(r.gathers)do
    if active(c,r.task_id,p.activity)and I.count(c,p.item_id)>=p.count then c:UpdateTaskActivity(r.task_id,p.activity,p.count)end
   end
  end
 end
 -- Proximity resources only while the original gather step is open. No
 -- duplicate cursor queue, no bank-based credit, no rewards for inactive tasks.
 for _,p in ipairs(D.resources)do
  local gather
  for _,r in ipairs(D.rules)do if r.task_id==p.task_id then for _,g in ipairs(r.gathers)do if g.item_id==p.item_id then gather=g end end end end
  if gather and active(c,p.task_id,gather.activity)and I.count(c,p.item_id)==0 then
   local dx,dy=c:GetX()-p.x,c:GetY()-p.y
   if dx*dx+dy*dy<=p.radius*p.radius and math.abs(c:GetZ()-p.z)<=p.vertical then
    local valid=true
    if p.water then
     local w=p.water
     valid=math.abs(c:GetX()-w.x)<=w.half_x and math.abs(c:GetY()-w.y)<=w.half_y and math.abs(c:GetZ()-w.z)<=w.half_z
    end
    if p.native_npc_id then
     valid=false
     -- All three original barrels share a type. Find the matching runtime
     -- anchor by position rather than accepting an arbitrary distant barrel.
     for npc in eq.get_entity_list():GetNPCList().entries do
      if npc.valid and npc:GetNPCTypeID()==p.native_npc_id and math.abs(npc:GetX()-p.x)<2 and math.abs(npc:GetY()-p.y)<2 then valid=true;break end
     end
    end
    if valid and I.give(c,p.item_id,1)then c:UpdateTaskActivity(p.task_id,gather.activity,1)end
   end
  end
 end
 return any
end
function M.resume(e)
 local c=e.self
 if poll(c)then c:SetTimer(timer,1)else c:StopTimer(timer)end
end
function M.timer(e)
 if e.timer~=timer then return false end
 if not poll(e.self)then e.self:StopTimer(timer)end
 return true
end
function M.matches(e)
 if eq.get_zone_id()~=397 or e.self:GetNPCTypeID()~=397093 then return false end
 for _,r in ipairs(D.rules)do if active(e.other,r.task_id,r.craft_activity)then return true end end
 return false
end
function M.trade(e)
 if not M.matches(e)then return false end
 local c=e.other;local given,items,total={},{},0
 local coins={copper=1,silver=10,gold=100,platinum=1000}
 for slot=1,4 do local i=e.trade['item'..slot];if i and i.valid then
  items[#items+1]=i;local id=tostring(i:GetID());given[id]=(given[id]or 0)+(i:IsStackable()and math.max(1,i:GetCharges())or 1)
 end end
 for name,value in pairs(coins)do local n=e.trade[name]or 0;if n>0 then given[name]=n;total=total+n*value end end
 local selected
 for _,r in ipairs(D.rules)do
  if active(c,r.task_id,r.craft_activity)then
   local enough=true
   for _,p in ipairs(r.materials)do if(given[tostring(p.item_id)]or 0)<p.quantity then enough=false end end
   if enough then selected=r;break end
  end
 end
 if not selected or c:GetInventory():GetItem(Slot.Cursor).valid then e.self:ReturnHandinItems(c);return true end
 local required={}
 for _,p in ipairs(selected.materials)do required[tostring(p.item_id)]=p.quantity end
 for name in pairs(coins)do if given[name]then required[name]=given[name]end end
 local consumed=e.self:CheckHandin(c,given,required,items)
 if not consumed then e.self:ReturnHandinItems(c);return true end
 -- Liviu's original four-ingredient alternative is free. Any offered money
 -- is explicitly returned even though CheckHandin must match denominations.
 if total>0 then c:AddMoneyToPP(given.copper or 0,given.silver or 0,given.gold or 0,given.platinum or 0,true)end
 if I.give(c,selected.output,1)then c:UpdateTaskActivity(selected.task_id,selected.craft_activity,1)
 else
  -- Inputs are plain original quest/tradeskill items. Restore exact consumed
  -- quantities if the non-lore output cannot be granted; leave craft uncredited.
  for _,p in ipairs(selected.materials)do c:SummonItem(p.item_id,p.quantity)end
 end
 e.self:ReturnHandinItems(c);return true
end
return M
