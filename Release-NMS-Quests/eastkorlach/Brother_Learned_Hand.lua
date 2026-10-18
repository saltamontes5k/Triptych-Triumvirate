-- eastkorlach/Brother_Learned_Hand.lua
-- Depths of Darkhollow: Vestiges of the Empire (Undershore).
--   505790 Investigate the Tomb of Emperor Illsalin (given here)
--   505791 Vestiges of the Empire (granted by player.lua once 505790 completes)
-- Tasks/activities live in utils/sql/20261016_dodh_undershore_vestiges.sql.

local INVESTIGATE = 505790;
local VESTIGES    = 505791;

function event_say(e)
	if not e.message:lower():find("hail") then
		return;
	end

	local c = e.other;

	if c:IsTaskActive(VESTIGES) then
		e.self:Say("Five gemstones were buried with the emperors of Illsalin. Recover them all and deliver them to the [Tomb], and the Shattered Blade will be made whole again.");
	elseif c:IsTaskCompleted(VESTIGES) then
		e.self:Say("The Shattered Blade is forged anew in your hands. Wear it well, for the Undershore remembers its dead.");
	elseif c:IsTaskActive(INVESTIGATE) then
		e.self:Say("Walk the western shore and find the [Tomb] of Emperor Illsalin. You will know it when you stand before it.");
	else
		e.self:Say("The emperors of old Illsalin were laid to rest along the Undershore, but their [Tomb] has been lost to the mists. Find it, and we will speak of the gemstones within.");
		c:AssignTask(INVESTIGATE, e.self:GetID());
	end
end
