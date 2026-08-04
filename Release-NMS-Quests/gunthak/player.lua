function event_fish_success(e)
	if e.self:GetClass() == Class.PALADIN then -- Paladin Only
		local data_bucket = ("Epic-Paladin-"..e.self:CharacterID());
		local epic_pal_rocleansing_status = tonumber(eq.get_data("Epic-Paladin-RoCleansing-"..e.self:CharacterID())) or 0;
		local epic_pal_rocompassion_status = tonumber(eq.get_data("Epic-Paladin-RoCompassion-"..e.self:CharacterID())) or 0;

		if eq.get_data(data_bucket) ~= "" then -- Has Started
			local temp = eq.get_data(data_bucket);
			s = eq.split(temp, ',');

			local epic_pre_onefive	= tonumber(s[1]);
			local epic_onefive		= tonumber(s[2]);		
			local epic_two			= tonumber(s[3]);
			local epic_twofive		= tonumber(s[4]);

			if epic_onefive == 3 then
				if(e.item:GetID() == 69914) then
					e.self:Message(MT.NPCQuestSay, "As you reel in the dark fish's scale, you notice a large fish in the water");
					eq.depop_all(224432);
					eq.spawn2(224432,0,0,-589.5,-134,-55.9,250); -- NPC: #A_Corrupted_Koalindl
				end
			end
		end
	end
end
