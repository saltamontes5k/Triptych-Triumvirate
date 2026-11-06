-- Execute real Vergalid actors. This module never manufactures kill, loot,
-- delivery, task-completion or reward credit. Scene progression is restricted
-- to source-backed physical triggers and confirmed native actor identities.
local D=require('achievement_quest_vergalid_data')
local R=require('vergalid_scene_rules')
local G=require('vergalid_orb_guardians')
local json=require('json')
local M={}
-- Flat keys avoid DataBucket's dot-delimited root merge across zone processes.
local PREFIX='rof2_vergalid_scene_v1_'
local LEGACY_PREFIX='hj.vergalid.scene.v1.'
local OWNER='vergalid.scene.key'
local MOTION='vergalid.scene.motion'
local NPC_TIMER='vergalid_actor'
local busy={}
local function valid(v)return v and v.valid end
local function yes(v)return v==true or v==1 end
local function EL()return eq.get_entity_list()end
local function here()return eq.get_zone_id()==404 end
local function inside(n,b)return b and n:GetX()>=b.minx and n:GetX()<=b.maxx and n:GetY()>=b.miny and n:GetY()<=b.maxy and n:GetZ()>=b.minz and n:GetZ()<=b.maxz end
local function near(n,p,xy,z)
 if not p then return false end
 local dx,dy=n:GetX()-p.x,n:GetY()-p.y
 return dx*dx+dy*dy<=xy*xy and math.abs(n:GetZ()-p.z)<=z
end
local function shared_id(c,task)
 if not D.tasks[task]or not D.tasks[task].shared then return nil end
 -- Keep native64-bit identity as a decimal string, never a Lua double.
 local id=c:GetSharedTaskIdentity()
 if type(id)~='string'or not id:match('^[1-9]%d*$')then return nil end
 return id
end
local function epoch(c,task)
 if D.tasks[task]and D.tasks[task].shared then return shared_id(c,task)and 1 or nil end
 local raw=c:GetBucket('vergalid.epoch.'..task)
 if not raw or raw==''then return nil end
 local value=tonumber(raw);assert(value and value>=1 and value==math.floor(value),'Invalid Vergalid acceptance epoch')
 return value
end
local function key(c,task,ep)
 local id=shared_id(c,task)
 if D.tasks[task]and D.tasks[task].shared then assert(id,'Missing native shared-task identity');return 'shared:'..task..':'..id end
 return tostring(c:CharacterID())..':'..task..':'..ep
end
local function load(k)
 local raw=eq.get_data(PREFIX..k);local legacy=false
 if not raw or raw==''then raw=eq.get_data(LEGACY_PREFIX..k);legacy=raw and raw~=''end
 if not raw or raw==''then return nil end
 local ok,s=pcall(json.decode,raw)
 if not ok or type(s)~='table'or s.key~=k then error('Corrupt Vergalid scene state; refusing a replacement actor')end
 -- Copy only a validated requested lease. Keep its old record intact; no
 -- root deletion, foreign-state rewrite or inferred task/actor progression.
 if legacy then eq.set_data(PREFIX..k,raw)end
 return s
end
local function save(s)eq.set_data(PREFIX..s.key,json.encode(s))end
local function member(c,s,r)
 if not valid(c)or not yes(c:IsTaskActive(r.task))then return false end
 if s.shared then return shared_id(c,r.task)==s.shared end
 return c:CharacterID()==s.owner and epoch(c,r.task)==s.epoch
end
local function actor(s,r)
 local found
 for n in EL():GetNPCList().entries do
  if n:GetEntityVariable(OWNER)==s.key then
   assert(n:GetNPCTypeID()==r.npc,'Vergalid actor lease has wrong native NPC type')
   assert(not found,'Duplicate Vergalid actor lease; refusing extra progression')
   found=n
  end
 end
 return found
end
local function protect(n,on)
 n:SetInvul(on);n:SetTargetable(not on)
 n:SetSpecialAbility(19,on and 1 or 0);n:SetSpecialAbility(20,on and 1 or 0)
 n:SetSpecialAbility(24,on and 1 or 0);n:SetSpecialAbility(25,on and 1 or 0)
end
local function bind(n,s)
 s.actor=n:GetID();s.position={x=n:GetX(),y=n:GetY(),z=n:GetZ(),heading=n:GetHeading()}
 n:SetEntityVariable(OWNER,s.key);n:SetTimer(NPC_TIMER,1)
 local r=D.scenes[s.task]
 if r.family=='bile'then
  local phase=s.restore_phase or s.phase
  protect(n,phase~='combat'and phase~='corpse')
 end
