local M=require('achievement_quest_blightfire_champion')

-- NMS preserved: the witch hunt (tasks 600451, 600481, 600482) from the
-- retired #Zan_the_Witch_Hunter.pl; runs alongside the champion glue.
local function witch_hunt_say(e)
	local text = e.message:lower()
	local done_msg = "The road is lighter for your work, and the witches quieter. Zan will remember."
	if text:find("hail", 1, true) then
		e.self:Say("Keep your wits about you on this road. The witches of the moors do not like [hunters].")
		if quest.istaskactive(600451) then e.self:Say("Six stingers. The craft waits.")
		elseif quest.istaskactive(600482) then e.self:Say("Six lightstones. The lamps still shine.")
		elseif quest.istaskactive(600481) then e.self:Say("Four witches, hunter. All of them.")
		elseif not quest.istaskcompleted(600451) then e.self:Say("First - [venom]. The Stone Hive carries stingers I need for the craft. Six of them.")
		elseif not quest.istaskcompleted(600482) then e.self:Say("The [witchlamps] - their lightstones feed the witches' sight. Six of them, burned out.")
		elseif not quest.istaskcompleted(600481) then e.self:Say("And the [witches] themselves. Four of them hold the moors: Agatha the Gray, Sinead the Scarlet, Ursula the Green, Eralynn the Shadow.")
		else e.self:Say(done_msg) end
	end
	local board = {
		{ "stingers", 600451, "Six Venomous Stonehive Stingers from the hive bixies.", "Six stingers. The craft waits." },
		{ "lamps",    600482, "Six Witchlamp Lightstones from the lamps themselves.", "Six lightstones. The lamps still shine." },
		{ "witches",  600481, "All four witches. Agatha, Sinead, Ursula, Eralynn. Then the moors breathe.", "Four witches, hunter. All of them." },
	}
	for _, entry in ipairs(board) do
		if text:find(entry[1], 1, true) then
			if not quest.istaskactive(entry[2]) and not quest.istaskcompleted(entry[2]) then
				e.self:Say(entry[3])
				quest.assigntask(entry[2])
			elseif quest.istaskactive(entry[2]) then
				e.self:Say(entry[4])
			else
				e.self:Say(done_msg)
			end
		end
	end
end

local function witch_hunt_trade(e)
	if not (quest.istaskactive(600451) or quest.istaskactive(600482)) then return end
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
	if quest.istaskactive(600451) then wanted["85757"] = 6 end
	if quest.istaskactive(600482) then wanted["85754"] = 6 end
	for id, count in pairs(wanted) do
		if (given[id] or 0) >= count then
			e.self:CheckHandin(e.other, given, { [id] = count }, items)
		end
	end
	e.self:ReturnHandinItems(e.other)
end

function event_say(e)M.say(e); witch_hunt_say(e) end
function event_trade(e)M.trade(e); witch_hunt_trade(e) end
function event_timer(e)M.timer(e)end
