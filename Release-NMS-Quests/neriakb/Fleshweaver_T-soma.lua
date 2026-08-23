-- Quest: Luggald Flesh

function event_say(e)
	local qglobals = eq.get_qglobals(e.self, e.other);
	if e.message:findi("Hail") then
		if qglobals["tsoma"] ~= nil and qglobals["tsoma"] == "1" or qglobals["tsoma"] == "2" or qglobals["tsoma"] == "3" then
			e.self:Say("So. You've come back. I hope, for your sake, you haven't returned empty handed.");
		else
			e.self:Say("Ah you must be the one sent to assist me. Good. I have need of flesh for my spellwork. I wish to summon them myself! Get me three samples of flesh from these new Luggald beings. Put the samples in this Fleshthread Satchel so that they don't decay.");
			e.other:SummonItem(17592); -- Item: Fleshthreaded Satchel
		end
	elseif e.message:findi("task") and qglobals["tsoma"] ~= nil and qglobals["tsoma"] == "1" then
		e.self:Say("We first learned of the Luggalds through our agents on Broken Skull Rock. It appears that Innoruuk intended these servants only for the trolls. We shall see about that! Go retrieve three samples of Fecund Luggald Flesh. You will need to get the flesh of those in the Crypt of Nadox this time. Here. Make sure to put them in this Fleshwoven Bag.");
		e.other:SummonItem(17593); -- Item: Fleshwoven Bag				
	end
end

--Trade Block
function event_trade(e)
	local item_lib = require("items");
	local qglobals = eq.get_qglobals(e.self, e.other);

	if item_lib.check_turn_in(e.trade, {item1 = 63012}) then -- Item: Satchel of Luggald Samples
		e.self:Say("Hmm. You seem more capable than my other assistants. I have another [task] to ask of you.");
		eq.set_global("tsoma", "1", 5, "F"); -- Completed tsoma First Task
	elseif item_lib.check_turn_in(e.trade, {item1 = 63013}) then -- Item: Fecund Luggald Samples
		e.self:Say("Ah, yes. These are fantastic examples. No doubt they will ensure the success of our attempt. Now quickly, go speak with my Assistant T`os. She's prepared the ritual of summoning on the shores of Toxxulia Forest. It should be far enough away if anything...occurs.");
		eq.set_global("tsoma", "2", 5, "F"); -- Completed tsoma Second Task
	elseif qglobals["tsoma"] ~= nil and qglobals["tsoma"] == "3" and item_lib.check_turn_in(e.trade, {item1 = 63015}) then -- Item: Fleshless Heart and flag
		e.self:Say("Apparently our ignorance exceeded our luck. Ah well, I'm sure the Prince of Hate will find some other punishment for our folly. Well, since you too chance his anger I suppose you deserve a reward. Here, take this...though I'm not sure how much use it will be against a god.");
		if e.other:HasClass(Class.WARRIOR) or e.other:HasClass(Class.PALADIN) or e.other:HasClass(Class.RANGER) or e.other:HasClass(Class.SHADOWKNIGHT) or e.other:HasClass(Class.BARD) or e.other:HasClass(Class.ROGUE) then
			e.other:SummonItem(63052); -- Item: Heartspike
			e.other:Ding();
			e.other:AddEXP(5000);
		else
			e.other:SummonItem(63053); -- Item: Heartspike
			e.other:Ding();
			e.other:AddEXP(5000);
		end
		eq.delete_global("tsoma"); -- clean up qglobal at quest completion
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
