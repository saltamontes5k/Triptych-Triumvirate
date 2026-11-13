-- CHRMFabled - scale script for the Fabled Encounters armor/augment items
-- (reference/Fabled-Loot-Design.xlsx, Design sheet section 2).
--
-- The server's charmfile scaling calls EVENT_SCALE_CALC on the wearer and
-- multiplies the item's scale-1.0 stats by whatever SetScale() leaves in
-- the instance. The scale follows the wearer's highest completed REGULAR
-- progression stage:
--
--   none/RoK -> 0.25 | SoV complete -> 0.43 | SoL complete -> 0.6 |
--   PoP complete or beyond -> 1.0
--
-- Weapons use the separate CHRMFabledWeapon table.

local prog = require("nms_progression")

local SCALES = {
	{ "PoP", 1.0 },
	{ "SoL", 0.6 },
	{ "SoV", 0.43 },
}

local function fabled_scale(owner)
	if not owner or not owner.IsClient or not owner:IsClient() then
		return 1.0
	end
	for _, entry in ipairs(SCALES) do
		if prog.stage_complete(owner, entry[1]) then
			return entry[2]
		end
	end
	return 0.25 -- none/RoK
end

function event_scale_calc(e)
	e.self:SetScale(fabled_scale(e.owner))
end
