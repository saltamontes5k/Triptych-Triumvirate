-- Private staging. Original actions/endpoints are researched; reconstructed
-- probabilities, combat stats and scene timings are labelled in scene data.
local D=require('achievement_quest_bixie_scenes_data')
local M={}
local actors={}
local function yes(v)return v==true or v==1 end
local function stage(c,t,a)return c and c.valid and yes(c:IsTaskActivityActive(t,a)) end
local function tokenkey(task)return 'achievement_may2013_bixie_attempt_'..task end
local function generation(c,task,renew)
 local key=tokenkey(task);local token=c:GetBucket(key)
 if renew or token=='' then
  local prior=tonumber(token:match('_(%d+)$')) or 0
  token=tostring(os.time())..'_'..c:CharacterID()..'_'..(prior+1)
  c:SetBucket(key,token)
 end
 return token
end
local function queuekey(char,task,token)
 return 'achievement_may2013_bixie_arrivals_'..char..'_'..task..'_'..token
end
local function bucketkey(id)
 return 'achievement_may2013_bixie_bucket_'..eq.get_zone_id()..'_'..eq.get_zone_instance_id()..'_'..id
end
local function near(a,b,r,z)
 local x,y=a:GetX()-b:GetX(),a:GetY()-b:GetY()
 return x*x+y*y<=r*r and math.abs(a:GetZ()-b:GetZ())<=z
end
local function clear(n)
 actors[n:GetID()]=nil;n:StopTimer('bixie_scene');n:StopTimer('bixie_guard_expire')
end
function M.accepted(e)
 if e.task_id==D.verrin.task or e.task_id==D.thralls.task then generation(e.other,e.task_id,true) end
end
local function flush(c,rule)
 local token=c:GetBucket(tokenkey(rule.task));if token=='' then return end
 local key=queuekey(c:CharacterID(),rule.task,token)
 local count=tonumber(eq.get_data(key)) or 0
 if count>0 and stage(c,rule.task,rule.activity) then
  -- Native task logic caps the count; a saved receipt is removed before credit
  -- so reconnects cannot repeatedly count the same NPC arrival.
  eq.delete_data(key)
  c:UpdateTaskActivity(rule.task,rule.activity,count)
 end
end
function M.player_sync(c)
 flush(c,D.verrin);flush(c,D.thralls)
end
function M.player_signal(e)
 if e.signal~=19903907 then return false end
 M.player_sync(e.self);return true
end
function M.player_enter(e)
 local c=e.self
 M.player_sync(c)
 if eq.get_zone_id()~=395 then return end
 local any=false
 for id in pairs(D.buckets.doors) do
  local ready=tonumber(eq.get_data(bucketkey(id))) or 0
  if ready>os.time() then
   local door=eq.get_entity_list():GetDoorsByDoorID(id)
   if door.valid then door:SetDisableTimer(true);door:ForceOpen(c,true) end
   any=true
  elseif ready>0 then
   local door=eq.get_entity_list():GetDoorsByDoorID(id)
   if door.valid then door:ForceClose(c,false);door:SetDisableTimer(false) end
   eq.delete_data(bucketkey(id))
  end
 end
 if any then c:SetTimer('bixie_bucket_refresh',1) end
end
function M.player_timer(e)
 if e.timer~='bixie_bucket_refresh' then return false end
 local any=false
 for id in pairs(D.buckets.doors) do
  local key=bucketkey(id);local ready=tonumber(eq.get_data(key)) or 0
  if ready>0 then
   if ready>os.time() then any=true else
    local door=eq.get_entity_list():GetDoorsByDoorID(id)
    if door.valid then door:ForceClose(e.self,false);door:SetDisableTimer(false) end
    eq.delete_data(key)
   end
  end
 end
 if not any then e.self:StopTimer(e.timer) end
 return true
end
function M.click_door(e)
 local id=e.door:GetDoorID();local item=D.buckets.doors[id]
 if not item then return nil end
 local c=e.self
 if not near(c,e.door,D.buckets.radius,D.buckets.height) then
  c:Message(13,'You cannot reach that. Move closer.');return 1
 end
 if yes(c:IsInvisible()) then c:Message(13,'You must be visible to collect the jumjum.');return 1 end
 if (tonumber(eq.get_data(bucketkey(id))) or 0)>os.time() then return 1 end
 if c:GetItemIDAt(Slot.Cursor)>0 then c:Message(13,'Empty your item cursor first.');return 1 end
 local empty=math.random(1,100)<=D.buckets.empty_percent
 if not empty then
  local before=c:CountItem(item);c:SummonItem(item,1)
  if c:CountItem(item)~=before+1 then return 1 end
  local activity=D.buckets.activity[item]
  if stage(c,D.buckets.task,activity) then c:UpdateTaskActivity(D.buckets.task,activity,1) end
 end
 eq.set_data(bucketkey(id),tostring(os.time()+D.buckets.respawn_seconds))
 e.door:SetDisableTimer(true);e.door:ForceOpen(c,true)
 c:SetTimer('bixie_bucket_refresh',1)
 return 1
