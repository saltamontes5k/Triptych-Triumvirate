-- arcstone/369070.lua - The Colossus of Skylance
-- Prophecy of Ro raid. At ~12% health the Colossus despawns and bursts into six
-- a_Colossus_shard (369119) NPCs; the shards are rooted/slowed and only the last
-- to fall drops loot (see arcstone/369119.lua).
-- NOTE: the reference also has the Colossus spawn two adds at 50%; no matching
-- add NPC exists in the DB, so that step is not scripted here.
local SHARD = 369119;
local NUM_SHARDS = 6;
local SPLIT_PCT = 12;

local split = false;

function event_hp(e)
	if split then
		return;
	end
	if e.self:GetHPRatio() <= SPLIT_PCT then
		split = true;
		local x, y, z, h = e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading();
		eq.depop();
		for i = 1, NUM_SHARDS do
			local a = (i - 1) * (math.pi * 2) / NUM_SHARDS;
			eq.spawn2(SHARD, 0, 0, x + math.cos(a) * 12, y + math.sin(a) * 12, z, h);
		end
		eq.zone_emote(MT.Yellow, "The Colossus of Skylance shudders and bursts apart into a ring of glimmering shards!");
	end
end
