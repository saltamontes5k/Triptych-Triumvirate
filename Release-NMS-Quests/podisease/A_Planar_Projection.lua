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
	local grummus_bucket = tonumber(e.other:GetAccountBucket("pop.flags.grummus")) or 0
	if e.message:findi("Hail") then
		if grummus_bucket == 0 then
			e.other:SetZoneFlag(Zone.codecay)
			e.other:SetAccountBucket("pop.flags.grummus", "1")
			e.other:Message(MT.LightBlue, "You receive a character flag!")
			e.self:Say("You need to journey to the Crypt of Decay to continue.")
		else
			e.self:Say("It looks like we've already spoken.")
		end
	end
end