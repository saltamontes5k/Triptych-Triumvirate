-- Chief_Mechanic_Clankwrench (438612) -- Secrets of Faydwer Steam Factory raid, event 3.
-- Tracked source: Release-NMS-Quests/steamfactory/438612.lua.
-- Rasper: raidSteam.html.
--
-- Simplified live encounter (the directional Steam Jet facing puzzle becomes a
-- kill-the-suit unlock, and the 50s damage-metered AE becomes a fixed blast):
--   * absorption panels -- alternating melee/caster emote, then a 12k AE
--     after an 8s warning (live scales 6k-20k by damage done in the window).
--   * health locks at 70/60/50/40/30/20/10% -- a modified steamsuit spawns and
--     Clankwrench is held at that health until the suit is destroyed.
-- On death: spawns the punchable Treasure_of_Chief_Mechanic_Clankwrench chest.

local SUIT  = 438640
local CHEST = 438652

local MY_X, MY_Y, MY_Z = -1179.875, 1604.125, 160.125

local engaged = false
local lock_pct = 70
local locked = false
local adds = {}

local function alive_clients(radius)
	local out = {}
	local clients = eq.get_entity_list():GetClientList()
	if not clients then return out end
	for client in clients.entries do
		if client and client:GetHPRatio() > 0
			and math.abs(client:GetX() - MY_X) <= (radius or 300)
			and math.abs(client:GetY() - MY_Y) <= (radius or 300) then
			out[#out + 1] = client
		end
	end
	return out
end

local function clear_adds()
	local el = eq.get_entity_list()
	for _, id in ipairs(adds) do
		local mob = el:GetNPCByID(id)
		if mob and mob.valid then mob:Depop() end
	end
	adds = {}
end

local function spawn_chest(e)
	local expedition = eq.get_expedition()
	if not expedition.valid then return end
	local x, y, z = e.self:GetX(), e.self:GetY(), e.self:GetZ()
	local chest = eq.unique_spawn(CHEST, 0, 0, x, y, z + 5, 0)
	if chest ~= nil then
		expedition:SetLootEventBySpawnID(chest:GetID(), "Chief Mechanic Clankwrench")
	end
end

local function engage(e)
	if engaged then return end
	engaged = true
	eq.set_timer("absorb", 60000)
	eq.set_timer("lockcheck", 2000)
	eq.zone_emote(15, "Chief Mechanic Clankwrench grinds forward, gears howling. 'SCRAP THEM ALL!'")
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
			locked = false
			lock_pct = 70
			clear_adds()
			for _, t in ipairs({ "absorb", "absorb_boom", "lockcheck" }) do
				eq.stop_timer(t)
			end
			e.self:SetEntityVariable("suit_id", "0")
			e.self:Heal()
			eq.zone_emote(15, "Clankwrench powers down. The event has reset.")
		end
		return
	end
	if not engaged then return end

	if e.timer == "absorb" then
		local mode = e.self:GetEntityVariable("absorb_mode") or ""
		if mode == "melee" then
			e.self:SetEntityVariable("absorb_mode", "caster")
			eq.zone_emote(15, "Clankwrench says, 'Activate spell shields! We'll see how they do without their precious magics!'")
		else
			e.self:SetEntityVariable("absorb_mode", "melee")
			eq.zone_emote(15, "Clankwrench says, 'Activate absorption panels! We'll take advantage of the energy they're putting into this beating!'")
		end
		eq.set_timer("absorb_boom", 8000)
	elseif e.timer == "absorb_boom" then
		eq.zone_emote(15, "The absorption panels discharge at the raid!")
		for _, client in ipairs(alive_clients(200)) do
			client:Damage(e.self, 12000, 0, 28)
		end
	elseif e.timer == "lockcheck" then
		if locked then
			local sid = tonumber(e.self:GetEntityVariable("suit_id") or "0") or 0
			local suit = (sid > 0) and eq.get_entity_list():GetNPCByID(sid) or nil
			if suit and suit.valid and suit:GetHPRatio() > 0 then
				-- hold Clankwrench at the lock until the suit is destroyed
				local maxhp = e.self:GetMaxHP()
				local floorhp = math.floor(maxhp * lock_pct / 100)
				if e.self:GetHP() < floorhp then
					e.self:SetHP(floorhp)
				end
			else
				locked = false
				e.self:SetEntityVariable("suit_id", "0")
				lock_pct = lock_pct - 10
				eq.zone_emote(15, "The modified steamsuit vents its Steam Jet across Clankwrench -- the lock fails!")
			end
		elseif lock_pct >= 10 and e.self:GetHPRatio() <= lock_pct then
			local x, y, z = e.self:GetX(), e.self:GetY(), e.self:GetZ()
			local suit = eq.spawn2(SUIT, 0, 0, x + 25, y, z, 0)
			if suit then
				adds[#adds + 1] = suit:GetID()
				e.self:SetEntityVariable("suit_id", tostring(suit:GetID()))
				locked = true
				local maxhp = e.self:GetMaxHP()
				e.self:SetHP(math.floor(maxhp * lock_pct / 100))
				eq.zone_emote(15, "Clankwrench's health locks at " .. lock_pct .. "%! A modified steamsuit activates -- destroy it to break the lock!")
			end
		end
	end
end

function event_death_complete(e)
	clear_adds()
	for _, t in ipairs({ "absorb", "absorb_boom", "lockcheck" }) do
		eq.stop_timer(t)
	end
	eq.zone_emote(15, "Chief Mechanic Clankwrench grinds to a halt and topples from the catwalk.")
	spawn_chest(e)
end
