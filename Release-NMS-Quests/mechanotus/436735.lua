-- Jemi (436735) -- Lost Lumpling (300034): S.H.I.P. expedition request.
-- "Where is Lumpling" -> "I'm up for the job" creates the expedition;
-- "ready" zones the group in.
local fort = require("sof_fortress")

local ship = {
	expedition = { name = "Jemi's S.H.I.P. Infiltration", min_players = 1, max_players = 6 },
	instance   = { zone = "shipworkshop", version = 0, duration = eq.seconds("2h") },
	compass    = { zone = "mechanotus", x = -1565, y = 208, z = 401.5 },
	safereturn = { zone = "mechanotus", x = -1565, y = 208, z = 401.5, h = 0 },
	zonein     = { x = 0, y = 0, z = 0, h = 0 },
	switchid   = 0,
}

function event_say(e)
	if e.message:findi("where is lumpling") then
		e.self:Say("*sniff* The little gnome? Her song leads up into the "
			.. "S.H.I.P. Workshop -- Meldrath's flying factory floor. The "
			.. "machines took her singing and called it work. I can slip "
			.. "you aboard... are you [up for the job]?")
	elseif e.message:findi("up for the job") then
		if e.other:IsTaskActive(fort.TASK_LUMPLING) then
			local current = e.other:GetExpedition()
			if current.valid then
				e.self:Say("You already hold an expedition. Use it first.")
				return
			end
			local dz = e.other:CreateExpedition(ship)
			if dz.valid then
				e.self:Say("Then we go. Tell me when you are [ready].")
			else
				e.self:Say("The way is... blocked. Try again shortly.")
			end
		else
			e.self:Say("Lumpling? Ask Cogwittle about his [lost] girl first.")
		end
	elseif e.message:findi("ready") then
		local dz = e.other:GetExpedition()
		if dz.valid then
			e.self:Say("Hold your breath.")
			e.other:MovePCDynamicZone(dz:GetZoneID())
		else
			e.self:Say("Ready for what? You hold no expedition.")
		end
	end
end

function event_trade(e)
	local item_lib = require("items")
	item_lib.return_items(e.self, e.other, e.trade)
end
