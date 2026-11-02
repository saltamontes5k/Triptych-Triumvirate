local quests = require("achievement_quest_npcs")

-- NMS preserved: the TSS forge board (tasks 600520-600523, Simple
-- Stud/Chisel/File/Clasp for Crescent Reach) from the retired
-- Smithy_Drawlyn.pl; runs alongside the crescent module glue.
local function forge_board_say(e)
	local text = e.message:lower()
	local done_msg = "The charter plates hold, smith. Crescent Reach thanks you."
	local board = {
		{ "stud",   600520, "First a [stud] - a Simple Stud, forged clean.", "A Simple Stud. The forge is hot." },
		{ "chisel", 600521, "And a [chisel] - a Simple Chisel for the stonecutters.", "A Simple Chisel. The masons wait." },
		{ "file",   600522, "A [file] next - a Simple File, well tempered.", "A Simple File. The armory grinds its teeth." },
		{ "clasp",  600523, "And a [clasp] - a Simple Clasp to hold the charter plates.", "A Simple Clasp. The plates still rattle." },
	}
	if text:find("hail", 1, true) then
		e.self:Say("The forge never rests since the charter came. The city [requests] simple work, if your hammer is honest.")
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
				e.other:AssignTask(entry[2])
			elseif quest.istaskactive(entry[2]) then
				e.self:Say(entry[4])
			else
				e.self:Say(done_msg)
			end
		end
	end
end

function event_say(e) quests.say(e); forge_board_say(e) end
function event_trade(e) quests.trade(e) end
function event_task_accepted(e) quests.accepted(e) end
