-- arcstone/369002.lua - Spirit Hunter Elijo
-- Prophecy of Ro: "Mark of the Spirits" (task 3031). The champions of Arcstone
-- each carry a mark; Elijo reads them. The five deliver activities auto-advance
-- in the task system, so trade only consumes the mark (it is not handed back).
local por = require("por_helper");

local MARK_TASK = 3031;

local marks = {
	85606, -- Mark of Okahn
	85607, -- Mark of Ravenglass
	85608, -- Mark of Stillwillow
	85609, -- Mark of Xanzerok
	85610, -- Mark of Oroshar
}

function event_say(e)
	local t = e.message:lower();
	if t:find("hail") then
		e.self:Say("The spirits of this shattered place whisper to me. Each champion that stalks Arcstone carries a mark - proof of the spirit it serves. Bring them to me, and I will read what they have to say.");
		if not e.other:IsTaskActive(MARK_TASK) and not e.other:IsTaskCompleted(MARK_TASK) then
			e.other:AssignTask(MARK_TASK);
		end
	elseif t:find("mark") or t:find("spirit") then
		e.self:Say("Five marks I seek: the Mark of Okahn, the Mark of Ravenglass, the Mark of Stillwillow, the Mark of Xanzerok, and the Mark of Oroshar. The named of Arcstone bear them.");
	end
end

function event_trade(e)
	local item_lib = require("items");

	if e.other:IsTaskActive(MARK_TASK) then
		for _, id in ipairs(marks) do
			if item_lib.check_turn_in(e.trade, { item1 = id }) then
				e.self:Say("A mark! The spirits grow restless. Bring me the rest.");
				return;
			end
		end
	end

	item_lib.return_items(e.self, e.other, e.trade);
end
