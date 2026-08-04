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
	local terris_bucket = tonumber(e.other:GetAccountBucket("pop.flags.terris")) or 0
	if e.message:findi("Hail") then
		if terris_bucket == 0 then
			e.other:SetAccountBucket("pop.flags.terris", "1")
			e.other:Message(MT.LightBlue, "You receive a character flag!")
		else
			e.self:Say("It looks like we've already spoken.")
		end
	end
end