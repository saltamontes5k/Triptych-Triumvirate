-- Xadrith the Voice (478715) -- SoD raid: Eriak's Downfall, phase 1.
-- Rasper: raidRathe3.html.
--
-- Simplified live encounter (Beguilement charm, Discordant Feedback and the
-- Kyv stand-still/move/duck death-touch prompts are not modelled):
--   * Permarooted (live) -- the script holds him at his spawn.
--   * Ra'tuk adds        -- two every 45s (live: mezzable; unhandled adds
--                           spawn more adds).
--   * Color Blaze        -- 5k AE every 60s.
-- On death: Eriak Dechard awakens (signal).

local raid = require("sod_raids")

local engaged = false
local adds = {}

local function clear_adds()
	local el = eq.get_entity_list()
	for _, id in ipairs(adds) do
		local mob = el:GetNPCByID(id)
		if mob and mob.valid then mob:Depop() end
	end
	adds = {}
end

function event_spawn(e)
	-- hold position (live: permaroot)
	e.self:SetEntityVariable("home_x", tostring(e.self:GetX()))
	e.self:SetEntityVariable("home_y", tostring(e.self:GetY()))
end

function event_combat(e)
	if e.joined then
		if not engaged then
			engaged = true
			eq.set_timer("adds", 45000)
			eq.set_timer("blaze", 60000)
			eq.zone_emote(15, "Xadrith the Voice shrieks, 'You trespass on the Voice of the Rallosian Empire!'")
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
			clear_adds()
			for _, t in ipairs({ "adds", "blaze" }) do eq.stop_timer(t) end
			pcall(function() e.self:GotoBind() end) -- back to the rooted spawn
			e.self:Heal()
			eq.zone_emote(15, "Xadrith falls silent once more.")
		end
		return
	end
	if not engaged then return end

	if e.timer == "adds" then
		for i = 1, 2 do
			local mob = raid.spawn_add(raid.ADD.ratuk, e.self, 50)
			if mob then
				adds[#adds + 1] = mob:GetID()
				local targets = raid.alive_clients(e.self:GetX(), e.self:GetY(), 300)
				if #targets > 0 then
					mob:AddToHateList(targets[math.random(#targets)], 1000, 10000)
				end
			end
		end
		eq.zone_emote(15, "Ra'tuk guardians answer the Voice's call!")
	elseif e.timer == "blaze" then
		eq.zone_emote(15, "Xadrith blazes with coruscating color!")
		for _, client in ipairs(raid.alive_clients(e.self:GetX(), e.self:GetY(), 200)) do
			raid.hit(e.self, client, 5000)
		end
	end
end

function event_death_complete(e)
	clear_adds()
	eq.zone_emote(15, "The Voice is silenced. From the deep chamber, Eriak Dechard stirs...")
	eq.signal(raid.CTRL.ERIAK, 1)
	eq.signal(478716, 1) -- awaken Eriak
end
