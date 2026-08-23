-- Krasnok Event

function event_spawn(e)
    eq.spawn2(228010,0,0,-1112,-46,-285.58,120); -- #Attendant_Mi`Ta
end

function event_signal(e)
    if(e.signal == 1) then
        eq.set_timer("Krasnok", 3 * 60 * 60 * 1000); -- 3 Hours
    elseif(e.signal == 2) then
        eq.stop_timer("Krasnok")
        eq.spawn2(228010,0,0,-1112,-46,-285.58,120); -- #Attendant_Mi`Ta
    end
end

function event_timer(e)
    if (e.timer == "Krasnok") then
        eq.stop_timer("Krasnok")
        eq.spawn2(228010,0,0,-1112,-46,-285.58,120); -- #Attendant_Mi`Ta

        eq.signal(228121,1,0); -- #Captain_Krasnok
        eq.signal(228122,1,0); -- #Fist_of_Krasnok
        eq.signal(228114,1,0); -- #bleeding_spell
        eq.signal(228115,1,0); -- #drowning_spell
        eq.signal(228116,1,0); -- #hate_spell
        eq.signal(228117,1,0); -- #languish_spell
    end
end