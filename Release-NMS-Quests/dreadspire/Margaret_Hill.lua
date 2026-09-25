-- dreadspire/Margaret_Hill.lua
-- Depths of Darkhollow: requests the Master Vule the Silent Tear expedition
-- (Dreadspire Keep, version 2). The static version-0 Vule is retained for
-- open-world play; the instance is what records the raid lockout.
local raids = require("dod_raids")

function event_say(e)
	raids.entry(e, "vule")
end
