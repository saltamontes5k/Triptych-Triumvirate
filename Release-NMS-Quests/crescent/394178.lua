-- Reconstructed dialogue, original task-objective custody. See provenance.json.
local function yes(v) return v==true or v==1 end
function event_say(e)
 local text=e.message:lower()
 if text:find("gather",1,true)then
  if e.other:GetLevel()<5 then e.self:Say("Return when you have reached level five.");return end
  if not yes(eq.is_task_active(3039701))then eq.task_selector({3039701})end
 elseif text:find("look",1,true)then
  if e.other:GetLevel()<5 then e.self:Say("Return when you have reached level five.");return end
  if not yes(eq.is_task_active(3039702))then eq.task_selector({3039702})end
 elseif text:find("work",1,true)then
  e.self:Say("A council gathering needs refreshments. Could you [help] me prepare?")
 elseif text:find("help",1,true)then
  e.self:Say("My lemonade was [left] in the puma cave. I need someone to fetch it.")
 elseif text:find("left",1,true)then
  e.self:Say("A crate in the puma cave holds the missing bottle. Will you [look] for it?")
 elseif text:find("experiments",1,true)then
  e.self:Say("I am trying a convenient pocket [flan], but need a few special ingredients.")
 elseif text:find("flan",1,true)then
  e.self:Say("The mushroom grove has the truffles I need. Could you [gather] six for me?")
 elseif text:find("hail",1,true)then
  e.self:Say("There is always [work] to do for the council, and my baking [experiments] could use a hand.")
 end
end
function event_trade(e)
 local handin,required,items={},{},{}
 for i=1,4 do
  local inst=e.trade["item"..i]
  if inst and inst.valid then
   items[#items+1]=inst
   local id=tostring(inst:GetID())
   handin[id]=(handin[id]or 0)+(inst:IsStackable()and inst:GetCharges()or 1)
   local delivered=inst:GetTaskDeliveredCount()
   if delivered>0 then required[id]=(required[id]or 0)+delivered end
  end
 end
 for _,coin in ipairs({"copper","silver","gold","platinum"})do
  if(e.trade[coin]or 0)>0 then handin[coin]=e.trade[coin]end
 end
 if next(required)then e.self:CheckHandin(e.other,handin,required,items)end
 e.self:ReturnHandinItems(e.other)
end
