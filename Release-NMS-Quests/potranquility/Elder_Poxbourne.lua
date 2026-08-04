function event_say(e)
	local hedge_bucket = tonumber(e.other:GetAccountBucket("pop.flags.hedge")) or 0
	local terris_bucket = tonumber(e.other:GetAccountBucket("pop.flags.terris")) or 0
	local poxbourne_bucket = tonumber(e.other:GetAccountBucket("pop.flags.poxbourne")) or 0
	if hedge_bucket == 1 and terris_bucket == 1 then
		if e.message:findi("Hail") then
			if poxbourne_bucket == 0 then
				e.self:Say(
					string.format(
						"Finally, after all this time, my mind is at peace... thank you, %s, Subduer of Torment.",
						e.other:GetCleanName()
					)
				)
				e.other:SetAccountBucket("pop.flags.poxbourne", "1")
				e.other:Message(MT.LightBlue, "You receive a character flag!")
			else
				e.self:Say("It looks like we've already spoken.")
			end
		end
	end
end