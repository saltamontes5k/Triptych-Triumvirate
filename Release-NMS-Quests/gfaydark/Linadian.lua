function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Greetings!  Please look through my fine wares.  I have spent my whole life practicing my skills in tailoring.  I do my best to compete with the other local merchants. but I have yet to make a profit.  I pray to Tunare that my [banded orc vests] will finally bring me a few extra coins.");
	elseif e.message:findi("banded orc vest") then
		e.self:Say("Glad you are interested!  I can create a leather vest I call a banded orc vest.  It will aid you in repelling any disease and offers quite a bit of protection in battle.  I will need some materials. For a Deathfist banded orc vest. I require two legionnaire pads worn by the Clan Deathfist. one Deathfist slashed belt. and ten gold coins. For a Crushbone banded orc vest. I require two legionnaire pads worn by the Clan Crushbone. one Crushbone belt. and one silk swatch.");
	end
end

function event_trade(e)
	local item_lib = require("items");
	if e.other:GetFaction(e.self) < 6 then -- requires indifferent faction
		if item_lib.check_turn_in(e.trade, {item1 = 13319,item2 = 13319,item3 = 13318,item4 = 16482}) then -- Items: Crushbone Shoulderpads x2, Crushbone Belt, Silk Swatch
			e.self:Say("Grand doing business with you. Hold your nose. I can never get rid of the orc stench of the vests. That is why the other merchants do not pay me much for them.");
			e.other:QuestReward(e.self,{exp = 100});
			e.other:SummonItem(12187);	-- Item: Banded Orc Vest
			e.other:Faction(276,5);		-- Faction: Kelethin Merchants
			e.other:Faction(246,1);		-- Faction: Faydarks Champions
			e.other:Faction(326,1);		-- Faction: Emerald Warriors
			e.other:Faction(5001,1); 	-- Faction: Anti-mage
		elseif item_lib.check_turn_in(e.trade, {item1 = 13917,item2 = 13917,item3 = 13916, gold = 10}) then -- Items: Deathfist Shoulderpads x2, Deathfist Slashed Belt, 10 gold
			e.self:Say("Grand doing business with you. Hold your nose. I can never get rid of the orc stench of the vests. That is why the other merchants do not pay me much for them.");
			e.other:QuestReward(e.self,{exp = 100});
			e.other:SummonItem(12187);	-- Item: Banded Orc Vest
			e.other:Faction(276,5);		-- Faction: Kelethin Merchants
			e.other:Faction(246,1);		-- Faction: Faydarks Champions
			e.other:Faction(326,1);		-- Faction: Emerald Warriors
			e.other:Faction(5001,1); 	-- Faction: Anti-mage
		end
	else
		e.self:Say("Don't take this personally, but I can't quite trust you with such matters.");
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
