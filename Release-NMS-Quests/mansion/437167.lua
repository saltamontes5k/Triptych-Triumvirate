-- a valve inspector (437167) -- Spy Reports (300036) Mansion finale.
-- Hail + "ready" starts the ring event: five waves of Steamwork
-- Eradicators. The task's kill activity (20) tracks the credit.

function event_say(e)
	if e.message:findi("ready") then
		if e.other:IsTaskActive(300036)
			and e.self:GetEntityVariable("ring") ~= "1" then
			e.self:SetEntityVariable("ring", "1")
			e.self:Say("Ready the lines! The valve spins -- they know we "
				.. "are here! Eradicators, FORWARD!")
			e.self:SetTimer("wave", 3000)
		elseif e.self:GetEntityVariable("ring") == "1" then
			e.self:Say("The eradicators are still coming -- hold the line!")
		else
			e.self:Say("The valves are sealed and quiet. Gurtrude's errands "
				.. "do not concern me.")
		end
	end
end

function event_timer(e)
	local wave = tonumber(e.self:GetEntityVariable("wave_n") or "0") or 0
	if wave >= 4 then
		e.self:StopTimer("wave")
		return
	end
	e.self:SetEntityVariable("wave_n", tostring(wave + 1))
	eq.zone_emote(15, "Steamwork Eradicators pour from the Mansion ducts! (" .. (wave + 1) .. "/4)")
	local x, y, z = e.self:GetX(), e.self:GetY(), e.self:GetZ()
	for i = 1, 5 do
		eq.spawn2(436738, 0, 0, x + math.random(-60, 60),
			y + math.random(-60, 60), z, 0)
	end
end
