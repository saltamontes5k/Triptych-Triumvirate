-- Scene settings are sourced or explicitly reconstructed in stonehive_data.
local D=require('achievement_quest_stonehive_data')
local M={}
local function yes(v)return v==true or v==1 end
local function active(c,t,a)return yes(c:IsTaskActive(t))and(a==nil or yes(c:IsTaskActivityActive(t,a)))end
local function npc(id)return eq.get_entity_list():GetNPCByNPCTypeID(id)end
local function live(n)return n and n.valid end
local function all_npcs(fn)
 for n in eq.get_entity_list():GetNPCList().entries do if n.valid then fn(n)end end
end
function M.fungus_spawn(e)
 -- Native class62 actor already has petals, seeds and sap in lootdrop109689.
 -- Preserve the collected weighted loot table, including empty/other-item rolls.
 -- Opening and looting the native corpse supplies the normal loot objectives.
end
function M.neezzee_spawn(e)
 e.self:SetEntityVariable('stone_neezzee_awake','0')
 eq.modify_npc_stat('aggro','0');eq.modify_npc_stat('assist','0')
end
function M.neezzee_say(e)
 if not e.message:lower():find('hail',1,true)or not active(e.other,3040313,0)then return end
 e.self:SetEntityVariable('stone_neezzee_awake','1')
 eq.modify_npc_stat('aggro',tostring(D.neezzee.aggro));eq.modify_npc_stat('assist',tostring(D.neezzee.assist))
 e.self:Say('You have walked into Stone Hive\'s trap!');e.self:Attack(e.other)
end
function M.neezzee_combat(e)
 if yes(e.joined)then
  eq.modify_npc_stat('aggro',tostring(D.neezzee.aggro));eq.modify_npc_stat('assist',tostring(D.neezzee.assist))
 else
  e.self:SetEntityVariable('stone_neezzee_awake','0');eq.modify_npc_stat('aggro','0');eq.modify_npc_stat('assist','0')
 end
end
function M.ensure_juzz()
 local n=npc(D.juzzulli.npc);if live(n)then return true end
 local p=D.juzzulli;n=eq.unique_spawn(p.npc,0,0,p.x,p.y,p.z,0)
 return live(n)
end
function M.juzz_spawn(e)
 -- Expire only an idle encounter actor. A continuing fight never times out.
 e.self:SetTimer('achievement_stone_juzz_idle',600)
end
function M.juzz_timer(e)
 if e.timer=='achievement_stone_juzz_idle'and not e.self:IsEngaged()then e.self:Depop(false)end
end
local function queen_home(n)
 return{x=tonumber(n:GetEntityVariable('stone_home_x')),y=tonumber(n:GetEntityVariable('stone_home_y')),z=tonumber(n:GetEntityVariable('stone_home_z')),h=tonumber(n:GetEntityVariable('stone_home_h'))or 0}
end
local function clear_swarms(n)
 local owner=tostring(n:GetID())
 all_npcs(function(a)
  if a:GetNPCTypeID()==D.queen.swarmer and a:GetEntityVariable('stone_queen_owner')==owner then a:Depop(false)end
 end)
end
function M.queen_spawn(e)
 local n=e.self;local q=D.queen
 n:SetEntityVariable('stone_home_x',tostring(n:GetX()));n:SetEntityVariable('stone_home_y',tostring(n:GetY()));n:SetEntityVariable('stone_home_z',tostring(n:GetZ()));n:SetEntityVariable('stone_home_h',tostring(n:GetHeading()))
 n:SetEntityVariable('stone_wave_one','0');n:SetEntityVariable('stone_wave_two','0')
 eq.modify_npc_stat('max_hp',tostring(q.hp));eq.modify_npc_stat('min_hit',tostring(q.min_hit));eq.modify_npc_stat('max_hit',tostring(q.max_hit));n:SetHP(n:GetMaxHP())
 eq.modify_npc_stat('max_mana',tostring(q.mana));n:SetMana(n:GetMaxMana());n:AddAISpell(1,q.spell,1,0,q.spell_recast,0)
 n:SetSpecialAbility(SpecialAbility.unsnareable,1);n:SetSpecialAbility(SpecialAbility.summon,0)
