function event_death_complete(e)
	if math.random(99) <= 10 then -- 10% chance
		e.self:Emote("disolves into a shimmering presence, coalescing into a swirl of smoke and energy.");
		eq.unique_spawn(179165,0,0,e.self:GetX(),e.self:GetY(),e.self:GetZ(),0); -- NPC: #A_shimmering_presence (179165)
	else
		e.self:Emote("explodes in a shower of green slime!");
		eq.spawn2(179145,0,0,e.self:GetX(),e.self:GetY(),e.self:GetZ(),0); -- NPC: The_temple (179145)
	end
end
