-- rage/player.lua - Sverag, Stronghold of Rage (zone 374)
-- Prophecy of Ro: "Become the Vessel" (task 3002). Restores the sit-at-the-tower
-- choreography: with all five Enraged Flesh pieces equipped, sit at the foot of
-- the tower (near the Razorthorn door) for five minutes, vent your rage upon the
-- stronghold, then sit before the door a second time for judgement.
--
-- Activities 1 and 2 of task 3002 are script-driven here (they are authored with
-- an impossible npc match so the task system never auto-completes them).
local por = require("por_helper");

local DOOR_X, DOOR_Y, DOOR_Z = -0.06, 80.01, 31.73; -- OBJ_RAGE_TOWERSWITCHA
local RADIUS       = 30.0;
local TICK_MS      = 3000;
local TICKS_NEEDED = 100; -- 100 * 3s = 5 minutes

-- equipment slot -> Enraged Flesh piece
local equipped = {
	[2]  = 88095, -- head  - Enraged Flesh Cap
	[7]  = 88096, -- arms  - Enraged Flesh Sleeves
	[12] = 88097, -- hands - Enraged Flesh Gloves
	[17] = 88093, -- chest - Enraged Flesh Tunic
	[18] = 88094, -- legs  - Enraged Flesh Leggings
};

local function wearing_armor(c)
	for slot, item_id in pairs(equipped) do
		if (c:GetItemIDAt(slot) % 1000000) ~= item_id then
			return false;
		end
	end
	return true;
end

local function at_tower(c)
	return c:CalculateDistance(DOOR_X, DOOR_Y, DOOR_Z) <= RADIUS;
end

function event_enter_zone(e)
	if e.self:IsTaskActive(por.tasks.become_the_vessel) then
		eq.set_timer("por_vessel", TICK_MS);
	end
end

function event_timer(e)
	if e.timer ~= "por_vessel" then
		return;
	end

	local c = e.self;
	local task = por.tasks.become_the_vessel;

	if not c:IsTaskActive(task) then
		eq.stop_timer("por_vessel");
		c:SetBucket("por.vessel_sit", "0");
		return;
	end

	local sit1  = eq.get_task_activity_done_count(task, por.activity.vessel_sit1);
	local kills = eq.get_task_activity_done_count(task, por.activity.vessel_kill);
	local sit2  = eq.get_task_activity_done_count(task, por.activity.vessel_sit2);

	local activity;
	if sit1 == 0 then
		activity = por.activity.vessel_sit1;
	elseif kills < 60 then
		c:SetBucket("por.vessel_sit", "0");
		return; -- the second sit is offered only once the rage has been vented
	elseif sit2 == 0 then
		activity = por.activity.vessel_sit2;
	else
		eq.stop_timer("por_vessel");
		c:SetBucket("por.vessel_sit", "0");
		return;
	end

	if not at_tower(c) or not c:IsSitting() or not wearing_armor(c) then
		c:SetBucket("por.vessel_sit", "0");
		return;
	end

	local ticks = (tonumber(c:GetBucket("por.vessel_sit")) or 0) + 1;
	if ticks >= TICKS_NEEDED then
		c:SetBucket("por.vessel_sit", "0");
		c:UpdateTaskActivity(task, activity, 1);
		c:Message(15, "You sense the presence of rage as it seeps into you. You have become the Vessel of Rage.");
		eq.zone_emote(MT.Yellow, string.format("%s has become the Vessel of Rage.", c:GetName()));
	else
		if ticks % 20 == 0 then
			c:Message(15, "You sense the presence of rage as it seeps into you...");
		end
		c:SetBucket("por.vessel_sit", tostring(ticks));
	end
end
