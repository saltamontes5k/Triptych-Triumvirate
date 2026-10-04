-- #the_Chamberlain (440700) -- Scout Gyrospire Beza (301100) finale.
-- Spiderlings (mezzable) join one at a time during the fight.

function event_combat(e)
	if e.joined then
		e.self:SetTimer("spider", 25000)
		e.self:Say("You would interrupt the schedule? The swarm will see to you.")
	else
		e.self:StopTimer("spider")
	end
end

function event_timer(e)
	if e.timer == "spider" then
		local n = tonumber(e.self:GetEntityVariable("spiders") or "0") or 0
		if n >= 3 then return end
		e.self:SetEntityVariable("spiders", tostring(n + 1))
		eq.zone_emote(15, "A steamwork spiderling skitters out of the wainscoting!")
		local mob = eq.spawn2(440707, 0, 0,
			e.self:GetX() + math.random(-30, 30),
			e.self:GetY() + math.random(-30, 30), e.self:GetZ(), 0)
		if mob ~= nil then
			local t = e.self:GetTarget()
			if t ~= nil then mob:AddToHateList(t, 1) end
		end
	end
end
