-- arcstone/369034.lua - an Eye of Zomm
-- Zomm the Seventh Born (369036) is ringed by nine eyes. When one is destroyed
-- it reports its own entity id to Zomm, which decides whether that wounds him
-- or merely reforms the eye (see arcstone/369036.lua).
local ZOMM = 369036;

function event_death(e)
	eq.signal(ZOMM, e.self:GetID());
end
