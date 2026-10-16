-- corathus/#Bellfast.lua
-- Depths of Darkhollow: Bellfast's clockwork collection chain (Corathus Creep).
--   505755  Parts for Bellfast                 -> Scrindite's Mechanoinstruction Manual (33295)
--   505763  Parts for Bellfast (research)      -> same manual, made by the player
--   505756  Scrindite's Senescent Scribbles    -> 33313
--   505757  Poxysmit's Precipitous Parts       -> 33312
--   505758  Epicthieck's Edification Edition   -> 33314
--   505759  Ambleshift's Anfractuous Album     -> 33311
-- Tasks live in utils/sql/20261013_dodh_corathus_chain.sql; 505756-505759
-- require either Parts variant done. 505763 goes to ENC/MAG/NEC/WIZ: they buy
-- the Spell Research Kit from CGXIV, combine the ten Mechanoinstruction Scraps
-- into three Tattered Mechanoinstructions (33296-33298), and trade them for
-- Pages 2-4; the gear delivery pays Page 5; recipe 938039 combines the five
-- pages into the manual. Page 1 is granted on task accept.
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
local TASK_PARTS_RESEARCH = 505763;

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

-- Research classes take the spell-research variant of Parts for Bellfast.
local RESEARCH_CLASSES = { [12] = true, [13] = true, [14] = true, [15] = true }; -- ENC MAG NEC WIZ

local PAGE_ONE = 33306; -- granted on research-task accept

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

-- Research-variant deliverables: tattered -> Pages 2-4, gears -> Page 5.
local ID_TASK_RESEARCH = {
	[33296] = { TASK_PARTS_RESEARCH, 3 },
	[33297] = { TASK_PARTS_RESEARCH, 5 },
	[33298] = { TASK_PARTS_RESEARCH, 7 },
	[32684] = { TASK_PARTS_RESEARCH, 10 },
	[32683] = { TASK_PARTS_RESEARCH, 11 },
};

-- Page paid when the matching research piece is delivered.
local PAGE = {
	[33296] = 33307, -- Page 2
	[33297] = 33308, -- Page 3
	[33298] = 33309, -- Page 4
	[32683] = 33310, -- Page 5
};

local PAGE_NAMES = {
	[33307] = "Scrindite's Mechanoinstruction Manual Page 2",
	[33308] = "Scrindite's Mechanoinstruction Manual Page 3",
	[33309] = "Scrindite's Mechanoinstruction Manual Page 4",
	[33310] = "Scrindite's Mechanoinstruction Manual Page 5",
};

-- The (task, activity) a delivered item counts for, if the client holds that
-- task (a player only ever carries one Parts variant). Pinions and gears are
-- deliverables of BOTH variants, so both maps have to be checked.
local function ref_for(e, id)
	local refs = { ID_TASK[id], ID_TASK_RESEARCH[id] };
	for _, ref in ipairs(refs) do
		if ref then
			local task_id = ref[1];
			if e.other:IsTaskCompleted(task_id) or e.other:IsTaskActivityActive(task_id, ref[2]) or e.other:IsTaskActive(task_id) then
				return ref;
			end
		end
	end
	return nil;
end

-- Consume exactly the units the task system accepted from this trade. A slot's
-- units are kept when the owning task is active or completed (the latter also
-- covers the trade that finished the final activity). Returns units kept and
-- the set of accepted item ids.
local function consume_delivered(e)
	local handin = {};
	local accepted = {};
	local insts = {};
	local kept = 0;

	for i = 1, 4 do
		local inst = e.trade["item" .. i];
		if inst and inst.valid then
			table.insert(insts, inst);
			local n = inst:GetTaskDeliveredCount();
			local ref = n and n > 0 and ref_for(e, inst:GetID()) or nil;
			if ref then
				local id = inst:GetID();
				handin[tostring(id)] = (handin[tostring(id)] or 0) + n;
				accepted[tostring(id)] = true;
				kept = kept + n;
			end
		end
	end

	if next(handin) == nil then
		return 0, accepted;
	end

	-- required == handin consumes exactly the delivered quantities; anything
	-- else in the trade stays unflagged for ReturnHandinItems.
	local ok = e.self:CheckHandin(e.other, handin, handin, insts);
	if not ok then
		return 0, accepted;
	end
	return kept, accepted;
end

-- Research variant: Bellfast trades the missing pages for research pieces.
local function pay_research_pages(e, accepted)
	if not (e.other:IsTaskActive(TASK_PARTS_RESEARCH) or e.other:IsTaskCompleted(TASK_PARTS_RESEARCH)) then
		return;
	end
	for id, page_id in pairs(PAGE) do
		if accepted[tostring(id)] and not e.other:HasItem(page_id) then
			e.other:SummonFixedItem(page_id);
			e.other:Message(15, "You have received " .. PAGE_NAMES[page_id] .. ".");
		end
	end
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

-- Either Parts variant unlocks the four book tasks.
local function parts_done(c)
	return c:IsTaskCompleted(TASK_PARTS) or c:IsTaskCompleted(TASK_PARTS_RESEARCH);
end

function event_say(e)
	if not e.message:lower():find("hail") then
		return;
	end
	local c = e.other;
	local part_task = RESEARCH_CLASSES[c:GetClass()] and TASK_PARTS_RESEARCH or TASK_PARTS;

	if not c:IsTaskActive(part_task) and not c:IsTaskCompleted(part_task) then
		c:AssignTask(part_task, e.self:GetID());
		if part_task == TASK_PARTS_RESEARCH then
			if not c:HasItem(PAGE_ONE) then
				c:SummonFixedItem(PAGE_ONE);
			end
			c:Message(15, "You have received Scrindite's Mechanoinstruction Manual Page 1.");
			e.self:Say("Bellfast's the name, repairs the trade - and you have a researcher's hands. Scrindite's Mechanoinstruction Manual wants restoring the scholar's way. There is Page 1. Buy a Spell Research Kit from Merchant Model CGXIV, combine the Mechanoinstruction Scraps you gather into Tattered Mechanoinstructions, and bring them to me - I will trade you the missing pages. Finish with five Clockwork Pinion Gears and two Clockwork Gears.");
		else
			e.self:Say("Bellfast's the name, repairs the trade. The clockworks that drag Expedition 328 about do not fix themselves. First, find Merchant Model CGXIV among the camp - the little merchant knows my list. Then bring me ten different Mechanoinstruction Scraps, five Clockwork Pinion Gears, and two Clockwork Gears. Do that and I will see about a manual.");
		end
		return;
	end

	if parts_done(c) then
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

	if c:IsTaskActive(TASK_PARTS_RESEARCH) then
		e.self:Say("Kit from CGXIV, Tattered Mechanoinstructions from the scraps, then five Clockwork Pinion Gears and two Clockwork Gears. Scrindite's pages will not write themselves.");
	else
		e.self:Say("Scraps, gears, pinions - the parts will not gather themselves. Ten different Mechanoinstruction Scraps, five Clockwork Pinion Gears, two Clockwork Gears. Hop to it.");
	end
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

	local kept, accepted = consume_delivered(e);

	if kept > 0 then
		pay_research_pages(e, accepted);
		e.self:Say(kept > 1 and (kept .. " pieces accepted - every one a gear tooth closer to a working arm.") or "A fine piece - accepted.");
		pay_completed(e);
	elseif had_items then
		e.self:Say("I have no use for that. Bring me scraps and gears, or the book parts I asked for.");
	end

	item_lib.return_items(e.self, e.other, e.trade);
end
