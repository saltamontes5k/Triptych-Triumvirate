local M=require('achievement_quest_bixies')
local S=require('achievement_quest_bixie_scenes')

-- NMS preserved: TSS hive-story chain (tasks 600448-600449) from the retired
-- #Buzzazar.pl; runs alongside the bixies scene glue.
local function hive_story_say(e)
	local text = e.message:lower()
	if text:find("hail", 1, true) then
		e.self:Say("Bzzz. You come to Buzzazar's ground, mon. Buzzazar watches de hive, and de hive watches back.")
		if quest.istaskactive(600448) then
			e.self:Say("De wasphers and de gardeners, mon. Ten each.")
		elseif quest.istaskactive(600449) then
			e.self:Say("Seven pages, mon. De evolution waits.")
		elseif not quest.istaskcompleted(600448) then
			e.self:Say("De [wasphers] and gardeners work de fringe. Buzz in, Buzz out - cull dem.")
		elseif not quest.istaskcompleted(600449) then
			e.self:Say("Buzzazar seeks de [evolution] of de hive - seven pages, scattered in de combs. Bring dem.")
		else
			e.self:Say("You have carried de whole story, mon. Buzzazar will remember. Bzzz.")
		end
	end
	if text:find("buzz", 1, true) then
		if not quest.istaskactive(600448) and not quest.istaskcompleted(600448) then
			e.self:Say("Ten wasphers and ten gardeners. Buzz through dem and return.")
			quest.assigntask(600448)
		elseif quest.istaskactive(600448) then
			e.self:Say("De wasphers and de gardeners, mon. Ten each.")
		else
			e.self:Say("You have carried de whole story, mon. Buzzazar will remember. Bzzz.")
		end
	end
	if text:find("evolution", 1, true) then
		if not quest.istaskactive(600449) and not quest.istaskcompleted(600449) then
			e.self:Say("Seven pages of de Bixie Evolution. Any worker or drone may carry one.")
			quest.assigntask(600449)
		elseif quest.istaskactive(600449) then
			e.self:Say("Seven pages, mon. De evolution waits.")
		else
			e.self:Say("You have carried de whole story, mon. Buzzazar will remember. Bzzz.")
		end
	end
end

-- Original handed all seven Bixie Evolution pages at once; keep that shape.
local function hive_story_trade(e)
	if not quest.istaskactive(600449) then return end
	local given, items = {}, {}
	for i = 1, 4 do
		local it = e.trade["item" .. i]
		if it and it.valid then
			local id = tostring(it:GetID())
			given[id] = (given[id] or 0) + (it:IsStackable() and it:GetCharges() or 1)
			items[#items + 1] = it
		end
	end
	local required = {}
	local all_present = true
	for _, id in ipairs({54643, 54644, 54645, 54646, 54647, 54648, 54649}) do
		if (given[tostring(id)] or 0) >= 1 then required[tostring(id)] = 1 else all_present = false end
	end
	if all_present and next(required) then
		e.self:CheckHandin(e.other, given, required, items)
	end
	e.self:ReturnHandinItems(e.other)
end

function event_spawn(e) S.spawn(e) end
function event_say(e) M.say(e); hive_story_say(e) end
function event_trade(e) M.trade(e); hive_story_trade(e) end
function event_task_accepted(e) M.accepted(e) end
function event_timer(e) S.timer(e) end
function event_death_complete(e) S.death_complete(e) end
function event_despawn(e) S.despawn(e) end
function event_combat(e) S.combat(e) end
