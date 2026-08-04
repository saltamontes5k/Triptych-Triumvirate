-- Innoruk Event

function event_signal(e)
    if(e.signal == 1) then
        e.self:Say("All praise Innoruk.");
    end
end

function event_combat(e)
    if e.joined then
        eq.signal(227073,1,0); -- a_Luggald_High_Priest
    end
end

function event_death_complete(e)
    eq.signal(227073,2,0); -- a_Luggald_High_Priest
end
