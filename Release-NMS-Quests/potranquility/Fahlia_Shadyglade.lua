function event_say(e)
	local bertox_bucket = tonumber(e.other:GetAccountBucket("pop.flags.bertox")) or 0
	local newleaf_bucket = tonumber(e.other:GetAccountBucket("pop.flags.newleaf")) or 0
	local saryrn_bucket = tonumber(e.other:GetAccountBucket("pop.flags.saryrn")) or 0
	local shadyglade_bucket = tonumber(e.other:GetAccountBucket("pop.flags.shadyglade")) or 0
	local terris_bucket = tonumber(e.other:GetAccountBucket("pop.flags.terris")) or 0
	if bertox_bucket == 1 and terris_bucket == 1 then
		if (
			newleaf_bucket == 1 and
			saryrn_bucket >= 1 and
			shadyglade_bucket == 1
		) then
			if e.message:findi("Hail") then
				if saryrn_bucket ~= 2 then
					e.self:Say("Oh thank you for helping Tylis! We will be forever in your debt")
					e.other:SetAccountBucket("pop.flags.saryrn", "2")
					e.other:Message(MT.LightBlue, "You receive a character flag!")
				else
					e.self:Say("It looks like we've already spoken.")
				end
			end
		else
			if e.message:findi("Hail") then
				local condition_link = eq.silent_say_link("condition")
				e.self:Say(
					string.format(
						"Greetings travelers. Please excuse me but I must attend to Tylis for his [%s] does not improve.'",
						condition_link
					)
				)
			elseif e.message:findi("condition") then
				local black_cube_link = eq.silent_say_link("black cube")
				e.self:Say(
					string.format(
						"It all goes back to when I found him. I had just purchased a new fishing pole in the hopes of finding some time to relax on the shores of the island. As I was walking out of the shop, I heard a distant moan. I walked toward the source and found Tylis lying by the reflecting pool. The pool was different, though. It now had a small [%s] floating over it. I tried to wake Tylis but was not successful. I then brought him here and have been caring for him since.'",
						black_cube_link
					)
				)
			elseif e.message:findi("black cube") then
				local plane_of_torment_link = eq.silent_say_link("Plane of Torment")
				e.self:Say(
					string.format(
						"I do not like that cube at all. Just thinking of it brings pain to my mind. Gazing upon it gives the sensation of being slowly rent apart at each limb. I believe that whatever has fallen over Tylis is related to this cursed cube. Other elders claim that it is a portal that will lead into the [%s].'",
						plane_of_torment_link
					)
				)
			elseif e.message:findi("Plane of Torment") then
				local go_link = eq.silent_say_link("go")
				e.self:Say(
					string.format(
						"It is not a plane that was originally sought to be reached by our elders. It is their belief though that Saryrn, the Mistress of Torment, intends to breed her suffering even into this protected plane of Quellious. I wish I had the strength to [%s] into the Plane of Torment and find out exactly the nature of the current circumstances to have afflicted Tylis, but I cannot leave his side in good conscience.'",
						go_link
					)
				)
			elseif e.message:findi("go") then
				if shadyglade_bucket == 0 then
					e.self:Say("Wonderful. I did not think that an outsider was one that I could trust to aid me in this. One name that Tylis has mentioned in agony is that of Maareq. I do not know whom this is, but he must be instrumental in Tylis' suffering. You must find Maareq and do what you must to release Tylis from this torture.'")
					e.other:SetAccountBucket("pop.flags.shadyglade", "1")
					e.other:Message(MT.LightBlue, "You receive a character flag!")
				else
					e.self:Say("It looks like we've already spoken.")
				end
			end
		end
	else
		e.self:Say("I can see that you may be passionate to help others but now I must ask you to be about your own business. I sense that if you were to try to help you may befall the same fate as poor Tyllis. Perhaps you should become more experienced in travelling through the planes before you learn more about his condition.")
	end
end