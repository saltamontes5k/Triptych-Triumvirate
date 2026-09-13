-- northro/392045.lua - Tak`Valnakor
-- Prophecy of Ro: offers the three Ruins of Takish-Hiz level 70 spell tasks.
local por = require("por_helper");

-- Which task activity each sandstone tablet corresponds to (deliver steps 5..9).
local tablet_activity = {
	[36135] = 5, -- Sandstone Tablet Chunk
	[36136] = 6, -- Piece of a Sandstone Tablet
	[36137] = 7, -- Part of a Sandstone Tablet
	[36138] = 8, -- Portion of a Sandstone Tablet
	[36139] = 9, -- Broken Section of a SandStone Tablet
}

local function offer_nro(c, npc)
	if not c:IsTaskCompleted(por.tasks.key_to_the_past) and not c:IsTaskActive(por.tasks.key_to_the_past) then
		c:AssignTask(por.tasks.key_to_the_past);
		npc:Say("Travel to the Ruins of Takish-Hiz and seek Krylin within the overturned tower at location minus four hundred and ten, minus forty. He will open the way into the Root of Ro. Recover the five fragments of the sandstone tablet.");
	elseif not c:IsTaskCompleted(por.tasks.burning_prince) and not c:IsTaskActive(por.tasks.burning_prince) then
		c:AssignTask(por.tasks.burning_prince);
		npc:Say("Speak with Queen Tak`Yaliz in the northern desert. She will send you into the past to put the Burning Prince, Tak`Salir, to rest.");
	elseif not c:IsTaskCompleted(por.tasks.message_from_the_past) and not c:IsTaskActive(por.tasks.message_from_the_past) then
		c:AssignTask(por.tasks.message_from_the_past);
		npc:Say("Speak with Queen Tak`Yaliz once more. Carry word to her younger self before the betrayal is complete.");
	end
end

function event_say(e)
	local t = e.message:lower();
	if t:find("hail") then
		e.self:Say("You there. The desert has given up its secrets and the empire of the Elddar walks again. Will you aid my people?");
	elseif t:find("help") or t:find("task") or t:find("i will") or t:find("visit her") then
		offer_nro(e.other, e.self);
	elseif t:find("suchun") or t:find("blood warden") or t:find("raid") then
		if e.other:IsTaskCompleted(por.tasks.key_to_the_past)
			and e.other:IsTaskCompleted(por.tasks.burning_prince)
			and e.other:IsTaskCompleted(por.tasks.message_from_the_past) then
			if por.enter(e.other, "takishruinsa", "Suchun, the Blood Warden", 1, 54, "6h", "3d") then
				e.self:Say("The Blood Warden waits in the depths. End him, and end this.");
			end
		else
			e.self:Say("Complete my tasks before you seek Suchun. He is not for the unprepared.");
		end
	elseif t:find("spell") or t:find("reward") or t:find("power") then
		if e.other:IsTaskCompleted(por.tasks.key_to_the_past)
			and e.other:IsTaskCompleted(por.tasks.burning_prince)
			and e.other:IsTaskCompleted(por.tasks.message_from_the_past) then
			if (tonumber(e.other:GetBucket("por.takishhiz_reward")) or 0) == 0 then
				if por.grant_rewards(e.other, "takishhiz") > 0 then
					e.other:SetBucket("por.takishhiz_reward", "1");
				end
			end
			e.self:Say("You have done all I asked. Take this knowledge of the old empire; use it well.");
		else
			e.self:Say("Finish what you have begun. The secrets of Takish-Hiz are earned, not given.");
		end
	end
end

function event_trade(e)
	local item_lib = require("items");
	local c = e.other;

	for item_id, activity in pairs(tablet_activity) do
		if item_lib.check_turn_in(e.trade, { item1 = item_id }) then
			c:UpdateTaskActivity(por.tasks.key_to_the_past, activity, 1);
			e.self:Say("A fragment of the old tablet. There are more to be found.");
			return;
		end
	end

	item_lib.return_items(e.self, e.other, e.trade);
end
