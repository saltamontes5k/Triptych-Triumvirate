-- eastkorlach/Brother_Nine_Stones.lua
-- Depths of Darkhollow: Dark Prophecy (Undershore).
--   505792 Dark Prophecy -- a proximity step at Jarzarrad the Prophet; the AA
--   is granted by player.lua on completion.
-- Tasks/activities live in utils/sql/20261016_dodh_undershore_vestiges.sql.

local DARK_PROPHECY = 505792;

function event_say(e)
	if not e.message:lower():find("hail") then
		return;
	end

	local c = e.other;

	if c:IsTaskActive(DARK_PROPHECY) then
		e.self:Say("Jarzarrad waits not far from here, near the great coral. Seek him out, and hear what the depths have shown him.");
	elseif c:IsTaskCompleted(DARK_PROPHECY) then
		e.self:Say("The prophecy has been read, and its weight now rests on your shoulders. Walk carefully.");
	else
		e.self:Say("The Nine have seen a [dark prophecy] written in the bones of Illsalin. Find Jarzarrad the Prophet and learn what he has foreseen.");
		c:AssignTask(DARK_PROPHECY, e.self:GetID());
	end
end
