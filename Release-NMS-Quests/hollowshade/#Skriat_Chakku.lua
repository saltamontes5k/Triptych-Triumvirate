-- #Skriat_Chakku (166235) for Hollowshade war
-- Owlbear leader at fort

function event_death_complete(e)
    eq.zone_emote(MT.Yellow, "Skriat`Chakku collapses in a pile of feathers, defeated. The Grimling and sonic wolves reclaim their homes, bringing balance back to the swamplands. Fortunately for the Owlbear, their great denmother left an heir.");
    eq.signal(166257, 1000); -- zone reset signal
end

