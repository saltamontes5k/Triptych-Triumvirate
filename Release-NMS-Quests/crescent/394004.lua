-- Preserve the stock Anarynn greeting while consuming only native task hand-ins.
local M=require("achievement_quest_blightfire")
function event_say(e)
 if e.message:lower():find('hail',1,true) then
  e.self:Say('Hello, '..e.other:GetCleanName()..'.  Are you just passing through the Reach as well?')
 end
end
function event_trade(e)M.trade(e)end
