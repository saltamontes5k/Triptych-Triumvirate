-- eastkorlach/Slave_Trader_Bologore.lua
-- Depths of Darkhollow: Slave Trader Bologore (Undershore) task.
--   505781 Harvest of the Deep
-- Collect five Living Nargil Corals (86019) and five Splintered Nargilore
-- Shards (86028) from the nargilor colonies of the Ruins of Illsalin and hand
-- them in. Task/loot live in utils/sql/20261016_dodh_undershore_missions.sql.
--
-- Trade handling follows the Bellfast pattern (see #Free_Trader_Arislo.lua).

local item_lib = require("items");

local TASK_HARVEST = 505781;

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

	if not c:IsTaskActive(TASK_HARVEST) then
		c:AssignTask(TASK_HARVEST, e.self:GetID());
		e.self:Say("The nargilor grows thick in the Ruins of Illsalin, and a trader with an eye for it can make coin from coral. Bring me five living nargil corals and five splintered nargilore shards from the colonies, and I will make it worth your while.");
	else
		e.self:Say("Five living nargil corals and five shards, from the colonies in the ruins. The coral will not harvest itself.");
	end
end

function event_trade(e)
	local consumed = consume_delivered(e);
	if consumed then
		e.self:Say("Fine specimens. The Malgrinnor market thanks you.");
	end
	item_lib.return_items(e.self, e.other, e.trade);
end
