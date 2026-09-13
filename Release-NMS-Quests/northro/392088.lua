-- northro/392088.lua - Queen Tak`Yaliz
-- Prophecy of Ro: restores the enchantment to the Twisted Chime once the
-- three Ruins of Takish-Hiz tasks are complete.
local por = require("por_helper");

local function nro_complete(c)
	return c:IsTaskCompleted(por.tasks.key_to_the_past)
		and c:IsTaskCompleted(por.tasks.burning_prince)
		and c:IsTaskCompleted(por.tasks.message_from_the_past)
end

function event_say(e)
	local t = e.message:lower();
	if t:find("hail") then
		e.self:Say("You walk among the ghosts of a fallen age. I am Tak`Yaliz, last queen of the Elddar. What business have you with the past?");
	elseif t:find("twisted chime") then
		e.self:Say("Your assistance to my people has been of great value to me. Let me see this chime you speak of and I will see what may be done.");
	elseif t:find("prepared") or t:find("enter") or t:find("past") or t:find("send me") then
		if por.enter(e.other, "takishruins", "Ruins of Takish-Hiz", 1, 6, "6h") then
			e.self:Say("The sands of time part for you. Go, and mend what was broken so long ago.");
		end
	end
end

function event_trade(e)
	local item_lib = require("items");
	local c = e.other;

	-- Twisted Chime (second) -> Twisted Harmonic Chime (no effect)
	if item_lib.check_turn_in(e.trade, { item1 = por.items.twisted_chime_second }) then
		if nro_complete(c) then
			e.self:Say("These magics are ancient and almost beyond my memory. I have done what I could for you in this. Perhaps it will prove enough.");
			c:SummonFixedItem(por.items.twisted_harmonic_chime_blank);
		else
			e.self:Say("The chime resists. There is more you must do for my people before I can restore its song. Return when the Burning Prince is at rest and word has reached the past.");
			c:SummonFixedItem(por.items.twisted_chime_second);
		end
		return;
	end

	item_lib.return_items(e.self, e.other, e.trade);
end
