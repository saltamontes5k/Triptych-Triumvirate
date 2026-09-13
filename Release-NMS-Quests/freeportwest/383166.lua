-- freeportwest/383166.lua - Emissary of Druzzil
-- Prophecy of Ro: begins the Deathknell access chain with a Shard of Mana.
local por = require("por_helper");

local shards = { 84164, 84165, 84167 } -- Shard / Glowing Shard / Black Shard of Mana

function event_say(e)
	local t = e.message:lower();
	if t:find("hail") then
		e.self:Say("The goddess Druzzil Ro has foreseen the devastation of this world, and so she beckons mortals to her Plane of Magic. I have a [proposition] for one such as you.");
	elseif t:find("proposition") then
		e.self:Say("The scrykin of the Plane of Magic are in turmoil, and a corruption spreads from a place of song. Druzzil would see it ended. Carry a shard of her mana and you may be called upon to prove yourself. Are you [interested]?");
	elseif t:find("interested") or t:find("i am interested") then
		local has = false;
		for _, id in ipairs(shards) do
			if e.other:HasItem(id) then has = true; end
		end
		if not has then
			e.other:SummonFixedItem(por.items.shard_of_mana);
			e.self:Say("Then take this Shard of Mana. As you grow nearer to the truth it will change, and when it is black as the void you will know the way to Deathknell is open to you.");
		else
			e.self:Say("You already carry a shard of Druzzil's mana. Guard it well.");
		end
	end
end
