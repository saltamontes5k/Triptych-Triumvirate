-- Centaur Troubles: ordinary native task producers own all objective credit.
-- Historical evidence and unresolved admission/faction values accompany this module.
local D=require('achievement_quest_mesa_corruption_data')
local M={}
local first,last=3040461,3040464
local function yes(v)return v==true or v==1 end
local function active(c,t)return yes(c:IsTaskActive(t))end
local function appropriate(c,t)
 if active(c,t)or not yes(eq.is_task_appropriate(t))then return false end
 if t>first and not yes(c:IsTaskCompleted(t-1))then return false end
 -- Prevent parallel acceptance of later/repeated stages in this one chain.
 for id=first,last do if active(c,id)then return false end end
 return true
end
function M.say(e)
 if not D.enabled or eq.get_zone_id()~=397 then return false end
 local npc=e.self:GetNPCTypeID()
 local text=e.message:lower()
 if npc==397007 then
  if text:find('hail',1,true)or text:find('unusual folk',1,true)or text:find('wits',1,true)or text:find('tasks',1,true)or text:find('difficult',1,true)then
   e.self:Say('I am also concerned about the '..eq.say_link('centaur')..' to the northwest. A smaller camp may know what has happened.')
   return false -- Preserve the existing armor/Dromrek dialogue and selectors.
  end
  if not(text:find('centaur',1,true)or text:find('see what',1,true))then return false end
  e.self:Say('A small centaur camp lies south of the main encampment. Investigate their troubles if you are willing.')
  if appropriate(e.other,first)then eq.task_selector({first})end
  return true
 end
 if npc~=397149 then return false end
 if text:find('hail',1,true)then
  -- SpeakWith objectives update through the native engine after this callback.
  -- Offer the next task only on a subsequent explicit keyword, after completion.
  local c=e.other
  local function ready(t,a)return yes(c:IsTaskActivityActive(t,a))end
  local function link(word)return eq.say_link(word)end
  if active(c,3040464)then
   e.self:Say(ready(3040464,1)and'My brothers are safe. Thank you for helping the centaur.'or'The source of the corruption still threatens my brothers. Please '..link('kill the shade')..'.')
  elseif active(c,3040463)then
   e.self:Say(ready(3040463,4)and('A shade is responsible? Please '..link('kill the shade')..' to free my brothers.')or'Investigate the camp and find what has made my brothers so aggressive.')
  elseif active(c,3040462)then
   e.self:Say(ready(3040462,1)and('You have reduced the danger. Will you do some '..link('research')..'?')or'The corrupted centaur still threaten the camp. Reduce their numbers, then return.')
  elseif active(c,3040461)then
   e.self:Say(ready(3040461,5)and('You have shown that I can '..link('trust')..' you.')or('First '..link('prove')..' that you can help us. Complete the tasks I have requested.'))
  elseif yes(c:IsTaskCompleted(3040463))then
   e.self:Say('If the corruption has returned, will you '..link('kill the shade')..'?')
  elseif yes(c:IsTaskCompleted(3040462))then
   e.self:Say('Will you do some '..link('research')..' into what troubles my brothers?')
  elseif yes(c:IsTaskCompleted(3040461))then
   e.self:Say('You have earned my '..link('trust')..'. Are you '..link('willing')..' to help my brothers?')
  else
   e.self:Say('My heart is heavy. Speak with Scout Madu, then '..link('prove')..' that you can help us.')
  end
  return true
 end
 local wanted
 if text:find('prove',1,true)or text:find('heavy',1,true)or text:find('%f[%a]search%f[%A]')then
  e.self:Say('First investigate our camp for Scout Madu. Defeat the widows, snakes and harpies requested in your task, then return to me.')
 elseif text:find('kill the shade',1,true)then wanted=3040464
 elseif text:find('research',1,true)then wanted=3040463
 elseif text:find('trust',1,true)or text:find('happened',1,true)or text:find('willing',1,true)then wanted=3040462
 end
 if wanted and appropriate(e.other,wanted)then eq.task_selector({wanted})end
 return true
end
function M.before_update(e)
 if eq.get_zone_id()~=397 or e.task_id~=3040462 or e.activity_id~=0 then return 0 end
 -- Period Apr/Sep2012 reports: friendly centaurs with the Shade absent do not count.
 for shade in eq.get_entity_list():GetNPCList().entries do
  if shade.valid and shade:GetNPCTypeID()==397196 and shade:GetSpawnPointID()==112270 and shade:GetHP()>0 and not shade:IsPet()then return 0 end
 end
 return 1
end
return M
