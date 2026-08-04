-- Krasnok Event

function event_signal(e)
    if(e.signal == 1) then
        eq.set_timer("hate", 43 * 1000); -- 43 Sec
    elseif(e.signal == 2) then
        eq.stop_timer("hate")
    end
end

function event_timer(e)
    if (e.timer == "hate") then
        e.self:CastSpell(3785,228118);	-- Spell: Hate's Fury, Target: #spell_target
        eq.set_timer("hate", 43 * 1000); -- 43 Sec
    end
end