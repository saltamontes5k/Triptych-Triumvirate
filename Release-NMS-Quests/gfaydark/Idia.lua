function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hail. " .. e.other:GetName() .. " - Are you [interested] in helping the League of Antonican Bards by delivering some [mail]?");
	elseif e.message:findi("interested") then
		e.self:Say("I have messages that need to go to - well. right now I have one that needs to go to Freeport.  Will you [deliver] mail to [" .. eq.say_link("I will deliver mail to Freeport",false,"Freeport") .. "] for me?");
	elseif e.message:findi("mail") and not e.message:findi("deliver") and not e.message:findi("freeport") and not e.message:findi("qeynos") then
		e.self:Say("The League of Antonican Bards has a courier system made up of travelers, adventurers, and [agents].  We pay good gold to anyone who will take messages from bards such as myself to one of our more distant offices.  Are you [interested]?");
	elseif e.message:findi("agents") then
		e.self:Say("Lyra Lyrestringer, Tacar Tissleplay, Kilam Oresinger and Siltria Marwind all report to Jakum Webdancer.");
	elseif e.message:findi("deliver") and e.message:findi("Freeport") then
		e.self:Say("Take this letter to Felisity Starbright. You can find her at the bard guild hall. I'm sure she will compensate you for your trouble.");
		e.other:SummonItem(18166); -- Item: Pouch of Mail (Freeport)
	end
end

function event_trade(e)
	local item_lib = require("items");
	if item_lib.check_turn_in(e.trade, {item1 = 18167}) then -- Item: Pouch of Mail (Kelethin)
		e.self:Say("More mail - you have done us a noteworthy service!  Please take this gold for your troubles.  If you are interested in more work, just ask me.");
		e.other:QuestReward(e.self,{exp = 1550, gold = eq.ChooseRandom(8,9,10,11,12)});
		e.other:Faction(284,5);		-- Faction: league of antonican bards
		e.other:Faction(281,1);		-- Faction: knights of truth
		e.other:Faction(262,1);		-- Faction: guards of qeynos
		e.other:Faction(304,-1);	-- Faction: ring of scale
		e.other:Faction(285,-1);	-- Faction: mayong mistmoore
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
