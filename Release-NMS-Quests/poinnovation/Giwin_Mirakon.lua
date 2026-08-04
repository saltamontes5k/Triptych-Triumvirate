function event_signal(e)
	if e.signal == 1 then
		e.self:Shout("Quickly! Come see me!")
		e.self:SetEntityVariable("Ready", "1")
		eq.set_timer("Clear", 1800 * 1000) -- 30 Minutes
	elseif e.signal == 2 then
		e.self:Shout("Fool! The machine cannot work outside of the room!")
	end
end

function event_timer(e)
	if e.timer == "Clear" then
		eq.stop_timer("Clear")
		e.self:DeleteEntityVariable("Ready")
	end
end

function event_say(e)
	local behemoth_bucket = tonumber(e.other:GetAccountBucket("pop.flags.behemoth")) or 0
	local ready_variable = tonumber(e.self:GetEntityVariable("Ready")) or 0
	if e.message:findi("Hail") then
		if behemoth_bucket < 1 or ready_variable ~= 1 then
			local great_warrior_link = eq.silent_say_link("great warrior")
			e.self:Say(
				string.format(
					"How did you get in here? Hrmm no matter, you will be helping me now for I am a [%s] of Rallos Zek and I know you wish not to provoke my fury!",
					great_warrior_link
				)
			)
		else
			if behemoth_bucket == 1 then
				e.other:SetAccountBucket("pop.flags.behemoth", "2")
				e.other:Message(MT.LightBlue, "You receive a character flag!")
			else
				e.self:Say("It looks like we've already spoken.")
			end
		end
	elseif e.message:findi("great warrior") then
		if behemoth_bucket == 0 then
			local task_link = eq.silent_say_link("task")
			e.self:Say(
				string.format(
					"Yeah, you heard me! You know that I must be important if Rallos himself has plucked me from battlefield to complete this [%s]. Even though I serve my lord, I am desperate to return to my place on the eternal battlefield.",
					task_link
				)
			)
		end
	elseif e.message:findi("task") then
		if behemoth_bucket == 0 then
			local test_the_machine_link = eq.silent_say_link("test the machine")
			e.self:Say(
				string.format(
					"Ya, you see Rallos sent me here to contract the machines to work on a mana powered piece of machinery that could test all on the eternal battlefield. This weapon of ultimate destruction is taking quite a long time to be completed. You know.. If you were to go [%s] and it were to fail against you I could be on my way back to tell Rallos that it was defeated by mere mortals. Help me to get back to the battlefield and out of this rusted out junkheap.",
					test_the_machine_link
				)
			)
		end
	elseif e.message:findi("test the machine") then
		if behemoth_bucket == 0 then
			e.self:Say("Haha! I knew I sensed the warring spirit within you. Go through over there. Ignore those steam powered soldiers and their talk of perimeters. Go into the main construction area. You will know you are there when you see power carriers taking energy to power up the machine. If you can stop the energy carriers from releasing their energy the machine will activate to see what has happened. I shall come to check on you and take a full report when you have destroyed it. Long live Rallos!")
			e.other:SetAccountBucket("pop.flags.behemoth", "1")
			e.other:Message(MT.LightBlue, "You receive a character flag!")
		else
			e.self:Say("It looks like we've already spoken.")
		end
	end
end