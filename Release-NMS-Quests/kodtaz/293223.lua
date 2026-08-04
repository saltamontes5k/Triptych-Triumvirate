function event_death_complete(e)
  eq.spawn2(293224,0,0,e.self:GetX() - 10, e.self:GetY(), e.self:GetZ(), e.self:GetHeading())
  eq.spawn2(293224,0,0,e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading())
  eq.spawn2(293225,0,0,e.self:GetX() + 10, e.self:GetY(), e.self:GetZ(), e.self:GetHeading())
end
