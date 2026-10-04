-- [[
-- Icyyr (446202) -- Crystallos raid, Ice Constructs first chamber.
-- Rasper: raidCrystallos.html (Ice Constructs).
-- Mitigation buff (50% melee+spell), summons a new Construct every 2 min,
-- max hit grows with the number of living Constructs. No chest.
--]]
local R = require("sof_crystallos_raid")
local CONSTRUCT = 446222
local MY_X, MY_Y = -780, -700

local engaged = false
local adds = {}

function event_combat(e)
	if e.joined then
		if not engaged then
			engaged = true
			eq.set_timer("summon", 120000)
			eq.zone_emote(15, "Icyyr thrums, drawing the shards of its kin into its bulk.")
		end
		eq.stop_timer("resetcheck")
	else
		eq.set_timer("resetcheck", 60000)
	end
end

function event_timer(e)
	if e.timer == "resetcheck" then
		if not e.self:IsEngaged() then
			engaged = false
			R.clear_list(adds)
			eq.stop_timer("summon")
			e.self:Heal()
		end
		return
	end
	if e.timer == "summon" then
		eq.zone_emote(13, "Icyyr summons yet another Construct -- they do not despawn when it dies!")
		local new = R.spawn_adds(CONSTRUCT, 1, MY_X, MY_Y, e.self:GetZ(), 60)
		for _, id in ipairs(new) do adds[#adds + 1] = id end
		eq.set_timer("summon", 120000)
	end
end

function event_death_complete(e)
	R.clear_list(adds)
	eq.stop_timer("summon")
end
