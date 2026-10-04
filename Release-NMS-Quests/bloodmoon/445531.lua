-- [[
-- a bloodmoon channeler (445531) -- Bloodmoon raid 3, version 3.
-- Rasper: raidBloodmoon3.html. Non-agro until attacked. When the last one
-- dies, Ralkor and Vesthun activate.
-- ]]
local M = require("sof_bloodmoon_raid")
local RALKOR, VESTHUN = 445530, 445510

function event_death_complete(e)
	if M.version() ~= 3 then return end
	local n = tonumber(eq.get_data("sof_bm_r3_ch")) or 1
	n = n - 1
	eq.set_data("sof_bm_r3_ch", tostring(n))
	if n <= 0 then
		eq.zone_emote(15, "The last channeler falls. Ralkor and Vesthun awaken!")
		local x, y, z = e.self:GetX(), e.self:GetY(), e.self:GetZ()
		eq.spawn2(RALKOR, 0, 0, x + 20, y, z, 0)
		eq.spawn2(VESTHUN, 0, 0, x - 20, y, z, 0)
	end
end
