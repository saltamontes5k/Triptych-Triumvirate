-- corathus/#Bellfast.lua
-- Depths of Darkhollow: Bellfast's clockwork collection chain (Corathus Creep).
--   505755  Parts for Bellfast                 -> Scrindite's Mechanoinstruction Manual (33295)
--   505756  Scrindite's Senescent Scribbles    -> 33313
--   505757  Poxysmit's Precipitous Parts       -> 33312
--   505758  Epicthieck's Edification Edition   -> 33314
--   505759  Ambleshift's Anfractuous Album     -> 33311
-- Tasks live in quests/dodh_errands.sql; 505756-505759 require 505755 done.
--
-- Trade handling: the task system counts Deliver activities from the trade
-- before event_trade fires (trading.cpp -> UpdateTasksOnDeliver), stamping each
-- matched instance's TaskDeliveredCount with the count actually applied. Each
-- accepted item id is mapped to (task, activity); its delivered units are
-- consumed via NPC:CheckHandin (required == handin) when the owning task is
-- active or completed, everything else is returned, and finished tasks pay
-- their reward item once (bucket-guarded).

local item_lib = require("items");

local TASK_PARTS = 505755;

local TASKS = { 505756, 505757, 505758, 505759 };

local REWARDS = {
	[TASK_PARTS] = 33295, -- Scrindite's Mechanoinstruction Manual
	[505756]     = 33313, -- Scrindite's Senescent Scribbles
	[505757]     = 33312, -- Poxysmit's Precipitous Parts
	[505758]     = 33314, -- Epicthieck's Edification Edition
	[505759]     = 33311, -- Ambleshift's Anfractuous Album
};

local REWARD_NAMES = {
	[TASK_PARTS] = "Scrindite's Mechanoinstruction Manual",
	[505756]     = "Scrindite's Senescent Scribbles",
	[505757]     = "Poxysmit's Precipitous Parts",
	[505758]     = "Epicthieck's Edification Edition",
	[505759]     = "Ambleshift's Anfractuous Album",
};

-- item id -> { task, activity } for every accepted collectible.
local ID_TASK = {
	-- Parts for Bellfast: scraps (activity 2), pinions (3), gears (4)
	[32731] = { TASK_PARTS, 2 }, [32732] = { TASK_PARTS, 2 }, [32733] = { TASK_PARTS, 2 },
	[32734] = { TASK_PARTS, 2 }, [32735] = { TASK_PARTS, 2 }, [32736] = { TASK_PARTS, 2 },
	[32737] = { TASK_PARTS, 2 }, [32738] = { TASK_PARTS, 2 }, [32739] = { TASK_PARTS, 2 },
	[32740] = { TASK_PARTS, 2 },
	[32684] = { TASK_PARTS, 3 },
	[32683] = { TASK_PARTS, 4 },
	-- Scrindite's Senescent Scribbles
	[32628] = { 505756, 0 }, [32626] = { 505756, 1 }, [32629] = { 505756, 2 }, [32627] = { 505756, 3 },
	-- Poxysmit's Precipitous Parts
	[32633] = { 505757, 0 }, [32631] = { 505757, 1 }, [32634] = { 505757, 2 }, [32632] = { 505757, 3 },
	-- Epicthieck's Edification Edition
	[32613] = { 505758, 0 }, [32621] = { 505758, 1 }, [32652] = { 505758, 2 },
	[32651] = { 505758, 3 }, [32653] = { 505758, 4 }, [32654] = { 505758, 5 },
	[32676] = { 505758, 6 }, [32689] = { 505758, 7 },
	-- Ambleshift's Anfractuous Album
	[32606] = { 505759, 0 }, [32607] = { 505759, 1 }, [32622] = { 505759, 2 }, [32623] = { 505759, 3 },
};

