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
		local saryrn_bucket = tonumber(e.other:GetAccountBucket("pop.flags.saryrn")) or 0
		if saryrn_bucket == 0 then
			e.other:Message(MT.DarkGray, "The Planar Projection seems to flicker in and out of existence. It seems to be impressed and grateful for the death of Saryrn.")
			e.other:SetAccountBucket("pop.flags.saryrn", "1")
			e.other:Message(MT.LightBlue, "You receive a character flag!")
		else
			e.self:Say("It looks like we've already spoken.")
		end
	end
end