end
function M.accepted(c,task)
 local r=D.scenes and D.scenes[task]
 if not D.enabled or not r or not r.enabled or not yes(c:IsTaskActive(task))then return end
 local shared=shared_id(c,task)
 if D.tasks[task].shared and(not shared or not here())then return end
 local ep=shared and 1 or(epoch(c,task)or 0)+1
 local k=key(c,task,ep)
 if shared and load(k)then return end -- Another member already owns this native occurrence.
 if not shared then c:SetBucket('vergalid.epoch.'..task,tostring(ep))end
 local s=R.begin(r.family,c:CharacterID(),ep);s.key=k;s.shared=shared;s.task=task;s.pending={};s.next_action=1
 save(s)
end
function M.needs_timer(c)
 if not D.enabled then return false end
 for task,r in pairs(D.scenes or{})do if r.enabled and yes(c:IsTaskActive(task))then return true end end
 return false
end
local function send(s,r,c,e)
 assert(member(c,s,r),'Foreign character cannot drive a Vergalid scene')
 e.owner=s.owner;e.epoch=epoch(c,r.task);e.zone=eq.get_zone_id()
 local next_state,actions=R.step(s,e)
 next_state.pending=actions;next_state.next_action=1;save(next_state)
 return next_state
end
local function move(n,p)assert(p,'Missing reviewed actor movement point');n:MoveTo(p.x,p.y,p.z,p.heading or 0,false)end
local function resume_motion(n,s,r)
 if not s.motion then return end
 local p=s.motion.point
 if near(n,p,r.arrival_xy,r.arrival_z)then
  s.motion=nil;n:SetEntityVariable(MOTION,'');save(s);return
 end
 -- Do not move a fighting actor or keep resetting its live path every tick.
 -- A restored NPC loses that path even when its entity variables survive.
 if not n:IsEngaged()and n:GetEntityVariable(MOTION)~=s.motion.kind then
  move(n,p);n:SetEntityVariable(MOTION,s.motion.kind)
 end
end
local function execute(s,r,c)
 while s.pending and s.pending[s.next_action or 1]do
  assert(member(c,s,r),'Scene owner/task changed while executing')
  local index=s.next_action or 1;local action=s.pending[index];local n=actor(s,r)
  if action.kind=='spawn_actor'then
   if r.family=='orb'then
    -- A genuine native shared kill may finish this objective while a scene
    -- action is waiting. Do not spawn another orb after that update.
    if not yes(c:IsTaskActivityActive(r.task,r.trigger_activity))then
     s.phase='objective_complete';s.pending={};s.next_action=1;save(s);return s
    end
    G.validate(r)
   end
   if not n then
    -- Another lease or unowned copy of this managed type is not ours to
    -- adopt, destroy or duplicate. Retry after that actual actor is gone.
    for other in EL():GetNPCList().entries do if other:GetNPCTypeID()==r.npc then return s end end
    assert(r.spawn and r.npc,'Missing researched actor definition/position')
    eq.clear_npctype_cache(r.npc)
    local p=r.spawn;n=eq.spawn2(r.npc,0,0,p.x,p.y,p.z,p.heading or 0)
    if not valid(n)then return s end
    assert(n:GetNPCTypeID()==r.npc,'Unexpected native spawn identity');bind(n,s)
   else bind(n,s)end
   s.instance=eq.get_zone_instance_id()
   if r.family=='orb'then s.last_active=os.time()end
   s=send(s,r,c,{kind='spawn_result',actor_id=n:GetID(),identity_confirmed=true})
   if r.family=='orb'then c:BreakInvis()end
   G.sync(s,r,save,c)
  elseif action.kind=='reconcile_actor_lease'then
   if not n then return s end
   bind(n,s);s.phase=assert(s.restore_phase,'Missing scene recovery phase');s.restore_phase=nil
   s.next_action=index+1;save(s)
  else
   if not valid(n)then return s end
   if action.kind=='protect_actor'then protect(n,true)
   elseif action.kind=='unprotect_actor'then protect(n,false)
   elseif action.kind=='move_actor_to_bait'or action.kind=='move_actor_to_retreat'then
    s.motion={kind=action.kind,point=assert(action.kind=='move_actor_to_bait'and r.bait or r.retreat)}
    save(s);resume_motion(n,s,r)
   elseif action.kind=='advance_scene'then
    -- Replays after a save boundary cannot increment a later objective:
    -- only the exact still-active native scene activity is eligible.
    if yes(c:IsTaskActivityActive(r.task,action.activity))then c:UpdateTaskActivity(r.task,action.activity,1)end
   else error('Unknown Vergalid native scene action '..tostring(action.kind))end
   s.next_action=index+1;save(s)
  end
 end
 return s
