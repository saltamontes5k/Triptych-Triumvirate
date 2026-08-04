--poknowledge/librarian_Maelin.lua NPCID 202125
-- items: 84091, 84092, 84093, 84087, 52950, 55900, 20520
function event_say(e)
	local qglobals = eq.get_qglobals(e.other);
	if eq.is_task_active(500220) then
		if e.message:findi("trick or treat") then
			e.self:Say("Ah, here you go. Fresh from the Sugar Assembalage 2000.");
			e.other:SummonItem(eq.ChooseRandom(84091 ,84092, 84093, 84087, 84087, 84087, 84087, 84087, 84087));
			-- Item(s):
			-- Sand (84091)
			-- Chunk of Coal (84092)
			-- Pocket Lint (84093)
			-- Jawbreaker (84087) x 6
			eq.update_task_activity(500220, 1, 1);
		end
	end

	if e.other:HasItem(29165) then --Quintessence of Elements
		if e.message:findi("Hail") then
			e.self:Say("The Quintessence! Oh my this is amazing! I have come into contact with Chronographer Muon in the realm of innovation. Go to him, show him you have the power to activate machine. I shall meet you there, this I must see!");
		end
	else
		local flags = {
			["pop.flags.aerin"] = 1,
			["pop.flags.adler"] = 1,
			["pop.flags.agnarr"] = 1,
			["pop.flags.askr"] = 4,
			["pop.flags.bertox"] = 1,
			["pop.flags.codecay"] = 2,
			["pop.flags.construct"] = 1,
			["pop.flags.elder"] = 1,
			["pop.flags.faye"] = 1,
			["pop.flags.garn"] = 1,
			["pop.flags.grummus"] = 1,
			["pop.flags.hedge"] = 1,
			["pop.flags.marr"] = 1,
			["pop.flags.mavuin"] = 1,
			["pop.flags.poxbourne"] = 1,
			["pop.flags.saryrn"] = 2,
			["pop.flags.shadyglade"] = 1,
			["pop.flags.terris"] = 1,
			["pop.flags.tribunal"] = 1,
			["pop.flags.trell"] = 1,
			["pop.flags.valor"] = 1,
			["pop.flags.rallos"] = 1
		}

		local flags_missing = {}
		
		local all_requirements_met = true
		for flag, required_value in pairs(flags) do
			local current_bucket = tonumber(e.other:GetAccountBucket(flag)) or 0
			if current_bucket ~= required_value then
				flags_missing[flag] = {current_bucket, required_value}
				all_requirements_met = false
			end
		end
		if all_requirements_met then --Elemental Pre-Flagging
			if e.message:findi("hail") then
				local lore_link = eq.silent_say_link("lore")
				local information_link = eq.silent_say_link("information")
				e.self:Say(
					string.format(
						"Welcome back my friends. I assure you that I have been studying the Cipher of Druzzil very diligently. Did you happen to find any [%s] or [%s] that I could look at?",
						lore_link,
						information_link
					)
				);
			elseif e.message:findi("lore") then
				e.self:Say("A parchment of Rallos'? Let me read it, it says that Rallos was not alone in his feelings about mortals. Solusek Ro also holds stake in the war to be led on Norrath. Not only this but he is channeling power from his father's plane into his own. He is taking that power and intensifying it through an artifact of great power, and then focusing it onto one point. It is a detailed as a crystal that burns with all the powers of the plane of fire. It is said to have the ability to turn the face of Norrath into a charred wasteland. They plan for a manaetic behemoth to carry and deposit it upon Norrath. You must stop these plans, you must stop Solusek!");
			elseif e.message:findi("information") then
				e.self:Say("There is no way to escape from the prison that is The Plane of Time. I am sorry but your quest for information ends here. Time is something that none of us can escape. That is however.. back when my explorations of the Planes were more common, I would travel searching for knowledge and lore to bring back to Tanaan. I stumbled into the Plane of Innovation. It was a great marvel to see indeed. I found the creator of all things mechanical. Meldrath the Marvelous was a kind and just gnome. We spent many weeks together discussing all of his devices. This included a machine that would allow you to open a tear into a period of time and enter into that time. The machine was more of a flight of whimsy though as the power necessary to power such a machine was enormous. He jokingly equated needing the very essence of the elements to power it.");
				e.self:Emote("Maelin takes a deep breath and continues");
				e.self:Say("I can see now that he was not joking at all. Let us suppose that you travelers could venture into the Elemental Planes and retrieve this essence; and form it into one powerful conglomeration. You could open a tear into the period of time before Zebuxoruk was imprisoned. There is no way you can free him from his stasis now, but if you were to halt the Pantheon at the time of imprisonment. Hah! It could work I do believe. Forgive me, but my old gnomish heart is alive with the excitement of possibilities. Gather up your strength friends, travel into the deep elements. You will need all of your wits about you. Find the very essence of the elementals, and fuse them into one. How to combine them I do not know, and can only wish you luck on finding that information. If you can accomplish this please come get me. I would like to record the events as they take place!");
				e.other:SetAccountBucket("pop.flags.librarian", "1");
				e.other:Message(MT.LightBlue, "You receive a character flag!");
			end
		else
			e.self:Say("You lack the necessary requirements for me to speak with you.")
			e.other:Message(MT.Yellow, "Your missing flags are as follows:")
			for flag, _ in pairs(flags_missing) do
				local flag_name = string.gsub(flag, "pop.flags.", "")
				local current_value = flags_missing[flag][1]
				local required_value = flags_missing[flag][2]
				e.other:Message(
					MT.Yellow,
					string.format(
						"Flag: %s Current: %d Required: %d",
						flag_name,
						current_value,
						required_value
					)
				)
			end
		end
	end

	if e.message:findi("tome") then
		if qglobals["shadowknight_epic"] == "1" then
			e.self:Say("Yes, I seem to recall having such a tome. But evil it is. I don't hand out such dangerous knowledge to just anyone. However. . . I am curious about something and perhaps you can help me. A prominent professor of biology and I have a bet as to how a certain creature from the Realm of Discord, known as a murkglider breeds. He believes they give live birth, and I believe they are egg layers. Unfortunately, I have been so busy here, that I have not been able to make arrangements to travel there and observe the creatures more. If you could travel to the Realm of Discord and [" ..eq.say_link('find an egg', false, 'find an egg') .. "] for me, I will give you the book you seek.");
		elseif e.message:findi("find an egg") then
			e.self:Say("I appreciate your help with this! The creature I was supposed to study are most commonly known as murkgliders. The easiest way to describe them is that they look like large, floating octopuses. See if you can hunt down any breeding murkgliders and return an egg to me that I can study. You might want to bring some companions along, as this might be a dangerous task.");
		end
	elseif e.message:findi("Jeb Lumsed sent me") then
		if (qglobals["ench_epic"] == "2") then
			e.self:Say("This is from Jeb, you say? I will set my best researchers on it at once. We have recently made some discoveries that he should be aware of. Here, take this note down to Lobaen, she will retrieve them for you.");
			e.other:SummonItem(52950); --Note to Lobaen
		end
	end
end

function event_trade(e)
	local qglobals = eq.get_qglobals(e.other);
	local item_lib = require("items");
	if qglobals["shadowknight_epic"] == "1" and item_lib.check_turn_in(e.trade, {item1 = 55900}) then --hand in Gelatinous Murkglider Egg (Drops from Murkglider Breeder in Ruined City of Dranik)
		e.self:Say("I knew they were egg-layers! Ha, this is one gnome who hates losing a bet and thanks to you I wont! This is the tome you seek. Please bring it back to me when you are done.");
		e.other:SummonItem(20520); --The Silent Gods
	end
	item_lib.return_items(e.self, e.other, e.trade);
end