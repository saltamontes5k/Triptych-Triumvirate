-- Vrex_Xalkak`s_Marauder (294594)
function event_combat(e)
	if e.joined then
		eq.set_timer("OOBcheck", 3 * 1000);
	else
		eq.stop_timer("OOBcheck");
	end
end

function event_timer(e)
	if e.timer == "OOBcheck" then
		eq.stop_timer("OOBcheck");
		if e.self:GetX() > 720 or e.self:GetX() < 500 or e.self:GetY() < -300 or e.self:GetY() > -120 then
			e.self:CastSpell(3791,e.self:GetID()); -- Spell: Ocean's Cleansing
			e.self:GotoBind();
			e.self:WipeHateList();
			e.self:SetHP(e.self:GetMaxHP());
		else
			eq.set_timer("OOBcheck", 3 * 1000);
		end
  end
end

function event_death_complete(e)
  eq.depop(294595);
  eq.spawn2(294595,0,0,520,-211.5,-50,128); -- NPC: #Vrex_Xalkak_Nixki
  eq.signal(294595,2);
	eq.zone_emote(MT.Yellow,"The marauder's remains crash to the ground. It is no more.");
end
