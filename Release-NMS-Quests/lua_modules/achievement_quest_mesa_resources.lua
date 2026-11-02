-- Period quest interactions with original, identity-checked world resources.
-- Configurable reconstructed distances and unresolved routes are labelled in data.
local D=require('achievement_quest_mesa_data').resources
local I=require('achievement_quest_mesa_inventory')
local M={};local doors_until={};local cycle_index={}
local function yes(v)return v==true or v==1 end
local function active(c,t,a)return yes(c:IsTaskActive(t))and yes(c:IsTaskActivityActive(t,a))end
local function near(c,p,r,v)
 local dx,dy=c:GetX()-p.x,c:GetY()-p.y
 return dx*dx+dy*dy<=r*r and math.abs(c:GetZ()-p.z)<=v
end
local function resource(n)
 if not n or not n.valid then return end
 local p=D.npcs[n:GetSpawnPointID()]
 if p and p.zone==eq.get_zone_id()and p.npc==n:GetNPCTypeID()
  and near(n,p,1,2)then return p end
end
local function client(c)return c and c.valid and c:IsClient()end
local function credit(c,t,a,n)
 if not active(c,t,a)then return false end
 c:UpdateTaskActivity(t,a,n or 1);return true
end
function M.spawn(e)
 local n=e.self;local p=resource(n);if not p then return end
 local radius=p.radius or D.radius
 eq.set_proximity(p.x-radius,p.x+radius,p.y-radius,p.y+radius,p.z-D.vertical,p.z+D.vertical)
end
local function collect(e)
 local c=e.other;local n=e.self;local p=resource(n)
 if not p or not client(c)or not near(c,p,p.radius or D.radius,D.vertical)then return end
 local key='mesa_resource_enter_'..c:CharacterID();local now=os.time()
 if tonumber(n:GetEntityVariable(key))==now then return end
 if p.kind=='rocks'then
  -- All original gnoll mine piles qualify, including the other two mine camps.
  if active(c,3040406,0)then credit(c,3040406,0)end
  if active(c,3040406,1)and I.give(c,87212)then
   n:SetEntityVariable(key,tostring(now));credit(c,3040406,1)
  end
 elseif p.kind=='food'then
  if n:GetEntityVariable('mesa_food_replaced')=='1'then return end
  if active(c,3040404,1)and I.give(c,p.item)then
   n:SetEntityVariable(key,tostring(now));credit(c,3040404,1)
  end
  if active(c,3040406,3)and I.take_one(c,87212)then
   -- Appearance follows consumption, never a successful-looking failed handoff.
   n:SetEntityVariable('mesa_food_original_race',tostring(n:GetRace()))
   n:SetEntityVariable('mesa_food_replaced','1');n:SetRace(428)
   n:SetTimer('achievement_mesa_food_restore',p.respawn_seconds)
   n:SetEntityVariable(key,tostring(now));credit(c,3040406,3)
  end
 end
end
-- ProcessMove emits EVENT_ENTER before installing the packet coordinates on
-- Client. Defer to a bounded NPC timer, then revalidate the actual client state.
local enter_timer='achievement_mesa_resource_enter_'
function M.enter(e)
 local c=e.other;local n=e.self
 if not resource(n)or not client(c)then return end
 n:SetTimer(enter_timer..c:CharacterID(),1)
