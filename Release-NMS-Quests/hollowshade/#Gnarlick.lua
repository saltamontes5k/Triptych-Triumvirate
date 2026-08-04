-- #Gnarlick (166275) for Hollowshade war
-- Wolf leader at fort

function event_death_complete(e)
    eq.zone_emote(MT.Yellow, "A howl echoes through the land as Gnarlick's blood seeps into the ground. The owlbears and grimlings take back their homes in respectful silence, bringing balance back to the swamplands. The wolves keen and howl as a powerful wolf successor steps forward to feed upon their former leader.");
    eq.signal(166257, 1000); -- zone reset signal
end

