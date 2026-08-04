-- Quests:
-- Greenmist 8
-- Cursed Wafers
-- Shaman Cudgel 1/2

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Greetings, and may the pain of the ancients guide you. You have come to us for guidance, have you not? We are the Hierophants of Cabilis and we guide the young Scale Mystics. All petitioners shall speak with me of [temple tasks]. I can also check the [progress] of tasks we have assigned you.");
	elseif e.other:GetFaction(e.self) <= 4 and e.other:HasClass(Class.SHAMAN) then
		if e.message:findi("temple tasks") then
			e.self:Say("The Temple of Terror requires all young Scaled Mystics to [perform daily tasks.]. The tasks are necessary to the upkeep of our order as well as that of our brothers, the Crusaders of Greenmist.");
		elseif e.message:findi("daily tasks") then
			e.self:Say("We require many components for various rituals. Take this Component mortar and fill it with the following items - foraged [mud crabs]. two small mosquito wings and one portion of bone chips. You must then use the pestle and combine all the components. When you have a full component mortar, you may return to me and I shall pay you your wages, but most importantly, you shall prove your devotion to the Scaled Mystics.");
			if not e.other:HasItem(17020) then
				e.other:SummonItem(17020); -- Item: Component Mortar
			end
		elseif e.message:findi("mud crabs") then
			e.self:Say("Mud crabs are tiny crustaceans which live along the mudcaked shores of the Lake of Ill Omen. You can forage for them and find a handful of them at a time.");
		elseif e.message:findi("lost skulls") then
			if e.other:GetLevel() >= 5 then
				e.self:Say("You must have heard of the Trilac Brotherhoods disappearance. They are the skulls of three soon to be ancients. They were taken from this temple by a silent intruder. Crusaders are always on duty. I do not know how they got into our vault. Every petitioner is ordered to search for the three skulls and return them to me along with their petitioner cudgel and then they shall become clairvoyants.");
			else
				e.self:Say("Come back when you are more experienced and you can assist us.");
			end
		elseif e.message:findi("iron cudgel") then
			if e.other:GetLevel() >= 5 then
				e.self:Emote("shakes his head and waves a finger in your face. If you are looking to be handed the Iron Cudgel of the Clairvoyant then you are sadly mistaken. Perhaps if you were to gather a few [lost skulls] for the temple we may find you worthy to wield one.'");
			else
				e.self:Say("Come back when you are more experienced and you can assist us.");
			end
		end

		if e.other:GetBucket("Shaman_Cudgel") == "1" then
			if e.other:GetLevel() >= 10 then
				if e.message:findi("larger problem") then
					e.self:Say("Many of the ancient skulls have been cast out of our temple. A hierophant was supposed to cast a special spell which was to protect the skulls from dust and decay. He cast some unknown spell which has sent many of our skulls to their original point of death. It would be most helpful if you would [assist in collecting the ancient skulls].");
				elseif e.message:findi("ancient skull") then
					e.self:Emote("seems unsure of your prowess. 'Hmmm. First you shall go after the two skulls of the Cleansers of the Outlands. If you find them, bring them back unbroken and then I shall trust you. Hand me both skulls and your iron cudgel of the clairvoyant and I will know you are prepared.'");
				end
			else
				e.self:Say("Come back when you are more experienced and you can assist us.");
			end
		end
	elseif e.other:HasClass(Class.SHAMAN) then
		if e.message:findi("iron cudgel") then
			e.self:Say("If you are looking to be handed the Iron Cudgel of the Clairvoyant then you are sadly mistaken. Perhaps if you were to gather a few [lost skulls] for the temple we may find you worthy to wield one.");
			end
	elseif e.message:findi("liquid") then
		e.self:Say("The bottle contains deklium in a liquid solution. The metal of prophecy has been determined to rest in a mass of living earth. Our scholars have written of a mass of ore that fell from the heavens. This ore was used in the creation of a blade of our father, Rile. We have been filled with visions of this blade. I have seen it in the hands of our Crusaders as they march towards the new age of Greenmist! Seek out the corrupted earth that guards the interlopers. We have an alchemist near there. He will be able to use the deklium to determine which golem contains the metal. Take care to go in force. I sense that there will be a battle.");
	end

	if e.other:HasClass(Class.SHAMAN) and e.message:findi("progress") then
		local Shaman_Cudgel_Progress = e.other:GetBucket("Shaman_Cudgel");

		e.other:Message(MT.Blue, "Shaman Cudgel/Skull Quest Status:");

		if Shaman_Cudgel_Progress == "8.2" then
			e.other:Message(MT.Yellow, "You are on the 8th Quest");
			e.other:Message(MT.Cyan, "You have been given the Iksar Remains and are ready for the final fight.");
		elseif Shaman_Cudgel_Progress == "8.1" then
			e.other:Message(MT.Yellow, "You are on the 8th Quest");
			e.other:Message(MT.Cyan, "You have turned in the Shrunken Iksar Skull Necklace to Oracle Vauris.");
		elseif Shaman_Cudgel_Progress == "7" then
			e.other:Message(MT.Yellow, "You are on the 8th Quest");
			e.other:Message(MT.Cyan, "You have recieved the SkyIron Cudgel of the Arisen and have just started the 8th Quest");
		elseif Shaman_Cudgel_Progress == "7.3" then
			e.other:Message(MT.Yellow, "You are on the 7th Quest");
			e.other:Message(MT.Cyan, "You have recieved the Ornate Skull Case and are ready to fill and turn in.");
		elseif Shaman_Cudgel_Progress == "7.2" then
			e.other:Message(MT.Yellow, "You are on the 7th Quest");
			e.other:Message(MT.Cyan, "You have recieved the Note to Granix.");
		elseif Shaman_Cudgel_Progress == "7.1" then
			e.other:Message(MT.Yellow, "You are on the 7th Quest");
			e.other:Message(MT.Cyan, "You have recieved the Dusty Iksar Skull back from Hierophant Granix");
		elseif Shaman_Cudgel_Progress == "6" then
			e.other:Message(MT.Yellow, "You are on the 7th Quest");
			e.other:Message(MT.Cyan, "You have recieved the Iron Cudgel of the Hierophant and have just started the 7th Quest");
		elseif Shaman_Cudgel_Progress == "6.1" then
			e.other:Message(MT.Yellow, "You are on the 6th Quest");
			e.other:Message(MT.Cyan, "You have turned in the Potion of Swirling Liquid to the Coerced Channeler");
		elseif Shaman_Cudgel_Progress == "5" then
			e.other:Message(MT.Yellow, "You are on the 6th Quest");
			e.other:Message(MT.Cyan, "You have recieved the Iron Cudgel of the Channeler and have just started the 6th Quest");
		elseif Shaman_Cudgel_Progress == "4" then
			e.other:Message(MT.Yellow, "You are on the 5th Quest");
			e.other:Message(MT.Cyan, "You have recieved the Iron Cudgel of the Prophet and have just started the 5th Quest");
		elseif Shaman_Cudgel_Progress == "3" then
			e.other:Message(MT.Yellow, "You are on the 4th Quest");
			e.other:Message(MT.Cyan, "You have recieved the Iron Cudgel of the Mystic and have just started the 4th Quest");
		elseif Shaman_Cudgel_Progress == "3.2" then
			e.other:Message(MT.Yellow, "You are on the 3rd Quest");
			e.other:Message(MT.Cyan, "You have turned in the The Bone Garrison and recieved the Skull Chest");
		elseif Shaman_Cudgel_Progress == "3.1" then
			e.other:Message(MT.Yellow, "You are on the 3rd Quest");
			e.other:Message(MT.Cyan, "You have turned in the A Froglok Hex Doll and recieved the The Bone Garrison");
		elseif Shaman_Cudgel_Progress == "2" then
			e.other:Message(MT.Yellow, "You are on the 3rd Quest");
			e.other:Message(MT.Cyan, "You have recieved the Iron Cudgel of the Seer and have just started the 3rd Quest");
		elseif Shaman_Cudgel_Progress == "1" then
			e.other:Message(MT.Yellow, "You are on the 2nd Quest");
			e.other:Message(MT.Cyan, "You have recieved the Iron Cudgel of the Clairvoyant and have just started the 2nd Quest");
		elseif Shaman_Cudgel_Progress == "" then
			e.other:Message(MT.Yellow, "You have not completed the Shaman Cudgel Quest #1");
		end
	end
