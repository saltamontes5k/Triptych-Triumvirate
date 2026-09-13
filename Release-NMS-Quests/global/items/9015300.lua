--[[
	Sunrise Hills House Key (item 9015300)
	SoD/Imperium-style: clicking the key ports you straight home to
	your instanced house in phinteriortree (Evantil's Abode).
]]

local HOUSE_ZONE     = "phinteriortree"
local HOUSE_DURATION = 315360000 -- 10 years, in seconds; refreshed on every use

-- arrival point inside the house (ground floor of the treehouse; tune with #loc if needed)
local ARRIVAL = { x = 100.0, y = 90.0, z = -60.0, h = 128.0 }

function event_item_click(e)
	-- NOTE: in item scripts e.self is the ItemInstance; the clicking player is e.owner
	local c = e.owner
	if not c or not c:IsClient() then return end

	local instance_id = eq.house_get_instance_for_char(c:CharacterID())
	if instance_id == 0 then
		c:Message(15, "The key is cold and unresponsive. You do not own a home in Sunrise Hills; the Realtor there can help you claim one.")
		return
	end

	-- make sure we are on the guest list and refresh the lease
	eq.assign_to_instance_by_char_id(instance_id, c:CharacterID())
	eq.update_instance_timer(instance_id, HOUSE_DURATION)

	c:Message(15, "Your key hums softly as it carries you home...")
	c:MoveZoneInstance(instance_id, ARRIVAL.x, ARRIVAL.y, ARRIVAL.z, ARRIVAL.h)
end
