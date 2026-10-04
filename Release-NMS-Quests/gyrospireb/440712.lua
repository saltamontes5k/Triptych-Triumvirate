-- #Engineer_Tristos (440712) -- openGyroBeza basement rare.
-- Rasper: "can spawn fire elemental adds" (an_elemental_flame 440718).

local ADD = 440718
local CAP = 3

function event_spawn(e)
	e.self:SetEntityVariable("adds", "0")
end

function event_combat(e)
	if e.joined then
		e.self:SetTimer("forge", 45000)
	else
		e.self:StopTimer("forge")
	end
end

function event_timer(e)
	if e.timer == "forge" then
		local n = tonumber(e.self:GetEntityVariable("adds") or "0") or 0
		if n >= CAP then return end
		e.self:SetEntityVariable("adds", tostring(n + 1))
		e.self:Say("The forge provides!")
		eq.zone_emote(15, "A fire elemental claws its way out of the boiler!")
		local mob = eq.spawn2(ADD, 0, 0,
			e.self:GetX() + math.random(-30, 30),
			e.self:GetY() + math.random(-30, 30), e.self:GetZ(), 0)
		if mob ~= nil then
			local t = e.self:GetTarget()
			if t ~= nil then mob:AddToHateList(t, 1) end
		end
	end
end
