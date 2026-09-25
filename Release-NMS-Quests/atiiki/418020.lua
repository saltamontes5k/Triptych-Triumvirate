--[[
Osinzuhazhfet (418020), top of the Atiiki pyramid.
Stone Tongue of Ateleka (task 620100): say "ready" and he raises one
Guardian of Ateleka (423915) at a time; each falls drops a piece of the
tongue's story. Simplified from the live chest-guessing minigame for
solo-friendly play (golem kills drive the task).
]]

local GOLEM = 423915;

function event_say(e)
	if e.message:find("ready") then
		if e.other and not e.other:IsTaskActive(620100) then
			e.self:Say("The tongue sleeps until a seeker undertakes the task, mortal.");
			return;
		end
		if eq.get_entity_list():IsMobSpawnedByNpcTypeID(GOLEM) then
			e.self:Say("A guardian already stands! Deal with it first.");
			return;
		end
		e.self:Emote("slams a stone fist to the pyramid floor - stone grinds against stone as a guardian rises!");
		eq.spawn2(GOLEM, 0, 0,
			e.self:GetX() + math.random(-25, 25),
			e.self:GetY() + math.random(-25, 25),
			e.self:GetZ(), 0);
	elseif e.message:find("hail") then
		e.self:Say("Ssspeak the word 'ready' when you would wake the stone, seeker.");
	end
end

function event_encounter_load(e)
	-- per-NPC file: nothing to register
end
