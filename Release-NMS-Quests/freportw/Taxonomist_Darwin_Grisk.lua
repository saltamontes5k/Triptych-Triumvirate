-- Quest: Luggald Rumors

function event_say(e)
	local qglobals = eq.get_qglobals(e.self, e.other);

	if e.message:findi("hail") then
		if  qglobals["grisk"] ~= nil and (qglobals["grisk"] == "1" or qglobals["grisk"] == "2" or qglobals["grisk"] == "3") then
			e.self:Say("Thank the gods, you have returned safely! We had heard tell of your battle. Did you by chance find anything of informational value?");
		else
			e.self:Say("Have you come to [help]? If not, be gone! I will not have my time wasted.");
		end
	elseif e.message:findi("help") then
		e.self:Say("Recently rumors have surfaced that a new race, the Luggalds, walks the land. I suspect that some evil force is involved in their appearance. Are you [willing] to risk unknown dangers to help me find out?");
	elseif e.message:findi("willing") then
		e.self:Say("Good. I have not been able to confirm the existence of these beings. I will need definite proof if the rest of the members of the Academy are to believe me. Take this Warded Satchel and retrieve three examples of Luggald Flesh.");
		e.other:SummonItem(17590); -- Warded Satchel
	elseif e.message:findi("aid") and qglobals["grisk"] ~= nil and qglobals["grisk"] == "1" then
		e.self:Say("Travel to the Crypt of Nadox and slay as many of the Luggalds there as you can. This will slow their plans, but to truly damage their efforts I will need more information. Bring me three more samples of their fecund flesh so that I can compare them with the other examples. Combine them in this Warded Chest.");
		e.other:SummonItem(17591); -- Warded Chest
	end
end

function event_trade(e)
	local item_lib = require("items");

	if item_lib.check_turn_in(e.trade, {item1 = 63009}) then -- Item: Warded Luggald Samples
		e.self:Say("Very good. This will no doubt convince the others. However, we don't have time to wait for their consensus. Deep in the uncovered Crypt of Nadox the Luggalds seem to be at work. This can mean nothing good for the mortal world. You must provide further [aid].");
		eq.set_global("grisk", "1", 5, "F"); -- Completed grisk First Task
	elseif item_lib.check_turn_in(e.trade, {item1 = 63010}) then -- Item: Chest of Luggald Samples
		e.self:Say("Alas, it all becomes clear! The Luggalds seek to spread their vile race. I had received word of a dark elf performing arcane rites on the shores of Toxxulia Forest. Now I know she must be attempting to summon other Luggalds. She is expecting an agent of the enemy. Talk with her. Then deal with her and any evil she creates.");
		eq.set_global("grisk", "2", 5, "F"); -- Completed grisk Second Task
	elseif item_lib.check_turn_in(e.trade, {item1 = 63015}) then -- Item: Fleshless Heart
		e.self:Say("Well done. I can only imagine the evil you averted. Here. Take this a token of my personal thanks. May we all continue to benefit from your valor.");
		if e.other:HasClass(Class.BARD) or e.other:HasClass(Class.BEASTLORD) or e.other:HasClass(Class.PALADIN) or e.other:HasClass(Class.RANGER) or e.other:HasClass(Class.ROGUE) or e.other:HasClass(Class.SHADOWKNIGHT) or e.other:HasClass(Class.WARRIOR) then
			e.other:SummonItem(63050); -- Item: Bonebite
			e.other:Ding();
			e.other:AddEXP(5000);
		else
			e.other:SummonItem(63051); -- Item: Signet of Grisk
			e.other:Ding();
			e.other:AddEXP(5000);
		end
		eq.delete_global("grisk"); -- clean up qglobal at quest completion
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
