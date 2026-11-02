local M=require('achievement_quest_stonehive')

-- NMS preserved: TSS hive-war chain (tasks 600440-600442) from the retired
-- #Scout_Vreshnar.pl; runs alongside the stonehive glue.
local function hive_war_say(e)
	local text = e.message:lower()
	local done_msg = "You have done the watch proud, " .. e.other:GetName() .. ". The hive will think twice before it stings Crescent Reach again."
	local board = {
		{ "warriors", 600440, "Twelve warriors and twelve laborers. Thin the ranks and report back to me.", "Twelve warriors, twelve laborers. The hive still crawls." },
		{ "war",      600441, "Twelve eggtender drones and twelve wasphers. Break the brood and come back.", "The drones and wasphers, friend. Twelve each." },
		{ "golden",   600442, "The Stone Hive Trickster itself, and ten slavers for good measure. Then we will see about a reward.", "The Trickster, and its slavers. Golden, they say. Dead, I say." },
	}
	if text:find("hail", 1, true) then
		e.self:Say("Ah, the scout returns. Vreshnar watches the Stone Hive from the ridge and likes what he sees not at all.")
		for _, entry in ipairs(board) do
			if quest.istaskactive(entry[2]) then e.self:Say(entry[4]) return end
		end
		for _, entry in ipairs(board) do
			if not quest.istaskcompleted(entry[2]) and not quest.istaskactive(entry[2]) then return end
		end
		e.self:Say(done_msg)
	end
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

function event_say(e)M.say(e); hive_war_say(e) end
function event_trade(e)M.trade(e)end
