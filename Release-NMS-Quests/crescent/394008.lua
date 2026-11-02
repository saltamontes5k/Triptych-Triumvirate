local quests = require("achievement_quest_npcs")
function event_say(e) quests.say(e) end
function event_trade(e) quests.trade(e) end
function event_task_accepted(e) quests.accepted(e) end
