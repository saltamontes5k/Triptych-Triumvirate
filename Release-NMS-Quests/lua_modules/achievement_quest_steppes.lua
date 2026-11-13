-- Native task core owns completion, delivery consumption, XP and all rewards.
local D=require('achievement_quest_steppes_data')
local I=require('achievement_quest_mesa_inventory')
local B=require('achievement_quest_blightfire')
local E=require('achievement_quest_steppes_encounters')
local M={}
local timer='achievement_steppes_inventory'
local function yes(v)return v==true or v==1 end
local function active(c,id,a)return yes(c:IsTaskActive(id))and(a==nil or yes(c:IsTaskActivityActive(id,a)))end
local function arm(c)
 local needed=false
 if D.enabled then
  for _,id in ipairs(D.inventory_tasks)do if active(c,id,0)then needed=true end end
 end
 if needed then c:SetTimer(timer,1)else c:StopTimer(timer)end
end
local function eligible(c,t)
 if active(c,t.id)or c:GetLevel()<t.min_level then return false end
 if not t.repeatable and yes(c:IsTaskCompleted(t.id))then return false end
 for _,id in ipairs(t.prerequisites)do if not yes(c:IsTaskCompleted(id))then return false end end
 return yes(eq.is_task_appropriate(t.id))
end
function M.say(e)
 if not D.enabled then return false end
 local ids=D.givers[e.self:GetNPCTypeID()];if not ids then return false end
 local text=e.message:lower();local wanted=text:find('hail',1,true)or text:find('help',1,true)or text:find('task',1,true)or text:find('work',1,true)
 if not wanted then E.say(e);return true end
 local solo,shared={},{}
 for _,id in ipairs(ids)do local t=D.tasks[id]
  if eligible(e.other,t)then local list=t.shared and shared or solo;list[#list+1]=id end
 end
 -- Native selector cannot mix solo/shared: any shared task drops all solo
 -- offers. Give Jakar explicit modes instead of accidentally hiding Cull.
 local want_shared=text:find('group',1,true)or text:find('shared',1,true)
 local want_solo=text:find('solo',1,true)
 if #solo>0 and #shared>0 and not want_shared and not want_solo then
  e.self:Say('I have '..eq.say_link('solo work')..' and '..eq.say_link('group work')..' available.')
 elseif want_shared or(#solo==0 and not want_solo)then
  if #shared>0 then eq.task_selector(shared)end
 else
  if #solo>0 then eq.task_selector(solo)end
 end
 E.say(e);return true
end
function M.trade(e)
 if not D.enabled then return false end
 -- Before handing inventory custody back to core-marked consumption,
 -- encounter adapter may observe actual native delivery receipts only.
 E.trade_receipt(e)
 B.trade(e)
 return true
end
local observe_inventory
function M.accepted(e)if not D.enabled then return end;observe_inventory(e.self);arm(e.self);E.accepted(e)end
function M.resume(e)if not D.enabled then return end;observe_inventory(e.self);arm(e.self);E.resume(e)end
function M.complete(e)if not D.enabled then return end;E.complete(e);arm(e.self)end
function M.stage(e)if not D.enabled then return end;E.stage(e);arm(e.self)end
function M.update(e)if not D.enabled then return end;E.update(e)end
function M.cast(e)if not D.enabled then return end;return E.cast(e)end
function M.task_fail(e)if not D.enabled then return end;E.task_fail(e);arm(e.self)end
function M.before_update(e)if not D.enabled then return 0 end;return E.before_update(e)end
function M.killed_merit(e)if not D.enabled then return end;E.killed_merit(e)end
function M.death_complete(e)if not D.enabled then return end;E.death_complete(e)end
function M.zone_shutdown(e)if not D.enabled then return end;E.zone_shutdown(e)end
function M.click_door(e)if not D.enabled then return 0 end;return E.click_door(e)end
function M.spawn(e)if not D.enabled then return end;return E.spawn(e)end
function M.despawn(e)if not D.enabled then return end;return E.despawn(e)end
observe_inventory=function(c)
 for _,id in ipairs(D.inventory_tasks)do
  if active(c,id,0)then
   local a=D.tasks[id].activities[1]
   local done=eq.get_task_activity_done_count(id,0)
   local held=math.min(a.goalcount,I.count(c,a.item_ids[1]))
   if done>=0 and held>done then c:UpdateTaskActivity(id,0,held-done)end
  end
 end
end
function M.timer(e)
 if e.timer~=timer then return D.enabled and E.timer(e)or false end
 if not D.enabled then e.self:StopTimer(timer);return true end
 -- Original Cull hand-ins accept prelooted supplies immediately in Crescent
 -- Reach. Possession observations must not require a needless Steppes trip.
 observe_inventory(e.self);arm(e.self);return true
end
return M
