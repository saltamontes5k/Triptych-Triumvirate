-- Rogue Epic 1.5

function event_combat(e)
	if e.joined then
		e.self:Say("Grr... The piece is mine, snake! You'll not have it.");
		eq.depop_with_timer();
	end
end