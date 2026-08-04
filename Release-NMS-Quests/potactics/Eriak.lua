function event_say(e)
	local tallon_bucket = tonumber(e.other:GetAccountBucket("pop.flags.tallon")) or 0
	local vallon_bucket = tonumber(e.other:GetAccountBucket("pop.flags.vallon")) or 0
	if tallon_bucket == 1 and vallon_bucket == 1 then
		if e.message:findi("hail") then
			local weapons_link = eq.silent_say_link("weapons")
			e.self:Emote(
				string.format(
					"grins at you coldly. 'The twins lie bleeding at the feet of Rallos, and the halls of Drunder shiver with uncertainty. But one challenge lies before you. Face the warlord and his two injured acolytes and the power of Drunder is yours for the taking. The Warlord will not fall easily. The weapons of dark courage will not be enough, your [%s] will require the power of torment to topple the Warlord.",
					weapons_link
				)
			)
		elseif e.message:findi("weapons") then
			local blood_link = eq.silent_say_link("blood")
			e.self:Say(
				string.format(
					"Though your weapons may have been effective against the twins, they will prove of little use against the Warlord. Temper them with the Torment of Saryn and you may yet be able to cleave the armor of the warlord. Insanity is not easily manipulated though. You'll have to suspend it in the [%s] of zek.",
					blood_link
				)
			)
		elseif e.message:findi("blood") then
			e.self:Emote("looks at you silently for a moment. His eyes scan from your feet up to your face and linger there, staring into your eyes. He blinks once, slowly. He then draws a dagger from his waist and throws the iron gauntlet from his left hand to the floor. The dagger drifts across his forearm, and without a sound cuts into his calloused skin. A trickle of dark blood creeps down his arm and drips into a small vial in Eriak's right hand. He hands you the vial, staring through your eyes into your soul without a word.")
			e.other:SummonItem(28592) -- Vial of Black Blood
		end
	else
		e.self:Emote("glares at you through blackened eyes of malice. 'Foolish, but brave I suppose. As if that word has any meaning in this place. Prove yourself on the field of blood if you dare.")
	end
end
