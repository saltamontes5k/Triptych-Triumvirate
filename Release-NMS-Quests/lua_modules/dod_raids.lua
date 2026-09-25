--[[
	dod_raids.lua - Depths of Darkhollow raid access (shared by the zone entry seals)

	Each parent zone has an "a_sealed_portal" NPC that maps its NPC type id to a
	raid key below and calls M.entry(e, key).

	The boss bodies for these raids are placed by spawn2 in the named instance
	version (see quests/task_sql/dod_raids.sql), so the encounter scripts attach
	directly to them.
--]]

local M = {}

local DURATION = eq.seconds("6h")

M.defs = {
	antraygus = {
		name = "Antraygus, the Sporali King",
		instance = { zone = "corathusa", version = 1, duration = DURATION },
		expedition = { name = "Antraygus, the Sporali King", min_players = 1, max_players = 54 },
		compass = { zone = "corathus", x = 16, y = -337, z = -46 },
		safereturn = { zone = "corathus", x = 16, y = -337, z = -46, h = 0 },
		zonein = { x = 117, y = 89, z = 168, h = 128 },
	},
	sendaii = {
		name = "Sendaii, the Hive Queen",
		instance = { zone = "drachnidhivec", version = 1, duration = DURATION },
		expedition = { name = "Sendaii, the Hive Queen", min_players = 1, max_players = 54 },
		compass = { zone = "drachnidhive", x = 475.91, y = 202.56, z = 161.39 },
		safereturn = { zone = "drachnidhive", x = 475.91, y = 202.56, z = 161.39, h = 0 },
		zonein = { x = 4, y = -8, z = -747, h = 0 },
	},
	bloodeye = {
		name = "Bloodeye",
		instance = { zone = "eastkorlacha", version = 2, duration = DURATION },
		expedition = { name = "Bloodeye", min_players = 1, max_players = 54 },
		compass = { zone = "eastkorlach", x = -953.87, y = -1128.98, z = 184.13 },
		safereturn = { zone = "eastkorlach", x = -953.87, y = -1128.98, z = 184.13, h = 0 },
		zonein = { x = 1455, y = 502, z = -82, h = 0 },
	},
	shyra = {
		name = "Matriarch Shyra",
		instance = { zone = "westkorlacha", version = 3, duration = DURATION },
		expedition = { name = "Matriarch Shyra", min_players = 1, max_players = 54 },
		compass = { zone = "westkorlach", x = -1730, y = -337, z = 4 },
		safereturn = { zone = "westkorlach", x = -1730, y = -337, z = 4, h = 0 },
		zonein = { x = -503, y = -201, z = 12, h = 386 },
	},
	korlach = {
		name = "Korlach, the Deep Leviathan",
		instance = { zone = "westkorlachc", version = 3, duration = DURATION },
		expedition = { name = "Korlach, the Deep Leviathan", min_players = 1, max_players = 54 },
		compass = { zone = "westkorlach", x = -2229, y = 395, z = 895 },
		safereturn = { zone = "westkorlach", x = -2229, y = 395, z = 895, h = 0 },
		zonein = { x = -34, y = 1868, z = 84, h = 0 },
	},
	draygun = {
		name = "Emperor Draygun",
		instance = { zone = "illsalinc", version = 2, duration = DURATION },
		expedition = { name = "Emperor Draygun", min_players = 1, max_players = 54 },
		compass = { zone = "illsalin", x = 308, y = -182, z = -32 },
		safereturn = { zone = "illsalin", x = 308, y = -182, z = -32, h = 0 },
		zonein = { x = -6, y = -664, z = -111, h = 0 },
	},
	mayong = {
		name = "Mayong Mistmoore",
		instance = { zone = "dreadspire", version = 1, duration = DURATION },
		expedition = { name = "Mayong Mistmoore", min_players = 1, max_players = 54 },
		compass = { zone = "dreadspire", x = 1386, y = -1032, z = -574 },
		safereturn = { zone = "dreadspire", x = 1386, y = -1032, z = -574, h = 0 },
		zonein = { x = 1386, y = -1032, z = -574, h = 0 },
	},
	council = {
		name = "The Council of Nine",
		instance = { zone = "illsalinb", version = 1, duration = DURATION },
		expedition = { name = "The Council of Nine", min_players = 1, max_players = 42 },
		compass = { zone = "eastkorlach", x = -1000, y = -1250, z = 184 },
		safereturn = { zone = "eastkorlach", x = -1000, y = -1250, z = 184, h = 0 },
		zonein = { x = -207, y = -171, z = -21, h = 0 },
	},
	vule = {
		name = "Master Vule the Silent Tear",
		instance = { zone = "dreadspire", version = 2, duration = DURATION },
		expedition = { name = "Master Vule the Silent Tear", min_players = 1, max_players = 54 },
		compass = { zone = "dreadspire", x = 1358, y = -1030, z = -572 },
		safereturn = { zone = "dreadspire", x = 1358, y = -1030, z = -572, h = 0 },
		zonein = { x = 0, y = 147, z = -1354, h = 0 },
	},
}

function M.entry(e, key)
	local def = M.defs[key]
	if not def then
		return
	end

	local client = e.other
	local msg    = string.lower(e.message or "")
	local dz     = client:GetExpedition()
	local has    = dz.valid and dz:GetName() == def.name

	if msg:find("hail") then
		local link = eq.say_link("enter")
		if has then
			eq.get_entity_list():MessageClose(e.self, true, 100, MT.SayEcho,
				"The seal remembers you. Say [" .. link .. "] to return to " .. def.name .. ".")
		else
			eq.get_entity_list():MessageClose(e.self, true, 100, MT.SayEcho,
				"A trembling seal hangs in the air. Beyond it waits " .. def.name ..
				". Say [" .. link .. "] to break the seal and enter.")
		end
	elseif msg:find("enter") then
		if not has then
			dz = client:CreateExpedition(def)
		end
		if dz.valid then
			local zi = def.zonein
			client:MovePCInstance(dz:GetZoneID(), dz:GetInstanceID(), zi.x, zi.y, zi.z, zi.h or 0)
		else
			client:Message(MT.Red, "The seal will not yield. (The expedition could not be created.)")
		end
	end
end

return M
