--#Jeplak,_Lord_of_Srerendi (210471)
--Zone: Postorms

function event_spawn(e)
	-- activate immediately
	e.self:SetBodyType(1, true);		--humanoid
	e.self:SetSpecialAbility(24, 0);	--will not aggro
	e.self:SetSpecialAbility(35, 0);	--no harm from players
end

function event_slay(e)
	if e.other:IsClient() or e.other:IsPet() then
		spawn_adds(e,2,2);	--2 adds on death always
	end
end

function event_death_complete(e)
	eq.local_emote({e.self:GetX(), e.self:GetY(), e.self:GetZ()},7,300,"As the corpse of Jeplak crashes to the ground, you notice a slight, deranged smile on his face.");
end

function spawn_adds(e,low,high)
	local rand = math.random(low,high);
	for n = 1,high do
		mob = eq.spawn2(eq.ChooseRandom(210474,210473),0,0,e.self:GetX() + math.random(-50,50),e.self:GetY() + math.random(-50,50),e.self:GetZ() - 10,e.self:GetHeading());	--#a_lost_soul or #a_mangled_traveller
	end
end
