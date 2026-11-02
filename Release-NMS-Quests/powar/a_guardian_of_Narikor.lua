-- powar: a guardian of Narikor — sometimes the corpse draws a slaver captain
-- (PoP-ized stand-in for the black-powder click: kill guardians or taskmasters
-- and a captain sometimes comes to claim the body - and wears the ring.)
local P = require("powar_shared")

function event_death(e)
  if math.random(1, 100) <= 15 then
    eq.unique_spawn(P.NPC.slaver_capt, 0, 0, e.self:GetX() + 10, e.self:GetY() + 10, e.self:GetZ(), 0)
    eq.zone_emote(15, "A slaver captain strides in to claim the corpse - and the ring on it.")
  end
end
