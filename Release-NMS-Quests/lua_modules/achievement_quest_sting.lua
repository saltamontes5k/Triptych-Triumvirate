-- May 2013 Short Sharp Sting. Native tasks own kills, loot, hand-ins,
-- task completion, rewards, persistence and achievement criteria.
local D=require('achievement_quest_sting_settings')
local M={}
local BUZZ,FESTER,JOKES=3040317,3040318,3040319
local function yes(v)return v==true or v==1 end
local function live(v)return v and v.valid end
local function active(c,t,a)return live(c)and yes(c:IsTaskActive(t))and(a==nil or yes(c:IsTaskActivityActive(t,a)))end
local function near(c,n,r,z)
 local dx,dy=c:GetX()-n:GetX(),c:GetY()-n:GetY()
 return dx*dx+dy*dy<=r*r and math.abs(c:GetZ()-n:GetZ())<=z
end
local function npc(id)return eq.get_entity_list():GetNPCByNPCTypeID(id)end
local function configured()
 local b=D.buzz
 if b.reviewed~=true or b.copy_npc~=396941 or type(b.faction_id)~='number' or
    b.faction_id<=0 or b.faction_id~=math.floor(b.faction_id)or math.abs(b.faction_id)==math.huge or
    type(b.maximum_raw_faction)~='number'or b.maximum_raw_faction>=0 or
    b.maximum_raw_faction~=math.floor(b.maximum_raw_faction)or math.abs(b.maximum_raw_faction)==math.huge or
    type(b.copy_positions)~='table' or #b.copy_positions~=3 then return false end
 local immediate=0
 for _,p in ipairs(b.copy_positions)do
  for _,k in ipairs({'x','y','z','h'})do if type(p[k])~='number' or p[k]~=p[k]or math.abs(p[k])==math.huge then return false end end
  if type(p.immediate_attack)~='boolean'then return false end
  if p.immediate_attack then immediate=immediate+1 end
 end
 return immediate==2
end
function M.ready()return configured()end
function M.say(e)
 local n,c=e.self,e.other;local text=(e.message or''):lower()
 if n:GetNPCTypeID()~=395209 then return end
 if not(text:find('hail',1,true)or text:find('agricultur',1,true)or text:find('honeycomb',1,true)or
        text:find('prank',1,true)or text:find('observ',1,true)or text:find('prunae',1,true)or text:find('find her',1,true)or text:find('other task',1,true))then return end
 local offered={}
 for _,id in ipairs({BUZZ,FESTER,JOKES})do
  if not active(c,id)and yes(eq.is_task_appropriate(id))and(id~=BUZZ or configured())then offered[#offered+1]=id end
 end
 if #offered>0 then eq.task_selector(offered)end
end
function M.trade(e)require('achievement_quest_blightfire').trade(e)end
local timer='achievement_sting_imposter'
local function arm(c)
 if eq.get_zone_id()==396 and active(c,JOKES)then c:SetTimer(timer,1)else c:StopTimer(timer)end
end
function M.accepted(e)if e.task_id==JOKES then arm(e.self)end end
function M.enter(e)arm(e.self)end
function M.updated(e)if e.task_id==JOKES then arm(e.self)end end
function M.timer(e)
 if e.timer~=timer then return false end
 local c=e.self
 if eq.get_zone_id()~=396 or not active(c,JOKES)then c:StopTimer(timer);return true end
 -- Native fresh-loot progress unlocks objective2. An old inventory clue alone
 -- never unlocks it; neither hails nor task offers manufacture loot credit.
 if not active(c,JOKES,2)or c:CountItem(54661)<1 then return true end
 local n=npc(396233)
 if not live(n)or not near(c,n,60,20)or n:IsEngaged()then return true end
 n:SetEntityVariable('sting_imposter_revealed','1')
 n:SendIllusionPacket({race=520})
 n:Attack(c)
 return true
end
function M.prunae_say(e)
 if(e.message or''):lower():find('hail',1,true)then
  e.self:Say('Please help me. The other prisoner is an imposter!')
 end
end
function M.caged_spawn(e)e.self:SetEntityVariable('sting_imposter_revealed','0')end
function M.caged_say(e)
 if(e.message or''):lower():find('hail',1,true)then
  e.self:Say('She is the imposter. Free me!')
 end
end
function M.caged_combat(e)
 if not yes(e.joined)and e.self:GetEntityVariable('sting_imposter_revealed')=='1'then
  e.self:SendIllusionPacket({race=522});e.self:SetEntityVariable('sting_imposter_revealed','0')
 end
end
local function copies(root)
 local out={};local owner=tostring(root:GetID())
 for n in eq.get_entity_list():GetNPCList().entries do
  if live(n)and n:GetNPCTypeID()==D.buzz.copy_npc and n:GetEntityVariable('sting_root')==owner then out[#out+1]=n end
 end
 return out
end
function M.prankster_spawn(e)e.self:SetEntityVariable('sting_buzz_owner','')end
function M.prankster_say(e)
 local n,c=e.self,e.other;local text=(e.message or''):lower()
 if not active(c,BUZZ)then return end
 if text:find('hail',1,true)and active(c,BUZZ,2)then
  -- Native SpeakWith follows EVENT_SAY. Attack only after three actual copy
  -- kills unlocked this stage; ordinary/repeated early hails grant nothing.
  n:Attack(c);return
 end
 if not active(c,BUZZ,1)or not(text:find('prank',1,true))then return end
 if not configured()then return end
 if c:GetCharacterFactionLevel(D.buzz.faction_id)>D.buzz.maximum_raw_faction then
  n:Say('There is no work here for you. Leave me be.');return
 end
 local char=tostring(c:CharacterID())
 local existing=copies(n)
 if #existing>0 then return end
 -- Restore only missing kills after a lost/restarted generation. The native
 -- task counter, not a spawn receipt or hail count, determines what remains.
 local done=eq.get_task_activity_done_count(BUZZ,1)
 if type(done)~='number'or done<0 or done>=3 or done~=math.floor(done)then return end
 n:SetEntityVariable('sting_buzz_owner',char)
 local made={}
 for i=done+1,3 do
  local p=D.buzz.copy_positions[i]
  local a=eq.spawn2(D.buzz.copy_npc,0,0,p.x,p.y,p.z,p.h)
  if not live(a)then
   -- A partial spawn does not grant kills, and never leaves an incomplete
   -- generation blocking the task. Only this root's new actors are removed.
   for _,v in ipairs(made)do if live(v)then v:Depop(false)end end
   n:SetEntityVariable('sting_buzz_owner','');return
  end
  a:SetEntityVariable('sting_root',tostring(n:GetID()));a:SetEntityVariable('sting_owner',char)
  made[#made+1]=a
 end
 for i,a in ipairs(made)do if D.buzz.copy_positions[done+i].immediate_attack then a:Attack(c)end end
end
function M.prankster_death(e)
 for _,n in ipairs(copies(e.self))do if not n:IsEngaged()then n:Depop(false)end end
end
return M
