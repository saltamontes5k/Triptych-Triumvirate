-- Named Spawner Chance Script

function event_death_complete(e)
    if( math.random(100) >= 95) then -- 5% Chance to spawn named
        eq.unique_spawn(227302,0,0,e.self:GetX(),e.self:GetY(),e.self:GetZ(), 82); -- #A_Broken_Skull_Peer
    end
end