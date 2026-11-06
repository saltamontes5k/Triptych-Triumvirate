-- Native tasks own ordinary kill/loot/hand-in updates and XP/faction delivery.
-- Special actions remain disabled until the whole content package is installed.
local D=require('achievement_quest_dragonscale_data')
local json=require('json')
local M={}
local W=D.world or {}
local farm={3041001,3041002,3041003}
local farm_key='achievement.dragonscale.farm_cycle'
local rescue=3041014
local guard_type=442900
local guard_epoch='achievement.dragonscale.rescue_epoch'
local function yes(v)return v==true or v==1 end
local function active(c,id)return c and c.valid and yes(c:IsTaskActive(id))end
local function step(c,id,a)return active(c,id)and yes(c:IsTaskActivityActive(id,a))end
local function static()return eq.get_zone_instance_id()==0 end
local function enabled()return D.enabled and static()end
local function state(c,key)
 local text=c:GetBucket(key);if not text or text==''then return {}end
 local ok,value=pcall(json.decode,text);return ok and type(value)=='table'and value or {}
end
local function save(c,key,value)c:SetBucket(key,json.encode(value))end
local function eligible(c,t)
 if not enabled()or not t or not t.enabled or not t.runtime_dependencies_ready or c:GetLevel()<t.minimum_level or active(c,t.task_id)then return false end
 if not t.repeatable and yes(c:IsTaskCompleted(t.task_id))then return false end
 for _,id in ipairs(t.prerequisites)do if not yes(c:IsTaskCompleted(id))then return false end end
 if t.minimum_faction_rule then
  local minimum=tonumber(eq.get_rule(t.minimum_faction_rule))
  if not minimum or c:GetModCharacterFactionLevel(1185)<minimum then return false end
 end
 return yes(eq.is_task_appropriate(t.task_id))
