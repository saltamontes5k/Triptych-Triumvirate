-- global/items/72200.lua -- Explosive Device (You Might Poke an Eye Out,
-- 301109). Ground caches supply them; the placement is tracked by the
-- mission's explore steps. Click = flavor + guidance.

function event_item_click(e)
	if e.owner == nil then return end
	if e.owner:IsTaskActive(301109) then
		e.owner:Message(15, "Plant your bombs: the basement core, the mid-floor pipes, and the roof catapult. The caches will not move.")
	else
		e.owner:Message(15, "An armed explosive. Best not to fidget with it.")
	end
end
