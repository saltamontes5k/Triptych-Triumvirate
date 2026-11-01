-- Capture/rescue state machine. Original cage/teleport/spell identities remain
-- unverified in data: this scene cannot start until those settings are reviewed.
local D=require('achievement_quest_mesa_data').capture
local R=require('achievement_quest_mesa_resources')
local M={};local task,activity=3040411,2
local timer='achievement_mesa_captivity';local actor_timer='achievement_mesa_capture_actor'
local prefix='achievement.may2013.mesa.capture.'
local function key(k)return prefix..k end
local function yes(v)return v==true or v==1 end
local function active(c)return yes(c:IsTaskActive(task))and yes(c:IsTaskActivityActive(task,activity))end
local function get(c,k)return c:GetBucket(key(k))end
local function set(c,k,v)c:SetBucket(key(k),tostring(v))end
local function point(p)
 return type(p)=='table'and type(p.x)=='number'and type(p.y)=='number'and type(p.z)=='number'
end
local function configured()
 return D.verified==true and type(D.model)=='string'and D.model~=''
  and type(D.cage_npc)=='number'and D.cage_npc>0 and type(D.scout_npc)=='number'and D.scout_npc>0 and D.cage_npc~=D.scout_npc
  and type(D.blind_spell)=='number'and D.blind_spell>0
  and point(D.location)and point(D.scout_start)and point(D.scout_end)
  and type(D.radius)=='number'and D.radius>0 and type(D.vertical)=='number'and D.vertical>0
  and D.blind_seconds>0 and D.rescue_seconds>D.blind_seconds
  and type(D.scout_travel_seconds)=='number'and D.scout_travel_seconds>0
  and D.scout_travel_seconds<D.rescue_seconds
  and type(D.arrival_timeout_seconds)=='number'and D.arrival_timeout_seconds>0
end
local function near(c,p,r,v)
 local dx,dy=c:GetX()-p.x,c:GetY()-p.y
 return dx*dx+dy*dy<=r*r and math.abs(c:GetZ()-p.z)<=v
end
local function own(n,c,token,role)
 return n and n.valid and n:GetEntityVariable('mesa_capture_owner')==tostring(c:CharacterID())
  and n:GetEntityVariable('mesa_capture_token')==token
  and n:GetEntityVariable('mesa_capture_role')==role
  and n:GetNPCTypeID()==(role=='cage'and D.cage_npc or D.scout_npc)
end
local function actors(c,fn)
 for n in eq.get_entity_list():GetNPCList().entries do
  if n.valid and n:GetEntityVariable('mesa_capture_owner')==tostring(c:CharacterID())
   and(n:GetNPCTypeID()==D.cage_npc or n:GetNPCTypeID()==D.scout_npc)then fn(n)end
 end
end
local function unblind(c)
 local spell=tonumber(get(c,'blind_owned'))
 if spell and spell>0 then c:BuffFadeBySpellID(spell);set(c,'blind_owned','')end
end
function M.release(c)
 c:StopTimer(timer)
 if get(c,'state')==''and get(c,'blind_owned')==''then return end
 unblind(c);actors(c,function(n)n:Depop(false)end)
 for _,k in ipairs{'state','token','started','cage','scout','blind_until','instance','arrival_deadline'}do set(c,k,'')end
 -- betrayal.applied belongs to the accepted task, never to a login or a cage.
end
local function spawn(c,token,role,p)
 local id=role=='cage'and D.cage_npc or D.scout_npc
 local n=eq.spawn2(id,0,0,p.x,p.y,p.z,p.heading or 0)
 if not n or not n.valid then return end
 n:SetEntityVariable('mesa_capture_owner',tostring(c:CharacterID()))
 n:SetEntityVariable('mesa_capture_token',token);n:SetEntityVariable('mesa_capture_role',role)
 n:SetTimer(actor_timer,1);return n
end
function M.capture(c)
 if eq.get_zone_id()~=397 or not active(c)or c:IsDead()then return false end
 if not configured()then c:Message(13,'The Mesa capture scene is awaiting original asset verification.');return false end
 -- The period scene has a shared cage, not overlapping copies of a prison.
 for n in eq.get_entity_list():GetNPCList().entries do
  if n.valid and n:GetNPCTypeID()==D.cage_npc and n:GetEntityVariable('mesa_capture_role')=='cage'
   and n:GetEntityVariable('mesa_capture_owner')~=tostring(c:CharacterID())then
   c:Message(13,'Another prisoner is being held. Try speaking with Devan again shortly.');return false
  end
 end
 M.release(c)
 local sequence=(tonumber(c:GetBucket('achievement.may2013.mesa.capture_sequence'))or 0)+1
 c:SetBucket('achievement.may2013.mesa.capture_sequence',tostring(sequence))
 local token=tostring(c:CharacterID())..':'..tostring(sequence)
 local cage=spawn(c,token,'cage',D.location);if not cage then return false end
 set(c,'token',token);set(c,'cage',cage:GetID());set(c,'state','arriving')
 set(c,'instance',eq.get_zone_instance_id())
 set(c,'arrival_deadline',os.time()+D.arrival_timeout_seconds)
 local p=D.location;c:MovePCInstance(397,eq.get_zone_instance_id(),p.x,p.y,p.z,p.heading or 0)
 c:SetTimer(timer,1);return true
