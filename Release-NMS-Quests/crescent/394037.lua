local repeatable={[3039601]=true,[3039602]=true,[3039603]=true,[3039604]=true}
local function yes(v)return v==true or v==1 end
local function offers(e,ids)
 if e.other:GetLevel()<15 then e.self:Say("Return when you have reached level fifteen.");return end
 local choices={}
 for _,id in ipairs(ids)do
  if not yes(eq.is_task_active(id))and(repeatable[id]or not yes(eq.is_task_completed(id)))and(id~=3039606 or yes(eq.is_task_completed(3039605)))then choices[#choices+1]=id end
 end
 if #choices>0 then eq.task_selector(choices)else e.self:Say("Complete your current work before asking again.")end
end
local function handin(e)
 local handin,required,items={},{},{}
 for i=1,4 do local inst=e.trade["item"..i]
  if inst and inst.valid then
   items[#items+1]=inst;local id=tostring(inst:GetID());handin[id]=(handin[id]or 0)+(inst:IsStackable()and inst:GetCharges()or 1)
   local delivered=inst:GetTaskDeliveredCount();if delivered>0 then required[id]=(required[id]or 0)+delivered end
  end
 end
 for _,coin in ipairs({"copper","silver","gold","platinum"})do if(e.trade[coin]or 0)>0 then handin[coin]=e.trade[coin]end end
 if next(required)then e.self:CheckHandin(e.other,handin,required,items)end
 e.self:ReturnHandinItems(e.other)
end

local function seeds(e)
 if yes(eq.is_task_active(3039603))and eq.is_task_activity_active(3039603,0)and e.other:CountItem(84231)==0 then e.other:SummonItem(84231);e.self:Say("Keep the seeds in a main inventory slot. Plant across the field, then return.")end
end
function event_task_accepted(e)if e.task_id==3039603 then seeds(e)end end

function event_say(e)
 local text=e.message:lower()
 if text:find("work",1,true)or text:find("task",1,true)or text:find("set them free",1,true)then offers(e,{3039603,3039604}) elseif text:find("seeds",1,true)then seeds(e) elseif text:find("hail",1,true)then e.self:Say("Help us sow the farm and recover our lost locket. Ask for [work] or [seeds].")end
end
function event_trade(e)handin(e)end
