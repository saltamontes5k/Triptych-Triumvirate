--added functionality for rogue pre-quest in Shar Vahl prison #Drogerin

function event_click_door(e)
	local door_id = e.door:GetDoorID();
	
	if (e.self:HasClass(Class.ROGUE)) then 
		if (door_id == 106) then
			if (e.self:HasItem(52007) == true) then
				eq.spawn2(155346,0,0,-541.79,99.84,-235.62,506.8);
				e.self:Message(13, "You try the Cell Key on the lock and it's a perfect fit.");
			end
		end
	end
end
