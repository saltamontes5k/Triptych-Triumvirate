-- Vzarn_the_Cunning (487120) -- Lichen Creep v1 raid "A Cunning Plan".
-- Tracked source: Release-NMS-Quests/lichencreep/487120.lua.
-- Rasper: miscRaidProg.html.
--
-- Simplified live encounter:
--   * every 30s he relocates within his warren ("always three steps ahead");
--   * every 45s two decoys split off -- a decoy that lives 20s detonates
--     for 6k;
--   * 50% -- the plan unfolds: four lost autarchians join.
-- On death: Treasure_of_a_Cunning_Plan chest (6 Amulets) + 72h lockout.

local prog = require("uf_progression")

local DECOY = 487121
local ADD = 487012
local CHEST = prog.CHEST.cunning
local LOCKOUT = eq.seconds("72h")

local engaged = false
local adds50_done = false
local adds = {}
local decoys = {}

local function engage(e)
	if engaged then return end
	engaged = true
	eq.set_timer("relocate", 30000)
	eq.set_timer("decoys", 45000)
	eq.zone_emote(15, "Vzarn steps out of the creep, applauding slowly. 'So. You took the bait.'")
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
			adds50_done = false
			prog.clear_adds(adds)
			prog.clear_adds(decoys)
			adds = {}
			decoys = {}
			for _, t in ipairs({ "relocate", "decoys", "decoy_boom" }) do eq.stop_timer(t) end
			e.self:Heal()
			eq.zone_emote(15, "Vzarn melts into the creep. The event has reset.")
		end
		return
	end
	if not engaged then return end

	if e.timer == "relocate" then
		eq.zone_emote(13, "Vzarn is suddenly elsewhere -- always three steps ahead.")
		e.self:GMMove(e.self:GetX() + math.random(-100, 100),
			e.self:GetY() + math.random(-100, 100), e.self:GetZ())
	elseif e.timer == "decoys" then
		for i = 1, 2 do
			local m = eq.spawn2(DECOY, 0, 0, e.self:GetX() + math.random(-40, 40),
				e.self:GetY() + math.random(-40, 40), e.self:GetZ(), 0)
			if m then decoys[#decoys + 1] = m:GetID() end
		end
		eq.set_timer("decoy_boom", 20000)
		eq.zone_emote(15, "Two of Vzarn is two too many -- kill the real threat's decoys!")
	elseif e.timer == "decoy_boom" then
		local el = eq.get_entity_list()
		local alive = false
		for _, id in ipairs(decoys) do
			local m = el:GetNPCByID(id)
			if m and m.valid then
				alive = true
				break
			end
		end
		if alive then
			eq.zone_emote(13, "A decoy bursts in a coruscating trap!")
			for _, c in ipairs(prog.alive_clients(e.self:GetX(), e.self:GetY(), 250)) do
				c:Damage(e.self, 6000, 0, 28)
			end
		end
		prog.clear_adds(decoys)
		decoys = {}
	end

	if not adds50_done and e.self:GetHPRatio() <= 50 then
		adds50_done = true
		for i = 1, 4 do
			local m = eq.spawn2(ADD, 0, 0, e.self:GetX() + math.random(-60, 60),
				e.self:GetY() + math.random(-60, 60), e.self:GetZ(), 0)
			if m then adds[#adds + 1] = m:GetID() end
		end
		eq.zone_emote(15, "The plan unfolds -- Vzarn's lost autarchians emerge!")
	end
end

function event_death_complete(e)
	prog.clear_adds(adds)
	prog.clear_adds(decoys)
	adds = {}
	decoys = {}
	for _, t in ipairs({ "relocate", "decoys", "decoy_boom" }) do eq.stop_timer(t) end
	eq.zone_emote(15, "Vzarn falls mid-gloat. So much for the cunning plan.")
	prog.spawn_chest(e, CHEST, "A Cunning Plan")
	local exp = eq.get_expedition()
	if exp.valid and not exp:HasLockout("A Cunning Plan") then
		exp:AddLockout("A Cunning Plan", LOCKOUT)
	end
end
