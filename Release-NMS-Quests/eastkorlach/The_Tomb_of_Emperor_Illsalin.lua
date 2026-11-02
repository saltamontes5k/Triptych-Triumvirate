-- eastkorlach/The_Tomb_of_Emperor_Illsalin.lua
-- Depths of Darkhollow: the turn-in target for Vestiges of the Empire (505791).
--
-- The five emperor gemstones (85526-85530) are delivered to this object-npc
-- (362064).  The task system counts the Deliver activities before this event
-- fires (trading.cpp -> UpdateTasksOnDeliver), stamping each accepted
-- instance's TaskDeliveredCount.  Because the Tomb has an EVENT_TRADE sub the
-- engine skips its own consume loop, so the script consumes exactly the
-- delivered units (NPC:CheckHandin, required == handin) and returns the rest.
-- The engine pays the task reward; nothing is paid here.

local item_lib = require("items");

local VESTIGES = 505791;

function event_trade(e)
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

	local consumed = false;
	if next(handin) ~= nil then
		consumed = e.self:CheckHandin(e.other, handin, handin, insts);
	end

	item_lib.return_items(e.self, e.other, e.trade);

	if not consumed then
		return;
	end

	if e.other:IsTaskCompleted(VESTIGES) then
		e.self:Say("The gemstones sink into the ancient stone, and the Shattered Blade is made whole.");
		eq.zone_emote(MT.Yellow, "The Tomb of Emperor Illsalin trembles as the five gemstones are united.");
	else
		e.self:Say("The Tomb drinks the light of the gemstone and falls silent, waiting for the rest.");
	end
end
