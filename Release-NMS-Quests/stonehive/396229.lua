local M=require('achievement_quest_stonehive')

-- NMS preserved: TSS scout chain steps 600588 (The Saving Salve) and 600589
-- (Muddied Bixie Plans hand-off) from the retired Scout_Neauza.pl; runs
-- alongside the stonehive glue.
local function scout_say(e)
	local text = e.message:lower()
	if text:find("hail", 1, true) then
		if quest.istaskactive(600588) then
			e.self:Say("The enthraller on the staircase carries a [saving salve]. Bring it before this poison finishes me!")
		elseif quest.istaskactive(600589) then
			e.self:Say("The plans, such as they are, must reach [Vreshnar] in Blightfire Moors. Hurry!")
		elseif quest.istaskcompleted(600588) and not quest.istaskcompleted(600589) then
			e.self:Say("What a mess I got myself into! This agent stuff is harder than it looks! I had just found this set of plans when I was attacked. I can only take this as a sign that those bixies are serious! Hurry back to Vreshnar and show him what I've found. Don't worry about me, I won't let that happen again. Ha!")
			e.self:SummonItem(54624)
			quest.assigntask(600589)
		elseif quest.istaskcompleted(600589) then
			e.self:Say("I've still got a lot of work to take care of here, but I won't let the hive get the better of me twice.")
		else
			e.self:Say("Cough. . . you there! One of those enthralled bixies got the better of me. Slay the [enthraller] on the staircase and bring me the salve it carries.")
		end
	end
	if text:find("enthraller", 1, true) and not quest.istaskactive(600588) and not quest.istaskcompleted(600588) then
		e.self:Say("Kill it and loot the salve. Mind the staircase - the guards up there answer quickly.")
		quest.assigntask(600588)
	end
end

local function scout_trade(e)
	if not quest.istaskactive(600588) then return end
	local given, items = {}, {}
	for i = 1, 4 do
		local it = e.trade["item" .. i]
		if it and it.valid then
			local id = tostring(it:GetID())
			given[id] = (given[id] or 0) + (it:IsStackable() and it:GetCharges() or 1)
			items[#items + 1] = it
		end
	end
	if (given["54623"] or 0) >= 1 then
		e.self:CheckHandin(e.other, given, { ["54623"] = 1 }, items)
	end
	e.self:ReturnHandinItems(e.other)
end

function event_say(e)M.say(e); scout_say(e) end
function event_trade(e)M.trade(e); scout_trade(e) end
