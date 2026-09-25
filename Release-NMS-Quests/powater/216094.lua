-- 216094 - Coirnav the Avatar of Water (real encounter boss)
-- NMS progression: Coirnav is one of the elemental gods gating Dragons of Norrath (and LDoN).
-- This additive hook credits the kill whenever the real Coirnav dies, independent of the
-- water event controller state. Memory NPC is global/26000.pl; hailing it grants the DoN subflag.

local memory = require("nms_memory")

function event_death_complete(e)
	memory.spawn(e, "DoN", "coirnav the avatar of water")
end
