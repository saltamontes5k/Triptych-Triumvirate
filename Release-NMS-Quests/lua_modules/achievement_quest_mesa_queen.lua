-- Native tasks own real loot, delivery, kills, completion, rewards and persistence.
-- This module supplies physical quest objects and the researched hand-in attack.
local D=require('achievement_quest_mesa_queen_data')
local I=require('achievement_quest_mesa_inventory')
local B=require('achievement_quest_blightfire')
local M={}
local function yes(v)return v==true or v==1 end
local function active(c,t,a)return yes(c:IsTaskActive(t))and(a==nil or yes(c:IsTaskActivityActive(t,a)))end
local function enabled()return D.enabled and eq.get_zone_id()==D.zone end
local function supply(c,id)
 if I.count(c,id)>0 then return true end
 -- CountItem includes bank/shared-bank storage. Existing custody prevents
 -- replacement duplication; retrieving a banked quest item is ordinary play.
 if c:CountItem(id)>0 then c:Message(13,'Retrieve your existing quest item from storage first.');return false end
 return I.give(c,id,1)
end
local function arm(c)
 if enabled()and active(c,3040469,0)then c:SetTimer(D.timer,1)
 else c:StopTimer(D.timer)end
end
function M.resume(e)arm(e.self)end
function M.accepted(e)
 if not enabled()then return end
 if e.task_id==3040473 then supply(e.self,D.antidote)end
 arm(e.self)
end
function M.timer(e)
 if e.timer~=D.timer then return false end
 local c=e.self
 if not enabled()or not active(c,3040469,0)then c:StopTimer(D.timer);return true end
 if c:GetHP()<=0 then return true end
 local x,y=c:GetX()-D.water.x,c:GetY()-D.water.y
 if x*x+y*y<=D.water_radius*D.water_radius and math.abs(c:GetZ()-D.water.z)<=D.water_vertical then
  -- An actual arrival and an actual owned sample produce this objective.
  -- An occupied cursor or failed item creation cannot silently advance it.
  if supply(c,D.water_item)then c:UpdateTaskActivity(3040469,0,1);c:StopTimer(D.timer)end
 end
 return true
end
local function offer(c,t,previous)
 if active(c,t)or not yes(eq.is_task_appropriate(t))then return end
 if previous and not yes(c:IsTaskCompleted(previous))then return end
 for _,other in ipairs(D.tasks)do if active(c,other)then return end end
 eq.task_selector({t})
end
function M.say(e)
 if not enabled()then return false end
 local c,n,text=e.other,e.self:GetNPCTypeID(),e.message:lower()
 if n==D.ekaterina then
  if text:find('hail',1,true)then
   if active(c,3040473)then e.self:Say('What has happened to my queen? If you have lost the '..eq.say_link('cure')..', ask me before returning to her.')
   elseif active(c,3040472)then e.self:Say('Ramona on the mesa may know a remedy. Bring the cure to me when she has prepared it.')
   elseif active(c,3040471)then e.self:Say('Prove your strength against the dark widows, murkwater oozes and ring snakes, then return.')
   elseif active(c,3040470)then e.self:Say('Explore the satyr camp, dryad sanctuary and desert passage, then tell me what you find.')
   elseif active(c,3040469)then e.self:Say('Bring me a sample from the base of the northern waterfall.')
   elseif yes(c:IsTaskCompleted(3040473))then e.self:Say('My poor queen. Please leave me to my grief.')
   elseif yes(c:IsTaskCompleted(3040472))then e.self:Say('Will you '..eq.say_link('deliver')..' the cure to the queen?')
   elseif yes(c:IsTaskCompleted(3040471))then e.self:Say('Please '..eq.say_link('go see Ramona')..' on the mesa.')
   elseif yes(c:IsTaskCompleted(3040470))then e.self:Say('Can you show that you '..eq.say_link('stand a chance')..' of surviving the journey?')
   elseif yes(c:IsTaskCompleted(3040469))then e.self:Say('Will you help me '..eq.say_link('further')..'?')
   else e.self:Say('Why do you bother me in my '..eq.say_link('misery')..'?')end
  elseif text:find('misery',1,true)then e.self:Say('My queen has changed. Why would a dry one '..eq.say_link('care')..'?')
  elseif text:find('care',1,true)then e.self:Say('If you wish to help, say that you will '..eq.say_link('help')..' me.')
  elseif text:find('go see ramona',1,true)then offer(c,3040472,3040471)
  elseif text:find('stand a chance',1,true)then offer(c,3040471,3040470)
  elseif text:find('further',1,true)then offer(c,3040470,3040469)
  elseif text:find('deliver',1,true)then offer(c,3040473,3040472)
  elseif text:find('cure',1,true)and active(c,3040473,0)and yes(c:IsTaskCompleted(3040472))then supply(c,D.antidote)
  elseif text:find('help',1,true)then offer(c,3040469)
  else return false end
  return true
 elseif n==D.ramona and active(c,3040472)then
  if text:find('hail',1,true)or text:find('require',1,true)then
   if active(c,3040472,7)then e.self:Say('You have done well. Take this antidote to Ekaterina.')
   else e.self:Say('Bring me a puma paw, mountain recluse venom sac and snake fang from Blackfeather Roost. Only fresh finds there will help.')end
   return true
  end
 end
 return false
