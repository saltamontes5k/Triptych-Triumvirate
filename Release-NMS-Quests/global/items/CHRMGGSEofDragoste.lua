-- Confirmed earlyzero/finalfull behavior. Intermediate growth percentages are
-- explicitly configurable server defaults in achievement_quest_mesa_love_data;
-- they are not presented as an exact recovered May2013 scaling table.
function event_scale_calc(e)
 e.self:SetScale(require('achievement_quest_mesa_love').scale(e.owner))
end
