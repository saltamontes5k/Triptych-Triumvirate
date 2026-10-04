-- crystallos/player.lua -- Crystallos, Lair of the Awakened access gate.
-- Entry requires the Prismatic Crystal Charm (36620). GMs pass freely.
local prog = require("sof_progression")

local LAIYKEN_CAMP = { x = -1092, y = 1983, z = 362.25, h = 0 }

function event_enter_zone(e)
	if e.self:GetGM() then
		return
	end
	if e.self:CountItem(prog.ITEM.charm) > 0
		or prog.has_flag(e.self, prog.FLG.crystallos) then
		return
	end
	e.self:Message(13, "The prismatic barrier flares and hurls you back. "
		.. "The brothers' charm is the only way through.")
	e.self:MovePC(442, LAIYKEN_CAMP.x, LAIYKEN_CAMP.y, LAIYKEN_CAMP.z, LAIYKEN_CAMP.h)
end
