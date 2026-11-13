-- Kathryn defenses: shared original NPC, scene-owned attackers and native
-- killed-merit credit. Configuration remains disabled until NPC/SQL review.
local D=require('achievement_quest_mesa_defense_data')
local M={}
local scenes={}
local sequence=0
local owner_key='mesa_defense_owner'
local token_key='mesa_defense_token'
local timer='achievement_mesa_defense'
local actor_timer='achievement_mesa_defense_actor'
local function yes(v)return v==true or v==1 end
local function active(c,t,a)return yes(c:IsTaskActive(t))and(a==nil or yes(c:IsTaskActivityActive(t,a)))end
local function near(a,b,r,v)
 local x,y=a:GetX()-b:GetX(),a:GetY()-b:GetY()
 return x*x+y*y<=r*r and math.abs(a:GetZ()-b:GetZ())<=v
end
local function kathryn()return eq.get_entity_list():GetNPCByNPCTypeID(D.kathryn)end
local function token(n)return n:GetEntityVariable(token_key)end
local function own(n,s)
 return n and n.valid and token(n)==s.token and n:GetEntityVariable(owner_key)==tostring(s.owner)
end
-- Corpse creation clears NPC:GetID() before merit/death-complete callbacks.
-- Retain the spawn identity on the exact token-tagged actor, not a corpse or
-- a fresh same-type spawn; death-complete also supplies killed_entity_id.
local function actor_id(n)
 local id=tonumber(n:GetEntityVariable('mesa_defense_actor_id'))or 0
 local live=n:GetID()
 if id<=0 or(live~=0 and live~=id)then return end
 return id
end
local function scene_client(s)
 local c=eq.get_entity_list():GetClientByCharID(s.owner)
 if c and c.valid and not c:IsDead()and active(c,s.task)then return c end
end
local function cleanup(s)
 scenes[s.owner]=nil
 for n in eq.get_entity_list():GetNPCList().entries do
  if own(n,s)and n:GetNPCTypeID()~=D.kathryn then n:Depop(false)end
 end
 local k=kathryn()
 if own(k,s)then k:DeleteEntityVariable(owner_key);k:DeleteEntityVariable(token_key)end
 local c=eq.get_entity_list():GetClientByCharID(s.owner)
 if c and c.valid then c:StopTimer(timer)end
end
local function fail(s,reason)
 local c=eq.get_entity_list():GetClientByCharID(s.owner)
 if not c or not c.valid or not active(c,s.task)then c=nil end
 cleanup(s)
 if c then c:Message(13,reason);c:FailTask(s.task)end
end
local function valid(s)
 local c,k=scene_client(s),kathryn()
 if not c or not own(k,s)or k:GetHP()<=0 then return end
 if not near(c,k,D.owner_radius,D.vertical_radius)then return end
 return c,k
end
local function spawn(s,index)
 local c,k=valid(s);if not c then return false end
 local role=s.config.waves[index]
 local id=D.actors[role]
 if not id or id<=0 then return false end
 local p=D.spawn
 local spawned=eq.spawn2(id,0,0,p.x,p.y,p.z,p.heading or 0)
 if not spawned or not spawned.valid then return false end
 local n=spawned:CastToNPC()
 if not n or not n.valid then return false end
 n:SetEntityVariable(owner_key,tostring(s.owner));n:SetEntityVariable(token_key,s.token)
 n:SetEntityVariable('mesa_defense_wave',tostring(index))
 n:SetEntityVariable('mesa_defense_merit','0')
 n:SetEntityVariable('mesa_defense_actor_id',tostring(n:GetID()))
 n:SetTimer(actor_timer,1)
 -- The final original grabber carries the note on its actual corpse. It is
 -- never given by a timer or by a kill-counter shortcut.
 s.actors[index]=n:GetID()
 -- Register ownership before fallible NPC-only setup. A failed setup must
 -- return failure and remove its actor, never retry one spawn every tick.
 local prepared=pcall(function()
  if s.config.note_item and index==#s.config.waves then n:AddItem(s.config.note_item,1)end
  n:SetRunning(true);n:AddToHateList(k,1)
 end)
 if not prepared then n:Depop(false);s.actors[index]=nil;return false end
 return true
