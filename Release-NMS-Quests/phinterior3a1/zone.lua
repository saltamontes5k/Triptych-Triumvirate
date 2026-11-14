--[[
	Player House Interior - arrival greeting.

	This file is placed in every house-interior zone's quest folder.

	Furniture belongs to the native real-estate system (zone/nms_housing.cpp and the
	nms_house_item rows): the client's own Real Estate window places and picks items up,
	the commit handler stores the row, and every interior identity burst re-sends the
	placed rows on zone-in. The script-driven MVP this file used to carry - bag-prop
	slot markers spawned as ground objects, click to place, click to pick up - is
	retired, so this script spawns nothing and handles no clicks.
]]

local function is_owner(c)
	return eq.house_get_owner_for_instance(eq.get_zone_instance_id()) == c:CharacterID()
end

function event_enter_zone(e)
	local c = e.other
	if not c then
		return
	end

	if is_owner(c) then
		c:Message(15, "Welcome home. Use the Real Estate window to place or pick up furnishings.")
	else
		c:Message(15, "You are visiting a private residence. Please be respectful.")
	end
end
