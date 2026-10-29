-- Scene ownership and quest-item lifecycle for the Welcome to the Moors chain.
-- Ordinary objectives and rewards remain in the native task engine.
local D=require('achievement_quest_blightfire_welcome_data')
local B=require('achievement_quest_blightfire')
local M={}
local function yes(v)return v==true or v==1 end
local function active(c,t,a)return yes(c:IsTaskActive(t))and(a==nil or yes(c:IsTaskActivityActive(t,a)))end
local function supply(c,item)
 if c:CountItem(item)>0 then return true end
 c:SummonItem(item,1);return c:CountItem(item)>0
end
local function token(c)return c:GetBucket('achievement.welcome.attempt')end
local function belongs(n,c)return n:GetEntityVariable('welcome_owner')==tostring(c:CharacterID())and n:GetEntityVariable('welcome_attempt')==token(c)end
local function mark(n,c)
 n:SetEntityVariable('welcome_owner',tostring(c:CharacterID()));n:SetEntityVariable('welcome_attempt',token(c))
end
local function arrival_key(char,attempt)return 'achievement.welcome.ratwork.arrived.'..tostring(char)..'.'..attempt end
local function eligible(c,id)
 local t=D.tasks[id];if not t or active(c,id)or not yes(eq.is_task_appropriate(id))then return false end
 if not t.repeatable and yes(c:IsTaskCompleted(id))then return false end
 for _,prior in ipairs(t.prerequisites)do if not yes(c:IsTaskCompleted(prior))then return false end end
 return true
end
local function sync(c)
 if active(c,3040102,0)then supply(c,36173)end
 if active(c,3040102,7)then supply(c,36194)end
 if active(c,D.pick.task)then supply(c,D.pick.item)end
 if active(c,D.trap.task)then supply(c,D.trap.item)end
 if active(c,D.croc.task,0)or active(c,D.croc.task,1)then supply(c,D.croc.core)end
end
function M.player_event(e)
 if e.task_id and not D.tasks[e.task_id]then return end
 sync(e.self)
 for _,id in ipairs({3040102,D.pick.task,D.trap.task,D.croc.task})do
  if active(e.self,id)then e.self:SetTimer('welcome_items',2);return end
 end
end
function M.player_accepted(e)
 if e.task_id==D.croc.task then
  local old=tonumber(e.self:GetBucket('achievement.welcome.sequence'))or 0
  e.self:SetBucket('achievement.welcome.sequence',tostring(old+1))
  e.self:SetBucket('achievement.welcome.attempt',tostring(os.time())..'_'..tostring(old+1))
 end
 M.player_event(e)
end
function M.player_timer(e)
 if e.timer~='welcome_items'then return false end
 local needed=false
 for _,id in ipairs({3040102,D.pick.task,D.trap.task,D.croc.task})do if active(e.self,id)then needed=true end end
 if needed then sync(e.self)else e.self:StopTimer(e.timer)end
 return true
end
function M.task_complete(e)
 if e.task_id==D.pick.task then e.self:RemoveItem(D.pick.item,1)end
