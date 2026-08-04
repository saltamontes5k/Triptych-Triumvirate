function event_click_door(e)
	local door = e.door:GetDoorID();
	local group = e.self:GetGroup();
	local raid = e.self:GetRaid();
	--eq.zone_emote(MT.Lime,"Door ID is: " .. door);   --debug to easily check door IDs

	--for Inner Acrylia floor panel in grimling warlord throne room (Opens only after first stage of Khati Sha Event Completion)
	local zone_id = eq.get_zone_id();
	local instance_id = eq.get_zone_instance_id();
	local qglobals = eq.get_qglobals(e.self);

	if door == 5 then
		if qglobals[instance_id .. "_IAC_Seal_1"] ~= nil or e.self:GetGM() then
			e.self:Message(MT.Red,"With the Wards destroyed and the seals broken the panel on the floor slides open");
		else 
			e.self:Message(MT.Red,"You notice something amiss with the floor panels at your feet; however you cannot seem to get them to move.");
			e.door:ForceClose(e.self);
		end
	end

	if door == 17 then	--Inner AC statue
		if e.self:HasItem(5972) or e.self:KeyRingCheck(5972) then	-- Item: Hollow Acrylia Obelisk
			if e.self:IsRaidGrouped() then
				raid:TeleportGroup(e.self, zone_id, instance_id, 228, -354, 7, 510, raid:GetGroup(e.self:GetName()));
			elseif e.self:IsGrouped() then
				group:TeleportGroup(e.self, zone_id, instance_id, 228, -354, 7, 510);
			end
		end
	end

	-- makes the fancy 4-paneled door operate properly.
	if door == 1 or door == 2 or door == 3 or door == 4 then
		if qglobals[instance_id .. "_IAC_Seal_2"] ~= nil or e.self:GetGM() then
			e.self:Message(MT.Red,"With the final Ward destroyed the door glides open with ease.");
			local ent_list = eq.get_entity_list()
			for i=1,4 do
				if i ~= door then ent_list:GetDoorsByDoorID(i):ForceOpen(e.self) end
			end
		else
			e.self:Message(MT.Red,"The Spirit of the final Ward holds the seal tight.");
			e.door:ForceClose(e.self);
		end
	end
end
