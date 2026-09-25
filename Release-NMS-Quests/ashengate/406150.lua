-- 406150 - Dyn`Leth (Ashengate North raid capstone)
-- NMS progression: Dyn'Leth is the gate for The Buried Sea and Secrets of Faydwer.
-- On death spawn two memory NPCs (global/26000.pl) so the raid can hail for both the
-- TBS and SoF subflags (same objective name on both stages).

local memory = require("nms_memory")

function event_death_complete(e)
	local x = e.self:GetX(); local y = e.self:GetY(); local z = e.self:GetZ(); local h = e.self:GetHeading();

	memory.spawn_at(e.other, x, y, z, h, "SoF", "dyn`leth");
	memory.spawn_at(e.other, x, y, z, h, "TBS", "dyn`leth");
end
