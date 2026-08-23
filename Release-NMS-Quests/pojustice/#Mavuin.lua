function event_say(e)
	local mavuin_bucket = tonumber(e.other:GetAccountBucket("pop.flags.mavuin")) or 0
	local tribunal_bucket = tonumber(e.other:GetAccountBucket("pop.flags.tribunal")) or 0
	if e.message:findi("Hail") then
		local valor_bucket = tonumber(e.other:GetAccountBucket("pop.flags.valor")) or 0
		if mavuin_bucket == 0 then
			local what_information_link = eq.silent_say_link("what information", "this information")
			e.self:Say(
				string.format(
					"I have been locked away, shamed for a reason that is not my own! Take [%s] to the Tribunal, I beg of you! It may be the only chance to prove that I am truly innocent!",
					what_information_link
				)
			)
		elseif mavuin_bucket == 1 and tribunal_bucket == 1 then
			if valor_bucket == 0 then
				e.self:Say("So you have pleaded my case to the Tribunal, I am most thankful. I hope that they will listen to my case soon and release me. The knowledge that I promised you is this. The followers in the Plane of Tranquility are trying to find information on what has happened to Zebuxoruk. What I know is that he has been captured for a second time. If you want to find out more information I believe you should seek an audience with Karana and Mithaniel Marr. I can only assume that they were present at the time of his capture and know why this has taken place. Also seek from Marr a way to translate the divine language. Only with it can you understand the writing of the gods. There is no more that I can tell you, but thank you once again for your attempt in returning my freedom.")
				e.other:SetAccountBucket("pop.flags.valor", "1")
				e.other:Message(MT.LightBlue, "You receive a character flag!")
			else
				e.self:Say("It looks like we've already spoken.")
			end
		end
	elseif e.message:findi("what information") then
		if mavuin_bucket == 0 then
			local plea_your_case_link = eq.silent_say_link("plea your case", "plea my case")
			e.self:Say(
				string.format(
					"Oh, excuse me... The Tribunal is not a being who deals with parchment and quills, he will test you to allow me to [%s]. When you tell him of my request you must mention my name, be prepared, %s.",
					plea_your_case_link,
					e.other:GetCleanName()
				)
			)
		end
	elseif e.message:findi("plea your case") then
		if mavuin_bucket == 0 then
			e.self:Say("Thank you! I wish you luck.")
			e.other:SetAccountBucket("pop.flags.mavuin", "1")
			e.other:Message(MT.LightBlue, "You receive a character flag!")
		end
	end
end