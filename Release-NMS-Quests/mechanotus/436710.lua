-- Large systems mechanic (436710) -- Octa add. On absorb, Octa repairs 8%.

function event_death_complete(e)
	local octa = eq.get_entity_list():GetNPCByNPCTypeID(436133)
	if octa ~= nil and octa:IsEngaged() then
		eq.signal(436133, 1)
	end
end
