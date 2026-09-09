-- 216094 - Coirnav the Avatar of Water (real encounter boss)
-- NMS progression: Coirnav is one of the elemental gods gating Dragons of Norrath (and LDoN).
-- This additive hook credits the kill whenever the real Coirnav dies, independent of the
-- water event controller state. Memory NPC is global/26000.pl; hailing it grants the DoN subflag.

function event_death_complete(e)
	local memory_npc = eq.spawn2(26000, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading())
	if memory_npc ~= nil then
		memory_npc:SetEntityVariable("Flag-Name", "coirnav the avatar of water")
		memory_npc:SetEntityVariable("Stage-Name", "DoN")
	end
end
