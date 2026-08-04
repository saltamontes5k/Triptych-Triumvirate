-- Krasnok Event

function event_signal(e)
    if(e.signal == 1) then
        eq.set_timer("languish", 32 * 1000); -- 32 Sec
    elseif(e.signal == 2) then
        eq.stop_timer("languish")
    end
end

function event_timer(e)
    if (e.timer == "languish") then
        e.self:CastSpell(3783,228118);	-- Spell: Languish of the Sea, Target: #spell_target
        eq.set_timer("languish", 32 * 1000); -- 32 Sec
    end
end