end
function M.before_update(e)
 if not enabled()then return 0 end
 if e.task_id==3040472 and e.activity_id==7 then
  -- Called only after native SpeakWith filtering matched Ramona. Give the
  -- real antidote before allowing this genuine hail objective to advance.
  return supply(e.self,D.antidote)and 0 or 1
 end
 return 0
end
function M.trade(e)
 if not enabled()then B.trade(e);return end
 local used=0
 for slot=1,4 do
  local i=e.trade['item'..slot]
  if i and i.valid and i:GetID()==D.antidote then used=used+i:GetTaskDeliveredCount()end
 end
 local attack=e.self:GetNPCTypeID()==D.queen and used>0 and active(e.other,3040473,1)
 B.trade(e) -- Consume exactly native-delivered objects; return unrelated items/coins.
 if attack then
  e.self:Say('This was my choice. I reject your cure. Die, dry one!')
  e.self:AddToHateList(e.other,1)
  -- Existing nearby defenders join the actual encounter. No new copies,
  -- forced player damage, faction-standing writes or scripted kill credit.
  for g in eq.get_entity_list():GetNPCList().entries do
   if g.valid and g:GetHP()>0 and not g:IsPet()and g:GetSpawnPointID()>0 and D.guards[g:GetNPCTypeID()]then
    local x,y=g:GetX()-e.self:GetX(),g:GetY()-e.self:GetY()
    if x*x+y*y<=D.guard_reach*D.guard_reach and math.abs(g:GetZ()-e.self:GetZ())<=D.guard_vertical then g:AddToHateList(e.other,1)end
   end
  end
 end
end
function M.npc_spawn(e)
 if not enabled()then return false end
 local n=e.self
 if n.valid and n:GetSpawnPointID()>0 and D.protectors[n:GetNPCTypeID()]then n:SetTimer(D.guard_timer,1);return true end
 return false
end
function M.npc_timer(e)
 if e.timer~=D.guard_timer then return false end
 local n=e.self
 if not enabled()or not n.valid or n:GetHP()<=0 or n:IsPet()or not D.protectors[n:GetNPCTypeID()]then return true end
 local queen=eq.get_entity_list():GetNPCByNPCTypeID(D.queen)
 if not queen or not queen.valid or queen:GetHP()<=0 or not queen:IsEngaged()or queen:GetHPRatio()>=D.guard_heal_below then return true end
 local x,y=n:GetX()-queen:GetX(),n:GetY()-queen:GetY()
 if x*x+y*y>D.guard_reach*D.guard_reach or math.abs(n:GetZ()-queen:GetZ())>D.guard_vertical then return true end
 local due=tonumber(n:GetEntityVariable('mesa.queen.heal_due'))or 0
 if os.time()>=due then
  -- Period2009 report: protectors can Complete Heal her. Use the genuine
  -- spell/mana/casting path, not direct HP restoration. Timings are defaults.
  n:CastSpell(D.guard_heal_spell,queen:GetID())
  n:SetEntityVariable('mesa.queen.heal_due',tostring(os.time()+D.guard_heal_recast))
 end
 return true
end
return M
