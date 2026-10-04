-- #Head_Sizentist_Myrmel_Gorgoth (439709) -- Tactical Teleportation
-- (301113) boss. Power-up emotes while engaged; each surge self-buffs
-- (Steam Shield) and heals a sliver, so burn him before the 4th.

function event_combat(e)
	if e.joined then
		e.self:SetEntityVariable("surge", "0")
		e.self:SetTimer("surge", 20000)
		e.self:Say("Unauthorized matter in my laboratory. How... novel.")
	else
		e.self:StopTimer("surge")
	end
end

function event_timer(e)
	if e.timer == "surge" then
		local n = tonumber(e.self:GetEntityVariable("surge") or "0") or 0
		n = n + 1
		e.self:SetEntityVariable("surge", tostring(n))
		if n <= 3 then
			eq.zone_emote(15, "Gorgoth drinks from a teleporter conduit -- he swells with power! (" .. n .. "/3)")
			e.self:Heal(5)
			e.self:CastSpell(7934, e.self:GetID())
		else
			eq.zone_emote(15, "Gorgoth's frame blazes -- the next blow will be CATASTROPHIC.")
			e.self:CastSpell(7934, e.self:GetID())
		end
	end
end
