-- Dorinda (398039) - rof2b composition: the reconstruction's Roost achievement
-- routes dispatched below, folded with this server's TSS A Small Wager task
-- (600594).
local roost = require('achievement_quest_roost')
local item_lib = require("items")

local function tss_say(e)
	if e.message:findi("hail") then
		if e.other:IsTaskActive(600594) then
			e.self:Say("Still breathing? The [" .. eq.say_link("trinket") .. "] will not steal itself, weakling.")
		elseif not e.other:IsTaskCompleted(600594) then
			e.self:Say("Hello weakling. You don't mind if I call you a weakling, do you? I just happen to be the type of person who believes in speaking the truth, and the truth is, " .. e.other:GetCleanName() .. ", you are [" .. eq.say_link("weak") .. "].")
		else
			e.self:Say("I did not think you would survive, and here you stand. I apologize, " .. e.other:GetCleanName() .. " - you are not so weak after all.")
		end
	end
	if e.message:findi("weak") and not e.other:IsTaskActive(600594) and not e.other:IsTaskCompleted(600594) then
		e.self:Say("Well of course you're weak - you're not a harpy! Haha! But I can see I've offended you so I'll give you a chance to prove me [" .. eq.say_link("wrong") .. "].")
	end
	if e.message:findi("wrong") and not e.other:IsTaskActive(600594) and not e.other:IsTaskCompleted(600594) then
		e.self:Say("If you really want to prove me wrong then here's a challenge for you. Sneak into the royal throne room of our beloved queen and steal a royal [" .. eq.say_link("trinket") .. "]. If you survive the encounter, return it to me and I will apologize.")
		e.other:AssignTask(600594)
	end
	if e.message:findi("trinket") and e.other:IsTaskActive(600594) then
		e.self:Say("The Queen keeps her little treasures in a cage at the back of her throne room, on the last isle. Every soul in there sees through invisibility. Mind your step, weakling.")
	end
end

function event_say(e)
	tss_say(e)
	roost.say(e)
end

function event_trade(e)
	-- Consume the royal trinket only while A Small Wager is active (the task
	-- system handles completion); anything else is returned.
	if e.other:IsTaskActive(600594) then
		item_lib.check_turn_in(e.trade, { item1 = 28678 })
	end
	item_lib.return_items(e.self, e.other, e.trade)
	roost.trade(e)
end