end
local function reset_orb(s,r)
 -- Persist reset intent before removing only this scene's root. Surviving
 -- guards remain real actors; original reports describe them stacking.
 if s.phase~='resetting'then s.phase='resetting';s.pending={};s.next_action=1;save(s)end
 local n=actor(s,r)
 if valid(n)then n:StopTimer(NPC_TIMER);n:Depop(false)end
 -- Never infer death, task credit or reward from an idle disappearance.
 for _,slot in ipairs(s.guardians or{})do
  slot.generation=slot.generation+1;slot.phase='ready';slot.actor=nil;slot.due=nil
 end
 s.actor=0;s.actor_died=nil;s.position=nil;s.phase='ready';s.last_active=nil;s.restore_phase=nil
 save(s)
end
local function orb_activity(s,r,n)
 local target
 for candidate in EL():GetClientList().entries do
  if member(candidate,s,r)and near(candidate,r.spawn,100,60)then target=candidate;break end
 end
 local active=target~=nil or n:IsEngaged()or G.engaged(s,r)
 local now=os.time();local delay=r.guardians.idle_reset_seconds
 assert(type(delay)=='number'and delay==math.floor(delay)and delay>0,'Orb idle reset requires reviewed positive seconds')
 -- Bound persistence traffic while retaining a durable activity timestamp.
 if not s.last_active or(active and now-s.last_active>=15)then s.last_active=now;save(s)end
 if not active and now-s.last_active>=delay then reset_orb(s,r);return nil,true end
 return target,false
end
local function tick_scene(c,r)
 local ep=epoch(c,r.task)
 -- A genuine active native task may predate script activation or survive a
 -- crash immediately before its acceptance callback. Initialize scene state
 -- from that task, never from possession of a bait/quest item alone.
 if not ep or not load(key(c,r.task,ep))then M.accepted(c,r.task);ep=epoch(c,r.task)end
 if not ep then return end
 local s=load(key(c,r.task,ep));if not s or not member(c,s,r)then return end
 if s.instance and s.instance~=eq.get_zone_instance_id()then return end
 if s.phase=='resetting'then reset_orb(s,r)end
 s=execute(s,r,c)
 if s.pending and s.pending[s.next_action or 1]then return end
 local n=actor(s,r)
 if valid(n)then
  local changed=s.actor~=n:GetID();bind(n,s);if changed then save(s)end
 elseif s.actor>0 and s.phase~='corpse'then
  s=send(s,r,c,{kind='actor_missing',actor_id=s.actor});execute(s,r,c);return
 end
 if s.phase=='ready'and yes(c:IsTaskActivityActive(r.task,r.trigger_activity))and inside(c,r.site)then
  local held=r.family=='orb'or c:GetItemIDAt(Slot.Cursor)==r.item
  if held then
   s=send(s,r,c,{kind='plant',stage_active=true,at_site=true,cursor_matches=held,custody_confirmed=held})
   execute(s,r,c)
  end
 elseif valid(n)and r.family=='bile'and(s.phase=='approaching'or s.phase=='waiting_for_return')then
  local expected=s.phase=='approaching'and 1 or 2
  local dx,dy=c:GetX()-r.bait.x,c:GetY()-r.bait.y
  local distance=dx*dx+dy*dy
  s=send(s,r,c,{kind='observe',actor_id=n:GetID(),actor_alive=n:GetHP()>0,actor_at_bait=near(n,r.bait,r.arrival_xy,r.arrival_z),owner_at_safety=distance>=r.safety_min*r.safety_min and distance<=r.safety_max*r.safety_max,owner_at_bait=inside(c,r.site),stage_active=yes(c:IsTaskActivityActive(r.task,expected))})
  if s.phase=='waiting_for_return'and not s.return_deadline then
   local delay=r.return_window_seconds;assert(type(delay)=='number'and delay>0 and delay==math.floor(delay),'Bile return timeout requires reviewed positive seconds')
   s.return_deadline=os.time()+delay;save(s)
  end
  execute(s,r,c)
 end
