-- the_Masked_Hierarch (486230) -- Foundation v1 raid "Masked Invaders".
-- Tracked source: Release-NMS-Quests/foundation/486230.lua.
-- Rasper: miscRaidProg.html.
--
-- Simplified live encounter (bellikos in masks):
--   * three invasion waves, 60s apart -- three masked champions each;
--   * every 25s a hierarch's decree (6k AE, 200 range);
--   * 60% and 30% -- two champions join from the wings.
-- On death: Treasure_of_the_Masked_Invaders chest + 72h lockout.

local prog = require("uf_progression")

local CHAMPION = 486220
local CHEST = prog.CHEST.masked
local LOCKOUT = eq.seconds("72h")

local engaged = false
local waves_done = false
local adds60_done = false
local adds30_done = false
local adds = {}

local function spawn_champions(e, n)
	local x, y = e.self:GetX(), e.self:GetY()
	local targets = prog.alive_clients(x, y, 300)
	for i = 1, n do
		local m = eq.spawn2(CHAMPION, 0, 0, x + math.random(-60, 60),
			y + math.random(-60, 60), e.self:GetZ(), 0)
		if m then
			adds[#adds + 1] = m:GetID()
			if #targets > 0 then
				m:AddToHateList(targets[math.random(#targets)], 500, 5000)
			end
		end
	end
end

local function engage(e)
	if engaged then return end
	engaged = true
	eq.set_timer("waves", 60000)
	eq.set_timer("decree", 25000)
	eq.zone_emote(15, "THE MASKED INVADERS POUR FROM THE LOWER WORKS!")
	spawn_champions(e, 3)
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
			waves_done = false
			adds60_done = false
			adds30_done = false
			prog.clear_adds(adds)
			adds = {}
			for _, t in ipairs({ "waves", "decree" }) do eq.stop_timer(t) end
			e.self:Heal()
			eq.zone_emote(15, "The masked ones melt back into the works. The event has reset.")
		end
		return
	end
	if not engaged then return end
	local x, y = e.self:GetX(), e.self:GetY()

	if e.timer == "waves" then
		if waves_done then
			eq.stop_timer("waves")
			return
		end
		spawn_champions(e, 3)
		eq.zone_emote(15, "Another wave of masked champions storms the floor!")
	elseif e.timer == "decree" then
		eq.zone_emote(13, "The Hierarch issues a decree -- the very air burns!")
		for _, c in ipairs(prog.alive_clients(x, y, 200)) do
			c:Damage(e.self, 6000, 0, 28)
		end
	end

	local ratio = e.self:GetHPRatio()
	if not adds60_done and ratio <= 60 then
		adds60_done = true
		spawn_champions(e, 2)
		eq.zone_emote(15, "Champions emerge from the side galleries!")
	end
	if not adds30_done and ratio <= 30 then
		adds30_done = true
		waves_done = true
		spawn_champions(e, 2)
		eq.zone_emote(15, "The last of the masked host throws itself at you!")
	end
end

function event_death_complete(e)
	prog.clear_adds(adds)
	adds = {}
	for _, t in ipairs({ "waves", "decree" }) do eq.stop_timer(t) end
	eq.zone_emote(15, "The Masked Hierarch falls. The invasion collapses.")
	prog.spawn_chest(e, CHEST, "Masked Invaders")
	local exp = eq.get_expedition()
	if exp.valid and not exp:HasLockout("Masked Invaders") then
		exp:AddLockout("Masked Invaders", LOCKOUT)
	end
end
