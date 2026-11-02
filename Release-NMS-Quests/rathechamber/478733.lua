-- an_anchor_of_the_timeshear (478733) -- SoD raid controller:
-- Eriak's Downfall (rathechamber v51).
-- Registers the expedition loot event for the chest and adds the 72h
-- expedition lockout when the encounter signals completion.
-- Rasper: raidRathe3.html.

local raid = require("sod_raids")
local ach = require("achievement_flags")
local EVENT = raid.EVENT.ERIAK
local CHEST = raid.CHEST.ERIAK

function event_spawn(e)
	e.self:SetEntityVariable("done", "0")
	local exp = eq.get_expedition()
	if exp.valid then
		exp:SetLootEventByNPCTypeID(CHEST, EVENT)
	end
end

function event_signal(e)
	if e.signal == 1 and e.self:GetEntityVariable("done") ~= "1" then
		e.self:SetEntityVariable("done", "1")
		local exp = eq.get_expedition()
		if exp.valid and not exp:HasLockout(EVENT) then
			exp:AddLockout(EVENT, eq.seconds("72h"))
		end
		ach.set_zone(1647740, 1, 1647741)
		ach.set_zone(1600030, 1, 1600265)
	end
end
