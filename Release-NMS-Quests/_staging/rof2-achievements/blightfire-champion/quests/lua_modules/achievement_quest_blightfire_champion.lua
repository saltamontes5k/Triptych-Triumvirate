-- Private Champion candidate; scene configuration retains historical/reconstruction labels.
local D=require('achievement_quest_blightfire_champion_data')
local B=require('achievement_quest_blightfire')
local M={}
local function yes(v)return v==true or v==1 end
local function active(c,t,a)return c.valid and yes(c:IsTaskActive(t))and(a==nil or yes(c:IsTaskActivityActive(t,a)))end
local function supply(c,id)if c:CountItem(id)==0 then c:SummonItem(id,1)end end
local function cycle(c)return tonumber(c:GetBucket('achievement.champion.tower.stage'))or 0 end
local function eligible(c,t)
 if active(c,t.id)or not yes(eq.is_task_appropriate(t.id))then return false end
 if t.id>=3040204 and t.id<=3040206 then return cycle(c)==t.id-3040204 end
 return t.repeatable or not yes(c:IsTaskCompleted(t.id))
end
local function immune(n,value)
 for _,id in ipairs({SpecialAbility.immune_melee,SpecialAbility.immune_magic,SpecialAbility.immune_aggro,SpecialAbility.immune_aggro_on})do n:SetSpecialAbility(id,value)end
