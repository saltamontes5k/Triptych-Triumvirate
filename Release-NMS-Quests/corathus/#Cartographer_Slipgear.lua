-- corathus/#Cartographer_Slipgear.lua
-- Depths of Darkhollow: Slipgear's Errands - the five DoDH exploration tasks
-- (Corathus Creep, Undershore, Stoneroot Falls, The Hive, Ruins of Illsalin).
-- All five offered on hail; completing all five once awards Slipgear's Gem.
-- Tasks live in quests/dodh_errands.sql (505750-505754).

local errands = { 505750, 505751, 505752, 505753, 505754 };

local GEM = 51683; -- Slipgear's Gem
local GEM_FLAG = "dodh.errands_gem";

local function all_errands_done(client)
	for _, id in ipairs(errands) do
		if not client:IsTaskCompleted(id) then
			return false;
		end
	end
	return true;
end

function event_say(e)
	if not e.message:lower():find("hail") then
		return;
	end
	local c = e.other;

	if all_errands_done(c) then
		if (tonumber(c:GetBucket(GEM_FLAG)) or 0) == 0 then
			c:SetBucket(GEM_FLAG, "1");
			if not c:HasItem(GEM) then
				c:SummonFixedItem(GEM);
			end
			e.self:Say("Every landmark charted, from the veins to the falls. You have done a cartographer proud, friend - and done what the rest of the Expedition could not. Take this; it hums when the Deep goes quiet. I never did learn why.");
			c:Message(15, "You have received Slipgear's Gem.");
		else
			e.self:Say("The charts are complete thanks to you. The Deep holds more than ink can hold, but my errands are done.");
		end
		return;
	end

	local offered = 0;
	for _, id in ipairs(errands) do
		if not c:IsTaskActive(id) and not c:IsTaskCompleted(id) then
			c:AssignTask(id, e.self:GetID());
			offered = offered + 1;
		end
	end

	if offered > 0 then
		e.self:Say("A fresh face! Slipgear, cartographer of Expedition 328 - or what is left of it. Five charts need finishing: the Creep we stand in, and the Undershore, Stoneroot, the Hive, and old Illsalin beyond. I have marked every landmark that matters. Walk them all and report back; take the whole bundle at once, if your legs are willing.");
	else
		e.self:Say("The landmarks will still be there when you get back. Walk safe - the sporali do not share the Deep with visitors gladly.");
	end
end
