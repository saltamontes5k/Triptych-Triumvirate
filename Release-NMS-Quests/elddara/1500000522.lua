-- elddara/1500000522.lua - Brazlin the High Priest of Ro
-- Prophecy of Ro: "The Corruption of Ro" (task 3398). Brazlin shields himself
-- with the Guardian of the High Priest; when the Guardian falls he flees.
local por = require("por_helper");

local function guardian_present()
	local npc = eq.get_entity_list():GetNPCByNPCTypeID(por.npcs.guardian_of_high_priest);
	return npc and npc.valid;
end

local function spawn_guardian(npc)
	if guardian_present() then
		return;
	end
	eq.spawn2(por.npcs.guardian_of_high_priest, 0, 0, npc:GetX() + 6, npc:GetY(), npc:GetZ(), npc:GetHeading());
end

function event_say(e)
	local t = e.message:lower();
	if t:find("hail") then
		e.self:Say("You fools think that you can stop the corruption?");
	elseif t:find("corruption") or t:find("stop") then
		e.self:Say("HA HA HA HA HA HA! Well at least you have a sense of humor. I would like you to meet my little friend. Guardian! Show these pathetic souls what pain is.");
		spawn_guardian(e.self);
	end
end

function event_aggro(e)
	spawn_guardian(e.self);
end
