-- Falrazim (442086) -- NW caves, Dragonscale Hills. Group target requests:
-- Deepscar's Den (dragonscaleb version 51) and Big Bynn I's lair
-- (dragonscaleb version 52, tell Tinmizer "begin" inside).
local prog = require("sof_progression")

local deepscar_dz = {
	expedition = { name = "Deepscar's Den", min_players = 1, max_players = 6 },
	instance   = { zone = "dragonscaleb", version = 51, duration = eq.seconds("3h") },
	compass    = { zone = "dragonscale", x = -2577, y = 2639, z = -0.75 },
	safereturn = { zone = "dragonscale", x = -2577, y = 2639, z = -0.75, h = 0 },
	zonein     = { x = 230, y = 45, z = 6.875, h = 0 },
}

local bigbynn_dz = {
	expedition = { name = "Big Bynn's Lair", min_players = 1, max_players = 54 },
	instance   = { zone = "dragonscaleb", version = 52, duration = eq.seconds("3h") },
	compass    = { zone = "dragonscale", x = -2577, y = 2639, z = -0.75 },
	safereturn = { zone = "dragonscale", x = -2577, y = 2639, z = -0.75, h = 0 },
	zonein     = { x = 215, y = 60, z = 6.875, h = 0 },
}

local function request(e, spec, name, lockout)
	if e.other:GetLevel() < 70 then
		e.self:Say("Return at level 70, " .. e.other:GetCleanName() .. ".")
		return
	end
	local current = e.other:GetExpedition()
	if current.valid then
		e.self:Say("You already hold a claim to an expedition. Use it or let it lapse.")
		return
	end
	local dz = e.other:CreateExpedition(spec)
	if dz.valid then
		dz:AddReplayLockout(lockout)
		e.self:Say(name .. " is sworn. Enter when ready.")
	else
		e.self:Say("The way will not open just now. Ask me again shortly.")
	end
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("You have found Falrazim's hollow. Two prey matter here: "
			.. "[Deepscar], the overseer worm, and the dragon [Big Bynn I].")
	elseif e.message:findi("deepscar") then
		e.self:Say("His den lies below. Tell me you [seek deepscar] and I "
			.. "will open the way -- take his cryptic timetable while you "
			.. "are there; the Warmarshal wants it.")
	elseif e.message:findi("seek deepscar") then
		request(e, deepscar_dz, "Deepscar's Den", eq.seconds("18h"))
	elseif e.message:findi("big bynn") then
		e.self:Say("The great dragon dreams behind my cave. Say [I am "
			.. "powerful] and I will wake him for you.")
	elseif e.message:findi("i am powerful") then
		request(e, bigbynn_dz, "Big Bynn's Lair", eq.seconds("72h"))
	end
end

function event_trade(e)
	local item_lib = require("items")
	item_lib.return_items(e.self, e.other, e.trade)
end
