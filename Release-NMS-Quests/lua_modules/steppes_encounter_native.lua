-- Native Steppes scene executor; ownership/custody checks precede progression.
local M={}
local cfg=require('steppes_encounter_config')
local model=require('steppes_encounter_state')
local json=require('json') -- Existing installed MIT Lua module, not a new runtime dependency.
local busy,queues={},{}
local prefix='hj.steppes.scene.v2.'
local OWNER,TOKEN,BIND='steppes.owner','steppes.token','steppes.bound_id'
local function EL()return eq.get_entity_list()end
local function valid(o)return o and o.valid end
local function scope()return cfg.scene_zone..'.'..cfg.scene_instance..'.'end
local function data(k)local v=eq.get_data(k);if not v or v==''then return nil end;local ok,r=pcall(json.decode,v);if ok then return r end end
local function save(s)eq.set_data(prefix..s.key,json.encode(s))end
local function load(k)return data(prefix..k)end
local function inside(n,b)
 if not b then return false end
 return n:GetX()>=b.minx and n:GetX()<=b.maxx and n:GetY()>=b.miny and n:GetY()<=b.maxy and n:GetZ()>=b.minz and n:GetZ()<=b.maxz
end
local function here()return eq.get_zone_id()==cfg.scene_zone and eq.get_zone_instance_id()==cfg.scene_instance end
local function ident(c,d)
 if not c:IsTaskActive(d.task)then return nil end
 if d.shared then local id=c:GetSharedTaskIdentity();if id~=''then return 'shared:'..id end;return nil end
 local epoch=c:GetBucket('steppes.epoch.'..d.task)
 if epoch~=''then return 'solo:'..c:CharacterID()..':'..epoch end
end
local function key(c,d)local id=ident(c,d);if id then return scope()..d.family..':'..id end end
local function member(c,s,d)return valid(c)and c:IsTaskActive(d.task)and ident(c,d)==s.identity end
local function representative(s,d)
 for c in EL():GetClientList().entries do if member(c,s,d)then return c end end
end
local function actor(s,token)
 local a=s.actors[token];local owner=a and a.external_owner or s.key;local wanted=a and a.external_token or token
 for n in EL():GetNPCList().entries do
  if n:GetEntityVariable(OWNER)==owner and n:GetEntityVariable(TOKEN)==wanted then return n end
 end
end
local function scene_lease(d)return prefix..'lease.'..scope()..d.scene end
local function release(s,d)
 local k=scene_lease(d);if eq.get_data(k)==s.key then eq.delete_data(k)end
end
local function door_restore(s,c)
 if not s.door_snapshot then return end
 c=valid(c)and c or Mob() -- Native nullable Mob wrapper, never an unbound Lua nil.
 local door=EL():GetDoorsByDoorID(s.door_snapshot.id)
 if valid(door)then
  door:SetLockPick(s.door_snapshot.lockpick);door:SetKeyItem(s.door_snapshot.key)
  door:SetDisableTimer(s.door_snapshot.disable_timer)
  if s.door_snapshot.open then door:ForceOpen(c,true)else door:ForceClose(c);door:SetOpenState(false)end
 end
 s.door_snapshot=nil
end
local function yavia_restore(s)
 if not s.yavia_snapshot then return end
 local n=EL():GetNPCByID(s.yavia_snapshot.entity_id)
 if valid(n)and n:GetNPCTypeID()==399032 and n:GetEntityVariable(OWNER)==s.key then
  n:SetHP(s.yavia_snapshot.hp);n:SetEntityVariable(OWNER,'')
 end
 s.yavia_snapshot=nil
end
local function stop(s,d,reason,c)
 -- Original NPCs and earned corpses are never indiscriminately depopped.
 s.status=reason;s.executing=false;save(s)
 for n in EL():GetNPCList().entries do
  if n:GetEntityVariable(OWNER)==s.key and n:GetEntityVariable(TOKEN)~=''then
   n:SetEntityVariable('steppes.cleaning','1');n:Depop(false)
  end
 end
 door_restore(s,c);yavia_restore(s);release(s,d);save(s)
 if valid(c)and reason~='complete'then c:Message(13,'This encounter stopped safely. Remove and request the task again to restart it.')end
