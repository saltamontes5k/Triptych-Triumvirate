local raids = require("dod_raids")
local dodh  = require("dodh_helper")

local by_id = {
	[900017] = "mayong",
}

function event_say(e)
	-- The Demi-Plane of Blood is keyed by the Monocle of Blood (Bonzz guide,
	-- requirement one of three; loot rights and the curse blockers are handled
	-- by the expedition lockout and the zone aura).
	if by_id[e.self:GetNPCTypeID()] and not e.other:GetGM()
		and (tonumber(e.other:GetBucket(dodh.flags.monocle)) or 0) == 0 then
		e.self:Say("The seal recognizes no one who does not carry the Monocle of Blood. Treddlehoop down in the undershore crafts them - if you gather what he needs.");
		return
	end
	raids.entry(e, by_id[e.self:GetNPCTypeID()])
end
