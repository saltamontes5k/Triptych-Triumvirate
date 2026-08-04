local total_champagne = 0;

function event_say(e)
	if e.message:findi("lucan") then
		e.self:Say("That man is no just ruler. He has jailed me and my friend Zimel for merely begging.");
	elseif e.message:findi("hail") then
		e.self:Say("Do you have any spare coppers for a thirsty soul?");
	elseif e.message:findi("tell me of zimel") then
		e.self:Say("What?! You know my friend Zimel?! I would like to speak of him, but my mouth is so parched. Maybe a fine grog would loosen my lips. I am uncertain which flavor shall do the trick.");
	end
end

function event_trade(e)
	local champagne = 0;
	local item_lib = require("items");

	if item_lib.check_turn_in(e.trade, {item1 = 13829,item2 = 13829,item3 = 13829,item4 = 13829}) then
		total_champagne = total_champagne + 4;
		champagne = 4;
	elseif item_lib.check_turn_in(e.trade, {item1 = 13829,item2 = 13829,item3 = 13829}) then
		total_champagne = total_champagne + 3;
		champagne = 3;
	elseif item_lib.check_turn_in(e.trade, {item1 = 13829,item2 = 13829}) then
		total_champagne = total_champagne + 2;
		champagne = 2;
	elseif item_lib.check_turn_in(e.trade, {item1 = 13829}) then
		total_champagne = total_champagne + 1;
		champagne = 1;
	end

	if champagne > 0 then
		repeat
			e.self:Say("Oooh!! That is the taste. My lips are almost loose. Maybe another will do the trick.");
			champagne = champagne - 1;
		until champagne == 0
	end

	if total_champagne >= 4 then
		e.self:Say("Ahh!! That was good. Now where were we?. Oh yes. My [" .. eq.say_link("tell me of zimel",false,"friend Zimel") .. "] is a fellow beggar. He was locked up in the arena. They were going to let him go when the Freeport Militia came for him. Ha!! He is crazy as a troll now. I took this blanket from his cell before I was released. I no longer need it and my guilt has reached its peak. I do not want crazy old Zimel to freeze. Perhaps you can return it to him.");
		e.other:QuestReward(e.self,{exp = 10}); -- Item: Bunker Cell #1 (Zimel's Blanket)
		e.other:SummonFixedItem(12196);
		total_champagne = 0;
	end
	item_lib.return_items(e.self, e.other, e.trade);
end
