-- Candidate native-task routing; the core owns all kill, loot and delivery credit.
local D=require('achievement_quest_mesa_remaining_data')
local B=require('achievement_quest_blightfire')
local M={}
local function yes(v)return v==true or v==1 end
local function appropriate(c,t,n)
 if #t.missing_dependencies>0 or yes(c:IsTaskActive(t.id)) or not yes(eq.is_task_appropriate(t.id))then return false end
 for _,id in ipairs(t.offer_exclusions)do if yes(c:IsTaskActive(id))then return false end end
 local f=c:GetFactionLevel(c:CharacterID(),n:GetNPCTypeID(),c:GetBaseRace(),c:GetClass(),c:GetDeity(),n:GetPrimaryFaction(),n)
 if f>=Faction.Threatenly or (t.minimum_faction>0 and f>t.minimum_faction)then return false end
 return true
end
local armor_words={forearms=3040421,feet=3040422,hands=3040423,head=3040424,arms=3040425,legs=3040426,torso=3040427}
function M.say(e)
 if eq.get_zone_id()~=397 then return false end
 local n=e.self:GetNPCTypeID();local text=e.message:lower();local armor=n==397007
 if armor then
  local id=armor_words[text:match('^%s*(.-)%s*[?.!]*$')]
  if id then
   if appropriate(e.other,D[id],e.self)then eq.task_selector({id})end
   return true
  end
  if not text:find('extra armor',1,true)then return false end
 elseif n~=397043 and n~=397097 and n~=397096 then return false end
 local wanted=armor or text:find('hail',1,true)or text:find('help',1,true)or text:find('protect',1,true)or text:find('task',1,true)
 if not wanted then return true end
 local choices={}
 for id,t in pairs(D)do if t.giver==n and appropriate(e.other,t,e.self)then choices[#choices+1]=id end end
 table.sort(choices)
 if #choices>0 then eq.task_selector(choices)end
 return true
end
function M.trade(e)B.trade(e)end
return M
