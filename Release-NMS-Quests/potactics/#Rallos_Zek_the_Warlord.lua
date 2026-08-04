-- This is a list of the spawn2 id's of all mobs that spawn in the pit.
-- There are mobs that do not spawn in the pit, that path into it.
-- They are not disabled from spawning.
local pit_spawn2_ids = {
	44462,
	44639,
	44640,
	44641,
	44642,
	44646,
	44654,
	44655,
	44656,
	44657,
	44664,
	44665,
	44666,
	44667,
	44674,
	44675,
	44676,
	44677,
	44678,
	44679,
	44680,
	44681,
	44682,
	44687,
	44688,
	44702,
	44703,
	44705,
	44708,
	44709,
	44710,
	44711,
	44712,
	44713,
	44715,
	44716,
	44719,
	44720,
	44721,
	44722,
	44723,
	44724,
	44727,
	44728,
	44729,
	44737,
	44738,
	44742,
	44743,
	44744,
	44745,
	44746,
	44747,
	44748,
	44749,
	44758,
	44759,
	44760,
	44761,
	44762,
	44763,
	44764,
	44765,
	44775,
	44776,
	44780,
	44781,
	44782
}

function event_spawn(e)
	eq.zone_emote(0, "A great cry echoes across the field of blood and through the halls of Drunder. The creatures in the arena flee to avoid the impending doom.")
--	eq.set_timer("Fail", 30 * 60 * 1000) --30 Minutes
	for _, spawn2_id in ipairs(pit_spawn2_ids) do
		-- Disable the spawn2 entry for all the pit mobs
		eq.disable_spawn2(spawn2_id)
	end

	-- Disable piglet from spawning and starting the stampede
	eq.disable_spawn2(157400)
end

function event_combat(e)
	if e.joined then
		eq.set_timer("Adds", 60 * 1000) -- 60 Seconds
		eq.set_timer("Out of Arena", 5 * 1000) -- 5 Seconds
	else
		e.self:SaveGuardSpot(e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading()) -- Doesn't move
	end
end

function event_death_complete(e)
	if tostring(eq.get_zone_instance_version()) == eq.get_rule("Custom:StaticInstanceVersion") then -- Only flag in non-respawning dz
		eq.spawn2(214105, 0, 0, 699, 8, -294, 128) -- #A_Planar_Projection
	end
--	eq.stop_timer("Fail")
	eq.stop_timer("Adds")
	eq.signal(214123, 214113)
	for _, spawn2_id in ipairs(pit_spawn2_ids) do
		eq.update_spawn_timer(spawn2_id, 30 * 60 * 1000) -- 30 Minutes
		eq.enable_spawn2(spawn2_id)
	end

	eq.update_spawn_timer(157400, 30 * 60 * 1000) -- 30 Minutes
	eq.enable_spawn2(157400)
end

function event_killed_merit(e)
	if tostring(eq.get_zone_instance_version()) == eq.get_rule("Custom:StaticInstanceVersion") then -- Only flag in non-respawning dz
		local rallos_bucket = tonumber(e.other:GetAccountBucket("pop.flags.rallos")) or 0
		if rallos_bucket == 0 then
			e.other:SetAccountBucket("pop.flags.rallos", "1")
			e.other:Message(MT.LightBlue, "You receive a character flag!")
		end
	end
end

function event_timer(e)
--	if e.timer == "Fail" then
--		for _, spawn2_id in ipairs(pit_spawn2_ids) do
--			eq.update_spawn_timer(spawn2_id, 30 * 60 * 1000) -- 30 Minutes
--			eq.enable_spawn2(spawn2_id)
--		end

--		eq.update_spawn_timer(157400, 30 * 60 * 1000) -- 30 Minutes
--		eq.enable_spawn2(157400)

--		eq.stop_timer("Adds")
--		eq.stop_timer("Fail")

--		eq.depop_all(214114)

--		eq.depop()
	if e.timer == "Adds" then
		if e.self:IsEngaged() then
			local npc_ids = { 214114, 214136 }
			eq.spawn2(npc_ids[math.random(#npc_ids)], 0, 0, 519, 216, -293, 132)
			eq.spawn2(npc_ids[math.random(#npc_ids)], 0, 0, 647, 346, -293, 132)
			eq.spawn2(npc_ids[math.random(#npc_ids)], 0, 0, 853, 220, -293, 132)
			eq.spawn2(npc_ids[math.random(#npc_ids)], 0, 0, 779, -30, -293, 132)
			eq.spawn2(npc_ids[math.random(#npc_ids)], 0, 0, 507, -164, -293, 132)
			eq.spawn2(npc_ids[math.random(#npc_ids)], 0, 0, 847, -327, -293, 132)
			eq.spawn2(npc_ids[math.random(#npc_ids)], 0, 0, 518, -357, -293, 132)
			e.self:Emote("The corpses across the grounds of the arena begin to twitch and spasm as the will of the Warlord brings them to life.")
		else
			eq.stop_timer("Adds")
		end
	elseif e.timer == "Out of Arena" then
		if e.self:GetHateListCount() > 0 then
			local hate_entries = e.self:GetHateList().entries
			for hate_entry in hate_entries do
				if hate_entry.ent:IsClient() and hate_entry.ent:GetX() > 950 then
					e.self:CastSpell(982, hate_entry.ent:GetID()) -- Spell: Cazic Touch
				end
			end

		end
	end
end
