-- global/items/88283.lua -- Bloodwolf Spirit Pouch (Lost Lumpling, 300034).
-- The combine is done; deliver the pouch to Lamperious Cogwittle to wake
-- the Bloodwolf (spawned at the gardener's huts).

function event_item_click(e)
	if e.owner == nil then return end
	e.other:Message(15, "The pouch trembles against your hip. Cogwittle can wake what sleeps inside.")
end
