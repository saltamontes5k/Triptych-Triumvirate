-- dreadspire/player.lua
-- Depths of Darkhollow: the Demi-Plane of Blood (dreadspire, instance version 1).
--
--   * Applies the "Aura of Crimson Mists" zone curse. Each of the four curse
--     blockers a player absorbs (dodh.grant_blocker) weakens it by 25%; all four
--     suppress it entirely.
--   * Warns players who have not yet broken all five "Curse of Blood" raids that
--     they lack loot rights inside the Demi-Plane.
--
-- The static Dreadspire Keep is version 0 and is unaffected.
local dodh = require("dodh_helper")

local AURA_INTERVAL = 30000 -- ms
local DEMIPLANE_VERSION = 1

local function in_demiplane()
	return eq.get_zone_instance_version() == DEMIPLANE_VERSION
end

function event_enter_zone(e)
	local c = e.self
	if not in_demiplane() then
		return
	end

	eq.set_timer("dodh_aura", AURA_INTERVAL)

	if not dodh.has_loot_rights(c) then
		c:Message(15, "The Curse of Blood still binds this place: break all five raids, or the Demi-Plane of Blood will not yield its spoils to you.")
	end

	local n = dodh.blocker_count(c)
	if n >= 4 then
		c:Message(15, "The Aura of Crimson Mists parts around you harmlessly; all four blockers are in place.")
	elseif n > 0 then
		c:Message(15, string.format("The Aura of Crimson Mists gnaws at you, but your blockers dull it (%d of 4).", n))
	end
end

function event_timer(e)
	if e.timer ~= "dodh_aura" then
		return
	end

	local c = e.self
	if not in_demiplane() then
		eq.stop_timer("dodh_aura")
		return
	end

	-- Clients who have defeated Mayong Mistmoore are immune to the aura.
	if dodh.has_mayong_immunity(c) then
		return
	end

	local spell = dodh.aura_spell(c)
	if spell then
		c:ApplySpell(spell)
	end
end