end
local function trade_items(e)
 local given,items={},{}
 for i=1,4 do local it=e.trade['item'..i];if it and it.valid then local id=tostring(it:GetID());given[id]=(given[id]or 0)+(it:IsStackable()and it:GetCharges()or 1);items[#items+1]=it end end
 for _,coin in ipairs({'copper','silver','gold','platinum'})do if(e.trade[coin]or 0)>0 then given[coin]=e.trade[coin]end end
 return given,items
end
local function consume(e,item,amount)
 local given,items=trade_items(e);local required={};if(given[tostring(item)]or 0)>=amount then required[tostring(item)]=amount end
 local used=next(required)and e.self:CheckHandin(e.other,given,required,items)
 e.self:ReturnHandinItems(e.other);return used
end
function M.bone_spawn(e)
 immune(e.self,1);e.self:AddItem(D.bone.item,1)
end
function M.player(e)
 if not e.task_id or not D.tasks[e.task_id]then return end
 if e.task_id==3040208 and active(e.self,3040208)then supply(e.self,D.moorwalkers.item)end
 if e.task_id==3040206 and active(e.self,3040206,0)then supply(e.self,D.tower.crest)end
end
function M.complete(e)
 if e.task_id and e.task_id>=3040204 and e.task_id<=3040206 then e.self:SetBucket('achievement.champion.tower.stage',tostring((e.task_id-3040203)%3))end
end
function M.say(e)
 local id=e.self:GetNPCTypeID();local text=e.message:lower()
 if id==D.witch.zan and(text:find('hail',1,true)or text=='she')then e.self:PauseWandering(20)end
 if id==D.tower.npc then
  if text:find('hail',1,true)and active(e.other,3040206,0)then
   e.self:SetEntityVariable('champion_hail_'..e.other:CharacterID(),'1')
   e.self:Say('Show me the battle crests of my watch if you dare challenge me.')
  end
  return
 end
 if not(text:find('hail',1,true)or text:find('dark tower',1,true)or text:find('quest',1,true)or text=='she')then return end
 local options={}
 for _,tid in ipairs(D.givers[id]or{})do if eligible(e.other,D.tasks[tid])then options[#options+1]=tid end end
 if #options>0 then eq.task_selector(options)end
end
function M.trade(e)
 local green=false
 for i=1,4 do local it=e.trade['item'..i];if it and it.valid and it:GetID()==85761 and it:GetTaskDeliveredCount()>0 then green=true end end
 B.trade(e)
 if green and e.self:GetNPCTypeID()==D.witch.zan then
  e.self:Say('The curse is broken. Find the other witches and bring their staffs to Shaytherrin.')
  e.self:SetRace(D.witch.drakkin_race);e.self:SetNPCFactionID(0);e.self:WipeHateList();e.self:PauseWandering(D.witch.walk_seconds+2)
  e.self:MoveTo(e.self:GetX()+120,e.self:GetY(),e.self:GetZ(),e.self:GetHeading(),false);e.self:SetTimer('champion_zan_leave',D.witch.walk_seconds)
 end
end
function M.moor_spawn(e)
 e.self:SetSpecialAbility(SpecialAbility.summon,1);e.self:SetSpecialAbility(SpecialAbility.rampage,1)
 eq.modify_npc_stat('max_hit',tostring(D.moorwalkers.max_hit))
end
function M.sleep(e)
 local d=D.moorwalkers;if e.spell_id~=d.spell then return 0 end
 if not e.target or not e.target.valid then return 1 end
 local c=eq.get_entity_list():GetClientByID(e.caster_id);local n=e.target:CastToNPC()
 if eq.get_zone_id()~=395 or not c.valid or not n.valid then return 1 end
 local activity=d.targets[n:GetNPCTypeID()]
 if activity==nil or not active(c,d.task,activity)or c:CountItem(d.item)==0 or n:GetOwnerID()~=0 then return 1 end
 if n:GetHPRatio()>d.max_hp_ratio then c:Message(13,'The Moorwalker is too strong. It must first be weakened.');return 1 end
 if n:GetHP()<=0 or n:GetEntityVariable('champion_slumber')=='1'then return 1 end
 n:SetEntityVariable('champion_slumber','1');n:WipeHateList();n:PauseWandering(d.slumber_seconds+2);immune(n,1);n:TempName('Slumbering_Moorwalker');n:SetAppearance(3)
 c:Message(15,'The Moorwalker lumbers to the ground and falls into hibernation.')
 c:UpdateTaskActivity(d.task,activity,1);n:SetTimer('champion_slumber',d.slumber_seconds);return 1
end
local function boss()return eq.get_entity_list():GetNPCByNPCTypeID(D.tower.npc)end
local function phase(n)return n:GetEntityVariable('champion_tower_phase')end
function M.defan_spawn(e)
 e.self:SetEntityVariable('champion_tower_phase','idle');e.self:SetInvul(true);immune(e.self,1)
 eq.modify_npc_stat('level','42');eq.modify_npc_stat('max_hit','200');eq.modify_npc_stat('max_hp',tostring(D.tower.initial_hp));e.self:SetHP(e.self:GetMaxHP());eq.modify_npc_stat('max_mana',tostring(D.tower.mana));e.self:SetMana(e.self:GetMaxMana())
 for _,spell in ipairs(D.tower.spells)do e.self:AddAISpell(1,spell.id,spell.type,-1,spell.recast,0)end
 e.self:SetSpecialAbility(SpecialAbility.summon,1);e.self:SetSpecialAbility(SpecialAbility.rampage,1);e.self:SetSpecialAbility(SpecialAbility.flurry,1)
end
function M.defan_trade(e)
 local c=e.other;local p=phase(e.self)
 if not active(c,3040206,0)or e.self:GetEntityVariable('champion_hail_'..c:CharacterID())~='1'or(p~='idle'and p~='arming')then e.self:ReturnHandinItems(c);return end
 if not consume(e,D.tower.crest,1)then return end
 e.self:SetEntityVariable('champion_member_'..c:CharacterID(),'1');c:UpdateTaskActivity(3040206,0,1)
 if p=='idle'then
  e.self:SetEntityVariable('champion_tower_phase','arming');e.self:SetEntityVariable('champion_owner_entity',tostring(c:GetID()));e.self:SetEntityVariable('champion_owner_character',tostring(c:CharacterID()))
  e.self:Say('You have challenged the Captain of the Watch Tower. Prepare yourselves!')
  e.self:SetTimer('champion_arm',D.tower.roster_window_seconds);e.self:SetTimer('champion_reset',D.tower.reset_seconds)
 end
end
function M.roof(n)
 if phase(n)~='floor'then return false end
 n:SetEntityVariable('champion_tower_phase','roof');n:WipeHateList();n:SetHP(n:GetMaxHP());local p=D.tower.roof;n:GMMove(p.x,p.y,p.z,0,false)
 n:Say('Face me atop the tower!');return true
end
function M.defan_hp(e)if phase(e.self)=='floor'then M.roof(e.self)end end
function M.defan_death(e)
 if phase(e.self)=='floor'then M.roof(e.self);return 1 end
 if phase(e.self)~='roof'then e.self:SetHP(e.self:GetMaxHP());return 1 end
 return 0
end
function M.defan_merit(e)
 if phase(e.self)=='roof'and e.other.valid and e.self:GetEntityVariable('champion_member_'..e.other:CharacterID())=='1'and active(e.other,3040206,1)then e.other:UpdateTaskActivity(3040206,1,1)end
end
function M.torch_trade(e)
 local n=boss();if not n.valid or(phase(n)~='floor'and phase(n)~='roof'and phase(n)~='arming')then e.self:ReturnHandinItems(e.other);return end
 local given=trade_items(e);local qty=given[tostring(D.tower.torch_item)]or 0
 if qty<1 then e.self:ReturnHandinItems(e.other);return end
 if not consume(e,D.tower.torch_item,qty)then return end
 local seconds=e.self:GetNPCTypeID()==D.tower.signal_npc and D.tower.signal_seconds_per_torch or D.tower.torch_seconds
 local untiltime=math.max(os.time(),tonumber(e.self:GetEntityVariable('champion_lit_until'))or 0)+seconds*qty
 e.self:SetEntityVariable('champion_lit_until',tostring(untiltime));e.self:SetAppearance(0);e.self:Emote('burns brightly.');e.self:SetTimer('champion_torch_out',untiltime-os.time())
end
local function add(n,id,x,y,z)
 local total=0;local list=eq.get_entity_list():GetNPCList()
 for v in list.entries do if v:GetEntityVariable('champion_parent_entity')==tostring(n:GetID())then total=total+1 end end
 if total>=D.tower.add_limit then return end
 local v=eq.spawn2(id,0,0,x,y,z,0);if not v.valid then return end
 v:SetEntityVariable('champion_parent_entity',tostring(n:GetID()));v:SetTimer('champion_add_expire',D.tower.reset_seconds)
 local t=n:GetHateTop();if t.valid then v:AddToHateList(t,1)end
end
function M.tower_timer(e)
 local n=e.self
 if e.timer=='champion_arm'then
  n:StopTimer(e.timer);n:SetEntityVariable('champion_tower_phase','floor');n:SetInvul(false);immune(n,0);eq.set_next_hp_event(D.tower.transition_hp);n:SetTimer('champion_adds',D.tower.adds_interval_seconds)
  local c=eq.get_entity_list():GetClientByID(tonumber(n:GetEntityVariable('champion_owner_entity'))or 0)
  if c.valid and tostring(c:CharacterID())==n:GetEntityVariable('champion_owner_character')then n:AddToHateList(c,1)end
 elseif e.timer=='champion_reset'then n:Depop(true)
 elseif e.timer=='champion_adds'then
  if phase(n)=='floor'then
   local list=eq.get_entity_list():GetNPCList()
   for v in list.entries do if v:GetNPCTypeID()==D.tower.torch_npc and(tonumber(v:GetEntityVariable('champion_lit_until'))or 0)<os.time()then add(n,D.tower.bat,v:GetX(),v:GetY(),v:GetZ())end end
  elseif phase(n)=='roof'then
   local signal=eq.get_entity_list():GetNPCByNPCTypeID(D.tower.signal_npc)
   if signal.valid and(tonumber(signal:GetEntityVariable('champion_lit_until'))or 0)<os.time()then add(n,D.tower.bat,n:GetX()+5,n:GetY(),n:GetZ());add(n,D.tower.rat,n:GetX()-5,n:GetY(),n:GetZ())end
  end
 end
end
function M.witch_summon(e)e.self:SetSpecialAbility(SpecialAbility.summon,1)end
function M.witch_spawn(e)M.witch_summon(e);e.self:SetEntityVariable('champion_eye_index','0');eq.set_next_hp_event(D.witch.thresholds[1])end
function M.witch_hp(e)
 local i=(tonumber(e.self:GetEntityVariable('champion_eye_index'))or 0)+1;if i>D.witch.eye_count then return end
 e.self:SetEntityVariable('champion_eye_index',tostring(i));local eye=eq.spawn2(D.witch.eye,0,0,e.self:GetX()+3,e.self:GetY(),e.self:GetZ(),0)
 if eye.valid then local t=e.self:GetHateTop();if t.valid then eye:AddToHateList(t,1)end;eye:SetTimer('champion_add_expire',D.tower.reset_seconds)end
 if D.witch.thresholds[i+1]then eq.set_next_hp_event(D.witch.thresholds[i+1])end
end
function M.timer(e)
 if e.timer=='champion_slumber'or e.timer=='champion_zan_leave'or e.timer=='champion_add_expire'then e.self:Depop(true);return true end
 if e.timer=='champion_torch_out'then e.self:StopTimer(e.timer);e.self:SetAppearance(3);return true end
 return false
end
return M
