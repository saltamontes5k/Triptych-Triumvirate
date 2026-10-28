-- powar: a Decorin taskmaster — the other body a slaver captain will claim.
local P = require("powar_shared")

function event_death(e)
  if math.random(1, 100) <= 15 then
    eq.unique_spawn(P.NPC.slaver_capt, 0, 0, e.self:GetX() - 10, e.self:GetY() + 10, e.self:GetZ(), 0)
    eq.zone_emote(15, "A slaver captain strides in to claim the corpse - and the ring on it.")
  end
end
