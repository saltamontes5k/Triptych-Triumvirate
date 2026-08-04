--Quest for Paineel - Davorre Bloodthorn: Neonate Cowardice and Experienced Courier

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Greetings. Perhaps within that husk you call a body there is some worth? Are you [experienced] in your craft, young one, or are you a [neonate]?");
	elseif e.message:findi("neonate") then
		e.self:Say("Well then, child, I may still have a task for you. Will you [make use of your pathetic cowardice], then, eh?");
	elseif e.message:findi("pathetic cowardice") then
		e.self:Say("I see. This will not be the first time for you, I am sure. Take this list to Auhrik Siet`ka. His writing has become illegible in his old age, but he shall clarify what it is he needs you to do. Do as he says, child, and perhaps you will prove yourself a bit more worthy than the rotting flesh he will most likely have you return to him.");
		if not e.other:HasItem(14041) then
			e.other:SummonItem(14041); -- Item: A Rolled Up Note
		end
	elseif e.message:findi("experienced") then
		e.self:Say("Ahhhh, a youth doth approach me with such confidence! That is to be commended in and of itself. Ordinarily, I would turn you away without a second glance, but perhaps you can be of some use. Tell me, child, are you [willing to assist] me in a small, yet important, task?");
	elseif e.message:findi("willing to assist") then
		e.self:Say("Good, child. Deliver this note to Veisha Fathomwalker. You shall find her patrolling the outer regions of Toxxulia Forest. I trust that you will keep your eyes to yourself in this matter. Now go, and please travel within the veil of night, so you will not be seen by those whose minds are still clouded with delusions of Erudin's grandeur.");
		if not e.other:HasItem(12998) then
			e.other:SummonItem(12998); -- Item: Rolled up Note
		end
	end
end

function event_trade(e)
	local item_lib = require("items");

	if item_lib.check_turn_in(e.trade, {item1 = 12997}) then -- Item: Veisha's Engagement Ring
		e.self:Say("Only a few years have passed and her heart has already forgotten me. No doubt she has found another to warm her bed. Go, find her new lover, and bring me nothing less than his head.");
		e.other:Faction(265,5);		-- Faction: Heretics
		e.other:Faction(254,-5);	-- Faction: Gate Callers
		e.other:Faction(242,-5);	-- Faction: Deepwater Knights
		e.other:Faction(231,-5);	-- Faction: Craftkeepers
		e.other:Faction(233,-5);	-- Faction: Crimson Hands
		e.other:QuestReward(e.self,{exp = 500});
	elseif item_lib.check_turn_in(e.trade, {item1 = 12996}) then -- Item: Phaeril Nightshire's Head
		e.self:Say("Apparently her choice in suitors has drifted to the most pathetic of wretches ever to slither Odus. You have done well, child. I ask of you one last task before my message to Veisha is complete. Here, deliver this to her with my most sincere regards.");
		e.other:Faction(265,5);		-- Faction: Heretics
		e.other:Faction(254,-5);	-- Faction: Gate Callers
		e.other:Faction(242,-5);	-- Faction: Deepwater Knights
		e.other:Faction(231,-5);	-- Faction: Craftkeepers
		e.other:Faction(233,-5);	-- Faction: Crimson Hands
		e.other:SummonItem(12995);	-- Item: A Locked Chest
		e.other:QuestReward(e.self,{exp = 500});
	elseif item_lib.check_turn_in(e.trade, {item1 = 12994}) then -- Item: Veisha Fathomwalker's Head
		e.self:Say("My revenge has been satisfied. Thank you, my child. You have proven yourself to be a most worthy asset to our cause. Here, I no longer have any use for this, my ties to the old life are now severed.");
		e.other:Faction(265,5);		-- Faction: Heretics
		e.other:Faction(254,-5);	-- Faction: Gate Callers
		e.other:Faction(242,-5);	-- Faction: Deepwater Knights
		e.other:Faction(231,-5);	-- Faction: Craftkeepers
		e.other:Faction(233,-5);	-- Faction: Crimson Hands
		e.other:SummonItem(5526);	-- Item: Battle Worn Halberd
		e.other:QuestReward(e.self,{exp = 6000});
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
