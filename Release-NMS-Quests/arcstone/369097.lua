-- arcstone/369097.lua - Apprentice Mage Sarcrynn
-- Prophecy of Ro: "Black Orb of the Scrykin" (3423). Collect the thirteen elder
-- scrykin orbs and forge the Black Orb of Scrykin.
local por = require("por_helper");

local orbs = {
	85622, 85623, 85624, 85625, 85626, 85627, 85628,
	85629, 85630, 85631, 85632, 85633, 85634,
}

function event_say(e)
	local t = e.message:lower();
	if t:find("hail") then
		e.self:Say("The elder scrykin are the most powerful of my kind, and the most mad. Each carries a black orb at the core of their being. Bring me all thirteen, and I can forge something far greater.");
		if not e.other:IsTaskActive(por.tasks.black_orb_of_the_scrykin) and not e.other:IsTaskCompleted(por.tasks.black_orb_of_the_scrykin) then
			e.other:AssignTask(por.tasks.black_orb_of_the_scrykin);
		end
	elseif t:find("orb") then
		e.self:Say("Thirteen orbs, one from each of the elder scrykin. The named of Relic and the depths of Skylance hold most of them.");
	end
end

function event_trade(e)
	local item_lib = require("items");
	local c = e.other;

	for _, id in ipairs(orbs) do
		if item_lib.check_turn_in(e.trade, { item1 = id }) then
			c:SetBucket("por.orb." .. id, "1");
			local n = 0;
			for _, oid in ipairs(orbs) do
				if (tonumber(c:GetBucket("por.orb." .. oid)) or 0) == 1 then
					n = n + 1;
				end
			end
			e.self:Say(string.format("An orb! I now hold %d of the thirteen.", n));
			if n >= 13 and not c:HasItem(85667) then
				c:SummonFixedItem(85667); -- Black Orb of Scrykin
				e.self:Say("All thirteen! By Druzzil, it is complete. The Black Orb of the Scrykin is yours.");
			end
			return;
		end
	end

	item_lib.return_items(e.self, e.other, e.trade);
end
