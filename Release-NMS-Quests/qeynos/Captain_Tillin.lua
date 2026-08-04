function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hail, " .. e.other:GetName() .. "! Spend your time wisely in the city of Qeynos. Do not let your mind wander to thoughts of bravado or crime. My guards can easily put to rest any outbreaks. Good day to you, citizen!");
	elseif e.message:findi("executioner") then
		e.self:Say("The executioner is quite an exceptional person.  [Field Marshall Ralem] happened upon her while on a secret operation in Everfrost Peaks.  They fought side by side against some creature the locals named Iceberg.  The creature escaped.  Ralem was grateful and eventually recruited her when she decided to separate from the guards of Halas.");
	elseif e.message:findi("field marshall ralem") then
		e.self:Say("Field Marshall Ralem Christof is in charge of a brigade of roving rangers, druids and warriors.  He hails from the Jaggedpine.  He is quite an exceptional ranger.  No one is ever really sure where he is.  His brigade is constantly on the move.");
	end
end

function event_signal(e)
	e.self:Say("Ah.  Good.  You have arrived.  [Executioner], could you please visit McNeal Jocub at Fish's Tavern.  He has violated our laws and the sentence is death.");
	eq.signal(1202,1);
end

function event_trade(e)
	local item_lib = require("items");

	if item_lib.check_turn_in(e.trade, {item1 = 18815}) then -- Item: Tattered Note
		e.self:Say("I heard you were on your way.  I have called for the state [executioner].  She should be on her way now.  She will deal with our friend, McNeal Jocub.  Thank you for your help, citizen.");
		e.other:Faction(262,40,0);	-- Faction: Guards of Qeynos
		e.other:Faction(219,6,0);	-- Faction: Antonius Bayle
		e.other:Faction(230,-6,0);	-- Faction: Corrupt Qeynos Guards
		e.other:Faction(223,-10,0);	-- Faction: Circle of Unseen Hands
		e.other:Faction(291,4,0);	-- Faction: Merchants of Qeynos
		e.other:QuestReward(e.self,math.random(10),math.random(9),math.random(5),0,13305,500); -- Item: Medal of Merit
		eq.spawn2(1202,62,0,-412,75,-24,0);
	elseif item_lib.check_turn_in(e.trade, {item1 = 18912}) then -- Item: Tattered Cloth Note
		e.self:Say("So, an assassin has been sent to Qeynos! I shall have my guards keep an eye out for any suspicious looking visitors. As for you... you should speak with the Surefall Glade ambassador. Ambassador Gash is staying at the Lion's Mane Inn here in South Qeynos. Inform him that [an assassin has been sent to kill] him. Do not let the assassin near him!");
		e.other:Faction(262,5,0);	-- Faction: Guards of Qeynos
		e.other:Faction(219,1,0);	-- Faction: Antonius Bayle
		e.other:Faction(230,-1,0);	-- Faction: Corrupt Qeynos Guards
		e.other:Faction(223,-1,0);	-- Faction: Circle of Unseen Hands
		e.other:Faction(291,1,0);	-- Faction: Merchants of Qeynos
		e.other:QuestReward(e.self,math.random(10),math.random(9),math.random(5),0,0,500);
	elseif item_lib.check_turn_in(e.trade, {item1 = 8280}) then  -- Item: Compiled Report  (Qeynos Badge #5)
		e.self:Emote("scans the report with a furrowed brow. 'So the threat is worse then we had anticipated. The intelligence we have gathered is true. We have little time, return to Seargeant Caelin and give him these orders. Time is of the essence. Hurry now, these people are in grave danger and something must be done to stop this!'");
		e.other:QuestReward(e.self,{exp = 1000});
		e.other:SummonItem(8287);	-- Item: Orders for Sergeant Caelin
	end

	while item_lib.check_turn_in(e.trade, {item1 = 13915}) do
		e.self:Say("Very good! One less gnoll the people of Qeynos need to fear. Here is your bounty as promised.");
		e.other:QuestReward(e.self,{exp = 1000});
		e.other:Faction(262,3);		-- Faction: Guards of Qeynos
		e.other:Faction(219,1);		-- Faction: Antonius Bayle
		e.other:Faction(230,-1);	-- Faction: Corrupt Qeynos Guards
		e.other:Faction(223,-1);	-- Faction: Circle of Unseen Hands
		e.other:Faction(291,1);		-- Faction: Merchants of Qeynos
		e.other:SummonItem(10070);	-- Item: Moonstone
	end

	item_lib.return_items(e.self, e.other, e.trade)
end
