-- Treasure_of_Meldrath (460507) -- MMM raid win chest, mechanotus instance v1.
-- Rasper: raidMMM.html -- Meldrath chest: 12 Oil Stained Crystals (progression),
-- one of five armor pieces, and a chance at a Prismatic Faycite.
--
-- Punch to open (Anguish/Solteris loot-event chest): the payload lives on
-- loottable 1520007740 and is protected by the expedition loot event that
-- 460506.lua registers on spawn. (The runes + Gyro Cores are still to author.)
-- Expires after 10 minutes so a cleared instance tidies itself.

local EXPIRE_MS = 600000 -- 10 minutes

function event_spawn(e)
	eq.set_timer("expire", EXPIRE_MS)
end

function event_timer(e)
	if e.timer == "expire" then
		e.self:Depop()
	end
end
