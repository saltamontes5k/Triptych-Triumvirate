-- Native guardian custody for Unearthed Power. Exact profiles, positions and
-- replacement delay require review; this module selects no fallback values.
-- Guardians never award synthetic task, loot, completion or reward credit.
local M={}
local KEY='vergalid.orb.guardian.key'
local SLOT='vergalid.orb.guardian.slot'
local GEN='vergalid.orb.guardian.generation'
local function valid(n)return n and n.valid end
local function integer(n)return type(n)=='number'and n==math.floor(n)and n>0 end
function M.validate(r)
 local g=r.guardians
 assert(g and g.reviewed==true and type(g.slots)=='table'and #g.slots==2,'Orb guardian profiles/positions require explicit review')
 assert(integer(g.replacement_seconds),'Orb guardian replacement delay requires an explicit positive integral value')
 local ids,roles={},{}
 for _,v in ipairs(g.slots)do
  assert(integer(v.npc)and v.npc~=r.npc and not ids[v.npc],'Guardian types must be distinct dedicated reviewed NPC types')
  assert((v.role=='cleric'or v.role=='warrior')and not roles[v.role],'Orb requires one cleric and one warrior')
  assert(type(v.point)=='table','Missing reviewed guardian position')
  for _,a in ipairs({'x','y','z'})do local n=v.point[a];assert(type(n)=='number'and n==n and math.abs(n)<100000,'Invalid guardian coordinate')end
  ids[v.npc]=true;roles[v.role]=true
 end
 return g
end
local function find(s,index,generation,npc)
 local found
 for n in eq.get_entity_list():GetNPCList().entries do
  if n:GetEntityVariable(KEY)==s.key and tonumber(n:GetEntityVariable(SLOT))==index and tonumber(n:GetEntityVariable(GEN))==generation then
   assert(n:GetNPCTypeID()==npc and tonumber(n:GetEntityVariable(GEN))==generation,'Conflicting guardian lease identity')
   assert(not found,'Duplicate native guardian lease');found=n
  end
 end
 return found
end
local function verify(n,v)
 assert(n:GetNPCTypeID()==v.npc and n:GetLevel()==74 and n:GetRace()==522,'Guardian must match reviewed native level74 drakkin profile')
 assert(n:GetClass()==(v.role=='cleric'and 2 or 1),'Guardian role/class mismatch')
end
function M.sync(s,r,persist,target)
 if r.family~='orb'or s.phase~='combat'or s.instance~=eq.get_zone_instance_id()then return end
 local g=M.validate(r);s.guardians=s.guardians or{}
 local now=os.time()
 for i,v in ipairs(g.slots)do
  local slot=s.guardians[i]
  if not slot then slot={generation=1,phase='ready'};s.guardians[i]=slot;persist(s)end
  local n=find(s,i,slot.generation,v.npc)
  if valid(n)then
   verify(n,v)
   if slot.actor~=n:GetID()or slot.phase~='alive'then slot.actor=n:GetID();slot.phase='alive';persist(s)end
  elseif slot.phase=='ready'or(slot.phase=='dead'and slot.due and now>=slot.due)then
   -- Refuse an unowned copy rather than adopt, depop or duplicate it after
   -- an interrupted spawn. These dedicated types are reserved for this scene.
   local occupied=false
   for other in eq.get_entity_list():GetNPCList().entries do if other:GetNPCTypeID()==v.npc and other:GetEntityVariable(KEY)==''then occupied=true end end
   if not occupied then
    if slot.phase=='dead'then slot.generation=slot.generation+1 end
    slot.phase='spawning';slot.due=nil;persist(s)
    local p=v.point;n=eq.spawn2(v.npc,0,0,p.x,p.y,p.z,p.heading or 0)
    if valid(n)then
     verify(n,v)
     n:SetEntityVariable(KEY,s.key);n:SetEntityVariable(SLOT,tostring(i));n:SetEntityVariable(GEN,tostring(slot.generation))
     slot.actor=n:GetID();slot.phase='alive';persist(s)
     -- Only a freshly created guard acquires the authenticated scene member.
     -- Stable timers must not break crowd control or re-add hate continually.
     if valid(target)then n:AddToHateList(target,1)end
    else slot.phase='ready';persist(s)end
   end
  end
  -- Missing saved/spawning entities wait for their genuine lease; a stale
  -- ID is not a death observation and cannot start another replacement.
 end
end
function M.restore(n,s,r,persist)
 if not s or r.family~='orb'or s.instance~=eq.get_zone_instance_id()or n:GetEntityVariable(KEY)~=s.key then return false end
 local g=M.validate(r);local i=tonumber(n:GetEntityVariable(SLOT));local v=i and g.slots[i];local slot=i and s.guardians and s.guardians[i]
 if not v or not slot or slot.phase~='alive'or tonumber(n:GetEntityVariable(GEN))~=slot.generation then return false end
 verify(n,v)
 local found=find(s,i,slot.generation,v.npc)
 assert(not found or found:GetID()==n:GetID(),'Conflicting restored guardian lease')
 if slot.actor~=n:GetID()then slot.actor=n:GetID();persist(s)end
 return true
end
function M.death(n,s,r,persist,dead_id)
 if type(dead_id)~='number'or dead_id<=0 or dead_id~=math.floor(dead_id)then return false end
 local k=n:GetEntityVariable(KEY)
 if k==''then return false end
 if not s or k~=s.key or s.instance~=eq.get_zone_instance_id()or r.family~='orb'then return true end
 local g=M.validate(r);local i=tonumber(n:GetEntityVariable(SLOT));local v=i and g.slots[i];local slot=i and s.guardians and s.guardians[i]
 if not v or not slot or tonumber(n:GetEntityVariable(GEN))~=slot.generation then return true end
 verify(n,v)
 if slot.phase=='alive'and slot.actor==dead_id then
  slot.phase='dead';slot.due=os.time()+g.replacement_seconds;persist(s)
 end
 return true
end
function M.engaged(s,r)
 local g=M.validate(r)
 for i,v in ipairs(g.slots)do
  local slot=s.guardians and s.guardians[i]
  local n=slot and find(s,i,slot.generation,v.npc)
  if valid(n)and n:IsEngaged()then return true end
 end
 return false
end
function M.key(n)return n:GetEntityVariable(KEY)end
return M
