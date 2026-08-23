-- Monk Epic 1.5
local epic_disabled = true; -- Disabling for omens (epics) cannot reference perl expansion vars from lua.

function event_say(e)
	if not epic_disabled then
		if e.other:HasClass(Class.MONK) then
			local data_bucket = ("Epic-Monk-"..e.other:CharacterID());
			if eq.get_data(data_bucket) ~= "" then -- Has Started
				local temp = eq.get_data(data_bucket);
				s = eq.split(temp, ',');

				local epic_pre_onefive	= tonumber(s[1]);
				local epic_onefive		= tonumber(s[2]);
				local epic_two			= tonumber(s[3]);
				local epic_twofive		= tonumber(s[4]);

				if epic_onefive == 10 and e.message:findi("hail") then
					e.other:Message(MT.NPCQuestSay, "Quigli says 'I have nothing for you unless say you have the [right price]. . .'");
				elseif epic_onefive == 10 and e.message:findi("right") then
					e.other:Message(MT.NPCQuestSay, "Quigli says 'I have just placed my 'ands on this 'ere book and I'd be willin to part with it for a mighty price else you could try and [defeat me crew].'");
				elseif epic_onefive == 10 and e.message:findi("defeat") then
					e.other:Message(MT.NPCQuestSay, "Quigli says 'Good. . .good. I 'aven't 'ad much change to stretch me arms in a while.'");
					make_attackable(e.self, true);
					eq.set_timer("adds", 5 * 1000); -- 5 Sec
					eq.set_timer("depop",15 * 60 *1000); -- 15 Minutes
					e.self:AddToHateList(e.other,1);
				end
			end
		end
	else
		e.self:Say("Go Away, I am busy!");
	end
end

function make_attackable(mob, attackable)
	mob:SetSpecialAbility(SpecialAbility.immune_melee, attackable and 0 or 1)
	mob:SetSpecialAbility(SpecialAbility.immune_magic, attackable and 0 or 1)
	mob:SetSpecialAbility(SpecialAbility.immune_aggro, attackable and 0 or 1)
	mob:SetSpecialAbility(SpecialAbility.immune_aggro_on, attackable and 0 or 1)
	mob:SetSpecialAbility(SpecialAbility.no_harm_from_client, attackable and 0 or 1)
end

function event_timer(e)
	eq.stop_timer(e.timer);
	if e.timer == "adds" then
		e.self:Say("You sorry sacks of vermin come aid me now!");
		eq.spawn2(225380,0,0,e.self:GetX()-20,e.self:GetY()+5,e.self:GetZ(),e.self:GetHeading());	-- NPC: a_lackey_of_Quigli
		eq.spawn2(225381,0,0,e.self:GetX()-20,e.self:GetY()+10,e.self:GetZ(),e.self:GetHeading());	-- NPC: a_swabby_of_Quigli
		eq.spawn2(225381,0,0,e.self:GetX()-20,e.self:GetY()-5,e.self:GetZ(),e.self:GetHeading());	-- NPC: a_swabby_of_Quigli
		eq.spawn2(225382,0,0,e.self:GetX()-20,e.self:GetY()-10,e.self:GetZ(),e.self:GetHeading());	-- NPC: a_scallywag_of_Quigli
	elseif e.timer == "depop" then
		eq.depop_with_timer();
		eq.depop_all(225380);
		eq.depop_all(225381);
		eq.depop_all(225382);
	end
end

function event_death_complete(e)
	eq.depop_all(225380);
	eq.depop_all(225381);
	eq.depop_all(225382);
end
