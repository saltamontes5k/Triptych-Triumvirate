function event_spawn(e)
	eq.set_timer("Depop", 600 * 1000) -- 10 Minutes
end

function event_timer(e)
	if e.timer == "Depop" then
		eq.spawn_condition(eq.get_zone_short_name(), eq.get_zone_instance_id(), 2, 0)
		eq.stop_timer("Depop")
		eq.depop()
	end
end

function event_say(e)
	if e.message:findi("Hail") then
		local fennin_bucket = tonumber(e.other:GetAccountBucket("pop.flags.fennin")) or 0
		e.other:SummonItem(29147) -- Item: Globe of Dancing Flame
		if fennin_bucket == 0 then			
			e.other:SetAccountBucket("pop.flags.fennin", "1")
			e.other:Message(MT.LightBlue, "You receive a character flag!")
		else
			e.self:Say("It looks like we've already spoken.")
		end
	end
end