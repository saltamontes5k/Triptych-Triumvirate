-- Bring Friends: finite, open-world scenes. No inventory polling, elapsed-time
-- completion, forced task completion or credit from another party's actor.
local D=require('achievement_quest_mesa_friends_scenes_data')
local M={}
local scenes,claims={},{}
local initialized=false
local sequence=0
local tag='mesa.friends.scene'
local actor_tag='mesa.friends.actor'
local function yes(v)return v==true or v==1 end
local function active(c,t,a)return yes(c:IsTaskActive(t))and(a==nil or yes(c:IsTaskActivityActive(t,a)))end
local function identity(c,t)
 if D.scenes[t].shared then
  local s=c:GetSharedTaskIdentity()
  if s==''then return end
  return tostring(t)..':shared:'..s
 end
 return tostring(t)..':solo:'..c:CharacterID()
end
local function distance(n,p)
 local x,y=n:GetX()-p.x,n:GetY()-p.y
 return x*x+y*y,math.abs(n:GetZ()-p.z)
end
local function near(n,p,r)
 local d,z=distance(n,p);return d<=r*r and z<=D.vertical_radius
end
local function members(s,activity)
 local out={}
 for c in eq.get_entity_list():GetClientList().entries do
  if c.valid and active(c,s.task,activity)and identity(c,s.task)==s.key then out[#out+1]=c end
 end
 return out
end
local function own(n,s)
 return n and n.valid and n:GetEntityVariable(tag)==s.token
end
local function cleanup(s)
 for _,a in pairs(s.actors)do
  local n=eq.get_entity_list():GetNPCByID(a.id)
  if own(n,s)and n:GetHP()>0 then n:Depop(false)end
 end
 scenes[s.key]=nil
 if claims[s.task]==s.key then claims[s.task]=nil end
end
local function fail(s,message)
 local party=members(s)
 cleanup(s)
 -- Shared task failure needs one native request, not one per member.
 local c=party[1]
 if c then c:Message(13,message);c:FailTask(s.task)end
end
local function credit(s,a)
 local c=members(s,a)[1]
 if not c then return false end
 c:UpdateTaskActivity(s.task,a,1)
 return true
end
local function npc(a,s)
 local n=eq.get_entity_list():GetNPCByID(a.id)
 if own(n,s)and n:GetNPCTypeID()==D.actors[a.role]then return n end
end
local function spawn_wave(s,index)
 local cfg=D.scenes[s.task];local wave=cfg.waves[index]
 for _,role in ipairs(wave)do
  local p=cfg.spawn
  local mob=eq.spawn2(D.actors[role],0,0,p.x,p.y,p.z,0)
  if not mob or not mob.valid then return false end
  local n=mob:CastToNPC()
  if not n or not n.valid then return false end
  local aid=#s.actors+1
  s.actors[aid]={id=n:GetID(),role=role,dead=false}
  n:SetEntityVariable(tag,s.token);n:SetEntityVariable(actor_tag,tostring(aid))
  n:SetEntityVariable('mesa.friends.native_id',tostring(n:GetID()))
  -- These are ordinary corpse drops. Period sources explicitly require
  -- non-guaranteed Orders on both Glasson and his guards.
  if cfg.kind=='orders'and math.random(100)<=D.orders_chance_percent then n:AddItem(21491,1)end
  if role=='glasson'then n:AddAISpell(1,8639,2048,-1,20,0)end -- Entrancing Song; native mez AI, reconstructed recast.
  if cfg.destination then
   -- Nongrid MoveTo(false) leaves the original guard point intact, causing an
   -- automatic home return before the scripted camp pause has elapsed.
   -- Raiders must guard the destination until this controller orders return.
   local d=cfg.destination;n:MoveTo(d.x,d.y,d.z,0,cfg.kind=='raiders')
  end
 end
 s.next_wave=index+1;s.next_due=os.time()+D.wave_delay_seconds
 return true
end
local function start(c,t)
 local key=identity(c,t);if not key or claims[t]then return end
 sequence=sequence+1
 local s={key=key,task=t,token=key..':'..os.time()..':'..sequence,actors={},started=os.time(),next_wave=1,next_due=os.time(),credited=false}
 scenes[key]=s;claims[t]=key
 if not spawn_wave(s,1)then fail(s,'The encounter could not begin. Please request the task again.');return end
 -- Actual physical arrival and successful actor creation produce exploration.
 if not credit(s,0)then cleanup(s)end
end
function M.controller_spawn(e)
 if not D.enabled or eq.get_zone_id()~=397 or e.self:GetNPCTypeID()~=10 then return false end
 scenes={};claims={}
 -- Script reload cannot convert orphaned actors into a fresh event.
 for n in eq.get_entity_list():GetNPCList().entries do
  if n.valid and n:GetEntityVariable(tag)~=''then
   for _,id in pairs(D.actors)do if n:GetNPCTypeID()==id then n:Depop(false);break end end
  end
 end
 initialized=true
 e.self:SetTimer(D.timer,D.interval)
 return true
end
local function defend(n)
 if n:IsEngaged()then return end
 local p={x=n:GetX(),y=n:GetY(),z=n:GetZ()}
 local closest,dist=nil,D.defender_reach*D.defender_reach
 for d in eq.get_entity_list():GetNPCList().entries do
  if d.valid and d:GetHP()>0 and not d:IsPet()then
   local allowed=false
   for _,id in ipairs(D.defenders)do if d:GetNPCTypeID()==id then allowed=true;break end end
   if allowed then
    local dd,z=distance(d,p)
    if dd<dist and z<=D.vertical_radius then closest,dist=d,dd end
   end
  end
 end
 if closest then
  n:AddToHateList(closest,1);closest:AddToHateList(n,1)
 end
end
local function tick_scene(s)
 local cfg=D.scenes[s.task]
 if #members(s)==0 and not(cfg.kind=='raiders'and s.credited)then cleanup(s);return end
 if os.time()-s.started>D.timeout_seconds then
  if s.credited then cleanup(s)else fail(s,'The encounter ended before its objective was completed. Please request it again.')end
  return
 end
 if s.next_wave<=#cfg.waves and os.time()>=s.next_due then
  if not spawn_wave(s,s.next_wave)then fail(s,'An encounter wave could not arrive. Please request it again.');return end
 end
 local live,dead=0,0
 for _,a in pairs(s.actors)do
  if a.dead then dead=dead+1
  elseif not a.departed then
   local n=npc(a,s)
   if not n then
    if s.credited then a.departed=true
    else fail(s,'An encounter actor disappeared. Please request the task again.');return end
   else
    live=live+1
    if cfg.kind=='tree'then
     if near(n,cfg.destination,D.tree_radius)then fail(s,'The treekillers reached the Windwillow.');return end
     defend(n)
    elseif cfg.kind=='raiders'then
     if n:IsEngaged()then
      a.arrived=nil
     elseif not a.returning and near(n,cfg.destination,25)then
      a.arrived=a.arrived or os.time()
      if os.time()-a.arrived>=D.camp_pause_seconds then
       a.returning=true;local p=cfg.spawn;n:MoveTo(p.x,p.y,p.z,0,true)
      end
     elseif not a.returning then
      -- Count a continuous camp stay, not time spent fighting or outside it.
      a.arrived=nil
     elseif a.returning and near(n,cfg.spawn,25)then
      a.departed=true;n:Depop(false)
      if a.role=='captain'and not s.credited then fail(s,'The raider captain escaped. Please request the task again.');return end
     end
    end
   end
  end
 end
 if cfg.kind=='tree'and s.next_wave>#cfg.waves and dead==9 then
  -- Any genuine actor death counts, including an original friendly NPC's
  -- kill. A timer alone never awards the protection objective.
  if credit(s,1)then cleanup(s)else fail(s,'The defense no longer has an active participant.')end
 elseif s.credited and live==0 and s.next_wave>#cfg.waves then cleanup(s)end
end
function M.controller_timer(e)
 if e.timer~=D.timer then return false end
 if not D.enabled or eq.get_zone_id()~=397 or e.self:GetNPCTypeID()~=10 then return true end
 -- A local quest reload reconstructs Lua state without firing NPC EVENT_SPAWN.
 -- The existing controller timer must run the same namespace-owned orphan
 -- cleanup once before accepting another scene, rather than leaking old waves.
 if not initialized then M.controller_spawn(e)end
 -- One controller tick owns each scene; one timer per party member would
 -- duplicate waves and race shared-task activity updates.
 local pending={};for _,s in pairs(scenes)do pending[#pending+1]=s end
 for _,s in ipairs(pending)do if scenes[s.key]==s then tick_scene(s)end end
 for c in eq.get_entity_list():GetClientList().entries do
  if c.valid and c:GetHP()>0 then
   for t,cfg in pairs(D.scenes)do
    if active(c,t,0)and near(c,cfg.trigger,D.trigger_radius)then start(c,t)
    elseif active(c,t,1)then
     local key=identity(c,t)
     if key and not scenes[key]then
      c:Message(13,'The interrupted encounter must be requested again.');c:FailTask(t)
     end
    end
   end
  end
 end
 return true
end
local function actor_scene(n)
 if not n or not n.valid then return end
 local token=n:GetEntityVariable(tag)
 for _,s in pairs(scenes)do
  if token==s.token then
   local index=tonumber(n:GetEntityVariable(actor_tag));local a=index and s.actors[index]
   local native_id=tonumber(n:GetEntityVariable('mesa.friends.native_id'))
   if a and a.id==native_id and n:GetNPCTypeID()==D.actors[a.role]then return s,a end
  end
 end
end
function M.merit(e)
 local s,a=actor_scene(e.self);local c=e.other
 if not s or not c or not c.valid or not c:IsClient()then return end
 c=c:CastToClient()
 if active(c,s.task,1)and identity(c,s.task)==s.key then a.merit=true end
end
function M.death_complete(e)
 local s,a=actor_scene(e.self)
 if not s or a.dead or(e.killed_entity_id and e.killed_entity_id~=a.id)then return end
 a.dead=true
 local kind=D.scenes[s.task].kind
 if(kind=='orders'and a.role=='glasson')or(kind=='raiders'and a.role=='captain')then
  if not a.merit then fail(s,'Your party did not receive credit for the encounter target.');return end
  if not credit(s,1)then fail(s,'The encounter no longer has an active participant.');return end
  s.credited=true
  -- Do not erase the remaining raiders simply because the captain died.
  -- Their normal combat, camp pause and return path continue.
 end
end
return M
