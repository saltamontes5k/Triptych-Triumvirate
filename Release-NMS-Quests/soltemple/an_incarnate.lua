-- 1-9 is nothing, 10 is repop. Adjusted from original version due to an exploit that could cause these mobs to replicate endlessly as the original roll was 1d3, with one being nothing, two being respawn, three being spawn two copies.

function event_death_complete(e)
  local which = math.random(10);
  if  (which == 10) then
    eq.spawn2(80043, 0, 0, e.self:GetX(), e.self:GetY(),  e.self:GetZ(),  e.self:GetHeading()); -- NPC: an_incarnate
  end
end
