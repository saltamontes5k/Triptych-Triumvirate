-- Original concise dialogue; native tasks own progress and rewards.
local repeatable={[5436]=false}
local function yes(v) return v==true or v==1 end
local function offers(e,ids)
 if e.other:GetLevel()<10 then e.self:Say("Return after you have gained more experience.");return end
 local choices={}
 for _,id in ipairs(ids)do if not yes(eq.is_task_active(id)) and(repeatable[id]or not yes(eq.is_task_completed(id)))then choices[#choices+1]=id end end
 if #choices>0 then eq.task_selector(choices)else e.self:Say("Finish your current work before accepting another task.")end
end
local function native_handin(e)
 local handin,required,items={},{},{}
 for i=1,4 do
  local inst=e.trade["item"..i]
  if inst and inst.valid then
   items[#items+1]=inst;local id=tostring(inst:GetID())
   handin[id]=(handin[id]or 0)+(inst:IsStackable()and inst:GetCharges()or 1)
   local delivered=inst:GetTaskDeliveredCount();if delivered>0 then required[id]=(required[id]or 0)+delivered end
  end
 end
 for _,coin in ipairs({"copper","silver","gold","platinum"})do if(e.trade[coin]or 0)>0 then handin[coin]=e.trade[coin]end end
 if next(required)and e.self:CheckHandin(e.other,handin,required,items)then e.self:Say("Thank you. Your work has been recorded.")end
 e.self:ReturnHandinItems(e.other)
end

function event_say(e)
 local text=e.message:lower()
 if text:find("work",1,true)or text:find("task",1,true)then offers(e,{10640})
 elseif text:find("hail",1,true)then e.self:Say("I need Shelga's ingredient pouch. Ask for [work] if you can recover it.")end
end
function event_trade(e)native_handin(e)end
