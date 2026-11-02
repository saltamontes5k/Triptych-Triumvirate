local M=require("achievement_quest_blightfire")

-- NMS preserved: outpost bounty board (tasks 600443-600445, 600468-600472,
-- 600484) from the retired Scout_Captain_Slynn.pl; runs alongside the
-- blightfire glue (this NPC is also the supplies delivery point).
local function outpost_say(e)
	local text = e.message:lower()
	local done_msg = "You have earned your keep a dozen times over, scout. The outpost thanks you."
	local board = {
		{ "hatchery",    600443, "Twelve eggtender drones and ten waspling cocoons. Burn the brood.", "Twelve drones, ten cocoons. The hatchery still hums." },
		{ "fields",      600444, "Twelve gardeners, and five Globs of Raw Honey for the pot.", "Twelve gardeners and five globs of honey." },
		{ "silo",        600445, "Ten slavers and ten worker drones. Empty the silo guard.", "Ten slavers, ten drones. The silo still watches." },
		{ "hunters",     600468, "Eight giant bog rats and eight moss vipers. Then we talk about real work.", "Eight rats, eight vipers. The moors are still hungry." },
		{ "explorer",    600469, "Six slashclaws and six darkwater crocodilians. Walk both grounds and live.", "Six slashclaws, six crocs. Both grounds still crawl." },
		{ "runner",      600470, "Ten Mucktail gnolls off the road. The wagons will follow.", "Ten Mucktails on the road. The wagons wait." },
		{ "moorwalkers", 600471, "Three of each - Western, Southern, Northern, and Eastern. Then the roads breathe again.", "Three of each pack. The moors still walk." },
		{ "dreams",      600472, "Eight wanderers, six of the never-resting, and Duskfall himself.", "The fens still dream. Wanderers, never-resting, and Duskfall." },
		{ "memento",     600484, "Eight bog rats and eight vipers. Then the road is ours again.", "Eight rats, eight vipers. The road remembers." },
	}
	if text:find("hail", 1, true) then
		e.self:Say("New blood, eh? The outpost pays for work done. Plenty of [work] - and only some of it pretty.")
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

function event_say(e)M.say(e); outpost_say(e) end
function event_trade(e)M.trade(e)end
