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
		local marr_bucket = tonumber(e.other:GetAccountBucket("pop.flags.marr")) or 0
		if marr_bucket == 0 then
			e.other:SetAccountBucket("pop.flags.marr", "1")
			e.other:Message(MT.LightBlue, "You receive a character flag!")
		end
	end
end