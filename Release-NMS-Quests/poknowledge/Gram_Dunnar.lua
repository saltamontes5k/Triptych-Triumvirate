function event_say(e)
	if e.other:GetLevel() < 51 then
		e.self:Emote("The old dwarf glances at you briefly, then returns his attention to a small wooden object he is carving. 'Got no time for kids like you,' he grunts.")
	end

	if e.message:findi("Hail") then
		local craft_link = eq.silent_say_link("craft")
		local stories_link = eq.silent_say_link("stories")
		e.self:Say(
			string.format(
				"The old dwarf looks up at you slowly, his wrinkled hands continuing to carve a small wooden object. He grins as he eyes your dust-covered outfit and well-used equipment. 'Ahh, a young adventurer,' he says. 'Warms my heart to see the spirit I once had still going strong. Got too old, you see. He strokes his beard. 'Tried taking up a [%s], but it just isn't the same. Sure would be nice to hear some [%s] about those new places I'll never get to see.",
				craft_link,
				stories_link
			)
		)
	elseif e.message:findi("stories") then
		local story_bucket = tonumber(e.other:GetBucket("pop.flags.story")) or 0

		local stories = {
			[0] = {
				required = { mavuin = 1, tribunal = 1, valor = 1 },
				reward_flag = "pop.aa.stormvalor",
				message = "Gram Dunnar listens eagerly to your tales of the Plane of Valor and Plane of Storms. 'Everything turned to glass by the dragon! That must be a sight,' he exclaims. 'Wish I could go there,' he sighs."
			},
			[1] = {
				required = { adler = 1, elder = 1, grummus = 1 },
				reward_flag = "pop.aa.codecay",
				message = "Gram Dunnar shudders as you tell him of the Crypt of Decay. 'A foul place, indeed. I would have loved to slay a few of those creatures, though.'"
			},
			[2] = {
				required = { behemoth = 2 },
				reward_flag = "pop.aa.tactics",
				message = "Gram Dunnar grins excitedly at your description of the Plane of Tactics. 'I'd show the minions of Rallos Zek something, I would!'"
			},
			[3] = {
				required = { aerin = 1, mavuin = 1, tribunal = 1, valor = 1 },
				reward_flag = "pop.aa.hohonor",
				message = "'Animated suits of armor, eh?' Gram says as you tell him of the Halls of Honor. 'Saw something like that once, but never so many as that.'"
			},
			[4] = {
				required = { askr = 4, mavuin = 1, valor = 1, tribunal = 1 },
				reward_flag = "pop.aa.bothunder",
				message = "'Giants and a huge fortress,' Gram sighs wistfully as you finish your story of the Bastion of Thunder. 'Storming through a place like that, killing everything in sight - those were good days.'"
			},
			[5] = {
				required = { adler = 1, bertox = 1, codecay = 2, construct = 1, elder = 1, grummus = 1, hedge = 1, poxbourne = 1, terris = 1 },
				reward_flag = "pop.aa.potorment",
				message = "Gram Dunnar listens attentively to your story of the Plane of Torment. 'Ravens with bloody eyes,' he muses, 'and creatures with four mouths?'"
			},
			[6] = {
				required = { behemoth = 2, marr = 1, saryrn = 2, tallon = 1, vallon = 1 },
				reward_flag = "pop.aa.solrotower",
				message = "Gram Dunnar strokes his beard thoughtfully as you tell him of the Tower of Solusek Ro. 'The burning prince himself. A worthy opponent, I'm sure,' he says."
			}
		}

		if story_bucket >= 0 and story_bucket <= 6 then
			local current_story = stories[story_bucket]
			local all_requirements_met = true
			for flag, required_value in pairs(current_story.required) do
				local current_flag = string.format("pop.flags.%s", flag)
				local current_flag_value = tonumber(e.other:GetAccountBucket(current_flag)) or 0
				if current_flag_value ~= required_value then
					all_requirements_met = false
					break
				end

				local reward_flag_value = tonumber(e.other:GetBucket(current_story.reward_flag)) or 0
				if reward_flag_value ~= 0 then
					all_requirements_met = false
					break
				end
			end

			if all_requirements_met then
				e.other:Message(MT.LightBlue, current_story.message)
				e.other:AddAAPoints(1)
				e.other:Message(MT.White, "You've earned an AA Point!")
				e.other:SetBucket(current_story.reward_flag, "1")
				e.other:SetBucket("pop.flags.story", tostring(story_bucket + 1))
			else
				e.self:Say("You need to adventure more it seems, come back to me once you're done.")
			end
		else
			e.self:Say("I've already heard all of those stories!")
		end
	elseif e.message:findi("craft") then
		for class_id = 1, 16 do
			if e.other:HasClassID(class_id) then
				local item_id = 2035000 + class_id
				if e.other:HasItem(item_id) then
					e.self:Say("It looks like you already have a figurine.")
				--	return
				else
					e.other:SummonFixedItem(item_id)
				end
			end
		end

		e.self:Emote("Gram Dunnar stops carving and holds up the object between his short fingers. It is a figurine of a swordsman with many intricate details. 'No one really wants to buy them, these days. If there's no magic in it...' he shrugs. 'Still, something to take up some time.' He rummages through some finished pieces on the floor around him, picks up one, and tosses it to you. 'Here,' he says. 'Maybe it'll bring you some luck.")
	end
end
