-- Mestle (398047) - rof2b composition: the reconstruction's Roost achievement
-- routes dispatched below, folded with this server's TSS griffon-taming task
-- (600043 Blackfeather Roost, The Mesa).
local roost = require('achievement_quest_roost')
local item_lib = require("items")

local function tss_say(e)
	if e.message:findi("hail") then
		if not e.other:IsTaskCompleted(600043) then
			e.self:Say("You have come far, stranger. But the Mesa lies beyond Lady Inthra's reach. Kill her, and I will permit you to travel deeper into the roost. Do you [" .. eq.say_link("accept") .. "]?")
		else
			e.self:Say("Well done. Frail as you seem, you may be up to the task ahead. Speak with my sister Ashrana, and quickly.")
		end
	end
	if e.message:findi("accept") then
		if not e.other:IsTaskActive(600043) and not e.other:IsTaskCompleted(600043) then
			e.self:Say("Kill her, and return to me when you have done so. Only then will you be permitted to travel deeper into the roost.")
			e.other:AssignTask(600043)
		end
	end
end

function event_say(e)
	tss_say(e)
	roost.say(e)
end

function event_trade(e)
	item_lib.return_items(e.self, e.other, e.trade)
	roost.trade(e)
end
