--[[
a_dome_crack (423936), three placed in Zhisza.
The Domes are Cracking (task 620108): say "repair" near a crack while the
task is active and an ambush (423937 x4) pours out. Once per crack per
five minutes; the task's kill count (12) covers all three ambushes.
]]

local AMBUSH = 423937;

function event_say(e)
	if e.message:find("repair") or e.message:find("ready") then
		if e.other and not e.other:IsTaskActive(620108) then
			e.self:Say("The crack hums faintly. (You need the engineer's task to work here.)");
			return;
		end
		if (tonumber(e.self:GetEntityVariable("ambush_cd") or "0") or 0) > os.time() then
			e.self:Say("The crack is already defended - finish the ambush!");
			return;
		end
		e.self:SetEntityVariable("ambush_cd", tostring(os.time() + 300));
		e.self:Emote("splits wider with a sound like breaking glass - shissar pour out of the dome wall!");
		for i = 1, 4 do
			local ang = (i / 4) * 6.283;
			eq.spawn2(AMBUSH, 0, 0,
				e.self:GetX() + math.cos(ang) * 20,
				e.self:GetY() + math.sin(ang) * 20,
				e.self:GetZ(), 0);
		end
	elseif e.message:find("hail") then
		e.self:Say("A jagged crack races across the dome. Say 'repair' when you are ready for what comes.");
	end
end

function event_encounter_load(e)
end
