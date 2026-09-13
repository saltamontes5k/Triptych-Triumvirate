-- arcstone/369067.lua - Shrine of Druzzil Ro
-- Prophecy of Ro: the Deathknell access chain. The shrine directs the bearer of
-- the Black Shard of Mana onward and accepts it once the three raids are done.
local por = require("por_helper");

function event_say(e)
	local t = e.message:lower();
	if t:find("hail") then
		e.self:Say("The Shrine of Druzzil Ro thrums with quiet power. A voice like distant thunder fills your mind: 'What task would you ask of me?'");
	elseif t:find("what task") or t:find("task") then
		e.self:Say("'A corruption spreads through the Plane of Music. Sullon Zek's rage is poisoned, and Ayonae Ro has sealed herself within Deathknell. You must prove yourself against the rage of the tower.'");
	elseif t:find("enchantment") or t:find("what enchantment") then
		e.self:Say("'Only a shard of my own mana, tempered by the fury of the Plane of Rage and the blood of the fallen, can open the way. Daosheen, Sullon Zek, and Suchun must all fall.'");
	elseif t:find("what steps") or t:find("steps") then
		e.self:Say("'Take up my shard. Face the Firstborn in Skylance, then the Mistress of Rage, then the Blood Warden. When the shard is black, return to me.'");
	elseif t:find("i am willing") or t:find("willing") then
		e.self:Say("'Then go, mortal. The gods are not what they were, and only you can mend what has been broken.'");
	end
end

function event_trade(e)
	local item_lib = require("items");
	local c = e.other;

	-- Black Shard of Mana: the completed key, opens Deathknell
	if item_lib.check_turn_in(e.trade, { item1 = por.items.black_shard_of_mana }) then
		if (tonumber(c:GetBucket("por.suchun")) or 0) == 1 then
			e.self:Say("'The shard is complete, black as the void between the planes. The way into Deathknell, Tower of Dissonance, is open to you. Go, and still the dissonant song.'");
			c:Message(15, "Your path to Deathknell, Tower of Dissonance has been opened.");
			if (tonumber(c:GetBucket("por.deathknell")) or 0) == 0 then
				c:SetBucket("por.deathknell", "1");
			end
			if not c:HasItem(por.items.divine_fetters_of_ro) then
				c:SummonFixedItem(por.items.divine_fetters_of_ro);
				e.self:Say("'Take these fetters, mortal. Wrought of Ro's own bloodline, they will lay bare the dissonant goddess when the song turns against you.'");
				c:Message(15, "You have received the Divine Fetters of Ro.");
			end
		else
			e.self:Say("'The shard is not yet whole. The Blood Warden, Suchun, still draws breath.'");
			c:SummonFixedItem(por.items.black_shard_of_mana);
		end
		return;
	end

	item_lib.return_items(e.self, e.other, e.trade);
end
