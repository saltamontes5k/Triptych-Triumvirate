-- arcstone/369085.lua - Or`Sarro the Youngest
-- Prophecy of Ro: opens the Daosheen the Firstborn raid (Skylance chamber).
-- The raid now requires the "Entrance to Daosheen's Chamber" key (task 3379):
-- once Sarcrynn holds all four components, Or`Sarro awards the Crystals of the
-- Firstborn and the way is opened.
local por = require("por_helper");

local function has_chamber_key(c)
	return c:HasItem(por.items.crystals_of_the_firstborn)
		or (tonumber(c:GetBucket("por.daosheen_key")) or 0) == 1;
end

function event_say(e)
	local t = e.message:lower();
	if t:find("hail") then
		if e.other:IsTaskCompleted(por.tasks.entrance_to_daosheen_chamber) and not has_chamber_key(e.other) then
			e.other:SetBucket("por.daosheen_key", "1");
			e.other:SummonFixedItem(por.items.crystals_of_the_firstborn);
			e.self:Say("Excellent work, my friend. While you were away I recovered this scroll. I am not sure what it proves beyond Daosheen's obvious insanity, but it may offer clues to what he has been building in his study all these years. With your help, Daosheen's reign of madness will soon come to an end.");
			e.other:Message(15, "You have been given: Crystals of the Firstborn. You can now request the Daosheen the Firstborn raid.");
			return;
		end
		e.self:Say("Daosheen the Firstborn has sealed himself within Skylance, and his madness grows. Only the daring would face him. Shall I open the [way]?");
	elseif t:find("daosheen") or t:find("firstborn") or t:find("raid") or t:find("the way") or t:find("way") or t:find("enter") then
		if not has_chamber_key(e.other) then
			e.self:Say("You cannot breach the seal on Daosheen's chamber. Speak with Apprentice Mage Sarcrynn; he knows how the seal may be weakened.");
			return;
		end
		if por.enter(e.other, "skylance", "Daosheen the Firstborn", 1, 54, "6h") then
			e.self:Say("Steel yourself. The Firstborn does not suffer intruders lightly.");
		end
	end
end
