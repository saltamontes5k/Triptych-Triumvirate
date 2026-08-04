-- Named Spawner Chance Script

-- Event Death
function event_death_complete(e)
    if( math.random(100) >= 95) then -- 5% Chance to spawn named
        eq.unique_spawn(227297,0,0,e.self:GetX(),e.self:GetY(),e.self:GetZ(), 82); -- #Captain_Krakskull
    end
end