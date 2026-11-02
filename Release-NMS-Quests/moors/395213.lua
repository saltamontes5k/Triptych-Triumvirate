local M=require('achievement_quest_stonehive')

-- NMS preserved: TSS moor botany chain (tasks 600460-600463) from the retired
-- Botanist_Brezuu.pl; runs alongside the stonehive glue.
local function botany_say(e)
	local text = e.message:lower()
	local done_msg = "Splendid specimens, all of them! The council gardeners will hear of this. Come back when the moors bloom again."
	local board = {
		{ "plants", 600460, "Five Shambling Vegetables. Mind the thorns.", "Five shambling vegetables. The beds are empty." },
		{ "seed",   600461, "Four Seed Pods from the briar thorns.", "Four seed pods. Curious ones." },
		{ "sap",    600462, "Five Treant Saps from the rotwood treants.", "Five saps. The trees still weep." },
		{ "ooze",   600463, "Four Green Ooze Buds from the green oozes.", "Four ooze buds. Sticky business." },
	}
	if text:find("hail", 1, true) then
		e.self:Say("Vasha! You are just in time - the moors grow things that grow nowhere else, and I [need] samples of all of them.")
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

-- Sample hand-ins while the matching task is active; the rest comes back.
local function botany_trade(e)
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
	if quest.istaskactive(600460) then wanted["97048"] = 5 end
	if quest.istaskactive(600461) then wanted["54656"] = 4 end
	if quest.istaskactive(600462) then wanted["97054"] = 5 end
	if quest.istaskactive(600463) then wanted["85758"] = 4 end
	for id, count in pairs(wanted) do
		if (given[id] or 0) >= count then
			e.self:CheckHandin(e.other, given, { [id] = count }, items)
		end
	end
	e.self:ReturnHandinItems(e.other)
end

function event_say(e)M.say(e); botany_say(e) end
function event_trade(e)M.trade(e); botany_trade(e) end
