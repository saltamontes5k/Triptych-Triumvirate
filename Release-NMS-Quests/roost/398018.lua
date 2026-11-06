-- Fenith (398018) - rof2b composition: the reconstruction's Roost achievement
-- routes dispatched below, folded with this server's TSS griffon-taming task
-- (600040 The Ledge, 600110 puma cull) so both live on the same NPC.
local roost = require('achievement_quest_roost')
local item_lib = require("items")

local function tss_say(e)
	if e.message:findi("hail") then
		if not e.other:IsTaskCompleted(600040) then
			e.self:Say("Huh? You want to learn to ride the griffons of the Roost? It takes a [" .. eq.say_link("treat") .. "], and a steady hand. Feed one and see if it likes you.")
		else
			e.self:Say("So you managed to feed the griffon and keep all your fingers? Huh! Well, each griffon likes a different treat. Ask me for a [" .. eq.say_link("hint") .. "] if you like.")
		end
	end
	if e.message:findi("treat") then
		if not e.other:IsTaskActive(600040) and not e.other:IsTaskCompleted(600040) then
			e.self:Say("Combine the components in the treat kit, then give the treat to a tame griffon nearby. Mind your fingers!")
			e.other:AssignTask(600040)
		end
	end
	if e.message:findi("hint") then
		e.self:Say("The next griffon has a taste for something found closer to the first ledge.")
	end
	if e.message:findi("puma") then
		if not e.other:IsTaskActive(600110) and not e.other:IsTaskCompleted(600110) then
			e.self:Say("Those stupid pumas! Every time I turn my back they sneak into my stores of meat for the griffons and eat it all up! Kill a few mountain pumas for me and I'll be grateful.")
			e.other:AssignTask(600110)
		end
	end
	if e.message:findi("afraid") then
		e.self:Say("Well of course I'm afraid! Grumpy griffons are no laughing matter. Thin out those pumas for me, would you?")
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
