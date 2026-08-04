function event_spawn(e)
	eq.set_timer("Depop", 1800 * 1000) -- 30 Minutes
end

function event_timer(e)
	if e.timer == "Depop" then
		eq.stop_timer("Depop")
		eq.depop()
	end
end

function event_say(e)
	if e.message:findi("Hail") then
		e.other:SummonItem(29146) -- Item: Mound of Living Stone
		local rathe_bucket = tonumber(e.other:GetAccountBucket("pop.flags.rathe")) or 0
		if rathe_bucket == 0 then
			e.other:SetAccountBucket("pop.flags.rathe", "1")
			e.other:Message(MT.LightBlue, "You receive a character flag!")
		end
	end
end