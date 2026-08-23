function event_death_complete(e)
  eq.spawn2(293222,0,0,e.self:GetX() - 10, e.self:GetY(), e.self:GetZ(), e.self:GetHeading())
  eq.spawn2(293223,0,0,e.self:GetX() + 10, e.self:GetY(), e.self:GetZ(), e.self:GetHeading())
end
