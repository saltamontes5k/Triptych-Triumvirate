function event_spawn(e)
	local x,y,z,h = e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading();

	if x == -15 and y == 0 then
		eq.set_next_hp_event(90);
	elseif x == 445 and y == -489 then
		e.self:SetHP(473300)
		eq.set_next_hp_event(75);
	elseif x == 671 and y == -714 then
		e.self:SetHP(394420)
		eq.set_next_hp_event(50);
	elseif x == 534 and y == -210 then
		e.self:SetHP(262947)
	end
end

function event_hp(e)
	if(e.hp_event == 90) then
		eq.zone_emote(MT.White,"Guardian of Transcendence crumbles to dust upon the ground, but you have the feeling that you haven't seen the last of it yet.");
		eq.get_entity_list():FindDoor(15):SetLockPick(0);
		eq.get_entity_list():FindDoor(16):SetLockPick(0);
		eq.spawn2(294500,0,0,445,-489,-45,418); -- NPC: Guardian_of_Transcendence
		eq.depop()
	elseif(e.hp_event == 75) then
		eq.zone_emote(MT.White,"Guardian of Transcendence crumbled once again into a pile of dust. Like before, you feel like you haven't seen the last of it.");
		eq.get_entity_list():FindDoor(8):SetLockPick(0);
		eq.get_entity_list():FindDoor(9):SetLockPick(0);
		eq.spawn2(294500,0,0,671,-714,-50,382); -- NPC: Guardian_of_Transcendence
		eq.depop()
	elseif(e.hp_event == 50) then
		eq.zone_emote(MT.White,"Guardian of Transcendence crumbles once more to dust at your feet. Its presence remains, though. It is no doubt waiting for you.");
		eq.get_entity_list():FindDoor(10):SetLockPick(0);
		eq.get_entity_list():FindDoor(12):SetLockPick(0);
		eq.get_entity_list():FindDoor(13):SetLockPick(0);
		eq.get_entity_list():FindDoor(14):SetLockPick(0);
		eq.spawn2(294500,0,0,534,-210,-50,144); -- NPC: Guardian_of_Transcendence
		eq.depop()
	end
end

function event_death_complete(e)
	eq.spawn2(294595,0,0,520,-211.5,-50,128); -- NPC: #Vrex_Xalkak_Nixki
	eq.spawn2(294593,0,0,530,-261,-50,138); -- NPC: Vrex_Xalkak`s_Sentinel
	eq.spawn2(294598,0,0,531,-157,-50,252); -- NPC: #Vrex_Xalkak`s_Sentinel
	eq.spawn2(294599,0,0,522,-233,-50,136); -- NPC: #Vrex_Xalkak`s_Sentinel_
	eq.spawn2(294600,0,0,516,-182,-50,136); -- NPC: Vrex_Xalkak`s_Sentinel_
	eq.zone_emote(MT.White,"The death of the Guardian of Transcendence reveals a trusik geomancer! It appears he was the guardian all along and used his phenomenal abilities to lure you into his den!");
	eq.zone_emote(MT.White,"Vrex Xalkak Nixki says, 'I won't be defeated so easily! Come forth, my sentinels! Your time to work is at hand!'");
end
