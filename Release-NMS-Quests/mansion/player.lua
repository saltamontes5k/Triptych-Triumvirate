-- mansion/player.lua -- Meldrath's Majestic Mansion zone access gate.
-- Entry requires the configured Clockwork Key (keyringed via the door
-- puzzle) or the plain King's-chamber key 36444 (visitors arrive through
-- the Dragonscale east door). GMs pass freely.
local prog = require("sof_progression")

-- eject points
local MECH_CAMP = { x = -1500, y = 150, z = 400, h = 0 }

local function may_enter(e)
	if e.self:GetGM() then
		return true
	end
	if e.self:KeyRingCheck(prog.ITEM.key_configurable)
		or e.self:KeyRingCheck(prog.ITEM.key_mechanotus) then
		return true
	end
	if e.self:CountItem(prog.ITEM.key_configurable) > 0
		or e.self:CountItem(prog.ITEM.key_mechanotus) > 0 then
		return true
	end
	return prog.has_flag(e.self, prog.FLG.mansion)
end

function event_enter_zone(e)
	if not may_enter(e) then
		e.self:Message(13, "Without the clockwork key the mansion doors "
			.. "refuse you, and the steam throws you out.")
		e.self:MovePC(436, MECH_CAMP.x, MECH_CAMP.y, MECH_CAMP.z, MECH_CAMP.h)
	end
end
