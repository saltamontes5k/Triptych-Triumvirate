-- Reflections of Silver
-- stillmoonb version 2 (instance_version.stillmoon_ascent_reflections_of_silver)
--
-- Optional raid offered by Captain Areha Burina (NK, tasks 5504/5505) and
-- General Lereh Dirr (DR, task 5504) at High Amiable. Boss is Rikkukin the
-- Defender (339113); the fight itself (directional AE emotes, blind, frozen
-- aura HP locks, loot chest 339112) lives in the per-NPC script
-- stillmoonb/Rikkukin_the_Defender.lua, which also applies to this instance.
-- Kill activity "Rikkukin" credits automatically via partial name match, so
-- no death handler is needed here.

local function spawn_rikkukin()
	if eq.get_entity_list():IsMobSpawnedByNpcTypeID(339113) then
		return
	end
	eq.spawn2(339113, 0, 0, 1200.0, 6398.0, 750.0, 73.0) -- live-zone spawn point
end

function event_encounter_load(e)
	spawn_rikkukin()
end
