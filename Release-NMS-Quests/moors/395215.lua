local M=require("achievement_quest_blightfire")

-- NMS preserved: TSS farm kitchen chain (tasks 600465-600467) from the retired
-- Cook_Idriak.pl; runs alongside the blightfire glue.
local function kitchen_say(e)
	local text = e.message:lower()
	local done_msg = "The pot thanks you, and so does Idriak. Eat well, friend - you have earned it."
	local board = {
		{ "stew", 600465, "Six Rat Meats from the moonwhisker rats and their kin.", "Six rat meats. The pot is empty." },
		{ "flan", 600466, "Four Bixie Meats from the hive drones.", "Four bixie meats. No flan without them." },
		{ "heads", 600467, "Eight moorwalkers, any of the four packs. Then the garden is safe.", "Eight moorwalkers. The garden still trembles." },
	}
	if text:find("hail", 1, true) then
		e.self:Say("Hmph. You look like you can carry a pot without spilling it. Idriak [needs] ingredients, and the moors provide - if you provide the labor.")
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

-- Ingredient hand-ins (rat meat x6, bixie meat x4) while the matching task is
-- active; everything else comes back.
local function kitchen_trade(e)
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
	if quest.istaskactive(600465) then wanted["13408"] = 6 end
	if quest.istaskactive(600466) then wanted["97305"] = 4 end
	for id, count in pairs(wanted) do
		if (given[id] or 0) >= count then
			local required = { [id] = count }
			e.self:CheckHandin(e.other, given, required, items)
		end
	end
	e.self:ReturnHandinItems(e.other)
end

function event_say(e)M.say(e); kitchen_say(e) end
function event_trade(e)M.trade(e); kitchen_trade(e) end
