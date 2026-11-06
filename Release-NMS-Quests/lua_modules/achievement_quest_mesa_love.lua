local D=require('achievement_quest_mesa_love_data')
local I=require('achievement_quest_mesa_inventory')
local C=require('achievement_quest_mesa_crafting')
local M={}
local function yes(v)return v==true or v==1 end
local function active(c,t,a)return yes(c:IsTaskActive(t))and(a==nil or yes(c:IsTaskActivityActive(t,a)))end
local function owned(c,id)return c:GetInventory():HasItem(id)>=0 end
local function give_missing(c,id)
 if owned(c,id)then return true end
 return I.give(c,id,1)
end
local pending_key='achievement.mesa.love.pending_items'
local pending_timer='achievement_mesa_love_returns'
local function enqueue(c,id,n)
 local pending=c:GetBucket(pending_key)or''
 c:SetBucket(pending_key,pending..tostring(id)..':'..tostring(n)..'|')
 c:SetTimer(pending_timer,1)
end
local function return_item(c,id,n)
 if not I.give(c,id,n)then enqueue(c,id,n)end
end
local function ensure_supply(c,id)
 if owned(c,id)then return end
 for queued in (c:GetBucket(pending_key)or''):gmatch('(%d+):%d+|')do if tonumber(queued)==id then return end end
 return_item(c,id,1)
end
local function pattern(c,n,text)
 local handled=false
 for task,p in pairs(D.diagrams)do
  if p.npc==n and active(c,task)then
   if text:find('hail',1,true)or text:find('pattern',1,true)or text:find('instruction',1,true)or text:find('sketch',1,true)then give_missing(c,p.item);handled=true end
  end
 end
 return handled
end
function M.accepted(e)
 local t=D.tasks[e.task_id];if not t then return end
 local id=D.acceptance_items[e.task_id]
 if id then give_missing(e.self,id)end
end
function M.complete(e)
 if e.task_id==D.earring.initial_task then
  -- Repeated first quest can replace a discarded earring, but never awards
  -- another when the original is carried or banked. Later stages scale it.
  e.self:SetBucket('achievement.mesa.dragoste.pending','1')
  e.self:SetTimer('achievement_mesa_dragoste',1)
 end
end
function M.enter(e)
 if(e.self:GetBucket(pending_key)or'')~=''then e.self:SetTimer(pending_timer,1)end
 if e.self:GetBucket('achievement.mesa.dragoste.pending')=='1'then e.self:SetTimer('achievement_mesa_dragoste',1)end
end
function M.timer(e)
 if e.timer==pending_timer then
  local pending=e.self:GetBucket(pending_key)or''
  local id,n,remaining=pending:match('^(%d+):(%d+)|(.*)$')
  if not id then e.self:StopTimer(e.timer);return true end
  if I.give(e.self,tonumber(id),tonumber(n))then
   e.self:SetBucket(pending_key,remaining)
   if remaining==''then e.self:StopTimer(e.timer)end
  end
  return true
 end
 if e.timer~='achievement_mesa_dragoste'then return false end
 if e.self:GetBucket('achievement.mesa.dragoste.pending')~='1'then e.self:StopTimer(e.timer);return true end
 if yes(e.self:IsTaskCompleted(D.earring.initial_task))and give_missing(e.self,D.earring.item)then
  e.self:SetBucket('achievement.mesa.dragoste.pending','0');e.self:StopTimer(e.timer)
 end
 return true
end
function M.scale(c)
 if yes(c:IsTaskCompleted(D.earring.final_task))then return D.earring.full_scale end
 if not yes(c:IsTaskCompleted(D.earring.initial_task))then return 0 end
 local count=0
 for _,task in ipairs(D.earring.gift_tasks)do if yes(c:IsTaskCompleted(task))then count=count+1 else break end end
 return D.earring.scale_steps[count+1]
end
local aliases={health={'health','how are you','doing'},gemstone={'gemstone','gem'},scent={'scent','smell'},color={'color','colour'}}
local function matches(text,word,npc)
 if text:find(word,1,true)then return true end
 if npc==397100 then for _,alias in ipairs(aliases[word]or{})do if text:find(alias,1,true)then return true end end end
 return false
