function event_say(e)
	local adler_bucket = tonumber(e.other:GetAccountBucket("pop.flags.adler")) or 0
	if adler_bucket == 0 then
		if e.message:findi("Hail") then
			local portal_to_the_plane_of_disease_link = eq.silent_say_link("portal to the Plane of Disease")
			e.self:Say(
				string.format(
					"Can you smell it? It is the musk of death and pestilence. It is a smell that I have welcomed for so long, but now it turns my stomach. My brother Milyk and I have come here from Qeynos. We were members of the Bloodsabers but sought higher enlightenment. Upon arriving here Milyk began to channel all of his energy into opening the [%s].",
					portal_to_the_plane_of_disease_link
				)
			)
		elseif e.message:findi("portal to the Plane of Disease") then
			local ward_link = eq.silent_say_link("ward")
			e.self:Say(
				string.format(
					"We sought only the wisdom of Bertoxxulous. When Milyk finished his chant and the portal opened, it began to spew out this vile pestilence you see before you. Milyk caught the brunt of the plague, and his condition worsens. I have been infected as well, and am weak but I will go into the plane to save my brother if I must. The weavers have seen in their tapestries that one holds a [%s] that will halt the effects of the toxins that the touch of Bertoxxulous brings.",
					ward_link
				)
			)
		elseif e.message:findi("ward") then
			local adler_bucket = tonumber(e.other:GetAccountBucket("pop.flags.adler")) or 0
			if adler_bucket == 0 then
				e.self:Say("The ward is carried by the one that Bertoxxulous has created to protect the entrance into his den. If you dare travel into this pungent plane and find the ward bring it back. If we can halt the advanced toxins in Milyk's system maybe we can save him.")
				e.other:SetAccountBucket("pop.flags.adler", "1")
				e.other:Message(MT.LightBlue, "You receive a character flag!")
			else
				e.self:Say("It looks like we've already spoken.")
			end
		end
	elseif adler_bucket == 1 then
		local grummus_bucket = tonumber(e.other:GetAccountBucket("pop.flags.grummus")) or 0
		if grummus_bucket == 1 then
			e.self:Say("Please you must hurry! Take the ward that surrounds you back to my brother and lift the sickness that has come over him!")
		else
			e.self:Say("You must defeat Grummus!")
		end
	end
end