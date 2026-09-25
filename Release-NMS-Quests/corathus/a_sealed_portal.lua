local raids = require("dod_raids")

local by_id = {
	[900011] = "antraygus",
}

function event_say(e)
	raids.entry(e, by_id[e.self:GetNPCTypeID()])
end