end
local function target(n,rule)
 n:SetRunning(false)
 n:MoveTo(rule.finish.x,rule.finish.y,rule.finish.z,rule.finish.h or 0,false)
end
local function begin(n,c,rule)
 local state={char=c:CharacterID(),task=rule.task,activity=rule.activity,
  token=generation(c,rule.task,false),started=os.time(),rule=rule,phase='walking'}
 actors[n:GetID()]=state
 n:SetAppearance(0);n:SetNPCFactionID(0)
 target(n,rule);n:SetTimer('bixie_scene',2)
 return state
end
function M.say(e)
 if e.self:GetNPCTypeID()~=D.verrin.npc then return false end
 local text=e.message:lower()
 if text:find('hail',1,true) then
  e.self:Say('Quiet! I am hiding here. Tell me when the area is [clear] enough to leave.');return true
 end
 if not text:find('clear',1,true) then return false end
 local c=e.other;local rule=D.verrin
 if not stage(c,rule.task,rule.activity) then
  if stage(c,rule.task,rule.kill_activity) then e.self:Say('There are still too many bixies nearby for me to leave.') end
  return true
 end
 local current=actors[e.self:GetID()]
 if current then
  if current.char~=c:CharacterID() then c:Message(13,'Verrin is already returning to camp with another scout.') end
  return true
 end
 e.self:Say('Thank you. I will return to camp.');begin(e.self,c,rule)
 return true
end
function M.spawn(e)
 local id=e.self:GetNPCTypeID()
 if id==D.silo.npc then
  -- Trade-capable static barrel, not an attackable LDoN treasure chest.
  for _,ability in ipairs({SpecialAbility.immune_melee,SpecialAbility.immune_magic,SpecialAbility.immune_aggro,SpecialAbility.immune_aggro_on}) do e.self:SetSpecialAbility(ability,1) end
 end
 if id==D.verrin.npc then e.self:SetAppearance(3) end
 if id==395240 then e.self:SetSpecialAbility(SpecialAbility.rampage,1) end
 if id==395259 then e.self:SetSpecialAbility(SpecialAbility.flurry,1) end
 if id==395181 then
  e.self:SetSpecialAbility(SpecialAbility.unmezable,1)
  e.self:SetSpecialAbility(SpecialAbility.uncharmable,1)
 end
 for _,freed in pairs(D.thralls.freed_types) do
  if id==freed then e.self:SetTimer('bixie_unowned_expire',10);return end
 end