end

function event_trade(e)
	local item_lib					= require("items");
	local antifuckery				= tonumber(e.other:GetBucket("antifuckery")) or 0;
	local Shaman_Cudgel_Progress	= e.other:GetBucket("Shaman_Cudgel")

	if e.other:GetFaction(e.self) <= 4 then
		if item_lib.check_turn_in(e.trade, {item1 = 3895}) then -- Item: Note to Oxyn
			e.self:Emote("takes the note and begins to howl into the air! 'The visions are true! The new prophecy begins today, Crusader,' the mystic growls with pleasure. He quickly turns and takes a bottle of murky liquid from one of his potion bags and hands it to you. 'Take this and keep it safe. Our visions have told of this day. We have been able to learn of the metal of prophecy. This [" .. eq.say_link("liquid") .. "] will help us to locate its true resting place!");
			e.other:Faction(442,20);	-- Faction: Crusaders of Greenmist
			e.other:Faction(441,10);	-- Faction: Legion of Cabilis
			e.other:SummonItem(3892);	-- Item: Bottle of Liquid Deklium
			e.other:QuestReward(e.self,{exp = 5000});
		elseif antifuckery == 0 and item_lib.check_turn_in(e.trade, {item1 = 3886}) then -- Item: Chunk of Tynnonium
			e.self:Emote("holds the ore in his hands and begins to chant. His eyes go white as he raises the chunk of ore above his head. He lowers his arms and shakes his head for a moment. His eyes return to their normal state as they focus on you. The shaman hands you the ore and says, 'Seek out the creator of Rile's blade. He is still on this plane. I have felt his torment. Take this note to Librarian Zimor. He learned a great deal from the tome and can instruct you further.'");
			e.other:Faction(442,20); -- Faction: Crusaders of Greenmist
			e.other:Faction(441,10); -- Faction: Legion of Cabilis
			e.other:QuestReward(e.self,{items = {3893,3886},exp = 5000}); -- Items: Note to Librarian, Chunk of Tynnonium
			e.other:SetBucket("antifuckery", "1"); -- Anti Fuckery Code
		elseif e.other:HasClass(Class.SHAMAN) then
			if item_lib.check_turn_in(e.trade, {item1 = 12403}) then -- Item: Full Component Mortar
				e.self:Say("We appreciate your service. Take a few copper for your deed as well as some of our cursed waters. They will provide you with nourishment. As for future tasks, we are searching for a few [lost skulls] and i am sure you are searching for your [iron cudgel of the clairvoyant] And i also hear that the furscales are in need of some broodlings to do some manual labor. Tell them Oxyn sent you.");
				e.other:Faction(445, 2);	-- Faction: Scaled Mystics
				e.other:Faction(441, 1);	-- Faction: Legion of Cabilis
				e.other:QuestReward(e.self,{items = {12406,12406},exp = 50}); -- Items: Cursed Wafers 2x
			elseif Shaman_Cudgel_Progress == "" and e.other:GetLevel() >= 5 and item_lib.check_turn_in(e.trade, {item1 = 12721, item2 = 12722, item3 = 12723, item4 = 5140}) then -- Items: Morgl Skull, Logrin Skull, Waz Skull, Iron Cudgel of the Petitioner
				e.self:Say("Excellent! You have proved yourself worthy to wield the iron cudgel of the clairvoyant. As a clairvoyant I feel I can trust you, so I will tell you that the issue of the missing skulls is a [much larger problem] than last stated.");
				e.other:SetBucket("Shaman_Cudgel", "1");	-- Flag: Completed Cudgel Quest 1
				e.other:Message(MT.Yellow, "You have received a quest flag.");
				e.other:Faction(445, 10);					-- Faction: Scaled Mystics
				e.other:Faction(441, 5);					-- Faction: Legion of Cabilis
				e.other:SummonItem(5141);					-- Item: Iron Cudgel of the Clairvoyant
				e.other:QuestReward(e.self,{exp = 2000});
			elseif Shaman_Cudgel_Progress == "1" and e.other:GetLevel() >= 10 and item_lib.check_turn_in(e.trade, {item1 = 12724, item2 = 12725, item3 = 5141}) then -- Items: Skull with I, Skull with II, Iron Cudgel of the Clairvoyant
				e.self:Say("We are in your debt," .. e.other:GetCleanName() .. " . You are truly one who shall collect all the lost ancient skulls. Take your weapon. Go to Hierophant Zand and he shall guide you further. Tell him you are [the chosen saviour].");
				e.other:SetBucket("Shaman_Cudgel", "2");	-- Flag: Completed Cudgel Quest 2
				e.other:Message(MT.Yellow, "You have received a quest flag.");
				e.other:Faction(445, 10);					-- Faction: Scaled Mystics
				e.other:Faction(441, 5); 					-- Faction: Legion of Cabilis
				e.other:SummonItem(5142);					-- Item: Iron Cudgel of the Seer
				e.other:QuestReward(e.self,{exp = 60000, copper = math.random(9), silver = math.random(9), gold = math.random(9), platinum = math.random(1)});
			end
		end
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
