-- takishruins/376081.lua - Krylin
-- Prophecy of Ro: opens the Root of Ro instance for "The Key to the Past".
local por = require("por_helper");

function event_say(e)
	local t = e.message:lower();
	if t:find("hail") then
		e.self:Say("The ruins remember, even if the living do not. Are you here for the [Root of Ro]? The way is treacherous, but I can open it.");
	elseif t:find("root of ro") or t:find("root") or t:find("open") or t:find("ready") or t:find("enter") then
		if por.enter(e.other, "takishruinsa", "The Root of Ro", 1, 6, "6h") then
			e.self:Say("The sands part. Recover the fragments of the old tablet, and do not linger overlong.");
		end
	end
end
