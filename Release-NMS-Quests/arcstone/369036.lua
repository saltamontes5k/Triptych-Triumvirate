-- arcstone/369036.lua - Zomm the Seventh Born
-- Prophecy of Ro raid. Zomm is guarded by nine Eyes of Zomm (369034). Each eye
-- that is destroyed signals Zomm with its entity id:
--   * if Zomm is engaged, the eye's destruction wounds him for ~7% of his max HP;
--   * if Zomm is idle, the eye is immediately reformed where it stood.
-- The eyes are mez- and root-able and can be split from Zomm; while Zomm is
-- engaged the eyes cannot simply be respawned by leaving him unengaged.
local ZOMM = 369036;
local EYE = 369034;
local NUM_EYES = 9;
local PUPIL_DAMAGE = 0.07;

local eye_pos = {};

local function spawn_eye(e, x, y, z, h)
	local n = eq.spawn2(EYE, 0, 0, x, y, z, h);
	if n.valid then
		eye_pos[n:GetID()] = { x, y, z, h };
	end
end

function event_spawn(e)
	eye_pos = {};
	local cx, cy, cz, ch = e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading();
	for i = 1, NUM_EYES do
		local a = (i - 1) * (math.pi * 2) / NUM_EYES;
		spawn_eye(e, cx + math.cos(a) * 18, cy + math.sin(a) * 18, cz, ch);
	end
end

function event_signal(e)
	local id = e.signal;
	if e.self:GetTarget() ~= nil then
		local dmg = math.floor(e.self:GetMaxHP() * PUPIL_DAMAGE);
		e.self:Damage(e.self, dmg, 0, 0, false);
	else
		local p = eye_pos[id];
		if p ~= nil then
			eye_pos[id] = nil;
			spawn_eye(e, p[1], p[2], p[3], p[4]);
		end
	end
end

function event_death(e)
	eq.depop_all(EYE);
end
