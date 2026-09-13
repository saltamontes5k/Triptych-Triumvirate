function event_spawn(e)
	eq.set_timer("Depop", 600 * 1000) -- 10 Minutes
end

function event_timer(e)
	if e.timer == "Depop" then
		eq.stop_timer("Depop")
		eq.depop()
	end
end

function event_say(e)
	if e.message:findi("Hail") then
		local xegony_bucket = tonumber(e.other:GetAccountBucket("pop.flags.xegony")) or 0
		e.other:SummonItem(29164) -- Item: Amorphous Cloud of Air
		if xegony_bucket == 0 then
			e.other:SetAccountBucket("pop.flags.xegony", "1")
			e.other:Message(MT.LightBlue, "You receive a character flag!")
		else
			e.self:Say("It looks like we've already spoken.")
		end
	end
end