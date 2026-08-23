-- Taskmaster Luga Event

local treasureroom_sp2 = {
	29974,30002,30004,30004,46864,47819
}

function event_death_complete(e)
	if has_value(treasureroom_sp2, e.self:CastToNPC():GetSp2()) then -- spawn groups inside the treasurer room
		eq.signal(226211,1); -- signal The_room to add to wave counter
	elseif e.self:CastToNPC():GetSp2() == 282505 then -- spawn group inside the overlord room
		eq.signal(226204,1); -- #overlord_trigger (226204) to add to wave counter
	end
end

function has_value (tab, val)
	for index, value in ipairs(tab) do
		if value == val then
			return true
		end
	end
	return false
end
