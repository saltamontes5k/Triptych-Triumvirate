function event_death_complete(e)
	eq.zone_emote(1, "Loud cries of hopelessness echo throughout the burning lands. The creatures of Doomfire call out to their master, Fennin Ro the Tyrant of Fire, for his dead body now lies at the feet of the mighty adventurers.")
	if tostring(eq.get_zone_instance_version()) == eq.get_rule("Custom:StaticInstanceVersion") then -- Only flag in non-respawning dz
		eq.spawn2(217058, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading()) -- Essence_of_Fire
	end
end

function event_killed_merit(e)
	if tostring(eq.get_zone_instance_version()) == eq.get_rule("Custom:StaticInstanceVersion") then -- Only flag in non-respawning dz
		local fennin_bucket = tonumber(e.other:GetAccountBucket("pop.flags.fennin")) or 0
		if fennin_bucket == 0 then
			e.other:SummonItem(29147) -- Item: Globe of Dancing Flame
			e.other:SetAccountBucket("pop.flags.fennin", "1")
			e.other:Message(MT.LightBlue, "You receive a character flag!")
		end
	end
end
