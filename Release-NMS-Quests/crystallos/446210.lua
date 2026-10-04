-- [[
-- Tjudawos the Ancient (446210) -- Crystallos raid, wing boss (Fire).
-- Rasper: raidCrystallos.html (Tjudawos the Ancient).
--
-- Rooted; ~11k hits, single+AE rampage; permanent aura (4500 dmg + 50
-- mana/endurance drain per tick). Phase table:
--   100-80% : Tongue of Living Flame (12834) on many -- unresistable 8k DoT,
--             6 corruption counters; DT at 36s if not cured.
--   80-60%  : multiple elementals spawn (5k hit, stunnable, immune to mez)
--   60-40%  : resumes Tongue DT, self 40% spell reflect, Blast of Confusion
--             (12836) AE spin stun.
--   40-0%   : everything at once.
-- On death: Treasure_of_Tjudawos (446264) + fire-wing boss chest + lockout.
--]]

local R = require("sof_crystallos_raid")
local CHEST = 446264
local ELEM_ADD = 446224
local TONGUE, BLAST = 12834, 12836

local MY_X, MY_Y = 1520, -460

local engaged = false
local adds = {}

function event_combat(e)
	if e.joined then
		if not engaged then
			engaged = true
			eq.set_timer("aura", 6000)
			eq.set_timer("tongue", 30000)
			eq.zone_emote(15, "Tjudawos the Ancient awakens in a gale of living flame.")
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
			for _, t in ipairs({ "aura", "tongue", "elementals", "blast" }) do eq.stop_timer(t) end
			e.self:Heal()
		end
		return
	end
	if not engaged then return end

	if e.timer == "aura" then
		for _, c in ipairs(R.alive_clients(MY_X, MY_Y, 120)) do
			c:Damage(e.self, 4500, 0, 6)
			c:SetMana(math.max(0, c:GetMana() - 50))
		end
		eq.set_timer("aura", 6000)
		return
	end

	local hp = e.self:GetHPRatio()

	if e.timer == "tongue" then
		if hp >= 60 then
			eq.zone_emote(13, "You feel flames run up and down your body, burning you!")
			local t = R.alive_clients(MY_X, MY_Y, 400)
			for i = 1, math.min(4, #t) do
				if t[i] then e.self:CastSpell(TONGUE, t[i]:GetID()) end
			end
			eq.set_timer("tongue", 30000)
		else
			eq.stop_timer("tongue")
		end
		return
	end

	if e.timer == "elementals" then
		if not engaged then return end
		if hp <= 80 and e.self:GetEntityVariable("elem_done") ~= "1" then
			e.self:SetEntityVariable("elem_done", "1")
			eq.zone_emote(13, "Flame elementals condense out of the torchlight!")
			local new = R.spawn_adds(ELEM_ADD, 4, MY_X, MY_Y, e.self:GetZ(), 80)
			for _, id in ipairs(new) do adds[#adds + 1] = id end
		end
		eq.set_timer("elementals", 30000)
		return
	end

	if e.timer == "blast" then
		if hp <= 60 then
			eq.zone_emote(13, "Tjudawos blasts the room with a pulse of confusion!")
			for _, c in ipairs(R.alive_clients(MY_X, MY_Y, 300)) do
				e.self:CastSpell(BLAST, c:GetID())
			end
		end
		eq.set_timer("blast", 45000)
	end
end

function event_death_complete(e)
	R.clear_list(adds)
	for _, t in ipairs({ "aura", "tongue", "elementals", "blast" }) do eq.stop_timer(t) end
	R.chest(e.self, CHEST, "Crystallos: Halls of Fire")
	R.signal(R.SIG.fire)
	eq.zone_emote(15, "Tjudawos' fire gutters and dies. The fire wing is truly fallen.")
end
