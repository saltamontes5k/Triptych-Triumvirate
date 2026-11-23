-- an_anchor_of_the_timeshear (478737) -- SoD raid controller:
-- The Mindblight (discordtower v51).
-- Registers the expedition loot event for the chest and adds the 72h
-- expedition lockout when the encounter signals completion.
-- Rasper: raidDiscord.html.

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
		exp:SetLootEventByNPCTypeID(raid.chest_for("MINDBLIGHT", hard), raid.event_name("MINDBLIGHT", hard))
	end
end

function event_signal(e)
	if e.signal == 1 and e.self:GetEntityVariable("done") ~= "1" then
		e.self:SetEntityVariable("done", "1")
		local exp = eq.get_expedition()
		local event_name = raid.event_name("MINDBLIGHT", e.self:GetEntityVariable("hard") == "1")
		if exp.valid and not exp:HasLockout(event_name) then
			exp:AddLockout(event_name, eq.seconds("72h"))
		end
		ach.set_zone(1647140, 1, 1647140)
	end
end
