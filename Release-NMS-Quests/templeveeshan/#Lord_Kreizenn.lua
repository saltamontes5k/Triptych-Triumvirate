function event_combat(e)
	if e.joined then
		eq.set_timer("help", 5000);
		HelpMe(e);
	else
		eq.stop_timer("help");
	end
end

function event_timer(e)
	if e.timer == "help" then
		HelpMe(e);
	end
end

function HelpMe(e)
	local entity_list = eq.get_entity_list();
	local add_1	= entity_list:IsMobSpawnedByNpcTypeID(124010);

	if add_1 then
		entity_list:GetMobByNpcTypeID(124010):CastToNPC():MoveTo(e.self:GetX(), e.self:GetY(), e.self:GetZ(), 0, false);
	end
end
