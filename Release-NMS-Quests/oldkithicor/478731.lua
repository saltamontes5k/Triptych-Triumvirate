-- an_anchor_of_the_timeshear (478731) -- SoD raid controller:
-- Fall of General Bahgresh (oldkithicor v51).
-- Registers the expedition loot event for the chest and adds the 72h
-- expedition lockout when the encounter signals completion.
-- Rasper: raidKith.html.

local raid = require("sod_raids")
local EVENT = raid.EVENT.BAHGRESH
local CHEST = raid.CHEST.BAHGRESH

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
	end
end
