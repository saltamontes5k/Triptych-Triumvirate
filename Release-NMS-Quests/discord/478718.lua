-- The Mindshear Avatar (478718) -- SoD Korafax raid 2.
-- Rasper: raidKorafax.html.
--
-- Simplified live encounter (the acolyte shell-game, fake chest, resist
-- debuffs and the feigned-death finale are not modelled):
--   * On engage -- five mindshear acolytes defend it.
--   * Wave of Terror -- 8k AE within 150 every 60s (emote names a flavor).
--   * 50%            -- mindshear maniacs pour in every 45s (live: charmable
--                       girplans that suicide on charm break).
-- On death: Treasure_of_the_Mindshear chest + controller lockout.

local raid = require("sod_raids")

local engaged = false
local acolytes_done = false
local maniacs_on = false
local adds = {}

local TERRORS = {
	"a wave of flaming terror",
	"a wave of freezing terror",
	"a wave of magical terror",
	"a wave of noxious terror",
	"a wave of leprous terror",
}

local function clear_adds()
	local el = eq.get_entity_list()
	for _, id in ipairs(adds) do
		local mob = el:GetNPCByID(id)
		if mob and mob.valid then mob:Depop() end
	end
	adds = {}
end

local function reset(e)
	engaged = false
	acolytes_done = false
	maniacs_on = false
	clear_adds()
	for _, t in ipairs({ "terror", "maniacs", "resetcheck" }) do
		eq.stop_timer(t)
	end
	e.self:Heal()
	eq.zone_emote(15, "The Mindshear Avatar sinks back into the rift, unfinished.")
end

function event_combat(e)
	if e.joined then
		if not engaged then
			engaged = true
			eq.set_timer("terror", 60000)
			for i = 1, 5 do
				local mob = raid.spawn_add(raid.ADD.acolyte, e.self, 80)
				if mob then
					adds[#adds + 1] = mob:GetID()
					local targets = raid.alive_clients(e.self:GetX(), e.self:GetY(), 300)
					if #targets > 0 then
						mob:AddToHateList(targets[math.random(#targets)], 1000, 10000)
					end
				end
			end
			eq.zone_emote(15, "Five mindshear acolytes coil around the Avatar, whispering in one voice!")
		end
		eq.stop_timer("resetcheck")
	else
		eq.set_timer("resetcheck", 60000)
	end
end

function event_timer(e)
	if e.timer == "resetcheck" then
		if not e.self:IsEngaged() then reset(e) end
		return
	end
	if not engaged then return end

	if e.timer == "terror" then
		eq.zone_emote(15, TERRORS[math.random(#TERRORS)] .. " erupts from the Avatar!")
		for _, client in ipairs(raid.alive_clients(e.self:GetX(), e.self:GetY(), 150)) do
			raid.hit(e.self, client, 8000)
		end
	elseif e.timer == "maniacs" then
		for i = 1, 2 do
			local mob = raid.spawn_add(raid.ADD.maniac, e.self, 60)
			if mob then
				adds[#adds + 1] = mob:GetID()
				local targets = raid.alive_clients(e.self:GetX(), e.self:GetY(), 300)
				if #targets > 0 then
					mob:AddToHateList(targets[math.random(#targets)], 1000, 10000)
				end
			end
		end
		eq.zone_emote(15, "Mindshear maniacs crawl shrieking from the rift!")
	end

	-- acolytes dead -> Avatar stands alone
	if not acolytes_done and #adds > 0
		and not eq.get_entity_list():IsMobSpawnedByNpcTypeID(raid.ADD.acolyte) then
		acolytes_done = true
		eq.zone_emote(15, "The acolytes are spent. The Avatar's whisper becomes a scream.")
	end

	-- 50%: maniac waves
	if not maniacs_on and e.self:GetHPRatio() <= 50 then
		maniacs_on = true
		eq.set_timer("maniacs", 45000)
	end
end

function event_death_complete(e)
	clear_adds()
	eq.zone_emote(15, "The Mindshear Avatar unravels, its chorus silenced.")
	raid.spawn_chest(e, raid.CHEST.AVATAR)
	eq.signal(raid.CTRL.AVATAR, 1)
end
