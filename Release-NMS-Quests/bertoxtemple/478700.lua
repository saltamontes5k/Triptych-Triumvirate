-- Rottrued the Twisted (478700) -- SoD raid: Stop the Ascension, phase 2.
-- Rasper: raidOG2.html.
--
-- Simplified live encounter (the 8-camp martyr phase and the spawn-tether
-- penalties are not modelled; raid engages Rottrued directly):
--   * Draw of the Void -- random client 6.5k every 40s.
--   * 75%              -- three Wrext Mal mundunugu (dark ritualists,
--                         mezzable) pour in.
--   * 50%              -- resist shift: gains spell resistance (emote) and
--                         starts a recurring 8k AE every 30s (live: rare DT).
-- On death: Treasure_of_Rottrued chest + controller lockout.

local raid = require("sod_raids")

local engaged = false
local adds75_done = false
local ae50_on = false
local adds = {}

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
	adds75_done = false
	ae50_on = false
	clear_adds()
	for _, t in ipairs({ "draw", "fury", "resetcheck" }) do
		eq.stop_timer(t)
	end
	e.self:Heal()
	eq.zone_emote(15, "Rottrued's chant falters and dies. The ascension is halted -- for now.")
end

function event_combat(e)
	if e.joined then
		if not engaged then
			engaged = true
			eq.set_timer("draw", 40000)
			eq.zone_emote(15, "Rottrued the Twisted cries out, 'The Wrext Mal rise! Bertoxxulous ascends!'")
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

	if e.timer == "draw" then
		local victim = raid.random_client(e.self:GetX(), e.self:GetY(), 300)
		if victim then
			eq.zone_emote(15, "The void draws at " .. victim:GetCleanName() .. "!")
			raid.hit(e.self, victim, 6500)
		end
	elseif e.timer == "fury" then
		eq.zone_emote(15, "Rottrued unleashes a screeching fury!")
		for _, client in ipairs(raid.alive_clients(e.self:GetX(), e.self:GetY(), 200)) do
			raid.hit(e.self, client, 8000)
		end
	end

	-- 75%: mundunugu wave
	if not adds75_done and e.self:GetHPRatio() <= 75 then
		adds75_done = true
		for i = 1, 3 do
			local mob = raid.spawn_add(raid.ADD.ritualist, e.self, 45)
			if mob then
				adds[#adds + 1] = mob:GetID()
				local targets = raid.alive_clients(e.self:GetX(), e.self:GetY(), 300)
				if #targets > 0 then
					mob:AddToHateList(targets[math.random(#targets)], 1000, 10000)
				end
			end
		end
		eq.zone_emote(15, "Twisted mundunugu claw their way out of the temple floor!")
	end

	-- 50%: recurring AE
	if not ae50_on and e.self:GetHPRatio() <= 50 then
		ae50_on = true
		eq.zone_emote(15, "Rottrued's flesh turns aside spell and steel alike -- he begins to chant a screeching fury.")
		eq.set_timer("fury", 30000)
	end
end

function event_death_complete(e)
	clear_adds()
	eq.stop_timer("fury")
	eq.zone_emote(15, "Rottrued collapses, his ascension unmade. A hidden agent moves in the shadows.")
	raid.spawn_chest(e, raid.CHEST.ROTT)
	eq.signal(raid.CTRL.ROTT, 1)
end
