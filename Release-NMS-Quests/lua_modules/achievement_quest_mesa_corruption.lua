-- Source candidate: original spawn identities and native respawn/grid ownership.
-- Disabled configuration prevents all effects until reviewed deployment.
local D=require('achievement_quest_mesa_corruption_data')
local M={}
local last=nil
local pending={}
local failed=false
local function enabled()return D.enabled and eq.get_zone_id()==D.zone end
local function actors()return eq.get_entity_list():GetNPCList().entries end
local function scoped(n)
 return n.valid and D.actors[n:GetSpawnPointID()]==n:GetNPCTypeID()and not n:IsPet()
end
local function shade()
 for n in actors()do
  if n.valid and n:GetNPCTypeID()==D.shade_type and n:GetSpawnPointID()==D.shade_spawn and n:GetHP()>0 and not n:IsPet()then return n end
 end
 return nil
end
local function faction(n,corrupted)
 n:SetNPCFactionID(corrupted and D.hostile_group or D.friendly_group)
 if D.aggro_range>0 then n:ModifyNPCStat('aggro',tostring(D.aggro_range))end
end
function M.actor_spawn(e)
 if not enabled()or not scoped(e.self)then return false end
 faction(e.self,shade()~=nil)
 return true
end
function M.shade_spawn(e)
 if not enabled()then return false end
 local n=e.self
 if not n.valid or n:GetSpawnPointID()~=D.shade_spawn or n:GetNPCTypeID()~=D.shade_type or n:IsPet()then return false end
 if n:GetEntityVariable('mesa.corruption.prepared')=='1'then return true end
 n:SetSeeInvisibleLevel(1) -- Period Dec2007 report: Shade sees ordinary invisibility.
 n:SetSeeInvisibleLevel(1) -- Period Dec2007: sees ordinary invisibility.
 n:SetSpecialAbility(16,1) -- Native SnareImmunity handles root AND movement speed.
 n:SetSpecialAbility(1,1) -- Summoning; core97%/6sec defaults explicitly unrecovered.
 n:SetNPCFactionID(D.hostile_group)
 if D.aggro_range>0 then n:ModifyNPCStat('aggro',tostring(D.aggro_range))end
 for _,spell in ipairs(D.spells)do
  n:AddAISpell(1,spell.id,spell.kind,-1,D.ai_recast_seconds,0)
 end
 if D.aura_radius>0 then n:SetTimer(D.aura_timer,D.aura_tick_seconds)end
 n:SetEntityVariable('mesa.corruption.prepared','1')
 return true
end
function M.shade_timer(e)
 if e.timer~=D.aura_timer then return false end
 local n=e.self
 if not enabled()or D.aura_radius<=0 or not n.valid or n:GetHP()<=0 or n:GetNPCTypeID()~=D.shade_type or n:GetSpawnPointID()~=D.shade_spawn then
  if n.valid then n:StopTimer(D.aura_timer)end
  return true
 end
 -- Use the native spell/resist/invisibility path. Never directly strip buffs.
 -- The200unit radius is a labelled reconstruction using the native spell
 -- range; original environmental aura extent remains unverified.
 local radius2=D.aura_radius*D.aura_radius
 for c in eq.get_entity_list():GetClientList().entries do
  if c.valid and c:GetHP()>0 then
   local x,y,z=c:GetX()-n:GetX(),c:GetY()-n:GetY(),c:GetZ()-n:GetZ()
   if x*x+y*y+z*z<=radius2 then n:SpellFinished(9147,c)end
  end
 end
 return true
end
function M.controller_spawn(e)
 if not enabled()or e.self:GetNPCTypeID()~=10 then return false end
 last=nil;pending={};failed=false -- New native controller lifetime starts clean.
 e.self:SetTimer(D.controller_timer,D.controller_interval)
 return true
end
function M.controller_timer(e)
 if e.timer~=D.controller_timer or e.self:GetNPCTypeID()~=10 then return false end
 if not enabled()or failed then e.self:StopTimer(D.controller_timer);return true end
 local current=shade()
 local corrupted=current~=nil
 if current then M.shade_spawn{self=current}end
 if last==nil then
  -- Initial load normalizes actors without resetting any existing combat/health.
  for n in actors()do if scoped(n)then faction(n,corrupted)end end
  last=corrupted
  return true
 end
 if last~=corrupted then
  -- Period reports describe a depop/replacement, not merely wiping faction/hate.
  -- Only currently living actors are replaced. Already dead/absent spawn points
  -- retain their native respawn timers and cannot be resurrected by this event.
  for n in actors()do
   if scoped(n)and n:GetHP()>0 then
    local id=n:GetSpawnPointID()
    pending[id]={npc_type=n:GetNPCTypeID(),waited=0}
    n:Depop(false)
   end
  end
  last=corrupted
  return true -- Wait at least one native entity processing cycle before respawn.
 end
 local occupied={}
 for n in actors()do
  if n.valid then occupied[n:GetSpawnPointID()]=true end
 end
 for id,record in pairs(pending)do
  if occupied[id]then
   record.waited=record.waited+1
   if record.waited>=D.replacement_wait_ticks then
    failed=true;e.self:StopTimer(D.controller_timer)
    eq.debug('Mesa corruption old actor did not leave spawn '..id..'; controller stopped; operator review required.')
    return true
   end
  else
   -- This preserves the original native spawn location, grid and spawn group.
   local replacement=eq.spawn_from_spawn2(id)
   if not replacement.valid or replacement:GetNPCTypeID()~=record.npc_type then
    failed=true;e.self:StopTimer(D.controller_timer)
    eq.debug('Mesa corruption replacement failed for original spawn '..id..'; controller stopped; operator review required.')
    return true -- Do not silently retry or duplicate an uncertain spawn.
   end
   pending[id]=nil
  end
 end
 return true
end
return M
