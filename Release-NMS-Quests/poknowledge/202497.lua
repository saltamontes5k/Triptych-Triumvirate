function event_say(e)
    if(e.message:findi("hail")) then
        e.self:Say("Greetings, hero! Grand Librarian Maelin has tasked me to assist adventurers with a way to hastily reach him. Please let me know if you would like to be [" .. eq.silent_say_link("translocated") .. "] up to him.")
    elseif(e.message:findi("translocate")) then
        e.other:MovePC(Zone.poknowledge, 908.10, 19, 389.13, 129);
    end
end

function event_spawn(e)
    e.self:ModifyNPCStat("special_abilities", "19,1^20,1^21,1^24,1^25,1^35,1");
end