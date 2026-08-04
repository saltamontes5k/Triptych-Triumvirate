-- TOFS Door checks

function event_click_door(e)
	local door_id = e.door:GetDoorID();
    if door_id == 2 or door_id == 166 then --First Floor
		if e.self:HasItem(20033) or e.self:HasItem(20039) or e.self:KeyRingCheck(20033) or e.self:KeyRingCheck(20039) then --Crystal Key
			PortChars(e, 75, 660, 100, 40, 0);
		end
	elseif door_id == 4 or door_id == 167 then --Second Floor
		if e.self:HasItem(20034) or e.self:HasItem(20039) or e.self:KeyRingCheck(20034) or e.self:KeyRingCheck(20039) then --Three Toothed Key
			PortChars(e, 75, 670, 750, 75, 0);
		end
	elseif door_id == 16 or door_id == 165 then --Third Floor
		if e.self:HasItem(20035) or e.self:HasItem(20039) or e.self:KeyRingCheck(20035) or e.self:KeyRingCheck(20039) then --Frosty Key
			PortChars(e, 75, 170, 775, 175, 0);
		end
	elseif door_id == 27 or door_id == 169 then --Fourth Floor
		if e.self:HasItem(20036) or e.self:HasItem(20039) or e.self:KeyRingCheck(20036) or e.self:KeyRingCheck(20039) then --Small Rusty Key
			PortChars(e, 75, -150, 160, 217, 0);
		end
	elseif door_id == 34 or door_id == 168 then --Fifth Floor
		if e.self:HasItem(20037) or e.self:HasItem(20039) or e.self:KeyRingCheck(20037) or e.self:KeyRingCheck(20039) then --Bone Finger Key
			PortChars(e, 75, -320, 725, 12, 0);
		end
	elseif door_id == 34 or door_id == 168 then --Sixth Floor
		if e.self:HasItem(20038) or e.self:HasItem(20039) or e.self:KeyRingCheck(20038) or e.self:KeyRingCheck(20039) then --Large Metal Key
			PortChars(e, 75, -320, 725, 12, 0);
		end
	elseif door_id == 157 then -- Seventh Floor
		if e.self:HasItem(20038) or e.self:HasItem(20039) or e.self:KeyRingCheck(20038) or e.self:KeyRingCheck(20039) then --Large Metal Key
			PortChars(e, 75, 10, 65, 310, 0);
		end
	elseif door_id == 1 then --first floor going to mirror room.
		if e.self:HasItem(20039) or e.self:KeyRingCheck(20039) then --Tserinas Key
			PortChars(e, 75, 18, 260, 353, 0);
		end
	end
end


function PortChars(e, distance, dest_x, dest_y, dest_z, dest_h)
	local player_list		= nil;
	local player_list_count = nil;
	local group				= e.self:GetGroup();
	local instance_id		= eq.get_zone_instance_id();

	if group.valid then
		player_list = group;
		player_list_count = group:GroupCount();
	--if Group is True then drop these variables
	end

	if player_list ~= nil then
		for i = 0, player_list_count - 1, 1 do --Uses a 0-n group memembers
			local client_v = player_list:GetMember(i):CastToClient();
			if client_v.valid then --valid client
				if client_v:CalculateDistance(e.self:GetX(), e.self:GetY(), e.self:GetZ()) <= distance then
			        --check distance and port up
					client_v:MovePCInstance(111, instance_id, dest_x, dest_y, dest_z, dest_h);
				end
			end
		end
	else -- not grouped
		e.self:CastToClient():MovePCInstance(111, instance_id, dest_x, dest_y, dest_z, dest_h);
	end
end
