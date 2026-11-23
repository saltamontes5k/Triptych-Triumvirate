-- global/items/9015301.lua -- Wayfarer's GoD Progression Guide (clicky).
-- Right-click to read the full Gates of Discord progression walkthrough.
local guide = require("god_guide")

function event_item_click(e)
    if e.owner == nil then return end
    guide.show(e.owner)
end
