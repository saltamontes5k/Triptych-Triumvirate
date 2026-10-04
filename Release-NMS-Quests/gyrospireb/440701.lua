-- #Garden_Keeper_IV (440701) -- How Does Your Garden Grow (301101) finale.
-- Occasionally plants a bomb: ~2 ticks later it detonates (Small Explosion,
-- 7639) unless the raid has moved out.

function event_combat(e)
	if e.joined then
		e.self:SetTimer("bomb", 45000)
	else
		e.self:StopTimer("bomb")
	end
end

function event_timer(e)
	if e.timer == "bomb" then
		e.self:Say("Grow, little surprise. GROW.")
		e.self:StopTimer("bomb")
		e.self:SetTimer("detonate", 12000)
	elseif e.timer == "detonate" then
		e.self:StopTimer("detonate")
		eq.zone_emote(15, "The Keeper's planted bomb erupts!")
		e.self:CastSpell(7639, e.self:GetID())
		if e.self:IsEngaged() then
			e.self:SetTimer("bomb", 45000)
		end
	end
end
