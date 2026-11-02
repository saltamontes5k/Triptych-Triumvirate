-- illsalinc/Guardian_of_the_Pit.lua
-- Depths of Darkhollow: finale of "Deserting the Ranks" (task 505793).
--
-- When the Guardian falls the Shilgrave dead rise -- the Captain and two
-- legionnaires -- mirroring the live event in which Emperor Draygun reanimates
-- his fallen ranks.  The Captain (350095) carries the Captain's Insignia
-- (86017) that Zahn demands.
--
-- Task / activities / loot: utils/sql/20261016_dodh_illsalinc_deserting.sql

local CAPTAIN = 350095;
local LEGION  = 350035;

local function aggro_zone(mob)
	if not mob then
		return;
	end
	local cl = eq.get_entity_list():GetClientList();
	if not cl then
		return;
	end
	for _, c in ipairs(cl.entries) do
		if c.valid then
			mob:AddToHateList(c, 1);
		end
	end
end

function event_death_complete(e)
	local x, y, z, h = e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading();

	e.self:Emote("shudders and collapses, and the dead of the pits rise in answer.");
	eq.zone_emote(MT.Yellow, "The Guardian of the Pit falls. Emperor Draygun's dead stir in the dark.");

	aggro_zone(eq.spawn2(CAPTAIN, 0, 0, x, y, z, h));

	for _ = 1, 2 do
		aggro_zone(eq.spawn2(LEGION, 0, 0, x + math.random(-25, 25), y + math.random(-25, 25), z, h));
	end
end
