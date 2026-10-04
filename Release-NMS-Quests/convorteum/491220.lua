-- Unstable_Creation (491220) -- Convorteum v1, stage 3.
-- Tracked source: Release-NMS-Quests/convorteum/491220.lua.
-- Rasper: miscRaidProg.html.
--
-- Every 25s a wild flux discharge on a random raider (8k); every 45s two
-- unstable motes -- a mote that lives 25s detonates for 5k. Signals the
-- controller (2003).

local prog = require("uf_progression")

local CTRL = prog.NPC.conv_ctrl
local MOTE = 491263

local engaged = false
local adds = {}

local function engage(e)
	if engaged then return end
	engaged = true
	eq.set_timer("flux", 25000)
	eq.set_timer("motes", 45000)
	eq.zone_emote(15, "The Unstable Creation flickers between shapes that were never finished.")
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
			prog.clear_adds(adds)
			adds = {}
			for _, t in ipairs({ "flux", "motes", "mote_boom" }) do eq.stop_timer(t) end
			e.self:Heal()
			eq.zone_emote(15, "The Unstable Creation goes still. The event has reset.")
		end
		return
	end
	if not engaged then return end
	local x, y = e.self:GetX(), e.self:GetY()

	if e.timer == "flux" then
		local targets = prog.alive_clients(x, y, 300)
		if #targets > 0 then
			local victim = targets[math.random(#targets)]
			eq.zone_emote(13, "Wild flux discharges through " .. victim:GetCleanName() .. "!")
			victim:Damage(e.self, 8000, 0, 28)
		end
	elseif e.timer == "motes" then
		for i = 1, 2 do
			local m = eq.spawn2(MOTE, 0, 0, x + math.random(-50, 50),
				y + math.random(-50, 50), e.self:GetZ(), 0)
			if m then adds[#adds + 1] = m:GetID() end
		end
		eq.set_timer("mote_boom", 25000)
		eq.zone_emote(15, "Unstable motes break off -- do not let them linger!")
	elseif e.timer == "mote_boom" then
		local el = eq.get_entity_list()
		local alive = false
		for _, id in ipairs(adds) do
			local m = el:GetNPCByID(id)
			if m and m.valid then
				alive = true
				break
			end
		end
		if alive then
			eq.zone_emote(13, "An unstable mote detonates!")
			for _, c in ipairs(prog.alive_clients(x, y, 200)) do
				c:Damage(e.self, 5000, 0, 28)
			end
		end
		prog.clear_adds(adds)
		adds = {}
	end
end

function event_death_complete(e)
	prog.clear_adds(adds)
	adds = {}
	for _, t in ipairs({ "flux", "motes", "mote_boom" }) do eq.stop_timer(t) end
	eq.zone_emote(15, "The Unstable Creation stabilizes -- into death. The Third Ward is broken.")
	eq.signal(CTRL, 2003)
end
