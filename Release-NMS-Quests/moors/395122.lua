local M=require('achievement_quest_bixies')
local S=require('achievement_quest_bixie_scenes')

-- NMS preserved: Widow's Last Memory (600211), Jumjum Research (600450) and
-- Buzz on the Bixies (600483) from the retired Merchant_Makesn.pl; runs
-- alongside the bixies scene glue.
local function makesn_say(e)
	local text = e.message:lower()
	if text:find("hail", 1, true) then
		e.self:Say("Hail to you, traveler, and welcome to my humble store. I pray that your [" .. quest.saylink("adventures") .. "] have brought you more luck than mine.")
	end
	if text:find("adventures", 1, true) then
		e.self:Say("Not long ago, after the death of my husband, my daughter and I decided to start anew. Unfortunately, during our journey here our caravan was attacked by [" .. quest.saylink("gnolls") .. "].")
	end
	if text:find("gnolls", 1, true) then
		if not quest.istaskactive(600211) and not quest.istaskcompleted(600211) then
			e.self:Say("They took little of value - except a small trinket my dear husband gave me before his passing. They headed south toward their mines. Would you recover it for me?")
			quest.assigntask(600211)
		else
			e.self:Say("The gnolls headed south toward their mines. My locket, please.")
		end
	end
	if text:find("jumjum", 1, true) then
		if not quest.istaskactive(600450) and not quest.istaskcompleted(600450) then
			e.self:Say("The bixies of Stone Hive grow a strange [jumjum]. A scholar would pay well for the research: their honey-covered journal, and some of the raw honey itself.")
			quest.assigntask(600450)
		elseif quest.istaskactive(600450) then
			e.self:Say("The journal, and the raw honey. The hive workers carry both.")
		else
			e.self:Say("The research was well received, they tell me. My thanks again.")
		end
	end
	if text:find("buzz", 1, true) then
		if not quest.istaskactive(600483) and not quest.istaskcompleted(600483) then
			e.self:Say("The whole hive has a [buzz] about it lately - warriors and drones on the move. Thin them out before they decide the farm is theirs.")
			quest.assigntask(600483)
		elseif quest.istaskactive(600483) then
			e.self:Say("The buzz, friend. Warriors and drones alike.")
		else
			e.self:Say("Quieter, isn't it? The farm thanks you.")
		end
	end
end

-- Hand-ins only while their task is active (the task system owns completion);
-- everything else comes back through the handin system.
local function makesn_trade(e)
	local given, items = {}, {}
	for i = 1, 4 do
		local it = e.trade["item" .. i]
		if it and it.valid then
			local id = tostring(it:GetID())
			given[id] = (given[id] or 0) + (it:IsStackable() and it:GetCharges() or 1)
			items[#items + 1] = it
		end
	end
	local wanted = {}
	if quest.istaskactive(600211) then wanted["52644"] = 1 end
	if quest.istaskactive(600450) then wanted["54639"] = 1; wanted["52639"] = 5 end
	for id, count in pairs(wanted) do
		if (given[id] or 0) >= count then
			e.self:CheckHandin(e.other, given, { [id] = count }, items)
		end
	end
	e.self:ReturnHandinItems(e.other)
end

function event_spawn(e) S.spawn(e) end
function event_say(e) M.say(e); makesn_say(e) end
function event_trade(e) M.trade(e); makesn_trade(e) end
function event_task_accepted(e) M.accepted(e) end
function event_timer(e) S.timer(e) end
function event_death_complete(e) S.death_complete(e) end
function event_despawn(e) S.despawn(e) end
function event_combat(e) S.combat(e) end
