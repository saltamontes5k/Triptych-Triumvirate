-- eastkorlach/Slave_Trader_Zillvinshin.lua
-- Depths of Darkhollow: Slave Trader Zillvinshin (Undershore) tasks.
--   505782 Cleaning the Canals   505783 The Walls of Illsalin
-- 505783 is completed by combining ten Withered Shiliskin Tentacles (85551) into
-- a Tentacle-Laden Trophy Belt (85553) with Zillvinshin's Trophy Belt (85552,
-- granted on accept). Tasks/recipes live in
-- utils/sql/20261016_dodh_undershore_missions.sql.
--
-- Trade handling follows the Bellfast pattern (see #Free_Trader_Arislo.lua).

local item_lib = require("items");

local TASK_CANALS = 505782;
local TASK_WALLS  = 505783;
local TrophyBelt  = 85552;

local TASKS = { TASK_CANALS, TASK_WALLS };

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

	if c:IsTaskActive(TASK_WALLS) and c:GetInventory():HasItem(TrophyBelt) == -1 then
		c:SummonFixedItem(TrophyBelt);
		c:Message(15, "You have received Zillvinshin's Trophy Belt.");
	end

	if assigned > 0 then
		e.self:Say("The canals of the Undershore crawl with things that should not be, and the Illsalin shiliskin press against our walls. Thin the cave fishers, the moccasins and the witherans, and bring me ten withered shiliskin tentacles worked into a trophy belt - I have given you the belt to make it with.");
	else
		e.self:Say("Fishers, moccasins, witherans, and ten tentacles for the belt. The wall does not hold itself.");
	end
end

function event_trade(e)
	local consumed = consume_delivered(e);
	if consumed then
		e.self:Say("Ha! A trophy worthy of the wall. My thanks.");
	end
	item_lib.return_items(e.self, e.other, e.trade);
end
