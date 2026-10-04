-- Large systems reaper (436713) -- Octa add: lifetap caster. On absorb, it
-- feeds Octa (Blood of Fire AE + 10% heal).

function event_combat(e)
	if e.joined then
		eq.set_timer("reap", 20000)
	else
		eq.stop_timer("reap")
	end
end

function event_timer(e)
	if e.timer == "reap" then
		-- lifetap the nearest hated target (simplified PBAE lifetap)
		local t = e.self:GetTarget()
		if t ~= nil and t:IsClient() then
			e.self:CastSpell(9027, t:GetID())
			e.self:Heal()
		end
	end
end

function event_death_complete(e)
	local octa = eq.get_entity_list():GetNPCByNPCTypeID(436133)
	if octa ~= nil and octa:IsEngaged() then
		eq.signal(436133, 4)
	end
end
