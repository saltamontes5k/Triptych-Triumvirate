-- Beastlord 1.5
function event_say(e)
	if e.other:HasClass(Class.BEASTLORD) then -- Beastlords Only
		local data_bucket = ("Epic-Beastlord-"..e.other:CharacterID());

		if eq.get_data(data_bucket) ~= "" then -- Has Started
			local temp = eq.get_data(data_bucket);
			s = eq.split(temp, ',');

			local epic_pre_onefive	= tonumber(s[1]);
			local epic_onefive		= tonumber(s[2]);		
			local epic_two			= tonumber(s[3]);
			local epic_twofive		= tonumber(s[4]);

			if(epic_two == 1 and e.message:findi("hail")) then
				e.other:Message(MT.NPCQuestSay, "Rashara Wrualla says 'I'm so glad you are here. There is a gnoll here seeking to steal my very essence! How did I come upon such bad luck? I believe this gnoll heard about the theft of my warder's esseence, and now it wants mine. You must find it and spill its blood and take it to Muada forthwith!'");
				eq.unique_spawn(181007,0,0,800,3400,83,300);	-- NPC: #Dismal_Darkpaw_Mystic
			elseif(epic_onefive == 29 and e.message:findi("hail")) then
				e.other:Message(MT.NPCQuestSay, "Rashara Wrualla says 'Aye, I do remember that face, Beastlord. I am still recovering from my short trip to Kuua that suffers from the touch of the Realm of Discord. What a dark and foul place it is. Some of the creatures have hearts so dark it is nearly inconceivable. One of those creatures has robbed me of what I hold [most dear].'");
			elseif(epic_onefive == 9 and e.message:findi("wait")) then
				e.other:Message(MT.NPCQuestSay, "Rashara Wrualla says 'I have no time to study now. I must leave and prepare to assist Muada. I would guess you have a role in all of this too. Goodbye, young one.'");
				e.other:SummonItem(57008); -- Item: Letter from Muada
				update_databucket(e,epic_pre_onefive,10,epic_two,epic_twofive);
			elseif(epic_onefive == 29 and e.message:findi("most dear")) then
				e.other:Message(MT.NPCQuestSay, "Rashara Wrualla says 'There is a beast called a girplan, and while it does draw blood, it digs its fangs much deeper. I was traveling with my warder and encountered a girplan that was different somehow. It attacked me and my faithful warder ran to my aid. I did come upon some [luck], though.'");
			elseif(epic_onefive == 29 and e.message:findi("luck")) then
				e.other:Message(MT.NPCQuestSay, "Rashara Wrualla says 'I was able to get some distance when it landed a fatal blow to my companion. But, not only did it draw its blood afterward, it drew its essence, and now I am unable to summon my companion to my aid. I do not understand how it happened and I would have thought it [not possible].'");
			elseif(epic_onefive == 29 and e.message:findi("not possible")) then
				e.other:Message(MT.NPCQuestSay, "Rashara Wrualla says 'It would mean a great deal to me and the elders if you could seek out this girplan in that eerie scarred land and, perhaps, discover what it did to my warder. I am unable to go myself as I could never dream of traveling without my warder. You will find a beastlord in Discord who also seeks the same creature. Give him this note.'");
				e.other:SummonItem(52906); -- Item: Request of the Elders
				update_databucket(e,epic_pre_onefive,30,epic_two,epic_twofive);
			elseif(e.message:findi("hail")) then
				e.other:Message(MT.NPCQuestSay, "Rashara Wrualla says 'Hm? What is it? I'm rather busy.'");	
			end
		else
			e.other:Message(MT.NPCQuestSay, "Rashara Wrualla says 'Hm? What is it? I'm rather busy.'");
		end
	else
		e.other:Message(MT.NPCQuestSay, "Rashara Wrualla says 'Hm? What is it? I'm rather busy.'");
	end
end

function update_databucket(e,pre_one_five,one_five,two,two_five)
	eq.set_data("Epic-Beastlord-"..e.other:CharacterID(), pre_one_five..","..one_five..","..two..","..two_five);
	e.other:Message(MT.Yellow, "Your quest has been advanced"); -- Made up to let people know the flags have been updated.
end

function event_trade(e)
	local item_lib = require("items")
	local data_bucket = ("Epic-Beastlord-"..e.other:CharacterID());

	if eq.get_data(data_bucket) ~= "" then -- Has Started
		local temp = eq.get_data(data_bucket);
		s = eq.split(temp, ',');

		local epic_pre_onefive	= tonumber(s[1]);
		local epic_onefive		= tonumber(s[2]);		
		local epic_two			= tonumber(s[3]);
		local epic_twofive		= tonumber(s[4]);

		if epic_onefive == 8 and item_lib.check_turn_in(e.trade, {item1 = 57008}) then -- Item: Letter from Muada
			e.other:Message(MT.NPCQuestSay, "Rashara Wrualla says 'Terrible. Just terrible. I had a feeling something was wrong. You may return this to him--I have signed it. Interesting place here, isn't it? Those potameids do cause some trouble. I find them very hard to study as they are quite feisty. I specialize in the advancement and power of warders and the spirits of the wild I command are very dear and special. Many of them are of an ilk you have never seen and they are much sought after. All that will have to [wait]. I must go.'");
			update_databucket(e,epic_pre_onefive,9,epic_two,epic_twofive);
		elseif epic_onefive == 33 and item_lib.check_turn_in(e.trade, {item1 = 52907,item2 = 52908}) then -- Item: Rashara's Warder's Essence and Sealed Response to the Elders
			e.other:Message(MT.NPCQuestSay, "Rashara Wrualla says 'I am speechless. You have done what I thought was impossible. You've restored my place as a beastlord and an elder. I am forever in your debt. Return to Muada and tell him I sent you so you may hear the most-troubling news . . . it seems we know more about a true enemy of beastlords in Discord. I can say no more.'");
			update_databucket(e,epic_pre_onefive,34,epic_two,epic_twofive);
		end
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
