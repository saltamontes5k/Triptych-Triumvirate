-- Authored quest reconstruction. Native tasks own kills, loot, deliveries and rewards.
local D=require('achievement_quest_blightfire_spirits_data')
local M={}
local function yes(v)return v==true or v==1 end
local function active(c,t,a)return c and c.valid and yes(c:IsTaskActivityActive(t,a))end
local function near(a,x,y,r,z,height)
 return (a:GetX()-x)^2+(a:GetY()-y)^2<=r*r and (not z or math.abs(a:GetZ()-z)<height)
end
local function key(s)return 'achievement_may2013_spirits_'..eq.get_zone_id()..'_'..eq.get_zone_instance_id()..'_'..s end
local function number(k)return tonumber(eq.get_data(k)) or 0 end
local function has(c,id)return c:GetInventory():HasItem(id,1)~=-1 end
local function give(c,id)
 if has(c,id)then return true end
 if c:GetItemIDAt(Slot.Cursor)>0 then return false end
 local before=c:CountItem(id);c:SummonItem(id,1)
 return c:CountItem(id)==before+1
end
local function ground(n,x,y,z)
 local value=n:FindGroundZ(x,y,z)
 if value and value>-10000 and value<10000 then return value end
end
local function controller(origin)
 local n=eq.get_entity_list():GetNPCByNPCTypeID(D.ritual.controller)
 if n.valid then return n end
 local g=eq.get_entity_list():GetNPCByNPCTypeID(D.ritual.gubjak)
 if not g.valid then g=origin end
 if not g or not g.valid then return end
 local z=ground(g,D.ritual.x,D.ritual.y,D.ritual.z_hint)
 if not z then return end
 local spawned=eq.spawn2(D.ritual.controller,0,0,D.ritual.x,D.ritual.y,z,0)
 if spawned and spawned.valid then return spawned:CastToNPC()end
end
function M.player_sync(c)
 if active(c,D.wand.task,0)then give(c,D.wand.unattuned)end
 if active(c,D.wand.task,1)then
  if give(c,D.wand.attuned) and c:CountItem(D.wand.unattuned)>0 then c:RemoveItem(D.wand.unattuned,1)end
 end
 if eq.get_zone_id()==395 and (active(c,D.dragon.task,1)or active(c,D.dragon.task,2))
  and near(c,D.dragon.x,D.dragon.y,D.dragon.radius)then give(c,D.dragon.item)end
end
function M.player_event(e)
 if e.task_id and e.task_id~=D.wand.task and e.task_id~=D.dragon.task then return end
 M.player_sync(e.self)
 if yes(e.self:IsTaskActive(D.wand.task))or yes(e.self:IsTaskActive(D.dragon.task))then
  e.self:SetTimer('spirit_player_sync',2)
 end
end
function M.player_accepted(e)
 if e.task_id==D.wand.task then
  local k='achievement_may2013_spirit_wand_attempt'
  local old=e.self:GetBucket(k);local sequence=(tonumber(old:match('_(%d+)$'))or 0)+1
  e.self:SetBucket(k,tostring(os.time())..'_'..e.self:CharacterID()..'_'..sequence)
 end
 M.player_event(e)
end
function M.player_timer(e)
 if e.timer~='spirit_player_sync'then return false end
 if not yes(e.self:IsTaskActive(D.wand.task))and not yes(e.self:IsTaskActive(D.dragon.task))then
  e.self:StopTimer(e.timer);return true
 end
 M.player_sync(e.self);return true
end
function M.player_enter(e)
 M.player_event(e)
 if eq.get_zone_id()~=395 then return end
 local pending=number(key('fire'))>os.time()
 for id in pairs(D.skulls.doors)do
  if number(key('skull_'..id))>os.time()then
   local door=eq.get_entity_list():GetDoorsByDoorID(id)
   if door.valid then door:SetDisableTimer(true);door:ForceOpen(e.self,true)end
   pending=true
  end
 end
 if pending then controller(e.self)end
end
local function eligible(c,t)
 if not yes(eq.is_task_appropriate(t.id))or yes(c:IsTaskActive(t.id))then return false end
 if not t.repeatable and yes(c:IsTaskCompleted(t.id))then return false end
 for _,p in ipairs(t.prerequisites)do if not yes(c:IsTaskCompleted(p))then return false end end
 return true
