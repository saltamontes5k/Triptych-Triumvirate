-- Native core owns all task counts, item custody, rewards and achievements.
local D=require('achievement_quest_sunderock_data')
local B=require('achievement_quest_blightfire')
local A=require('sunderock_acquisition')
local M={}
local function yes(v)return v==true or v==1 end
local function active(c,id)return yes(c:IsTaskActive(id))end
local function appropriate(c,t,n)
 if not t or not t.enabled or active(c,t.id)or c:GetLevel()<t.min_level then return false end
 if not t.repeatable and yes(c:IsTaskCompleted(t.id))then return false end
 if t.conditional_repeat_after and yes(c:IsTaskCompleted(t.id))and not yes(c:IsTaskCompleted(t.conditional_repeat_after))then return false end
 if t.entry and t.entry.kind=='loot-offer'and c:CountItem(t.entry.item)<1 then return false end
 if t.cycle_stage and t.cycle_stage~=M.cycle(c)then return false end
 for _,id in ipairs(t.prerequisites)do if not yes(c:IsTaskCompleted(id))then return false end end
 if not yes(eq.is_task_appropriate(t.id))then return false end
 if n and n.valid then
  local faction=c:GetFactionLevel(c:CharacterID(),n:GetNPCTypeID(),c:GetBaseRace(),c:GetClass(),c:GetDeity(),n:GetPrimaryFaction(),n)
  if faction>=Faction.Threatenly then return false end
 end
 return true
end
function M.cycle(c)
 local v=tonumber(c:GetBucket('achievement.may2013.sunderock.springs_cycle'))
 if v and v==math.floor(v)and v>=1 and v<=4 then return v end
 for i,id in ipairs(D.springs_cycle)do if not yes(c:IsTaskCompleted(id))then return i end end
 return 1
end
function M.complete(e)
 if not D.enabled then return end
 local t=D.tasks[e.task_id]
 if t and t.cycle_stage then e.self:SetBucket('achievement.may2013.sunderock.springs_cycle',tostring(t.cycle_stage==4 and 1 or t.cycle_stage+1))end
 A.resume(e)
end
function M.say(e)
 if not D.enabled then return false end
 local choices=D.givers[e.self:GetNPCTypeID()];if not choices then return false end
 local text=e.message:lower();local wanted=false
 for _,word in ipairs(D.keywords[e.self:GetNPCTypeID()]or{'hail','help','task'})do if text:find(word,1,true)then wanted=true;break end end
 if not wanted then return false end
 local offer={}
 for _,id in ipairs(choices)do if appropriate(e.other,D.tasks[id],e.self)then offer[#offer+1]=id end end
 if #offer>0 then eq.task_selector(offer)end
 return true
end
function M.prepare_board(e)
 -- Extend the existing board's data, then let its original callback build one
 -- combined selector. Never replace its earlier quests or open two selectors.
 if eq.get_zone_id()~=395 or e.door:GetDoorID()~=47 then return end
 local board=require('achievement_quest_blightfire_data')
 local sign=board.signs[47]
 if not sign or sign.npc~=395002 then return end
 local id=3040701;local present=false
 for _,v in ipairs(sign.tasks)do if v==id then present=true;break end end
 if not present then sign.tasks[#sign.tasks+1]=id end
 board.tasks[id]=D.enabled and appropriate(e.self,D.tasks[id])and{prerequisites={}}or nil
end
function M.trade(e)
 if not D.enabled or not D.givers[e.self:GetNPCTypeID()]then return false end
 -- Core marks exact GetTaskDeliveredCount before invoking this callback.
 -- Existing helper consumes that marked amount and returns all other custody.
 B.trade(e)
 return true
end
-- Entry adapters, geometry, egg pre-loot admission and pod actors must be
-- installed together before enabling D. No hail replacement for acquisition.
M.resume=A.resume
M.pickup=A.pickup
M.loot=A.loot
M.timer=A.timer
M.actor_spawn=A.actor_spawn
M.actor_timer=A.actor_timer
M.pod_death=A.pod_death
return M
