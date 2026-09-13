-- arcstone/369005.lua - Lady Usher
-- Prophecy of Ro: Spirit Mark Armor (quest 3375). Hand her a Spirit Mark and the
-- matching Crafting Mold (which she sells) to receive the class-appropriate piece.
local por = require("por_helper");

function event_say(e)
	local t = e.message:lower();
	if t:find("hail") then
		e.self:Say("Greetings, " .. e.other:GetName() .. ". You arrived here unannounced, as though carried in by the wind! At first I thought you were one of the spirits of this isle. Now that I see you up close, I realize you are solid and not [clouded] at the edges like they are.");
	elseif t:find("clouded") then
		e.self:Say("Yes, clouded. It is difficult to explain and almost impossible to see, unless you know how to look without expectation. Essentially the spirits of this isle adopt physical bodies, but these [bodies] are transient, existing for moments at a time.");
	elseif t:find("bodies") then
		e.self:Say("When a spirit leaves its adopted body, it often leaves behind a spirit mark, in the same way we leave behind footprints. I've been studying these spirit marks since I arrived here. They can be used to forge powerful [armor].");
	elseif t:find("armor") then
		e.self:Say("I can help you create a suit of spirit-forged armor. Gather the seven Spirit Marks from the named spirits of this isle, buy a Crafting Mold for each slot from me, and hand each mark to me with its matching mold.");
	end
end

function event_trade(e)
	local item_lib = require("items");
	local c = e.other;

	for mark_id, slot in pairs(por.spirit_mark_slot) do
		for mold_id, mold_slot in pairs(por.spirit_mold_slot) do
			if mold_slot == slot and item_lib.check_turn_in(e.trade, { item1 = mark_id, item2 = mold_id }) then
				local n = por.grant_spirit_piece(c, slot);
				if n > 0 then
					e.self:Say("The spirits answer your call. Wear this piece well; it carries a shard of the isle itself.");
				else
					e.self:Say("The spirits find no affinity with your kind. I can do nothing with this.");
					c:SummonFixedItem(mark_id);
					c:SummonFixedItem(mold_id);
				end
				return;
			end
		end
	end

	item_lib.return_items(e.self, e.other, e.trade);
end
