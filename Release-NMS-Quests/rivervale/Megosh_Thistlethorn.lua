-- items: 19627, 51121, 51122, 18432, 13541, 19622, 19623, 19624
function event_spawn(e)
	local xloc = e.self:GetX();
	local yloc = e.self:GetY();
	eq.set_proximity(xloc - 50, xloc + 50, yloc - 50, yloc + 50);
end

function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("Greetings " .. e.other:GetName() .. "! I am Megosh Thistlethorn first Ranger of the Storm Reapers of Rivervale. I journeyed many years ago to the Surefall Glade far to the west of our lovely shire. It was there I trained with the human and half-elven rangers that like the Storm Reapers are faithful disciples of Karana. I have returned now to Rivervale to teach our interested young people the ways of a ranger of the Storm Lord. so that we may defend our shire and the wilds of Norrath from the [evil forces] that would see it destroyed.");
	elseif(e.message:findi("evil forces")) then  
		e.self:Say("Currently the Death Fist Clan of Orcs. a race of bloodthirsty humanoids concerned only with expanding their territory and slaughtering all who stand in their path. threatens our homeland. The Orcs have long had a minor presence in the Misty Thicket but lately they have been amassing in greater numbers. The Death Fist has been chopping down our trees and quarrying rock from the nearby mountains. We know only that they have been shipping the materials to the commonlands and stockpiling it for what purpose we do not know. As rangers of the Storm Reapers it is our duty to stop the desecration of the thicket.");
	end
end

function event_trade(e)
	local item_lib = require("items");

	if(item_lib.check_turn_in(e.trade, {item1 = 18432})) then -- Handin the Halfling Ranger note
		e.self:Say("Welcome to the Storm Reapers " .. e.other:GetName() .. "! Here is a tunic to keep you warm in your travels. Rivervale, our lovely home is facing dangerous times. From both the east and west forces devoted to the evil Gods Bertoxxulous adn Innoruuk are corrupting and destroying the wilds of Norrath. Also, the Orcs of Clan Deathfist are waging war on this entire region and gathering lumber and stone for some unknown purpose. We must do our best to preserve the lands and way of life of all Karanas people. Once you are ready to begin defending the vale against the [evil forces], please return to me. I also posses knowledge of various [trades], seek me out when you wish to learn about them.");
		e.other:SummonItem(13541); -- Jumjum Sack Tunic*
		e.other:Ding();
		e.other:Faction(355,100,0); -- +Storm Reapers
		e.other:Faction(286,10,0); -- +Mayor Gubbin
		e.other:Faction(292,15,0); -- +Merchants of Rivervale
		e.other:Faction(324,-15,0); -- -Unkempt Druids
		e.other:AddEXP(100);
	end
	item_lib.return_items(e.self, e.other, e.trade)
end

-- END of FILE Zone:rivervale  ID:19050 -- Megosh_Thistlethorn
