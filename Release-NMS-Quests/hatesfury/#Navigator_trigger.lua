-- Navigator Event

function event_spawn(e)
    local xloc = e.self:GetX();
    local yloc = e.self:GetY();
    eq.set_proximity(xloc - 25, xloc + 25, yloc - 25, yloc + 25);
end

function event_enter(e)
    eq.spawn2(228107,0,0,0,0,0,0); -- #Navigator_counter
    eq.depop_with_timer();
end