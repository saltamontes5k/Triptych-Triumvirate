-- [[
-- sof_crystallos_raid.lua -- shared helpers for the Crystallos raid
-- (crystallos instance v220). Encounter scripts require this for the
-- repeated chest/alive-client/controller-signal boilerplate.
--]]

local M = {}

M.CONTROLLER = 446240

-- wing signal keys (must match 446240.lua EVENTS)
M.SIG = { fire = 1001, earth = 1002, ice = 1003, air = 1004, brood = 1005, kerafyrm = 1006 }

-- chest npc types
M.CHEST = {
	fire = 446260, earth = 446261, ice = 446263, air = 446263,
	brood = 446268, kerafyrm = 446269,
}

function M.alive_clients(cx, cy, r)
	local out = {}
	local list = eq.get_entity_list():GetClientList()
	if not list then return out end
	for c in list.entries do
		if c and c:GetHPRatio() > 0
			and math.abs(c:GetX() - cx) <= r and math.abs(c:GetY() - cy) <= r then
			out[#out + 1] = c
		end
	end
	return out
end

function M.chest(enc, chest_id, event_name)
	local exp = eq.get_expedition()
	if not exp.valid then return end
	local c = eq.unique_spawn(chest_id, 0, 0, enc:GetX(), enc:GetY(), enc:GetZ() + 5, 0)
	if c then exp:SetLootEventBySpawnID(c:GetID(), event_name) end
end

function M.signal(key)
	eq.signal(M.CONTROLLER, key)
end

-- spawn a batch of a given add npc areound a point; returns spawned ids
function M.spawn_adds(npc_type, count, cx, cy, cz, radius)
	local ids = {}
	for i = 1, count do
		local m = eq.spawn2(npc_type, 0, 0,
			cx + math.random(-radius, radius), cy + math.random(-radius, radius), cz, 0)
		if m then ids[#ids + 1] = m:GetID() end
	end
	return ids
end

function M.clear_list(ids)
	for _, id in ipairs(ids) do
		local m = eq.get_entity_list():GetNPCByID(id)
		if m and m.valid then m:Depop() end
	end
end

return M
