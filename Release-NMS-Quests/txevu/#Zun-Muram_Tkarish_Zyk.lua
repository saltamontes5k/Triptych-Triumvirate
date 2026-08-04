-- Zun`Muram Tkarish Zyk NPCID 297150

local init_engage	= false

function event_signal(e)
  if e.signal == 100 then
    eq.set_timer('vuln', 30 * 1000)
    e.self:Emote(' staggers as his link to discord is severed.  Strike now!')
    eq.ZoneMarquee(MT.Yellow, 255, 1000, 2000, 6000, "Zun'muram Tkarish Zyk staggers as his link to discord is severed!")
    e.self:SetSpecialAbility(22, 0)
    e.self:ModifyNPCStat("mr", "200")
    e.self:ModifyNPCStat("pr", "200")
    e.self:ModifyNPCStat("dr", "200")
    e.self:ModifyNPCStat("cr", "200")
    e.self:ModifyNPCStat("fr", "200")
  end
end

function event_spawn(e)
	init_engage = false
	spawn_event()
end

function event_combat(e)
	if e.joined then
		eq.set_timer("ritualist_adds_1", 30 * 1000); -- 30s initial start
		eq.set_timer("ritualist_adds_2", 60 * 1000); -- 60s initial start
		eq.set_timer("ritualist_adds_3", 90 * 1000); -- 90s initial start
		eq.set_timer("ritualist_adds_4", 120 * 1000); -- 120s initial start
		-- Wanton Destruction, scripted AE
		eq.set_timer("wanton",15000);
		eq.set_timer("OOBcheck", 3000);
		--eq.stop_timer("fail_check");
		eq.set_timer("aggrolink", 3 * 1000);
		if not eq.is_paused_timer("fail_check") then
			eq.pause_timer("fail_check");
		end
	else
		-- wipe or tether
		eq.stop_timer("ritualist_adds_1");
		eq.stop_timer("ritualist_adds_2");
		eq.stop_timer("ritualist_adds_3");
		eq.stop_timer("ritualist_adds_4");
		eq.stop_timer("wanton");
		eq.signal(297147, 297150); -- Tell Ritualists I lost agro
		eq.signal(297075, 297150); -- Tell Ritualists I lost agro
		eq.signal(297076, 297150); -- Tell Ritualists I lost agro
		eq.signal(297077, 297150); -- Tell Ritualists I lost agro
		eq.stop_timer("OOBcheck");
		--eq.set_timer("fail_check", 20 * 60 * 1000); --20 min reset
		eq.stop_timer("aggrolink");
		if not init_engage then
			--30 minutes cumulative to finish or the entire event resets
			eq.set_timer("fail_check", 1800000)
			init_engage = true
		else
			eq.resume_timer("fail_check");
		end
	end
end

function event_timer(e)
	-- Ritualist Add Handling
	if e.timer == "ritualist_adds_1" then -- North
		eq.stop_timer(e.timer);
		if eq.get_entity_list():IsMobSpawnedByNpcTypeID(297075) then
			eq.spawn2(eq.ChooseRandom(297159, 297161, 297161, 297222, 297222, 297223, 297134),0,0,1305, 27, -304, 0):AddToHateList(e.self:GetHateTop(),1) -- North
			eq.set_timer("ritualist_adds_1", 2 * 60 * 1000); -- 2 minute timer
		end
  elseif e.timer == 'vuln' then
    eq.stop_timer('vuln')
    e.self:Emote(' grins as his discordant energy returns, rendering him immune to your strikes.')
    eq.ZoneMarquee(MT.Yellow, 255, 1000, 2000, 6000, "Zun'muram Tkarish Zyk grins as his discordant energy returns!")
    e.self:SetSpecialAbility(22, 1)
    e.self:ModifyNPCStat("mr", "1000")
    e.self:ModifyNPCStat("pr", "1000")
    e.self:ModifyNPCStat("dr", "1000")
    e.self:ModifyNPCStat("cr", "1000")
    e.self:ModifyNPCStat("fr", "1000")
	elseif e.timer == "ritualist_adds_2" then -- East
		eq.stop_timer(e.timer);
		if eq.get_entity_list():IsMobSpawnedByNpcTypeID(297077) then
			eq.spawn2(eq.ChooseRandom(297159, 297161, 297161, 297222, 297222, 297223, 297134),0,0,1276, 0, -304, 384):AddToHateList(e.self:GetHateTop(),1) -- East
			eq.set_timer("ritualist_adds_2", 2 * 60 * 1000); -- 2 minute timer
		end
	elseif e.timer == "ritualist_adds_3" then -- South
		eq.stop_timer(e.timer);
		if eq.get_entity_list():IsMobSpawnedByNpcTypeID(297076) then
			eq.spawn2(eq.ChooseRandom(297159, 297161, 297161, 297222, 297222, 297223, 297134),0,0,1305, -27, -304, 256):AddToHateList(e.self:GetHateTop(),1) -- South
			eq.set_timer("ritualist_adds_3", 2 * 60 * 1000); -- 2 minute timer
		end	
	elseif e.timer == "ritualist_adds_4" then -- West
		eq.stop_timer(e.timer);
		if eq.get_entity_list():IsMobSpawnedByNpcTypeID(297147) then
			eq.spawn2(eq.ChooseRandom(297159, 297161, 297161, 297222, 297222, 297223, 297134),0,0,1330, 0, -304, 128):AddToHateList(e.self:GetHateTop(),1) -- West
			eq.set_timer("ritualist_adds_4", 2 * 60 * 1000); -- 2 minute timer
		end
	elseif e.timer == "fail_check" then
		-- respawn the whole event
		eq.depop_all(297147); -- West
		eq.depop_all(297075); -- North
		eq.depop_all(297076); -- South
		eq.depop_all(297077); -- East
		eq.depop_all(297148);
		eq.depop_all(297149);
		eq.depop_all(297159);
		eq.depop_all(297161);
		eq.depop_all(297222);
		eq.depop_all(297223);
		eq.depop_all(297134);
		init_engage = false
		--init_engage = false
		eq.stop_all_timers()
		--eq.spawn2(297150,0,0,1506,2,-285,374) -- myself, which also will trigger Spawn_Event()
		--eq.depop()
		spawn_event()
	elseif e.timer == "wanton" then
		e.self:CastSpell(1250,e.self:GetID())
		eq.set_timer("wanton", eq.ChooseRandom(100,120) * 1000)
	elseif e.timer=="OOBcheck" then
		eq.stop_timer("OOBcheck");
			if e.self:GetX() < 1215 or e.self:GetY() > 106 or e.self:GetY() < -106 then
				e.self:CastSpell(3791,e.self:GetID()); -- Spell: Ocean's Cleansing
				e.self:GotoBind();
				e.self:WipeHateList();
			else
				eq.set_timer("OOBcheck", 3 * 1000);
			end
	elseif e.timer == "aggrolink" then
		local npc_list =  eq.get_entity_list():GetNPCList();
		for npc in npc_list.entries do
			if npc.valid and not npc:IsEngaged() and (npc:GetNPCTypeID() == 297148 or npc:GetNPCTypeID() == 297149 or npc:GetNPCTypeID() == 297147 or npc:GetNPCTypeID() == 297075 or npc:GetNPCTypeID() == 297076 or npc:GetNPCTypeID() == 297077) then
				npc:AddToHateList(e.self:GetHateRandom(),1); -- add ritualists and inquisitor goats to aggro list if alive
			end
		end
	end
end

function spawn_event()
	-- 4 Ikaav Ritualist and the two Inquisitor goats.
	eq.spawn2(297147,0,0,1353, 0, -305, 384);	-- West
	eq.spawn2(297075,0,0,1305, 45, -305, 256);	-- North
	eq.spawn2(297076,0,0,1305, -45, -305, 0);	-- South
	eq.spawn2(297077,0,0,1260, 0, -305, 128);	-- East
	eq.spawn2(297148,0,0,1528, 30, -285, 384);
	eq.spawn2(297149,0,0,1528, -30, -285, 384);
end
