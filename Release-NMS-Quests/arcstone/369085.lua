-- arcstone/369085.lua - Or`Sarro the Youngest
-- Prophecy of Ro: opens the Daosheen the Firstborn raid (Skylance chamber).
local por = require("por_helper");

function event_say(e)
	local t = e.message:lower();
	if t:find("hail") then
		e.self:Say("Daosheen the Firstborn has sealed himself within Skylance, and his madness grows. Only the daring would face him. Shall I open the [way]?");
	elseif t:find("daosheen") or t:find("firstborn") or t:find("raid") or t:find("the way") or t:find("way") or t:find("enter") then
		if por.enter(e.other, "skylance", "Daosheen the Firstborn", 1, 54, "6h") then
			e.self:Say("Steel yourself. The Firstborn does not suffer intruders lightly.");
		end
	end
end
