-- [[
-- Entharr (446200) -- Crystallos raid, Halls of Fire (wing minor).
-- Rasper: raidCrystallos.html (Halls of Fire).
--
-- Rooted in place; hits to ~10k, single + AE rampage, flurries.
--   * Word of Law (12941)  -- short 1k mana+endurance drain
--   * Confounding Pronouncement (12942) -- AE melee+spell slow
--   * self 755pt melee DS
-- On death: chest Treasure_of_Entharr (446260) + fire-wing lockout.
--
-- The dragon-head statues lining the hall cast a 17.5k directed AE in front
-- of them (modelled as a periodic warning + frontal nuke on the tank).
--]]

local CHEST = 446260
local CONTROLLER = 446240
local SIG_FIRE = 1001

local MY_X, MY_Y = -1180, -460

local engaged = false
local adds = {}

local function alive_clients(r)
	local out = {}
	local list = eq.get_entity_list():GetClientList()
	if not list then return out end
	for c in list.entries do
		if c and c:GetHPRatio() > 0 and math.abs(c:GetX() - MY_X) <= r
			and math.abs(c:GetY() - MY_Y) <= r then
			out[#out + 1] = c
		end
	end
	return out
end

local function clear_adds()
	for _, id in ipairs(adds) do
		local m = eq.get_entity_list():GetNPCByID(id)
		if m and m.valid then m:Depop() end
	end
	adds = {}
end

local function spawn_chest(e)
	local exp = eq.get_expedition()
	if not exp.valid then return end
	local c = eq.unique_spawn(CHEST, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ() + 5, 0)
	if c then exp:SetLootEventBySpawnID(c:GetID(), "Crystallos: Halls of Fire") end
end

local function engage(e)
	if engaged then return end
	engaged = true
	-- self melee DS (755)
	e.self:CastSpell(1240, e.self:GetID())  -- flame shield style (self DS)
	eq.set_timer("wordoflaw", 20000)
	eq.set_timer("confound", 45000)
	eq.set_timer("statues", 25000)
	eq.zone_emote(15, "Entharr's scales flare with heat. 'The fire will consume you.'")
end

function event_combat(e)
	if e.joined then
		engage(e)
		eq.stop_timer("resetcheck")
	else
		eq.set_timer("resetcheck", 60000)
	end
end

function event_timer(e)
	if e.timer == "resetcheck" then
		if not e.self:IsEngaged() then
			engaged = false
			clear_adds()
			for _, t in ipairs({ "wordoflaw", "confound", "statues" }) do eq.stop_timer(t) end
			e.self:Heal()
		end
		return
	end
	if not engaged then return end

	if e.timer == "wordoflaw" then
		local t = alive_clients(300)
		if #t > 0 then
			eq.zone_emote(13, "Entharr intones a Word of Law!")
			for _, c in ipairs(t) do c:SetMana(c:GetMana() - 1000) end
		end
		eq.set_timer("wordoflaw", 20000)
	elseif e.timer == "confound" then
		eq.zone_emote(15, "Entharr's pronouncement confounds your weapons and spells!")
		-- soft melee/slow flavour (no hard haste API on clients here)
		eq.set_timer("confound", 45000)
	elseif e.timer == "statues" then
		-- dragon-head statues: 17.5k directed AE to whoever stands directly ahead
		local t = alive_clients(350)
		if #t > 0 then
			local victim = t[math.random(#t)]
			eq.zone_emote(13, "A dragon-head statue vents fire straight ahead, catching " .. victim:GetCleanName() .. "!")
			victim:Damage(e.self, 17500, 0, 2)
		end
		eq.set_timer("statues", 25000)
	end
end

function event_death_complete(e)
	clear_adds()
	eq.stop_timer("wordoflaw")
	eq.stop_timer("confound")
	eq.stop_timer("statues")
	spawn_chest(e)
	eq.signal(CONTROLLER, SIG_FIRE)
	eq.zone_emote(15, "Entharr crumbles into ash. The Halls of Fire fall silent.")
end
