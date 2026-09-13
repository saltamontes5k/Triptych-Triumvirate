--[[
	Sunrise_Hills_Realtor (npc 712024) - Sunrise Hills (neighborhood, zone 712)
	Grants every character one free house (Imperium-style), issues replacement
	keys for 25,000 platinum, and can send travelers back to the Plane of Knowledge.
]]

local KEY_ITEM_ID    = 9015300
local HOUSE_ZONE     = "phinteriortree"
local HOUSE_DURATION = 315360000 -- 10 years, in seconds
local KEY_COST       = 25000000  -- 25,000 platinum, in copper

local POK_RETURN = { zone = 202, x = 1398.0, y = -306.0, z = -124.0, h = 328.0 }

function event_say(e)
	local c = e.other
	if not c or not c:IsClient() then return end

	local name = c:GetCleanName()

	if e.message:findi("hail") then
		if eq.house_get_instance_for_char(c:CharacterID()) == 0 then
			e.self:Say(
				"Welcome to Sunrise Hills, " .. name .. "! Every resident of our fair neighborhood is entitled to a free home. " ..
				"Say the word [" .. eq.say_link("claim") .. "] and I shall draw up the paperwork at once. " ..
				"Should you ever lose your key, I can issue a [" .. eq.say_link("replacement") .. "] for 25,000 platinum. " ..
				"I can also [" .. eq.say_link("return you to the Plane of Knowledge") .. "] when you are finished here."
			)
		else
			e.self:Say(
				"Ah, " .. name .. ", welcome back! Your residence is in good order. " ..
				"If you have lost your house key, I can issue a [" .. eq.say_link("replacement") .. "] for 25,000 platinum. " ..
				"Or I can [" .. eq.say_link("return you to the Plane of Knowledge") .. "]."
			)
		end
	elseif e.message:findi("claim") then
		if eq.house_get_instance_for_char(c:CharacterID()) ~= 0 then
			e.self:Say("But " .. name .. ", you already own a home here! Use your key to travel home whenever you like.")
			return
		end

		local instance_id = eq.create_instance(HOUSE_ZONE, 0, HOUSE_DURATION)
		if instance_id == 0 then
			e.self:Say("I am terribly sorry, the paperwork office appears to be closed. Please try again shortly.")
			return
		end

		local house_id = eq.house_create(c:CharacterID(), instance_id)
		if house_id == 0 then
			e.self:Say("My ledger seems to be missing a page... please try once more.")
			return
		end

		eq.assign_to_instance_by_char_id(instance_id, c:CharacterID())
		c:SummonItem(KEY_ITEM_ID, -1)
		e.self:Say(
			"Congratulations, " .. name .. "! The deed is signed - the home is yours for as long as you keep it. " ..
			"Here is your house key; click it whenever you wish to travel home. Make yourself comfortable in Evantil's Abode!"
		)
	elseif e.message:findi("replacement") or e.message:findi("key") then
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
	elseif e.message:findi("return") or e.message:findi("plane of knowledge") then
		e.self:Say("Safe travels, " .. name .. ".")
		c:MovePC(POK_RETURN.zone, POK_RETURN.x, POK_RETURN.y, POK_RETURN.z, POK_RETURN.h)
	end
end

function event_trade(e)
	local item_lib = require("items")
	item_lib.return_items(e.self, e.other, e.trade)
end
