-- Goru'kar Mesa zone player script: the reconstruction's scene, wand and
-- resource wiring (module handlers, placed zone-local so it cannot shadow the
-- perl global layer).
local mesa = require('achievement_quest_mesa')

function event_click_door(e)
	local result = mesa.click_door(e)
	if result ~= nil then return result end
end

function event_click_object(e)
	local result = mesa.click_object(e)
	if result ~= nil then return result end
end

function event_enter_zone(e)
	mesa.enter(e)
end

function event_task_accepted(e)
	mesa.accepted(e)
end

function event_task_complete(e)
	mesa.complete(e)
end

function event_task_fail(e)
	mesa.failed(e)
end

function event_timer(e)
	mesa.timer(e)
end

function event_death(e)
	mesa.death(e)
end
