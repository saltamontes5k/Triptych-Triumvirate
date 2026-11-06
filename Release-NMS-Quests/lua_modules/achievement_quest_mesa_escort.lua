-- Dorina's Lament uses the original Simu and actual walking/ambush/arrival.
-- Route geometry and encounter balance are labelled configurable reconstructions.
local D=require('achievement_quest_mesa_escort_data')
local M={}
local scene
local sequence=0
local timer='achievement_mesa_escort'
local actor_timer='achievement_mesa_escort_actor'
local owner_key='mesa_escort_owner'
local token_key='mesa_escort_token'
local function yes(v)return v==true or v==1 end
local function active(c,a)return yes(c:IsTaskActive(D.task))and yes(c:IsTaskActivityActive(D.task,a))end
local function npc(id)return eq.get_entity_list():GetNPCByNPCTypeID(id)end
local function near(a,p,r,v)
 local x,y=a:GetX()-p.x,a:GetY()-p.y
 return x*x+y*y<=r*r and math.abs(a:GetZ()-p.z)<=v
end
local function own(n,s)
 return n and n.valid and n:GetEntityVariable(token_key)==s.token and n:GetEntityVariable(owner_key)==tostring(s.owner)
end
local function original(s)
 local n=npc(D.simu)
 if own(n,s)and n:GetID()==s.actor then return n end
end
local function owner(s)
 local c=eq.get_entity_list():GetClientByCharID(s.owner)
 if c and c.valid then return c end
end
-- MoveTo corrects destination Z through the server collision map. Keep that
-- exact corrected destination as the guard point, preventing idle AI returning
-- home between steps. Compare arrival against it, never the navmesh floor Z.
local function move(n,p)n:SetRunning(false);n:MoveTo(p.x,p.y,p.z,p.heading or 0,true)end
local function arrived(n,p)
 local target={x=n:GetGuardPointX(),y=n:GetGuardPointY(),z=n:GetGuardPointZ()}
 return math.abs(target.x-p.x)<0.01 and math.abs(target.y-p.y)<0.01
  and near(n,target,D.waypoint_radius,D.vertical)
end
local function clear(n)
 if n and n.valid then
  n:DeleteEntityVariable(owner_key);n:DeleteEntityVariable(token_key);n:StopTimer(actor_timer)
 end
 scene=nil
end
local function raider(s)
 local n=eq.get_entity_list():GetNPCByID(s.raider or 0)
 if own(n,s)and n:GetNPCTypeID()==D.raider then return n end
