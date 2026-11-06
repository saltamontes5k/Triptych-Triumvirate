-- Call only from a subsequently verified qualifying primer/training interaction.
-- This helper does not establish that a primer was read or bind any callback.
local D=require('achievement_alaran_master_data')
local M={}
function M.credit(c)
 if not D.enabled then return false,'disabled' end
 if not D.trigger_verified then return false,'trigger_unbound' end
 if type(D.progress_value)~='number'or D.progress_value<1 or D.progress_value>4294967295 or D.progress_value~=math.floor(D.progress_value)or D.required_count~=D.progress_value then return false,'representation_unbound' end
 if not c or not c.valid then return false,'invalid_client' end
 local actual=c:GetLanguageSkill(D.language_id)
 if type(actual)~='number'or actual~=math.floor(actual)or actual<D.language_required then return false,'below_language_threshold' end
 -- Existing absolute setter: no class SkillValue25, language training, item
 -- consumption, task completion or direct completion of optional components.
 local result=c:SetAchievementProgress(D.achievement_id,D.component_type,D.component_id,D.progress_value,false)
 -- A true return can be a deferred RAM update. It is not a durable receipt.
 return result==true or result==1,'existing_setter_result'
end
-- Proposed combined family: only the existing Words training branch supplies
-- prior proficiency. No login, already100 reconciliation or optional-task credit.
function M.credit_training(c,prior)
 if not D.enabled then return false,'disabled' end
 if not D.trigger_verified then return false,'trigger_unbound' end
 if not c or not c.valid then return false,'invalid_client' end
 if type(prior)~='number'or prior~=math.floor(prior)or prior<0 or prior>=100 then return false,'invalid_prior_training_skill' end
 local actual=c:GetLanguageSkill(D.language_id)
 if type(actual)~='number'or actual~=math.floor(actual)or actual<prior or actual>100 then return false,'invalid_training_readback' end
 if actual==prior then return false,'no_training_gain' end
 local attempted,accepted=0,true
 for _,row in ipairs(D.siblings)do
  if prior<row.threshold and actual>=row.threshold then
   local result=c:SetAchievementProgress(row.achievement_id,1,row.component_id,1,false)
   attempted=attempted+1
   if result~=true and result~=1 then accepted=false end
  end
 end
 if prior<D.language_required and actual>=D.language_required then
  -- Reuse existing Master guard/setter; its separate9342 criterion is unchanged.
  local result=M.credit(c)
  attempted=attempted+1
  if not result then accepted=false end
 end
 -- Absolute setters allow retries without incrementing counters. Accepted may
 -- still mean deferred RAM work, never persisted SQL or reward acknowledgement.
 return attempted>0 and accepted,'existing_setter_results'
end
return M
