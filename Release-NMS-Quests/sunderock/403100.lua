-- Preserve prior handlers; core owns actual delivery and task progression.
local vergalid_previous_say=event_say
function event_say(e)
 if vergalid_previous_say then local r=vergalid_previous_say(e);if r and r~=0 then return r end end
 return require('achievement_quest_vergalid').say(e)
end
local vergalid_previous_trade=event_trade
function event_trade(e)
 if vergalid_previous_trade then local r=vergalid_previous_trade(e);if r and r~=0 then return r end end
 return require('achievement_quest_vergalid').trade(e)
end
local vergalid_previous_task_accepted=event_task_accepted
function event_task_accepted(e)
 if vergalid_previous_task_accepted then local r=vergalid_previous_task_accepted(e);if r and r~=0 then return r end end
 return require('achievement_quest_vergalid').accepted(e)
end
