-- Brell_Serilis (490041) -- Brell's Temple v3, An Audience with Brell.
-- Tracked source: Release-NMS-Quests/brellstemple/490041.lua.
-- Rasper: miscRaidProg.html.
--
-- The existing PEQ #Brell_Serilis, raised onto the raid envelope and
-- script-spawned/static only inside the v3 audience instance: this script
-- is inert outside instance version 3 (the unreachable v0 static keeps
-- its own peace).
--
-- Simplified live encounter:
--   * three serilian attendants greet the raid on engage;
--   * every 40s earthen wrath (8k AE, 250 range);
--   * every 90s, once the attendants fall, the mountain answers -- two
--     gem golems;
--   * 50% -- the mountain's rebuke: 12k on three raiders;
--   * 20% -- the final word: 15k AE.
-- On death: Treasure_of_Brell_Serilis chest (9 Amulets), 72h lockout, and
-- the brell_audience flag for surviving raiders.

local prog = require("uf_progression")

local ATT_A, ATT_B, ATT_C = 490141, 490142, 490143
local GEM_GOLEM = 490144
local CHEST = prog.CHEST.audience
local LOCKOUT = eq.seconds("72h")
local INSTANCE_V3 = 3

local engaged = false
local rebuke50_done = false
local final20_done = false
local golems_open = false
local adds = {}

local function engage(e)
	if engaged then return end
	engaged = true
	eq.set_timer("wrath", 40000)
	eq.set_timer("mountain", 90000)
	for _, tpl in ipairs({ ATT_A, ATT_B, ATT_C }) do
		local m = eq.spawn2(tpl, 0, 0, e.self:GetX() + math.random(-45, 45),
			e.self:GetY() + math.random(-45, 45), e.self:GetZ(), 0)
		if m then adds[#adds + 1] = m:GetID() end
	end
	eq.zone_emote(15, "Brell Serilis regards you from his throne of the world's bones. 'SPEAK, OR LEAVE.'")
end

function event_combat(e)
	if eq.get_zone_instance_version() ~= INSTANCE_V3 then return end
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
			rebuke50_done = false
			final20_done = false
			golems_open = false
			prog.clear_adds(adds)
			adds = {}
			for _, t in ipairs({ "wrath", "mountain" }) do eq.stop_timer(t) end
			e.self:Heal()
			eq.zone_emote(15, "Brell returns to his throne. The audience has reset.")
		end
		return
	end
	if not engaged then return end
	local x, y = e.self:GetX(), e.self:GetY()

	if e.timer == "wrath" then
		eq.zone_emote(13, "Brell's earthen wrath rolls through the innermost hall!")
		for _, c in ipairs(prog.alive_clients(x, y, 250)) do
			c:Damage(e.self, 8000, 0, 28)
		end
	elseif e.timer == "mountain" then
		if golems_open then
			for i = 1, 2 do
				local m = eq.spawn2(GEM_GOLEM, 0, 0, x + math.random(-60, 60),
					y + math.random(-60, 60), e.self:GetZ(), 0)
				if m then adds[#adds + 1] = m:GetID() end
			end
			eq.zone_emote(15, "THE MOUNTAIN ANSWERS -- gem golems rise from the floor!")
		else
			-- attendants still standing: the mountain holds its peace
			eq.zone_emote(13, "The attendants hold the mountain's attention.")
		end
	end

	local ratio = e.self:GetHPRatio()
	-- once the attendants are down, the mountain will answer
	local el = eq.get_entity_list()
	local att_alive = false
	for _, id in ipairs(adds) do
		local m = el:GetNPCByID(id)
		if m and m.valid then
			att_alive = true
			break
		end
	end
	if not att_alive and not golems_open then
		golems_open = true
		eq.zone_emote(15, "Brell's attendants are slain. The mountain itself listens now.")
	end

	if not rebuke50_done and ratio <= 50 then
		rebuke50_done = true
		local targets = prog.alive_clients(x, y, 300)
		for i = 1, math.min(3, #targets) do
			local victim = targets[math.random(#targets)]
			eq.zone_emote(13, "The mountain rebukes " .. victim:GetCleanName() .. "!")
			victim:Damage(e.self, 12000, 0, 28)
		end
	end
	if not final20_done and ratio <= 20 then
		final20_done = true
		eq.zone_emote(13, "'THE FINAL WORD,' BRELL THUNDERS, AND THE WORLD AGREES.")
		for _, c in ipairs(prog.alive_clients(x, y, 300)) do
			c:Damage(e.self, 15000, 0, 28)
		end
	end
end

function event_death_complete(e)
	prog.clear_adds(adds)
	adds = {}
	for _, t in ipairs({ "wrath", "mountain" }) do eq.stop_timer(t) end
	eq.zone_emote(15, "Brell Serilis bows his head. 'WELL FOUGHT. THE HEART OF THE UNDERFOOT AWAITS ITS OWNERS.'")
	prog.spawn_chest(e, CHEST, "An Audience with Brell Serilis")
	local exp = eq.get_expedition()
	if exp.valid and not exp:HasLockout("An Audience with Brell Serilis") then
		exp:AddLockout("An Audience with Brell Serilis", LOCKOUT)
	end
	for _, c in ipairs(prog.alive_clients(e.self:GetX(), e.self:GetY(), 300)) do
		prog.set(c, prog.FLG.brell_audience, 1)
		c:Message(15, "You have been received by Brell Serilis. The Convorteum awaits.")
	end
end
