-- Native tasks own SpeakWith, loot, delivery, completion, rewards and persistence.
-- Dialogue is reconstructed routing, not a claim of verbatim original text.
local D=require('achievement_quest_mesa_friends_data')
local M={}
local function yes(v)return v==true or v==1 end
local function done(c,t)return yes(c:IsTaskCompleted(t))end
local function active(c,t)return yes(c:IsTaskActive(t))end
local function offer(c,t,prior)
 if not D.ready[t]or active(c,t)or not yes(eq.is_task_appropriate(t))then return end
 if prior and not done(c,prior)then return end
 for _,other in ipairs({D.tasks.dream,D.tasks.orders,D.tasks.defense})do
  if other~=t and active(c,other)then
   c:Message(15,'Finish your current Hanook task first. If it is complete but still in your shared task window, leave that completed task before requesting the next one.')
   return
  end
 end
 eq.task_selector({t})
end
function M.say(e)
 if not D.enabled or eq.get_zone_id()~=397 then return false end
 local n=e.self:GetNPCTypeID();local c=e.other;local text=e.message:lower()
 local T=D.tasks
 if n==D.givers.hanook then
  if text:find('hail',1,true)then
   if active(c,T.dream)then
    e.self:Say('Speak with Elder Vasile and follow his instructions. Return when you have learned what troubles the Windwillow.')
   elseif active(c,T.orders)then
    e.self:Say('Investigate the Tuffein camp and bring me the raiders\' orders.')
   elseif active(c,T.defense)then
    e.self:Say('Protect the tree from the treekillers, then return to me.')
   elseif done(c,T.orders)then
    e.self:Say('Will you '..eq.say_link('stand')..' with us and protect the tree?')
   elseif done(c,T.dream)then
    e.self:Say('There is more to investigate. Ask '..eq.say_link('what more can I do')..'.')
   else
    e.self:Say('My '..eq.say_link('dreams')..' trouble me. Will you '..eq.say_link('help')..'?')
   end
  elseif text:find('%f[%a]more%f[%A]')then offer(c,T.orders,T.dream)
  elseif text:find('%f[%a]stand%f[%A]')then offer(c,T.defense,T.orders)
  elseif text:find('dream',1,true)then
   e.self:Say('I fear that the Tuffein may harm the Windwillow. Will you '..eq.say_link('help')..' me learn whether this is true?')
  elseif text:find('help',1,true)then offer(c,T.dream)
  else return false end
  return true
 elseif n==D.givers.vasile and active(c,T.dream)and text:find('hail',1,true)then
  if yes(c:IsTaskActivityActive(T.dream,0))then
   e.self:Say('Collect five trinkets from the Tuffein and bring them to me. I will examine their energy.')
  elseif yes(c:IsTaskActivityActive(T.dream,3))then
   e.self:Say('Hanook must hear this: Glasson plans to harm the Windwillow. Return to her with the news.')
  end
  return false -- Preserve Elder Vasile's established Roost dialogue and trade.
 elseif n==D.givers.peretaenu then
  if text:find('hail',1,true)or text:find('stop',1,true)or text:find('they',1,true)then
   e.self:Say('Drakkin raiders threaten the camp from the lowlands. Will you '..eq.say_link('help')..' stop them?')
  elseif text:find('help',1,true)then offer(c,T.raiders)
  else return false end
  return true
 end
 return false
end
return M
