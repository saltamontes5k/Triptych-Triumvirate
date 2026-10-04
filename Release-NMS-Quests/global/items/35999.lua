-- global/items/35999.lua -- Automated Incendiary Device Mark XIV
-- (Destroying the Competition, 300031). The five plant sites are explore
-- activities; clicking the device shows the remaining route.

function event_item_click(e)
	if e.owner == nil then return end
	if e.owner:IsTaskActive(300031) then
		e.owner:Message(15, "The device warms in your hands. Flizcog's list: "
			.. "the Showroom, the Fan Hall, the Foundry Walk, the "
			.. "Compression Room, and the Power Station -- Steam Factory, "
			.. "two hours on the clock.")
	else
		e.owner:Message(15, "Someone else's ordnance. Leave it alone.")
	end
end
