-- Frostfell (2007): Father Frostheart - Gemmi Goodkin boss
local FF = require("frostfell")

function event_death(e)
	local c = FF.killer(e)
	if c then
		FF.upd(c, FF.TASK.GEMMI, 2, 1)
	end
end
