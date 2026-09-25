-- rage/374016.lua - #The_Subjugant (Sverag, Stronghold of Rage)
-- Prophecy of Ro: "Become the Vessel" (task 3002).
--
-- PRIMARY PATH: rage/player.lua drives the two "sit before the tower door"
-- steps - equip the five Enraged Flesh pieces, sit within ~30 units of the
-- Sverag -> Razorthorn door (OBJ_RAGE_TOWERSWITCHA, x -0.06 y 80 z 31.7) for
-- five minutes, vent your rage on the stronghold (kill 60), then sit again.
--
-- FALLBACK: if the proximity/sit check cannot be satisfied (wrong spot,
-- geometry, a client that does not report sitting correctly), the Subjugant
-- offers a deterministic alternative. Hail it while wearing all five Enraged
-- Flesh pieces and it completes the current sit step, once per step.
-- See docs/por-enraged-flesh-charm.md.
local por = require("por_helper");

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

function event_say(e)
	local t = e.message:lower();

	if not (t:find("hail") or t:find("vessel") or t:find("rage") or t:find("judg")) then
		return;
	end

	local c = e.other;

	if not c:IsTaskActive(por.tasks.become_the_vessel) then
		e.self:Say("Only a Vessel of Rage may stand before me.");
		return;
	end

	if not wearing_armor(c) then
		e.self:Say("You are not clad in the trappings of rage. Return when you wear the full suit of Enraged Flesh.");
		return;
	end

	local sit1  = eq.get_task_activity_done_count(por.tasks.become_the_vessel, por.activity.vessel_sit1);
	local kills = eq.get_task_activity_done_count(por.tasks.become_the_vessel, por.activity.vessel_kill);
	local sit2  = eq.get_task_activity_done_count(por.tasks.become_the_vessel, por.activity.vessel_sit2);

	if sit1 == 0 then
		c:UpdateTaskActivity(por.tasks.become_the_vessel, por.activity.vessel_sit1, 1);
		e.self:Say("You have knelt before the tower. I receive your supplication and the rage begins to fill you.");
	elseif kills < 60 then
		e.self:Say("The rage has entered you, but you have not spent it. Kill within the stronghold until it is spent, then return to me.");
	elseif sit2 == 0 then
		c:UpdateTaskActivity(por.tasks.become_the_vessel, por.activity.vessel_sit2, 1);
		e.self:Say("You return, still armored in rage. The judgement is passed.");
	else
		e.self:Say("You have become the Vessel. Return to Grand Librarian Maelin and claim the Enraged Flesh Charm.");
	end
end
