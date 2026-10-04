-- Convorteum_Herald_Dagna (480260) -- Brell's Rest war camp.
-- Requests the T8 Convorteum instance (seven sequential stages).
-- Gate: the Audience with Brell flag. Rasper: miscRaidProg.html.
local prog = require("uf_progression")

local convorteum_dz = prog.dz("The Convorteum", "convorteum", 1,
	{ 13.0, -50.0, -44.125 })

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hail, " .. e.other:GetCleanName() .. ". I keep the door "
			.. "of the [Convorteum], the heart of the Underfoot, where the "
			.. "First Creation waits at the end of seven wards.")
	elseif e.message:findi("convorteum") or e.message:findi("raid") then
		if not prog.has_flag(e.other, prog.FLG.brell_audience) then
			e.self:Say("Brell does not grant the Convorteum to strangers. "
				.. "Stand [audience] before him first.")
			return
		end
		e.self:Say("The Audience was well spoken. Say [ready] and I will "
			.. "open the heart of the Underfoot to your raid -- seven wards, "
			.. "each harder than the last.")
	elseif e.message:findi("audience") then
		e.self:Say("An Audience with Brell Serilis, in Brell's Temple. Earn "
			.. "it and the Convorteum answers to you.")
	elseif e.message:findi("ready") or e.message:findi("enter") then
		prog.ready(e)
	end
end

function event_trade(e)
	local item_lib = require("items")
	-- An Amulet of Brell backs the request (consumed).
	if item_lib.check_turn_in(e.trade, { item1 = prog.ITEM.amulet }) then
		if not prog.has_flag(e.other, prog.FLG.brell_audience) then
			e.other:SummonItem(prog.ITEM.amulet)
			e.self:Say("Hold onto that. The [Convorteum] opens to those "
				.. "Brell has received, not to coin alone.")
			return
		end
		prog.request_raid(e, convorteum_dz, 80, nil)
		return
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
