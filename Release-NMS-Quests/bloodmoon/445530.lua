-- [[
-- Ralkor (445530) -- Bloodmoon raid 3 (Ralkor's Crystals), version 3.
-- Rasper: raidBloodmoon3.html. Spawned by the controller once the
-- channelers die. Health gates wake the raid's earlier bosses as echoes:
-- 90% Boneshards, 75% Balvik/Malkazor, 60% Grendol, 40% Harlos/Korvak,
-- 20% Crazok. Chest spawns on Ralkor's death regardless of adds.
-- ]]
local M = require("sof_bloodmoon_raid")
local CHEST = 445542
local VESTHUN, GALRIN, WILNOK = 445510, 445511, 445512
local BALVIK, MALKAZOR, GRENDOL = 445520, 445521, 445522
local KORVAK, HARLOS, CRAZOK = 445523, 445524, 445525
local GHOST = 445532
local BUCKET = "sof.bm.raid.ralkor"
local gates = {}

function event_combat(e)
	if not e.joined then eq.stop_all_timers(); return end
	if M.version() ~= 3 then return end
	eq.set_timer("watch", 2000)
	eq.set_timer("ghost", 30000)
end

local function spawn(cx, cy, cz, npc)
	M.spawn_adds(npc, 1, cx, cy, cz, 20)
end

function event_timer(e)
	if e.timer == "ghost" then
		M.spawn_adds(GHOST, 1, e.self:GetX(), e.self:GetY(), e.self:GetZ(), 50)
	elseif e.timer == "watch" then
		local r = e.self:GetHPRatio()
		local x, y, z = e.self:GetX(), e.self:GetY(), e.self:GetZ()
		local function gate(pct, fn)
			if r <= pct and not gates[pct] then gates[pct] = true; fn(x, y, z) end
		end
		gate(90, function(x, y, z) spawn(x, y, z, GALRIN); spawn(x, y, z, WILNOK)
			eq.zone_emote(15, "Galrin and Wilnok Boneshard rise again!") end)
		gate(75, function(x, y, z) spawn(x, y, z, BALVIK); spawn(x, y, z, MALKAZOR)
			eq.zone_emote(15, "Balvik and Malkazor Darkshadow answer Ralkor's call.") end)
		gate(60, function(x, y, z) spawn(x, y, z, GRENDOL)
			eq.zone_emote(15, "Grendol Wolfmaw charges in.") end)
		gate(40, function(x, y, z) spawn(x, y, z, HARLOS); spawn(x, y, z, KORVAK)
			eq.zone_emote(15, "Harlos and Korvak's storms return!") end)
		gate(20, function(x, y, z) spawn(x, y, z, CRAZOK)
			eq.zone_emote(15, "Crazok Moonfang himself joins the fray!") end)
	end
end

function event_death_complete(e)
	eq.stop_all_timers()
	if M.version() ~= 3 then return end
	M.chest(e.self, CHEST, "Bloodmoon: Ralkor's Crystals")
	M.flag_all(BUCKET, 1)
	M.signal(3, 1103)
end
