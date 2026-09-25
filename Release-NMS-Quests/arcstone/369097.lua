-- arcstone/369097.lua - Apprentice Mage Sarcrynn
-- Prophecy of Ro:
--   "Black Orb of the Scrykin" (3423): collect the thirteen elder scrykin orbs.
--   "Entrance to Daosheen's Chamber" (3379): take the four chamber-key
--   components and weaken the seal on Daosheen's chamber. Or`Sarro the Youngest
--   (arcstone/369085.lua) awards the Crystals of the Firstborn and opens the raid.
local por = require("por_helper");

local orbs = {
	85622, 85623, 85624, 85625, 85626, 85627, 85628,
	85629, 85630, 85631, 85632, 85633, 85634,
}

-- The four "Entrance to Daosheen's Chamber" components (task 3379 activities 0-3).
local key_items = {
	[85646] = true, -- Dragon Tooth of Shar`Drahn
	[85647] = true, -- Dragon Tooth of Tsikut
	[85648] = true, -- Dragon Tooth of Ashenback
	[85649] = true, -- Fragment of Porthio`s Shadow Staff
}

local function por_trade(e, item_lib)
	local c = e.other;

	-- The deliver activities auto-advance in the task system; consume the item
	-- here so it is not handed back.
	if c:IsTaskActive(por.tasks.entrance_to_daosheen_chamber) then
		for item_id in pairs(key_items) do
			if item_lib.check_turn_in(e.trade, { item1 = item_id }) then
				e.self:Say("A piece of the seal. Bring me all four and I can weaken Daosheen's protection. When it is done, seek Or`Sarro the Youngest at the Relic zone line.");
				return true;
			end
		end
	end

	return false;
end

function event_say(e)
	local t = e.message:lower();
	if t:find("hail") then
		e.self:Say("All day long Ao has us wandering this blasted slope, hunting for spell components. He claims it is part of our training before we can become true mages of Relic. Bah, I think he just wants to keep us busy while he studies the [real magic].");
		if not e.other:IsTaskActive(por.tasks.black_orb_of_the_scrykin) and not e.other:IsTaskCompleted(por.tasks.black_orb_of_the_scrykin) then
			e.other:AssignTask(por.tasks.black_orb_of_the_scrykin);
		end
	elseif t:find("real magic") then
		e.self:Say("Ah, you want to know the true power of the Plane of Magic? Draw closer, and speak in hushed voices. I have overheard the Elder Scrykin. Daosheen the Firstborn keeps the greatest secrets locked within Skylance, but the seal on his chamber can be weakened. Bring me the remains of his lieutenants: the Dragon Teeth of Shar`Drahn, Tsikut, and Ashenback, and a Fragment of Porthio`s Shadow Staff.");
		if not e.other:IsTaskActive(por.tasks.entrance_to_daosheen_chamber) and not e.other:IsTaskCompleted(por.tasks.entrance_to_daosheen_chamber) then
			e.other:AssignTask(por.tasks.entrance_to_daosheen_chamber);
		end
	elseif t:find("orb") then
		e.self:Say("Thirteen orbs, one from each of the elder scrykin. The named of Relic and the depths of Skylance hold most of them.");
	end
end

function event_trade(e)
	local item_lib = require("items");
	local c = e.other;

	if por_trade(e, item_lib) then
		return;
	end

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
