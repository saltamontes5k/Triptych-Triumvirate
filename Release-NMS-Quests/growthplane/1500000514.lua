-- growthplane/1500000514.lua - Dryad of Tunare
-- Prophecy of Ro: reward for "Tree Heaven". Melee/hybrid get the Belt of the
-- Rainmakers (39691); casters/priests get the Crimson Cloak of Moonwaters (39692).
local por = require("por_helper");

local melee = {
	[Class.WARRIOR] = true, [Class.PALADIN] = true, [Class.RANGER] = true,
	[Class.SHADOWKNIGHT] = true, [Class.MONK] = true, [Class.BARD] = true,
	[Class.ROGUE] = true, [Class.BEASTLORD] = true, [Class.BERSERKER] = true,
}

function event_say(e)
	local t = e.message:lower();
	if t:find("hail") then
		e.self:Say("These are sacred groves, traveler. What brings you so high into the Tree of Tunare?");
	end
end

function event_trade(e)
	local item_lib = require("items");
	local c = e.other;

	if item_lib.check_turn_in(e.trade, { item1 = 85645 }) then
		e.self:Say("What are these? By Tunare! The spirits of the ancient grove have returned at last. Bless you, traveler.");
		for class_id = 1, 16 do
			if c:HasClassID(class_id) then
				if melee[class_id] then
					if not c:HasItem(39691) then c:SummonFixedItem(39691) end
				else
					if not c:HasItem(39692) then c:SummonFixedItem(39692) end
				end
			end
		end
		return;
	end

	item_lib.return_items(e.self, e.other, e.trade);
end
