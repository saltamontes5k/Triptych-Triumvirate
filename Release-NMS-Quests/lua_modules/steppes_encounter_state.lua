-- Steppes scene transitions; native adapter authenticates all gameplay events.
-- Every input must come from the audited native adapter described in ADAPTER.md.
-- Effects run under a persisted executing marker; interrupted effects fail closed on reconciliation.
local M = {}
local function copy(t)
  if type(t) ~= 'table' then return t end
  local r = {}; for k,v in pairs(t) do r[k] = copy(v) end; return r
end
local function effect(s, out, kind, data)
  s.sequence = s.sequence + 1
  data = data or {}; data.kind = kind; data.id = s.key .. ':' .. s.sequence
  data.owner = s.key; out[#out+1] = data
end
local function objective(s,out,name,n)
  effect(s,out,'objective',{objective=name,count=n or 1})
end
local function spawn(s,out,role,n)
  for i=1,n do
    local token=s.key .. ':' .. role .. ':' .. tostring(i)
    assert(not s.actors[token], 'role reused within encounter')
    s.actors[token]={role=role,dead=false}; effect(s,out,'spawn',{role=role,token=token})
  end
end
local function cleanup(s,out,reason)
  -- Cleanup must target only actors carrying both this owner key and actor token.
  effect(s,out,'cleanup_owned',{reason=reason})
  if s.door_sealed then effect(s,out,'release_door_lease');s.door_sealed=false end
  if s.yavia_lease then effect(s,out,'restore_yavia_lease');s.yavia_lease=false end
  effect(s,out,'release_scene_lease');s.status=reason
end
function M.begin(config, identity, epoch)
  if not config.enabled then return nil,'disabled_pending_dependencies' end
  assert(type(identity)=='string' and #identity>0)
  assert(type(epoch)=='string' and #epoch>0)
  assert(config.family and config.quest)
  return {key=config.family..':'..identity..':'..epoch,identity=identity,epoch=epoch,
    family=config.family,quest=config.quest,status='active',phase='start',sequence=0,
    actors={},receipts={},milestones={},delivered={},wave=1,kills=0,
    yavia_lease=config.family=='yavia'},nil
end
function M.apply(original,e)
  local s=copy(original);local out={}
  if s.status~='active' then return s,out,'closed' end
  if e.kind=='expire' or e.kind=='cancel' or e.kind=='zone_shutdown' or e.kind=='effect_failed' then
    if not e.authoritative then return s,out,'untrusted_cleanup' end
    cleanup(s,out,e.kind);return s,out
  end
  -- Ownership derives from the live shared-task instance, or solo charID+accept epoch.
  -- Group IDs and task IDs alone are never identities. Do not trust user chat/input.
  if e.identity~=s.identity or not e.native_verified then return s,out,'foreign_or_unverified' end
  if not e.receipt or s.receipts[e.receipt] then return s,out,'duplicate_or_missing_receipt' end
  s.receipts[e.receipt]=true
  if e.kind=='actor_bound' then
    local a=s.actors[e.token]
    if not a or a.entity_id or not e.entity_id or e.entity_id<=0 then return s,out,'unexpected_actor' end
    a.entity_id=e.entity_id;return s,out
  end
  if e.kind=='actor_lost' then
    if not s.actors[e.token] then return s,out,'foreign_actor' end
    if s.actors[e.token].dead then return s,out,'already_dead' end
    -- Never manufacture kill progress from depop, corpse cleanup or a missing entity.
    cleanup(s,out,'actor_lost');return s,out
  end
  local f=s.family
  if e.kind=='stock_progress' then
    -- Adapter reads authoritative done_count after native Kill update. Never bump it here.
    if f=='bear' and e.objective=='goblins' and e.done_count>=30 and not s.milestones.bear then
      s.milestones.bear=true;s.phase='bear';spawn(s,out,'domesticated_bear',1)
    elseif f=='gnolls' and e.objective=='gnolls' then
      for _,m in ipairs({{5,'defender_5',2},{10,'defender_10',2},{20,'elite_20',3}}) do
        if e.done_count>=m[1] and not s.milestones[m[2]] then
          s.milestones[m[2]]=true;spawn(s,out,m[2],m[3])
        end
      end
    end
  elseif e.kind=='delivery' and f=='yavia' then
    if s.phase=='start' or s.phase=='food' then
      if e.item_id~=88141 and e.item_id~=88142 then return s,out,'wrong_item' end
      -- receipt is committed only after real hand-in custody; no preloot consume here.
      if s.delivered[tostring(e.item_id)] then return s,out,'already_delivered' end
      s.delivered[tostring(e.item_id)]=true
      -- Native delivery activity already updated; observe only, never duplicate it.
      if s.delivered['88141'] and s.delivered['88142'] then
        local waves={{'spiderling',2},{'assassin_2',2},{'assassin_3',3},{'mature',2},{'queen',1}}
        local w=waves[s.wave];s.phase='combat';s.kills=0
        -- Health stages use explicit researched or user-approved labelled configuration.
        effect(s,out,'yavia_health_stage',{wave=s.wave});spawn(s,out,w[1],w[2])
      end
    end
  elseif e.kind=='completed_cast' and f=='trap' then
    if e.spell_id==7230 and s.phase=='start' and e.in_validated_camp then
      s.phase='trap';spawn(s,out,'rune_trap',1);objective(s,out,'place_trap')
    end
  elseif e.kind=='proximity' then
    if f=='crypt' and e.trigger=='chamber' and s.phase=='start' then
      s.phase='chamber';objective(s,out,'chamber')
    elseif f=='crypt' and e.trigger=='chest' and s.phase=='chamber' then
      -- Native scene lease must already include door exclusivity before this event.
      s.phase='guardian';s.door_sealed=true
      effect(s,out,'seal_door_lease');objective(s,out,'chest');spawn(s,out,'crypt_guardian',1)
    elseif f=='prophet' and e.trigger=='north_crypt' and s.phase=='start' then
      s.phase='prophet';objective(s,out,'crypt');spawn(s,out,'prophet_spirit',1)
    elseif f=='portal' and e.trigger=='portal' and s.phase=='start' and e.fresh_materials_confirmed then
      s.phase='guardian';objective(s,out,'portal');spawn(s,out,'portal_guardian',1)
    end
  elseif e.kind=='trap_crossing' and f=='trap' and s.phase=='trap' then
    -- Input requires server-side crossing of exact trap geometry, eligible live goblin,
    -- matching encounter owner, and remaining slot reservation. A cast alone kills none.
    if e.eligible_goblin and e.live_entity_id and s.kills<3 then
      s.trap_victims=s.trap_victims or {}
      local reserved=0;for _ in pairs(s.trap_victims) do reserved=reserved+1 end
      if s.trap_victims[tostring(e.live_entity_id)]==nil and reserved<3 then
        s.trap_victims[tostring(e.live_entity_id)]=false
        effect(s,out,'trap_kill',{entity_id=e.live_entity_id})
      end
    end
  elseif e.kind=='trap_death' and f=='trap' and s.phase=='trap' then
    -- Only accept death linked to the issued trap_kill effect; ordinary player kills fail.
    if s.trap_victims and s.trap_victims[tostring(e.entity_id)]==false and e.trap_effect_confirmed then
      s.trap_victims[tostring(e.entity_id)]=true;s.kills=s.kills+1
      if s.kills==3 then objective(s,out,'watch_trap');s.phase='hail';effect(s,out,'chaos_dialogue') end
    end
  elseif e.kind=='owned_death' then
    local a=s.actors[e.token]
    if not a or a.dead or a.entity_id~=e.entity_id or not e.kill_credit_confirmed then
      return s,out,'foreign_duplicate_or_uncredited_death'
    end
    a.dead=true
    if f=='bear' and a.role=='domesticated_bear' then objective(s,out,'bear');s.phase='hail'
    elseif f=='gnolls' then
      if a.role=='defender_5' or a.role=='defender_10' then objective(s,out,'defenders')
      elseif a.role=='elite_20' then objective(s,out,'elites') end
    elseif f=='yavia' and s.phase=='combat' then
      s.kills=s.kills+1;objective(s,out,'wave_'..s.wave..'_kills')
      if s.kills==({2,2,3,2,1})[s.wave] then
        s.wave=s.wave+1;s.delivered={};s.phase=s.wave>5 and 'hail' or 'food'
      end
    elseif f=='crypt' and a.role=='crypt_guardian' then
      objective(s,out,'guardian');effect(s,out,'release_door_lease');s.door_sealed=false;s.phase='hail'
    elseif f=='portal' and a.role=='portal_guardian' then objective(s,out,'guardian');s.phase='delivery'
    elseif f=='prophet' and a.role=='prophet_spirit' then
      -- Charm must be on actual corpse with native loot ownership. No summon-on-death.
      objective(s,out,'spirit');s.phase='loot'
    end
  elseif e.kind=='finalized' then
    -- Caller proves task completion/delivery/hail independently; no automatic reward.
    cleanup(s,out,'complete')
  end
  return s,out
end
return M
