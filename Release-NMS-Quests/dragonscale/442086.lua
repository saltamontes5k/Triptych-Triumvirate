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


-- rof2b composition (2026-11-05): this giver's SoF faction-task dialogue above
-- is preserved; the reconstruction's Dragonscale Hills routes dispatch below.
-- Their handler is keyword-gated and opens its own task selector; the SoF
-- offer keywords 'work'/'offer'/'jobs' still reach the dialogue above, and a
-- plain hail keeps both the SoF greeting and their selector.
local dragonscale_mod = require('achievement_quest_dragonscale')
local rof2b_sof_say = event_say
local rof2b_sof_trade = event_trade
local rof2b_sof_accepted = event_task_accepted
local rof2b_their_kw = { 'hail', 'task', 'help', 'profit', 'clockworks',
	'replace', 'resources', 'deal', 'risk', 'assist', 'issues', 'grateful',
	'find her', 'aid' }
local function rof2b_theirs(e)
	local msg = e.message:lower()
	for _, w in ipairs(rof2b_their_kw) do
		if msg:find(w, 1, true) then return true end
	end
	return false
end

function event_say(e)
	if rof2b_theirs(e) then
		dragonscale_mod.say(e)
		if e.message:lower():find('hail', 1, true) and rof2b_sof_say then
			rof2b_sof_say(e)
		end
	elseif rof2b_sof_say then
		rof2b_sof_say(e)
	end
end

function event_trade(e)
	local handled = false
	if dragonscale_mod.trade then handled = dragonscale_mod.trade(e) end
	if not handled and rof2b_sof_trade then rof2b_sof_trade(e) end
end

function event_task_accepted(e)
	if rof2b_sof_accepted then rof2b_sof_accepted(e) end
	if dragonscale_mod.accepted then dragonscale_mod.accepted(e) end
end
