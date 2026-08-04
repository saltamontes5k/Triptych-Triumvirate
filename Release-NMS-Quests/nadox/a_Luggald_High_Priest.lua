-- Innoruk Event

local counter = 0;
local begin = 0;

function event_spawn(e)
    counter = 0; -- Make sure event is reset
    begin = 0; -- Make sure event is reset
end

function event_signal(e)
    if(e.signal == 1 and begin == 0) then
        begin = 1;
        e.self:Shout("Innoruuk protect us from the invaders in our land.");
        eq.set_timer("ceremony", 10 * 60 * 1000); -- 10 Minute Ceremony
        eq.signal(227082,1,0); -- a_luggald_apprentice
    elseif(e.signal == 2) then
        counter = counter + 1;
        if(counter == 1 or counter == 3) then
            e.self:Shout("As long as we have our numbers, Innoruuk will provide us with strength.");
        elseif(counter == 2 or counter == 4) then
            e.self:Shout("Innoruuk protect us from the invaders in our land.");
        elseif(counter == 5) then
            e.self:Shout("'Master Innoruuk, the invaders have intruded into your sacred place of worship! We are in need of your wisdom and power!");
            eq.stop_timer("ceremony");
            eq.unique_spawn(227331,0,0,1714,669,-87, 360); -- #Innoruk (Nadox)
            eq.depop_with_timer();
        end
    end
end

function event_timer(e)
    if (e.timer == "ceremony") then
        e.self:Shout("The ceremony is complete!");
        counter = 0; -- Make sure event is reset
        begin = 0; -- Make sure event is reset
    end
    eq.stop_timer(e.timer)
end

function event_death_complete(e)
    eq.stop_timer(e.timer)
end