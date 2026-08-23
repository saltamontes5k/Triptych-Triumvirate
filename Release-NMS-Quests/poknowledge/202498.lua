function event_say(e)
    if(e.message:findi("hail")) then
        e.self:Say("Greetings, hero! Grand Librarian Maelin has tasked me to assist adventurers with a way to hastily reach back to the bottom. Please let me know if you would like to be [" .. eq.silent_say_link("translocated") .. "].")
    elseif(e.message:findi("translocate")) then
        e.other:MovePC(Zone.poknowledge, 937, 14.5, 3.13, 132);
    end
end

function event_spawn(e)
    e.self:ModifyNPCStat("special_abilities", "19,1^20,1^21,1^24,1^25,1^35,1");
end