-- Private staging: quest scenes and task SQL must be completed before install.
-- Native tasks own loot/kill/deliver progress, reward selection and completion.
local data=require('achievement_quest_bixies_data')
local scenes=require('achievement_quest_bixie_scenes')
local M={}
local function yes(v) return v==true or v==1 end
local function active(id) return yes(eq.is_task_active(id)) end
local function completed(id) return yes(eq.is_task_completed(id)) end
local function contains(text,words)
 for _,word in ipairs(words or {}) do if text:find(word,1,true) then return true end end
 return false
end
local function owns(client,item)
 -- CountItem does not inspect socketed augments. Inventory HasItem searches
 -- worn, bags, bank and cursor, including augment sockets, and returns -1
 -- when absent. Do not use a nonnegative-slot test: augment sentinel differs.
 return client:GetInventory():HasItem(item,1)~=-1
end
local function eligible(id,client)
 local task=data.tasks[id]
 if not task or active(id) or not yes(eq.is_task_appropriate(id)) then return false end
 if task.repeatable==false and completed(id) then return false end
 if task.absent_lore_item and owns(client,task.absent_lore_item) then return false end
 for _,prior in ipairs(task.prerequisites or {}) do
  if not completed(prior) then return false end
 end
 return true
end
function M.accepted(e) scenes.accepted(e) end
function M.say(e)
 if scenes.say(e) then return true end
 local rule=data.givers[e.self:GetNPCTypeID()]
 if not rule then return false end
 local text=e.message:lower()
 local ids={}
 local request=false
 for _,offer in ipairs(rule.offers) do
  if contains(text,offer.keywords) then
   request=true
   if eligible(offer.id,e.other) then ids[#ids+1]=offer.id end
  end
 end
 if request then
  if #ids>0 then eq.task_selector(ids) end
  -- Hails also advance native report stages after this callback. Never grant
  -- whole tasks here or repeat prior selector calls from composed modules.
  return true
 end
 if contains(text,{'hail','adventures','depressing','property','daughter','business','bixies','discover'}) then
  e.self:Say(rule.greeting)
  return true
 end
 return false
end
function M.trade(e)
 if scenes.trade(e) then return end
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
 if next(required) and e.self:CheckHandin(e.other,handin,required,items) then
  scenes.silo(e,required['85758'] or 0)
 end
 e.self:ReturnHandinItems(e.other)
end
return M
