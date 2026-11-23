-- an_anchor_of_the_timeshear (478732) -- SoD raid controller:
-- A Council Divided (oldkaesoraa v51).
-- At instance boot, marks 4 of the 8 council members as Discord-aligned and
-- emotes the identification (Rasper: raidKunark1.html -- live reshuffles the
-- split on every reset; here the split is fixed at spawn). Any four council
-- deaths complete the event (documented simplification: loyalists are
-- killable and count). Win: Treasure_of_the_Council chest + 72h lockout.

local raid = require("sod_raids")
local ach = require("achievement_flags")

local COUNCIL = { 478707, 478708, 478709, 478710, 478711, 478712, 478713, 478714 }

local function shuffle(t)
	for i = #t, 2, -1 do
		local j = math.random(i)
		t[i], t[j] = t[j], t[i]
	end
	return t
end

function event_spawn(e)
	e.self:SetEntityVariable("done", "0")
	e.self:SetEntityVariable("dead", "0")
	-- v464 hard mode: chest and loot-event/lockout identity follow the
	-- expedition name's (Hard) suffix.
	local hard = raid.is_hard()
	e.self:SetEntityVariable("hard", hard and "1" or "0")
	local exp = eq.get_expedition()
	if exp.valid then
		exp:SetLootEventByNPCTypeID(raid.chest_for("COUNCIL", hard), raid.event_name("COUNCIL", hard))
	end
	-- councilors may boot after the anchor; align on a delay
	eq.set_timer("align", 10000)
	-- hard: poll for post-wipe loyalty redraws (live reshuffle rule)
	if hard then
		eq.set_timer("reshuffle", 30000)
	end
end

function event_timer(e)
	if e.timer == "reshuffle" then
		-- hard: after a wipe (two calm polls, fight not done, nobody
		-- engaged) the living councilors redraw their loyalties; dead
		-- members stay dead and the 4-aligned total is preserved.
		if e.self:GetEntityVariable("done") == "1" then
			eq.stop_timer("reshuffle")
			return
		end
		local el = eq.get_entity_list()
		local any_engaged = false
		local alive = {}
		for _, id in ipairs(COUNCIL) do
			local mob = el:GetNPCByID(id)
			if mob and mob.valid then
				if mob:IsEngaged() then any_engaged = true end
				alive[#alive + 1] = mob
			end
		end
		if any_engaged or #alive == 0 then
			e.self:SetEntityVariable("calm", "0")
			return
		end
		local calm = tonumber(e.self:GetEntityVariable("calm") or "0") + 1
		if calm < 2 then
			e.self:SetEntityVariable("calm", tostring(calm))
			return
		end
		e.self:SetEntityVariable("calm", "0")
		local dead = tonumber(e.self:GetEntityVariable("dead") or "0")
		local slots = 4 - dead
		if slots <= 0 or #alive == 0 then return end
		if slots > #alive then slots = #alive end
		local order = shuffle({ unpack(alive) })
		for i, mob in ipairs(order) do
			local bad = i <= slots
			mob:SetEntityVariable("discord", bad and "1" or "0")
			if bad then
				eq.zone_emote(15, mob:GetCleanName()
					.. " argues loudly for joining the Discord.")
			end
		end
		eq.zone_emote(15, "The surviving councilors redraw their loyalties!")
		return
	end
	if e.timer == "align" then
		local el = eq.get_entity_list()
		local order = shuffle({ unpack(COUNCIL) })
		local bad = {}
		for i = 1, 4 do bad[order[i]] = true end
		local all_found = true
		for _, id in ipairs(COUNCIL) do
			local mob = el:GetNPCByID(id)
			if mob and mob.valid then
				mob:SetEntityVariable("discord", bad[id] and "1" or "0")
				if bad[id] then
					eq.zone_emote(15, mob:GetCleanName()
						.. " argues loudly for joining the Discord.")
				end
			else
				all_found = false
			end
		end
		if not all_found then
			eq.set_timer("align", 10000) -- retry until every member is up
		else
			eq.stop_timer("align")
		end
	end
end

function event_signal(e)
	-- councilors signal with their npc id on death
	local dead = tonumber(e.self:GetEntityVariable("dead") or "0") + 1
	e.self:SetEntityVariable("dead", tostring(dead))
	if dead >= 4 and e.self:GetEntityVariable("done") ~= "1" then
		e.self:SetEntityVariable("done", "1")
		eq.zone_emote(15, "The council falls silent. Jaled`Dar's agents move among the bodies.")
		local exp = eq.get_expedition()
		local hard = e.self:GetEntityVariable("hard") == "1"
		local event_name = raid.event_name("COUNCIL", hard)
		if exp.valid and not exp:HasLockout(event_name) then
			exp:AddLockout(event_name, eq.seconds("72h"))
		end
		raid.spawn_chest(e, raid.chest_for("COUNCIL", hard))
		ach.set_zone(1645340, 1, 1645340)
		ach.set_zone(1600030, 1, 1600252)
	end
end
