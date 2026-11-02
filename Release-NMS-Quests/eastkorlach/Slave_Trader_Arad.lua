-- eastkorlach/Slave_Trader_Arad.lua
-- Depths of Darkhollow: Slave Trader Arad (Undershore) tasks.
--   505778 A Traitor's Fate   505779 Veruzan   505780 The Coral Bogs
-- 505778 is completed by combining ten Deep Orc Heads (85548) into a Totem of
-- Impaled Orc Heads (85549) with Arad's Spear (85550, granted on accept).
-- Tasks/recipes live in utils/sql/20261016_dodh_undershore_missions.sql.
--
-- Trade handling follows the Bellfast pattern (see #Free_Trader_Arislo.lua).

local item_lib = require("items");

local TASK_TRAITOR = 505778;
local TASK_VERUZAN = 505779;
local TASK_CORAL   = 505780;
local AradsSpear   = 85550;

local TASKS = { TASK_TRAITOR, TASK_VERUZAN, TASK_CORAL };

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

	if c:IsTaskActive(TASK_TRAITOR) and c:GetInventory():HasItem(AradsSpear) == -1 then
		c:SummonFixedItem(AradsSpear);
		c:Message(15, "You have received Arad's Spear.");
	end

	if assigned > 0 then
		e.self:Say("Work, then. The Deep Orcs of the Hive betrayed us - bring me their heads, ten of them, and my spear will make a totem of them. Then there is Veruzan in Stoneroot, a great beast - slay it and bring me its paws. And the coral bogs are thick with nargilor; I need four brittle cores and four glowing.");
	else
		e.self:Say("Orc heads, Veruzan's paws, nargilor cores - I am still waiting on all of it.");
	end
end

function event_trade(e)
	local consumed = consume_delivered(e);
	if consumed then
		e.self:Say("The Malgrinnor trade will remember this. Well done.");
	end
	item_lib.return_items(e.self, e.other, e.trade);
end
