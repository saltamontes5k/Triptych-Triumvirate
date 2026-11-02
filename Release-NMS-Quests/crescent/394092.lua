local M=require('achievement_quest_blightfire_champion')

-- NMS preserved: Pieces of the Past (task 600210; Ogre Relic 54638 in, reward
-- Sphere of the Ancients 53514 via the task) from the retired
-- Historian_Pewdri.pl; runs alongside the champion glue.
local function pewdri_say(e)
	local text = e.message:lower()
	if text:find("hail", 1, true) then
		e.self:Say("Hello there, adventurer. Are you by any chance heading out into the [" .. quest.saylink("Moors") .. "]?")
	end
	if text:find("moors", 1, true) then
		e.self:Say("I am researching the ogres that once lived here in Nokk. I have had luck finding a relic here and there, but could really use more. There is a ruined [" .. quest.saylink("tower") .. "] in particular that may hold an item or two.")
	end
	if text:find("tower", 1, true) then
		if not quest.istaskactive(600210) and not quest.istaskcompleted(600210) then
			e.self:Say("A watchtower out in the Moors, overrun by its guardian. Bring me whatever relics you recover.")
			quest.assigntask(600210)
		end
	end
	if text:find("relic", 1, true) and quest.istaskcompleted(600210) then
		e.self:Say("Thanks so much for your help, " .. e.other:GetName() .. ". This tells us a great deal about the old ogre kingdom.")
	end
end

local function pewdri_trade(e)
	if not quest.istaskactive(600210) then return end
	local given, items = {}, {}
	for i = 1, 4 do
		local it = e.trade["item" .. i]
		if it and it.valid then
			local id = tostring(it:GetID())
			given[id] = (given[id] or 0) + (it:IsStackable() and it:GetCharges() or 1)
			items[#items + 1] = it
		end
	end
	if (given["54638"] or 0) >= 1 then
		e.self:CheckHandin(e.other, given, { ["54638"] = 1 }, items)
	end
	e.self:ReturnHandinItems(e.other)
end

function event_say(e)M.say(e); pewdri_say(e) end
function event_trade(e)M.trade(e); pewdri_trade(e) end
function event_timer(e)M.timer(e)end
