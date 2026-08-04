function event_enter_zone(e)
	if e.self:GetClass() == Class.BARD or e.self:GetClass() == Class.ROGUE then
		if e.self:HasItem(52355) and not e.self:HasItem(52358) then -- Item Has: Shakey's Dilapidated Noggin Item Does Not Have: Shimmering Orange Lightstone
			eq.unique_spawn(100218, 328, 0, 0, 0, 385); -- NPC: Flighty_Orange_Wisp
			e.self:Message(MT.Yellow, "Out of the corner of your eye, you catch a glimpse of a brightly colored wisp as it darts by. It's moving at an incredible speed.");
		end
	end
end
