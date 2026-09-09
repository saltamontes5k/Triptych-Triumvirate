-- 381015 - Ayonae Ro (Deathknell, Tower of Dissonance final encounter)
-- NMS progression: clearing Deathknell is the gate for The Serpent's Spine.
-- Additive hook: when Ayonae Ro dies, spawn the memory NPC (global/26000.pl);
-- hailing it grants the TSS/deathknell subflag.

function event_death_complete(e)
	local memory_npc = eq.spawn2(26000, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading())
	if memory_npc ~= nil then
		memory_npc:SetEntityVariable("Flag-Name", "deathknell")
		memory_npc:SetEntityVariable("Stage-Name", "TSS")
	end
end
