-- corathus/Tisthal_Gimblecranz.lua
-- Depths of Darkhollow: "Spies Like Them" (mission 08, task 505794).
--
-- Tisthal sends you after Geeble Tripcrank in the Hive, then into the Coven of
-- Skinwalkers instance (drachnidhive version 6) to break the spy ring, then
-- takes the Unreadable Book (84057) for the lore.
-- Task / instance / loot: utils/sql/20261016_dodh_drachnidhive_spies.sql

local item_lib = require("items");

local TASK_SPIES = 505794;
local BOOK = 84057;

local spies = {
	expedition = { name = "The Hive: Coven of Skinwalkers", min_players = 1, max_players = 6 },
	instance   = { zone = "drachnidhive", version = 6, duration = eq.seconds("6h") },
	compass    = { zone = "corathus", x = 289, y = -873, z = -47 },
	safereturn = { zone = "corathus", x = 289, y = -873, z = -47, h = 0 },
	zonein     = { x = 500, y = -400, z = 90, h = 0 },
};

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

local function enter_coven(e)
	local c = e.other;
	local dz = c:GetExpedition();
	if not (dz.valid and dz:GetName() == spies.expedition.name) then
		if not c:IsTaskActive(TASK_SPIES) then
			c:AssignTask(TASK_SPIES, e.self:GetID());
		end
		dz = c:CreateExpedition(spies);
	end
	if dz.valid then
		local zi = spies.zonein;
		c:MovePCInstance(dz:GetZoneID(), dz:GetInstanceID(), zi.x, zi.y, zi.z, zi.h or 0);
	else
		c:Message(MT.Red, "The Coven of Skinwalkers will not open to you just now.");
	end
end

function event_say(e)
	local msg = e.message:lower();
	local c = e.other;

	if msg:find("spies") or msg:find("geeble") or msg:find("skinwalker") or msg:find("mission") then
		e.self:Say("Geeble Tripcrank - that turncoat - has been trading secrets with the skinwalkers. His Unreadable Book lies with him in the eastern tower of the Hive. Bring it to me, and I will read what he dared not. Say [" .. eq.say_link("enter") .. "] and I will open the Coven of Skinwalkers for you.");
	elseif msg:find("enter") and c:IsTaskActive(TASK_SPIES) then
		enter_coven(e);
	elseif msg:find("hail") then
		if c:IsTaskCompleted(TASK_SPIES) then
			e.self:Say("The skinwalkers' schemes are undone. Corathus owes you its silence.");
		elseif c:IsTaskActive(TASK_SPIES) then
			e.self:Say("The eastern tower of the Hive. Geeble's Unreadable Book. And then the Coven of Skinwalkers. Say [" .. eq.say_link("enter") .. "] when you would go below.");
		else
			e.self:Say("The skinwalkers have spies in the Hive, and I mean to root them out. Will you help me, " .. c:GetName() .. "? Ask about the [spies].");
		end
	end
end

function event_trade(e)
	local consumed = consume_delivered(e);
	if consumed then
		e.self:Say("This book... Geeble sold us all. You have my thanks, and Corathus's.");
	end
	item_lib.return_items(e.self, e.other, e.trade);
end