-- Consume exactly the units the task system accepted from this trade. A slot's
-- units are kept when the owning task is active or completed (the latter also
-- covers the trade that finished the final activity). Returns units kept.
local function consume_delivered(e)
	local handin = {};
	local insts = {};
	local kept = 0;

	for i = 1, 4 do
		local inst = e.trade["item" .. i];
		if inst and inst.valid then
			table.insert(insts, inst);
			local n = inst:GetTaskDeliveredCount();
			local ref = n and n > 0 and ID_TASK[inst:GetID()] or nil;
			if ref then
				local task_id, activity_id = ref[1], ref[2];
				local task_done = e.other:IsTaskCompleted(task_id);
				if task_done or e.other:IsTaskActivityActive(task_id, activity_id) or e.other:IsTaskActive(task_id) then
					local id = inst:GetID();
					handin[tostring(id)] = (handin[tostring(id)] or 0) + n;
					kept = kept + n;
				end
			end
		end
	end

	if next(handin) == nil then
		return 0;
	end

	-- required == handin consumes exactly the delivered quantities; anything
	-- else in the trade stays unflagged for ReturnHandinItems.
	local ok = e.self:CheckHandin(e.other, handin, handin, insts);
	if not ok then
		return 0;
	end
	return kept;
end

local function pay_completed(e)
	local paid = false;
	for task_id, item_id in pairs(REWARDS) do
		if e.other:IsTaskCompleted(task_id) then
			local flag = "dodh.reward." .. tostring(task_id);
			if (tonumber(e.other:GetBucket(flag)) or 0) == 0 then
				e.other:SetBucket(flag, "1");
				if not e.other:HasItem(item_id) then
					e.other:SummonFixedItem(item_id);
				end
				e.other:Message(15, "You have received " .. REWARD_NAMES[task_id] .. ".");
				paid = true;
			end
		end
	end
	return paid;
end

function event_say(e)
	if not e.message:lower():find("hail") then
		return;
	end
	local c = e.other;

	if not c:IsTaskActive(TASK_PARTS) and not c:IsTaskCompleted(TASK_PARTS) then
		c:AssignTask(TASK_PARTS, e.self:GetID());
		e.self:Say("Bellfast's the name, repairs the trade. The clockworks that drag Expedition 328 about do not fix themselves. First, find Merchant Model CGXIV among the camp - the little merchant knows my list. Then bring me ten different Mechanoinstruction Scraps, five Clockwork Pinion Gears, and two Clockwork Gears. Do that and I will see about a manual.");
		return;
	end

	if c:IsTaskCompleted(TASK_PARTS) then
		local offered = 0;
		for _, id in ipairs(TASKS) do
			if not c:IsTaskActive(id) and not c:IsTaskCompleted(id) then
				c:AssignTask(id, e.self:GetID());
				offered = offered + 1;
			end
		end
		if offered > 0 then
			e.self:Say("The manual, yes? Scrindite left more than one book to rot down here. Ragepaw and shadowmane parts, curiosities from every corner of the Deep, drachnid and gargoyle bits from up in Dreadspire. Four books, four sets of parts - bring them and I will restore every page.");
		else
			e.self:Say("Every page restored. Scrindite, Poxysmit, Epicthieck, Ambleshift - they would have liked you, I think. Or tried to eat you. Hard to say.");
		end
		return;
	end

	e.self:Say("Scraps, gears, pinions - the parts will not gather themselves. Ten different Mechanoinstruction Scraps, five Clockwork Pinion Gears, two Clockwork Gears. Hop to it.");
end

function event_trade(e)
	local had_items = false;
	for i = 1, 4 do
		local inst = e.trade["item" .. i];
		if inst and inst.valid then
			had_items = true;
			break;
		end
	end

	local kept = consume_delivered(e);

	if kept > 0 then
		e.self:Say(kept > 1 and (kept .. " pieces accepted - every one a gear tooth closer to a working arm.") or "A fine piece - accepted.");
		pay_completed(e);
	elseif had_items then
		e.self:Say("I have no use for that. Bring me scraps and gears, or the book parts I asked for.");
	end

	item_lib.return_items(e.self, e.other, e.trade);
end
