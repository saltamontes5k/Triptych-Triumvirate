-- Adrian (398022) - rof2b composition: the reconstruction's Roost achievement
-- routes dispatched below, folded with this server's TSS satyr scholar tasks
-- (600590 Explore the Roost!, 600591 Harass the Harpies!).
local roost = require('achievement_quest_roost')
local item_lib = require("items")

local function tss_say(e)
	if e.message:findi("hail") then
		if e.other:IsTaskActive(600590) then
			e.self:Say("The roost spreads up and out from here - the [" .. eq.say_link("ledge") .. "], the grove, the cliffs, and the great mesa. Find what you can and tell me of it.")
		elseif e.other:IsTaskActive(600591) then
			e.self:Say("The griffons still circle. Ten of them, and then we will speak further.")
		elseif not e.other:IsTaskCompleted(600590) then
			e.self:Say("Greetings to you, " .. e.other:GetCleanName() .. ". Are you certain that you wish to be here amongst so much [" .. eq.say_link("evil") .. "]?")
		elseif not e.other:IsTaskCompleted(600591) then
			e.self:Say("You have seen more of the roost than I ever dared. The harpies and their foul [" .. eq.say_link("griffons") .. "] still hunt my people for food. If you are stout enough of heart, perhaps you would like to [" .. eq.say_link("do something") .. "] about it?")
		else
			e.self:Say("You have done my people a great service, " .. e.other:GetCleanName() .. ". Perhaps there can be [" .. eq.say_link("peace") .. "] after all.")
		end
	end
	if e.message:findi("evil") and not e.other:IsTaskCompleted(600590) then
		e.self:Say("Oh, yes, evil! Most foul! In all the tales I heard as a young satyr there were none so horrible as those about harpies and their deeds. That is why I am here. In my heart I crave peace but until my people are safe that is not to be. We will never defeat this menace until we understand it better. If you can [" .. eq.say_link("find a way") .. "] to explore deeper into the roost, please let me know what you find.")
	end
	if e.message:findi("find a way") and not e.other:IsTaskActive(600590) and not e.other:IsTaskCompleted(600590) then
		e.self:Say("There are several areas in these cliffs and crags that the harpies nest in - a great [" .. eq.say_link("nest") .. "] on the first ledge, the grove on the second isle, the cliffs beyond, and the high mesa. Search them all and report back to me.")
		e.other:AssignTask(600590)
	end
	if e.message:findi("nest") and e.other:IsTaskActive(600590) then
		e.self:Say("The ledge nest lies past the narrow pass on the first isle. The grove is in the middle of the second. The cliffs are far to the right of the third, and the mesa sits atop the fourth.")
	end
	if e.message:findi("griffons") and not e.other:IsTaskActive(600591) and not e.other:IsTaskCompleted(600591) and e.other:IsTaskCompleted(600590) then
		e.self:Say("The griffons of this region are beholden to the harpies in a way I don't fully understand. Griffons themselves are fearsome enough but these, under the control of the harpies, are a terror like you've never seen. Slay a good number of them here in Blackfeather Roost then return to me and we will speak further.")
		e.other:AssignTask(600591)
	end
	if e.message:findi("do something") and not e.other:IsTaskActive(600591) and not e.other:IsTaskCompleted(600591) and e.other:IsTaskCompleted(600590) then
		e.self:Say("Slay ten of the blackfeather griffons. It does not frighten you, does it? I thought not. Go, and be careful.")
		e.other:AssignTask(600591)
	end
	if e.message:findi("peace") and e.other:IsTaskCompleted(600591) then
		e.self:Say("There can be no peace with an enemy without conscience. But you have blunted their claws, " .. e.other:GetCleanName() .. ". That is a beginning.")
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
