-- Navigator Event

local counter = 0;

function event_spawn(e)
    counter = 0; -- Ensure Counter is Reset
end

function event_signal(e)
    if(e.signal == 1) then
        counter = counter + 1;
    end

    if(counter == 12) then -- Spawn Navigator
        eq.unique_spawn(228110,0,0,1542,982,-582,250); -- the_Broken_Skull_Navigator
        counter = 0; -- Reset Counter
        eq.depop();
    end
end