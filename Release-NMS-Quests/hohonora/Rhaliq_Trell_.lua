function event_spawn(e)
	e.self:Shout("Clever ones you are!")
	eq.set_timer("Depop", 600 * 1000) -- 10 Minutes
end

function event_timer(e)
	if e.timer == "Depop" then
		eq.stop_timer("Depop")
		eq.depop()
	end
end

function event_say(e)
	local trell_bucket = tonumber(e.other:GetAccountBucket("pop.flags.trell")) or 0
	if e.message:findi("Hail") and trell_bucket ~= 1 then
		e.self:Say("Congratulations... Two other trials and you may have proven yourself worthy to stand before Lord Marr.")
		e.other:SetAccountBucket("pop.flags.trell", "1")
		e.other:Message(MT.LightBlue, "You receive a character flag!")
	end
end
