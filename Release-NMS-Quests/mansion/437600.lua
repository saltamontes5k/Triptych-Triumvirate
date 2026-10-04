-- King Ak`Anon (437600) -- held in the east wing of Meldrath's Majestic
-- Mansion. Trades the Clockwork Key for the Clockwork Seal of Ak'Anon and
-- ports visitors back to Dragonscale Hills on "leave".
local prog = require("sof_progression")

local CAMP = { x = 60, y = -80, z = 56, h = 0 } -- near Gimblefixx (TUNABLE)

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("A traveler! Gimblefixx still lives? Bless the cogs. "
			.. "Show me the [clockwork key] you carry and I will seal my "
			.. "mark upon it.")
	elseif e.message:findi("clockwork key") or e.message:findi("seal") then
		if e.other:CountItem(prog.ITEM.key_mechanotus) > 0 then
			e.self:Say("Trade it to me, then. My seal opens no doors, but "
				.. "Gurtrude trusts the mark of Ak'Anon above all others.")
		else
			e.self:Say("You carry no key, friend. Gimblefixx cuts them from "
				.. "silver clockwork parts.")
		end
	elseif e.message:findi("leave") then
		e.self:Say("Stay low along the wall and none shall see you go. Be "
			.. "well, " .. e.other:GetCleanName() .. ".")
		e.other:MovePC(442, CAMP.x, CAMP.y, CAMP.z, CAMP.h)
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, { item1 = prog.ITEM.key_mechanotus }) then
		e.other:SummonItem(prog.ITEM.seal)
		e.self:Say("You have my gratitude and my [seal], friend. Say the "
			.. "word and I will see you [leave] this place.")
		return
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
