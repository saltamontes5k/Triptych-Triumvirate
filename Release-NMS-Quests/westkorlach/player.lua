-- westkorlach/player.lua
-- Depths of Darkhollow: Stoneroot Falls zone-wide player hooks.
--
-- "The Search for Savil" (task 505789) is the survey trail of Researcher
-- Briznek's lost assistant.  The ten proximity ("update") activities each hand
-- the player one page of Assistant Savil's Field Book when they complete; the
-- empty 10-slot book (85051) is handed out by #Researcher_Briznek.
--    activity_id 0..9  -> page items 85041..85050
--    activity_id 10    -> deliver the restored book (no page)
-- Recipe 938055 combines the ten pages into Assistant Savil's Restored Field
-- Book (85053).  See utils/sql/20261016_dodh_stoneroot_briznek.sql.

local SEARCH_TASK = 505789;
local FIRST_PAGE  = 85041;

function event_task_stage_complete(e)
	if e.task_id ~= SEARCH_TASK then
		return;
	end

	if e.activity_id < 0 or e.activity_id > 9 then
		return;
	end

	local page = FIRST_PAGE + e.activity_id;
	if e.self:GetInventory():HasItem(page) == -1 then
		e.self:SummonFixedItem(page);
		e.self:Message(15, "You recover a waterlogged page of Assistant Savil's field notes.");
	end
end
