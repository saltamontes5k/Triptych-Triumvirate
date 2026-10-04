-- global/items/100085.lua -- Tinmyn's Oil Can charm (Oil Cans, 300035).
-- Live quirk: the can's stats pulse with the exact platinum you carry
-- (243, or 243x3). Simplified: the click reports your attunement.

function event_item_click(e)
	if e.owner == nil then return end
	local plat = math.floor(e.other:GetCarriedMoney() / 1000) -- 1pp = 1000c
	local tuned = false
	local p = 243
	while p <= plat do
		if p == plat then tuned = true end
		p = p * 3
	end
	if tuned then
		e.other:Message(15, "Tinmyn's Oil Can hums in perfect resonance with your coinpurse. It has never run smoother.")
	else
		e.other:Message(15, "The Oil Can sputters. It likes exactly 243 platinum (or 243x3, x9...) and you carry " .. plat .. ".")
	end
end
