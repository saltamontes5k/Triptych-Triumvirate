-- Stone Hive zone player script: the reconstruction's pickup/scene wiring
-- (global-player-stonehive fragment, placed zone-local so it cannot shadow the
-- perl global layer).
local stonehive = require('achievement_quest_stonehive')

function event_player_pickup(e)
	stonehive.pickup(e)
end

function event_task_accepted(e)
	stonehive.accepted(e)
end

function event_task_complete(e)
	stonehive.complete(e)
end

function event_enter_zone(e)
	stonehive.enter(e)
end

function event_timer(e)
	stonehive.timer(e)
end

function event_task_fail(e)
	stonehive.failed(e)
end
