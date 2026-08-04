--#Rallos_Zek (223168)
--Phase 5 God
--potimeb

local event_mobs = {223229,223230};

function event_spawn(e)
	eq.set_next_hp_event(90);
	SetDefaultStats(e);
end

function event_combat(e)
	if e.joined then
		eq.stop_timer("reset");
	else
		eq.set_timer("reset",1 * 60 * 1000);
	end
end

function event_timer(e)
	if e.timer == "reset" then
		eq.stop_timer("reset");
		eq.set_next_hp_event(90);
		SetDefaultStats(e)
		for k,v in pairs(event_mobs) do
			eq.depop_all(v);
		end
	end
end


function event_hp(e)
	e.self:Emote("roars a mighty war cry and swings his axe with a vengeance.");
	if (e.hp_event == 90) then
		SpawnAdds(e,2);
		eq.set_next_hp_event(75);
	elseif (e.hp_event == 75) then
		SpawnAdds(e,2);
		e.self:ModifyNPCStat("attack_delay","11");	--slightly increase attack speed 
		e.self:SetSpecialAbility(SpecialAbility.area_rampage,1);	--enable AE Rampage
		e.self:SetSpecialAbilityParam(SpecialAbility.area_rampage,0,10);
		eq.set_next_hp_event(50);
	elseif (e.hp_event == 50) then
		SpawnAdds(e,2);
		e.self:SetSpecialAbility(SpecialAbility.flurry,1);	--enable flurry
		e.self:SetSpecialAbilityParam(SpecialAbility.flurry,0,10);	
		eq.set_next_hp_event(25);
	elseif (e.hp_event == 25) then
		SpawnAdds(e,5);
		e.self:SetSpecialAbilityParam(SpecialAbility.area_rampage,0,20);
		e.self:ModifyNPCStat("attack_delay","9");	--increase attack speed 
	end
end

function SetDefaultStats(e)
	e.self:SetSpecialAbility(SpecialAbility.area_rampage,0);
	e.self:SetSpecialAbility(SpecialAbility.flurry,0);	
	e.self:ModifyNPCStat("attack_delay","13");	
end

function SpawnAdds(e, num)	
	--always spawns 4 adds
	for n = 1,2 do
		local id1 = eq.spawn2(223229,0,0,262,-280,5,449);	--a_summoned_minion
		local id2 = eq.spawn2(223230,0,0,262,-280,5,449);	--a_summoned_boar
		if ( id1.valid and e.self:GetTarget() and e.self:GetTarget().valid ) then
			id1:AddToHateList(e.self:GetTarget(), 1);
		end
		if ( id2.valid and e.self:GetTarget() and e.self:GetTarget().valid ) then
			id2:AddToHateList(e.self:GetTarget(), 1);
		end
	end
	--5th add for last hp event

	if (num == 5) then eq.spawn2(eq.ChooseRandom(223229,223230),0,0,262,-280,5,449); end
end


function event_death_complete(e)
	-- send a signal to the zone_status that I died
	eq.signal(223097,223168); -- Add Lockout
	eq.signal(223097,6);

	local killer = eq.get_entity_list():GetClientByID(e.killer_id)

    if killer and killer:GetBucket("SeasonalCharacter") == '1' then
        killer:CastToClient():SetBucket('flag-semaphore', '204')
        killer:Signal(100)
    end
end
