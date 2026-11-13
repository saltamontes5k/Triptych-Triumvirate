-- CHRMFabledWeapon - scale script for the Fabled Encounters weapon items
-- (reference/Fabled-Loot-Design.xlsx, Design sheet section 2).
--
-- Same progression-driven scale as CHRMFabled, but on the weapon table:
--
--   none/RoK -> 0.45 | SoV complete -> 0.64 | SoL complete -> 0.74 |
--   PoP complete or beyond -> 1.0

local prog = require("nms_progression")

local SCALES = {
	{ "PoP", 1.0 },
	{ "SoL", 0.74 },
	{ "SoV", 0.64 },
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
	return 0.45 -- none/RoK
end

function event_scale_calc(e)
	e.self:SetScale(fabled_scale(e.owner))
end
