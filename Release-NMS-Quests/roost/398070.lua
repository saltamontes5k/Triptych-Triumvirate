-- Ashrana (398070) - rof2b composition: the reconstruction's Roost achievement
-- routes dispatched below, folded with this server's TSS griffon-taming /
-- Queen's palace tasks (600044 Reach the Royal Throne, 600045 Kill the Queen).
-- Items: Royal Crest 28672, Royal Emblem 28673.
local roost = require('achievement_quest_roost')
local item_lib = require("items")

local function tss_say(e)
	if e.message:findi("hail") then
		if not e.other:IsTaskCompleted(600044) then
			e.self:Say("There is one snag to our fine plan - reaching my dear older sister the Queen. Only specially trained Royal Griffons can carry you there, and to ride them you need a [" .. eq.say_link("Royal Crest") .. "].")
		elseif not e.other:IsTaskCompleted(600045) then
			e.self:Say("Now we can finally [" .. eq.say_link("accomplish") .. "] our goal! Your prize waits for you if you can slay the Queen. Return with proof and I will see that you are rewarded.")
		else
			e.self:Say("My sister is dead and the roost is ours. You have my thanks, " .. e.other:GetCleanName() .. ".")
		end
	end
	if e.message:findi("Royal Crest") then
		if not e.other:IsTaskActive(600044) and not e.other:IsTaskCompleted(600044) then
			e.self:Say("Captain Slarus leads the Queen's personal guard, and she and her lieutenants alone carry the Crests. Kill Slarus and her Royal Guards, and bring me a Crest.")
			e.other:AssignTask(600044)
		else
			e.self:Say("Slarus still holds the Mesa. Bring me a Royal Crest.")
		end
	end
	if e.message:findi("accomplish") then
		if e.other:IsTaskCompleted(600044) and not e.other:IsTaskActive(600045) and not e.other:IsTaskCompleted(600045) then
			e.self:Say("Queen Eletyl must die. Take the Royal Griffon to her palace, slay her and her guards, and bring me the Royal Emblem as proof.")
			e.other:AssignTask(600045)
		end
	end
end

function event_say(e)
	tss_say(e)
	roost.say(e)
end

function event_trade(e)
	if item_lib.check_turn_in(e.trade, { item1 = 28672 }) then -- Royal Crest
		e.self:Say("You have done it. Take the crest, and may the Royal Griffons bear you swiftly.")
	elseif item_lib.check_turn_in(e.trade, { item1 = 28673 }) then -- Royal Emblem
		e.self:Say("Aha! Well done, " .. e.other:GetCleanName() .. ". Now we can finally accomplish our goal! The roost is ours.")
	end
	item_lib.return_items(e.self, e.other, e.trade)
	roost.trade(e)
end
