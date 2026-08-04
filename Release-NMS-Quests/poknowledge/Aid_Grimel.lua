function event_say(e)
	if e.message:findi("Hail") then
		local willing_to_help_link = eq.silent_say_link("willing to help")
		e.self:Say(
			string.format(
				"Greetings and Salutations %s! I am Grimel, aid to the mighty paladin Councilman Taldarius. In between his duties to the city, Taldarius and I spend most of our time in the Planes cleansing evil. Even now I am preparing for battle. Taldarius intends to go further into the Planes than ever before on our next trip and I am working on gathering the special supplies we need. If you are [%s] I may have some use for your skills if you are a master of trades and have traveled in the Planes.",
				e.other:GetCleanName(),
				willing_to_help_link
			)
		)
	else
		local aid_grimel_flag = tonumber(e.other:GetAccountBucket("pop.flags.aidgrimel")) or 0
		local codecay_bucket = tonumber(e.other:GetAccountBucket("pop.flags.codecay")) or 0
		if codecay_bucket == 2 then
			if e.message:findi("willing to help") then
				if aid_grimel_flag == 0 then
					local versed_in_the_art_of_smithing_link = eq.silent_say_link("versed in the art of smithing")
					e.self:Say(
					string.format(
						"Excellent! I am looking for a smith to add a special imbue to Councilman Taldarius's armor. Are you well [%s]?",
						versed_in_the_art_of_smithing_link
						)
					)
				elseif aid_grimel_flag == 1 then
					local brewing_skill_link = eq.silent_say_link("brewing skill")
					e.self:Say(
						string.format(
							"If you are not too busy I have another task, do you have any [%s]?",
							brewing_skill_link
						)
					)
				elseif aid_grimel_flag == 2 then
					local put_my_jewel_craft_skills_to_the_test_link = eq.silent_say_link("put my jewel craft skills to the test", "put your jewel craft spells to the test")
					e.self:Emote(
						string.format(
							"I see you are quite deft of hand, perhaps you would care to [%s]?'",
							put_my_jewel_craft_skills_to_the_test_link
						)
					)
				elseif aid_grimel_flag == 3 then
							local ready_to_use_some_clay_link = eq.silent_say_link("ready to use some clay")
					e.self:Emote(
						string.format(
							"grins. 'Quite a nice ring you made for me %s. We seem to be finishing the tasks on my list at a nice pace. Tell me when you are [%s].",
							e.other:GetCleanName(),
							ready_to_use_some_clay_link
						)
					)
				elseif aid_grimel_flag == 4 then
					local skilled_with_the_needle_link = eq.silent_say_link("am skilled with the needle", "skilled with the needle")
					e.self:Say(
						string.format(
							"Outstanding work %s!  Are ye [%s] as well as an accomplished potter?",
							e.other:GetCleanName(),
							skilled_with_the_needle_link
						)
					)
				elseif aid_grimel_flag == 5 then
					local skills_with_a_fletching_knife_link = eq.silent_say_link("skills with a fletching knife")
					e.self:Say(
						string.format(
							"Good work %s. If you have [%s] I may have a job for you to do.",
							e.other:GetCleanName(),
							skills_with_a_fletching_knife_link
						)
					)
				elseif aid_grimel_flag == 6 then
					local master_chef_link = eq.silent_say_link("master chef")
					e.self:Say(
						string.format(
							"Masterful work %s! The last item I need before we can be off is some food. I warn you this will truly test your skills. Do you fancy yourself a [%s]?",
							e.other:GetCleanName(),
							master_chef_link
						)
					)
				end
			elseif e.message:findi("versed in the art of smithing") and aid_grimel_flag == 0 then
				if e.other:GetRawSkill(63) >= 220 then -- Skill: Blacksmithing
					e.self:Say(
						string.format(
							"Thank you for offering to help %s. Take this breastplate and clean it with a diluted acid wash to get all of the debris out of it. Brew the wash by combining acid and three celestial essences. Once the armor is cleaned, coat it with hurricane temper. Finally add two black diamonds of nightmare to the breastplate. This should provide adequate protection for our next journey.",
							e.other:GetCleanName()
						)
					)
					e.other:SummonItem(15984) -- Item: Filthy Breastplate
				else
					e.self:Say("You do not seem to be skilled enough.")
				end
			elseif e.message:findi("brewing skill") and aid_grimel_flag == 1 then
				if e.other:GetRawSkill(65) >= 220 then -- Skill: Brewing
					e.self:Say("I bet you could make a wicked brew! However I am forced to drink a refreshing drink while out adventuring. I do have this powder that will give the best drinks quite a bite though. Mix the powder in with two Kaladim Constitutionals and a flask of pure water. If you need more dust just ask for it! Put three twice brewed constitutionals and the signet in this drink barrel. As hard as drink barrels are to get these days, you need to return it to me along with the drink you create with it.")
					e.other:SummonItem(17179) -- Item: Portable Drink Barrel
					e.other:SummonItem(15992) -- Item: Fermenting Dust
					e.other:SummonItem(15992) -- Item: Fermenting Dust
					e.other:SummonItem(15992) -- Item: Fermenting Dust
				else
					e.self:Say("You do not seem to be skilled enough.")
				end
			elseif e.message:findi("put my jewel craft skills to the test") and aid_grimel_flag == 2 then
				if e.other:GetRawSkill(68) >= 220 then -- Skill: Jewelry Making
					e.self:Say("My hand was crushed when I used it to deflect a blow from a War Boar that was headed towards Taldarius's back. For some time afterwards my hand was crippled but Brell saw to it I regained full use of it. The ring I used to wear was damaged beyond repair and my hand was never steady enough to etch a new one. If you would make me a new one by combining a mounted blue diamond, the etching dust and etching tools in a jewelry kit. Then take the faceted gem and combine it with a bar of pure enchanted velium and my signet. I have no idea how the pure bars are made. You may want to seek the help of the ice dwarves.")
					e.other:SummonItem(15988) -- Item: Etching Dust
				else
					e.self:Say("You do not seem to be skilled enough.")
				end
			elseif e.message:findi("ready to use some clay") and aid_grimel_flag == 3 then
				if e.other:GetRawSkill(69) >= 220 then -- Skill: Pottery
					e.self:Say("On our last tome gathering expedition a stray arrow in the Plane of War struck our urn filled with sacred water. It was quite a waste of sacred water! Three large enchanted blocks of clay, three lacquered opals, a vial of purified mana, a ceramic lining, sculpting tools and the urn pattern should make an unfired urn. The urn is so large you will need to fire it with three divine crystalline glazes. Once you have the urn it needs to be filled with three sacred waters and the signet as a cap.")
					e.other:SummonItem(16243) -- Item: Urn Patten
				else
					e.self:Say("You do not seem to be skilled enough.")
				end
			elseif e.message:findi("am skilled with the needle") and aid_grimel_flag == 4 then
				if e.other:GetRawSkill(61) >= 220 then -- Skill: Tailoring
					e.self:Say(
						string.format(
							"I appreciate the help %s. I need a new tunic made for Councilman Taldarius. Last trip through the Plane of Disease, one of those flies spit mucus on him and it dripped through his armor seams! The result was a gooey mess that ate away all the leather underneath. It was a blessing he was wearing something under all that metal! Combine three firesilk swatches, a vial of purified mana, an emblem of fire, a firestrand curing agent, a tunic pattern and the signet. Bring it to me when you have completed it.",
							e.other:GetCleanName()
						)
					)
				else
					e.self:Say("You do not seem to be skilled enough.")
				end
			elseif e.message:findi("skills with a fletching knife") and aid_grimel_flag == 5 then
				if e.other:GetRawSkill(64) >= 220 then -- Skill: Fletching
					e.self:Say(
						string.format(
							"Aye I can see you are skilled with the fletching knife %s. It is good too, I need to replace Councilman Taldarius's bow from Plane of Air. Combine a planing tool, two wind metal bow cams, an air arachnid silk string, a featherwood staff and the signet. I hope the bow will be up to his standards, he sure loved his old bow.",
							e.other:GetCleanName()
						)
					)
				else
					e.self:Say("You do not seem to be skilled enough.")
				end
			elseif e.message:findi("master chef")  and aid_grimel_flag == 6 then
				if e.other:GetRawSkill(60) >= 220 then -- Skill: Baking
					e.self:Say("When we adventure in the Planes there is only one meal that keeps us in top fighting shape. It is called a Bristlebane's Party Platter. Unfortunately the platter is awkward and not easy to adventure with so you need to place them in this satchel. I know not how to make the Platter, a rather nice female Halfling cleric always used to deliver them to us but I heard she was crushed by a Regrua while hunting for a rare component in the Plane of Water. Brell bless her soul! Combine three of the platters and the signet inside the satchel.")
					e.other:SummonItem(17180) -- Item: Field Satchel
				else
					e.self:Say("You do not seem to be skilled enough.")
				end
