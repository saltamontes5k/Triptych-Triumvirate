-- Hive_Controller (485290) -- Arthicrex v1, passive raid controller.
-- Tracked source: Release-NMS-Quests/arthicrex/485290.lua.
-- Rasper: miscRaidProg.html.
--
-- Hive Guardians event: the four guardians signal 1101-1104 on death.
-- Completion requires all four dead at once (guards never respawn inside
-- the instance, so a mid-raid wipe cannot fake progress). On completion:
-- 72h expedition lockout, the Treasure chest, and the raid-wide
-- hive_guardians flag (alive raiders near the controller only, like live's
-- "be present for the kill" credit).

local prog = require("uf_progression")

local LOCKOUT = eq.seconds("72h")
local EVENT = "Cliknar Hive Guardians"
local CHEST = prog.CHEST.guardians

local GUARDIANS = { 485220, 485221, 485222, 485223 }
-- chest drop point: the brood gallery crossroads (TUNABLE)
local CHEST_X, CHEST_Y, CHEST_Z = 491.0, -1634.0, 200.0

function event_spawn(e)
	local exp = eq.get_expedition()
	if exp.valid then
		exp:SetLootEventByNPCTypeID(CHEST, EVENT)
	end
	eq.zone_emote(13, "Four guardian halls ring the brood galleries. Break them all.")
end

function event_signal(e)
	local dead = 0
	for _, gid in ipairs(GUARDIANS) do
		local m = eq.get_entity_list():GetNPCByID(gid)
		if not (m and m.valid) then
			dead = dead + 1
		end
	end
	if dead < #GUARDIANS then
		eq.zone_emote(15, string.format("A guardian falls. %d of %d remain.",
			#GUARDIANS - dead, #GUARDIANS))
		return
	end
	local exp = eq.get_expedition()
	if exp.valid and not exp:HasLockout(EVENT) then
		exp:AddLockout(EVENT, LOCKOUT)
	end
	local chest = eq.unique_spawn(CHEST, 0, 0, CHEST_X, CHEST_Y, CHEST_Z + 5, 0)
	if chest ~= nil and exp.valid then
		exp:SetLootEventBySpawnID(chest:GetID(), EVENT)
	end
	for _, c in ipairs(prog.alive_clients(CHEST_X, CHEST_Y, 300)) do
		prog.set(c, prog.FLG.hive_guardians, 1)
		c:Message(15, "You have earned the right to face the Cliknar Queen.")
	end
	eq.zone_emote(15, "The hive's guardians are broken. The royal chamber lies open.")
end
