-- Goru'kar Mesa zone player script: the reconstruction's scene, wand and
-- resource wiring (module handlers, placed zone-local so it cannot shadow the
-- perl global layer).
-- rof2b additions (2026-11-05): the mesa-remaining batch (love/tudor/defense/
-- observations/escort/crafting), the centaur corruption before-update hook and
-- the Ekaterina save-the-queen player chain, composed into the base handlers.
local mesa = require('achievement_quest_mesa')
local love = require('achievement_quest_mesa_love')
local tudor = require('achievement_quest_mesa_tudor')
local defense = require('achievement_quest_mesa_defense')
local observations = require('achievement_quest_mesa_observations')
local escort = require('achievement_quest_mesa_escort')
local crafting = require('achievement_quest_mesa_crafting')
local centaur = require('achievement_quest_mesa_centaur')
local queen = require('achievement_quest_mesa_queen')

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
	love.enter(e)
	tudor.resume(e)
	defense.resume(e)
	observations.resume(e)
	escort.resume(e)
	queen.resume(e)
end

function event_task_accepted(e)
	mesa.accepted(e)
	love.accepted(e)
	tudor.resume(e)
	defense.resume(e)
	observations.resume(e)
	escort.resume(e)
	queen.accepted(e)
end

function event_task_complete(e)
	mesa.complete(e)
	love.complete(e)
	queen.resume(e)
end

function event_task_stage_complete(e)
	tudor.resume(e)
	defense.resume(e)
	observations.resume(e)
	escort.resume(e)
end

function event_task_fail(e)
	mesa.failed(e)
	defense.failed(e)
	escort.failed(e)
	queen.resume(e)
end

function event_task_before_update(e)
	local escort_result = escort.before_update(e)
	if escort_result ~= 0 then return escort_result end
	local crafting_result = crafting.before_update(e)
	if crafting_result ~= 0 and crafting_result ~= nil then return crafting_result end
	local centaur_result = centaur.before_update(e)
	if centaur_result ~= 0 and centaur_result ~= nil then return centaur_result end
	return queen.before_update(e)
end

function event_timer(e)
	mesa.timer(e)
	if love.timer(e) then return end
	if defense.client_timer(e) then return end
	if observations.timer(e) then return end
	if escort.client_timer(e) then return end
	tudor.timer(e)
	if queen.timer(e) then return end
end

function event_death(e)
	mesa.death(e)
end

function event_death_complete(e)
	defense.player_death(e)
	escort.player_death(e)
end
