-- eastkorlach/#Free_Trader_Arislo.lua
-- Depths of Darkhollow: Free Trader of Malgrinnor collection tasks (Undershore).
--   505772 Arislo's Armor    505773 Arislo's Weapons
--   505774 Arislo's Food     505775 Handy Work
-- Tasks/activities/loot live in utils/sql/20261016_dodh_undershore_missions.sql.
--
-- Trade handling: the task system counts Deliver activities from the trade
-- before the event fires (trading.cpp -> UpdateTasksOnDeliver), stamping each
-- accepted instance's TaskDeliveredCount. Because this NPC has an EVENT_TRADE
-- sub the engine skips its own consume loop, so the script consumes exactly the
-- delivered units (NPC:CheckHandin, required == handin) and returns the rest.
-- Rewards are paid by the task engine itself; nothing is paid here.

local item_lib = require("items");

local TASKS = { 505772, 505773, 505774, 505775 };

local function consume_delivered(e)
	local handin = {};
	local insts = {};

	for i = 1, 4 do
		local inst = e.trade["item" .. i];
		if inst and inst.valid then
			local n = inst:GetTaskDeliveredCount();
			if n and n > 0 then
				local id = tostring(inst:GetID());
				handin[id] = (handin[id] or 0) + n;
				table.insert(insts, inst);
			end
		end
	end

	if next(handin) == nil then
		return false;
	end
	return e.self:CheckHandin(e.other, handin, handin, insts);
end

function event_say(e)
	if not e.message:lower():find("hail") then
		return;
	end
	local c = e.other;
	local assigned = 0;

	for _, id in ipairs(TASKS) do
		if not c:IsTaskActive(id) then
			c:AssignTask(id, e.self:GetID());
			assigned = assigned + 1;
		end
	end

	if assigned > 0 then
		e.self:Say("You look like you can carry a load. The Malgrinnor markets pay for good hides and better meat - splorgath skin, witheran carapace and teeth, a few shiliskin bones and hands, and something to fill a hungry trader's belly. Bring what you find and we will talk trade.");
	else
		e.self:Say("Still working? The bogs will not empty themselves. Hides, teeth, bones, and a Glom or two - that is all I ask.");
	end
end

function event_trade(e)
	local consumed = consume_delivered(e);
	if consumed then
		e.self:Say("Ah, now that is a fair trade. My thanks.");
	end
	item_lib.return_items(e.self, e.other, e.trade);
end
