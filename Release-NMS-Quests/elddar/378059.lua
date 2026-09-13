-- elddar/378059.lua - Shalowen the Pure
-- Prophecy of Ro: the Tunare's Shrine corruption chain (3376 / 3514 / 3515).
-- Completing all three and the final turn-in yields The Chalice of Life (85670).
local por = require("por_helper");

local function assign_next(c, npc)
	if not c:IsTaskCompleted(por.tasks.investigating_the_elddar) and not c:IsTaskActive(por.tasks.investigating_the_elddar) then
		c:AssignTask(por.tasks.investigating_the_elddar);
		npc:Say("Corruption has taken root among our people. Enter Tunare's Shrine and recover the Figurine of Ro.");
	elseif not c:IsTaskCompleted(por.tasks.questioning_the_priest) and not c:IsTaskActive(por.tasks.questioning_the_priest) then
		c:AssignTask(por.tasks.questioning_the_priest);
		npc:Say("A priest of Ro has turned from the Mother. Question him, and bring me the Sealed Scroll of Ro.");
	elseif not c:IsTaskCompleted(por.tasks.key_to_corruption) and not c:IsTaskActive(por.tasks.key_to_corruption) then
		c:AssignTask(por.tasks.key_to_corruption);
		npc:Say("The Elddar treants guard the last secret. Bring me the Carved Wooden Key.");
	end
end

function event_say(e)
	local t = e.message:lower();
	if t:find("hail") then
		e.self:Say("You walk the Elddar, yet you are not of it. Tunare watches, and she is troubled. Will you help us root out the corruption among our people?");
		assign_next(e.other, e.self);
	elseif t:find("corruption") or t:find("help") or t:find("elddar") then
		assign_next(e.other, e.self);
	elseif t:find("raid") or t:find("priest of ro") or t:find("cleanse") then
		if por.enter(e.other, "elddara", "The Corruption of Ro", 1, 36, "6h", "3d") then
			e.self:Say("The heart of the corruption festers within the shrine. Gather your allies and cleanse it.");
		end
	end
end

function event_trade(e)
	local item_lib = require("items");
	local c = e.other;

	-- Figurine of Ro -> Restored Figurine of Ro
	if item_lib.check_turn_in(e.trade, { item1 = 85076 }) then
		c:UpdateTaskActivity(por.tasks.investigating_the_elddar, 1, 1);
		c:SummonFixedItem(85078); -- Restored Figurine of Ro
		e.self:Say("Tunare's grace flows through this relic once more. Keep it; it may yet matter.");
		return;
	end

	-- Sealed Scroll of Ro
	if item_lib.check_turn_in(e.trade, { item1 = 85080 }) then
		c:UpdateTaskActivity(por.tasks.questioning_the_priest, 1, 1);
		e.self:Say("So the priest was not alone in this. We will not forget what you have done.");
		return;
	end

	-- Carved Wooden Key
	if item_lib.check_turn_in(e.trade, { item1 = 85079 }) then
		c:UpdateTaskActivity(por.tasks.key_to_corruption, 1, 1);
		e.self:Say("The key to the corruption. With this, we can end it.");
		return;
	end

	-- Final turn-in: the restored relic once all is done
	if item_lib.check_turn_in(e.trade, { item1 = 85078 }) then
		if c:IsTaskCompleted(por.tasks.questioning_the_priest) and c:IsTaskCompleted(por.tasks.key_to_corruption) then
			if not c:HasItem(85670) then
				c:SummonFixedItem(85670); -- The Chalice of Life
			end
			e.self:Say("The corruption is cleansed, and the grove is whole. Take the Chalice of Life; it holds the memory of all who tended these woods.");
		else
			c:SummonFixedItem(85078);
			e.self:Say("There is more yet to be done before the grove is whole again.");
		end
		return;
	end

	item_lib.return_items(e.self, e.other, e.trade);
end
