	
function event_say(e)
    local qglobals = eq.get_qglobals(e.self, e.other);

	if e.message:findi("hail") then
		e.self:Say("Greetings, Traveler. I do not receive many visitors to my quarters here, besides the occasional unfortunate treasure seeker that often will make for a good snack.");
    elseif qglobals["CircletFalinkan"] ~= nil and qglobals["CircletFalinkan"] == "1" and e.message:findi("kardakor sent me") then
		e.self:Say("You are sent from Kardakor are you? Well surely he must have sent you to stand before me for a reason.");
    elseif qglobals["CircletFalinkan"] ~= nil and qglobals["CircletFalinkan"] == "1" and e.message:findi("talisman") then
		e.self:Say("Ah of course, It has been quite a long time sense my powers of identification have been requested. If you are sent from Kardakor then your intent must be well directed. I do have a favor to ask of you before I identify your talisman. I seek some rare [" .. eq.say_link("treasures") .. "] to further some studies that I have been working on for a long time.");
    elseif qglobals["CircletFalinkan"] ~= nil and qglobals["CircletFalinkan"] == "1" and e.message:findi("treasures") then
		e.self:Say("There are 3 items that I seek to continue my studies of some various and musterious magics. Bring to me the teachings of a high ranking Kromzek that I hear goes by the name of Gkrean, a chipped fang from a beast deep within the Cursed Necropolis. Also for good measure, I require the Head of a Kromzek Staff Sergeant to prove to your dedication to our cause. Present these 3 items to me along with your Talisman that you wish to learn more about and I shall do my best to identify its origin for you.");
    end
end

function event_trade(e)
	local item_lib = require("items");
    local qglobals = eq.get_qglobals(e.self, e.other);

	if e.other:GetFaction(e.self) <= 3 and qglobals["CircletFalinkan"] ~= nil and tonumber(qglobals.CircletFalinkan) == 1 then -- CoV Kindly
		if item_lib.check_turn_in(e.trade, {item1 = 1861,item2 = 1863, item3 = 1864, item4 = 1865}) then -- Items: Old Worn Talisman, Chipped Fang, Teachings of Gkrean, Head of Staff Sergeant Drioc
			e.self:Say("So you finally made it ! Head back to Ralgyn to get your reward.");
			e.other:Faction(436, 12);	-- Faction: Yelinak
			e.other:Faction(430, 50);	-- Faction: CoV
			e.other:Faction(448, -24);	-- Faction: Kromzek
			e.other:SummonItem(1866);	-- Item: Glanitar's Imbued Talisman
			e.other:QuestReward(e.self,{exp = 100000});
 			eq.set_global("CircletFalinkan","2",5,"F");
		elseif item_lib.check_turn_in(e.trade, {item1 = 1861}) then -- Item: Old Worn Talisman
		    e.self:Say("It would be my guess that you present this to me in hopes of finding out more about the magics it possesses. Before I can do this I require some rare treasures that you must present to me.");
            e.other:SummonItem(1861); -- Item: Old Worn Talisman
		end
	end

    item_lib.return_items(e.self, e.other, e.trade);
end
