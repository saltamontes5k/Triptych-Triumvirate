-- powar: a furious legionnaire (spawned by Refiner Dyrginal's challenge).
-- On death the Herald of War appears to collect the victor's Token of War.
local P = require("powar_shared")

function event_death(e)
  local top = P.top_client(e)
  eq.unique_spawn(P.NPC.herald, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), 0)
  eq.zone_emote(15, "The legionnaire falls, and the sound of far wings answers. A Herald of War descends.")
end

function event_spawn(e)
  e.self:Shout("WHO DARES LIGHT THE MARK?!");
end