end
local function restore_giant(n)
 local faction=tonumber(n:GetEntityVariable('spirit_original_faction'))
 if faction then n:SetNPCFactionID(faction)end
 local immune=tonumber(n:GetEntityVariable('spirit_original_aggro'))or 0
 n:SetSpecialAbility(SpecialAbility.immune_aggro,immune)
 n:SetEntityVariable('spirit_owner','');n:SetEntityVariable('spirit_atone','');n:SetEntityVariable('spirit_lord','')
 n:SetEntityVariable('spirit_attempt','')
 n:ResumeWandering();n:StopTimer('spirit_conversation')
end
local function giant_say(e)
 local n=e.self;local owner=tonumber(n:GetEntityVariable('spirit_owner'))
 if not owner then return false end
 local c=e.other
 if owner~=c:CharacterID()or not active(c,D.wand.task,1)
  or n:GetEntityVariable('spirit_attempt')~=c:GetBucket('achievement_may2013_spirit_wand_attempt')
  or not near(c,n:GetX(),n:GetY(),30,n:GetZ(),30)then return true end
 local text=e.message:lower()
 if text:find('disturb',1,true)then n:Say('We are fallen spirits. We must [atone] for defying our [lord].')end
 if text:find('atone',1,true)then n:SetEntityVariable('spirit_atone','1');n:Say('We are bound between life and death, unable to find peace.')end
 if text:find('lord',1,true)then n:SetEntityVariable('spirit_lord','1');n:Say('We disobeyed Rallos and refused his call to battle. His punishment binds us here.')end
 if n:GetEntityVariable('spirit_atone')=='1'and n:GetEntityVariable('spirit_lord')=='1'then
  c:UpdateTaskActivity(D.wand.task,1,1);n:Emote('finally finds release from the endless wandering.');n:Depop()
 end
 return true
end
function M.siphon(e)
 if e.spell_id~=D.wand.spell or eq.get_zone_id()~=395 or not e.target.valid then return 0 end
 local c=eq.get_entity_list():GetClientByID(e.caster_id)
 if not c.valid or not active(c,D.wand.task,1)or not has(c,D.wand.attuned)then return 0 end
 local n=e.target:CastToNPC();if not n.valid then return 0 end
 local allowed=false;for _,id in ipairs(D.wand.eligible)do if n:GetNPCTypeID()==id then allowed=true end end
 local owner=tonumber(n:GetEntityVariable('spirit_owner'))
 if owner and owner~=c:CharacterID()then c:Message(13,'That spirit is already speaking to another investigator.');return 1 end
 if owner==c:CharacterID()then return 1 end
 if not allowed or math.random(1,100)>D.wand.success_percent then
  c:Message(13,'The giant spirit seems unaffected by the wand.');return 1
 end
 -- Success before low health is documented in2007; do not invent a20percent gate.
 n:SetEntityVariable('spirit_original_faction',tostring(n:GetNPCFactionID()))
 n:SetEntityVariable('spirit_original_aggro',tostring(n:GetSpecialAbility(SpecialAbility.immune_aggro)))
 n:SetEntityVariable('spirit_owner',tostring(c:CharacterID()))
 n:SetEntityVariable('spirit_attempt',c:GetBucket('achievement_may2013_spirit_wand_attempt'))
 n:SetEntityVariable('spirit_atone','');n:SetEntityVariable('spirit_lord','')
 n:WipeHateList();n:SetNPCFactionID(0);n:SetSpecialAbility(SpecialAbility.immune_aggro,1);n:PauseWandering(D.wand.conversation_seconds)
 n:SetTimer('spirit_conversation',D.wand.conversation_seconds)
 n:Say('Who would [disturb] our restless spirits?')
 return 1
