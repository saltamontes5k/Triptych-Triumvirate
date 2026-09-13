local spawnedMobs = 0

function event_combat(e)
    if e.joined then
        eq.set_timer("spawn",2 * 60 * 1000)
    else
        eq.stop_timer("spawn")
        eq.depop_all(128014)
    end
end

function event_timer(e)
    if e.timer == "spawn" then
        eq.stop_timer(e.timer);
        eq.spawn2(128014,28,0,e.self:GetX()+10,e.self:GetY()+10,e.self:GetZ(),126.6)
        eq.spawn2(128014,29,0,e.self:GetX()-10,e.self:GetY()-10,e.self:GetZ(),126.6)
        spawnedMobs = spawnedMobs + 2
        if spawnedMobs < 8 then
            eq.set_timer("spawn",2 * 60 * 1000)
        end
    end
end

function event_death_complete(e)
    eq.depop_all(128014)
end
