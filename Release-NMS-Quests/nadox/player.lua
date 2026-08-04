function event_click_door(e)
	local door = e.door:GetDoorID();
	local entity_list = eq.get_entity_list();

	-- e.self:Message(MT.Lime,"Door ID is: [" .. door .. "] Open Type: [" .. e.door:GetOpenType() .. "] Lock Pick: [" .. e.door:GetLockPick() .. "] Key Item: [" .. e.door:GetKeyItem($

	if (door == 19) then
		eq.get_entity_list():GetDoorsByDoorID(20):ForceOpen(e.self);
	elseif (door == 20) then
		if e.self:GetZ() <= 50 then -- Below door
			eq.get_entity_list():GetDoorsByDoorID(20):ForceOpen(e.self);
		end
	end
end

function event_enter_zone(e)
	if e.self:GetClass() == Class.SHAMAN then
		local data_bucket = ("Epic-Shaman-"..e.self:CharacterID());
		local shaman_epic15_nadox = tonumber(eq.get_data("shaman_epic15_nadox")) or 0
		if eq.get_data(data_bucket) ~= "" then -- Has Started
			local temp = eq.get_data(data_bucket);
			s = eq.split(temp, ',');

			local epic_pre_onefive	= tonumber(s[1]);
			local epic_onefive		= tonumber(s[2]);		
			local epic_two			= tonumber(s[3]);
			local epic_twofive		= tonumber(s[4]);

			if epic_onefive == 19 and shaman_epic15_nadox == 0 then
				if eq.get_entity_list():IsMobSpawnedByNpcTypeID(227074) then
					eq.signal(227074, 1); -- NPC: Spiritseeker Nadox
				else
					eq.unique_spawn(227319,0,0,-536,-393,24,0); -- NPC: Spiritseeker Nadox
					eq.set_data("shaman_epic15_nadox", "1",tostring(eq.seconds("2h"))); -- 2H Cooldown on event
				end
			end
		end
	end
end

function event_loot(e)
	if e.self:GetClass() == Class.SHAMAN and e.item:GetID() == 57085 then -- Item: Ring of the Undead Spiritcharmer
		local data_bucket = ("Epic-Shaman-"..e.self:CharacterID());
		if eq.get_data(data_bucket) ~= "" then -- Has Started
			local temp = eq.get_data(data_bucket);
			s = eq.split(temp, ',');
	
			local epic_pre_onefive	= tonumber(s[1]);
			local epic_onefive		= tonumber(s[2]);		
			local epic_two			= tonumber(s[3]);
			local epic_twofive		= tonumber(s[4]);

			if epic_onefive == 19 then
				local x,y,z,h = e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading();
				eq.spawn2(283157,0,0,x,y,z,h); -- NPC: a_chest
				update_shaman_epic_databucket(e,epic_pre_onefive,20,epic_two,epic_twofive);
				return 0;
			else
				return 1;
			end
		else
			return 1;
		end
	end
end

function update_shaman_epic_databucket(e,pre_one_five,one_five,two,two_five)
	eq.set_data("Epic-Shaman-"..e.self:CharacterID(), pre_one_five..","..one_five..","..two..","..two_five);
	e.self:Message(MT.Yellow, "Your quest has been advanced"); -- Made up to let people know the flags have been updated.
end
