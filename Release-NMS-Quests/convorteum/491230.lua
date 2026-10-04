-- The_Keymaster (491230) -- Convorteum v1, stage 4.
-- Tracked source: Release-NMS-Quests/convorteum/491230.lua.
-- Rasper: miscRaidProg.html.
--
-- Every 35s he locks a random raider in a cage of keys (root emote + 3k);
-- every 50s two key thieves join. Signals the controller (2004).

local prog = require("uf_progression")

local CTRL = prog.NPC.conv_ctrl
local THIEF = 491264

local engaged = false
local adds = {}

local function engage(e)
	if engaged then return end
	engaged = true
	eq.set_timer("lock", 35000)
	eq.set_timer("thieves", 50000)
	eq.zone_emote(15, "The Keymaster jingles. 'EVERY DOOR HAS ITS KEY. EVERY RAID HAS ITS PRICE.'")
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
			for _, t in ipairs({ "lock", "thieves" }) do eq.stop_timer(t) end
			e.self:Heal()
			eq.zone_emote(15, "The Keymaster pockets his rings. The event has reset.")
		end
		return
	end
	if not engaged then return end
	local x, y = e.self:GetX(), e.self:GetY()

	if e.timer == "lock" then
		local targets = prog.alive_clients(x, y, 250)
		if #targets > 0 then
			local victim = targets[math.random(#targets)]
			eq.zone_emote(13, victim:GetCleanName() .. " is locked in a cage of keys!")
			victim:Damage(e.self, 3000, 0, 28)
			victim:Stun(5000)
		end
	elseif e.timer == "thieves" then
		for i = 1, 2 do
			local m = eq.spawn2(THIEF, 0, 0, x + math.random(-50, 50),
				y + math.random(-50, 50), e.self:GetZ(), 0)
			if m then adds[#adds + 1] = m:GetID() end
		end
		eq.zone_emote(15, "Key thieves swarm out to pick your pockets clean!")
	end
end

function event_death_complete(e)
	prog.clear_adds(adds)
	adds = {}
	for _, t in ipairs({ "lock", "thieves" }) do eq.stop_timer(t) end
	eq.zone_emote(15, "The Keymaster drops every key he ever stole. The Fourth Ward is broken.")
	eq.signal(CTRL, 2004)
end
