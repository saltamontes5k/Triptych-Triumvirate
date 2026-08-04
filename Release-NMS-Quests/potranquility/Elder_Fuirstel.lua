function event_say(e)
	local adler_bucket = tonumber(e.other:GetAccountBucket("pop.flags.adler")) or 0
	local elder_bucket = tonumber(e.other:GetAccountBucket("pop.flags.elder")) or 0
	local grummus_bucket = tonumber(e.other:GetAccountBucket("pop.flags.grummus")) or 0
	if (
		adler_bucket == 1 and
		elder_bucket == 0 and
		grummus_bucket == 1
	) then
		e.self:Message(MT.LightBlue, "Elder Fuirstel slowly turns towards you. You can feel the heat radiating from his face. The warding that envelopes your body reaches out and begins to surround him. You immediately see improvement in his condition. The pus filled sores covering his face and his burning fever start to vanish.")
		e.other:SetAccountBucket("pop.flags.elder", "1")
		e.other:Message(MT.LightBlue, "You receive a character flag!")
	else
		local bertox_bucket = tonumber(e.other:GetAccountBucket("pop.flags.bertox")) or 0
		local codecay_bucket = tonumber(e.other:GetAccountBucket("pop.flags.codecay")) or 0
		if bertox_bucket == 1 then
			if codecay_bucket ~= 2 then
				e.self:Emote(
					string.format(
						"Elder Fuirstel looks surprisingly better than when you last saw him. Elder Fuirstel says 'You actually did it! You defeated Bertoxxulous! I could feel it the moment he fell. Thank you very much, %s. You have done this world a great service.'",
						e.other:GetCleanName()
					)
				)
				e.other:SetAccountBucket("pop.flags.codecay", "2")
				e.other:Message(MT.LightBlue, "You receive a character flag!")
			else
				e.self:Say("It looks like I've helped you all I can.")
			end
		else
			e.other:Say("You must defeat Bertoxxulous!")
		end
	end
end