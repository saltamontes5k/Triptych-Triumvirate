function event_say(e)
	if e.message:findi("elemental essences") then
		local qglobals = eq.get_qglobals(e.other)
		local mape_epic_global = tonumber(qglobals["mage_epic"]) or 0
		if mage_epic_global == 6 then
			e.self:Say("Ahh the eternal search for knowledge, both bane and blessing to mortals. So, you seek the Elemental Essence of Fire? I have heard very little of it in many years, although, come to think of it, I have heard rumors of a powerful elemental trapped in the personal forge of Tagrin. I suspect that might be a good place to begin your search at the very least, but you'll need to find someone there willing to speak with you. Good luck seeker.")
			eq.set_global("mage_epic_fire1", "1", 5, "F")
		end
	elseif e.message:findi("hail") then
			local solusek_bucket = tonumber(e.other:GetAccountBucket("pop.flags.solusek")) or 0
			if solusek_bucket == 1 then
				e.self:Say(
					string.format(
						"So, you actually defeated Solusek Ro. Impressive, for a mortal. Enjoy your stay in the Burning Lands. It has been a while since I smelt a burning %s.",
						eq.get_race_name(e.other:GetBaseRace())
					)
				)
			else
				local portals_destination_link = eq.silent_say_link("portal's destination")
				e.self:Say(
					string.format(
						"Greetings mortal. Are you here about this [%s]? I have been getting a lot of questions about it lately.",
						portals_destination_link
					)
				)
			end
	elseif e.message:findi("portal's destination") then
			local solusek_ro_link = eq.silent_say_link("Solusek Ro")
			e.self:Say(
				string.format(
					"As I suspected. This portal leads to Doomfire, the Burning Lands, home to Fennin Ro, the Tyrant of Fire. Or rather, it used to. His son, [%s], disapproved of the number of you mortals entering his father's plane, and so he sealed it. It's a shame really, I was starting to enjoy the sounds you mortals make when you fall into the lava.",
					solusek_ro_link
				)
			)
	elseif e.message:findi("solusek ro") then
			e.self:Say("So I've got another one eh? Alright, well if you really want to enter the relm of the flame, you're going to have to 'convince' the Burning Prince to remove his seal. He has been staying in his tower lately, so you will be able to find him there. Not that it matters. Nobody ever makes it to see him anyways.")
	end
end