end
local function acquire(s,d,c)
 if not d.exclusive then return true end
 local k=scene_lease(d);local owner=eq.get_data(k)
 if owner~=''and owner~=s.key then
  local prior=load(owner)
  if prior and prior.status=='active'then return false end
 end
 eq.set_data(k,s.key)
 if d.family=='yavia'and not s.yavia_snapshot then
  local n=EL():GetNPCByNPCTypeID(d.yavia_npc)
  if not valid(n)then return false end
  if n:GetEntityVariable('steppes.yavia.initialized')~='1'then n:SetHP(math.max(1,math.floor(n:GetMaxHP()*0.11)));n:SetEntityVariable('steppes.yavia.initialized','1')end
  s.yavia_snapshot={entity_id=n:GetID(),hp=n:GetHP()};n:SetEntityVariable(OWNER,s.key)
  eq.set_timer('steppes_actor',cfg.maintenance_ms,n)
 end
 return true
end
local function ready(d)
 if not cfg.enabled or not d.enabled then return false end
 for _,a in pairs(d.actors)do
  if not a.npc_id or(not a.positions and not a.spawn_at_caster)or not a.aggro_reviewed then return false end
 end
 for _,b in pairs(d.bounds)do if not b then return false end end
 if d.family=='yavia'and not d.yavia_hp then return false end
 return true
end
local function ensure(c,d,accepted)
 if not ready(d)then return nil end
 if not d.shared and accepted then
  local v=(tonumber(c:GetBucket('steppes.epoch.'..d.task))or 0)+1
  c:SetBucket('steppes.epoch.'..d.task,tostring(v))
 end
 local k=key(c,d);if not k then return nil end
 c:SetBucket('steppes.last.'..d.task,k)
 local s=load(k)
 if not s then
  if not accepted and not d.shared then return nil end
  s=assert(model.begin({enabled=true,family=d.family,quest=d.quest},ident(c,d),k))
  s.key=k;s.task=d.task;s.members={};s.scope=scope()
  local left=eq.task_time_left(d.task);if left>0 then s.deadline=os.time()+left end
 end
 s.members[tostring(c:CharacterID())]=true;save(s)
 return s
end
local function reconcile(s,d,c,death_token)
 if s.status~='active'then return false end
 if s.executing then stop(s,d,'interrupted_native_effect',c);return false end
 for token,a in pairs(s.actors)do
  if not a.dead and token~=death_token then
   local n=actor(s,token)
   if not n then stop(s,d,'actor_lost_on_reload',c);return false end
   -- Bind-time entityID can be reused, so owner+token are the primary identity.
   a.entity_id=tonumber(n:GetEntityVariable(BIND))
  end
 end
 return true
end
local function event(s,kind,receipt)
 return {kind=kind,receipt=receipt,identity=s.identity,native_verified=true}
