-- Dimaal Event

function event_combat(e)
    if e.joined then
        eq.set_timer("combat_check", 15 * 60 * 1000); -- 15 Minute Combat Timer Check (Cleanup)
    end
end

function event_timer(e)
    if e.timer == "combat_check" then
        if not e.self:IsEngaged() then
            eq.stop_timer(e.timer);
            eq.signal(224115,2,1); -- Notify Dimaal that we failed (No Agro for 15 Minutes)
            eq.depop();
        end
    end
end
