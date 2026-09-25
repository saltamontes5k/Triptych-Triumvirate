--[[
	Sanguimanus_the_Redfang (900202) - Demi-Plane of Blood (dreadspire, version 1)
	Depths of Darkhollow raid encounter - functional baseline.
]]

local BOSS_ID = 900202
local EVENT   = "Sanguimanus the Redfang"
local LOCKOUT = eq.seconds("2d")
local ADD     = 351156
local sx, sy, sz

local function spawn_add(e, count, dist)
	for _ = 1, count do
		local m = eq.spawn2(ADD, 0, 0,
			e.self:GetX() + math.random(-dist, dist),
			e.self:GetY() + math.random(-dist, dist),
			e.self:GetZ(), e.self:GetHeading())
		local t = e.self:GetTarget()
		if m and t then m:AddToHateList(t, 1) end
	end
end

function event_spawn(e)
	sx, sy, sz = e.self:GetX(), e.self:GetY(), e.self:GetZ()
	eq.set_next_hp_event(66)
	local dz = eq.get_expedition()
	if dz.valid then dz:SetLootEventByNPCTypeID(BOSS_ID, EVENT) end
end

function event_combat(e)
	if e.joined then
		eq.set_timer("adds", 45000)
		eq.set_timer("leash", 6000)
	else
		eq.stop_timer("adds"); eq.stop_timer("leash"); eq.depop_all(ADD)
	end
end

function event_hp(e)
	if e.hp_event == 66 then
		e.self:Emote("bares his red fangs and howls for the pack.")
		spawn_add(e, 2, 35)
		eq.set_next_hp_event(33)
	elseif e.hp_event == 33 then
		e.self:Emote("goes into a blood frenzy.")
		spawn_add(e, 3, 40)
		e.self:ModifyNPCStat("max_hit", "3500")
	end
end

function event_timer(e)
	if e.timer == "adds" then
		spawn_add(e, 2, 45)
	elseif e.timer == "leash" then
		if math.abs(e.self:GetX() - sx) > 350 or math.abs(e.self:GetY() - sy) > 350 then
			e.self:Emote("lopes back into the shadows of the demi-plane.")
			eq.depop_all(ADD)
			e.self:SetHP(e.self:GetMaxHP())
			e.self:WipeHateList(); e.self:GotoBind()
			eq.stop_timer("adds"); eq.set_next_hp_event(66)
		end
	end
end

function event_death_complete(e)
	eq.depop_all(ADD)
	local dz = eq.get_expedition()
	if dz.valid then dz:AddLockout(EVENT, LOCKOUT) end
	eq.zone_emote(MT.Yellow, "Sanguimanus the Redfang falls, his fangs slick with his own blood.")
end
