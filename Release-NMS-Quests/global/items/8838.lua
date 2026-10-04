-- global/items/8838.lua -- Clockwork Key (36445, "a key with movable
-- teeth"). Right-click slides the currently adjusted tooth; waiting six
-- seconds between slides advances to the next tooth. When all eight
-- teeth match, click the Mansion door in Fortress Mechanotus.
local prog = require("sof_progression")

function event_item_click(e)
	if e.owner == nil then
		return
	end
	prog.lock_slide(e.owner)
end
