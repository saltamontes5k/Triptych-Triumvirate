-- Sleeper's Tomb 1.0 -- A wardstone (classic Al'Kabor).
function event_combat(e)
	if (e.joined) then
		e.self:Say("DEPART!");
		e.self:CastSpell(863, e.other:GetID(), 0, 0); -- Spell: Telekinesis
		eq.depop_with_timer();
	end
end