end
function M.tick(c)
 if not D.enabled or not here()or busy[c:CharacterID()]then return end
 busy[c:CharacterID()]=true
 local ok,err=xpcall(function()
  for task,r in pairs(D.scenes or{})do if r.enabled and yes(c:IsTaskActive(task))then tick_scene(c,r)end end
 end,debug.traceback)
 busy[c:CharacterID()]=nil
 if not ok then error(err)end
end
function M.actor_spawn(e)
 local n=e.self
 local guardian_key=G.key(n)
 if D.enabled and here()and guardian_key~=''then
  local gs=load(guardian_key);local gr=gs and D.scenes[gs.task]
  return gr and gr.enabled and G.restore(n,gs,gr,save)or false
 end
 local k=n:GetEntityVariable(OWNER)
 if not D.enabled or not here()or k==''then return false end
 local s=load(k);local r=s and D.scenes[s.task]
 if not s or not r or not r.enabled or s.instance~=eq.get_zone_instance_id()or n:GetNPCTypeID()~=r.npc or s.phase=='corpse'then return false end
 -- LoadNPCStatePreSpawn restores the saved lease before EVENT_SPAWN.
 -- Timers and MoveTo destinations must be reconstructed explicitly.
 local found=actor(s,r);assert(not found or found:GetID()==n:GetID(),'Duplicate restored Vergalid actor lease')
 n:SetEntityVariable(MOTION,'');if s.phase=='resetting'then n:SetTimer(NPC_TIMER,1);return true end
 bind(n,s);save(s);resume_motion(n,s,r)
 return true
end
function M.actor_timer(e)
 if e.timer~=NPC_TIMER then return false end
 local n=e.self;local k=n:GetEntityVariable(OWNER)
 if not D.enabled or not here()or k==''then n:StopTimer(NPC_TIMER);return true end
 local s=load(k);local r=s and D.scenes[s.task]
 if not s or not r or not r.enabled or s.instance~=eq.get_zone_instance_id()or n:GetNPCTypeID()~=r.npc then n:StopTimer(NPC_TIMER);return true end
 resume_motion(n,s,r)
 if r.family=='bile'and s.phase=='waiting_for_return'and s.return_deadline and os.time()>=s.return_deadline then
  local c=EL():GetClientByCharID(s.owner)
  -- Give an actual returning owner the next native player-timer opportunity.
  if not(member(c,s,r)and inside(c,r.site))then
   s.phase='expired';s.actor=0;s.pending={};s.next_action=1;save(s)
   n:StopTimer(NPC_TIMER);n:Depop(false)
   if member(c,s,r)then c:Message(13,'The creature has left. You may abandon and request this task again.')end
   return true
  end
 end
 local guardian_target
 if r.family=='orb'and s.phase=='resetting'then reset_orb(s,r);return true end
 if r.family=='orb'and s.phase=='combat'then
  local expired;guardian_target,expired=orb_activity(s,r,n)
  if expired then return true end
 end
 G.sync(s,r,save,guardian_target)
 -- Keep moving/saved actors alive when their owner zones; no auto-depop and
 -- no second spawn inferred from the absence of that character.
 local p=s.position
 if not p or p.x~=n:GetX()or p.y~=n:GetY()or p.z~=n:GetZ()then bind(n,s);save(s)end
 return true
end
function M.death(e)
 -- NPC::Death clears the live NPC ID while finalizing its corpse.
 -- The native completion event retains the original identity explicitly.
 local dead_id=tonumber(e.killed_entity_id)
 if not dead_id or dead_id<=0 or dead_id~=math.floor(dead_id)then return end
 local n=e.self
 local guardian_key=G.key(n)
 if D.enabled and here()and guardian_key~=''then
  local gs=load(guardian_key);local gr=gs and D.scenes[gs.task]
  if gr and gr.enabled then G.death(n,gs,gr,save,dead_id)end
  return
 end
 local k=n:GetEntityVariable(OWNER)
 if not D.enabled or not here()or k==''then return end
 local s=load(k);local r=s and D.scenes[s.task]
 if s and r and r.enabled and s.instance==eq.get_zone_instance_id()and n:GetNPCTypeID()==r.npc and s.actor==dead_id then
  s.phase='corpse';s.actor_died=true;s.pending={};s.next_action=1;save(s)
 end
end
return M
