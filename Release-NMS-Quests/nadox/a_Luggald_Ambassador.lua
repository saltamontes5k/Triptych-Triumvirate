-- The Luggald Broodmother Event

function event_death_complete(e)
    eq.unique_spawn(227001,50,0,1554,668,-88, 383); -- The_Luggald_Broodmother
    eq.zone_emote(MT.NPCQuestSay,"The ground begins to rumble and shake as you question your reason to explore these blood covered walls."); -- Emote the zone
end
