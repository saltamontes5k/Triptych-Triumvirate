function event_spawn(e)
	local xloc = e.self:GetX();
	local yloc = e.self:GetY();
	eq.set_proximity(xloc - 50, xloc + 50, yloc - 50, yloc + 50);
end

function event_enter(e)
	if e.other:HasItem(18019) then -- Item: Harbingers of Fear Guild Note
		e.other:Message(MT.Yellow,"Sern Adolia glances at you with obvious scorn. 'Are you here to learn the ways of Cazic-Thule? If that is the case, then read the note in your inventory and then hand it to me. If you are not here for such a purpose, I suggest you leave at once lest you anger me further.'");
	end
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("I hope you have a good reason for disturbing my contemplations. Perhaps you [" .. eq.say_link("I seek knowledge",false,"seek the knowledge") .. "] of those who meditate within this Temple of Fear?");
	elseif e.message:findi("I seek knowledge") then
		e.self:Say("It is the secrets of Fear you seek, but first you must prove your devotion to our temple. There are pack rats within the city that have a habit of getting into things. Some of these rats have ingested a concoction developed by the necromancers of this great city. The rats have since died and, due to the concoction, their undead corpses now roam the fields. Bring me four livers from these undead rats so that we may examine them.");
	elseif e.message:findi("duties") then
		e.self:Say("The primary duty of this temple is to spread terror, fright, and dread as a symbol of your devotion to our lord Cazic Thule. We are currently researching a means of summoning avatars of Fright, Terror and Dread, the primary minions of the Faceless in his home plane. Will you [assist me in summoning] the avatar of Fright?");
	elseif e.message:findi("assist") then
		e.self:Say("In order to summon the avatar of Fright. I require some special components for the ritual. Fetch me the flesh of a zombie. the dust used in the process of mummification. [charred bone chips]. and a [vial of Tunare's Breath].");
	elseif e.message:findi("chips") then
		e.self:Say("Some time ago a necromancer by the name of Obretl was sent to slay Rathmana Allin and his abomination of an adopted son. Ortallius. Obretl failed in his task and now haunts a small ruin in the desert of Ro cursed by Solusek to wallow in his failure in the form of a burning skeleton. Slay Obretl to free him from his pathetic existence and gather his charred remains.");
	elseif e.message:findi("vial") then
		e.self:Say("Tunare's Breath is a life-giving potion created by the Fier'Dal Soldiers of Tunare. Seek out the druid Kalayia who is known to wander the Faydarks in search of reagents for potions. Procure from her a vial of Tunare's Breath. Shed her blood if need be.");
	elseif e.message:findi("trades") then
		e.self:Say("I thought you might be one who was interested in the various different trades, but which one would suit you? Ahh, alas, it would be better to let you decide for yourself, perhaps you would even like to master them all! That would be quite a feat. Well, lets not get ahead of ourselves, here, take this book. When you have finished reading it, ask me for the [second book], and I shall give it to you. Inside them you will find the most basic recipes for each trade. These recipes are typically used as a base for more advanced crafting, for instance, if you wished to be a smith, one would need to find some ore and smelt it into something usable. Good luck!");
		if e.other:HasItem(51121) then
			e.other:SummonItem(51121); -- Item: Tradeskill Basics : Volume I
		end
	elseif e.message:findi("second book") then
		e.self:Say("Here is the second volume of the book you requested, may it serve you well!")
		if e.other:HasItem(51122) then
			e.other:SummonItem(51122); -- Item: Tradeskill Basics : Volume II
		end
	end
end

function event_trade(e)
	local item_lib = require("items");
	if item_lib.check_turn_in(e.trade, {item1 = 18019}) then -- Item: Harbingers of Fear Guild Note
		e.self:Say("You are welcomed into the fold. Now go out. and prove yourself. young one. You have much to learn about the Dark Truth. Once you are ready to begin your training please make sure that you see Sadorno Chomosh, he can assist you in developing your hunting and gathering skills. Return to me when you have become more experienced in our art, I will be able to further instruct you on how to progress through your early ranks, as well as in some of the various [trades] you will have available to you.");
		e.other:Faction(265,100);	-- Faction: Heretics
		e.other:Faction(254,-100);	-- Faction: Gate Callers
		e.other:Faction(242,-100);	-- Faction: Deepwater Knights
		e.other:Faction(231,-100);	-- Faction: Craftkeepers
		e.other:Faction(233,-100);	-- Faction: Crimson Hands
		e.other:SummonItem(13573);	-- Item: Blood Splattered Tunic
		e.other:QuestReward(e.self,{exp = 100});
	elseif item_lib.check_turn_in(e.trade, {item1 = 13270, item2 = 13270, item3 = 13270, item4 = 13270}) then -- Items: 4x Infected Rat Livers
		e.self:Say("Well done, go now and continue your contemplations of fear. Keep up with your [" .. eq.say_link("duties") .. "] and you will soon be reaping the rewards granted by our Lord Cazic-Thule!!");
		e.other:Faction(265,10);	-- Faction: Heretics
		e.other:Faction(254,-10);	-- Faction: Gate Callers
		e.other:Faction(242,-10);	-- Faction: Deepwater Knights
		e.other:Faction(231,-10);	-- Faction: Craftkeepers
		e.other:Faction(233,-10);	-- Faction: Crimson Hands
		e.other:SummonItem(1437);	-- Item: Initiate Symbol of Cazic-Thule
		e.other:QuestReward(e.self,{exp = 500});
	elseif item_lib.check_turn_in(e.trade, {item1 = 13074, item2 = 16990, item3 = 14102, item4 = 14103}) then -- Items: Zombie Skin, Embalming Dust, Charred Bone Chips, Vial of Tunare's Breath
		e.self:Say("Excellent Job " .. e.other:GetName() .. ". These components will help with our research immeasurably. You will soon be reaping the rewards granted by our Lord Cazic-Thule!! If you want to further assist our research effots, talk to Atdehim Sqonci.");
		e.other:Faction(265,30);	-- Faction: Heretics
		e.other:Faction(254,-30);	-- Faction: Gate Callers
		e.other:Faction(242,-30);	-- Faction: Deepwater Knights
		e.other:Faction(231,-30);	-- Faction: Craftkeepers
		e.other:Faction(233,-30);	-- Faction: Crimson Hands
		e.other:SummonItem(14100);	-- Item: Fright Forged Helm
		e.other:QuestReward(e.self,{exp = 1000});
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
