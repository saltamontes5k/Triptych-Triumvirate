-- Large systems trooper (436712) -- Octa add: DPS guard. On absorb, Octa
-- overcharges 5%.

function event_death_complete(e)
	local octa = eq.get_entity_list():GetNPCByNPCTypeID(436133)
	if octa ~= nil and octa:IsEngaged() then
		eq.signal(436133, 3)
	end
end
