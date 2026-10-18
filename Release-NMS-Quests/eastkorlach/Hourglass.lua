-- eastkorlach/Hourglass.lua
-- Depths of Darkhollow: Hourglass (Undershore) - Ruins of Illsalin tasks.
--   505776 Destroy the Bloodwings   505777 Dredged Drachnids
-- 505777 is completed by combining ten Drachnid Spirits (85563) into a Skull of
-- Spirits (85564) with Hourglass' Voodoo Skull (85562, granted on accept) and
-- handing it in. Tasks/recipes live in
-- utils/sql/20261016_dodh_undershore_missions.sql.
--
-- Trade handling follows the Bellfast pattern: the engine stamps
-- TaskDeliveredCount on accepted items, and this script consumes exactly those
-- units (NPC:CheckHandin) since having an EVENT_TRADE sub opts out of the
-- engine's own consume loop.

local item_lib = require("items");

local TASK_BLOODWINGS = 505776;
local TASK_DRACHNIDS  = 505777;
local VoodooSkull     = 85562;

local TASKS = { TASK_BLOODWINGS, TASK_DRACHNIDS };

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

	if c:IsTaskActive(TASK_DRACHNIDS) and c:GetInventory():HasItem(VoodooSkull) == -1 then
		c:SummonFixedItem(VoodooSkull);
		c:Message(15, "You have received Hourglass' Voodoo Skull.");
	end

	if assigned > 0 then
		e.self:Say("The dead do not rest in the Ruins of Illsalin, and the Bloodwings pick at everything that falls. Break their perch guards and winged watchers, and bring me the spirits of the drowned drachnids - ten of them, bound in the voodoo skull I have given you.");
	else
		e.self:Say("Ten drachnid spirits, bound in the voodoo skull. The Bloodwings will not miss them.");
	end
end

function event_trade(e)
	local consumed = consume_delivered(e);
	if consumed then
		e.self:Say("The spirits settle into the skull. Good. The depths are a little quieter for it.");
	end
	item_lib.return_items(e.self, e.other, e.trade);
end
