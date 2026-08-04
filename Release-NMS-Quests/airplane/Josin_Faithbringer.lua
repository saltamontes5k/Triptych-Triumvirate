function event_say(e)
	if e.message:findi("Hail") then
		e.self:Say("Greetings, " .. e.other:GetCleanName() .. ".  Are you ready to begin your test of faith?");
	elseif e.message:findi("test of faith") and e.other:HasClass(Class.CLERIC) then
		e.self:Say("I have faith that you will do well. Choose Alan or Deric");
	elseif e.message:findi("test of faith") then
		e.self:Say("Your will is honorable, but I am busy.");
	elseif e.message:findi("Alan") and e.other:HasClass(Class.CLERIC) then
		e.self:Say("Take and read this book. When you are done, hand it back to me and I will summon him.");
		e.other:SummonFixedItem(18540); -- Practical Arts
	elseif e.message:findi("Deric") and e.other:HasClass(Class.CLERIC) then
		e.self:Say("Take and read this book. When you are done, hand it back to me and I will summon him.");
		e.other:SummonFixedItem(18541); -- True Healing
	end
end

function event_trade(e)
	local item_lib = require("items");
	if item_lib.check_turn_in(e.trade, {item1 = 18540}) then --Strength
		e.self:Say("Farewell.");
		eq.spawn2(71080,0,0,660.7,1361.6,-766.9,386.4); -- NPC: Alan_Harten
		eq.depop_with_timer();
	elseif item_lib.check_turn_in(e.trade, {item1 = 18541}) then --Tranquility
		e.self:Say("Farewell.");
		eq.spawn2(71083,0,0,660.7,1338.0,-766.9,386.4); -- NPC: Deric_Lennox
		eq.depop_with_timer();
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
