-- #Hartmut (440703) -- Sand in the Gears (301102). At 80/55/30% he flees
-- lower down the spire (depop + respawn at an offset, hate carried over);
-- the last stand is fought to the death.

local FLEES = { 80, 55, 30 }

function event_combat(e)
	if e.joined then
		e.self:SetTimerMS("fleecheck", 2000)
	else
		e.self:StopTimer("fleecheck")
	end
end

function event_timer(e)
	local n = tonumber(e.self:GetEntityVariable("flee_n") or "1") or 1
	if n > #FLEES then return end
	if e.self:GetHPRatio() <= FLEES[n] then
		e.self:SetEntityVariable("flee_n", tostring(n + 1))
		e.self:Say("This floor bores me! We continue... below.")
		local x, y, z = e.self:GetX(), e.self:GetY(), e.self:GetZ()
		local t = e.self:GetTarget()
		e.self:Depop()
		local next_form = eq.spawn2(440703, 0, 0, x - 120, y - 120, z - 90, 0)
		if next_form ~= nil then
			next_form:SetEntityVariable("flee_n", tostring(n + 1))
			if t ~= nil then next_form:AddToHateList(t, 1) end
		end
	end
end
