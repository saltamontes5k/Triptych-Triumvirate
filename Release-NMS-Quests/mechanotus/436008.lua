-- Plink Squichbolt (436008) -- Fortress Mechanotus strike camp.
-- Steam Factory raid requester ("eliminate"): steamfactory instance v51
-- with Spindlecrank, the Mining Behemoth and Chief Mechanic Clankwrench.
local prog = require("sof_progression")

local steam_raid = {
	expedition = { name = "Steam Factory: Eliminate the Machines", min_players = 1, max_players = 54 },
	instance   = { zone = "steamfactory", version = 51, duration = eq.seconds("8h") },
	compass    = { zone = "mechanotus", x = -1404, y = 162, z = 397.5 },
	safereturn = { zone = "mechanotus", x = -1404, y = 162, z = 397.5, h = 0 },
	zonein     = { x = 613.5, y = -1106.75, z = 97.125, h = 0 }, -- TUNABLE
}

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Psst -- over here. The Steam Factory runs three "
			.. "monstrosities: [Spindlecrank], the [Mining Behemoth] and "
			.. "Chief Mechanic [Clankwrench]. Ready to [eliminate] them?")
	elseif e.message:findi("eliminate") then
		if e.other:GetLevel() < 70 then
			e.self:Say("You'd get flattened. Come back at level 70.")
			return
		end
		local current = e.other:GetExpedition()
		if current.valid then
			e.self:Say("You already hold a claim to an expedition. Use it or let it lapse.")
			return
		end
		local dz = e.other:CreateExpedition(steam_raid)
		if dz.valid then
			dz:AddReplayLockout(eq.seconds("72h"))
			e.self:Say("The foundry floor is yours. Cut the power, break "
				.. "the machines, and grab every notebook page you find -- "
				.. "the Warmarshal collects them.")
		else
			e.self:Say("The Factory doors are cycling. Ask me again shortly.")
		end
	elseif e.message:findi("ready") then
		local dz = e.other:GetExpedition()
		if dz.valid then
			e.self:Say("Back to the grind, " .. e.other:GetCleanName() .. ".")
			e.other:MovePCDynamicZone(dz:GetZoneID())
		else
			e.self:Say("You belong to no expedition.")
		end
	end
end

function event_trade(e)
	local item_lib = require("items")
	item_lib.return_items(e.self, e.other, e.trade)
end
