-- Krasnok Event

function event_signal(e)
    if(e.signal == 1) then
        eq.set_timer("drowning", 55 * 1000); -- 55 Sec
    elseif(e.signal == 2) then
        eq.stop_timer("drowning")
    end
end

function event_timer(e)
    if (e.timer == "drowning") then
        e.self:CastSpell(3784,228118);	-- Spell: Drowning Panic, Target: #spell_target
        eq.set_timer("drowning", 55 * 1000); -- 55 Sec
    end
end