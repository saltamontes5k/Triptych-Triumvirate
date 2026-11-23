local key_tasks = require("rof2_dodh_public_key_tasks")

local function legacy_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("Hello, most honored guest. I hope all is going well with you and that everything here is to your satisfaction.");
	end
end

function event_say(e)
    legacy_say(e)
    key_tasks.doorman(e)
end
