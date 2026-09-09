-- 406150 - Dyn`Leth (Ashengate North raid capstone)
-- NMS progression: Dyn'Leth is the gate for The Buried Sea and Secrets of Faydwer.
-- On death spawn two memory NPCs (global/26000.pl) so the raid can hail for both the
-- TBS and SoF subflags (same objective name on both stages).

function event_death_complete(e)
	local memory_id = 26000;
	local x = e.self:GetX(); local y = e.self:GetY(); local z = e.self:GetZ(); local h = e.self:GetHeading();

	local m1 = eq.spawn2(memory_id, 0, 0, x, y, z, h);
	if m1 ~= nil then
		m1:SetEntityVariable("Flag-Name", "dyn`leth");
		m1:SetEntityVariable("Stage-Name", "SoF");
	end

	local m2 = eq.spawn2(memory_id, 0, 0, x, y, z, h);
	if m2 ~= nil then
		m2:SetEntityVariable("Flag-Name", "dyn`leth");
		m2:SetEntityVariable("Stage-Name", "TBS");
	end
end
