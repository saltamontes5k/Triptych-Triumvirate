-- Native tasks own kills, fresh loot, deliveries, exploration, rewards and persistence.
local D=require('achievement_quest_mesa_data')
local B=require('achievement_quest_blightfire')
local S=require('achievement_quest_mesa_scenes')
local I=require('achievement_quest_mesa_inventory')
local M={}
local function yes(v)return v==true or v==1 end
local function active(c,t,a)return yes(c:IsTaskActive(t))and(a==nil or yes(c:IsTaskActivityActive(t,a)))end
local function key(s)return'achievement.may2013.mesa.'..s end
local function stage(c)
 for i,t in ipairs(D.series.madu)do if active(c,t)then return i end end
 local nextstage=tonumber(c:GetBucket(key('madu.next')))
 if nextstage and nextstage>=1 and nextstage<=5 and nextstage==math.floor(nextstage)then
  if tonumber(c:GetBucket(key('madu.accepted')))==D.series.madu[nextstage]then c:SetBucket(key('madu.next'),'1');c:SetBucket(key('madu.accepted'),'0');return 1 end
  return nextstage
 end
 for i,t in ipairs(D.series.madu)do if not yes(c:IsTaskCompleted(t))then return i end end
 return 1
end
local supply=I.give
local function arm(c)
 if eq.get_zone_id()==397 and active(c,3040412,0)then c:SetTimer('achievement_mesa_fire',1)end
end
function M.accepted(e)
 if not D.tasks[e.task_id]then return end
 if e.task_id>=3040416 and e.task_id<=3040420 then
  e.self:SetBucket(key('madu.next'),tostring(e.task_id-3040415));e.self:SetBucket(key('madu.accepted'),tostring(e.task_id))
 end
 if e.task_id==3040419 and I.count(e.self,88130)==0 then supply(e.self,88130,10)end
 if e.task_id==3040411 then
  for _,f in ipairs{'applied','1107','1108'}do e.self:SetBucket(key('betrayal.'..f),'0')end
 end
 arm(e.self)
end
function M.complete(e)
 if e.task_id>=3040416 and e.task_id<=3040420 then
  e.self:SetBucket(key('madu.accepted'),'0');e.self:SetBucket(key('madu.next'),tostring(e.task_id==3040420 and 1 or e.task_id-3040414))
 end
 if e.task_id==3040411 then S.release(e.self)end
end
function M.failed(e)
 if e.task_id>=3040416 and e.task_id<=3040420 then e.self:SetBucket(key('madu.next'),'1');e.self:SetBucket(key('madu.accepted'),'0')end
 if e.task_id==3040411 then S.release(e.self)end
end
function M.enter(e)arm(e.self);S.resume(e.self)end
function M.death(e)S.release(e.self)end
local function appropriate(c,t)
 if t.enabled==false or active(c,t.id)or not yes(eq.is_task_appropriate(t.id))then return false end
 for _,id in ipairs(t.prerequisites)do if not yes(c:IsTaskCompleted(id))then return false end end
 return t.id<3040416 or t.id>3040420 or D.series.madu[stage(c)]==t.id
end
function M.cross_say(e)
 if not e.message:lower():find('hail',1,true)then return false end
 local a=D.cross[e.self:GetNPCTypeID()]
 if a and active(e.other,3040418,a.activity)then e.self:Say(a.dialogue);return true end
 return false
end
function M.say(e)
 local c=e.other;local n=e.self:GetNPCTypeID();local text=e.message:lower();local hail=text:find('hail',1,true)
 if n==397013 and hail and(active(c,3040411,1)or active(c,3040411,2))then
  -- Speech callbacks run before native SpeakWith. Defer teleport until the
  -- native objective has advanced, so travel cannot invalidate the hail.
  c:SetTimer('achievement_mesa_capture',1);return
 end
 if n==397007 and active(c,3040419)and I.count(c,88130)==0 and(hail or text:find('wand',1,true))then supply(c,88130,10)end
 if M.cross_say(e)then return end
 if not D.givers[n]then return end
 local faction=c:GetFactionLevel(c:CharacterID(),e.self:GetNPCTypeID(),c:GetBaseRace(),c:GetClass(),c:GetDeity(),e.self:GetPrimaryFaction(),e.self)
 if faction>=Faction.Threatenly then e.self:Say('You have not earned our trust.');return end
 local wanted=false
 for _,word in ipairs(D.keywords[n])do if text:find(word,1,true)then wanted=true;break end end
 if wanted then
  local choices={};for _,id in ipairs(D.givers[n])do if appropriate(c,D.tasks[id])then choices[#choices+1]=id end end
  if #choices>0 then eq.task_selector(choices)end
 elseif hail then e.self:Say(D.greetings[n])end
end
function M.giant_say(e)
 if eq.get_zone_id()~=397 or not e.message:lower():find('hail',1,true)then return end
 local c=e.other;local n=e.self
 for i,id in ipairs{397251,397243,397259,397255}do
  if n:GetNPCTypeID()==id and active(c,3040417,i-1)then
   -- 2007 firsthand: attempted first parlay provokes combat. Do not alter the
   -- global faction or require a dust buff on the later, successful hail task;
   -- period reports explicitly allow distant hails and another player's dust.
   n:Attack(c);return
  end
 end
end
function M.trade(e)B.trade(e)end
function M.click_door(e)return S.click_door(e)end
function M.click_object(e)return S.click_object(e)end
function M.timer(e)
 local c=e.self
 if e.timer=='achievement_mesa_fire'then
  if eq.get_zone_id()~=397 or not active(c,3040412,0)then c:StopTimer(e.timer);return end
  local p=D.fire;local dx,dy=c:GetX()-p.x,c:GetY()-p.y
  if dx*dx+dy*dy<=p.radius*p.radius and math.abs(c:GetZ()-p.z)<p.vertical and supply(c,88132)then c:UpdateTaskActivity(3040412,0,1)end
 elseif e.timer=='achievement_mesa_capture'then
  c:StopTimer(e.timer);if eq.get_zone_id()==397 and active(c,3040411,2)then S.capture(c)end
 else S.client_timer(e)end
end
return M
