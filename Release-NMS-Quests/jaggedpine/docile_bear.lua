---- Quest:Paying Oracle Jaarl Respect
function event_spawn(e)
    e.self:SetGrid(258);
    eq.start(258);	
end

function event_waypoint_arrive(e)
    local grid = e.self:GetGrid()

    if (e.wp == 3) then
        eq.spawn2(181002,0,0,1889.94,1648.53,-12.9,265.2); -- NPC: a docile bear, KOS
        eq.depop();
    end
end
