-- Krasnok Event

function event_signal(e)
    if e.signal == 1 then
        eq.set_timer("bleeding", 63 * 1000); -- 63 Sec
    elseif e.signal == 2 then
        eq.stop_timer("bleeding")
    end
end

function event_timer(e)
    if e.timer == "bleeding" then
        e.self:CastSpell(3786,228118);	-- Spell: Bleeding Ether, Target: #spell_target
        eq.set_timer("bleeding", 63 * 1000); -- 63 Sec
    end
end