end
local apply
local function execute(s,d,c,out)
 for _,fx in ipairs(out)do
  if fx.kind=='spawn'then
   if not here()then error('wrong_scene_zone')end
   local acquired=acquire(s,d,c)
   if not acquired and(d.family=='portal'or d.family=='prophet')then
    -- Original task is solo, but period evidence permits native group kill credit.
    -- Join the already-live original guardian; never spawn a duplicate or retype the task.
    local owner=eq.get_data(scene_lease(d));local existing=load(owner);local joined=false
    if existing then for othertoken,other in pairs(existing.actors)do
     local n=actor(existing,othertoken)
     if other.role==fx.role and valid(n)then
      s.actors[fx.token].external_owner=owner;s.actors[fx.token].external_token=othertoken
      s.actors[fx.token].entity_id=tonumber(n:GetEntityVariable(BIND));joined=true;break
     end
    end end
    if not joined then error('portal_scene_busy_without_live_guardian')end
    save(s)
   elseif not acquired then error('scene_busy')end
   if acquired then
   local a=assert(d.actors[fx.role]);local i=tonumber(fx.token:match(':(%d+)$'))
   local p=a.spawn_at_caster and {x=c:GetX(),y=c:GetY(),z=c:GetZ(),heading=c:GetHeading()}or assert(a.positions[i]or a.positions[1])
   local n=eq.spawn2(a.npc_id,0,0,p.x,p.y,p.z,p.heading)
   if not valid(n)then error('native_spawn_failed')end
   n=n:CastToNPC();n:SetEntityVariable(OWNER,s.key);n:SetEntityVariable(TOKEN,fx.token)
   n:SetEntityVariable(BIND,tostring(n:GetID()));s.actors[fx.token].entity_id=n:GetID()
   if fx.role=='prophet_spirit'then
    if n:CountItem(54667)==0 then n:AddItem(54667,1)end
    if n:CountItem(54667)~=1 then error('unreviewed_duplicate_charm_loot')end
   end -- Period single real-corpse charm.
   if a.aggro then
    local source=s.source_character and EL():GetClientByCharID(s.source_character)or c
    n:AddToHateList(member(source,s,d)and source or c,1)
   end
   eq.set_timer('steppes_actor',cfg.maintenance_ms,n);save(s)
   end
  elseif fx.kind=='objective'then
   local a=assert(d.objectives[fx.objective],'unbound_manual_objective')
   if not member(c,s,d)or not c:IsTaskActivityActive(d.task,a)then error('manual_objective_not_active')end
   -- Mark before native call; a crash midcall fails this scene on reconciliation.
   save(s);c:UpdateTaskActivity(d.task,a,fx.count)
   if(d.family=='portal'and fx.objective=='guardian')or(d.family=='prophet'and fx.objective=='spirit')then release(s,d)end
  elseif fx.kind=='seal_door_lease'then
   if not acquire(s,d,c)then error('crypt_scene_busy')end
   local door=EL():GetDoorsByDoorID(d.door_id);if not valid(door)then error('door_missing')end
   if not s.door_snapshot then s.door_snapshot={id=d.door_id,open=door:IsDoorOpen(),
    lockpick=door:GetLockPick(),key=door:GetKeyItem(),disable_timer=door:GetDisableTimer()}end
   save(s);door:SetDisableTimer(true);door:SetLockPick(65535);door:ForceClose(c);door:SetOpenState(false)
  elseif fx.kind=='release_door_lease'then door_restore(s,c)
  elseif fx.kind=='restore_yavia_lease'then yavia_restore(s)
  elseif fx.kind=='yavia_health_stage'then
   if not acquire(s,d,c)then error('yavia_scene_busy')end
   local n=EL():GetNPCByID(s.yavia_snapshot.entity_id);if not valid(n)then error('yavia_missing')end
   n:SetHP(assert(d.yavia_hp[fx.wave]))
  elseif fx.kind=='trap_kill'then
   local n=EL():GetNPCByID(fx.entity_id)
   if not valid(n)or not cfg.goblins[n:GetNPCTypeID()]then error('trap_victim_missing')end
   n:SetEntityVariable('steppes.trap_owner',s.key)
   n:SetEntityVariable('steppes.trap_victim',tostring(fx.entity_id));save(s)
   n:Kill() -- Real native death; no fabricated kill counters/XP/loot grants.
  elseif fx.kind=='cleanup_owned'then
   for n in EL():GetNPCList().entries do
    if n:GetEntityVariable(OWNER)==s.key and n:GetEntityVariable(TOKEN)~=''then
     n:SetEntityVariable('steppes.cleaning','1');n:Depop(false)
    end
   end
  elseif fx.kind=='release_scene_lease'then release(s,d)
  elseif fx.kind=='chaos_dialogue'then
   local n=EL():GetMobByNpcTypeID(399010);if valid(n)then n:Shout('Death to the gnollses!')end
  else error('unknown_effect:'..fx.kind)end
 end
end
apply=function(s,d,c,e)
 if busy[s.key]then queues[s.key]=queues[s.key]or {};table.insert(queues[s.key],{c=c,e=e});return end
 if not reconcile(s,d,c,e.kind=='owned_death'and e.token or nil)then return end
 busy[s.key]=true
 local nextstate,out=model.apply(s,e);nextstate.executing=true;save(nextstate)
 local ok,why=pcall(execute,nextstate,d,c,out)
 if not ok then stop(nextstate,d,'effect_failure:'..tostring(why),c)
 else nextstate.executing=false;save(nextstate)end
 busy[s.key]=nil
 local q=queues[s.key]or {};queues[s.key]=nil
 for _,v in ipairs(q)do local latest=load(s.key);if latest then apply(latest,d,v.c,v.e)end end
end
function M.accepted(e)
 if not cfg.enabled then return 0 end
 local d=cfg.families[e.task_id];if d then local s=ensure(e.self,d,true);if s then eq.set_timer('steppes_encounter',cfg.maintenance_ms,e.self)end end
 if e.task_id==cfg.rubbing.task or e.task_id==cfg.library.task then
  e.self:SetBucket('steppes.epoch.'..e.task_id,tostring((tonumber(e.self:GetBucket('steppes.epoch.'..e.task_id))or 0)+1))
  eq.set_timer('steppes_encounter',cfg.maintenance_ms,e.self)
 end
 return 0
