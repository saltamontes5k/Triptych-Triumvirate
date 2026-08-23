-- Taskmaster Luga Event

local count = 0;

function event_spawn(e)
    count = 0; -- Ensure Counter is Reset
end

function event_signal(e)
    if e.signal == 1 then
        count = count + 1;
        if count == 23 then
            eq.signal(226072,1,0); -- NPC: #Taskmaster_Luga
            eq.spawn2(226207,0,0,-1276,1085,-141.62, 0); -- NPC: Taskmaster_Lugald_Brokenskull
            eq.depop();
        end
    end
end