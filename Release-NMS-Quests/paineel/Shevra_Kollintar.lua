function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Unless you intend to [" .. eq.say_link("make myself useful",false,"make yourself useful") .. "], do not bother me.  I await the return of our Lord, Cazic-Thule.  He comes, and I shall be the first to greet Him.  I will train you, if need be, for He looks upon those who aid Him kindly.  If you are not here for training, return to your meditations or bother someone else.");
	elseif e.message:findi("make myself useful") then
		e.self:Say("One of our spies has reported a sighting of Malik Zaren, a courier of [the High Council].  He was seen resting at an inn called 'Golden Roosters' in High Pass Hold and is en route to Erudin Palace. He may be carrying a message containing information of great value to us.  Hunt him down and return to me with the letter he carries. I will reward you for this task.");
	elseif e.message:findi("high council") then
		e.self:Say("The High Council is the governing board of Erudin, our sworn enemies.  Beware of these types, they will not look upon you warmly.");
	end
end

function event_trade(e)
	local item_lib = require("items");

	if item_lib.check_turn_in(e.trade, {item1 = 12270}) then -- Item: Sealed Letter
		e.self:Say("Ah, excellent work.  I certainly had my doubts about you, " .. e.other:GetName() .. ".  Wear this well.");
		e.other:Faction(265,5);		-- Faction: Heretics
		e.other:Faction(242,-5);	-- Faction: Deepwater Knights
		e.other:Faction(254,-5);	-- Faction: Gate Callers
		e.other:Faction(231,-5);	-- Faction: Craftkeepers
		e.other:Faction(233,-5);	-- Faction: Crimson Hands
		e.other:SummonItem(eq.ChooseRandom(3040,3042,3043,3044,3046,3047,3048,3049,3050,3051)); -- Items: Random Blackened Iron
        e.other:QuestReward(e.self,{exp = 500});
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
