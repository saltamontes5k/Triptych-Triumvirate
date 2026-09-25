-- 381015 - Ayonae Ro (Deathknell, Tower of Dissonance final encounter)
-- NMS progression: clearing Deathknell is the gate for The Serpent's Spine.
-- Additive hook: when Ayonae Ro dies, spawn the memory NPC (global/26000.pl);
-- hailing it grants the TSS/deathknell subflag.

local memory = require("nms_memory")

function event_death_complete(e)
	memory.spawn(e, "TSS", "deathknell")
end
