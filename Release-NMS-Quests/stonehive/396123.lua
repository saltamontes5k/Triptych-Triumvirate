local M=require('achievement_quest_stonehive')

-- NMS preserved: Warwing task series (tasks 600584-600587; Who's Who? ->
-- Infiltrate the Hive -> Honey, I'm Home! -> The Queen Bixie) from the retired
-- Warwing_Wendlez.pl; runs alongside the stonehive glue.
local function warwing_say(e)
	local text = e.message:lower()
	local done_msg = "You have destroyed the queen! The bixie threat has been contained, for now. . . but there may be a future queen being raised among the grubs. How long will it be until a new threat emerges?"
	if text:find("hail", 1, true) then
		if quest.istaskactive(600584) then
			e.self:Say("Find [Neezzee] in the war council chamber, two elevators up. Do not trust her - she will know why you have come.")
		elseif quest.istaskactive(600585) then
			e.self:Say("The [war plans] lie in the council chamber, not far from where Neezzee held court. Grab them and bring them to me.")
		elseif quest.istaskactive(600586) then
			e.self:Say("Wings, flesh, a scent gland, antennae, and an [insignia]. Bring me all of it and I will disguise you.")
		elseif quest.istaskactive(600587) then
			e.self:Say("Suit up and slay [Queen Pelzia]. Off with her head!")
		elseif not quest.istaskcompleted(600584) then
			e.self:Say("Who sent you? Was it [Vreshnar]? I suppose it must have been.. my whereabouts are secret, and a scout of Crescent Reach would not have given up my position willingly. Listen here, I've discovered the key to unhinging Stone Hive. Their military genius lies in the mind of one particular strategist by the name of [Neezzee], but her room is well guarded.")
		elseif not quest.istaskcompleted(600585) then
			e.self:Say("I. . . don't know what happened, it must have been a powerful enchantment. How mortifying! Neezzee is gone, you say? Now our only hope is to find her [plans].")
		elseif not quest.istaskcompleted(600586) then
			e.self:Say("Most interesting. They are nearly.. gibberish. It seems our Bixies are more caught up in the idea of war than any idea of whom they want to war upon! I fear this may be some form of misdirection. We must get you [disguised] as well. It requires many components to escape notice around here!")
		elseif not quest.istaskcompleted(600587) then
			e.self:Say("That should do nicely! When you are ready, [suit up] so you will be able to approach the queen's chambers without arousing suspicion. We can make no mistakes, the safety of Crescent Reach lays on our very shoulders!")
		else
			e.self:Say(done_msg)
		end
	end
	local board = {
		{ "neezzee",  600584, "Find her in the war council chamber, two elevators up. It's best to kill all the mobs in the room first. She will not assist until you greet her - and then she will show her true face. Slay her and return to me." },
		{ "plans",    600585, "She obsessively documented every military plan or theory she had. They must be inside the council chamber! It is heavily guarded, but if you dispatched Neezzee so easily I am sure it should pose little challenge. Bring me those plans!" },
		{ "disguise", 600586, "Yes, we must get you disguised. A rather arduous task I'm afraid. Bring me two intact bixie wings, two bits of intact bixie flesh, one intact scent gland, two intact antennae, and one intact Stone Hive insignia. All of it can be gathered before you return." },
		{ "queen",    600587, "It's the only way to be sure. Once you suit up, dispatch Queen Pelzia in her chamber beyond the council room. Off with her head!" },
	}
	for _, entry in ipairs(board) do
		if text:find(entry[1], 1, true) and not quest.istaskactive(entry[2]) and not quest.istaskcompleted(entry[2]) then
			e.self:Say(entry[3])
			quest.assigntask(entry[2])
		end
	end
end

-- War-plan and disguise-component hand-ins while their task is active.
local function warwing_trade(e)
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
	if quest.istaskactive(600585) then wanted["21793"] = 1 end
	if quest.istaskactive(600586) then
		wanted["54616"] = 2; wanted["54617"] = 2; wanted["54618"] = 1; wanted["54619"] = 2; wanted["54620"] = 1
	end
	for id, count in pairs(wanted) do
		if (given[id] or 0) >= count then
			e.self:CheckHandin(e.other, given, { [id] = count }, items)
		end
	end
	e.self:ReturnHandinItems(e.other)
end

function event_say(e)M.say(e); warwing_say(e) end
function event_trade(e)M.trade(e); warwing_trade(e) end
