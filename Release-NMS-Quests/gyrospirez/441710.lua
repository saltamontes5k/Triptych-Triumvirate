-- #Chamberlain_VI (441710) -- openGyroZeka rare, outside the spire.
-- Rasper: at 75% and 50% spawns an add (a_chamberlain_attendant 441717,
-- mezzable and rootable).

local ADD = 441717

function event_spawn(e)
	e.self:SetEntityVariable("adds", "0")
end

function event_combat(e)
	if e.joined then
		e.self:SetTimer("check", 2000)
	else
		e.self:StopTimer("check")
	end
end

function event_timer(e)
	if e.timer == "check" then
		local pct = e.self:GetHPRatio()
		local spawned = tonumber(e.self:GetEntityVariable("adds") or "0") or 0
		local want = 0
		if pct <= 75 then want = 1 end
		if pct <= 50 then want = 2 end
		while spawned < want do
			spawned = spawned + 1
			eq.zone_emote(15, "A chamberlain attendant scuttles out of the spire!")
			local mob = eq.spawn2(ADD, 0, 0,
				e.self:GetX() + math.random(-25, 25),
				e.self:GetY() + math.random(-25, 25), e.self:GetZ(), 0)
			if mob ~= nil then
				local t = e.self:GetTarget()
				if t ~= nil then mob:AddToHateList(t, 1) end
			end
		end
		e.self:SetEntityVariable("adds", tostring(spawned))
	end
end