end
local function visit(c,d)
 local s=ensure(c,d,false);if not s or not here()or not reconcile(s,d,c)then return end
 if s.deadline and os.time()>=s.deadline then stop(s,d,'native_task_expired',c);return end
 if d.shared and eq.shared_task_member_count(s.identity:sub(8))==0 then stop(s,d,'shared_task_ended',c);return end
 for _,trigger in ipairs({'chamber','chest','north_crypt','portal'})do
  local b=d.bounds[trigger]
  local eligible=(trigger=='chest'and s.phase=='chamber')or(trigger~='chest'and s.phase=='start')
  if eligible and trigger~='camp'and trigger~='crossing'and inside(c,b)then
   local e=event(s,'proximity','proximity:'..trigger);e.trigger=trigger
   e.fresh_materials_confirmed=d.family~='portal'or c:IsTaskActivityActive(d.task,d.objectives.portal)
   apply(s,d,c,e);s=load(s.key)
  end
 end
 if d.family=='trap'and s.phase=='trap'then
  local trap
  for token,a in pairs(s.actors)do if a.role=='rune_trap'then trap=actor(s,token)end end
  if valid(trap)then
   for n in EL():GetNPCList().entries do
    local b=d.bounds.crossing
    local crossing={minx=trap:GetX()+b.minx,maxx=trap:GetX()+b.maxx,miny=trap:GetY()+b.miny,maxy=trap:GetY()+b.maxy,minz=trap:GetZ()+b.minz,maxz=trap:GetZ()+b.maxz}
    if cfg.goblins[n:GetNPCTypeID()]and n:GetHP()>0 and inside(n,crossing)then
     -- Original goblins are only trapped when pulled by this native owner/task group.
     if n:GetHateAmount(c)>0 then
      local e=event(s,'trap_crossing','crossing:'..n:GetID());e.eligible_goblin=true;e.live_entity_id=n:GetID()
      apply(load(s.key),d,c,e)
     end
    end
   end
  end
 end
end
local function acquisition(c)
 local r=cfg.rubbing
 if r.enabled and eq.get_zone_id()==399 and c:IsTaskActivityActive(r.task,r.activity)and inside(c,r.stone)then
  local epoch=c:GetBucket('steppes.epoch.'..r.task)
  local receipt='steppes.rubbing.'..epoch
  if epoch~=''and c:GetBucket(receipt)==''and c:GetItemIDAt(Slot.Cursor)==13063 and c:GetInventory():HasItem(88140,1,34)<0 then
   c:SetBucket(receipt,'executing')
   c:DeleteItemInInventory(Slot.Cursor,1,true)
   c:SummonItem(88140)
   -- Native HasItem where34 includes personal inventory and the complete cursor queue.
   if c:GetInventory():HasItem(88140,1,34)>=0 then c:UpdateTaskActivity(r.task,r.activity,1);c:SetBucket(receipt,'done')end
  end
 end
 local l=cfg.library
 if l.enabled and eq.get_zone_id()==401 and c:IsTaskActivityActive(l.task,l.activity)and inside(c,l.bounds)then
  c:UpdateTaskActivity(l.task,l.activity,1)
 end
end
function M.resume(e)
 if not cfg.enabled then return 0 end
 acquisition(e.self)
 if(cfg.rubbing.enabled and e.self:IsTaskActive(cfg.rubbing.task))or(cfg.library.enabled and e.self:IsTaskActive(cfg.library.task))then eq.set_timer('steppes_encounter',cfg.maintenance_ms,e.self)end
 for _,d in pairs(cfg.families)do if ready(d)and e.self:IsTaskActive(d.task)then visit(e.self,d);eq.set_timer('steppes_encounter',cfg.maintenance_ms,e.self)end end
 return 0
end
function M.update(e)
 if not cfg.enabled or e.count==nil then return 0 end
 local d=cfg.families[e.task_id];if not d then return 0 end
 local s=ensure(e.self,d,false);if not s or not here()then return 0 end
 if e.activity_id==0 and(d.family=='bear'or d.family=='gnolls')then
  local v=event(s,'stock_progress','native:'..e.activity_id..':'..e.count)
  v.objective=d.family=='bear'and'goblins'or'gnolls';v.done_count=e.count;apply(s,d,e.self,v)
 elseif d.family=='yavia'and e.activity_id<15 and e.activity_id%3<2 and e.count>=1 then
  local wave=math.floor(e.activity_id/3)+1
  if wave==s.wave then
   local v=event(s,'delivery','native_delivery:'..e.activity_id)
   v.item_id=e.activity_id%3==0 and 88141 or 88142;apply(s,d,e.self,v)
  end
 end
 return 0