end
local function return_home(s)
 local r=raider(s);if r then r:Depop(false)end
 s.raider=nil;s.phase='returning';s.returned_at=os.time()
 local n=original(s)
 if not n or n:GetHP()<=0 then clear(n);return end
 -- Failure/return never grants objective credit. The normal return is walking
 -- along the actual visited route in reverse, rather than teleporting arrival.
 s.return_index=math.min(s.index or 1,#D.points)
 n:WipeHateList();move(n,D.points[s.return_index])
end
local function fail(s,text)
 local c=owner(s)
 if c and yes(c:IsTaskActive(D.task))then c:Message(13,text);c:FailTask(D.task)end
 if scene==s and s.phase~='returning'then return_home(s)end
end
local function start(c)
 if not D.enabled or scene or not active(c,D.activity)or c:IsDead()then return false end
 local n=npc(D.simu)
 if not n or not n.valid or n:GetHP()<=0 or n:IsEngaged()or n:GetGrid()~=D.original_grid
  or n:GetEntityVariable(token_key)~=''or not near(c,D.home,D.start_radius,D.vertical)
  or not near(n,D.home,D.start_radius,D.vertical)then return false end
 sequence=sequence+1
 local s={owner=c:CharacterID(),token=tostring(c:CharacterID())..':'..os.time()..':'..sequence,actor=n:GetID(),
  index=1,phase='walking',started=os.time(),last_progress=os.time(),ambush_done=false}
 scene=s;n:SetEntityVariable(owner_key,tostring(s.owner));n:SetEntityVariable(token_key,s.token)
 n:SetTimer(actor_timer,1);c:SetTimer(timer,1);move(n,D.points[1]);return true
end
function M.before_update(e)
 if e.task_id~=D.task or e.activity_id~=D.honey_activity then return 0 end
 local n=npc(D.simu)
 if not D.enabled or not n or not n.valid or n:GetHP()<=0 or n:IsEngaged()or n:GetGrid()~=D.original_grid or scene or n:GetEntityVariable(token_key)~=''
  or not near(n,D.home,D.start_radius,D.vertical)then
  e.self:Message(13,'Simu is not ready for another escort. Please keep the honey and try again when he has returned.');return 1
 end
 return 0
end
function M.resume(e)
 local c=e.self
 if D.enabled and eq.get_zone_id()==397 and active(c,D.activity)and not c:IsDead()then
  c:SetTimer(timer,1)
  if not scene then start(c)end
 end
end
function M.client_timer(e)
 if e.timer~=timer then return false end
 local c=e.self
 if not D.enabled or eq.get_zone_id()~=397 or not active(c,D.activity)or c:IsDead()then
  c:StopTimer(timer)
  if scene and scene.owner==c:CharacterID()and scene.phase~='returning'then fail(scene,'The escort was interrupted.')end
 elseif not scene then start(c)end
 return true
end
function M.failed(e)
 if e.task_id==D.task and scene and scene.owner==e.self:CharacterID()and scene.phase~='returning'then return_home(scene)end
end
function M.player_death(e)
 if scene and scene.owner==e.self:CharacterID()and scene.phase~='returning'then fail(scene,'You could no longer escort Simu.')end
end
function M.death_complete(e)
 local s=scene;local n=e.self
 if not s or not own(n,s)then return end
 if n:GetNPCTypeID()==D.simu then fail(s,'Simu did not survive the journey.');clear(n)
 elseif n:GetNPCTypeID()==D.raider and tonumber(n:GetEntityVariable('mesa_escort_actor_id'))==s.raider
  and(not e.killed_entity_id or e.killed_entity_id==s.raider) then
  -- Killing the ambusher is not a separate journal objective. Any genuine
  -- kill that lets Simu survive can clear the encounter; it grants no task
  -- kill credit and cannot bypass walking the rest of the route.
  s.ambush_done=true;s.raider=nil;s.phase='walking';s.last_progress=os.time()
 end
end
function M.actor_timer(e)
 if e.timer~=actor_timer then return false end
 local n=e.self
 if n:GetNPCTypeID()==D.raider then
  if not scene or not own(n,scene)then
   if n:GetEntityVariable(token_key)~=''then n:Depop(false)end
  end
  return true
 end
 if n:GetNPCTypeID()~=D.simu then return false end
 local s=scene
 if not s or not own(n,s)then
  if n:GetEntityVariable(token_key)~=''then
   -- Recover only this module's stale lock after Lua/zone reload. Teleport is
   -- an emergency actor reset, never an escort-success or arrival mechanism.
   n:WipeHateList();n:GMMove(D.home.x,D.home.y,D.home.z,D.home.heading or 0,false);n:SaveGuardSpot();clear(n)
  end
  return true
 end
 if n:GetHP()<=0 then fail(s,'Simu did not survive the journey.');clear(n);return true end
 if s.phase=='returning'then
  local p=D.points[s.return_index]
  if arrived(n,p)then
   s.return_index=s.return_index-1
   if s.return_index<1 then move(n,D.home);clear(n)
   else move(n,D.points[s.return_index])end
  elseif os.time()-s.returned_at>D.return_timeout then
   n:GMMove(D.home.x,D.home.y,D.home.z,D.home.heading or 0,false);n:SaveGuardSpot();clear(n)
  end
  return true
 end
 local c=owner(s)
 if not c or c:IsDead()or not active(c,D.activity)or not near(c,{x=n:GetX(),y=n:GetY(),z=n:GetZ()},D.owner_radius,D.owner_vertical)then
  fail(s,'Simu lost his escort.');return true
 end
 if os.time()-s.started>D.timeout then fail(s,'The journey could not be completed in time.');return true end
 if n:IsEngaged()then s.last_progress=os.time();return true end
 if s.phase=='ambush'then
  if not raider(s)then fail(s,'The ambusher disappeared before the encounter was resolved.')end
  return true
 end
 local p=D.points[s.index]
 if not arrived(n,p)then
  if os.time()-s.last_progress>D.stall_timeout then fail(s,'Simu could not continue along the trail.')end
  return true
 end
 s.last_progress=os.time()
 if s.index==D.ambush_index and not s.ambush_done then
  local a=D.ambush
  local r=eq.spawn2(D.raider,0,0,a.x,a.y,a.z,a.heading or 0)
  if not r or not r.valid then fail(s,'The trail encounter could not start.');return true end
  r:SetEntityVariable(owner_key,tostring(s.owner));r:SetEntityVariable(token_key,s.token)
  r:SetEntityVariable('mesa_escort_actor_id',tostring(r:GetID()))
  r:SetTimer(actor_timer,1);s.raider=r:GetID();s.phase='ambush';r:AddToHateList(n,1);return true
 end
 if s.index==#D.points then
  local d=npc(D.dorina)
  if not d or not d.valid or d:GetHP()<=0 or not near(n,{x=d:GetX(),y=d:GetY(),z=d:GetZ()},D.arrival_radius,D.vertical)then
   fail(s,'Dorina was not at the meeting place.');return true
  end
  if not s.ambush_done then fail(s,'The trail encounter was not completed.');return true end
  -- Set return state before native task callbacks can re-enter this module.
  s.phase='returning';s.returned_at=os.time();s.return_index=#D.points
  c:UpdateTaskActivity(D.task,D.activity,1);c:StopTimer(timer)
  move(n,D.points[s.return_index]);return true
 end
 s.index=s.index+1;move(n,D.points[s.index]);return true
end
return M
