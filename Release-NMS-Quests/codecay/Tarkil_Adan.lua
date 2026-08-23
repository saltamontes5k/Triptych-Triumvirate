--[[function event_spawn(e) -- Disabled flag mob despawn timer to behave similar to other PoP flag mobs - Twinkles
	eq.set_timer("Depop", 1200 * 1000) -- 20 Minutes
end

function event_timer(e)
	if e.timer == "Depop" then
		eq.stop_timer("Depop")
		eq.depop()
	end
end]]

function event_say(e)
	if e.message:findi("Hail") then
		local codecay_bucket = tonumber(e.other:GetAccountBucket("pop.flags.codecay")) or 0
		if codecay_bucket == 0 then
			e.self:Emote("lets out a groan and then whimpers saying, 'Yes great ones yesss I was king once I wasss. ' The creature then mutters under his breath and passes you a small glowing bone fragment etched in runes. Then speaks again saying, 'The tortured ones oh the tortured ones, you must go to the depths of Lxanvom and free them. Go to the bone throne at the ruins entrance there you will find access to the depths.' He then goes back to whimpering and rocking back and forth.")
			e.other:SetAccountBucket("pop.flags.codecay", "1")
			e.other:Message(MT.LightBlue, "You receive a character flag!")
		else
			e.self:Say("It looks like we've already spoken.")
		end
	end
end