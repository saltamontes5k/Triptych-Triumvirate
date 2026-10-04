-- global/items/9920004.lua -- Siege Engine Inspection Notes (Spy Reports,
-- 300036). The six observations of Siege Inspector Huttle are tracked in
-- mechanotus/player.lua; this is the resulting hand-in item.

function event_item_click(e)
	if e.owner == nil then return end
	e.other:Message(15, "Six neat observations, each ending 'This one seems to be coming along nicely.' The inconspicuous mechanic will want these.")
end
