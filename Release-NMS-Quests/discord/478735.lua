-- an_anchor_of_the_timeshear (478735) -- SoD raid controller:
-- The Mindshear Avatar (discord v52).
-- Registers the expedition loot event for the chest and adds the 72h
-- expedition lockout when the encounter signals completion.
-- Rasper: raidKorafax.html.

local raid = require("sod_raids")
local ach = require("achievement_flags")

function event_spawn(e)
	e.self:SetEntityVariable("done", "0")
	-- v464 hard mode: the chest and the loot-event/lockout identity
	follow the expedition name's (Hard) suffix, so hard and normal
	run as separate lockouts with separate chests.
	local hard = raid.is_hard()
	e.self:SetEntityVariable("hard", hard and "1" or "0")
	local exp = eq.get_expedition()
	if exp.valid then
		exp:SetLootEventByNPCTypeID(raid.chest_for("AVATAR", hard), raid.event_name("AVATAR", hard))
	end
end

function event_signal(e)
	if e.signal == 1 and e.self:GetEntityVariable("done") ~= "1" then
		e.self:SetEntityVariable("done", "1")
		local exp = eq.get_expedition()
		local event_name = raid.event_name("AVATAR", e.self:GetEntityVariable("hard") == "1")
		if exp.valid and not exp:HasLockout(event_name) then
			exp:AddLockout(event_name, eq.seconds("72h"))
		end
		ach.set_zone(1647040, 1, 1647041)
		ach.set_zone(1600040, 1, 1600280)
	end
end