end
local function handin(e,required)
 local given,items={},{}
 for i=1,4 do
  local inst=e.trade['item'..i]
  if inst and inst.valid then
   items[#items+1]=inst;local id=tostring(inst:GetID())
   given[id]=(given[id] or 0)+(inst:IsStackable() and inst:GetCharges() or 1)
  end
 end
 for _,coin in ipairs({'copper','silver','gold','platinum'}) do
  if (e.trade[coin] or 0)>0 then given[coin]=e.trade[coin] end
 end
 local enough=true
 for id,count in pairs(required)do if (given[id] or 0)<count then enough=false end end
 local ok=enough and e.self:CheckHandin(e.other,given,required,items)
 e.self:ReturnHandinItems(e.other)
 return ok
end
local function traded(e,id)
 local count=0
 for i=1,4 do
  local inst=e.trade['item'..i]
  if inst and inst.valid and inst:GetID()==id then count=count+(inst:IsStackable() and inst:GetCharges() or 1) end
 end
 return count
end
function M.trade(e)
 local id=e.self:GetNPCTypeID();local c=e.other;local rule=D.thralls
 if id==rule.alchemist then
  if traded(e,rule.powder)<1 then return false end
  -- Native delivery may already have advanced to rescues before EVENT_TRADE.
  if not stage(c,rule.task,rule.powder_activity) and not stage(c,rule.task,rule.activity) then e.self:ReturnHandinItems(c);return true end
  if c:GetItemIDAt(Slot.Cursor)>0 then
   c:Message(13,'Empty your item cursor and give me the powder again.');e.self:ReturnHandinItems(c);return true
  end
  local before=c:CountItem(rule.antidote)
  c:SummonItem(rule.antidote,rule.antidote_quantity)
  if c:CountItem(rule.antidote)~=before+rule.antidote_quantity then e.self:ReturnHandinItems(c);return true end
  if not handin(e,{[tostring(rule.powder)]=1}) then c:RemoveItem(rule.antidote,rule.antidote_quantity) end
  return true
 end
 if rule.npcs[id] then
  if not e.self.valid then return true end
  if traded(e,rule.antidote)<1 then return false end
  if not stage(c,rule.task,rule.activity) or actors[e.self:GetID()] then e.self:ReturnHandinItems(c);return true end
  -- Keep the stock spawn's refill separate from the long walk. Historical
  -- players rescued the same respawning thrall while earlier ones walked.
  local freed_mob=eq.spawn2(rule.freed_types[id],0,0,e.self:GetX(),e.self:GetY(),e.self:GetZ(),0)
  if not freed_mob or not freed_mob.valid then e.self:ReturnHandinItems(c);return true end
  local freed=freed_mob:CastToNPC()
  local guard_type=rule.guards[math.random(1,#rule.guards)]
  -- Reuse the original source point. An arbitrary lateral offset can put
  -- the guard inside the farmhouse wall, making ordinary melee fail.
  local guard=eq.spawn2(guard_type,0,0,e.self:GetX(),e.self:GetY(),e.self:GetZ(),0)
  if not guard or not guard.valid then freed:Depop();e.self:ReturnHandinItems(c);return true end
  if not handin(e,{[tostring(rule.antidote)]=1}) then guard:Depop();freed:Depop();return true end
  local state=begin(freed,c,rule);state.guard=guard:GetID()
  guard:SetEntityVariable('bixie_scene_victim',tostring(freed:GetID()))
  guard:SetTimer('bixie_guard_expire',rule.timeout_seconds)
  guard:AddToHateList(freed,1)
  freed:Say('The haze is clearing. Please help me escape!')
  e.self:Depop(true)
  return true
 end
 return false
end
function M.silo(e,delivered)
 if e.self:GetNPCTypeID()~=D.silo.npc or delivered<1 then return end
 if actors[e.self:GetID()] then return end
 local spawned=eq.spawn2(D.silo.ooze,0,0,e.self:GetX(),e.self:GetY(),e.self:GetZ(),0)
 if not spawned or not spawned.valid then return end
 local ooze=spawned:CastToNPC()
 if not ooze.valid then return end
 local state={phase='eating',ticks=0,ooze=ooze:GetID()}
 actors[e.self:GetID()]=state
 ooze:SetTargetable(false);ooze:SetNPCFactionID(0)
 for _,ability in ipairs({SpecialAbility.immune_melee,SpecialAbility.immune_magic,SpecialAbility.immune_aggro,SpecialAbility.immune_aggro_on}) do ooze:SetSpecialAbility(ability,1) end
 ooze:MoveTo(e.self:GetX(),e.self:GetY(),e.self:GetZ(),0,false)
 e.self:SetTimer('bixie_scene',D.silo.tick_seconds)
end
function M.combat(e)
 if e.self:GetNPCTypeID()==395181 and yes(e.joined) then e.self:Say('Is that you, Mommy?') end
end
function M.death_complete(e)
 if e.self:GetNPCTypeID()==395181 then e.self:Say("It's so quiet . . .") end
 if e.self:GetNPCTypeID()==D.cocoons.npc then
  for i=1,math.random(D.cocoons.minimum,D.cocoons.maximum) do
   eq.spawn2(D.cocoons.larva,0,0,e.self:GetX()+math.random(-3,3),e.self:GetY()+math.random(-3,3),e.self:GetZ(),0)
  end
 end
 clear(e.self)
end
local function arrival(n,s)
 local c=eq.get_entity_list():GetClientByCharID(s.char)
 if c.valid and c:GetBucket(tokenkey(s.task))==s.token then
  if stage(c,s.task,s.activity) then c:UpdateTaskActivity(s.task,s.activity,1) end
 else
  local key=queuekey(s.char,s.task,s.token)
  eq.set_data(key,tostring((tonumber(eq.get_data(key)) or 0)+1),'7d')
  eq.cross_zone_signal_client_by_char_id(s.char,19903907)
 end
 clear(n);n:Depop(true)
end
function M.timer(e)
 if e.timer=='bixie_unowned_expire' then
  e.self:StopTimer(e.timer)
  if not actors[e.self:GetID()] then e.self:Depop() end
  return true
 end
 if e.timer=='bixie_guard_expire' then clear(e.self);e.self:Depop();return true end
 if e.timer~='bixie_scene' then return false end
 local n=e.self;local s=actors[n:GetID()]
 if not s then n:StopTimer(e.timer);return true end
 if s.phase=='eating' then
  local ooze=eq.get_entity_list():GetNPCByID(s.ooze)
  if not ooze.valid then clear(n);return true end
  s.ticks=s.ticks+1
  ooze:ChangeSize(D.silo.initial_size+s.ticks*D.silo.growth_per_tick)
  ooze:Emote('grows as it consumes the jumjum.')
  if s.ticks>=D.silo.ticks then
   ooze:Emote('swells with stolen jumjum, then bursts!')
   ooze:Depop();clear(n)
  end
  return true
 end
 if os.time()-s.started>s.rule.timeout_seconds then clear(n);n:Depop(true);return true end
 if n:GetHP()<=0 then clear(n);return true end
 local p=s.rule.finish
 local x,y=n:GetX()-p.x,n:GetY()-p.y
 if x*x+y*y<=s.rule.arrival_radius^2 and math.abs(n:GetZ()-p.z)<=s.rule.arrival_height then
  arrival(n,s);return true
 end
 -- Combat/mez may interrupt movement. Resume genuine navigation after it;
 -- elapsed time alone never supplies escort/rescue objective credit.
 if not yes(n:IsEngaged()) then target(n,s.rule) end
 return true
end
function M.despawn(e)clear(e.self)end
return M
