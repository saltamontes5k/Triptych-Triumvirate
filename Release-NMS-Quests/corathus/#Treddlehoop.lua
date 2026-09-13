-- corathus/#Treddlehoop.lua
-- Depths of Darkhollow: Dreadspire access giver and Demi-Plane Monocle turn-in.
-- Tasks 505746 "Check Out a Library Book" and 505747 "Eyes Wide Open"; final
-- Monocle of Blood hand-in (Lens of Eye-Glass + seeing device).
local dodh = require("dodh_helper");

function event_say(e)
	local t = e.message:lower();
	if t:find("hail") then
		if not e.other:HasItem(dodh.items.treddlehoop_device) then
			e.other:SummonFixedItem(dodh.items.treddlehoop_device);
			e.self:Say("Well now, a fresh face at the crash site! Take my Wonderful Monoculor Seeing Device - it will see you into Dreadspire Keep. There is work for a capable sort, if you have the stomach for it.");
		else
			e.self:Say("Back again, are you? Dreadspire Keep still stands, and its secrets remain. What do you need?");
		end
	elseif t:find("book") or t:find("library") or t:find("shard") then
		if e.other:HasItem(dodh.items.shard_mystical_glass) then
			if not e.other:IsTaskActive(dodh.tasks.library_book) and not e.other:IsTaskCompleted(dodh.tasks.library_book) then
				e.other:AssignTask(dodh.tasks.library_book, e.self:GetID());
			end
			e.self:Say("A Shard of Mystical Glass! The Official Cataloguer up in the Dreadspire library keeps a Study of Mystical Vision. Bring it to me, and I will make something useful of that shard.");
		else
			e.self:Say("You will need a Shard of Mystical Glass first. The shadowmane researchers in the keep carry them.");
		end
	elseif t:find("special ingredients") or t:find("ingredients") or t:find("lens") then
		if e.other:HasItem(dodh.items.polished_glass_shard) then
			if not e.other:IsTaskActive(dodh.tasks.eyes_wide_open) and not e.other:IsTaskCompleted(dodh.tasks.eyes_wide_open) then
				e.other:AssignTask(dodh.tasks.eyes_wide_open, e.self:GetID());
			end
			e.self:Say("The next lens needs special ingredients. Gronk One-Eye in the tunnels wears a Bloody Cloth Eye Patch; bring it and the crypt blood slurry, and I will grind you a Blurry Lens.");
		else
			e.self:Say("Bring me the Polished Mystical Glass Shard first, and we will talk of special ingredients.");
		end
	elseif t:find("monocle") or t:find("blood") then
		e.self:Say("The Monocle of Blood is the key to the Demi-Plane itself. Bring me a Lens of Eye-Glass and my seeing device, and I will bind them into the monocle.");
	end
end

function event_trade(e)
	local item_lib = require("items");
	local c = e.other;

	-- Task 505746: Study of Mystical Vision -> Polished Mystical Glass Shard
	if item_lib.check_turn_in(e.trade, { item1 = dodh.items.study_mystical_vision }) then
		if c:IsTaskActive(dodh.tasks.library_book) or c:IsTaskCompleted(dodh.tasks.library_book) then
			c:UpdateTaskActivity(dodh.tasks.library_book, 0, 1);
			if not c:HasItem(dodh.items.polished_glass_shard) then
				c:SummonFixedItem(dodh.items.polished_glass_shard);
			end
			e.self:Say("The study, and the shard. Ah yes - there. A Polished Mystical Glass Shard. Hold on to it; you will need it.");
		else
			e.self:Say("I have no task for you. Keep your study.");
			c:SummonFixedItem(dodh.items.study_mystical_vision);
		end
		return;
	end

	-- Task 505747: Bloody Cloth Eye Patch -> Blurry Lens
	if item_lib.check_turn_in(e.trade, { item1 = dodh.items.bloody_cloth_eyepatch }) then
		if c:IsTaskActive(dodh.tasks.eyes_wide_open) or c:IsTaskCompleted(dodh.tasks.eyes_wide_open) then
			c:UpdateTaskActivity(dodh.tasks.eyes_wide_open, 1, 1);
			if not c:HasItem(dodh.items.blurry_lens) then
				c:SummonFixedItem(dodh.items.blurry_lens);
			end
			e.self:Say("The eyepatch! Good work. Here is your Blurry Lens. Coldwind Blackfoot in Nektulos Forest will know what to do with it.");
		else
			e.self:Say("That curio is of no use to me yet.");
			c:SummonFixedItem(dodh.items.bloody_cloth_eyepatch);
		end
		return;
	end

	-- Final: Lens of Eye-Glass + seeing device -> Monocle of Blood
	if item_lib.check_turn_in(e.trade, { item1 = dodh.items.lens_of_eye_glass, item2 = dodh.items.treddlehoop_device }) then
		if not c:HasItem(dodh.items.monocle_of_blood) then
			c:SummonFixedItem(dodh.items.monocle_of_blood);
		end
		if (tonumber(c:GetBucket(dodh.flags.monocle)) or 0) == 0 then
			c:SetBucket(dodh.flags.monocle, "1");
		end
		e.self:Say("The lens and the device, together as one. There! The Monocle of Blood. With it you may walk the Demi-Plane of Blood itself. Mind what you find there.");
		c:Message(15, "You have received the Monocle of Blood.");
		return;
	end

	item_lib.return_items(e.self, e.other, e.trade);
end
