function event_say(e)
	if e.message:findi("hail") then
		e.self:Emote("appears to be ignoring you completely.");
	elseif e.message:findi("audience with the overlord") then
		e.self:Say("The Overlord is not seeing anyone at this time. however. I may have work for you. You seem to have some experience with the kobold annoyance in the region. Are you [interested]. " .. e.other:GetName() .. "?");
	elseif e.message:findi("interested") then
		e.self:Say("Then I shall give you a [task]. I assume you are aware of the kobold lair nearby. Many of our adventurous knights and priests crusade to destroy those pests so seeing many Erudites frequent the area is normal. However. it is not normal to see someone carry large crates into the lair and return empty handed. This person's movements also show he is attempting to remain unseen.....the [fool].");
	elseif e.message:findi("fool") then
		e.self:Say("Whoever it is. obviously is not an Erudite. even though he appears to be. Only an outsider would take us to be such idiots as to fall for their pitiful attempt at disguise. Or perhaps....well. never mind that. I want you to enter the kobold lair and find these crates. Return one to me and we'll decide what to do from there.");
	elseif e.message:findi("task") then
		e.self:Say("According to the evidence we've uncovered, it appears the kobolds are nothing but pawns to harass us. Or perhaps even all of Odus. If they wish to play these games, then we'll humor them. We'll take their pawn with one of our knights. Will you be the [knight], " .. e.other:GetName() .. "?");
	elseif e.message:findi("knight") then
		e.self:Say("Then you will deliver this chest for us. Don't worry about what's inside it. Although we enjoy our solitude, we do make allies. We also make use of those allies. We will do so now. Take the chest to Lyris Moonbane below the human city of Qeynos. You will then follow her instructions and complete any tasks she assigns you. In return, she will send you back with what we wish. Fear is our armor.");
		if not e.other:HasItem(1792) then
			e.other:SummonItem(1792); -- Item: Heavy Locked Chest
		end
	end
end

function event_trade(e)
	local item_lib = require("items");
	if item_lib.check_turn_in(e.trade, {item1 = 1773}) then -- Item: Large Empty Crate
		e.self:Say("Hmmm. Very odd. The dust in the crate implies some sort of stone was transported in it. Perhaps our brothers of the Arcane will be able to find out where this dust came from and what it?s used for. Take this dust sample and note to Keletha Nightweaver. She will examine the dust and send you back with a report. Make haste.");
		e.other:SummonItem(1774); -- Item: Envelope with dust sample
        e.other:QuestReward(e.self,{exp = 1000});
	elseif item_lib.check_turn_in(e.trade, {item1 = 1775}) then -- Item: heretics report
		e.self:Emote("'s eyes redden with intense anger after reading the report. When he speaks, his voice is suprisingly calm and measured. He says, 'Listen close " .. e.other:Race() .. ". When you leave this building, you will find the courier who is bringing the ore. You will kill him, and collect his head and a box of the ore. You will then find the supplier, and collect his head and any other information you find on him. Bring me these four things and you will be rewarded. Do not fail.'");
		e.other:QuestReward(e.self,{exp = 1000});
	elseif item_lib.check_turn_in(e.trade, {item1 = 1776, item2 = 1777, item3 = 18174, item4 = 1778}) then -- Items: crate of ore, couriers head, suppliers head, sealed letter
		e.self:Say("'Honestly " .. e.other:GetName() .. ", I thought you would not return. Such strength and intelligence in a Knight of Fear I have not seen for quite some time. Wear this in pride of the ancient Ridossan. Perhaps when you are ready, i will give you a more [" .. eq.say_link("important task") .. "]. This conspiracy must be stopped.'");
		e.other:Faction(265,20);	-- Faction: Heretics
		e.other:Faction(242,-20);	-- Faction: Deepwater Knights
		e.other:Faction(254,-20);	-- Faction: Gate Callers
		e.other:Faction(231,-20);	-- Faction: Craftkeepers
		e.other:Faction(233,-20);	-- Faction: Crimson Hands
		e.other:SummonItem(1764);	-- Item: Leggings of Ridossan
        e.other:QuestReward(e.self,{exp = 2000});
	elseif item_lib.check_turn_in(e.trade, {item1 = 1892}) then -- Item: Empty Jar
		e.self:Say("Well done, " .. e.other:GetName() .. "! Now we need only wait for the kobolds to start dying off and our plan will be complete. Should only take 8 years or so. One such as yourself will wear this ancient armor well. The Tunic of the crusader Rodossan is now yours.  He shall watch over and praise you in your triumphs... your defeats on the other hand... well, never mind that.");
		e.other:Faction(265,40);	-- Faction: Heretics
		e.other:Faction(242,-40);	-- Faction: Deepwater Knights
		e.other:Faction(254,-40);	-- Faction: Gate Callers
		e.other:Faction(231,-40);	-- Faction: Craftkeepers
		e.other:Faction(233,-40);	-- Faction: Crimson Hands
		e.other:SummonItem(1765);	-- Item: Tunic of Ridossan
        e.other:QuestReward(e.self,{exp = 2000});
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
