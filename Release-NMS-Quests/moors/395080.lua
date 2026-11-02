local M=require('achievement_quest_blightfire_champion')

-- NMS preserved: TSS watch bounty board (tasks 600473-600479) from the retired
-- Defan_the_Watch_Captain.pl; runs alongside the champion tower glue.
local function watch_board_say(e)
	local text = e.message:lower()
	local done_msg = "The watch is in your debt, soldier. The roads are quieter for you, and the board thanks you."
	local board = {
		{ "cliffs",    600473, "Ten slashclaws. Clear the high passes.", "Ten slashclaws. The cliffs still crawl." },
		{ "crocodile", 600474, "Eight darkwater crocodilians, and Mossback himself.", "Eight crocs and Mossback. The river still ticks." },
		{ "pools",     600475, "Eight snapjaws and eight lockjaws. Drain the pools of them.", "Eight and eight. The pools still snap." },
		{ "fens",      600476, "Ten of the ghostpack. Quiet the fens.", "Ten ghostpack wolves. The fens still howl." },
		{ "combs",     600477, "Ten worker drones and eight eggtender drones. Burn the combs.", "Ten workers, eight eggtenders. The combs still hum." },
		{ "dragon",    600478, "Eight hedge devils and six baleful briars. Give the dragon peace.", "Eight devils, six briars. The bones still crawl." },
		{ "crusade",   600479, "Twelve watchtower guardians and eight blightfire wanderers. The crusade starts with you.", "The crusade calls. Twelve guardians, eight wanderers." },
	}
	if text:find("hail", 1, true) then
		e.self:Say("You stand before the watch captain of the moors. We keep the roads, and the roads need [keeping]. The board is open.")
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

function event_spawn(e)M.defan_spawn(e)end
function event_say(e)M.say(e); watch_board_say(e) end
function event_trade(e)M.defan_trade(e)end
function event_hp(e)M.defan_hp(e)end
function event_death(e)return M.defan_death(e)end
function event_killed_merit(e)M.defan_merit(e)end
function event_timer(e)M.tower_timer(e)end
