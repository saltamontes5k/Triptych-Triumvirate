-- Moors (Blightfire) zone player script.
-- RoF2 zone quest lines (job board, welcome, spirits, champion, bixies) plus the
-- NMS King of the Monsters moors-v40 monster mission hooks, ported here from the
-- retired player.pl so the single lua player script owns every player event in
-- this zone. Requires the lua GetZoneInstanceVersion client binding.
local blightfire = require("achievement_quest_blightfire")
local bixie_scenes = require("achievement_quest_bixie_scenes")
local spirits = require("achievement_quest_blightfire_spirits")
local welcome = require("achievement_quest_blightfire_welcome")
local champion = require("achievement_quest_blightfire_champion")
-- The Stone Hive chain starts from moors givers (Vreshnar/Brezuu/Idriak);
-- run its task bookkeeping here too so accepts in this zone stay in sync.
local stonehive = require("achievement_quest_stonehive")

-- NMS: Old Man McKenzie's King of the Monsters (moors v40 monster mission).
-- The task (800005) tracks the six devour-per-color activities;
-- #King_of_the_Monsters_Controller.lua runs the shroud/prey/fail state machine
-- and listens for these signals. Version 0 Blightfire Moors is untouched.
local hunt_task_id    = 800005
local hunt_version    = 40
local hunt_controller = 1520001970

function event_click_door(e)
	local result = blightfire.click_door(e)
	if result ~= nil then return result end
	result = bixie_scenes.click_door(e)
	if result ~= nil then return result end
	return spirits.click_door(e)
end

function event_enter_zone(e)
	bixie_scenes.player_enter(e)
	welcome.player_event(e)
end

function event_task_accepted(e)
	welcome.player_accepted(e)
	champion.player(e)
	stonehive.accepted(e)
end

function event_task_stage_complete(e)
	welcome.player_event(e)
end

function event_task_complete(e)
	-- NMS King of the Monsters completion signal.
	if e.self:GetZoneInstanceVersion() == hunt_version and e.task_id == hunt_task_id then
		quest.signal(hunt_controller, 1)
	end
	blightfire.task_complete(e)
	welcome.task_complete(e)
	champion.complete(e)
end

function event_timer(e)
	if bixie_scenes.player_timer(e) then return end
	welcome.player_timer(e)
end

function event_signal(e)
	bixie_scenes.player_signal(e)
end

function event_death(e)
	-- NMS: silent unshroud so the bind release wakes the real character; no
	-- packets here (client is on the death UI). global_player.pl is the safety
	-- net for any other exit path.
	if e.self:GetZoneInstanceVersion() == hunt_version then
		e.self:RemoveShroudSilent()
		quest.signal(hunt_controller, 2)
	end
end