end
function M.stage(e)return 0 end -- Native update callback has absolute counts; stage export does not.
function M.trade_receipt(e)return 0 end -- Native delivery count callback owns Yavia transitions.
function M.killed_merit(e)
 if not cfg.enabled then return 0 end
 local n,c=e.self,e.other;local k=n:GetEntityVariable(OWNER);local s=load(k)
 if s then local d=cfg.families[s.task]
  if d and member(c,s,d)then n:SetEntityVariable('steppes.merit.'..s.identity,'1')end
  if d and(d.family=='portal'or d.family=='prophet')and c:IsTaskActivityActive(d.task,d.objectives.guardian or d.objectives.spirit)then
   local own=load(c:GetBucket('steppes.last.'..d.task))
   if own and own.status=='active'and (own.phase=='guardian'or own.phase=='prophet')and member(c,own,d)then
    local keys=n:GetEntityVariable('steppes.group.merit');local ok,items=pcall(json.decode,keys)
    if not ok then items={}end
    items[own.key]=c:CharacterID();n:SetEntityVariable('steppes.group.merit',json.encode(items))
   end
  end
 end
 return 0
end
function M.death_complete(e)
 if not cfg.enabled then return 0 end
 local n=e.self;local trapkey=n:GetEntityVariable('steppes.trap_owner')
 if trapkey~=''then
  local s=load(trapkey);if s then local d=cfg.families[s.task];local c=representative(s,d)
   local id=tonumber(n:GetEntityVariable('steppes.trap_victim'))
   if id==e.killed_entity_id then local v=event(s,'trap_death','trap_death:'..id)
    v.entity_id=id;v.trap_effect_confirmed=true;apply(s,d,c,v)end
  end
 end
 local k=n:GetEntityVariable(OWNER);local s=load(k);if not s then return 0 end
 local d=cfg.families[s.task]
 if d.family=='yavia'and n:GetNPCTypeID()==d.yavia_npc then stop(s,d,'yavia_died',representative(s,d));return 0 end
 if d.family=='portal'or d.family=='prophet'then
  local ok,keys=pcall(json.decode,n:GetEntityVariable('steppes.group.merit'))
  if ok then for ownkey,charid in pairs(keys)do
   local own=load(ownkey);local credited=EL():GetClientByCharID(charid)
   if own and valid(credited)and member(credited,own,d)then
    for token,a in pairs(own.actors)do
     if(a.role=='portal_guardian'or a.role=='prophet_spirit')and a.entity_id==e.killed_entity_id then
      local v=event(own,'owned_death','death:'..token);v.token=token;v.entity_id=e.killed_entity_id;v.kill_credit_confirmed=true
      apply(own,d,credited,v)
     end
    end
   end
  end end
  return 0
 end
 local c=representative(s,d);local token=n:GetEntityVariable(TOKEN)
 if c and n:GetEntityVariable('steppes.merit.'..s.identity)=='1'then
  local v=event(s,'owned_death','death:'..token);v.token=token;v.entity_id=e.killed_entity_id;v.kill_credit_confirmed=true
  apply(s,d,c,v)
 elseif s.status=='active'then stop(s,d,'foreign_or_uncredited_death',c)end
 return 0
end
function M.despawn(e)
 if not cfg.enabled or e.self:GetEntityVariable('steppes.cleaning')=='1'then return 0 end
 local s=load(e.self:GetEntityVariable(OWNER));if not s then return 0 end
 local token=e.self:GetEntityVariable(TOKEN);local a=s.actors[token]
 if(a and not a.dead)or(e.self:GetNPCTypeID()==399032 and s.family=='yavia')then stop(s,cfg.families[s.task],'native_actor_depop',representative(s,cfg.families[s.task]))end
 return 0
end
function M.complete(e)
 if not cfg.enabled then return 0 end
 local d=cfg.families[e.task_id];if not d then return 0 end
 local k=e.self:GetBucket('steppes.last.'..d.task);local s=load(k)
 if s and s.status=='active'then stop(s,d,'complete',e.self)end
 return 0
end
function M.task_fail(e)
 if not cfg.enabled then return 0 end
 local d=cfg.families[e.task_id];if not d then return 0 end
 local s=load(e.self:GetBucket('steppes.last.'..d.task))
 if s and(not d.shared or eq.shared_task_member_count(s.identity:sub(8))==0)then stop(s,d,'task_failed',e.self)end
 return 0
