-- Pure scene transitions. Native adapters must supply actual spatial/custody
-- observations, persist the returned state, and verify each action result.
-- Ordinary NPC death/loot/delivery credit remains entirely in the task core.
local M={}
local function copy(s)local r={};for k,v in pairs(s)do r[k]=v end;return r end
function M.begin(family,owner,epoch)
 assert(family=='bile'or family=='vergalak'or family=='orb','Unknown Vergalid scene')
 assert(owner>0 and epoch>0,'Scene requires native owner and acceptance epoch')
 return {family=family,owner=owner,epoch=epoch,phase='ready',actor=0}
end
function M.step(state,e)
 local s=copy(state);local actions={}
 -- Replay, stale entity IDs and observations from another native task owner
 -- never advance a shared scene or provide another character's supplies.
 if e.owner~=s.owner or e.epoch~=s.epoch or e.zone~=404 then return s,actions end
 if e.kind=='plant'and s.phase=='ready'and e.stage_active and e.at_site and
    (s.family=='orb'or(e.cursor_matches and e.custody_confirmed))then
  s.phase='spawning';actions[#actions+1]={kind='spawn_actor',family=s.family}
 elseif e.kind=='spawn_result'and s.phase=='spawning'then
  if e.actor_id and e.actor_id>0 and e.identity_confirmed then
   s.actor=e.actor_id
   if s.family=='bile'then
    s.phase='approaching';actions={{kind='protect_actor'},{kind='advance_scene',activity=0},{kind='move_actor_to_bait'}}
   elseif s.family=='vergalak'then
    s.phase='combat';actions={{kind='advance_scene',activity=2}}
   else s.phase='combat' end
  else s.phase='ready';s.actor=0 end
 elseif e.kind=='observe'and s.family=='bile'and e.actor_id==s.actor and e.actor_alive then
  if s.phase=='approaching'and e.actor_at_bait and e.owner_at_safety and e.stage_active then
   s.phase='waiting_for_return';actions={{kind='advance_scene',activity=1}}
  elseif s.phase=='waiting_for_return'and e.owner_at_bait and e.stage_active then
   s.phase='combat';actions={{kind='advance_scene',activity=2},{kind='unprotect_actor'},{kind='move_actor_to_retreat'}}
  end
 elseif e.kind=='actor_missing'and e.actor_id==s.actor and s.actor>0 then
  -- A saved-zone resume may restore the same lease-tagged actor. Never issue
  -- quest credit or spawn an unbounded replacement from a stale pointer.
  s.restore_phase=s.phase;s.phase='needs_reconciliation';actions={{kind='reconcile_actor_lease'}}
 end
 return s,actions
end
return M
