-- Frostfell (2006): a hiding Frostfell goblin - Saving Santug
local FF = require("frostfell")

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Psst! Happy Frostfell. Will you help me [save Santug]?")
	elseif e.message:findi("save santug") or e.message:findi("help") or e.message:findi("stop him") then
		FF.assign(e.other, FF.TASK.SANTUG)
		e.self:Say("The Grinnuch stole Santug's gifts! Bring me Santug's Gift and I will search it for an Ornate Bright Red Sled.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if e.other:IsTaskActive(FF.TASK.SANTUG) then
		if item_lib.check_turn_in(e.trade, {item1 = FF.ITEM.SANTUG_GIFT}) then
			if math.random(3) == 1 then
				e.self:Say("At last, an Ornate Bright Red Sled! Take it to The Grinnuch.")
				e.other:SummonItem(FF.ITEM.ORNATE_SLED)
			else
				e.self:Say("No sled in this one. Bring me another gift!")
			end
			FF.upd(e.other, FF.TASK.SANTUG, 1, 1)
		elseif item_lib.check_turn_in(e.trade, {item1 = FF.ITEM.STOCKING}) then
			e.self:Say("A Santug's Stocking! Here, take the upgraded stocking.")
			e.other:SummonItem(87570)
			FF.upd(e.other, FF.TASK.SANTUG, 3, 1)
		end
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
