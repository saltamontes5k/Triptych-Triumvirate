-- [[
-- Kildrukaun the Ancient (446211) -- Crystallos raid, wing boss (Earth).
-- Rasper: raidCrystallos.html (Kildrukaun the Prophet).
--
-- Rooted; summons at full HP; ~12k hits, single+AE rampage. Targeted AEs:
--   * Strike of the Ancients (12773) -- 2500 dd + AC debuff
--   * Kildrukaun's Revenge (16998)   -- large flux
-- Each 10% adds 2 mezzable awakened drakes (90/70/50/20/10 plus vortex at
-- 60 and 30 -> Kildrukaun's Curse 12949, 10k dot + 2k mana dot, 24 corruption
-- counters).
-- On death: Treasure_of_Kildrukaun (446265) + earth-wing boss chest.
--]]

local R = require("sof_crystallos_raid")
local CHEST = 446265
local DRAKE_ADD = 446223
local STRIKE, CURSE = 12773, 12949

local MY_X, MY_Y = -1780, -520

local engaged = false
local adds = {}
local last_step = 100

local DRAKE_STEPS = { 90, 70, 50, 20, 10 }
local VORTEX = { 60, 30, 10 }

function event_combat(e)
	if e.joined then
		if not engaged then
			engaged = true
			eq.set_timer("strike", 18000)
			eq.set_timer("stepcheck", 2000)
			eq.zone_emote(15, "Kildrukaun the Prophet delivers a dire prophecy -- to you.")
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
			last_step = 100
			R.clear_list(adds)
			eq.stop_timer("strike")
			eq.stop_timer("stepcheck")
			e.self:Heal()
		end
		return
	end
	if not engaged then return end

	if e.timer == "strike" then
		eq.zone_emote(13, "Kildrukaun the Prophet shouts out 'Rasper! You will be the instrument of my revenge!'")
		local t = R.alive_clients(MY_X, MY_Y, 400)
		if #t > 0 then
			local v = t[math.random(#t)]
			e.self:CastSpell(STRIKE, v:GetID())
		end
		eq.set_timer("strike", 22000)
		return
	end

	if e.timer == "stepcheck" then
		local hp = e.self:GetHPRatio()
		-- drake waves at descending 10% thresholds
		for _, step in ipairs(DRAKE_STEPS) do
			if hp <= step and last_step > step then
				eq.zone_emote(13, "Awakened drakes waken from the earth to defend Kildrukaun!")
				local new = R.spawn_adds(DRAKE_ADD, 2, MY_X, MY_Y, e.self:GetZ(), 90)
				for _, id in ipairs(new) do adds[#adds + 1] = id end
			end
		end
		-- vortex curse at 60 and 30
		for _, v in ipairs(VORTEX) do
			if hp <= v and e.self:GetEntityVariable("vortex_" .. v) ~= "1" then
				e.self:SetEntityVariable("vortex_" .. v, "1")
				eq.zone_emote(13, "A swirling vortex forms around Kildrukaun! Get out of the room or hug the wall!")
				for _, c in ipairs(R.alive_clients(MY_X, MY_Y, 120)) do
					e.self:CastSpell(CURSE, c:GetID())
				end
			end
		end
		last_step = hp
		eq.set_timer("stepcheck", 2000)
	end
end

function event_death_complete(e)
	R.clear_list(adds)
	eq.stop_timer("strike")
	eq.stop_timer("stepcheck")
	R.chest(e.self, CHEST, "Crystallos: Keepers of Stone")
	R.signal(R.SIG.earth)
	eq.zone_emote(15, "Kildrukaun's prophecy is spent. Stone and earth return to silence.")
end