end
function M.timer(e)
 if e.timer:sub(1,#enter_timer)==enter_timer then
  local n=e.self;n:StopTimer(e.timer)
  local id=tonumber(e.timer:sub(#enter_timer+1))
  if not id or id<=0 or not resource(n)then return true end
  local c=eq.get_entity_list():GetClientByCharID(id)
  if client(c)then collect({self=n,other=c})end
  return true
 end
 if e.timer~='achievement_mesa_food_restore'then return false end
 local n=e.self;local p=resource(n);if not p or p.kind~='food'then return false end
 n:StopTimer(e.timer)
 if n:GetEntityVariable('mesa_food_replaced')=='1'then
  local race=tonumber(n:GetEntityVariable('mesa_food_original_race'))
  if race then n:SetRace(race)end
  n:SetEntityVariable('mesa_food_replaced','');n:SetEntityVariable('mesa_food_original_race','')
 end
 return true
end
function M.killed_merit(e)
 -- The engine dispatches this to each actual eligible kill participant. It
 -- handles pet ownership/group eligibility; no GM counters or synthetic kills.
 local c=e.other;local n=e.self
 if eq.get_zone_id()~=397 or not n.valid or n:GetNPCTypeID()~=D.weapon_rack
  or not client(c)or not active(c,3040405,1)then return end
 local count=tonumber(n:GetEntityVariable('mesa_weapon_count'))
 if not count then count=math.random(1,3);n:SetEntityVariable('mesa_weapon_count',tostring(count))end
 local key='mesa_weapon_credit_'..c:CharacterID()
 if n:GetEntityVariable(key)=='1'then return end
 n:SetEntityVariable(key,'1');credit(c,3040405,1,count)
end
local function watched(c)
 if c:IsInvisible()then return true end
 for n in eq.get_entity_list():GetNPCList().entries do
  if n.valid and n:GetPrimaryFaction()==D.watcher_faction
   and near(n,{x=c:GetX(),y=c:GetY(),z=c:GetZ()},D.watcher_radius,D.vertical)
   and n:CheckLoS(c)then return true end
 end
 return false
end
local function cycle_ready(kind)
 local p=D.cycles[kind]
 if not p or #p<2 then return end
 for _,v in ipairs(p)do if not v.reviewed then return end end
 return p
end
local function ground(c,p)
 -- Native third argument is a Z OFFSET from the calling mob, not world Z.
 local z=c:FindGroundZ(p.x,p.y,p.z+10-c:GetZ())
 if type(z)~='number'or z~=z or math.abs(z-p.z)>32 then return end
 return z
end
local function relocate(c,door,p,kind)
 local route=cycle_ready(kind);if not route then return false end
 local index=(cycle_index[door:GetDoorID()]or 1)%#route+1
 local target=route[index];local base=ground(c,p);local nextground=ground(c,target)
 if not base or not nextground then return false end
 -- Preserve the collected mesh origin's offset above its original terrain.
 local z=nextground+(p.z-base)
 if math.abs(z-target.z)>32 then return false end
 door:SetLocation(target.x,target.y,z);cycle_index[door:GetDoorID()]=index
 return true
end
local function provoke(c,kind)
 local ids={};for _,id in ipairs(D.provokers[kind]or{})do ids[id]=true end
 for n in eq.get_entity_list():GetNPCList().entries do
  if n.valid and ids[n:GetNPCTypeID()]and n:GetOwnerID()==0
   and near(n,{x=c:GetX(),y=c:GetY(),z=c:GetZ()},D.reaction_radius,D.vertical)
   and n:CheckLoS(c)then n:Attack(c)end
 end
end
-- Original beer source is a persistent crafting-barrel Object. RoF2 does
-- not instantiate the duplicate OBJ_STILL_BARREL database door as a switch.
function M.click_object(e)
 local c=e.self;local o=e.object;local p=D.beer_object
 if eq.get_zone_id()~=397 or not client(c)or not o or not o.valid or not p
  or o:GetDBID()~=p.db_id or o:GetModelName():upper()~=p.model or o:GetType()~=p.type
  or not near(o,p,1,D.vertical)then return 0 end
 local pos={x=o:GetX(),y=o:GetY(),z=o:GetZ()}
 if not near(c,pos,D.reach,D.vertical)then return 0 end
 local now=os.time();if now<(doors_until[19]or 0)then return 1 end
 if I.give(c,21792)then credit(c,3040407,2);doors_until[19]=now+D.doors[19].cooldown_seconds end
 -- The engine runs the original crafting-container click first. Keep it intact.
 return 1
end
function M.click_door(e)
 local c=e.self;local door=e.door
 if eq.get_zone_id()~=397 or not client(c)or not door or not door.valid then return 0 end
 local id=door:GetDoorID();local p=D.doors[id]
 if not p or door:GetDoorDBID()~=p.db_id or door:GetDoorName():upper()~=p.model then return 0 end
 local pos={x=door:GetX(),y=door:GetY(),z=door:GetZ()}
 if not near(c,pos,D.reach,D.vertical)then c:Message(13,'Move closer to the object.');return 1 end
 local now=os.time();if now<(doors_until[id]or 0)then return 1 end
 local changed=false
 if p.kind=='fruit'or p.kind=='vegetables'then
  local a=p.kind=='fruit'and 0 or 1
  local supply_item=p.kind=='fruit'and 21790 or 21791
  -- Supplies are edible original items. A consumed/lost item must not strand a
  -- pending delivery, but reacquisition never repeats collection credit.
  local supply=active(c,3040407,a)or(active(c,3040407,a+3)and I.count(c,supply_item)==0)
  if (supply or(p.kind=='fruit'and active(c,3040401,1)))then
   if watched(c)then c:Message(13,'You cannot steal from the sacks while invisible or being watched.');return 1 end
   if supply and I.give(c,supply_item)then changed=true;credit(c,3040407,a)end
   if p.kind=='fruit'and active(c,3040401,1)then changed=credit(c,3040401,1)or changed end
  end
 elseif p.kind=='beer'then
  -- Period reports allow taking beer without the task; no free task credit.
  if I.give(c,21792)then changed=true;credit(c,3040407,2)end
 elseif p.kind=='bush'or p.kind=='stone'then
  local t,a,equip=3040412,1,88132
  if p.kind=='stone'then t,a,equip=3040414,0,88135 end
  if active(c,t,a)and c:GetItemIDAt(Slot.Primary)==equip then
   if c:IsInvisible()then c:Message(13,'You cannot do that while invisible.');return 1 end
   if not relocate(c,door,p,p.kind)then return 1 end
   changed=credit(c,t,a)
   if changed then
    c:Message(15,p.kind=='bush'and'The plant burns quickly and turns to ash.'or'The stone breaks into smaller pieces.')
    provoke(c,p.kind)
   end
  end
 end
 if changed then
  doors_until[id]=now+p.cooldown_seconds
  if p.kind~='bush'and p.kind~='stone'then door:ForceOpen(c,true)end
 end
 return 1
end
return M
