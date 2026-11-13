-- Original journal opening and seven-page assembly; native tasks own progress,
-- tradeskill output, reward delivery and persistence. No inventory pre-credit.
local M={task_id=3040320,recipe_id=3040320,journal_id=54639}
local function yes(v)return v==true or v==1 end
function M.open(e)
 local c=e.self
 if e.item_id~=M.journal_id or not c or not c.valid then return end
 local slot=tonumber(e.slot_id)
 -- Use server-published slot constants, never client slot guesses.
 if not slot or slot<Slot.General1 or slot>Slot.General10 or c:GetItemIDAt(slot)~=M.journal_id then return end
 if yes(c:IsTaskActive(M.task_id)) then return end
 -- The native assignment enforces the configured level and repeatability.
 -- The original task starts on opening, with no NPC offer or fabricated loot.
 c:AssignTask(M.task_id,c:GetID(),true)
end
function M.validate(e)
 if e.recipe_id~=M.recipe_id then return 0 end
 local c=e.self
 -- Refuse before ingredient consumption unless all seven actual loot goals
 -- have completed and the native assembly objective has become active.
 if not c or not c.valid or not yes(c:IsTaskActive(M.task_id)) or
    not yes(c:IsTaskActivityActive(M.task_id,7)) then
  if c and c.valid then c:Message(13,'Open the journal and complete its seven page objectives before assembling it.')end
  return 1
 end
 return 0
end
return M
