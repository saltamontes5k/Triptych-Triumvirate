-- Master_of_Hate - Muramite Proving Grounds chamber Master (PoR gate + trial AA)
-- NMS progression: all six chamber Masters must fall before Prophecy of Ro unlocks, and each
-- clear grants its matching grant-only 'Mastery of X' AA (70000-70005) to everyone in the instance.
-- Memory NPC is global/26000.pl; hailing it grants the PoR subflag.

local memory = require("nms_memory")

function event_death_complete(e)
	-- PoR gate subflag
	memory.spawn(e, "PoR", "master of hate")

	-- Trial AA grant to every client in the instance (raid credit)
	local aa_id = 70000
	local list = eq.get_entity_list():GetClientList()
	for c in list.entries do
		if c.valid and not c:GetGM() and c:GetLevel() >= 65 then
			c:GrantAlternateAdvancementAbility(aa_id, 1)
			c:Message(MT.Yellow, "Your trials are complete. You have earned a rank of the appropriate mastery!")
		end
	end
end
