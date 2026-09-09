local enableBanish = false

function event_combat(e)
	if (e.joined and enableBanish) then
		eq.set_timer("banish", 60000)
	else
		eq.stop_timer("banish")
	end
end

function event_timer(e)
	local instance_id = eq.get_zone_instance_id();
	local zone_id = eq.get_zone_id();
	local rand_hate = e.self:GetHateRandom();
	eq.debug("banish selected: " ..rand_hate:GetName());
	if (enableBanish and rand_hate.valid and rand_hate:IsClient() and not e.self:IsMezzed() and not rand_hate:IsPet() and e.self:GetHPRatio() >= 11) then
		local rand_hate_v = rand_hate:CastToClient();
		if (rand_hate_v.valid) then
			eq.debug(rand_hate_v:GetName());
			e.self:Say("begone " .. rand_hate_v:GetName());
			e.self:SetHate(rand_hate_v, 1, 1);
			rand_hate_v:MovePCInstance(zone_id, instance_id, 1864.94, 941.05, -254.0, 0);
		end
	end
end

function event_death_complete(e)
	--eq.signal(1120001052,1); -- seedling
	eq.signal(222012,1); -- #rathe_controller

	-- NMS progression: The Rathe Council is the earth god gating Dragons of Norrath (and LDoN).
	-- When the last councilman falls, spawn the memory NPC (global/26000.pl); hailing it grants
	-- the DoN subflag. The controller is #-disabled in this tree, so detect completion directly.
	local m1 = eq.get_entity_list():IsMobSpawnedByNpcTypeID(222008);
	local m2 = eq.get_entity_list():IsMobSpawnedByNpcTypeID(222013);
	if (not m1 and not m2) then
		local memory_npc = eq.spawn2(26000, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading())
		if memory_npc ~= nil then
			memory_npc:SetEntityVariable("Flag-Name", "rathe council")
			memory_npc:SetEntityVariable("Stage-Name", "DoN")
		end
	end
end
