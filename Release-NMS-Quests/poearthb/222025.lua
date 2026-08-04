function event_combat(e)
	if (e.joined) then
		eq.set_timer("banish", 60000)
	else
		eq.stop_timer("banish")
	end
end

function event_timer(e)
	local instance_id = eq.get_zone_instance_id();
    local zone_id = eq.get_zone_id();
	local rand_hate = e.self:GetHateRandom()
		eq.debug("banish selected: " ..rand_hate:GetName());
		if (rand_hate.valid and rand_hate:IsClient() and not e.self:IsMezzed() and not rand_hate:IsPet() and e.self:GetHPRatio() >= 11) then
			local rand_hate_v = rand_hate:CastToClient()
			if (rand_hate_v.valid) then
				eq.debug(rand_hate_v:GetName());
				e.self:Say("begone " .. rand_hate_v:GetName())
				e.self:SetHate(rand_hate_v, 1, 1)
				rand_hate_v:MovePCInstance(zone_id, instance_id, 1864.94, 941.05, -254.0, 0)
			end
		end
end