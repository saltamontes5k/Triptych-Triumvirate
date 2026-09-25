--[[
Akarahotuten (418071), atop the Atiiki pyramid.
  The Great Invasion (620101): first hail spawns the efreeti honor guard
  (423916 x2) and the invading shissar wave (423917 x10, 423918 x4).
  Fate of the Combine (620102): hail spawns Emperor Zhizuzun (423919).
Both spawn once per entity (entity-variable guarded); the NPCs are static
in the instance, so re-hailing after a wipe re-fights whatever remains.
]]

local EFREETI  = 423916;
local INVADER  = 423917;
local PRIEST   = 423918;
local ZHIZUZUN = 423919;

function event_say(e)
	if e.message:find("hail") then
		if e.other:IsTaskActive(620101) then
			if e.self:GetEntityVariable("invasion_started") ~= "1" then
				e.self:SetEntityVariable("invasion_started", "1");
				e.self:Emote("raises a burning hand! 'To arms, nobles of fire - the invaders are upon us!'");
				for i = 1, 2 do
					eq.spawn2(EFREETI, 0, 0,
						e.self:GetX() + (i == 1 and 20 or -20), e.self:GetY() + 15, e.self:GetZ(), 0);
				end
				for i = 1, 10 do
					local ang = (i / 10) * 6.283;
					eq.spawn2(INVADER, 0, 0,
						e.self:GetX() + math.cos(ang) * 60,
						e.self:GetY() + math.sin(ang) * 60,
						e.self:GetZ(), 0);
				end
				for i = 1, 4 do
					local ang = (i / 4) * 6.283 + 0.7;
					eq.spawn2(PRIEST, 0, 0,
						e.self:GetX() + math.cos(ang) * 80,
						e.self:GetY() + math.sin(ang) * 80,
						e.self:GetZ(), 0);
				end
			else
				e.self:Say("The battle rages, mortal - see it done!");
			end
		elseif e.other:IsTaskActive(620102) then
			if eq.get_entity_list():IsMobSpawnedByNpcTypeID(ZHIZUZUN) then
				e.self:Say("The Emperor already walks!");
			else
				e.self:SetEntityVariable("zhizu_spawned", "1");
				e.self:Emote("whispers to the temple, and the memory of an emperor answers.");
				eq.spawn2(ZHIZUZUN, 0, 0, e.self:GetX() + 30, e.self:GetY() + 30, e.self:GetZ(), 0);
			end
		else
			e.self:Say("The pyramid is quiet... for now.");
		end
	end
end

function event_encounter_load(e)
end