end
function M.queen_combat(e)
 if yes(e.joined)then eq.set_next_hp_event(D.queen.wave_thresholds[1]);e.self:SetTimer('achievement_stone_queen_tether',1)
 else M.queen_end(e);e.self:SetEntityVariable('stone_wave_one','0');e.self:SetEntityVariable('stone_wave_two','0')end
end
local function wave(n,typeid,count)
 local target=n:GetHateTop();local existing=0
 if typeid==D.queen.grub then all_npcs(function(a)if a:GetNPCTypeID()==typeid then existing=existing+1 end end);count=math.min(count,math.max(0,D.queen.grub_cap-existing))end
 for i=1,count do
  local angle=(i-1)*math.pi*2/math.max(1,count)
  local a=eq.spawn2(typeid,0,0,n:GetX()+math.cos(angle)*8,n:GetY()+math.sin(angle)*8,n:GetZ(),0)
  if live(a)then
   a:SetEntityVariable('stone_queen_owner',tostring(n:GetID()))
   if typeid==D.queen.swarmer then a:SetTimer('achievement_stone_swarmer_tether',1)end
   if live(target)then a:Attack(target)end
  end
 end
end
function M.queen_hp(e)
 local n=e.self;local ratio=tonumber(e.hp_event)or n:GetHPRatio()
 if ratio<=D.queen.wave_thresholds[1]and n:GetEntityVariable('stone_wave_one')~='1'then
  n:SetEntityVariable('stone_wave_one','1');wave(n,D.queen.swarmer,D.queen.swarmer_count);eq.set_next_hp_event(D.queen.wave_thresholds[2])
 end
 if ratio<=D.queen.wave_thresholds[2]and n:GetEntityVariable('stone_wave_two')~='1'then
  n:SetEntityVariable('stone_wave_two','1');wave(n,D.queen.grub,D.queen.grub_count)
 end
end
function M.queen_end(e)
 e.self:StopTimer('achievement_stone_queen_tether');clear_swarms(e.self)
 -- Young grubs intentionally survive the encounter and remain ordinary NPCs.
end
function M.queen_timer(e)
 if e.timer~='achievement_stone_queen_tether'then return end
 local n=e.self;local p=queen_home(n);if not p.x or not p.y or not p.z then return end
 local dx,dy=n:GetX()-p.x,n:GetY()-p.y
 if dx*dx+dy*dy>D.queen.tether_radius*D.queen.tether_radius or math.abs(n:GetZ()-p.z)>D.queen.tether_vertical then
  clear_swarms(n);n:WipeHateList();n:BuffFadeAll();n:GMMove(p.x,p.y,p.z,p.h,false);n:SetHP(n:GetMaxHP());n:SetMana(n:GetMaxMana())
  n:SetEntityVariable('stone_wave_one','0');n:SetEntityVariable('stone_wave_two','0');eq.set_next_hp_event(D.queen.wave_thresholds[1])
 end
end
function M.add_timer(e)
 if e.timer~='achievement_stone_swarmer_tether'then return end
 local owner=tonumber(e.self:GetEntityVariable('stone_queen_owner'))or 0
 local queen=eq.get_entity_list():GetNPCByID(owner)
 if not live(queen)or queen:GetNPCTypeID()~=D.queen.npc or not queen:IsEngaged()then e.self:Depop(false);return end
 local dx,dy=e.self:GetX()-queen:GetX(),e.self:GetY()-queen:GetY()
 if dx*dx+dy*dy>D.queen.tether_radius*D.queen.tether_radius then e.self:Depop(false)end
end
return M
