-- The_Stone_Warden (491210) -- Convorteum v1, stage 2.
-- Tracked source: Release-NMS-Quests/convorteum/491210.lua.
-- Rasper: miscRaidProg.html.
--
-- Self stone DS on engage; every 30s shards shed (5k AE, 200 range);
-- every 90s two shed shards fight as adds. Signals the controller (2002).

local prog = require("uf_progression")

local CTRL = prog.NPC.conv_ctrl
local ADD = 491262

local engaged = false
local adds = {}

local function engage(e)
	if engaged then return end
	engaged = true
	eq.set_timer("shed", 30000)
	eq.set_timer("shards", 90000)
	eq.zone_emote(15, "The Stone Warden grinds awake, rock screaming on rock.")
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
			for _, t in ipairs({ "shed", "shards" }) do eq.stop_timer(t) end
			e.self:Heal()
			eq.zone_emote(15, "The Stone Warden settles back into the wall. The event has reset.")
		end
		return
	end
	if not engaged then return end
	local x, y = e.self:GetX(), e.self:GetY()

	if e.timer == "shed" then
		eq.zone_emote(13, "The Stone Warden sheds its skin in an explosion of shards!")
		for _, c in ipairs(prog.alive_clients(x, y, 200)) do
			c:Damage(e.self, 5000, 0, 28)
		end
	elseif e.timer == "shards" then
		for i = 1, 2 do
			local m = eq.spawn2(ADD, 0, 0, x + math.random(-50, 50),
				y + math.random(-50, 50), e.self:GetZ(), 0)
			if m then adds[#adds + 1] = m:GetID() end
		end
		eq.zone_emote(15, "Shed shards knit themselves into fighting shapes!")
	end
end

function event_death_complete(e)
	prog.clear_adds(adds)
	adds = {}
	for _, t in ipairs({ "shed", "shards" }) do eq.stop_timer(t) end
	eq.zone_emote(15, "The Stone Warden crumbles. The Second Ward is broken.")
	eq.signal(CTRL, 2002)
end
