-- Lucian (398023) - rof2b composition: the reconstruction's Roost achievement
-- routes dispatched below, folded with this server's TSS satyr troublemaker
-- tasks (600592 Cause some mayhem, 600593 Strike a Blow, 600595 Destroy!).
local roost = require('achievement_quest_roost')
local item_lib = require("items")

local function tss_say(e)
	if e.message:findi("hail") then
		if e.other:IsTaskActive(600592) then
			e.self:Say("Gayatri roosts on the fourth isle, minding the harpies' young. Kill her and bring me the [" .. eq.say_link("heart") .. "]. I can't wait to hear the screams from here!")
		elseif e.other:IsTaskActive(600593) then
			e.self:Say("Bloody your [" .. eq.say_link("sword") .. "] a little more, friend. The harpies and their griffons will remember it.")
		elseif e.other:IsTaskActive(600595) then
			e.self:Say("Those [" .. eq.say_link("nests") .. "] will not hack themselves apart. The ledge, the grove, the cliffs, and the mesa - leave nothing standing.")
		elseif not e.other:IsTaskCompleted(600592) then
			e.self:Say("Bah, what now? Can't you see I'm [" .. eq.say_link("busy") .. "] here?")
		elseif not e.other:IsTaskCompleted(600593) then
			e.self:Say("Back so soon? Do you seek [" .. eq.say_link("vengeance") .. "] as I do, or do you just enjoy causing [" .. eq.say_link("mayhem") .. "]?")
		else
			e.self:Say("Listen. . . can you hear the frightened screams in the roost? It will take them some time to recover from us! If you are still hungry for ruin, there are always more [" .. eq.say_link("nests") .. "] to knock down.")
		end
	end
	if e.message:findi("busy") and not e.other:IsTaskCompleted(600592) then
		e.self:Say("Yes! I said I'm busy. Busy trying to [" .. eq.say_link("kill") .. "] and [" .. eq.say_link("destroy") .. "]. How does that make you feel?")
	end
	if e.message:findi("mayhem") and not e.other:IsTaskActive(600592) and not e.other:IsTaskCompleted(600592) then
		e.self:Say("Mayhem is always fun, isn't it? I just happen to know a way you can cause a great deal of it! The harpies entrust the care of their young to a harpy named Gayatri. If you were to kill her, it would throw the entire roost into a panic. [" .. eq.say_link("Do it") .. "] and I'll make it worth your while.")
		e.other:AssignTask(600592)
	end
	if e.message:findi("do it") and e.other:IsTaskActive(600592) then
		e.self:Say("Haha! I can't wait to hear about it!")
	end
	if e.message:findi("vengeance") and e.other:IsTaskCompleted(600592) and not e.other:IsTaskActive(600593) and not e.other:IsTaskCompleted(600593) then
		e.self:Say("If it's vengeance you seek then perhaps we can help each other. Kill a good number of these pesky harpies and griffons, and I think I can find a reward to make bloodying your sword even more worthwhile. Do you [" .. eq.say_link("agree") .. "]?")
		e.other:AssignTask(600593)
	end
	if e.message:findi("sword") and e.other:IsTaskActive(600593) then
		e.self:Say("Twenty-four harpies and five blackfeather griffons. Then we will have a good laugh about it together.")
	end
	if e.message:findi("destroy") and not e.other:IsTaskActive(600595) and not e.other:IsTaskCompleted(600595) and e.other:IsTaskCompleted(600593) then
		e.self:Say("Destroy? Don't mind if I do! If you want to join in the fun, why don't you go hack apart some harpy [" .. eq.say_link("nests") .. "]? Let me know when you're done. We'll have a good laugh about it together.")
		e.other:AssignTask(600595)
	end
	if e.message:findi("nests") then
		if e.other:IsTaskActive(600595) then
			e.self:Say("Nine small nests, twenty-two large ones, and five of the ornate royal roosts on the mesa. Tear them all down!")
		elseif e.other:IsTaskCompleted(600595) then
			e.self:Say("Already done? Hah! The roost will not soon forget you.")
		end
	end
	if e.message:findi("heart") and e.other:IsTaskActive(600592) then
		e.self:Say("The heart of Gayatri. Bring it here and listen to the roost wail!")
	end
end

function event_say(e)
	tss_say(e)
	roost.say(e)
end

function event_trade(e)
	-- Consume the Gayatri heart only while Cause some mayhem is active (the
	-- task system handles completion); anything else is returned.
	if e.other:IsTaskActive(600592) then
		item_lib.check_turn_in(e.trade, { item1 = 13617 })
	end
	item_lib.return_items(e.self, e.other, e.trade)
	roost.trade(e)
end