end
function M.timer(e)
 if not cfg.enabled then return 0 end
 if e.timer=='steppes_encounter'then M.resume(e)
 elseif e.timer=='steppes_actor'then
  local s=load(e.self:GetEntityVariable(OWNER));if s then local d=cfg.families[s.task];local c=representative(s,d)
   if not reconcile(s,d,c)then return 0 end
   if(s.deadline and os.time()>=s.deadline)or(d.shared and eq.shared_task_member_count(s.identity:sub(8))==0)then stop(s,d,'native_task_ended',c)
   elseif not d.shared then
    local id=tonumber(s.identity:match('solo:(%d+):'));local owner=EL():GetClientByCharID(id)
    if valid(owner)and not member(owner,s,d)then stop(s,d,'solo_task_removed',owner)end
   end
  end
 end
 return 0
end
function M.click_door(e)
 if not cfg.enabled or not here()then return 0 end
 local d=cfg.families[3040609];local k=eq.get_data(scene_lease(d));local s=load(k)
 if s and s.status=='active'and s.door_sealed and e.door:GetDoorID()==d.door_id then return 1 end
 if ready(d)and e.door:GetDoorID()==d.door_id and e.self:IsTaskActive(d.task)then e.door:ForceOpen(e.self,true);return 1 end
 return 0
end
function M.cast(e)
 if not cfg.enabled then return 0 end
 local sp=e.spell:ID();local d=cfg.families[3040607]
 if sp==7230 and e.cast_item_id==84243 and here()and ready(d)and inside(e.self,d.bounds.camp)then
  local s=ensure(e.self,d,false);if s then
   local v=event(s,'completed_cast','cast:'..e.self:CharacterID()..':'..os.time()..':'..s.sequence)
   v.spell_id=sp;v.in_validated_camp=true;apply(s,d,e.self,v)
  end
 end
 -- Charged portal repair behavior is separate from achievement completion.
 local r=cfg.repair;local item=({[9483]=87206,[9484]=87207,[9485]=87208})[sp]
 if r.enabled and r.reset_policy and item and item==e.cast_item_id and e.cast_item_charge_consumed and inside(e.self,r.bounds)then
  local k=prefix..'repair.'..scope();local s=data(k)or{percent=0}
  local amount=({[9483]=1,[9484]=2,[9485]=3})[sp];s.percent=math.min(100,s.percent+amount);eq.set_data(k,json.encode(s))
  e.self:Message(15,'The portal is '..s.percent..'% repaired.')
  -- Full-portal raid continuation remains adjacent content; no task/achievement credit.
 end
 return 0
end
function M.before_update(e)
 if not cfg.enabled then return 0 end
 local d=cfg.families[e.task_id]
 if d and d.enabled and not ready(d)then return 1 end
 if d and ready(d)and((e.activity_id==0 and(d.family=='bear'or d.family=='gnolls'))or(d.family=='yavia'and e.activity_id<15 and e.activity_id%3<2))then
  local s=ensure(e.self,d,false);if s then s.source_character=e.self:CharacterID();save(s)end
 end
 if d and d.family=='yavia'and ready(d)and e.activity_id<15 and e.activity_id%3<2 then
  local s=ensure(e.self,d,false)
  if not s or s.status~='active'or not acquire(s,d,e.self)then return 1 end
  save(s) -- Lease acquired BEFORE core consumes either delivery; foreign hand-ins return intact.
 end
 return 0
end
function M.say(e)return 0 end
function M.zone_shutdown(e)
 if not cfg.enabled or not here()then return 0 end
 -- Live NPC tags provide exact local ownership even if no owner client remains online.
 local seen={};for n in EL():GetNPCList().entries do local k=n:GetEntityVariable(OWNER)
  if k~=''and not seen[k]then seen[k]=true;local s=load(k);if s then stop(s,cfg.families[s.task],'zone_shutdown',representative(s,cfg.families[s.task]))end end
 end
 return 0
end
function M.spawn(e)
 local d=cfg.families[3040610]
 if ready(d)and e.self:GetNPCTypeID()==399032 then
  e.self:SetHP(math.max(1,math.floor(e.self:GetMaxHP()*0.11)))
  e.self:SetEntityVariable('steppes.yavia.initialized','1')
 end
 return 0
end -- Original Yavia is never respawned/replaced by this module.
return M
