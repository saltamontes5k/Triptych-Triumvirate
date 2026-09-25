--[[
Emperor Zhizuzun (423919) - Fate of the Combine (task 620102).
The emperor flees through the temple memory: at 80/60/40% he shatters and
reforms nearby (depop + respawn at an offset, shed aggro). At 20% he makes
his last stand - the final phase must be fought to death so the task's
kill activity completes naturally.
]]

local PHASES = { 80, 60, 40 };

function event_combat(e)
	if e.joined then
		e.self:SetTimerMS("phase", 2 * 1000);
	else
		e.self:StopTimer("phase");
	end
end

function event_timer(e)
	if e.timer == "phase" then
		local pct = e.self:GetHPRatio();
		local phase = tonumber(e.self:GetEntityVariable("phase") or "1") or 1;

		if phase <= #PHASES and pct <= PHASES[phase] then
			e.self:SetEntityVariable("phase", tostring(phase + 1));
			e.self:Emote("shatters into motes of golden light, reforming elsewhere in the temple!");
			local x, y, z = e.self:GetX(), e.self:GetY(), e.self:GetZ();
			e.self:Depop();
			local next_form = eq.spawn2(423919, 0, 0, x + math.random(-70, 70), y + math.random(-70, 70), z, 0);
			if next_form ~= nil then
				next_form:SetEntityVariable("phase", tostring(phase + 1));
				local t = e.self:GetTarget();
				if t ~= nil then
					next_form:AddToHateList(t, 1);
				end
			end
		else
			if phase == 4 and pct <= 20 and (tonumber(e.self:GetEntityVariable("last_stand") or "0") or 0) == 0 then
				e.self:SetEntityVariable("last_stand", "1");
				e.self:Emote("makes his last stand - 'The Combine is DUST, and I am its memory!'");
			end
			e.self:SetTimerMS("phase", 2 * 1000);
		end
	end
end

function event_death_complete(e)
	eq.zone_emote(MT.Red, "The memory of Emperor Zhizuzun fades. Akarahotuten emerges, waiting to be hailed.");
end

function event_encounter_load(e)
end
