function event_spawn(e)
	eq.set_timer("Depop", 1200 * 1000) -- 20 Minutes
end

function event_timer(e)
	if e.timer == "Depop" then
		eq.stop_timer("Depop")
		eq.depop()
	end
end

function event_say(e)
	if e.message:findi("Hail") then
		local aerin_bucket = tonumber(e.other:GetAccountBucket("pop.flags.aerin")) or 0
		if aerin_bucket == 0 then
			if not e.other:HasZoneFlag(Zone.hohonora) then
				e.other:SetZoneFlag(Zone.hohonora)
				e.other:Message(MT.LightBlue, "You receive a character flag!")
			end	
			e.other:SetAccountBucket("pop.flags.aerin", "1")
			e.other:Message(MT.LightBlue, "You receive a character flag!")
		else
			e.self:Say("It looks like we've already spoken.")
		end
	end
end