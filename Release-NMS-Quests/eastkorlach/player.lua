-- eastkorlach/player.lua
-- Player-side task hooks for the Undershore (Depths of Darkhollow).
--   * 505790 Investigate the Tomb of Emperor Illsalin -> grants 505791
--   * 505792 Dark Prophecy -> grants a measure of AA on completion
-- Task data: utils/sql/20261016_dodh_undershore_vestiges.sql

local INVESTIGATE   = 505790;
local VESTIGES      = 505791;
local DARK_PROPHECY = 505792;

function event_task_stage_complete(e)
	local c = e.self;

	if e.task_id == INVESTIGATE then
		if not c:IsTaskActive(VESTIGES) and not c:IsTaskCompleted(VESTIGES) then
			c:AssignTask(VESTIGES);
			c:Message(MT.Yellow, "The Tomb of Emperor Illsalin opens before you. Brother Learned Hand ought to hear of this.");
		end
	elseif e.task_id == DARK_PROPHECY then
		c:AddAAPoints(1);
		c:Message(MT.Yellow, "The dark prophecy unfolds before you, and a sliver of its power remains with you.");
	end
end