--			elseif e.message:findi("lose") then
--				local versed_in_the_art_of_smithing_link = eq.silent_say_link("versed in the art of smithing")
--				e.self:Say(
--					string.format(
--						"Aye then, let's start over. Are you well [%s]?",
--						versed_in_the_art_of_smithing_link
--					)
--				)
--				e.other:SetAccountBucket("pop.flags.aidgrimel", "0")
			else
				local willing_to_help_link = eq.silent_say_link("willing to help")
				e.self:Say(
					string.format(
						"Greetings and Salutations %s! I am Grimel, aid to the mighty paladin Councilman Taldarius. In between his duties to the city, Taldarius and I spend most of our time in the Planes cleansing evil. Even now I am preparing for battle. Taldarius intends to go further into the Planes than ever before on our next trip and I am working on gathering the special supplies we need. If you are [%s] I may have some use for your skills if you are a master of trades and have traveled in the Planes.",
						e.other:GetCleanName(),
						willing_to_help_link
					)
				)
--				e.self:Say("Ye still don't have the component made. Did you [lose] it?")
			end
		else
			e.self:Say("You do not seem experienced enough in the Planes.")
		end
	end
end

function event_trade(e)
	local item_lib = require("items")
	local aid_grimel_flag = tonumber(e.other:GetAccountBucket("pop.flags.aidgrimel")) or 0
	if aid_grimel_flag == 0 and item_lib.check_turn_in(e.trade, {item1 = 15985}) then -- Item: Imbued Breastplate
		local brewing_skill_link = eq.silent_say_link("brewing skill")
		e.self:Say(
			string.format(
				"What a wonderful job! Councilman Taldarius shall wear this on our next adventure, I am sure he will find it more protective than his old one. Take this signet as a token of my gratitude. If you are not too busy I have another task, do you have any [%s]?",
				brewing_skill_link
			)
		)
		e.other:SetAccountBucket("pop.flags.aidgrimel", "1")
		e.other:SummonItem(16249) -- Item: Hardened Leather Signet.
	elseif aid_grimel_flag == 1 and item_lib.check_turn_in(e.trade, {item1 = 15993, item2 = 17179}) then -- Item: Portable Drink, Portable Drink Barrel
		local put_my_jewel_craft_skills_to_the_test_link = eq.silent_say_link("put my jewel craft skills to the test", "put your jewel craft spells to the test")
		e.self:Emote(
			string.format(
				"gulps down a Twice Brewed Constitutional and burps loudly! 'Ahhhh that was refreshing! That should hold me over for quite some time. I see you are quite deft of hand, perhaps you would care to [%s]?'",
				put_my_jewel_craft_skills_to_the_test_link
			)
		)
		e.other:SetAccountBucket("pop.flags.aidgrimel", "2")
		e.other:SummonItem(16250) -- Item: Clay Signet
	elseif aid_grimel_flag == 2 and item_lib.check_turn_in(e.trade, {item1 = 15991}) then -- Item: Velium Blue Diamond Ring
		local ready_to_use_some_clay_link = eq.silent_say_link("ready to use some clay")
		e.self:Emote(
			string.format(
				"grins. 'Quite a nice ring you have made for me %s. May it serve me as well as my old ring. Here take this signet. We seem to be finishing the tasks on my list at a nice pace. Tell me when you are [%s].",
				e.other:GetCleanName(),
				ready_to_use_some_clay_link
			)
		)
		e.other:SummonItem(16251) -- Item: Wooden Signet
		e.other:SetAccountBucket("pop.flags.aidgrimel", "3")
	elseif aid_grimel_flag == 3 and item_lib.check_turn_in(e.trade, {item1 = 16246}) then -- Item: Filled Sacred Urn
		local skilled_with_the_needle_link = eq.silent_say_link("am skilled with the needle", "skilled with the needle")
		e.self:Say(
			string.format(
				"Outstanding work %s! I can feel the purity of the water radiating through the clay. Are ye [%s] as well as an accomplished potter?",
				e.other:GetCleanName(),
				skilled_with_the_needle_link
			)
		)
		e.other:SummonItem(16252) -- Item: Metal Signet
		e.other:SetAccountBucket("pop.flags.aidgrimel", "4")
	elseif aid_grimel_flag == 4 and item_lib.check_turn_in(e.trade, {item1 = 15986}) then -- Item: Fire Undergarment Tunic
		local skills_with_a_fletching_knife_link = eq.silent_say_link("skills with a fletching knife")
		e.self:Say(
			string.format(
				"Good work %s. This will definitely serve Councilman Taldarius well. Here take this! If you have [%s] I may have a job for you to do.",
				e.other:GetCleanName(),
				skills_with_a_fletching_knife_link
			)
		)
		e.other:SummonItem(32800) -- Item: Marked Signet
		e.other:SetAccountBucket("pop.flags.aidgrimel", "5")
	elseif aid_grimel_flag == 5 and item_lib.check_turn_in(e.trade, {item1 = 16247}) then -- Item: Signet Featherwood Bow
		local master_chef_link = eq.silent_say_link("master chef")
		e.self:Say(
			string.format(
				"Masterful work %s! I can see your skill in the curves of the bow. Take this as a sign of my respect for your skill. The last item I need before we can be off is some food. I warn you this will truly test your skills. Do you fancy yourself a [%s]?",
				e.other:GetCleanName(),
				master_chef_link
			)
		)
		e.other:SummonItem(16254) -- Item: Runed Signet
		e.other:SetAccountBucket("pop.flags.aidgrimel", "6")
	elseif aid_grimel_flag == 6 and item_lib.check_turn_in(e.trade, {item1 = 16248}) then -- Item: Food Satchel
		e.self:Say("Truly amazing! Now the Councilman and I can be off on our expedition to the Elemental Planes!' He takes out a tool and marks his signet before handing it to you, 'Before we depart you may want to ask the Councilman about the signet.")
		e.other:SummonItem(16256) -- Item: Marked Runed Signet
		e.other:SetAccountBucket("pop.flags.aidgrimel", "0")
	end

	item_lib.return_items(e.self, e.other, e.trade)
end
