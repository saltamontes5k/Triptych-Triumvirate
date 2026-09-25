--[[
Xao Aulin (423928) - The Hydromancer (task 620107), Thalassius.
Every 60 seconds in combat he calls a wave: a darkwater clawfiend
(423929), a raging sea dervish (423930) and two sea mephits (423931),
capped at 12 live adds. Adds persist after his death per the guide.
]]

local CLAWFIEND = 423929;
local DERVISH   = 423930;
local MEPHIT    = 423931;

function event_combat(e)
	if e.joined then
		e.self:SetTimerMS("adds", 10 * 1000);
		e.self:Emote("Xao Aulin spreads his arms - the water itself rises against you!");
	else
		e.self:StopTimer("adds");
	end
end

function event_timer(e)
	if e.timer == "adds" then
		-- summon one full wave every minute while engaged
		eq.spawn2(CLAWFIEND, 0, 0, e.self:GetX() + 30, e.self:GetY() + 20, e.self:GetZ(), 0);
		eq.spawn2(DERVISH, 0, 0, e.self:GetX() - 30, e.self:GetY() + 20, e.self:GetZ(), 0);
		eq.spawn2(MEPHIT, 0, 0, e.self:GetX() + 20, e.self:GetY() - 30, e.self:GetZ(), 0);
		eq.spawn2(MEPHIT, 0, 0, e.self:GetX() - 20, e.self:GetY() - 30, e.self:GetZ(), 0);
		eq.zone_emote(MT.Red, "Darkwater creatures boil up around Xao Aulin!");
		e.self:SetTimerMS("adds", 60 * 1000);
	end
end

function event_death_complete(e)
	eq.zone_emote(MT.Red, "Xao Aulin's wards fail - but his creatures remain. Clean up or flee!");
end

function event_encounter_load(e)
end
