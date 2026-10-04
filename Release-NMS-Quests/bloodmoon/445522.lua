-- [[
-- Grendol Wolfmaw (445522) -- Bloodmoon raid 2, version 2.
-- Rasper: raidBloodmoon2.html. Comes with 6 mezzable worgs.
-- ]]
local M = require("sof_bloodmoon_raid")
local WORG = 445526

function event_combat(e)
	if not e.joined then return end
	if M.version() ~= 2 then return end
	if not e.joined then return end
	M.spawn_adds(WORG, 6, e.self:GetX(), e.self:GetY(), e.self:GetZ(), 45)
end

function event_death_complete(e)
end
