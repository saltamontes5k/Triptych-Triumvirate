---- Quest:Snarla's Friendship
function event_say(e)
    local fac = e.other:GetFaction(e.self);

	local epic_pre_onefive	= 0;
	local epic_onefive		= 0;
	local epic_two			= 0;
	local epic_twofive		= 0;

	if e.other:HasClass(Class.ENCHANTER) then
		local data_bucket = ("Epic-Enchanter-"..e.other:CharacterID());

		local s					= nil;	-- Status Array

		if eq.get_data(data_bucket) ~= "" then -- Has Started
			local temp = eq.get_data(data_bucket);
			s = eq.split(temp, ',');
	
			epic_pre_onefive	= tonumber(s[1]);
			epic_onefive		= tonumber(s[2]);		
			epic_two			= tonumber(s[3]);
			epic_twofive		= tonumber(s[4]);
		end
	end

	if epic_two == 10 and e.message:findi("Firwyn") then
		e.other:Message(MT.NPCQuestSay, "Chef Brargus says 'Ah, talked to Feyana did you? I'm surprised she trusted the likes of you with something like this. I suppose it's no loss to her if you just wind up dead now is it? If you want to know where to find Firwyn you're going to have to bring me some mountain pooka meat. I'm working on a new recipe and I simply must have it. Off with you.'");
		update_enchanter_epic_databucket(e,epic_pre_onefive,epic_onefive,11,epic_twofive);
	end

	if(e.message:findi("hail")) then
		e.self:Say("Whatchoo want?");
	elseif(e.message:findi("dryad pate")) then
		if (fac <=5) then
			e.self:Say("You want my secret recipe for Nymph Pate? You don't look like you could even cook a [" .. eq.say_link("Patty Melt") .. "] without making a disgusting mess, let alone something as delicate and refined as Nymph Pate!");
		else
			dialogue_reject(e.self);		--NPC will not advance quest without proper faction
		end
	elseif(e.message:findi("patty melt")) then
		if (fac <=5) then	
			e.self:Say("Yeah, you know a patty melt! It's like a [" .. eq.say_link("Grilled Cheese Sandwich") .. "] with some meat stuck in between the whole mess. Sheesh, are you a vegetarian or something?");
		else
			dialogue_reject(e.self);		--NPC will not advance quest without proper faction
		end
	elseif(e.message:findi("grilled cheese sandwich")) then
		if (fac <=5) then
			e.self:Say("Great Brell's gravy, you are inept aren't you! I'll say this slowly. You take some bread, then you take some cheese then you put them together and cook it with a frying pan! I'll tell you what, if you can manage to figure out how to make a Patty Melt, bring it back to me and if it's halfway edible I'll give you my recipe for Nymph Pate.");
		else
			dialogue_reject(e.self);		--NPC will not advance quest without proper faction
		end
	end
end

function event_trade(e)
    local item_lib = require("items");
	local epic_pre_onefive	= 0;
	local epic_onefive		= 0;
	local epic_two			= 0;
	local epic_twofive		= 0;

	if e.other:HasClass(Class.ENCHANTER) then
		local data_bucket = ("Epic-Enchanter-"..e.other:CharacterID());

		local s					= nil;	-- Status Array

		if eq.get_data(data_bucket) ~= "" then -- Has Started
			local temp = eq.get_data(data_bucket);
			s = eq.split(temp, ',');
	
			epic_pre_onefive	= tonumber(s[1]);
			epic_onefive		= tonumber(s[2]);		
			epic_two			= tonumber(s[3]);
			epic_twofive		= tonumber(s[4]);
		end
	end

	if (epic_two == 11 or epic_two == 12) and not eq.get_entity_list():IsMobSpawnedByNpcTypeID(181010) and item_lib.check_turn_in(e.trade, {item1 = 54240}) then -- Item: Mountain Pooka Meat
		e.other:Message(MT.NPCQuestSay, "Chef Brargus says 'That should do nicely. Now, about Firwyn. You should be able to find her in the forest nearby but I would be careful if I were you. She can be a bit feisty, and you don't exactly look like a warrior if you know what I mean.'");
		eq.spawn2(181010, 0, 0,-386,-37,-27.3,100); -- NPC: #Firwyn
		update_enchanter_epic_databucket(e,epic_pre_onefive,epic_onefive,12,epic_twofive);
	end

    if(item_lib.check_turn_in(e.trade, {item1 = 8194})) then -- Patty Melt
        e.self:Emote("wolfs down the Patty Melt in one bite.");
        e.self:Say("Yeah, this isn't too bad I guess. Not nearly as good as I could have done though.");
        e.self:Emote("scribbles on a piece of paper and hands it to " .. e.other:GetName() .. ".");
        e.self:Say("Here is the recipe you wanted.");
--        e.other:Faction(96,-5); -- Faction; Regent - this is Eye of Seru, I see nothing that shows any faction mod to anything from this handin
        e.other:QuestReward(e.self,0,0,0,0,18430,1000); -- Elegant Pates
    end
    item_lib.return_items(e.self, e.other, e.trade)
end

function dialogue_reject(npc)
	local phrase = math.random(1,4);
	if (phrase == 1) then
		npc:Say("I wonder how much I could get for the tongue of a blithering fool?  Leave before I decide to find out for myself.");
	elseif (phrase == 2) then
		npc:Say("Oh look, a talking lump of refuse. How novel!");
	elseif (phrase == 3) then
		npc:Say("Is that your BREATH , or did something die in here? Now go away!");
	elseif (phrase == 4) then
		npc:Say("I didn't know Slime could speak common.  Go back to the sewer before I lose my temper.");
	end
end

function update_enchanter_epic_databucket(e,pre_one_five,one_five,two,two_five)
	eq.set_data("Epic-Enchanter-"..e.other:CharacterID(), pre_one_five..","..one_five..","..two..","..two_five);
	e.other:Message(MT.Yellow, "Your quest has been advanced");
end