end
function M.say(e)
 if giant_say(e)then return true end
 local c=e.other;local id=e.self:GetNPCTypeID();local text=e.message:lower();local choices={};local owned=false
 for tid,t in pairs(D.tasks)do
  if t.giver==id then
   owned=true
   if (text:find(t.request_keyword,1,true)or text:find('work',1,true)or text:find('task',1,true))and eligible(c,t)then choices[#choices+1]=tid end
  end
 end
 if not owned then return false end
 table.sort(choices)
 if #choices>0 then eq.task_selector(choices);return true end
 M.player_sync(c)
 if id==394108 then
  -- Let the original Akins callback continue to offer his two existing quests.
  if text:find('hail',1,true)then e.self:Say('Ask about my [theory], what I [initially thought], the [bottom] of the mystery, or [solving] it. My earlier [work] is still available.')end
  return false
 end
 if id==D.ritual.gubjak then
  if active(c,D.skulls.task,2)then
   e.self:SetEntityVariable('spirit_fade_owner',tostring(c:CharacterID()));e.self:SetTimer('spirit_fade',1)
  else e.self:Say('Show [compassion] to the lost. After the first ritual, the [totems] must be [destroyed].')end
 end
 return true
end
local function handin(e,required)
 local given,items={},{}
 for slot=1,4 do local i=e.trade['item'..slot]
  if i and i.valid then items[#items+1]=i;local id=tostring(i:GetID());given[id]=(given[id]or 0)+(i:IsStackable()and i:GetCharges()or 1)end
 end
 for _,coin in ipairs({'copper','silver','gold','platinum'})do if(e.trade[coin]or 0)>0 then given[coin]=e.trade[coin]end end
 for id,count in pairs(required)do if(given[id]or 0)<count then e.self:ReturnHandinItems(e.other);return false end end
 local result=e.self:CheckHandin(e.other,given,required,items);e.self:ReturnHandinItems(e.other);return result
end
local function begin_ritual(n)
 if n:GetEntityVariable('spirit_phase')=='walking'then return end
 local r=D.ritual;local z=ground(n,r.x,r.y,r.z_hint)
 if not z then return end
 n:SetEntityVariable('spirit_home_x',tostring(n:GetX()));n:SetEntityVariable('spirit_home_y',tostring(n:GetY()));n:SetEntityVariable('spirit_home_z',tostring(n:GetZ()))
 n:SetEntityVariable('spirit_phase','walking');n:SetEntityVariable('spirit_walk_until',tostring(os.time()+r.walk_timeout_seconds))
 n:SetEntityVariable('spirit_fire_z',tostring(z));n:SetRunning(false);n:MoveTo(r.x,r.y,z,0,false)
 n:SetTimer('spirit_ritual_walk',1);n:Say('Wait here while I carry the bark to the ritual fire.')
end
function M.trade(e)
 local used={}
 for slot=1,4 do local i=e.trade['item'..slot]
  if i and i.valid and i:GetTaskDeliveredCount()>0 then local id=tostring(i:GetID());used[id]=(used[id]or 0)+i:GetTaskDeliveredCount()end
 end
 local gubjak=e.self:GetNPCTypeID()==D.ritual.gubjak
 if gubjak and active(e.other,D.ritual.task,3)then
  if e.self:GetEntityVariable('spirit_phase')=='walking'then e.self:ReturnHandinItems(e.other);return end
  if not ground(e.self,D.ritual.x,D.ritual.y,D.ritual.z_hint)then e.self:ReturnHandinItems(e.other);return end
  local required=next(used)and used or {['36179']=4}
  if handin(e,required)then begin_ritual(e.self)end
  return
 end
 if next(used)then handin(e,used)else e.self:ReturnHandinItems(e.other)end
end
local function skulls_refresh(sender)
 local pending=false
 for id in pairs(D.skulls.doors)do
  local k=key('skull_'..id);local ready=number(k)
  if ready>os.time()then pending=true
  elseif ready>0 then
   local door=eq.get_entity_list():GetDoorsByDoorID(id)
   if door.valid then door:ForceClose(sender,false);door:SetDisableTimer(false)end
   eq.delete_data(k)
  end
 end
 return pending
end
function M.click_door(e)
 local id=e.door:GetDoorID();local p=D.skulls.doors[id];if not p then return nil end
 local c=e.self
 if not active(c,D.skulls.task,0)then return nil end
 if not near(c,p.x,p.y,D.skulls.radius,p.z,D.skulls.height)then c:Message(13,'Move closer to the skull.');return 1 end
 if number(key('skull_'..id))>os.time()then return 1 end
 if not controller(c)then return 1 end
 local dx,dy=D.ritual.x-p.x,D.ritual.y-p.y;local length=math.sqrt(dx*dx+dy*dy);if length<1 then return 1 end
 local nx,ny=dx/length,dy/length;local guards={}
 for _,side in ipairs({-1,1})do
  local x,y=p.x+nx*20-ny*side*5,p.y+ny*20+nx*side*5
  local z=ground(c,x,y,p.z)
  if not z then for _,n in ipairs(guards)do n:Depop()end;return 1 end
  local mob=eq.spawn2(D.skulls.guardian,0,0,x,y,z,0)
  if not mob or not mob.valid then for _,n in ipairs(guards)do n:Depop()end;return 1 end
  guards[#guards+1]=mob
 end
 eq.set_data(key('skull_'..id),tostring(os.time()+D.skulls.cooldown_seconds),'2h')
 e.door:SetDisableTimer(true);e.door:ForceOpen(c,true)
 c:UpdateTaskActivity(D.skulls.task,0,1);c:Message(15,'The skull crumbles, releasing two ancestral guardians.')
 controller(c);return 1
end
function M.spawn(e)
 local n=e.self;local id=n:GetNPCTypeID()
 if id==D.ritual.controller then
  n:SetTargetable(false);n:SetInvisible(1)
  for _,a in ipairs({SpecialAbility.immune_melee,SpecialAbility.immune_magic,SpecialAbility.immune_aggro,SpecialAbility.immune_aggro_on})do n:SetSpecialAbility(a,1)end
  n:SetTimer('spirit_controller',2)
 elseif id==D.skulls.guardian or id==D.ritual.shades[1]or id==D.ritual.shades[2]then
  n:SetEntityVariable('spirit_spawned',tostring(os.time()));n:SetTimer('spirit_actor_expire',10)
 elseif id==D.ritual.gubjak then
  if number(key('fire'))>os.time()then controller()end
 end
end
function M.timer(e)
 local n=e.self;local now=os.time();local r=D.ritual
 if e.timer=='spirit_conversation'then restore_giant(n);return true end
 if e.timer=='spirit_fade'then
  n:StopTimer(e.timer);local c=eq.get_entity_list():GetClientByCharID(tonumber(n:GetEntityVariable('spirit_fade_owner'))or 0)
  if c.valid and yes(c:IsTaskCompleted(D.skulls.task))then n:Emote('finds peace and fades from sight.');n:Depop(true)end
  return true
 end
 if e.timer=='spirit_actor_expire'then
  local started=tonumber(n:GetEntityVariable('spirit_spawned'))or now
  if now-started>=r.seconds then n:Depop()end
  return true
 end
 if e.timer=='spirit_ritual_walk'then
  local z=tonumber(n:GetEntityVariable('spirit_fire_z'))or r.z_hint
  if near(n,r.x,r.y,12,z,15)then
   eq.set_data(key('fire'),tostring(math.max(now,number(key('fire')))+r.seconds),'2d')
   n:Emote('places the bark in the ritual fire, calling the lost spirits.');controller()
   n:MoveTo(tonumber(n:GetEntityVariable('spirit_home_x')),tonumber(n:GetEntityVariable('spirit_home_y')),tonumber(n:GetEntityVariable('spirit_home_z')),0,false)
   n:SetEntityVariable('spirit_phase','');n:StopTimer(e.timer)
  elseif now>(tonumber(n:GetEntityVariable('spirit_walk_until'))or 0)then
   n:SetEntityVariable('spirit_phase','');n:StopTimer(e.timer)
  elseif not yes(n:IsEngaged())then n:MoveTo(r.x,r.y,z,0,false)end
  return true
 end
 if e.timer~='spirit_controller'then return false end
 local expiry=number(key('fire'));local skull_pending=skulls_refresh(n)
 for slot=1,r.slots do
  local id=tonumber(n:GetEntityVariable('spirit_slot_'..slot))or 0
  local actor=eq.get_entity_list():GetNPCByID(id)
  local owned=actor.valid and actor:GetEntityVariable('spirit_ritual_controller')==tostring(n:GetID())
   and actor:GetEntityVariable('spirit_ritual_slot')==tostring(slot)
  if expiry<=now then
   if owned then actor:Depop()end
  elseif not owned then
   local next_spawn=tonumber(n:GetEntityVariable('spirit_next_'..slot))or 0
   if id>0 then
    n:SetEntityVariable('spirit_slot_'..slot,'0');n:SetEntityVariable('spirit_next_'..slot,tostring(now+r.respawn_seconds))
   elseif next_spawn<=now then
    local angle=2*math.pi*(slot-1)/r.slots;local x,y=r.x+math.cos(angle)*100,r.y+math.sin(angle)*100
    local z=ground(n,x,y,r.z_hint)
    if z then
     local mob=eq.spawn2(r.shades[(slot%2)+1],0,0,x,y,z,0)
     if mob and mob.valid then
      mob:SetEntityVariable('spirit_ritual_controller',tostring(n:GetID()));mob:SetEntityVariable('spirit_ritual_slot',tostring(slot))
      n:SetEntityVariable('spirit_slot_'..slot,tostring(mob:GetID()))
     end
    end
   end
  end
 end
 if expiry<=now and not skull_pending then eq.delete_data(key('fire'));n:Depop()end
 return true
end
return M
