-- The_Hall_of_Records (491240) -- Convorteum v1, stage 5.
-- Tracked source: Release-NMS-Quests/convorteum/491240.lua.
-- Rasper: miscRaidProg.html.
--
-- Every 40s the archive speaks -- two living records join; every 30s an
-- unrecorded scream (5k AE, 200 range). Signals the controller (2005).

local prog = require("uf_progression")

local CTRL = prog.NPC.conv_ctrl
local ADD = 491265

local engaged = false
local adds = {}

local function engage(e)
	if engaged then return end
	engaged = true
	eq.set_timer("records", 40000)
	eq.set_timer("scream", 30000)
	eq.zone_emote(15, "The Hall of Records unfolds, every page of it alive and angry.")
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
			for _, t in ipairs({ "records", "scream" }) do eq.stop_timer(t) end
			e.self:Heal()
			eq.zone_emote(15, "The Hall of Records closes. The event has reset.")
		end
		return
	end
	if not engaged then return end
	local x, y = e.self:GetX(), e.self:GetY()

	if e.timer == "records" then
		for i = 1, 2 do
			local m = eq.spawn2(ADD, 0, 0, x + math.random(-50, 50),
				y + math.random(-50, 50), e.self:GetZ(), 0)
			if m then adds[#adds + 1] = m:GetID() end
		end
		eq.zone_emote(15, "Living records fling themselves from the shelves!")
	elseif e.timer == "scream" then
		eq.zone_emote(13, "The Hall screams with every name it has ever recorded!")
		for _, c in ipairs(prog.alive_clients(x, y, 200)) do
			c:Damage(e.self, 5000, 0, 28)
		end
	end
end

function event_death_complete(e)
	prog.clear_adds(adds)
	adds = {}
	for _, t in ipairs({ "records", "scream" }) do eq.stop_timer(t) end
	eq.zone_emote(15, "The Hall of Records burns to its last page. The Fifth Ward is broken.")
	eq.signal(CTRL, 2005)
end