end
local function betrayal(c)
 if c:GetBucket('achievement.may2013.mesa.betrayal.applied')=='1'then return end
 -- Separate idempotence markers avoid replaying the first faction if a later
 -- callback resumes after the second faction operation failed.
 for _,f in ipairs{1107,1108}do
  local k='achievement.may2013.mesa.betrayal.'..f
  if c:GetBucket(k)~='1'then
   c:SetFactionLevel2(c:CharacterID(),f,c:GetClass(),c:GetBaseRace(),c:GetDeity(),-2000,0)
   c:SetBucket(k,'1')
  end
 end
 c:SetBucket('achievement.may2013.mesa.betrayal.applied','1')
end
function M.resume(c)
 if get(c,'state')==''then return end
 if not configured()or eq.get_zone_id()~=397 or c:IsDead()or not active(c)
  or tonumber(get(c,'instance'))~=eq.get_zone_instance_id()
  or(not near(c,D.location,D.radius,D.vertical)
   and not(get(c,'state')=='arriving'and os.time()<(tonumber(get(c,'arrival_deadline'))or 0)))then M.release(c);return end
 -- Rebuild missing actors after a zone shutdown/login. A real new scout must
 -- arrive; an elapsed offline deadline alone never completes the objective.
 local cage=eq.get_entity_list():GetNPCByID(tonumber(get(c,'cage'))or 0)
 if not own(cage,c,get(c,'token'),'cage')then
  M.release(c);M.capture(c);return
 end
 c:SetTimer(timer,1)
end
function M.client_timer(e)
 if e.timer~=timer then return false end
 local c=e.self
 if not configured()or eq.get_zone_id()~=397 or c:IsDead()or not active(c)
  or tonumber(get(c,'instance'))~=eq.get_zone_instance_id()then M.release(c);return true end
 local token=get(c,'token');local entities=eq.get_entity_list()
 local cage=entities:GetNPCByID(tonumber(get(c,'cage'))or 0)
 if not own(cage,c,token,'cage')then M.release(c);return true end
 local now=os.time();local state=get(c,'state')
 if state=='arriving'then
  -- Same-zone relocation can reach the client after a timer callback. Do not
  -- apply faction or blindness at the old position, or destroy the cage early.
  if not near(c,D.location,D.radius,D.vertical)then
   if now>=(tonumber(get(c,'arrival_deadline'))or 0)then M.release(c)end
   return true
  end
  set(c,'arrival_deadline','')
  betrayal(c);set(c,'started',now);set(c,'blind_until',now+D.blind_seconds);set(c,'state','waiting')
  -- Two-argument binding only: the three-argument native Lua overload drops
  -- duration. Native duration is ticks; timer ends only this scene-owned buff.
  if not c:FindBuff(D.blind_spell)then
   c:ApplySpellBuff(D.blind_spell,math.ceil(D.blind_seconds/6)+1)
   if c:FindBuff(D.blind_spell)then set(c,'blind_owned',D.blind_spell)end
  end
 elseif not near(c,D.location,D.radius,D.vertical)then M.release(c);return true end
 if now>=(tonumber(get(c,'blind_until'))or 0)then unblind(c)end
 local elapsed=now-(tonumber(get(c,'started'))or now)
 if elapsed<D.rescue_seconds-D.scout_travel_seconds then return true end
 local scout=entities:GetNPCByID(tonumber(get(c,'scout'))or 0)
 if not own(scout,c,token,'scout')then
  scout=spawn(c,token,'scout',D.scout_start);if not scout then return true end
  set(c,'scout',scout:GetID());local p=D.scout_end;scout:MoveTo(p.x,p.y,p.z,p.heading or 0,true)
 end
 if elapsed>=D.rescue_seconds and near(scout,D.scout_end,D.arrival_radius or 5,D.vertical)
  and not scout:IsEngaged()then
  scout:Say('You have been betrayed. I will free you; make your way to Scout Madu.')
  -- Owner, current task, current instance, cage, scout arrival, elapsed time and
  -- living captive are all verified before the one custom rescue update.
  c:UpdateTaskActivity(task,activity,1);M.release(c)
 end
 return true
end
function M.npc_timer(e)
 if e.timer~=actor_timer then return R.timer(e)end
 local n=e.self;local role=n:GetEntityVariable('mesa_capture_role')
 if(role~='cage'and role~='scout')or n:GetNPCTypeID()~=(role=='cage'and D.cage_npc or D.scout_npc)then return false end
 local c=eq.get_entity_list():GetClientByCharID(tonumber(n:GetEntityVariable('mesa_capture_owner'))or 0)
 if not c or not c.valid or c:IsDead()or not active(c)
  or get(c,'token')~=n:GetEntityVariable('mesa_capture_token')then n:Depop(false)end
 return true
end
function M.click_door(e)return R.click_door(e)end
function M.click_object(e)return R.click_object(e)end
return M
