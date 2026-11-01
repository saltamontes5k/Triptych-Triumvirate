
local welcome=require('achievement_quest_blightfire_welcome')

-- NMS preserved: TSS Mucktail works chain (tasks 600455-600459) from the
-- retired Ordunn_the_Miner.pl; runs alongside the welcome glue.
local function mucktail_say(e)
	local text = e.message:lower()
	local done_msg = "The quarry's quiet for the first time in years. Ordunn owes you a pint, and Ordunn pays his debts."
	local board = {
		{ "pick",   600455, "Ten Mucktail miners. Clear the lower diggings and report back.", "Ten miners, friend. The diggings still crawl." },
		{ "deeper", 600456, "Ten rock breakers, and the foreman with them.", "Ten breakers and the foreman. Deeper you go." },
		{ "golden", 600457, "Fifteen miners and Pit Boss Scar himself. Break the pit for good.", "Fifteen miners, and Scar. The Golden Pick waits." },
		{ "mines",  600458, "Twelve miners and eight breakers. Sweep the mines.", "The mines, friend. Twelve and eight." },
		{ "quarry", 600459, "Ten guard dogs and ten breakers. Empty the quarry.", "Dogs and breakers. The quarry waits." },
	}
	if text:find("hail", 1, true) then
		e.self:Say("Hmph. Another soft-handed adventurer. Ordunn needs hard workers - or hard fighters. Same thing down here.")
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

function event_say(e)welcome.say(e); mucktail_say(e) end
function event_trade(e)welcome.trade(e)end
