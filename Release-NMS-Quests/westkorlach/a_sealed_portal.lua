local raids = require("dod_raids")

local by_id = {
	[900014] = "shyra",
	[900015] = "korlach",
}

function event_say(e)
	raids.entry(e, by_id[e.self:GetNPCTypeID()])
end
