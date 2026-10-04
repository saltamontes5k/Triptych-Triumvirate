-- Large systems mender (436711) -- Octa add: PBAE caster. On absorb, its
-- steam vents through Octa (Release of Steam).

function event_combat(e)
	if e.joined then
		eq.set_timer("mend", 18000)
	else
		eq.stop_timer("mend")
	end
end

function event_timer(e)
	if e.timer == "mend" then
		local octa = eq.get_entity_list():GetNPCByNPCTypeID(436133)
		if octa ~= nil and octa:IsEngaged() and not octa:IsMezzed() then
			e.self:CastSpell(8106, octa:GetID()) -- Perfected Heal (30k)
		end
	end
end

function event_death_complete(e)
	local octa = eq.get_entity_list():GetNPCByNPCTypeID(436133)
	if octa ~= nil and octa:IsEngaged() then
		eq.signal(436133, 2)
	end
end