end
local function configured(t)
 return D.enabled==true and t and D.actors.thug>0 and D.actors.grabber>0
end
local function release_orphan(n)
 local owner=tonumber(n:GetEntityVariable(owner_key))or 0
 if owner==0 or scenes[owner]then return end
 local old=token(n)
 if old==''then return end
 for actor in eq.get_entity_list():GetNPCList().entries do
  if actor.valid and token(actor)==old and actor:GetEntityVariable(owner_key)==tostring(owner)
   and(actor:GetNPCTypeID()==D.actors.thug or actor:GetNPCTypeID()==D.actors.grabber)then actor:Depop(false)end
 end
 local k=kathryn()
 if k and k.valid and token(k)==old and k:GetEntityVariable(owner_key)==tostring(owner)then
  k:DeleteEntityVariable(owner_key);k:DeleteEntityVariable(token_key)
 end
end
local function start(c,task,t)
 if not configured(t)or not active(c,task,0)then return false end
 local k=kathryn()
 if not k or not k.valid or k:GetHP()<=0 or not near(c,k,D.trigger_radius,D.vertical_radius)then return false end
 release_orphan(k)
 local owner=tonumber(k:GetEntityVariable(owner_key))or 0
 if owner>0 then return false end
 sequence=sequence+1
 local s={owner=c:CharacterID(),task=task,config=t,token=tostring(c:CharacterID())..':'..os.time()..':'..sequence,
  actors={},killed={},next_credit=1,next_spawn=1,started=os.time(),next_due=os.time()}
 scenes[s.owner]=s;k:SetEntityVariable(owner_key,tostring(s.owner));k:SetEntityVariable(token_key,s.token)
 c:SetTimer(timer,1)
 -- Do not commit the proximity stage if spawning fails.
 if not spawn(s,1)then cleanup(s);return false end
 s.next_spawn=2
 if t.simultaneous then
  for i=2,#t.waves do
   if not spawn(s,i)then cleanup(s);return false end
   s.next_spawn=i+1
  end
 end
 c:UpdateTaskActivity(task,0,1)
 return true
end
function M.resume(e)
 local c=e.self
 if eq.get_zone_id()~=397 then return end
 local needed=false
 for task,t in pairs(D.tasks)do if configured(t)and active(c,task)then
  needed=true
  -- After a script/zone reload, interrupted combat must restart through the
  -- native failure path. Offline elapsed time cannot become defense credit.
  if not active(c,task,0)and not scenes[c:CharacterID()]then
   for _,a in ipairs(t.kill_activities)do if active(c,task,a)then
    c:Message(13,'The interrupted defense must be requested again.');c:FailTask(task);break
   end end
  end
 end end
 if needed then c:SetTimer(timer,1)end
end
function M.failed(e)
 local s=scenes[e.self:CharacterID()]
 if s and s.task==e.task_id then cleanup(s)end
end
function M.player_death(e)
 local s=scenes[e.self:CharacterID()]
 if s then fail(s,'You could no longer protect Kathryn.')end
