function event_say(e)
	local valor_bucket = tonumber(e.other:GetAccountBucket("pop.flags.valor")) or 0
	local askr_bucket = tonumber(e.other:GetAccountBucket("pop.flags.askr")) or 0

	if valor_bucket == 1 then
		if e.message:findi("Hail") then
			if askr_bucket == 2 then
				e.self:Say("Prove your strength: slay one giant from each faction. Return a Srerendi beard, a Krendic bone, and a Kelek`Vor sash in the bag.")
			elseif askr_bucket == 3 then
				e.self:Say("The giants are fierce. Each tribe leader holds a piece to open the Bastion of Thunder. Seal two pieces in the bag, and I'll forge your medallion.")
			else
				local problem_link = eq.silent_say_link("problem")
				e.self:Emote(
					string.format(
						"gazes at you with a rough beard and reeking of ale. 'Not here to clean? You wouldn't handle this [%s] anyway. Leave me to my drink.'",
						problem_link
					)
				)
			end
		elseif e.message:findi("problem") then
			e.self:Emote("gestures toward the cave exit. 'Can't you see the monsters outside, pillaging at will? If you want to help, bring me one of their heads. Until then, I'm doomed with my *hic* potions.'")
		elseif e.message:findi("yes") then
			local askr_bucket = tonumber(e.other:GetAccountBucket("pop.flags.askr")) or 0
			local continue_link = eq.silent_say_link("continue")
			if askr_bucket == 1 then
				e.self:Say(
					string.format(
						"Remarkable—you've slain a giant. I've been trapped here by storm giants for too long. They once moved as one but now split around Mount Grenidor. [%s]",
						continue_link
					)
				)
			end
		elseif e.message:findi("continue") then
			if askr_bucket == 1 then
				local continue_link = eq.silent_say_link("continue")
				e.self:Say(
					string.format(
						"South of Grenidor: Srerendi giants rule the shores. West: Krendic giants, tough and gritty. North: Kelek`Vor giants, masters of the woods. [%s]",
						continue_link
					)
				)
				e.other:SetAccountBucket("pop.flags.askr", "2")
			elseif askr_bucket == 2 then
				e.self:Say("Prove your strength: slay one giant from each faction. Return a Srerendi beard, a Krendic bone, and a Kelek`Vor sash in this bag.")
				e.other:SummonItem(17192) -- Askr's Bag of Verity
			end
		elseif e.message:findi("It was me") then
			if askr_bucket == 1 then
				local paying_attention_link = eq.silent_say_link("I am paying attention", "paying attention")
				e.self:Say(
					string.format(
						"Impressive—you've slain a giant. Prove you're as skilled as you seem. Are you [%s]?",
						paying_attention_link
					)
				)
			end
		elseif e.message:findi("I am paying attention") then
			if askr_bucket == 1 then
				local continue_link = eq.silent_say_link("continue")
				e.self:Say(
					string.format(
						"Once, this land was serene under Karana's care. Then the storm giants invaded and split into factions around Mount Grenidor. [%s]",
						continue_link
					)
				)
			end
		elseif e.message:findi("Bastion of Thunder") then
			if askr_bucket == 3 then
				e.self:Say("The giants are fierce. Each tribe leader holds a piece to open the Bastion of Thunder. Seal two pieces in this bag, and I'll forge your medallion.")
				e.other:SummonItem(17192) -- Askr's Bag of Verity
			end
		end
	else
		e.self:Say("You must complete the Planes of Valor before I can help you.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	local valor_bucket = tonumber(e.other:GetAccountBucket("pop.flags.valor")) or 0
	if valor_bucket == 1 then
		local askr_bucket = tonumber(e.other:GetAccountBucket("pop.flags.askr")) or 0
		if askr_bucket == 0 then
			if (
				item_lib.check_turn_in(e.trade, {item1 = 11486}) or
				item_lib.check_turn_in(e.trade, {item1 = 28749}) or
				item_lib.check_turn_in(e.trade, {item1 = 28781}) or
				item_lib.check_turn_in(e.trade, {item1 = 28782})
			) then
				e.self:Say("Soberly, Askr eyes the giant's head. 'Did you really sever this storm giant's head?'")
				e.other:SetAccountBucket("pop.flags.askr", "1")
			end
		elseif askr_bucket == 2 then
			if item_lib.check_turn_in(e.trade, {item1 = 11487}) then
				local bastion_of_thunder_link = eq.silent_say_link("Bastion of Thunder")
				e.other:SetAccountBucket("pop.flags.askr", "3")
				e.self:Emote(string.format("examines the remains and then says, 'It's true—you can push back the giants. You're ready to explore the [%s] and finish what you've started.'", bastion_of_thunder_link))
			end
		elseif askr_bucket == 3 then
			if item_lib.check_turn_in(e.trade, {item1 = 11488}) then
				e.self:Emote("A mystical medallion appears and vanishes. Askr says, 'You've gathered the pieces! Now take the medallion to Mount Grenidor's heart and deliver the giants to their maker.'")
				e.other:SetAccountBucket("pop.flags.askr", "4")
				e.other:Message(MT.LightBlue, "You receive a character flag!")
			end
		end
	end

	item_lib.return_items(e.self, e.other, e.trade)
end
