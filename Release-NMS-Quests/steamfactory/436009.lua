-- a_rebel_brownie_emissary (436009) -- Secrets of Faydwer Steam Factory raid.
-- Tracked source: Release-NMS-Quests/steamfactory/436009.lua.
-- Rasper: raidSteam.html -- the raid's entry phrase is "ready".
-- Plink Squichbolt (436008) creates the expedition; the emissary just sends an
-- already-sworn raid back in.

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Ready to strike the heart of the factory, "
			.. e.other:GetCleanName() .. "? Say [ready] and I will send you in.")
	elseif e.message:findi("ready") then
		local dz = e.other:GetExpedition()
		if dz.valid then
			e.self:Say("For the Resistance!")
			e.other:MovePCDynamicZone(dz:GetZoneID())
		else
			e.self:Say("You belong to no expedition. Speak with Plink "
				.. "Squichbolt to swear one.")
		end
	end
end

function event_trade(e)
	local item_lib = require("items")
	item_lib.return_items(e.self, e.other, e.trade)
end
