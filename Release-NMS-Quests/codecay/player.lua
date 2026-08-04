function event_enter_zone(e)
	local qglobals = eq.get_qglobals(e.self);
	
	if(qglobals["mage_epic"] == "10" and qglobals["mage_epic_cod"] == nil) then
		e.self:Message(15,"Your staff begins to glow");
	end
end

function event_click_door(e)
	if (e.door:GetDoorID() == 7) then
		local codecay_bucket = tonumber(e.self:GetAccountBucket("pop.flags.codecay")) or 0
		if (codecay_bucket >= 1 or e.self:GetGM()) then
			e.self:MovePCInstance(200, eq.get_zone_instance_id(), 0, -16, -289, 256)
		else
			e.self:Message(1, "There is still more work to be done.")
		end
	end
end

function event_loot(e)
	if (e.self:HasClass(Class.MAGICIAN) and e.item:GetID() == 19544 and e.corpse:GetNPCTypeID()==200060) then
		local qglobals = eq.get_qglobals(e.self);
		if(qglobals["mage_epic"] == "10") then
			return 0;
		else
			return 1;
		end
	end
end
