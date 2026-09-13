--[[
	phinteriortree (766) - Evantil's Abode - Player House Interior
	Zone script for the player housing system.

	- On the first player entering this instance session, loads the owner's
	  persisted furniture (house_objects) and spawns the placement slots.
	- Clicking an empty slot marker places the first furniture item found in your bags.
	- Clicking placed furniture picks it back up (owner only).

	All placement/pickup is owner-only (MVP access model).
]]

local ARRIVAL = { x = 100.0, y = 90.0, z = -60.0, h = 128.0 }

-- placement slot offsets around the arrival point
local SLOTS = {
	{ dx =  2.0, dy =  2.0 },
	{ dx = -2.0, dy =  2.0 },
	{ dx =  4.0, dy =  0.0 },
	{ dx = -4.0, dy =  0.0 },
	{ dx =  0.0, dy =  4.0 },
	{ dx =  0.0, dy = -4.0 },
	{ dx = -2.0, dy = -2.0 },
	{ dx =  2.0, dy = -2.0 },
}

local SLOT_MODEL = "IT64_ACTORDEF" -- small bag model used as the slot marker

-- placeable furniture (items table, itemtype 11 housing items)
local FURNITURE = {
	61800, 61801, 61802, 61803, 61804, 61805, 61806, 61807, 61808, 61809,
	61810, 61811, 61812, 61813, 61814, 61815, 61816, 61817, 61818, 61819,
	61820, 61821,
}

-- per-session state (a zone process hosts exactly one house instance)
local initialized = false
local placed     = {}  -- [object_entity_id] = { row, item, slot }
local slots      = {}  -- [object_entity_id] = slot_index
local slot_taken = {}  -- [slot_index] = true when furniture sits on the slot

local function is_owner(c)
	return eq.house_get_owner_for_instance(eq.get_zone_instance_id()) == c:CharacterID()
end

local function spawn_slots()
	for i, s in ipairs(SLOTS) do
		local ent = eq.create_ground_object_from_model(
			SLOT_MODEL,
			ARRIVAL.x + s.dx,
			ARRIVAL.y + s.dy,
			ARRIVAL.z,
			ARRIVAL.h
		)
		if ent and ent > 0 then
			slots[ent] = i
			slot_taken[i] = false
		end
	end
end

local function load_furniture()
	local list = eq.house_list_objects(eq.get_zone_instance_id())
	for entry in string.gmatch(list or "", "[^|]+") do
		local row, item, x, y, z, h = string.match(
			entry, "^(%d+):(%d+):([%-%d%.]+):([%-%d%.]+):([%-%d%.]+):([%-%d%.]+)$"
		)
		if row then
			local ent = eq.create_ground_object(
				tonumber(item),
				tonumber(x), tonumber(y), tonumber(z), tonumber(h)
			)
			if ent and ent > 0 then
				placed[ent] = { row = tonumber(row), item = tonumber(item), slot = nil }
			end
		end
	end
end

function event_enter_zone(e)
	local c = e.other
	if not c then return end

	if not initialized then
		initialized = true
		load_furniture()
		spawn_slots()
	end

	if is_owner(c) then
		c:Message(15, "Welcome home. Click an empty slot marker to place furniture from your bags; click placed furniture to pick it back up.")
	else
		c:Message(15, "You are visiting a private residence. Please be respectful.")
	end
end

function event_click_object(e)
	local obj = e.object
	local c = e.other
	if not obj or not c or not c:IsClient() then return end

	local ent = obj:GetID()

	-- clicked placed furniture -> owner picks it up
	local p = placed[ent]
	if p then
		if not is_owner(c) then
			c:Message(13, "Only the owner may touch the furnishings here.")
			return
		end
		if p.slot then
			slot_taken[p.slot] = false
		end
		eq.house_delete_object(p.row)
		placed[ent] = nil
		obj:Depop()
		c:SummonItem(p.item, 1)
		c:Message(15, "You carefully pick up the furnishing.")
		return
	end

	-- clicked a slot marker -> owner places furniture from bags
	local slot_index = slots[ent]
	if slot_index then
		if not is_owner(c) then
			c:Message(13, "This is not your home.")
			return
		end

		if slot_taken[slot_index] then
			c:Message(13, "This spot is already furnished.")
			return
		end

		local chosen = nil
		for _, fid in ipairs(FURNITURE) do
			if c:CountItem(fid) > 0 then
				chosen = fid
				break
			end
		end
		if not chosen then
			c:Message(13, "You have no furniture in your bags to place here.")
			return
		end

		local s = SLOTS[slot_index]
		local sx, sy = ARRIVAL.x + s.dx, ARRIVAL.y + s.dy
		local row = eq.house_add_object(eq.get_zone_instance_id(), chosen, sx, sy, ARRIVAL.z, ARRIVAL.h)
		if not row or row == 0 then
			c:Message(13, "Something went wrong while placing your furnishing.")
			return
		end

		c:RemoveItem(chosen, 1)
		local new_ent = eq.create_ground_object(chosen, sx, sy, ARRIVAL.z, ARRIVAL.h)
		if new_ent and new_ent > 0 then
			placed[new_ent] = { row = row, item = chosen, slot = slot_index }
			slot_taken[slot_index] = true
		end
		c:Message(15, "You place the furnishing with care.")
	end
end
