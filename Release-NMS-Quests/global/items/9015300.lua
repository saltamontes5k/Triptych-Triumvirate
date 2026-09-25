--[[
	Sunrise Hills House Key (item 9015300)
	Clicking the key carries the owner straight home to their instanced
	house. Arrival uses the house zone's safe point (set per zone in the
	zone table), so it always lands on the floor.
]]

local HOUSE_DURATION = 315360000 -- 10 years, in seconds; refreshed on every use

function event_item_click(e)
	-- in item scripts e.self is the ItemInstance; the clicking player is e.owner
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
	c:MoveZoneInstance(instance_id) -- no coords -> lands on the zone's safe point
end
