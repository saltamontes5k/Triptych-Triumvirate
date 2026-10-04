-- #Chamberlain_XI (440710) -- openGyroBeza ground-floor rare.
-- Rasper: "spawns an add every 25%" (a_chamberlain_automaton 440717).

local ADD = 440717

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
		local want = math.min(4, math.floor((100 - pct) / 25))
		while spawned < want do
			spawned = spawned + 1
			eq.zone_emote(15, "The Chamberlain's guard rounds the corner!")
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
