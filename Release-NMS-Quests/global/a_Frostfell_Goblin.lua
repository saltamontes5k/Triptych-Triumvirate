-- Frostfell (2006): a_Frostfell_Goblin - shared quest giver for all cities + Plane of Knowledge
-- Resolved globally (quests/global/a_Frostfell_Goblin.lua) for every a_Frostfell_Goblin spawn.
local FF = require("frostfell")

function event_say(e)
	local name = e.other:GetName()
	if e.message:findi("hail") then
		e.self:Say("Happy Frostfell, " .. name .. "! I could use help [searching for clues] or [saving Santug].")
	elseif e.message:findi("searching") or e.message:findi("clue") then
		FF.assign(e.other, FF.TASK.CLUES)
		e.self:Say("Kill a grimp and bring me the five clues. Try the beach near the docks in South Desert of Ro: a Broken Toy, a Snowball with a Rock in It, a Symbol of Innoruuk, a Fragment of a Charm Scroll and Fur from a Mammoth.")
	elseif e.message:findi("saving") or e.message:findi("santug") or e.message:findi("stop him") then
		FF.assign(e.other, FF.TASK.SANTUG)
		e.self:Say("The Grinnuch stole Santug's gifts! Search the northern ruins of Everfrost Peaks and find the hiding Frostfell goblin first.")
	elseif e.message:findi("list") then
		e.self:Say("Santug Claugg keeps Santug's List. Speak with him by the big bank.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	local p = e.other
	-- Searching for Clues: the five clues
	if p:IsTaskActive(FF.TASK.CLUES) and item_lib.check_turn_in(e.trade, {
		{item1 = FF.ITEM.CLUE_BROKEN_TOY},
		{item2 = FF.ITEM.CLUE_SCROLL},
		{item3 = FF.ITEM.CLUE_INNORUUK},
		{item4 = FF.ITEM.CLUE_SNOWBALL},
		{item5 = FF.ITEM.CLUE_FUR},
	}) then
		e.self:Say("You found them all! Here, take these Grimp Scales.")
		p:SummonItem(FF.ITEM.GRIMP_SCALES)
		p:UpdateTaskActivity(FF.TASK.CLUES, 0, 1)
		p:UpdateTaskActivity(FF.TASK.CLUES, 1, 1)
	-- Saving Santug: open a gift, maybe find the sled
	elseif p:IsTaskActive(FF.TASK.SANTUG) and item_lib.check_turn_in(e.trade, {item1 = FF.ITEM.SANTUG_GIFT}) then
		if math.random(3) == 1 then
			e.self:Say("At last, an Ornate Bright Red Sled! Take it to The Grinnuch.")
			p:SummonItem(FF.ITEM.ORNATE_SLED)
		else
			e.self:Say("No sled in this one. Bring me another gift!")
		end
		p:UpdateTaskActivity(FF.TASK.SANTUG, 1, 1)
	-- Santug's List: upgrade the stocking
	elseif item_lib.check_turn_in(e.trade, {item1 = FF.ITEM.STOCKING}) then
		e.self:Say("A Santug's Stocking! Here, take the upgraded stocking.")
		p:SummonItem(87570)
		p:UpdateTaskActivity(FF.TASK.SANTUG, 3, 1)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