end
function M.say(e)
 local id=e.self:GetNPCTypeID();local text=e.message:lower();sync(e.other)
 if id==D.croc.hammer and text:find('hail',1,true)and active(e.other,D.croc.task,2)then
  if eq.get_data(arrival_key(e.other:CharacterID(),token(e.other)))=='1'then
   e.self:Say('Number Eight has returned safely. Thank you for rescuing my ratwork!')
   e.other:UpdateTaskActivity(D.croc.task,2,1)
  else e.self:Say('Please see Number Eight safely back to camp before we finish.')end
  return
 end
 if id==394091 then
  if active(e.other,3040102)and(text:find('hail',1,true)or text:find('parts',1,true))then e.self:Say('Bring me branches from Rotwood saplings and skins from the darkwater crocodiles so I can repair the pick.')end
  return
 end
 local request=text:find('hail',1,true)or text:find('true',1,true)or text:find('magic',1,true)or text:find('skins',1,true)or text:find('trouble',1,true)
 if request then
  local options={};for _,tid in ipairs(D.giver_tasks[id]or{})do if eligible(e.other,tid)then options[#options+1]=tid end end
  if #options>0 then eq.task_selector(options)end
 end
end
function M.trade(e)B.trade(e);sync(e.other)end
function M.mining(e)
 if e.spell_id~=D.pick.spell or eq.get_zone_id()~=395 or not e.target.valid then return 0 end
 local n=e.target:CastToNPC();if not n.valid then return 0 end
 local mine=D.pick.rocks[n:GetSpawnPointID()];if not mine then return 0 end
 local c=eq.get_entity_list():GetClientByID(e.caster_id)
 if not c.valid or c:CountItemEquippedByID(D.pick.item)==0 or not active(c,D.pick.task,mine*2-1)then return 1 end
 local item=D.pick.ore[mine];local before=c:CountItem(item)
 c:SummonItem(item,1)
 if c:CountItem(item)>before then
  c:Message(15,'The Golden Pick uncovers an ore sample from this mine.')
  c:UpdateTaskActivity(D.pick.task,mine*2-1,1)
 else c:Message(13,'Make room for the ore sample before mining again.')end
 n:SetHP(n:GetMaxHP());return 1
end
function M.capture(e)
 if e.spell_id~=D.trap.spell then return 0 end
 local c=eq.get_entity_list():GetClientByID(e.caster_id)
 if eq.get_zone_id()~=395 or not c.valid or not e.target.valid or not active(c,D.trap.task,1)or c:CountItem(D.trap.item)==0 then return 1 end
 local n=e.target:CastToNPC();if not n.valid or n:GetOwnerID()~=0 then return 1 end
 local allowed=false;for _,id in ipairs(D.trap.cubs)do if n:GetNPCTypeID()==id then allowed=true end end
 if not allowed then c:Message(13,'This trap can only capture a slashclaw cub.');return 1 end
 c:Message(15,'The slashclaw cub mews weakly as it is captured in the trap.')
 c:UpdateTaskActivity(D.trap.task,1,1);n:Depop();return 1
end
function M.pool_kill(e)
 local c=e.other;if eq.get_zone_id()~=395 or not c.valid or not active(c,D.croc.task,0)then return end
 local allowed=false;for _,id in ipairs(D.croc.pool_ids)do if e.self:GetNPCTypeID()==id then allowed=true end end
 if not allowed then return end
 local dx,dy=e.self:GetX()-D.croc.pool_x,e.self:GetY()-D.croc.pool_y
 if dx*dx+dy*dy>D.croc.pool_radius^2 then return end
 local existing=eq.get_entity_list():GetNPCByID(tonumber(c:GetBucket('achievement.welcome.croc_actor'))or 0)
 if existing.valid and belongs(existing,c)then return end
 if math.random(1,100)>D.croc.spawn_percent then return end
 local n=eq.spawn2(D.croc.npc,0,0,e.self:GetX(),e.self:GetY(),e.self:GetZ(),e.self:GetHeading())
 if not n.valid then return end
 mark(n,c);c:SetBucket('achievement.welcome.croc_actor',tostring(n:GetID()));n:SetTimer('welcome_expire',D.croc.expires_seconds)
end
function M.croc_kill(e)
 local c=e.other;if not c.valid or not belongs(e.self,c)or not active(c,D.croc.task,0)then return end
 if e.self:GetEntityVariable('welcome_rescued')=='1'then return end
 local n=eq.spawn2(D.croc.ratwork,0,0,e.self:GetX(),e.self:GetY(),e.self:GetZ(),e.self:GetHeading())
 if not n.valid then return end
 mark(n,c);n:SetTimer('welcome_expire',D.croc.expires_seconds)
 e.self:SetEntityVariable('welcome_rescued','1');c:SetBucket('achievement.welcome.croc_actor',tostring(n:GetID()))
 c:UpdateTaskActivity(D.croc.task,0,1)
end
function M.rat_trade(e)
 local c=e.other;local given,required,items={},{},{}
 for i=1,4 do
  local it=e.trade['item'..i]
  if it and it.valid then local key=tostring(it:GetID());given[key]=(given[key]or 0)+(it:IsStackable()and it:GetCharges()or 1);items[#items+1]=it end
 end
 for _,coin in ipairs({'copper','silver','gold','platinum'})do if(e.trade[coin]or 0)>0 then given[coin]=e.trade[coin]end end
 local valid=belongs(e.self,c)and active(c,D.croc.task,1)and(given[tostring(D.croc.core)]or 0)>0
 if valid then required[tostring(D.croc.core)]=1 end
 local used=valid and e.self:CheckHandin(c,given,required,items)
 e.self:ReturnHandinItems(c)
 if not used then return end
 local h=eq.get_entity_list():GetNPCByNPCTypeID(D.croc.hammer)
 if not h.valid then c:SummonItem(D.croc.core,1);return end
 e.self:Say('Power core installed. Returning to Master Hammerstock.')
 e.self:SetEntityVariable('welcome_walking','1');e.self:SetEntityVariable('welcome_walk_started',tostring(os.time()))
 e.self:SetNPCFactionID(0);e.self:WipeHateList()
 e.self:MoveTo(h:GetX(),h:GetY(),h:GetZ(),h:GetHeading(),false)
 e.self:SetTimer('welcome_walk',2);c:UpdateTaskActivity(D.croc.task,1,1)
end
function M.actor_timer(e)
 if e.timer=='welcome_expire'then e.self:Depop();return true end
 if e.timer~='welcome_walk'then return false end
 local h=eq.get_entity_list():GetNPCByNPCTypeID(D.croc.hammer);if not h.valid then return true end
 local dx,dy=e.self:GetX()-h:GetX(),e.self:GetY()-h:GetY()
 if dx*dx+dy*dy<225 and math.abs(e.self:GetZ()-h:GetZ())<25 then
  eq.set_data(arrival_key(e.self:GetEntityVariable('welcome_owner'),e.self:GetEntityVariable('welcome_attempt')),'1','1d')
  e.self:Depop();return true
 end
 local since=tonumber(e.self:GetEntityVariable('welcome_walk_started'))or os.time()
 if os.time()-since>D.croc.walk_timeout_seconds then e.self:Depop();return true end
 return true
end
return M
