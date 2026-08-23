function event_spawn(e)
  el = eq.get_entity_list()
  target = el:GetRandomClient(e.self:GetX(), e.self:GetY(), e.self:GetZ(), 500)
  e.self:AddToHateList(target, 1000)
end

