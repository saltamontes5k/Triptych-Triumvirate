-- #Prince_Garzemort (166277) for Hollowshade war
-- Grimling leader at fort

function event_death_complete(e)
    eq.zone_emote(MT.Yellow, "A heavy silence descends upon the moor as Garzemort stills in death. One by one the sonic wolves and owlbears return to their homes, leaving an uneasy peace upon the land. Small grimling hands lift the price's body in the air and carry him into the caves to seek resurrection from their Master.");
    eq.signal(166257, 1000); -- zone reset signal
end

