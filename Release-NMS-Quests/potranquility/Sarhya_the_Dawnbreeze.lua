function event_say(e)
	if e.message:findi("hail") then
		local rallos_bucket = tonumber(e.other:GetAccountBucket("pop.flags.rallos")) or 0
		local plane_of_air_link =  eq.silent_say_link("Plane of Air")
		if rallos_bucket == 1 then
			e.self:Say(
				string.format(
					"It appears that you are ready to travel into the Elemental Planes. Beware many of the gods there have set up wards to protect them against assaults. Most I cannot speak about; however I do have information on the Circle of Protection that guards Xegony, in her [%s].",
					plane_of_air_link
				)
			)
		else
			e.self:Say(
				string.format(
					"Well met I am keeper of the Portal to the [%s].",
					plane_of_air_link
				)
			)
		end
	elseif e.message:findi("plane of air") then
		local rallos_bucket = tonumber(e.other:GetAccountBucket("pop.flags.rallos")) or 0
		if rallos_bucket == 1 then
			e.self:Say("Xegony has created four avatars, each one embodies a different aspect of her power, and each of these avatars was created with a portion of her very essence. The story goes, the one who possesses each of these essences may create a key to break Xegony's ward and enter into her inner sanctum. I don't know the truth behind this, as I have neither the power, nor the desire to challenge the Avatars myself. I have fashioned this, which I believe will form the four essences into a key.")
			e.other:SummonItem(17888) -- Pouch of Swirling Winds
		else
			e.self:Say("The Elemental Planes are not for idle exploration. Return to me when you have a reason to enter and I will consider opening the portal for you.")
		end
	elseif e.message:findi("elemental essences") then
		local qglobals = eq.get_qglobals(e.other)
		local mage_epic_global = tonumber(qglobals["mage_epic"]) or 0
		if mage_epic_global == 6 then
			e.self:Say("You seek the elemental essences? It has been a very long time since I've heard them spoke of. I am afraid I cannot be of much help, except to tell you it often enjoys to whistle through valleys and canyons. I fear it may not even reside in this realm any longer.")
			eq.set_global("mage_epic_air1", "1", 5, "F")
		end
	end
end