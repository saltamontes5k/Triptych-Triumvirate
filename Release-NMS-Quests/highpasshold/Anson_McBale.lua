-- items: 28014
function event_say(e)
	local fac = e.other:GetFaction(e.self);
	local level = e.other:GetLevel();
	
	if(fac <= 5) then
		if(e.message:findi("hail")) then
			e.self:Emote("looks at you suspiciously. 'Yeah? Whacha want?'");
		elseif(e.message:findi("see stanos") and level >= 50) then
			e.self:Say("This better be important.");
			eq.unique_spawn(5088,0,0,336,10,45,450); -- NPC: Stanos_Herkanor
		elseif(e.message:findi("see stanos") and level <= 49) then
			e.self:Say("Get lost. Stanos is a busy man, and you look like you could barely handle a Shralok orc.")
		end
	else
		e.self:Say("Go away! We don't have time for the likes of you.");
	end
end

function event_trade(e)
	local item_lib = require("items")
	if(e.other:GetLevel() >= 50) then
		if(item_lib.check_turn_in(e.trade, {item1 = 28014})) then
		--e.self:Say("Ah, we have been expecting this. Let me get Stanos, he will want to inspect it first, but here are your coins.");
		e.self:Say("Ah, we have been expecting this. Let me get Stanos, he will want to inspect it.");
		e.other:Ding();
		e.other:Faction(332,50,0); -- Faction: Highpass Guards
		e.other:Faction(329,7,0); -- Faction: Carson McCabe
		e.other:Faction(331,7,0); -- Faction: Merchants of Highpass
		e.other:Faction(230,2,0); -- Faction: Corrupt Qeynos Guards
		e.other:Faction(330,2,0); -- Faction: The Freeport Militia
		e.other:AddEXP(500);
		-- e.other:Message(15,"You receive 35 platinum from Anson McBale.")
		-- e.other:AddMoneyToPP(0, 0, 0, 35, true);
		eq.unique_spawn(5088,0,0,336,10,45,450); -- NPC: Stanos_Herkanor
		end
	elseif(e.other:GetLevel() <= 49) then
		if(item_lib.check_turn_in(e.trade, {item1 = 28014})) then
			e.self:Say("What is this? I trust Vilnius' judgment, but you're not yet ready for what is to come. Come back when you have some more experience at your trade.");
			e.other:SummonFixedItem(28014);
		end
	end
	item_lib.return_items(e.self, e.other, e.trade)
end

function event_signal(e)
	e.self:Say("Vilnius has always had a good eye for talent. I think we can trust this one. But will he trust us? You have to wonder if he even knows who we are...");
	eq.signal(5088, 0); --stanos
end