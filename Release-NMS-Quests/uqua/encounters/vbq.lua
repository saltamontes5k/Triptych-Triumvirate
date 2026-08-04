local mob_count = 0
local abilities_inactive        = "19,1^20,1^21,1^24,1^25,1^35,1";
local abilities_active          = "1,1^2,1^4,1,10,0,7^5,1^7,1^12,1^13,1^14,1^15,1^16,1^17,1^21,1^31,1";
local guardian_alive            = true;
local channeler_alive			= 2;
local barxt_alive				= true;
local init_queued 				= false;

function add_loot(e)
  local item_ids = {68740, 68741, 68742, 68743, 68744, 68745, 68746, 68747, 68748, 68749, 68750, 68751, 68752, 68753, 68754, 68755, 68756, 68757}
  local item1 = item_ids[math.random(#item_ids)]
  local item2 = item_ids[math.random(#item_ids)]
  local item3 = item_ids[math.random(#item_ids)]

  e.self:AddItem(item1, 1)
  e.self:AddItem(item2, 1)
  e.self:AddItem(item3, 1)
end

function reset()
	-- Depop everything involved
  eq.stop_all_timers()
	eq.depop(292028) -- #Aura_of_Destruction
	eq.depop(292067) -- #Guardian_of_Destruction
	eq.depop(292068) -- Vrex_Barxt_Qurat
	eq.depop(292069) -- #Vrex_Barxt_Qurat
	eq.depop_all(292072) -- an_anchorite_of_destruction
	eq.depop(292074) -- #a_destructive_channeler
	eq.depop(292075) -- #a_destructive_channeler_
	eq.depop_all(292083) -- a_disciple_of_destruction_
	eq.depop_all(292086) -- a_summoner_of_destruction
	eq.depop_all(292087) -- a_summoner_of_destruction
	eq.depop_all(292088) -- a_summoner_of_destruction
	
	-- Respawn the relevant things
  init()
end

function check_tether(e)
	if e.self:GetY() < -184 then
		e.self:CastSpell(3230,e.self:GetID()); -- Spell: Balance of the Nameless
		e.self:GotoBind();
		e.self:WipeHateList();
	end
end

function check_heal(e)
	local npc_list = eq.get_entity_list():GetNPCList()
	if npc_list ~= nil then
		for npc in npc_list.entries do
			if npc:GetNPCTypeID() == 292074 then --#a_destructive_channeler
				e.self:HealDamage(7500)
			end
		end
	end
end

function init()
	eq.spawn2(292067,0,0,-866,-43,61,260) -- Guardian of Destruction
	eq.spawn2(292068,0,0,-869,-16,65,250) -- Vrex Barxt Qurat
	
	eq.spawn2(292086,0,0,-813,-74,59,472);  -- SW 1st
	eq.spawn2(292086,0,0,-902,-83,59,26);   -- SE 1st
	eq.spawn2(292086,0,0,-904,109,59,226);  -- NE 1st
	eq.spawn2(292086,0,0,-827,110,59,270);  -- NW 1st

	eq.spawn2(292087,0,0,-822,-77,59,474);  -- SW 2nd
	eq.spawn2(292087,0,0,-911,-79,59,22);   -- SE 2nd
	eq.spawn2(292087,0,0,-895,112,59,228);  -- NE 2nd
	eq.spawn2(292087,0,0,-817,106,59,282);  -- NW 2nd

	eq.spawn2(292088,0,0,-830,-83,59,478);  -- SW 3rd
	eq.spawn2(292088,0,0,-921,-76,59,32);   -- SE 3rd
	eq.spawn2(292088,0,0,-886,117,59,226);  -- NE 3rd
	eq.spawn2(292088,0,0,-808,102,59,290);  -- NW 3rd
	mob_count = 0
	guardian_alive = true
	barxt_alive = true
	channeler_alive = 2
end

function summoner_spawn(e)
	e.self:SetSpecialAbility(25, 1); --turn on immune to aggro
	e.self:SetSpecialAbility(24, 1); --turn on anti aggro
	e.self:SetSpecialAbility(35, 1); --turn on immunity
end

function summoner_signal(e)
	if e.signal == 1 then
		e.self:SetAppearance(3) --Dead
	end
end

function add_spawn(e)
	e.self:SetSpecialAbility(25, 1); --turn on immune to aggro
	e.self:SetSpecialAbility(24, 1); --turn on anti aggro
	e.self:SetSpecialAbility(35, 1); --turn on immunity
end

function add_combat(e)
	if e.joined then
		eq.stop_timer("reset")
		eq.set_timer("tether", 3 * 1000) --Check tether every 3 seconds
	else
		eq.set_timer("reset", 2 * 60 * 1000) --reset if not on agro for 2 minutes once active
	end
end

function add_signal(e)
	if e.signal == 1 then
		e.self:SetSpecialAbility(25, 0); --turn on immune to aggro
		e.self:SetSpecialAbility(24, 0); --turn on anti aggro
		e.self:SetSpecialAbility(35, 0); --turn on immunity
		e.self:AddToHateList(eq.get_entity_list():GetRandomClient(), 1);
	end
end

function add_timer(e)
	if e.timer == "tether" then
		check_tether(e)
	elseif e.timer == "reset" then
		eq.stop_timer("reset")
		reset()
	end
end

function add_death_complete(e)
	mob_count = mob_count - 1
	eq.signal(292069, 2)
	eq.zone_emote(MT.Yellow, "Some destructive energy dissipates, damaging Barxt.")
end

function channeler_spawn(e)
	eq.set_timer("aoe", 195 * 1000) -- 3 min, 15 sec
	e.self:SetSpecialAbility(25, 1); --turn on immune to aggro
	e.self:SetSpecialAbility(24, 1); --turn on anti aggro
	e.self:SetSpecialAbility(35, 1); --turn on immunity
end

function channeler_combat(e)
	if e.joined then
		eq.set_timer("tether", 3 * 1000) --Check tether every 3 seconds
	end
end

function channeler_1_timer(e)
	if e.timer == "tether" then
		check_tether(e)
	elseif e.timer == "aoe" then
		local target = eq.get_entity_list():GetRandomClient(e.self:GetX(), e.self:GetY(), e.self:GetZ(), 100 * 100)
		if target.valid then
			e.self:CastSpell(5055, target:GetID()) --Creeping Fury
		end
	end
end

function channeler_2_timer(e)
	if e.timer == "tether" then
		check_tether(e)
	elseif e.timer == "aoe" then
		local target = eq.get_entity_list():GetRandomClient(e.self:GetX(), e.self:GetY(), e.self:GetZ(), 100 * 100)
		if target.valid then
			e.self:CastSpell(5056, target:GetID()) --Rampaging Force
		end
	end
end

function channeler_signal(e)
	if e.signal == 1 then
		local barxt = eq.get_entity_list():GetMobByNpcTypeID(292069)
		e.self:SetSpecialAbility(25, 0); --turn off immune to aggro
		e.self:SetSpecialAbility(24, 0); --turn off anti aggro
		e.self:SetSpecialAbility(35, 0); --turn off immunity
		e.self:AddToHateList(barxt:GetTarget(), 1)
	end
end

function channeler_death_complete(e)
	eq.signal(292069, 3)
end

function aura_spawn(e)
	eq.set_timer("aoe", 1 * 60 * 1000) --AoE Withering Destruction every 1 minute
	eq.set_timer("healthcheck", 1 * 60 * 1000) -- Heal the Guardian of Destruction or Vrex Barxt Qurat every 1 minute
end

function aura_timer(e)
	if e.timer == "aoe" then
		local target = eq.get_entity_list():GetRandomClient(e.self:GetX(), e.self:GetY(), e.self:GetZ(), 360 * 360)
		if target.valid then
			e.self:CastSpell(5120, target:GetID()) --Withering Destruction
		end
	elseif e.timer == "healthcheck" then
		if guardian_alive then
			eq.signal(292067, 1)
			eq.zone_emote(MT.Yellow, "I can feel the energy from the guardian course through my soul! More! Give me more, I say! Trushar, give me the power to destroy these creatures and send them and the others back from where they came!")
		else
			eq.signal(292069, 1)
			eq.zone_emote(MT.Yellow, "They have destroyed the guardian before the transfer could be completed. Regardless, you must transfer your remaining energy to me, my minions.")
		end
	end
end

function specter_say(e)
	if guardian_alive then
		e.self:Say("Oh no. What have you done? When you slew me, my existence was tied closely to the Guardian of Destruction. With my death I have lost a part of myself. I will be trapped here - bound to this hellish temple and surrounded by the evidence of my failure for all eternity. Why did you interfere with the ritual? If only you had destroyed the Guardian first...'")
	else
		if not e.other:HasItem(60252) then
			e.self:Say("Thank you for helping me see the truth. When you slew the construct, I was driven to the brink of insanity. By destroying my mortal self, you freed my tortured spirit. Please accept this offering. It is a fragment of a master key. Once you have the first two pieces of the High Temple key, you will be able to bypass the wards that protect Qvic. When you have located all three fragments you may find a way to gain entrance into the lair of Txevu. The Muramites have taken control of it and I fear that even now they may be defacing our most sacred temple. Please remember that while you have come far, this is but one small step in your quest to free Taelosia. There are many challenges that yet await you.");
			e.other:SummonItem(60252); -- Item: Fragment of the High Temple
		end
	end
end

function guardian_spawn(e)
	eq.set_timer("tether", 3 * 1000) -- Every 3s, check tether
	eq.set_next_hp_event(70)
	
	e.self:ModSkillDmgTaken(0, 25) -- 1h blunt (125%)
	e.self:ModSkillDmgTaken(2, 25) -- 2H blunt (125%)
	e.self:ModSkillDmgTaken(1, -25) -- 1h slash (75%)
	e.self:ModSkillDmgTaken(3, -25) -- 2h slash (75%)
	e.self:ModSkillDmgTaken(7, -25) -- archery
end

function guardian_combat(e)
	if e.joined then
		eq.stop_timer("reset")
		eq.unique_spawn(292028,0,0,-867, 178, 60, 266); --#Aura_of_Destruction (292028)
	else
		eq.set_timer("reset", 2 * 60 * 1000) --2 minute to reset
	end
end

function guardian_timer(e)
	if e.timer == "tether" then
		check_tether(e)
	elseif e.timer == "reset" then
		eq.stop_timer("reset")
		reset()
	end
end

function guardian_hp(e)
	if e.hp_event == 70 then
		eq.depop(292068) --Vrex_Barxt_Qurat
		eq.spawn2(292069,0,0,-869,-16,65,250); --#Vrex_Barxt_Qurat
		eq.zone_emote(MT.Yellow,"Realizing that his avatar of destruction is fighting a losing battle, Barxt enters the fray. At the same time, you hear the shuffle of feet in the hallway leading to the entrance of the chamber and an ominous sound from behind the door indicates that it has been locked.  You have been sealed in and have no choice but to deal with this madman.  Barxt yells,  'You will die here this day whether it be by my hands or this massive construct. Trushar's will shall be done.  Your corpses shall rot here.  This chamber shall become your eternal grave!");
	end
end

function guardian_signal(e)
	if e.signal == 1 then
		check_heal(e)
	elseif e.signal == 2 then
		e.self:SetSpecialAbility(25, 1); --turn on immune to aggro
		e.self:SetSpecialAbility(24, 1); --turn on anti aggro
		e.self:SetSpecialAbility(35, 1); --turn on immunity
		e.self:SetOOCRegen(0);
		e.self:WipeHateList();
		e.self:SetAppearance(3); -- Dead
	elseif e.signal == 3 then
		e.self:SetSpecialAbility(25, 0); --turn off immune to aggro
		e.self:SetSpecialAbility(24, 0); --turn off anti aggro
		e.self:SetSpecialAbility(35, 0); --turn off immunity
    e.self:AddToHateList(eq.get_entity_list():GetRandomClient(), 1);
	end
end

function guardian_death_complete(e)
	if barxt_alive then
		guardian_alive = false
    eq.signal(292069, 4)
	end
end

function barxt_combat(e)
	if e.joined then
		eq.stop_timer("reset")
	else
		eq.set_timer("reset", 2 * 60 * 1000) --2 minute to reset
	end
end

function barxt_spawn(e)
	eq.set_timer("add_phase_1", 1 * 60 * 1000) -- 1 Minute
	eq.set_timer("tether", 3 * 1000) --3s Check Tether
  e.self:AddToHateList(eq.get_entity_list():GetRandomClient(), 1);
  eq.set_next_hp_event(40)
	eq.spawn2(292074,0,0,-748,16,60,382) -- NPC: #a_destructive_channeler
	eq.spawn2(292075,0,0,-985,15,60,124) -- NPC: #a_destructive_channeler_
end

function barxt_timer(e)
	if e.timer == "tether" then
		check_tether(e)
	elseif e.timer == "reset" then
		eq.stop_timer("reset")
		reset()
	elseif e.timer == "add_phase_1" then
		eq.stop_timer("add_phase_1")
		eq.set_timer("add_phase_2", 45 * 1000) -- 45 seconds
		eq.signal(292086, 1) -- Summoners Lay Down
		eq.spawn2(eq.ChooseRandom(292072,292083),0,0,-813,-74,59,472);  -- SW 1st
		eq.spawn2(eq.ChooseRandom(292072,292083),0,0,-902,-83,59,26);   -- SE 1st
		eq.spawn2(eq.ChooseRandom(292072,292083),0,0,-904,109,59,226);  -- NE 1st
		eq.spawn2(eq.ChooseRandom(292072,292083),0,0,-827,110,59,270);  -- NW 1st
		eq.zone_emote(MT.Yellow, "Completing their chant of power, some of the trusik collapse to the floor.  A destructive spirit appears in their place.")
	elseif e.timer == "add_phase_2" then
		eq.stop_timer("add_phase_2")
		eq.set_timer("add_phase_3", 45 * 1000) -- 45 seconds
		eq.signal(292087, 1) -- Summoners Lay Down
		eq.spawn2(eq.ChooseRandom(292072,292083),0,0,-822,-77,59,474);  -- SW 2nd
		eq.spawn2(eq.ChooseRandom(292072,292083),0,0,-911,-79,59,22);   -- SE 2nd
		eq.spawn2(eq.ChooseRandom(292072,292083),0,0,-895,112,59,228);  -- NE 2nd
		eq.spawn2(eq.ChooseRandom(292072,292083),0,0,-817,106,59,282);  -- NW 2nd
		eq.zone_emote(MT.Yellow, "Completing their chant of power, some of the trusik collapse to the floor.  A destructive spirit appears in their place.")
	elseif e.timer == "add_phase_3" then
		eq.stop_timer("add_phase_3")
		eq.set_timer("trigger_adds", 45 * 1000) -- 45 seconds
		eq.signal(292088, 1) -- Summoners Lay Down
		eq.spawn2(eq.ChooseRandom(292072,292083),0,0,-830,-83,59,478);  -- SW 3rd
		eq.spawn2(eq.ChooseRandom(292072,292083),0,0,-921,-76,59,32);   -- SE 3rd
		eq.spawn2(eq.ChooseRandom(292072,292083),0,0,-886,117,59,226);  -- NE 3rd
		eq.spawn2(eq.ChooseRandom(292072,292083),0,0,-808,102,59,290);  -- NW 3rd
		eq.zone_emote(MT.Yellow, "Completing their chant of power, some of the trusik collapse to the floor.  A destructive spirit appears in their place.")
	elseif e.timer == "trigger_adds" then
    eq.stop_timer("trigger_adds")
		mob_count = 12
		
		-- Deactivate Barxt
		e.self:ModifyNPCStat("special_abilities",abilities_inactive)
		e.self:SetOOCRegen(0)
		e.self:WipeHateList()
		e.self:SetSpecialAbility(25, 1); --turn on immune to aggro
		e.self:SetSpecialAbility(24, 1); --turn on anti aggro
		e.self:SetSpecialAbility(35, 1); --turn on immunity
		
		-- #Guardian_of_Destruction go to sleep
		eq.signal(292067, 2)
		
		-- Wake up adds
		eq.signal(292072, 1)
		eq.signal(292083, 1)
		
		-- Depop summoners
		eq.depop_all(292086)
		eq.depop_all(292087)
		eq.depop_all(292088)
		
		eq.zone_emote(MT.Yellow, "Vrex Barxt Qurat makes a complex series of gestures, and he is surrounded by an dense crystal shield.  'Servants of Destruction, your master calls!'")
  elseif e.timer == "aoe" then
    e.self:CastSpell(1250, e.self:GetID())
	end
end

function barxt_hp(e)
	if e.hp_event == 40 then
		eq.zone_emote(MT.Yellow,"Barxt's bond with the Guardian of Destruction causes his skin to harden like rock, giving his lithe body an onyx sheen.  He cracks a devilish smile and beckons you to continue.");
		e.self:ModSkillDmgTaken(0, -70);        -- 1h blunt
		e.self:ModSkillDmgTaken(1, -70);        -- 1h slashing
		e.self:ModSkillDmgTaken(2, -70);        -- 2h blunt
		e.self:ModSkillDmgTaken(3, -70);        -- 2h slashing
		e.self:ModSkillDmgTaken(28, -70);       -- hand to hand
		e.self:ModSkillDmgTaken(36, -70);       -- piercing
		e.self:ModSkillDmgTaken(51, -70);       -- throwing
		e.self:ModSkillDmgTaken(77, -70);       -- 2h piercing
		e.self:ModSkillDmgTaken(7, -70) 		-- archery
		e.self:ModifyNPCStat("mr","500");
		e.self:ModifyNPCStat("pr","500");
		e.self:ModifyNPCStat("fr","500");
		e.self:ModifyNPCStat("cr","500");
		e.self:ModifyNPCStat("dr","500");		
		eq.set_next_hp_event(10);
		eq.stop_timer("add_phase_1")
		eq.stop_timer("add_phase_2")
		eq.stop_timer("add_phase_3")
    eq.stop_timer("trigger_adds")
		
		--Wake up the channelers
		eq.signal(292074, 1)
		eq.signal(292075, 1)
		
		eq.zone_emote(MT.Red,"Vrex Barxt Qurat yells, 'Minions of Annihilation, rise and end them!'");
	elseif e.hp_event == 10 then
		eq.zone_emote(MT.Yellow,"Barxt's cronies focus their attention to his offense, causing tendrils of dark magic to wrap around his slender frame.  He laughs, reveling in his newfound strength.");
	
		e.self:ModifyNPCStat("min_hit", tostring(math.floor(e.self:GetNPCStat("min_hit") * 1.25)))
		e.self:ModifyNPCStat("max_hit", tostring(math.floor(e.self:GetNPCStat("max_hit") * 1.25)))
    eq.set_timer("aoe", 30 * 1000) --Wanton Destruction every 30 seconds

		if guardian_alive then
			eq.zone_emote(MT.Yellow, "The voice of Preshna the Lost rings in your ears, 'You MUST destroy the golem first to free Barxt's spirit from this world!'");
    end
	end
end

function barxt_signal(e)
	local one_percent = math.floor(e.self:GetMaxHP() * 0.01)
	if e.signal == 1 then
		check_heal(e)
	elseif e.signal == 2 then
		if e.self:GetHP() > one_percent then
			e.self:SetHP(e.self:GetHP() - one_percent)
		end
		if mob_count == 0 or (not eq.get_entity_list():IsMobSpawnedByNpcTypeID(292072) and not eq.get_entity_list():IsMobSpawnedByNpcTypeID(292083)) then
			e.self:ModifyNPCStat("special_abilities", abilities_active)
			e.self:SetSpecialAbility(25, 0); --turn off immune to aggro
		  e.self:SetSpecialAbility(24, 0); --turn off anti aggro
		  e.self:SetSpecialAbility(35, 0); --turn off immunity
	    e.self:AddToHateList(eq.get_entity_list():GetRandomClient(), 1);
	    eq.signal(292067, 3) -- #Guardian_of_Destruction wake up
		end
  elseif e.signal == 3 then
		channeler_alive = channeler_alive - 1
		if channeler_alive <= 0 then
			eq.zone_emote(MT.Yellow, "Barxt staggers as the influence of the channelers fades, removing the onyx sheen from his skin.")
			e.self:ModSkillDmgTaken(0, 0);        -- 1h blunt
			e.self:ModSkillDmgTaken(1, 0);        -- 1h slashing
			e.self:ModSkillDmgTaken(2, 0);        -- 2h blunt
			e.self:ModSkillDmgTaken(3, 0);        -- 2h slashing
			e.self:ModSkillDmgTaken(28, 0);       -- hand to hand
			e.self:ModSkillDmgTaken(36, 0);       -- piercing
			e.self:ModSkillDmgTaken(51, 0);       -- throwing
			e.self:ModSkillDmgTaken(77, 0);       -- 2h piercing
			e.self:ModSkillDmgTaken(7, 0) 		-- archery
			e.self:ModifyNPCStat("mr","200");
			e.self:ModifyNPCStat("pr","200");
			e.self:ModifyNPCStat("fr","200");
			e.self:ModifyNPCStat("cr","200");
			e.self:ModifyNPCStat("dr","200");
		end
	elseif e.signal == 4 then
    add_loot(e)
  end
end

function barxt_death_complete(e)
	barxt_alive = false
	-- Depop Aura
	eq.depop_all(292028)

  -- Depop Preshna
  eq.depop_all(292066)

  --If the player hauled ass, despawn all the summoners, anchorites, and disciples
  eq.depop_all(292086)
	eq.depop_all(292087)
	eq.depop_all(292088)
  eq.depop_all(292083)
  eq.depop_all(292072)
	
	if guardian_alive then
		eq.zone_emote(MT.Red, "As his body falls to the floor in defeat, the specter of Barxt appears to struggle as it pulls free of the body.  You suddenly feel as if you have made a grave mistake...")
  else
    eq.zone_emote(MT.Yellow, "Exploding in a wave of energy, Barxt's corpse slumps to the floor.")
    eq.zone_marquee(MT.White, "Vrex Barxt Qurat has been defeated.  His ethereal specter stands patiently at the Altar of Destruction.")
  end
  eq.stop_all_timers()
  eq.spawn2(292076,0,0,-869,-16,65,250); -- NPC: #Specter_of_Barxt
  eq.get_entity_list():FindDoor(5):SetLockPick(0); --unlock barxt door
end

function event_encounter_load(e)
	--Vrex Barxt Qurat
	eq.register_npc_event('vbq', Event.death_complete, 292069, barxt_death_complete)
	eq.register_npc_event('vbq', Event.signal, 292069, barxt_signal)
	eq.register_npc_event('vbq', Event.hp, 292069, barxt_hp)
	eq.register_npc_event('vbq', Event.timer, 292069, barxt_timer)
	eq.register_npc_event('vbq', Event.spawn, 292069, barxt_spawn)
	eq.register_npc_event('vbq', Event.combat, 292069, barxt_combat)
	
	--Guardian of Destruction
	eq.register_npc_event('vbq', Event.death_complete, 292067, guardian_death_complete)
	eq.register_npc_event('vbq', Event.signal, 292067, guardian_signal)
	eq.register_npc_event('vbq', Event.hp, 292067, guardian_hp)
	eq.register_npc_event('vbq', Event.timer, 292067, guardian_timer)
	eq.register_npc_event('vbq', Event.combat, 292067, guardian_combat)
	eq.register_npc_event('vbq', Event.spawn, 292067, guardian_spawn)
	
	--Specter of Barxt
	eq.register_npc_event('vbq', Event.say, 292076, specter_say)
	
	--Aura of Destruction
	eq.register_npc_event('vbq', Event.timer, 292028, aura_timer)
	eq.register_npc_event('vbq', Event.spawn, 292028, aura_spawn)
	
	--Destructive Channeler (292074)
	eq.register_npc_event('vbq', Event.death_complete, 292074, channeler_death_complete)
	eq.register_npc_event('vbq', Event.signal, 292074, channeler_signal)
	eq.register_npc_event('vbq', Event.timer, 292074, channeler_1_timer)
	eq.register_npc_event('vbq', Event.combat, 292074, channeler_combat)
	eq.register_npc_event('vbq', Event.spawn, 292074, channeler_spawn)
	
	--Destructive Channeler (292075)
	eq.register_npc_event('vbq', Event.death_complete, 292075, channeler_death_complete)
	eq.register_npc_event('vbq', Event.signal, 292075, channeler_signal)
	eq.register_npc_event('vbq', Event.timer, 292075, channeler_2_timer)
	eq.register_npc_event('vbq', Event.combat, 292075, channeler_combat)
	eq.register_npc_event('vbq', Event.spawn, 292075, channeler_spawn)
	
	--A Summoner of Destruction (292086)
	eq.register_npc_event('vbq', Event.spawn, 292086, summoner_spawn)
	eq.register_npc_event('vbq', Event.signal, 292086, summoner_signal)
	
	--A Summoner of Destruction (292087)
	eq.register_npc_event('vbq', Event.spawn, 292087, summoner_spawn)
	eq.register_npc_event('vbq', Event.signal, 292087, summoner_signal)
	
	--A Summoner of Destruction (292088)
	eq.register_npc_event('vbq', Event.spawn, 292088, summoner_spawn)
	eq.register_npc_event('vbq', Event.signal, 292088, summoner_signal)
	
	--An Anchorite of Destruction
  eq.register_npc_event('vbq', Event.timer, 292072, add_timer)
	eq.register_npc_event('vbq', Event.spawn, 292072, add_spawn)
	eq.register_npc_event('vbq', Event.combat, 292072, add_combat)
	eq.register_npc_event('vbq', Event.signal, 292072, add_signal)
	eq.register_npc_event('vbq', Event.death_complete, 292072, add_death_complete)
	
	--A disciple of Destruction
  eq.register_npc_event('vbq', Event.timer, 292083, add_timer)
  eq.register_npc_event('vbq', Event.spawn, 292083, add_spawn)
	eq.register_npc_event('vbq', Event.combat, 292083, add_combat)
	eq.register_npc_event('vbq', Event.signal, 292083, add_signal)
	eq.register_npc_event('vbq', Event.death_complete, 292083, add_death_complete)	
  eq.zone_emote(MT.Yellow,"Within the large chamber lies a massive stone guardian and many trusik. As they wave their arms and chant, you hear a raspy voice near the large altar in the center of the room. You have disrupted the ritual of destruction. Your interference is an annoyance to the great Trushar and it is his will that you be dealt with. Defilers, witness what happens when the destructive forces of Trushar are combined with my geomantic knowledge. Rise, Guardian of Destruction! Come to life and destroy those who would defile this temple!");
  eq.zone_emote(MT.Yellow,"I can feel the energy from the guardian course through my soul! More! Give me more, I say! Trushar, give me the power to destroy these creatures and send them and the others back from where they came!");

  init()
end
