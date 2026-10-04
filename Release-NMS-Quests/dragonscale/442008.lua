-- [[
-- Overvolt Rigster the IV (442008) -- Dragonscale Hills.
--   * faction task giver (tasks 300007, 300008, 300009, 300026).
--   * Mechamatic Guardian expedition requester (Rasper: openGuardian.html):
--       "head into" -> generic instance (guardian zone version 0, the full
--                      zone, ~20 min respawns -- the only version the named
--                      rares live in).
--       "mission N" -> one of the five single-floor missions (zone versions
--                      1-5, no respawns) for grabbing the Expediator Marks.
--       "ready"     -> re-enters an active expedition.
--     gate: level 70+. Entry is by conversation (no door/dz_switch needed).
-- ]]

local TASKS = { 300007, 300008, 300009, 300026 }
local REQUIRES = {}

local FLOORS = {
	{ 1, "First Floor" },
	{ 2, "Second Floor" },
	{ 3, "Third Floor" },
	{ 4, "Fourth Floor" },
	{ 5, "Top Floor" },
}

local function guardian_spec(version, name)
	return {
		expedition = { name = name, min_players = 1, max_players = 6 },
		instance   = { zone = "guardian", version = version, duration = eq.seconds("2h") },
		compass    = { zone = "dragonscale", x = -2514, y = 3642, z = 26 },
		safereturn = { zone = "dragonscale", x = -2514, y = 3642, z = 26, h = 2 },
		zonein     = { x = -115, y = 60, z = 4, h = 0 },
		switchid   = 0,
	}
end

local function request_guardian(e, version, name)
	local c = e.other
	if c:GetLevel() < 70 then
		e.self:Say("The Guardian would grind you to filings. Return at level 70.")
		return
	end
	if c:GetExpedition().valid then
		e.self:Say("You already hold a claim to an expedition. Use it or let it lapse.")
		return
	end
	local dz = c:CreateExpedition(guardian_spec(version, name))
	if dz.valid then
		e.self:Say(name .. " is yours. Say [ready] to head in.")
	else
		e.self:Say("The Guardian's access is cycling. Ask me again shortly.")
	end
end

local function offer_tasks(e)
	e.self:Say("These are the duties I can entrust to you, " .. e.other:GetCleanName() .. ".")
	local available = {}
	for _, tid in ipairs(TASKS) do
		local required = REQUIRES[tid]
		if required == nil or e.other:IsTaskCompleted(required) then
			available[#available + 1] = tid
		end
	end
	eq.task_selector(available)
end

local function offer_missions(e)
	e.self:Say("Which floor of the Mechamatic Guardian do you [seek]? Each is a "
		.. "single-floor mission, no respawns.")
	for _, f in ipairs(FLOORS) do
		e.self:Say("Floor " .. f[1] .. " (" .. f[2] .. "): "
			.. eq.say_link("mission " .. f[1], false, "take me there") .. ".")
	end
end

function event_say(e)
	local m = e.message
	local n = tonumber(m:match("[mM]ission%s*(%d)"))
	if m:findi("hail") then
		e.self:Say("Hail, " .. e.other:GetCleanName() .. ". There is work to be done if you "
			.. "would lend a hand. Ask me about a [task], to [head into] the Mechamatic "
			.. "Guardian, or for a [mission] to a single floor.")
	elseif n and n >= 1 and n <= 5 then
		request_guardian(e, n, "The Mechamatic Guardian: " .. FLOORS[n][2])
	elseif m:findi("task") or m:findi("work") or m:findi("offer") or m:findi("jobs") then
		offer_tasks(e)
	elseif m:findi("head into") or m:findi("head in") then
		if e.other:GetExpedition().valid then
			e.self:Say("Back into the Guardian, " .. e.other:GetCleanName() .. ".")
			e.other:MovePCDynamicZone(447)
		else
			request_guardian(e, 0, "The Mechamatic Guardian")
		end
	elseif m:findi("mission") or m:findi("seek") or m:findi("floor") then
		offer_missions(e)
	elseif m:findi("ready") or m:findi("enter") or m:findi("go in") then
		local dz = e.other:GetExpedition()
		if dz.valid then
			e.self:Say("Mind the steamworks, " .. e.other:GetCleanName() .. ".")
			e.other:MovePCDynamicZone(dz:GetZoneID())
		else
			e.self:Say("You belong to no expedition.")
		end
	end
end

function event_task_accepted(e)
	if e.task_id == 300026 then
		e.other:SummonItem(36244)
	end
end

function event_trade(e)
	local item_lib = require("items")
	item_lib.return_items(e.self, e.other, e.trade)
end
