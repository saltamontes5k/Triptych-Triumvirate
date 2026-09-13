-- Farnjer - A Fool In Love / All You Need Is Love (Erollisi Day)
local ED = require("erollisiday")
local FOOL = ED.TASK.FOOL
local ALL  = ED.TASK.ALLNEED
local FIND = ED.TASK.FINDME

function event_say(e)
	local c = e.other
	local m = e.message

	if m:findi("hail") then
		if not c:IsTaskActive(FOOL) and not c:IsTaskCompleted(FOOL) then
			ED.assign(c, FOOL)
			ED.upd(c, FOOL, 0, 1)
			e.self:Say("Hello, my friend! It is a sad day. My friend Rolo got into the Dust of a Broken Heart and now he is in love with a biggin! He cannot possibly be enamored with a halfy - halfies are too big, and too serious. Please [" .. eq.say_link("talk to Rolo") .. "].")
		elseif c:IsTaskActive(FOOL) then
			if c:GetTaskActivityDoneCount(FOOL, 7) >= 1 then
				ED.upd(c, FOOL, 8, 1)
				c:QuestReward(e.self, 0, 0, 0, 0, 0, 3000)
				c:Message(15, "You have helped Rolo through his heartache.")
				quest.complete_task(FOOL)
				e.self:Say("You have done a wonderful thing. Rolo will be himself again. Thank you, " .. c:GetName() .. ".")
			else
				e.self:Say("Rolo is still pining. Perhaps some [" .. eq.say_link("wonderful gifts") .. "] will cheer him, or a kind word from Deputy Mims in her tower.")
			end
		else
			e.self:Say("Hail, " .. c:GetName() .. "! The hills are full of heartache today.")
		end

		if not c:IsTaskActive(ALL) and not c:IsTaskCompleted(ALL) then
			e.self:Say("Oh! And Deputy Mims was speaking of [" .. eq.say_link("wonderful gifts") .. "] the other day. I would love to know what they are.")
		end

		if c:IsTaskActive(FIND) then
			if c:GetTaskActivityDoneCount(FIND, 7) >= 1 and c:GetTaskActivityDoneCount(FIND, 8) < 1 then
				ED.upd(c, FIND, 8, 1)
				c:SummonItem(ED.ITEM.BROWNIE_FAM)
				c:QuestReward(e.self, 0, 0, 0, 0, 0, 5000)
				c:Message(15, "You have uncovered the goblins' plot and warned the vale.")
				quest.complete_task(FIND)
				e.self:Say("You have done the vale a great service. Please accept this Lovely Brownie Familiar, with our thanks.")
			elseif c:GetTaskActivityDoneCount(FIND, 5) >= 1 and c:GetTaskActivityDoneCount(FIND, 6) < 1 then
				ED.upd(c, FIND, 6, 1)
				e.self:Say("A Goblin News Flyer? This is grave news. Rolo will want to see it as well - speak with him, then return to me.")
			end
		end

	elseif m:findi("talk to Rolo") then
		if c:IsTaskActive(FOOL) then
			ED.upd(c, FOOL, 1, 1)
			e.self:Say("Yes, Rolo is on the pillar just there. Speak with him and see if you can talk some sense into him.")
		end

	elseif m:findi("wonderful gifts") then
		if not c:IsTaskActive(ALL) and not c:IsTaskCompleted(ALL) then
			ED.assign(c, ALL)
			ED.upd(c, ALL, 0, 1)
			e.self:Say("Truly? Then listen closely to Deputy Mims in her tower, and tell me what gifts she and Deputy Ranen spoke of.")
		elseif c:IsTaskActive(ALL) and c:GetTaskActivityDoneCount(ALL, 1) >= 1 and c:GetTaskActivityDoneCount(ALL, 2) < 1 then
			ED.upd(c, ALL, 2, 1)
			e.self:Say("The gifts! A Slice of Jumjum Cake, a Fresh Rivervale Flower, a Goblin Doll and a Bandit Drum. Please gather them and bring them to Deputy Mims.")
		end
	end
end
