function event_death_complete(e)
	eq.unique_spawn(212063, 0, 0, e.self:GetX(), e.self:GetY(),  e.self:GetZ(),  e.self:GetHeading()) -- NPC: #Rizlona
end

function event_combat(e)
	if e.joined then
		eq.set_timer("Out of Bounds", 6 * 1000) -- 6 Seconds
	else
		eq.stop_timer("Out of Bounds")
	end
end

function event_timer(e)
	if e.timer == "Out of Bounds" then
		eq.stop_timer("Out of Bounds")
		if e.self:GetY() < 2076 then
			e.self:Say("If you wish to challenge me, you must do it on my terms!")
			e.self:CastSpell(2830, e.self:GetID())
			e.self:SetHP(e.self:GetMaxHP())
			e.self:GotoBind()
			e.self:WipeHateList()
		else
			eq.set_timer("Out of Bounds", 6 * 1000) -- 6 Seconds
		end
	end
end