function event_say(e)
	local codecay_bucket = tonumber(e.other:GetAccountBucket("pop.flags.codecay")) or 0
	if codecay_bucket >= 1 then
		if e.message:findi("Hail") then
			local challenge_bertoxxulous_link = eq.silent_say_link("Challenge Bertoxxulous")
			e.self:Say(
				string.format(
					"You believe you can [%s], mortal?",
					challenge_bertoxxulous_link
				)
			)
		elseif e.message:findi("Challenge Bertoxxulous") then
			e.self:Say("Give the Crypt Lord my regards.")
			e.other:MovePC(200, 0, -16, -289, 128) -- Zone: lakeofillomen
		end
	end
end
