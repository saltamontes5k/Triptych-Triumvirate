-- dragonscale/player.lua -- Crystallos pool golem system.
-- Walking into one of the ten pools on the road to Crystallos wakes its
-- guardian golem, which carries six essences of its element.
--
-- TUNING: the pool coordinates below are seeded along the path to the
-- Crystallos barrier. Stand at each pool in game, /loc, and correct the
-- x/y values (the golem spawns at the waker's z, so only x/y matter).
-- Trigger radius is generous (120) by design.
local prog = require("sof_progression")

local POOLS = {
	--  name (pool order per the SoF map)     npc      x      y
	{ "Manastream Pool",        442600,   200,   800 },
	{ "Ragemire Pool",          442601,   420,  1150 },
	{ "Pool of Currents",       442602,   750,  1350 },
	{ "Lifewater Pool",         442603,  1000,  1600 },
	{ "Thunderstrike Pool",     442604,   850,  1900 },
	{ "Pool of Dancing Tears",  442605,  1100,  2100 },
	{ "Pool of the Ill",        442606,  1300,  2400 },
	{ "Firecrest Pool",         442607,  1150,  2700 },
	{ "Pool of Prismatic Icicles", 442608, 1400, 2900 },
	{ "Arcana Pool",            442609,  1600, 3100 },
}

local TRIGGER_RADIUS = 120

local function check_pools(e)
	local x, y = e.self:GetX(), e.self:GetY()
	local el = eq.get_entity_list()
	for _, pool in ipairs(POOLS) do
		if math.abs(x - pool[3]) <= TRIGGER_RADIUS
			and math.abs(y - pool[4]) <= TRIGGER_RADIUS
			and not el:IsMobSpawnedByNpcTypeID(pool[2]) then
			-- spawn at the waker's z so the golem stands on the pool's ground
			local mob = eq.spawn2(pool[2], 0, 0, pool[3], pool[4],
				e.self:GetZ(), 0)
			if mob then
				eq.zone_emote(15, "The waters of " .. pool[1]
					.. " churn as a guardian rises!")
			end
		end
	end
end

function event_enter_zone(e)
	eq.set_timer("sof_pools", 5000)
end

function event_timer(e)
	if e.timer == "sof_pools" then
		eq.set_timer("sof_pools", 5000)
		check_pools(e)
	end
end
