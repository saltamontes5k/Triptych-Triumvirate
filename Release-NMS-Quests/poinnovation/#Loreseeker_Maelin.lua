function event_say(e)
	if (
		e.other:HasItem(29165) or
		e.other:HasItem(1029165) or
		e.other:HasItem(2029165) or
		e.other:HasItem(18637) or
		e.other:HasItem(1018637) or
		e.other:HasItem(2018637)
	) then
		if e.message:findi("Hail") then
			local researched_link = eq.silent_say_link("researched")
			e.self:Emote(
				string.format(
					"fidgets about with excitement, 'So here you are, this is quite impressive. I cannot wait to see the results of this impressive machine! I have coordinated with the clockworks here that have not gone mad. We have set the machine to tear a point of time open that should be equal to that based on the cipher and history that we have [%s].'",
					researched_link
				)
			)
		elseif e.message:findi("researched") then
			e.self:Say("Based on the findings from the information that you brought back to me I have determined the exact time to open. I believe the machine will work. Please step up and activate the machine! Once you have formed a bond with the Plane of Time you will be able to access the Plane again through the Plane of Tranquility. They have built a portal there, but no one was able to become attuned to that plane, until you that is. Good luck!")
			e.other:SetAccountBucket("pop.flags.maelin", "1")
			e.other:Message(MT.LightBlue, "You receive a character flag!")
		end
	end
end