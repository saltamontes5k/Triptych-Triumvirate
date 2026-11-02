local M=require('achievement_quest_blightfire_spirits')

-- NMS preserved: restless dead of the moors (tasks 600446-600447) from the
-- retired #Gubjak_the_Lost.pl; runs alongside the spirits scene glue.
local function graveyard_say(e)
	local text = e.message:lower()
	local done_msg = "De dead sleep quiet now. Gubjak thanks you, mon, and de moors breathe easier."
	if text:find("hail", 1, true) then
		e.self:Say("Hnnn. You walk soft among the dead, mon. Gubjak remembers de old ways, and de dead here remember nothin'.")
		if quest.istaskactive(600446) then e.self:Say("Five bone shards, mon. De dead be waitin'.")
		elseif quest.istaskactive(600447) then e.self:Say("Twelve thralls still walkin'. Lay dem down.")
		elseif not quest.istaskcompleted(600446) then e.self:Say("De [spirits] here be restless for want of bone. Bring me shards from de blightfire dead and Gubjak will call dem proper.")
		elseif not quest.istaskcompleted(600447) then e.self:Say("De [thralls] walk dat should sleep. Lay dem down, mon.")
		else e.self:Say(done_msg) end
	end
	if text:find("spirits", 1, true) then
		if not quest.istaskactive(600446) and not quest.istaskcompleted(600446) then
			e.self:Say("Five Blightfire Bone Shards, from de witchlamps and de treants and de crocs. Den Gubjak calls.")
			quest.assigntask(600446)
		elseif quest.istaskactive(600446) then
			e.self:Say("Five bone shards, mon. De dead be waitin'.")
		else
			e.self:Say(done_msg)
		end
	end
	if text:find("rest", 1, true) then
		if not quest.istaskactive(600447) and not quest.istaskcompleted(600447) then
			e.self:Say("Twelve thralls. Lay dem to rest and come back to Gubjak.")
			quest.assigntask(600447)
		elseif quest.istaskactive(600447) then
			e.self:Say("Twelve thralls still walkin'. Lay dem down.")
		else
			e.self:Say(done_msg)
		end
	end
end

local function graveyard_trade(e)
	if not quest.istaskactive(600446) then return end
	local given, items = {}, {}
	for i = 1, 4 do
		local it = e.trade["item" .. i]
		if it and it.valid then
			local id = tostring(it:GetID())
			given[id] = (given[id] or 0) + (it:IsStackable() and it:GetCharges() or 1)
			items[#items + 1] = it
		end
	end
	if (given["46286"] or 0) >= 5 then
		e.self:CheckHandin(e.other, given, { ["46286"] = 5 }, items)
	end
	e.self:ReturnHandinItems(e.other)
end

function event_spawn(e) M.spawn(e) end
function event_say(e) M.say(e); graveyard_say(e) end
function event_aggro_say(e) M.say(e) end
function event_trade(e) M.trade(e); graveyard_trade(e) end
function event_timer(e) M.timer(e) end