end
function M.client_timer(e)
 if e.timer~=timer then return false end
 local c=e.self;local s=scenes[c:CharacterID()]
 if eq.get_zone_id()~=397 or c:IsDead()then
  if s then fail(s,'The defense was interrupted.')else c:StopTimer(timer)end
  return true
 end
 if not s then
  local waiting=false
  for task,t in pairs(D.tasks)do if configured(t)and active(c,task,0)then
   waiting=true;if start(c,task,t)then return true end
  end end
  if not waiting then c:StopTimer(timer)end
  return true
 end
 if not valid(s)then fail(s,'Kathryn could not be protected, or you left the encounter.');return true end
 if os.time()-s.started>D.timeout_seconds then fail(s,'The defense has taken too long. Please request it again.');return true end
 for index,id in pairs(s.actors)do if not s.killed[index]then
  local n=eq.get_entity_list():GetNPCByID(id)
  if not own(n,s)then fail(s,'An attacker disappeared before the defense was completed.');return true end
 end end
 if s.retry_index and os.time()>=s.retry_due then
  local index=s.retry_index
  if not spawn(s,index)then fail(s,'The replacement attacker could not arrive.');return true end
  s.retry_index=nil;s.retry_due=nil
 end
 if s.next_spawn<=#s.config.waves and os.time()>=s.next_due then
  -- Single-wave encounters wait for the previous real kill before starting
  -- the configured inter-wave delay.
  local index=s.next_spawn
  if s.killed[index-1]then
   if not spawn(s,index)then fail(s,'The next attacker could not arrive.');return true end
   s.next_spawn=index+1
  end
 end
 return true
end
function M.merit(e)
 local n,c=e.self,e.other
 if not n or not n.valid or not c or not c.valid or not c:IsClient()then return end
 local s=scenes[tonumber(n:GetEntityVariable(owner_key))or 0]
 if not s or not own(n,s)or c:CastToClient():CharacterID()~=s.owner or not valid(s)then return end
 local index=tonumber(n:GetEntityVariable('mesa_defense_wave'))
 if not index or s.actors[index]~=actor_id(n)then return end
 -- EVENT_KILLED_MERIT is emitted by the core for its credited player/group/
 -- raid. No scripted approximation of pet ownership or kill stealing.
 n:SetEntityVariable('mesa_defense_merit','1')
end
function M.death_complete(e)
 local n=e.self
 if not n or not n.valid then return end
 local s=scenes[tonumber(n:GetEntityVariable(owner_key))or 0]
 if not s or not own(n,s)then return end
 if n:GetNPCTypeID()==D.kathryn then fail(s,'Kathryn was killed.');return end
 local index=tonumber(n:GetEntityVariable('mesa_defense_wave'))
 if not index or s.actors[index]~=actor_id(n)or s.killed[index]then return end
 if e.killed_entity_id and e.killed_entity_id~=s.actors[index]then return end
 local c=valid(s)
 if not c then fail(s,'The defense was interrupted.');return end
 -- Period reports require the thug to die first. A grabber killed too soon
 -- (or killed by the dryads) gives no banked objective credit; a replacement
 -- grabber rushes after roughly two minutes. Do not turn the ordered native
 -- journal into a simultaneous unordered kill counter.
 if s.config.simultaneous and index==2 and
  (not active(c,s.task,s.config.kill_activities[index])or n:GetEntityVariable('mesa_defense_merit')~='1')then
  s.actors[index]=nil;s.retry_index=index;s.retry_due=os.time()+D.retry_delay_seconds
  return
 end
 if n:GetEntityVariable('mesa_defense_merit')~='1'then fail(s,'The defense requires a credited player kill.');return end
 s.killed[index]=true
 -- Native stage visibility, not elapsed time, controls each kill update.
 while s.next_credit<=#s.config.waves and s.killed[s.next_credit]do
  local activity=s.config.kill_activities[s.next_credit]
  if not active(c,s.task,activity)then fail(s,'The defense journal is no longer at the expected stage.');return end
  s.next_credit=s.next_credit+1
  c:UpdateTaskActivity(s.task,activity,1)
 end
 s.next_due=os.time()+D.wave_delay_seconds
 if s.next_credit>#s.config.waves then cleanup(s)end
end
function M.actor_timer(e)
 if e.timer~=actor_timer then return false end
 local n=e.self
 local s=scenes[tonumber(n:GetEntityVariable(owner_key))or 0]
 if not s or not own(n,s)then
  -- Only our explicitly tagged reconstruction actors can be removed here.
  if token(n)~=''and(n:GetNPCTypeID()==D.actors.thug or n:GetNPCTypeID()==D.actors.grabber)then release_orphan(n);n:Depop(false)end
 elseif not valid(s)then fail(s,'The defense was interrupted.')end
 return true
end
return M
