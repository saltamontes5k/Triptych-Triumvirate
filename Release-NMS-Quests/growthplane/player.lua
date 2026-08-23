function event_enter_zone(e)
	if e.self:HasClass(Class.BARD) or e.self:HasClass(Class.ROGUE) then
		if e.self:HasItem(52355) and not e.self:HasItem(52361) then -- Item Has: Shakey's Dilapidated Noggin Item Does Not Have: Reflective Viridian Lightstone
			eq.unique_spawn(127105, 234, 0, 0, 0, 0); -- NPC: Flighty_Viridian_Wisp
			e.self:Message(MT.Yellow, "Out of the corner of your eye, you catch a glimpse of a brightly colored wisp as it darts by. It's moving at an incredible speed.");
		end
	end
end
