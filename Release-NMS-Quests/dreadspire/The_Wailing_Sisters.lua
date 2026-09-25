--[[
	The_Wailing_Sisters (900203) - Demi-Plane of Blood (dreadspire, version 1)
	Depths of Darkhollow raid encounter - functional baseline.

	One script drives the three sisters; adds are called in waves.
]]

local BOSS_ID = 900203
local EVENT   = "The Wailing Sisters"
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
	eq.set_next_hp_event(75)
	local dz = eq.get_expedition()
	if dz.valid then dz:SetLootEventByNPCTypeID(BOSS_ID, EVENT) end
end

function event_combat(e)
	if e.joined then
		eq.set_timer("adds", 40000)
		eq.set_timer("leash", 6000)
	else
		eq.stop_timer("adds"); eq.stop_timer("leash"); eq.depop_all(ADD)
	end
end

function event_hp(e)
	if e.hp_event == 75 then
		e.self:Emote("lets out a keening wail that draws the restless dead.")
		spawn_add(e, 3, 35)
		eq.set_next_hp_event(50)
	elseif e.hp_event == 50 then
		e.self:Emote("wails in chorus, and the air itself shudders.")
		spawn_add(e, 3, 40)
		eq.set_next_hp_event(25)
	elseif e.hp_event == 25 then
		e.self:Emote("screams in unison, a dirge of the damned.")
		spawn_add(e, 4, 45)
		e.self:ModifyNPCStat("max_hit", "3500")
	end
end

function event_timer(e)
	if e.timer == "adds" then
		spawn_add(e, 2, 45)
	elseif e.timer == "leash" then
		if math.abs(e.self:GetX() - sx) > 350 or math.abs(e.self:GetY() - sy) > 350 then
			e.self:Emote("fades into the blood mist.")
			eq.depop_all(ADD)
			e.self:SetHP(e.self:GetMaxHP())
			e.self:WipeHateList(); e.self:GotoBind()
			eq.stop_timer("adds"); eq.set_next_hp_event(75)
		end
	end
end

function event_death_complete(e)
	eq.depop_all(ADD)
	local dz = eq.get_expedition()
	if dz.valid then dz:AddLockout(EVENT, LOCKOUT) end
	eq.zone_emote(MT.Yellow, "The Wailing Sisters' song ends at last.")
end
