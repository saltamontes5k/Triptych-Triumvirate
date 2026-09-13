-- nektulos/#Coldwind_Blackfoot.lua
-- Depths of Darkhollow: tasks 505748 "Misty for You" and 505749 "Eye Bound".
-- The final steps of the Demi-Plane of Blood access chain (Lens of Eye-Glass).
local dodh = require("dodh_helper");

function event_say(e)
	local t = e.message:lower();
	if t:find("hail") then
		e.self:Say("You found me. Good. I have been watching the Demi-Plane from afar, and I think you may be the one to finish what was started. Have you brought the [lens]?");
	elseif t:find("willing to prove") or t:find("prove") or t:find("blurry") then
		if e.other:HasItem(dodh.items.blurry_lens) or e.other:IsTaskCompleted(dodh.tasks.eyes_wide_open) then
			if not e.other:IsTaskActive(dodh.tasks.misty_for_you) and not e.other:IsTaskCompleted(dodh.tasks.misty_for_you) then
				e.other:AssignTask(dodh.tasks.misty_for_you, e.self:GetID());
			end
			e.self:Say("Then prove it. My sister, Misty, was taken into the lower spire. Slay what she has become and bring me her Moon-shaped Diamond Pendant.");
		else
			e.self:Say("Come back when you carry a Blurry Lens. You are not ready to prove anything yet.");
		end
	elseif t:find("lens of bound eyes") or t:find("vule") or t:find("eye bound") then
		if e.other:HasItem(dodh.items.lens_of_bound_eyes) or e.other:IsTaskCompleted(dodh.tasks.misty_for_you) then
			if not e.other:IsTaskActive(dodh.tasks.eye_bound) and not e.other:IsTaskCompleted(dodh.tasks.eye_bound) then
				e.other:AssignTask(dodh.tasks.eye_bound, e.self:GetID());
			end
			e.self:Say("The Lens of Bound Eyes can see into the lower spire. Master Vule the Silent Tear guards what you need. Kill him and bring me his eye.");
		else
			e.self:Say("First bring me proof of Misty. Then we will speak of Vule.");
		end
	end
end

function event_trade(e)
	local item_lib = require("items");
	local c = e.other;

	-- Task 505748: Moon-shaped Diamond Pendant -> Lens of Bound Eyes
	if item_lib.check_turn_in(e.trade, { item1 = dodh.items.moon_diamond_pendant }) then
		if c:IsTaskActive(dodh.tasks.misty_for_you) or c:IsTaskCompleted(dodh.tasks.misty_for_you) then
			c:UpdateTaskActivity(dodh.tasks.misty_for_you, 1, 1);
			if not c:HasItem(dodh.items.lens_of_bound_eyes) then
				c:SummonFixedItem(dodh.items.lens_of_bound_eyes);
			end
			e.self:Say("Misty... so it is true. Take the Lens of Bound Eyes. Use it to find Vule, and end this.");
		else
			e.self:Say("You have no task from me. Keep the pendant, if it means anything to you.");
			c:SummonFixedItem(dodh.items.moon_diamond_pendant);
		end
		return;
	end

	-- Task 505749: Vule's Eye -> Lens of Eye-Glass
	if item_lib.check_turn_in(e.trade, { item1 = dodh.items.vules_eye }) then
		if c:IsTaskActive(dodh.tasks.eye_bound) or c:IsTaskCompleted(dodh.tasks.eye_bound) then
			c:UpdateTaskActivity(dodh.tasks.eye_bound, 1, 1);
			if not c:HasItem(dodh.items.lens_of_eye_glass) then
				c:SummonFixedItem(dodh.items.lens_of_eye_glass);
			end
			e.self:Say("Vule's eye. You have done the impossible. Take the Lens of Eye-Glass to Treddlehoop; he will fashion the Monocle of Blood.");
		else
			e.self:Say("You have no task from me. Keep the eye.");
			c:SummonFixedItem(dodh.items.vules_eye);
		end
		return;
	end

	item_lib.return_items(e.self, e.other, e.trade);
end
