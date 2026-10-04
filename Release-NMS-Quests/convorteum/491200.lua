-- The_Gatekeeper (491200) -- Convorteum v1, stage 1.
-- Tracked source: Release-NMS-Quests/convorteum/491200.lua.
-- Rasper: miscRaidProg.html.
--
-- Every 40s a door wardens call -- two door wardens join; every 25s a
-- gate slam (7k AE, 150 range). Signals the controller (2001) on death.

local prog = require("uf_progression")

local CTRL = prog.NPC.conv_ctrl
local ADD = 491261

local engaged = false
local adds = {}

local function engage(e)
	if engaged then return end
	engaged = true
	eq.set_timer("wardens", 40000)
	eq.set_timer("slam", 25000)
	eq.zone_emote(15, "The Gatekeeper unbars its mace. 'THE FIRST WARD IS TESTED.'")
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
			for _, t in ipairs({ "wardens", "slam" }) do eq.stop_timer(t) end
			e.self:Heal()
			eq.zone_emote(15, "The Gatekeeper resumes its vigil. The event has reset.")
		end
		return
	end
	if not engaged then return end
	local x, y = e.self:GetX(), e.self:GetY()

	if e.timer == "wardens" then
		for i = 1, 2 do
			local m = eq.spawn2(ADD, 0, 0, x + math.random(-50, 50),
				y + math.random(-50, 50), e.self:GetZ(), 0)
			if m then adds[#adds + 1] = m:GetID() end
		end
		eq.zone_emote(15, "Door wardens answer the Gatekeeper's call!")
	elseif e.timer == "slam" then
		eq.zone_emote(13, "The Gatekeeper slams its mace -- the ward shakes!")
		for _, c in ipairs(prog.alive_clients(x, y, 150)) do
			c:Damage(e.self, 7000, 0, 28)
		end
	end
end

function event_death_complete(e)
	prog.clear_adds(adds)
	adds = {}
	for _, t in ipairs({ "wardens", "slam" }) do eq.stop_timer(t) end
	eq.zone_emote(15, "The Gatekeeper falls. The First Ward is broken.")
	eq.signal(CTRL, 2001)
end
