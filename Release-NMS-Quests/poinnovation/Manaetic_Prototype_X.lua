local instance_id = eq.get_zone_instance_id();

function event_combat(e)
	if(e.joined == true) then
		eq.set_timer("banish",math.random(15,30) * 1000);
	else
		eq.stop_timer("banish");
	end
end

function event_timer(e)
	if e.timer == "banish" then
		local cur_target = e.self:GetHateTop();
		if cur_target.valid and cur_target:IsClient() then
			local client = cur_target:CastToClient();
			client:MovePCInstance(206, instance_id, -248,-241,3.13,384);
		end

		eq.stop_timer(e.timer);
		eq.set_timer("banish",math.random(15,30) * 1000);
	end
end
