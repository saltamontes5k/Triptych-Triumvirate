-- illsalinb/#Avatar_of_the_Council.lua (349030)
-- Depths of Darkhollow: the instanced Council of Nine (Temple of the Korlach,
-- illsalinb version 1). The stock encounter supplies the bodies; this grants
-- the Curse of Blood and records the expedition lockout when the Avatar falls.
local dodh = require("dodh_helper")

local EVENT = "The Council of Nine"
local LOCKOUT = eq.seconds("5d12h")

function event_death_complete(e)
	local dz = eq.get_expedition()
	if dz.valid then
		dz:AddLockout(EVENT, LOCKOUT)
	end
	dodh.grant_curse_zone("council")
end
