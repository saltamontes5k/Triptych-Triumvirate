-- eastkorlach/Brother_Dark_Water.lua
-- Depths of Darkhollow: requests the Council of Nine expedition, which runs in
-- the Temple of the Korlach instance (illsalinb, version 1). The custom
-- open-world Council of Nine in the Undershore is unchanged.
local raids = require("dod_raids")

function event_say(e)
	raids.entry(e, "council")
end
