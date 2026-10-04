-- Scout Clockwork Arakyd (447039) -- SoF faction task
-- "The Steamwork You're Looking For" (300026).
-- Hand-written flavor: the Fuzzlecutter Motivator 5000 handed in here is
-- consumed by the task system's deliver step; anything else is returned.

local MOTIVATOR = 36244

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Ssshh! Recon patrol for the Strike Force. It is not wise to wander these floors without a reason.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if e.trade:HasItem(MOTIVATOR) > 0 then
		e.self:Say("The Motivator 5000! At last. Now I can get this rustbucket moving again. Give Overvolt my regards.")
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
