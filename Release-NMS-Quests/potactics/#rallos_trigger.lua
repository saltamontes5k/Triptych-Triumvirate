function event_spawn(e)
	eq.set_timer("Rallos Untargetable", 5 * 1000) -- 5 Seconds
end

function event_signal(e)
	if e.signal == 500 then -- Mini Rallos Failed, Repop
		eq.set_timer("Rallos Untargetable", 5 * 1000) -- 5 Seconds
	elseif e.signal == 777 then -- Tallon/Vallon Failed, Reset
		eq.get_zone():SetVariable("Event Tallon", "0")
		eq.get_zone():SetVariable("Event Vallon", "0")
	elseif e.signal == 214052 then -- Mini Rallos Death
		eq.stop_timer("Mini")
		eq.unique_spawn(214113, 0, 0, 702, 0, -294.9, 0) -- NPC: #Rallos_Zek_the_Warlord
	elseif e.signal == 214056 then -- Decorin Berik Death
		eq.get_zone():SetVariable("Berik", "1")

		local grunhork_variable = tonumber(eq.get_zone():GetVariable("Grunhork")) or 0
		if grunhork_variable == 1 then -- Spawn Vallon and Tallon
			eq.zone_emote(0, "The air of Drunder grows strangely cold as a rumble shakes through the fortress' walls. The Warlord stirs.")
			eq.stop_timer("Decorin")
			eq.unique_spawn(214108, 187, 0, 620, -560, 145, 385) -- NPC: #Tallon_Zek
			eq.unique_spawn(214111, 188, 0, 620, 580, 145, 385) -- NPC: #Vallon_Zek_

			for door_id = 14, 17 do
				local door = eq.get_entity_list():FindDoor(door_id)
				if door.valid then
					door:SetLockPick(0)
				end
			end

			eq.get_zone():SetVariable("Berik", "0")
			eq.get_zone():SetVariable("Grunhork", "0")
--		else
--			eq.set_timer("Decorin", 6 * 60 * 1000) -- 6 Minutes
		end
	elseif e.signal == 214057 then -- Decorin Grunhork Death
		eq.get_zone():SetVariable("Grunhork", "1")

		local berik_variable = tonumber(eq.get_zone():GetVariable("Berik")) or 0
		if berik_variable == 1 then -- Spawn Vallon and Tallon
			eq.zone_emote(0, "The air of Drunder grows strangely cold as a rumble shakes through the fortress' walls. The Warlord stirs.")
			eq.stop_timer("Decorin")
			eq.unique_spawn(214108, 187, 0, 620, -560, 145, 385) -- NPC: #Tallon_Zek
			eq.unique_spawn(214111, 188, 0, 620, 580, 145, 385) -- NPC: #Vallon_Zek_

			for door_id = 14, 17 do
				local door = eq.get_entity_list():FindDoor(door_id)
				if door.valid then
					door:SetLockPick(0)
				end
			end

			eq.get_zone():SetVariable("Berik", "0")
			eq.get_zone():SetVariable("Grunhork", "0")
--		else
--			eq.set_timer("Decorin", 6 * 60 * 1000) -- 6 Minutes
		end
	elseif e.signal == 214108 then -- Event Tallon Death
		eq.get_zone():SetVariable("Event Tallon", "1")

		local vallon_variable = tonumber(eq.get_zone():GetVariable("Event Vallon")) or 0
		if vallon_variable == 1 then
			eq.stop_timer("VTRZ")
			eq.signal(214052, 0) -- Have Fake Rallos spawn Mini Rallos

			eq.get_zone():SetVariable("Event Tallon", "0")
			eq.get_zone():SetVariable("Event Vallon", "0")
		end
	elseif e.signal == 214111 then -- Event Vallon Death
		eq.get_zone():SetVariable("Event Vallon", "1")

		local tallon_variable = tonumber(eq.get_zone():GetVariable("Event Tallon")) or 0
		if tallon_variable == 1 then
			eq.stop_timer("VTRZ")
			eq.signal(214052, 0) -- Have Fake Rallos spawn Mini Rallos

			eq.get_zone():SetVariable("Event Tallon", "0")
			eq.get_zone():SetVariable("Event Vallon", "0")
		end
	elseif e.signal == 214113 then -- Rallos Zek the Warlord Death, Depop
		eq.depop_with_timer()
	end
end

function event_timer(e)
--	if e.timer == "Decorin" then
--		eq.stop_timer("Decorin")
--		eq.signal(214056, 0) -- NPC: Decorin_Berik
--		eq.signal(214057, 0) -- NPC: Decorin_Grunhork
--		eq.get_zone():SetVariable("Berik", "0")
--		eq.get_zone():SetVariable("Grunhork", "0")
	if e.timer == "Rallos Untargetable" then
		eq.stop_timer("Rallos Untargetable")
		eq.unique_spawn(214052, 0, 0, 500, 11, 194, 129) -- NPC: #Rallos_Zek_ (Untargetable)
	end
end