end
function M.say(e)
 if not enabled()then return end
 local ids=D.givers[e.self:GetNPCTypeID()];if not ids then return end
 local text=e.message:lower();local requested=false
 for _,word in ipairs({'hail','task','help','profit','clockworks','replace','resources','deal','risk','assist','issues','grateful','find her','aid'})do
  if text:find(word,1,true)then requested=true;break end
 end
 if not requested then return end
 -- Reissue only a missing physical banner for an already active banner task.
 if e.self:GetNPCTypeID()==442015 and (step(e.other,3041006,0)or step(e.other,3041006,1)or step(e.other,3041007,0)or step(e.other,3041007,1))and e.other:CountItem(36679)==0 then e.other:SummonItem(36679,1)end
 local available={};for _,id in ipairs(ids)do if eligible(e.other,D.tasks[id])then available[#available+1]=id end end
 if #available>0 then eq.task_selector(available)end
end
function M.accepted(e)
 local t=D.tasks[e.task_id];local c=e.other
 if not enabled()or not t or not t.enabled or not t.runtime_dependencies_ready or not active(c,t.task_id)or e.self:GetNPCTypeID()~=t.giver_npc_id then return end
 if t.supply_item and c:CountItem(t.supply_item)==0 then c:SummonItem(t.supply_item,1)end
 if e.task_id>=3041001 and e.task_id<=3041003 then
  -- Period direct evidence requires the three farm jobs together. A fresh
  -- acceptance starts a fresh cycle; older completed jobs cannot substitute.
  local all=true;for _,id in ipairs(farm)do if not active(c,id)then all=false end end
  save(c,farm_key,{ready=all,completed={}})
 end
 if e.task_id==rescue then
  -- A new acceptance cannot inherit or accumulate actors from a cancelled job.
  for n in eq.get_entity_list():GetNPCList().entries do
   if n:GetNPCTypeID()==guard_type and n:GetEntityVariable('dragonscale_owner')==tostring(c:CharacterID())then n:Depop()end
  end
  c:SetBucket(guard_epoch,'')
 end
end
function M.complete(e)
 local t=D.tasks[e.task_id];local c=e.self
 if not enabled()or not t or not t.enabled or not t.runtime_dependencies_ready then return 0 end
 local item=t.rewards.item_id
 if e.task_id>=3041001 and e.task_id<=3041003 then
  local s=state(c,farm_key)
  if s.ready then
   s.completed=s.completed or {};s.completed[tostring(e.task_id)]=true
   local all=true;for _,id in ipairs(farm)do if not s.completed[tostring(id)]then all=false end end
   if all then item=79764;s.ready=false end
   save(c,farm_key,s)
  end
 end
 -- Repeatable lore rewards do not block the native XP/faction completion.
 -- CountItem includes bank custody, so an already-owned gear is never replaced.
 if item and c:CountItem(item)==0 then c:SummonItem(item,1)end
 return 0
end
function M.before_update(e)
 local t=D.tasks[e.task_id];if not t then return 0 end
 return enabled()and t.enabled and t.runtime_dependencies_ready and 0 or 1
end
function M.trade(e)
 if not enabled()or not D.givers[e.self:GetNPCTypeID()]then return end
 local handin,required,items={},{},{}
 for slot=1,4 do
  local inst=e.trade['item'..slot]
  if inst and inst.valid then
   items[#items+1]=inst;local id=tostring(inst:GetID())
   handin[id]=(handin[id]or 0)+(inst:IsStackable()and inst:GetCharges()or 1)
   local used=inst:GetTaskDeliveredCount();if used>0 then required[id]=(required[id]or 0)+used end
  end
 end
 for _,coin in ipairs({'copper','silver','gold','platinum'})do if(e.trade[coin]or 0)>0 then handin[coin]=e.trade[coin]end end
 if next(required)then e.self:CheckHandin(e.other,handin,required,items)end
 e.self:ReturnHandinItems(e.other)
end
function M.banner(e)
 -- The native completed-item-cast event authenticates the actual expendable
 -- item and its consumed charge. Blank placeholder spell effects need not run.
 if not e.spell or e.spell:ID()~=13260 or not enabled()or eq.get_zone_id()~=442 then return 0 end
 if e.cast_item_id~=36679 or not e.cast_item_charge_consumed or
    type(e.cast_item_slot)~='number'or e.cast_item_slot<0 then return 0 end
 local c=e.self
 if not c or not c.valid or e.caster_id~=c:GetID()or e.target_id~=c:GetID()or c:GetLevel()<70 then return 0 end
 local b=W.banner;if not b then return 0 end
 local dx,dy=c:GetX()-b.x,c:GetY()-b.y
 if dx*dx+dy*dy>b.radius*b.radius or c:GetZ()<b.min_z or c:GetZ()>b.max_z then c:Message(13,'This is not the clockwork claim site. Bobbenpin can replace the banner.');return 0 end
 for _,id in ipairs({3041006,3041007})do if step(c,id,1)then c:UpdateTaskActivity(id,1,1)end end
 return 0
end
local function belongs(n,c,epoch)
 return n.valid and n:GetNPCTypeID()==guard_type and n:GetEntityVariable('dragonscale_owner')==tostring(c:CharacterID())and n:GetEntityVariable('dragonscale_epoch')==epoch
end
function M.rescue_hail(e)
 if not enabled()or eq.get_zone_id()~=442 or e.self:GetNPCTypeID()~=442182 or not e.message:lower():find('hail',1,true)then return end
 local c=e.other
 if not(step(c,rescue,1)or step(c,rescue,2))or yes(c:IsInvisible())or c:GetInvisibleUndeadLevel()>0 then return end
 local cfg=W.guards;if not cfg then return end
 local dx,dy,dz=c:GetX()-e.self:GetX(),c:GetY()-e.self:GetY(),c:GetZ()-e.self:GetZ()
 if dx*dx+dy*dy>cfg.hail_radius*cfg.hail_radius or math.abs(dz)>cfg.hail_vertical then return end
 local epoch=c:GetBucket(guard_epoch)
 if not epoch or epoch==''then epoch=tostring(os.time())..':'..tostring(c:GetID());c:SetBucket(guard_epoch,epoch)end
 local living=0
 for n in eq.get_entity_list():GetNPCList().entries do if belongs(n,c,epoch)and n:GetHP()>0 then living=living+1 end end
 local done=step(c,rescue,2)and eq.get_task_activity_done_count(rescue,2)or 0
 local needed=math.max(0,2-done-living);local spawned={}
 for i=1,needed do
  local offset=i%2==0 and cfg.offset_x or -cfg.offset_x
  local n=eq.spawn2(guard_type,0,0,e.self:GetX()+offset,e.self:GetY()+cfg.offset_y,e.self:GetZ(),e.self:GetHeading())
  if not n.valid then for _,old in ipairs(spawned)do old:Depop()end;return end
  n:SetEntityVariable('dragonscale_owner',tostring(c:CharacterID()));n:SetEntityVariable('dragonscale_epoch',epoch)
  n:SetTimer('dragonscale_guard_expire',cfg.expires_seconds);spawned[#spawned+1]=n
 end
 if step(c,rescue,1)then c:UpdateTaskActivity(rescue,1,1)end
 for _,n in ipairs(spawned)do n:AddToHateList(c,1)end
end
function M.guard_killed(e)
 if not enabled()or eq.get_zone_id()~=442 then return end
 local c=e.other;if not c or not c.valid or not step(c,rescue,2)then return end
 local epoch=c:GetBucket(guard_epoch)
 if not epoch or epoch==''or not belongs(e.self,c,epoch)or e.self:GetEntityVariable('dragonscale_credited')=='1'then return end
 e.self:SetEntityVariable('dragonscale_credited','1');c:UpdateTaskActivity(rescue,2,1)
end
function M.guard_timer(e)
 if e.timer~='dragonscale_guard_expire'or e.self:GetNPCTypeID()~=guard_type then return false end
 e.self:StopTimer(e.timer);e.self:Depop();return true
end
function M.actor_spawn(e)
 if not enabled()then return end
 local id=e.self:GetNPCTypeID()
 if eq.get_zone_id()==442 and id==442086 then e.self:AddItem(36637,1)
 elseif eq.get_zone_id()==443 and id==443900 then e.self:AddItem(36652,1)end
end
return M
