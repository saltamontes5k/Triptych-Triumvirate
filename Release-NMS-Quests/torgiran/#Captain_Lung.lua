-- Overseer Wrank Event

-- Event Death
function event_death_complete(e)
    eq.signal(226200,11,0); -- #wrank_trigger
end
