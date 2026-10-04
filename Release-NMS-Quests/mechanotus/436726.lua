-- #Head_Engineer_Gearwhir (436726) -- Spy Reports (300036): summons
-- mezzable skitter crews at 80/60/40/20%. Drops the Work Schedule (6x,
-- loot table 1520007323).

local THRESHOLDS = { 80, 60, 40, 20 }

function event_combat(e)
	if e.joined then
		e.self:SetEntityVariable("phase", "1")
		e.self:SetTimerMS("phase", 2000)
		eq.zone_emote(15, "Head Engineer Gearwhir: 'An unauthorized audit? CALL THE CREWS!'")
	else
		e.self:StopTimer("phase")
	end
end

function event_timer(e)
	local phase = tonumber(e.self:GetEntityVariable("phase") or "1") or 1
	if phase > #THRESHOLDS then return end
	if e.self:GetHPRatio() <= THRESHOLDS[phase] then
		e.self:SetEntityVariable("phase", tostring(phase + 1))
		eq.zone_emote(15, "Gearwhir whistles -- skitters pour from the assembly racks!")
		local x, y, z = e.self:GetX(), e.self:GetY(), e.self:GetZ()
		for i = 1, 2 do
			local mob = eq.spawn2(436724, 0, 0, x + math.random(-35, 35),
				y + math.random(-35, 35), z, 0)
			if mob ~= nil then
				local t = e.self:GetTarget()
				if t ~= nil then mob:AddToHateList(t, 1) end
			end
		end
	end
end

function event_death_complete(e)
	eq.zone_emote(15, "Head Engineer Gearwhir's wrench clatters. The work schedule is pinned to his chassis.")
end
