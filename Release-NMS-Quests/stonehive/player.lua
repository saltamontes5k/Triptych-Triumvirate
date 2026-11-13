-- Stone Hive zone player script: the reconstruction's pickup/scene wiring
-- (global-player-stonehive fragment, placed zone-local so it cannot shadow the
-- perl global layer).
-- rof2b additions (2026-11-05): the Short Sharp Sting partisan task events and
-- the bixie journal item click / combine validation (sting recipients and the
-- journal combines both live in this zone).
local stonehive = require('achievement_quest_stonehive')
local sting = require('achievement_quest_sting')
local journal = require('achievement_quest_bixie_journal')

function event_player_pickup(e)
	stonehive.pickup(e)
end

function event_task_accepted(e)
	stonehive.accepted(e)
	sting.accepted(e)
end

function event_task_update(e)
	sting.updated(e)
end

function event_task_complete(e)
	stonehive.complete(e)
end

function event_enter_zone(e)
	stonehive.enter(e)
	sting.enter(e)
end

function event_task_fail(e)
	stonehive.failed(e)
end

function event_timer(e)
	if sting.timer(e) then return end
	stonehive.timer(e)
end

function event_item_click_client(e)
	journal.open(e)
end

function event_combine_validate(e)
	return journal.validate(e)
end