end
local question_answers={health='I am doing well.',gemstone='Emerald is my favorite gemstone.',drink='Cold pure water is my favorite drink.',food='I enjoy roasted acorns.',color='I prefer a deep forest green.',scent='I love the scent of the earth.'}
function M.say(e)
 if eq.get_zone_id()~=397 and eq.get_zone_id()~=394 then return false end
 local c,n,text=e.other,e.self:GetNPCTypeID(),e.message:lower()
 local faction=c:GetFactionLevel(c:CharacterID(),n,c:GetBaseRace(),c:GetClass(),c:GetDeity(),e.self:GetPrimaryFaction(),e.self)
 if faction>=Faction.Threatenly then return true end
 -- Merchant diagrams are useful and replaceable, but they never grant task
 -- loot, craft or completion credit. Native SpeakWith owns the first hail.
 if pattern(c,n,text)then e.self:Say('These instructions describe the materials and combine. I can also make it after you supply every material and the crafting fee.');return true end
 if n==397100 or n==397118 then
  for task,t in pairs(D.tasks)do if active(c,task)then
   for _,a in ipairs(t.activities)do
    if a.kind=='scene'and a.npc_ids[1]==n and a.keyword and active(c,task,a.activityid)and matches(text,a.keyword,n)then
     c:UpdateTaskActivity(task,a.activityid,1)
     e.self:Say(question_answers[a.keyword]or'Thank you for telling me.');return true
    end
   end
  end end
 end
 if n~=397118 and n~=397086 then return false end
 for task,id in pairs(D.acceptance_items)do
  if active(c,task)and D.tasks[task].giver==n and(text:find('hail',1,true)or text:find('flask',1,true)or text:find('letter',1,true))then give_missing(c,id)end
 end
 if not(text:find('hail',1,true)or text:find('love',1,true)or text:find('help',1,true)or text:find('task',1,true)or text:find('gift',1,true)or text:find('questions',1,true)or text:find('protect',1,true)or text:find('drink',1,true)or text:find('food',1,true)or text:find('dress',1,true)or text:find('stop',1,true)or text:find('atheme',1,true)or text:find('athame',1,true)or text:find('pot',1,true)or text:find('promise',1,true)or text:find('teach',1,true)or text:find('box',1,true)or text:find('sad',1,true)or text:find('make',1,true))then return true end
 local choices={}
 for task,t in pairs(D.tasks)do
  -- Offers stay hidden until the complete scene/SQL package is reviewed.
  if t.enabled and t.giver==n and not active(c,task)and yes(eq.is_task_appropriate(task))then
   local ok=true
   for _,prior in ipairs(t.prerequisites)do if not yes(c:IsTaskCompleted(prior))then ok=false end end
   if ok then choices[#choices+1]=task end
  end
 end
 table.sort(choices)
 if #choices>0 then eq.task_selector(choices)end
 return true
end
local function normal_trade(e)
 local given,used,items,delivered={},{},{},{}
 for slot=1,4 do local i=e.trade['item'..slot];if i and i.valid then
  items[#items+1]=i;local id=i:GetID();given[tostring(id)]=(given[tostring(id)]or 0)+(i:IsStackable()and math.max(1,i:GetCharges())or 1)
  local n=i:GetTaskDeliveredCount();if n>0 then used[tostring(id)]=(used[tostring(id)]or 0)+n;delivered[id]=(delivered[id]or 0)+n end
 end end
 for _,coin in ipairs{'copper','silver','gold','platinum'}do if(e.trade[coin]or 0)>0 then given[coin]=e.trade[coin]end end
 if not next(used)then e.self:ReturnHandinItems(e.other);return end
 local required={};for id,n in pairs(used)do required[id]=n end
 for _,coin in ipairs{'copper','silver','gold','platinum'}do if given[coin]then required[coin]=given[coin]end end
 local consumed=e.self:CheckHandin(e.other,given,required,items)
 if consumed then
  -- Native task deliveries consume only their tagged quantity. Unrequested
  -- coins are returned, so material credit cannot turn an accidental fee into
  -- a donation and a failed equality check cannot prevent gift returns.
  e.other:AddMoneyToPP(given.copper or 0,given.silver or 0,given.gold or 0,given.platinum or 0,true)
  local npc=e.self:GetNPCTypeID()
  for _,r in ipairs(D.returns)do if r.npc==npc and(delivered[r.input]or 0)>0 and(not r.requires_active or active(e.other,r.task))then return_item(e.other,r.output,delivered[r.input])end end
  for _,r in ipairs{D.first_gift,D.honey}do
   if r.npc==npc and active(e.other,r.task,r.next_activity)then ensure_supply(e.other,r.output)end
  end
 end
 e.self:ReturnHandinItems(e.other)
end
function M.trade(e)
 if C.trade(e)then return true end
 local n=e.self:GetNPCTypeID()
 if n~=397118 and n~=397086 and n~=397120 and n~=394228 then return false end
 normal_trade(e);return true
end
return M
