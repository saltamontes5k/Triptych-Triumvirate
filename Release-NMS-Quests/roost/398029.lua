-- Coryn (398029) - rof2b composition: the reconstruction's Roost achievement
-- routes dispatched below, folded with this server's TSS griffon-taming task
-- (600042 Blackfeather Roost, The Cliffs).
local roost = require('achievement_quest_roost')
local item_lib = require("items")

local function tss_say(e)
	if e.message:findi("hail") then
		if not e.other:IsTaskCompleted(600042) then
			e.self:Say("Coryn will help you, yes! Strong strangers want to explore, yes? Coryn can help you explore if strong strangers help Coryn too! [" .. eq.say_link("Rescue") .. "] Coryn and Coryn will help!")
		else
			e.self:Say("Coryn is happy! Strong strangers fed the griffon and Coryn is safe.")
		end
	end
	if e.message:findi("rescue") then
		e.self:Say("Coryn is weak and the Nobles think it's fun to hurt Coryn. Coryn wants [" .. eq.say_link("revenge") .. "] but not strong enough. Will you take revenge for Coryn?")
	end
	if e.message:findi("revenge") then
		if not e.other:IsTaskActive(600042) and not e.other:IsTaskCompleted(600042) then
			e.self:Say("Kill two Nobles for Coryn and Coryn will help. Return when they are dead and Coryn will help you explore more.")
			e.other:AssignTask(600042)
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
