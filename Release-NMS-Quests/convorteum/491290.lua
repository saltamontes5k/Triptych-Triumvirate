-- Convorteum_Controller (491290) -- Convorteum v1, passive raid controller.
-- Tracked source: Release-NMS-Quests/convorteum/491290.lua.
-- Rasper: miscRaidProg.html.
--
-- Seven sequential stages, Crystallos controller pattern:
--   * instance boot: depop stages 2-7 (incl. all three Magus Sisters),
--     stage 1 (The Gatekeeper) stands;
--   * stage N signals 2000+N on its boss's death -> 72h expedition
--     lockout for that stage, Treasure chest at the stage's hall, the
--     raid-wide stage flag, then (unless N == 7) the next stage pops
--     after a short emote;
--   * stage 6 (The Magus Sisters) completes only when all three sisters
--     are dead.

local prog = require("uf_progression")

local CTRL = prog.NPC.conv_ctrl
local STAGES = prog.NPC.stages
local SISTERS = prog.NPC.sisters
local CHESTS = prog.CHEST.conv
local LOCKOUT = eq.seconds("72h")

local STAGE_NAMES = {
	"The Gatekeeper", "The Stone Warden", "Unstable Creation",
	"The Keymaster", "The Hall of Records", "The Magus Sisters",
	"The First Creation",
}

-- must match uf_content/gen_uf_convorteum.py STAGE_SPOTS (TUNABLE)
local STAGE_SPOTS = {
	{ 63.0, -90.0, -44.125 },
	{ 13.0, -150.0, -44.125 },
	{ -37.0, -50.0, -44.125 },
	{ 63.0, -10.0, -44.125 },
	{ -37.0, -150.0, -44.125 },
	{ 3.0, -230.0, -44.125 },
	{ 13.0, 50.0, -44.125 },
}

local function depop_future()
	local el = eq.get_entity_list()
	for n = 2, 7 do
		for _, id in ipairs((n == 6) and SISTERS or { STAGES[n] }) do
			local m = el:GetNPCByID(id)
			if m and m.valid then
				m:Depop()
			end
		end
	end
end

local function pop_stage(n)
	local el = eq.get_entity_list()
	local ids = (n == 6) and SISTERS or { STAGES[n] }
	for _, id in ipairs(ids) do
		local m = el:GetNPCByID(id)
		if m and m.valid then
			m:Depop(false)  -- force a respawn from the static spawn
		end
	end
end

function event_spawn(e)
	local exp = eq.get_expedition()
	if exp.valid then
		for i, chest in ipairs(CHESTS) do
			exp:SetLootEventByNPCTypeID(chest, STAGE_NAMES[i])
		end
	end
	eq.set_timer("boot", 15000)
	eq.zone_emote(13, "The heart of the Underfoot beats around you. Seven wards stand between you and the First Creation.")
end

function event_timer(e)
	if e.timer == "boot" then
		depop_future()
		local exp = eq.get_expedition()
		if exp.valid then
			e.self:SetEntityVariable("stage", "1")
		end
		eq.zone_emote(13, "The First Ward holds: THE GATEKEEPER bars the way.")
	elseif e.timer == "next" then
		local n = tonumber(e.self:GetEntityVariable("next") or "0")
		if n >= 2 and n <= 7 then
			pop_stage(n)
			e.self:SetEntityVariable("stage", tostring(n))
			eq.zone_emote(13, "Ward " .. n .. " opens: " .. STAGE_NAMES[n] .. " awaits.")
		end
	end
end

function event_signal(e)
	local n = e.signal - 2000
	if n < 1 or n > 7 then return end

	-- stage 6 needs all three sisters down
	if n == 6 then
		local el = eq.get_entity_list()
		for _, id in ipairs(SISTERS) do
			local m = el:GetNPCByID(id)
			if m and m.valid then
				return  -- not all sisters are dead yet
			end
		end
	end

	local exp = eq.get_expedition()
	local spot = STAGE_SPOTS[n]
	if exp.valid and not exp:HasLockout(STAGE_NAMES[n]) then
		exp:AddLockout(STAGE_NAMES[n], LOCKOUT)
	end
	local chest = eq.unique_spawn(CHESTS[n], 0, 0, spot[1], spot[2], spot[3] + 5, 0)
	if chest ~= nil and exp.valid then
		exp:SetLootEventBySpawnID(chest:GetID(), STAGE_NAMES[n])
	end
	for _, c in ipairs(prog.alive_clients(spot[1], spot[2], 300)) do
		prog.set(c, prog.STAGE_FLG[n], 1)
		c:Message(15, "Ward " .. n .. " is broken: " .. STAGE_NAMES[n] .. " falls.")
	end
	eq.zone_emote(15, STAGE_NAMES[n] .. " has been defeated!")

	if n < 7 then
		e.self:SetEntityVariable("next", tostring(n + 1))
		eq.set_timer("next", 15000)
	else
		eq.zone_emote(15, "All seven wards are broken. The heart of the Underfoot is yours.")
	end
end
