-- Krasnok Event

function event_death_complete(e)
    eq.signal(228114,2,0); -- #bleeding_spell
    eq.signal(228115,2,0); -- #drowning_spell
    eq.signal(228116,2,0); -- #hate_spell
    eq.signal(228117,2,0); -- #languish_spell
    eq.signal(228118,2,0); -- #spell_target
    eq.signal(228122,1,0); -- #Fist_of_Krasnok
end

function event_signal(e)
    if(e.signal == 1) then
        eq.depop();
    end
end
