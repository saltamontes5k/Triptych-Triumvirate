-- eastkorlach/Zahn.lua
-- Depths of Darkhollow: Zahn (Undershore) tasks.
--   505784 Shilgrave Vengeance - hand in twelve Malgrin Legion Shields (85536).
--   505793 Deserting the Ranks  - the Nargilor Pits mission (illsalinc v1).
-- Task/loot live in utils/sql/20261016_dodh_undershore_missions.sql (505784)
-- and utils/sql/20261016_dodh_illsalinc_deserting.sql (505793).
--
-- Trade handling follows the Bellfast pattern (see #Free_Trader_Arislo.lua):
-- the task system stamps TaskDeliveredCount before this event fires, and the
-- script consumes exactly the delivered units.

local item_lib = require("items");

local TASK_VENGEANCE = 505784;
local TASK_DESERTING = 505793;
local SHOULDER_GUARD = 86018;

local deserting = {
	expedition = { name = "The Nargilor Pits: Deserting the Ranks", min_players = 1, max_players = 6 },
	instance   = { zone = "illsalinc", version = 1, duration = eq.seconds("6h") },
	compass    = { zone = "eastkorlach", x = 726, y = -573, z = -12 },
	safereturn = { zone = "eastkorlach", x = 726, y = -573, z = -12, h = 0 },
	zonein     = { x = -6, y = -664, z = -111, h = 0 },
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

local function enter_pits(e)
	local c = e.other;
	local dz = c:GetExpedition();
	if not (dz.valid and dz:GetName() == deserting.expedition.name) then
		if not c:IsTaskActive(TASK_DESERTING) then
			c:AssignTask(TASK_DESERTING, e.self:GetID());
			c:SummonFixedItem(SHOULDER_GUARD);
		end
		dz = c:CreateExpedition(deserting);
	end
	if dz.valid then
		local zi = deserting.zonein;
		c:MovePCInstance(dz:GetZoneID(), dz:GetInstanceID(), zi.x, zi.y, zi.z, zi.h or 0);
	else
		c:Message(MT.Red, "The way into the Nargilor Pits will not open just now.");
	end
end

function event_say(e)
	local msg = e.message:lower();
	local c = e.other;

	if msg:find("desert") or msg:find("ranks") then
		e.self:Say("So you would turn the Legion's own dead against them. Take this Heirloom Shoulder Guard and seek the Nargilor Pits beneath Illsalin. Recover the Carved Nargil Triangle, put the Guardian of the Pit down, and break the Shilgrave Captain. Say [" .. eq.say_link("enter") .. "] when you are ready to descend.");
	elseif msg:find("enter") and c:IsTaskActive(TASK_DESERTING) then
		enter_pits(e);
	elseif msg:find("hail") then
		if not c:IsTaskActive(TASK_VENGEANCE) then
			c:AssignTask(TASK_VENGEANCE, e.self:GetID());
			e.self:Say("The Malgrin Legion holds the Undershore, and I owe them a debt I intend to collect. Their soldiers and sergeants carry shields bearing the Legion's mark - bring me twelve of them and their strength bleeds. Do this for me.");
		else
			e.self:Say("Twelve Malgrin Legion Shields. Every one is a blow struck against the Legion.");
		end
		e.self:Say("And when you tire of shields, ask me of the [ranks] I would see desert Emperor Draygun.");
	end
end

function event_trade(e)
	local consumed = consume_delivered(e);
	if consumed then
		e.self:Say("The Legion feels this. You have my gratitude.");
	end
	item_lib.return_items(e.self, e.other, e.trade);
end
