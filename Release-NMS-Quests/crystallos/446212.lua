-- [[
-- Zeixshi`Kar the Ancient (446212) -- Crystallos raid, wing boss (Ice).
-- Rasper: raidCrystallos.html (Zeixshi`Kar).
--
-- ~12k hits, flurries, AE rampage. Spells:
--   * Zeixshi`Kar's Icy Breath (7983) -- PBAE 8k dd, 1k mana drain, snare,
--     spell/melee slow, accuracy debuff, 30 curse counters
--   * Zeixshi`Kar's Icy Claw (7984)   -- ST 10k dd, stun, fd, agro-remover
-- Emote (moisture freezing / encasing in ice) -> soon a frontal AE that
-- mezzes, DAs, and turns victims into a golem for 1.5 min (DT if not cured).
-- The cure is Igneous Crystalline Ember: 3 people click it on the victim.
-- On death: Treasure_of_Zeixshi_Kar (446267) + ice-wing boss chest.
--]]

local R = require("sof_crystallos_raid")
local CHEST = 446267
local EMBER = 446232 -- placeholder; actual ember handled on item/object
local BREATH, CLAW = 7983, 7984

local MY_X, MY_Y = -1520, 1740

local engaged = false
local thawed = {}

local function freeze_raid(e)
	eq.zone_emote(13, "The moisture in the air around Zeixshi`Kar freezes and gathers around him, encasing him in jagged shards of ice.")
	local t = R.alive_clients(MY_X, MY_Y, 300)
	if #t > 0 then
		local v = t[math.random(#t)]
		-- mezz + DA + golem illusion; simplified: a heavy sting
		v:Damage(e.self, 8000, 0, 3)
		eq.zone_emote(13, v:GetCleanName() .. " is frozen solid! A living ember, clicked thrice, will thaw them.")
		thawed[v:GetID()] = true
	end
end

function event_combat(e)
	if e.joined then
		if not engaged then
			engaged = true
			eq.set_timer("breath", 25000)
			eq.set_timer("claw", 30000)
			eq.set_timer("freeze", 65000)
			eq.zone_emote(15, "Zeixshi`Kar regards the raid through a veil of driving frost.")
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
			thawed = {}
			eq.stop_timer("breath")
			eq.stop_timer("claw")
			eq.stop_timer("freeze")
			e.self:Heal()
		end
		return
	end
	if not engaged then return end

	if e.timer == "breath" then
		eq.zone_emote(13, "Zeixshi`Kar draws in a breath -- Icy Breath!")
		for _, c in ipairs(R.alive_clients(MY_X, MY_Y, 120)) do
			e.self:CastSpell(BREATH, c:GetID())
		end
		eq.set_timer("breath", 25000)
	elseif e.timer == "claw" then
		local t = R.alive_clients(MY_X, MY_Y, 400)
		if #t > 0 then
			local v = t[math.random(#t)]
			eq.zone_emote(13, "A razor claw of ice lashes " .. v:GetCleanName() .. "!")
			e.self:CastSpell(CLAW, v:GetID())
		end
		eq.set_timer("claw", 30000)
	elseif e.timer == "freeze" then
		freeze_raid(e)
		eq.set_timer("freeze", 65000)
	end
end

-- 3 people clicking the Igneous Ember on a frozen victim thaws them
function event_say(e)
	if e.message:findi("thaw") then
		e.self:Say("Only three live embers, clicked together, will thaw the frozen.")
	end
end

function event_death_complete(e)
	eq.stop_timer("breath")
	eq.stop_timer("claw")
	eq.stop_timer("freeze")
	R.chest(e.self, CHEST, "Crystallos: Ice Constructs")
	R.signal(R.SIG.ice)
	eq.zone_emote(15, "Zeixshi`Kar cracks and dissolves into drifting snow.")
end
