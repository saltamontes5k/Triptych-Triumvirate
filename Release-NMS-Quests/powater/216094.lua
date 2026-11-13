-- 216094 - Coirnav the Avatar of Water (real encounter boss)
-- NMS progression: Coirnav is one of the elemental gods gating Dragons of Norrath (and LDoN).
-- Memory NPC is global/26000.pl; hailing it grants the DoN subflag.
--
-- SCRIPT BINDING NOTE: the engine resolves per-NPC quest files by numeric ID before the
-- #name file (zone/quest_parser_collection.cpp GetQIByNPCQuest), so this file shadows
-- #Coirnav_the_Avatar_of_Water.lua — it is the only script that ever binds here. It must
-- carry the entire encounter handoff: controller signal, PoP flag merit, and banish shout.

local memory = require("nms_memory")

function event_signal(e)
	if e.signal == 7 then
		e.self:Shout("Violaters of this domain be banished from this domain!")
	end
end

function event_death_complete(e)
	-- Hand the death to the event controller: depop remaining wave trash, set
	-- coirnav_done, and spawn the Essence of Water (PoP flag elemental) in the
	-- non-respawning dz (Custom:StaticInstanceVersion).
	eq.signal(216107, 5) -- #coirnav_controller
	-- DoN/LDoN elemental subflag credit (global memory NPC)
	memory.spawn(e, "DoN", "coirnav the avatar of water", "LDoN", "coirnav the avatar of water")
end

function event_killed_merit(e)
	if tostring(eq.get_zone_instance_version()) == eq.get_rule("Custom:StaticInstanceVersion") then -- Only flag in non-respawning dz
		local coirnav_bucket = tonumber(e.other:GetAccountBucket("pop.flags.coirnav")) or 0
		if coirnav_bucket == 0 then
			e.other:SummonItem(29163) -- Item: Sphere of Coalesced Water
			e.other:SetAccountBucket("pop.flags.coirnav", "1")
			e.other:Message(MT.LightBlue, "You receive a character flag!")
		end
	end
end
