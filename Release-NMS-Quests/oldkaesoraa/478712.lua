-- Councilor (SoD raid: A Council Divided, oldkaesoraa v51).
-- The anchor marks 4 of the 8 as Discord-aligned at boot; those four emit a
-- 10k AE while engaged. Death signals the anchor (Rasper: raidKunark1.html).

local raid = require("sod_raids")
local MY_ID = 478712

function event_combat(e)
	if e.joined then raid.councilor_engaged(e) end
end

function event_timer(e)
	raid.councilor_timer(e)
end

function event_death_complete(e)
	eq.signal(raid.CTRL.COUNCIL, MY_ID)
end
