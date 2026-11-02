-- westkorlach/#Researcher_Briznek.lua
-- Depths of Darkhollow: Researcher Briznek (Stoneroot Falls) offers five
-- open-world collection tasks.  Tell him "I am willing to help you", then name
-- the subject of the task you want.
--   505785 Basilisks      505786 Shiliskins   505787 Snakes
--   505788 Witherans      505789 The Search for Savil
-- Tasks/recipe live in utils/sql/20261016_dodh_stoneroot_briznek.sql.
--
-- The four kill/loot tasks are finished by trading the collected components
-- back to Briznek.  "The Search for Savil" hands out Assistant Savil's Empty
-- Field Book (85051); the ten page items are granted by westkorlach/player.lua
-- as each proximity update completes.
--
-- Trade handling follows the Bellfast pattern (see eastkorlach/#Free_Trader_Arislo.lua).

local item_lib = require("items");

local TASK_BASILISK  = 505785;
local TASK_SHILISKIN = 505786;
local TASK_SNAKE     = 505787;
local TASK_WITHERAN  = 505788;
local TASK_SAVIL     = 505789;

local EMPTY_FIELD_BOOK = 85051;

local function offer(e, task_id, line)
	local c = e.other;
	if c:IsTaskActive(task_id) then
		e.self:Say("You are already at work on that - finish it and bring me what I asked for.");
		return;
	end
	c:AssignTask(task_id, e.self:GetID());
	e.self:Say(line);
	if task_id == TASK_SAVIL and c:GetInventory():HasItem(EMPTY_FIELD_BOOK) == -1 then
		c:SummonFixedItem(EMPTY_FIELD_BOOK);
		c:Message(15, "You have received Assistant Savil's Empty Field Book.");
	end
end

function event_say(e)
	local msg = e.message:lower();

	if msg:find("hail") or msg:find("willing") or msg:find("help") then
		e.self:Say("Ah, an adventurer. I am compiling a natural history of Stoneroot Falls, and my notes are woefully incomplete. Are you willing to help? Ask me about the basilisks, the shiliskins, the snakes, the witherans, or the search for Savil.");
		return;
	end

	if msg:find("basilisk") then
		offer(e, TASK_BASILISK, "The basilisks lair on the isle where Grokui slumbers. Slay twenty-five of them and bring me four of their cracked tails.");
	elseif msg:find("shiliskin") then
		offer(e, TASK_SHILISKIN, "The Xillsfar shiliskin infest the city of Xill. Thin them out and bring me four damaged bone chips.");
	elseif msg:find("snake") then
		offer(e, TASK_SNAKE, "The redbacks nest on the high pillars. Climb up, kill twenty of the females, and bring me four decent skins.");
	elseif msg:find("witheran") then
		offer(e, TASK_WITHERAN, "The witherans wander these rocks. Kill thirty of the brutes and bring me four aged glands.");
	elseif msg:find("savil") then
		offer(e, TASK_SAVIL, "My assistant Savil vanished while surveying the falls. I have marked the places he meant to visit - go there, recover his scattered pages, and bind them into his field book.");
	end
end

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

	if next(handin) ~= nil then
		if e.self:CheckHandin(e.other, handin, handin, insts) then
			e.self:Say("Splendid. This will do nicely for my records.");
		end
	end

	item_lib.return_items(e.self, e.other, e.trade);
end
