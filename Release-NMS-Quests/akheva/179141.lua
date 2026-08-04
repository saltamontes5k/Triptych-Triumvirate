function event_combat(e)
	if e.joined then
        e.self:CastedSpellFinished(eq.ChooseRandom(2817,2816), e.self:GetHateTop()); -- Spell: Thought Vortex, Storm Tremor
		eq.depop_with_timer();
	end
end
