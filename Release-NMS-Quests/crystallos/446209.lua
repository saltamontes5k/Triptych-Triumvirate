-- [[
-- Brood Mother Visziaj (446209) -- Crystallos raid, basement.
-- Rasper: raidCrystallos.html (Brood Mother Visziaj).
--
-- Preceded by Dar`Kelor (446207, 10k PBAE flux) and Ki`Mrash (446208, 10k
-- PBAE flux, AE rampage). Egg tenders path to rooms and hatch whelps/drakelings.
-- She paths ~3 min then roots on her dias and attacks. AEs:
--   * Crystal Chill Vapors (6964) -- short-range AE 1250 dd + 750 dot
--   * Corruption of the Brood Mother (13232) -- AE melee/spell-damage debuff
--   * Siphon of Visziaj (13233) -- 4k dd + 2k mana/endurance drain
--   * Brood Mother's Meteor Shower (13234) -- targeted AE 10k dd + stun
-- Death: Treasure_of_the_Brood_Mother (446268) + brood lockout; all adds despawn.
--]]

local R = require("sof_crystallos_raid")
local CHEST = 446268
local EGG_TENDER, WHELP, DRAKELING = 446227, 446228, 446229
local VAPORS, CORRUPT, SIPHON, METEOR = 6964, 13232, 13233, 13234

local MY_X, MY_Y = -500, 300

local engaged = false
local adds = {}

function event_combat(e)
	if e.joined then
		if not engaged then
			engaged = true
			eq.set_timer("vapors", 20000)
			eq.set_timer("siphon", 35000)
			eq.set_timer("meteor", 45000)
			eq.set_timer("tenders", 30000)
			eq.zone_emote(15, "Brood Mother Visziaj turns, shrieking a challenge over her clutch.")
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
			for _, t in ipairs({ "vapors", "siphon", "meteor", "tenders" }) do eq.stop_timer(t) end
			e.self:Heal()
		end
		return
	end
	if not engaged then return end

	if e.timer == "vapors" then
		eq.zone_emote(13, "Brood Mother exhales crystal chill vapors over the closest foes!")
		for _, c in ipairs(R.alive_clients(MY_X, MY_Y, 60)) do
			e.self:CastSpell(VAPORS, c:GetID())
		end
		eq.set_timer("vapors", 20000)
	elseif e.timer == "siphon" then
		local t = R.alive_clients(MY_X, MY_Y, 400)
		if #t > 0 then
			eq.zone_emote(13, "Brood Mother siphons strength and mana from the raid!")
			for i = 1, math.min(4, #t) do
				if t[i] then e.self:CastSpell(SIPHON, t[i]:GetID()) end
			end
		end
		eq.set_timer("siphon", 35000)
	elseif e.timer == "meteor" then
		local t = R.alive_clients(MY_X, MY_Y, 500)
		if #t > 0 then
			local v = t[math.random(#t)]
			eq.zone_emote(13, "A meteor shower rains down on " .. v:GetCleanName() .. "!")
			e.self:CastSpell(METEOR, v:GetID())
		end
		eq.set_timer("meteor", 45000)
	elseif e.timer == "tenders" then
		if e.self:GetHPRatio() >= 20 then
			eq.zone_emote(13, "Egg tenders scuttle off to hatch the clutch!")
			local new = R.spawn_adds(EGG_TENDER, 2, MY_X, MY_Y, e.self:GetZ(), 90)
			for _, id in ipairs(new) do adds[#adds + 1] = id end
		end
		eq.set_timer("tenders", 30000)
	end
end

function event_death_complete(e)
	R.clear_list(adds)
	for _, t in ipairs({ "vapors", "siphon", "meteor", "tenders" }) do eq.stop_timer(t) end
	R.chest(e.self, CHEST, "Crystallos: Brood Mother")
	R.signal(R.SIG.brood)
	eq.zone_emote(15, "The Brood Mother collapses, and her clutch begins to fade.")
	-- despawn the egg tenders/whelps that are still up
	eq.depop_all(EGG_TENDER)
	eq.depop_all(WHELP)
	eq.depop_all(DRAKELING)
end
