-- Krasnok Event

function event_death_complete(e)
    eq.spawn2(228122,0,0,e.self:GetX(),e.self:GetY(),e.self:GetZ(), 0); -- Fist_of_Krasnok
end


function event_signal(e)
    if e.signal == 1 then
        eq.depop();
    end
end