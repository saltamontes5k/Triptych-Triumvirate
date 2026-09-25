--[[
	Sunrise_Hills_Realtor (npc 712024) - Sunrise Hills (neighborhood, zone 712)

	Grants each character one free house chosen from the list of player
	house interiors (the "phinterior" family plus a couple of extras),
	issues replacement keys for 25,000 platinum, and offers a trip back
	to the Plane of Knowledge.
]]

local KEY_ITEM_ID    = 9015300
local HOUSE_DURATION = 315360000 -- 10 years, in seconds
local KEY_COST       = 25000000  -- 25,000 platinum, in copper

local POK_RETURN = { zone = 202, x = 1398.0, y = -306.0, z = -124.0, h = 328.0 }

-- The list of player houses. Clicking a name sends its key; the key maps to a zone.
local HOUSES = {
	{ key = "cottage",         name = "Cozy One-Bedroom Cottage", zone = "plhogrinteriors1a1" },
	{ key = "small-a",         name = "Small House",              zone = "phinterior1a1" },
	{ key = "small-b",         name = "Small House (B)",          zone = "phinterior1a2" },
	{ key = "small-c",         name = "Small House (C)",          zone = "phinterior1a3" },
	{ key = "round-a",         name = "Round House",              zone = "phinterior1b1" },
	{ key = "round-b",         name = "Round House (B)",          zone = "phinterior1b2" },
	{ key = "round-c",         name = "Round House (C)",          zone = "phinterior1b3" },
	{ key = "vaulted",         name = "Vaulted House",            zone = "phinterior1c1" },
	{ key = "deluxe",          name = "Deluxe House",             zone = "phinterior1d1" },
	{ key = "medium-a",        name = "Medium House",             zone = "phinterior3a1" },
	{ key = "medium-b",        name = "Medium House (B)",         zone = "phinterior3a2" },
	{ key = "medium-c",        name = "Medium House (C)",         zone = "phinterior3a3" },
	{ key = "grand-a",         name = "Grand House",              zone = "phinterior6a1" },
	{ key = "grand-b",         name = "Grand House (B)",          zone = "phinterior6a2" },
	{ key = "grand-c",         name = "Grand House (C)",          zone = "phinterior6a3" },
	{ key = "treehouse",       name = "Evantil's Abode (Treehouse)",      zone = "phinteriortree" },
	{ key = "grand-treehouse", name = "Grand Treehouse",          zone = "phinteriortree3br" },
}

local function house_name_for_zone(zone)
	for _, h in ipairs(HOUSES) do
		if h.zone == zone then return h.name end
	end
	return zone
end

local function offer_house_list(e)
	local links = {}
	for _, h in ipairs(HOUSES) do
		links[#links + 1] = eq.say_link(h.name, false, h.key)
	end
	e.self:Say("Of course! Which of our fine residences would you like? " .. table.concat(links, ", ") .. ". Each resident may claim one home, free of charge.")
end

local function claim_house(e, c, house)
	local existing = eq.house_get_instance_for_char(c:CharacterID())
	if existing ~= 0 then
		e.self:Say("But " .. c:GetCleanName() .. ", you already own a home. Use your key to travel there whenever you wish!")
		return
	end

	local instance_id = eq.create_instance(house.zone, 0, HOUSE_DURATION)
	if instance_id == 0 then
		e.self:Say("I am terribly sorry, the paperwork office appears to be closed. Please try again shortly.")
		return
	end

	local house_id = eq.house_create(c:CharacterID(), instance_id, house.zone)
	if house_id == 0 then
		e.self:Say("My ledger seems to be missing a page... please try once more.")
		return
	end

	eq.assign_to_instance_by_char_id(instance_id, c:CharacterID())
	c:SummonItem(KEY_ITEM_ID, -1)
	e.self:Say(
		"Congratulations, " .. c:GetCleanName() .. "! The deed is signed - " .. house.name ..
		" is yours for as long as you keep it. Here is your house key; click it whenever you wish to travel home."
	)
end

function event_say(e)
	local c = e.other
	if not c or not c:IsClient() then return end

	local name = c:GetCleanName()

	if e.message:findi("hail") then
		if eq.house_get_instance_for_char(c:CharacterID()) == 0 then
			e.self:Say(
				"Welcome to Sunrise Hills, " .. name .. "! Every resident of our fair neighborhood is entitled to one free home. " ..
				"Say the word [" .. eq.say_link("claim") .. "] and I shall show you the choices. " ..
				"Should you lose your key, I can issue a [" .. eq.say_link("replacement") .. "] for 25,000 platinum. " ..
				"I can also [" .. eq.say_link("return you to the Plane of Knowledge") .. "] when you are finished here."
			)
		else
			e.self:Say(
				"Ah, " .. name .. ", welcome back! If you have lost your house key, I can issue a " ..
				"[" .. eq.say_link("replacement") .. "] for 25,000 platinum. " ..
				"Or I can [" .. eq.say_link("return you to the Plane of Knowledge") .. "]."
			)
		end
		return
	end

	if e.message:findi("claim") then
		if eq.house_get_instance_for_char(c:CharacterID()) ~= 0 then
			e.self:Say("But " .. name .. ", you already own a home here! Use your key to travel home whenever you like.")
			return
		end
		offer_house_list(e)
		return
	end

	-- house selection (exact key sent by the say-link, or exact name typed)
	for _, h in ipairs(HOUSES) do
		if e.message:lower() == h.key or e.message:lower() == h.name:lower() then
			claim_house(e, c, h)
			return
		end
	end

	if e.message:findi("replacement") or e.message:findi("lost my key") then
		local instance_id = eq.house_get_instance_for_char(c:CharacterID())
		if instance_id == 0 then
			e.self:Say("You do not own a home in Sunrise Hills yet. Say [" .. eq.say_link("claim") .. "] and we shall fix that at once.")
			return
		end
		if c:CountItem(KEY_ITEM_ID) > 0 then
			e.self:Say("You still carry your key, " .. name .. ". Check your bags before you spend your coin!")
			return
		end
		if not c:TakeMoneyFromPP(KEY_COST, true) then
			e.self:Say("A replacement key costs 25,000 platinum, " .. name .. ". Come back when your purse is heavier.")
			return
		end
		c:SummonItem(KEY_ITEM_ID, -1)
		e.self:Say("Here is your replacement key, " .. name .. ". Try not to lose this one - I have a reputation to maintain.")
		return
	end

	if e.message:findi("return") or e.message:findi("plane of knowledge") then
		e.self:Say("Safe travels, " .. name .. ".")
		c:MovePC(POK_RETURN.zone, POK_RETURN.x, POK_RETURN.y, POK_RETURN.z, POK_RETURN.h)
	end
end

function event_trade(e)
	local item_lib = require("items")
	item_lib.return_items(e.self, e.other, e.trade)
end
