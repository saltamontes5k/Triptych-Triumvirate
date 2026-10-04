-- #Captain_Gearwell (441703) -- Cut Off the Head (301108). Dispels buffs
-- (live: 4 casts) and slings Freezing Mist (7939).

function event_combat(e)
	if e.joined then
		e.self:SetEntityVariable("dispel_n", "0")
		e.self:SetTimer("tricks", 22000)
	else
		e.self:StopTimer("tricks")
	end
end

function event_timer(e)
	if e.timer == "tricks" then
		local t = e.self:GetTarget()
		if t == nil then return end
		local n = tonumber(e.self:GetEntityVariable("dispel_n") or "0") or 0
		if n < 4 and t:IsClient() then
			-- strip the target's buffs (live dispel behavior)
			t:BuffFadeByEffect(0)
			e.self:SetEntityVariable("dispel_n", tostring(n + 1))
			e.self:Say("Your gadgets, stripped! Your protections, VOID!")
		end
		e.self:CastSpell(7939, t:GetID())
	end
end
