--[[
	Emperor Draygun, the Lich King (350051) - The Nargil Pits (illsalinc, version 2)
	Depths of Darkhollow raid encounter - functional baseline.

	HP phases tear loose fragments of Draygun and his shadows; a periodic wave
	adds more and a leash timer resets the fight if he is pulled from the pits.
]]

local dodh      = require("dodh_helper")

local BOSS_ID   = 350051
local EVENT     = "Emperor Draygun"
local LOCKOUT   = eq.seconds("5d12h")

local FRAGMENT  = 364011
local SHADOW    = 364013
local FRAGMENT2 = 364018
local SHADOW2   = 364016
local ADDS      = { FRAGMENT, SHADOW, FRAGMENT2, SHADOW2 }

local sx, sy, sz

local function spawn_add(e, npc_id, count, dist)
	for _ = 1, count do
		local x = e.self:GetX() + math.random(-dist, dist)
		local y = e.self:GetY() + math.random(-dist, dist)
		local m = eq.spawn2(npc_id, 0, 0, x, y, e.self:GetZ(), e.self:GetHeading())
		local t = e.self:GetTarget()
		if m and t then
			m:AddToHateList(t, 1)
		end
	end
end

local function clear_adds()
	for _, id in ipairs(ADDS) do
		eq.depop_all(id)
	end
end

function event_spawn(e)
	sx, sy, sz = e.self:GetX(), e.self:GetY(), e.self:GetZ()
	eq.set_next_hp_event(80)
	local dz = eq.get_expedition()
	if dz.valid then
		dz:SetLootEventByNPCTypeID(BOSS_ID, EVENT)
	end
end

function event_combat(e)
	if e.joined then
		eq.set_timer("adds", 45000)
		eq.set_timer("leash", 6000)
	else
		eq.stop_timer("adds")
		eq.stop_timer("leash")
		clear_adds()
	end
end

function event_hp(e)
	if e.hp_event == 80 then
		e.self:Emote("raises a withered hand and shadows peel away from his throne.")
		spawn_add(e, SHADOW, 2, 40)
		eq.set_next_hp_event(60)
	elseif e.hp_event == 60 then
		e.self:Emote("shatters, and fragments of the Emperor scatter across the floor.")
		spawn_add(e, FRAGMENT, 2, 40)
		eq.set_next_hp_event(40)
	elseif e.hp_event == 40 then
		e.self:Emote("howls a lich's curse, and the pits crawl with his echoes.")
		spawn_add(e, SHADOW2, 2, 45)
		spawn_add(e, FRAGMENT2, 2, 45)
		eq.set_next_hp_event(20)
	elseif e.hp_event == 20 then
		e.self:Emote("frenzies, the Nargilor Pits trembling with his rage.")
		e.self:ModifyNPCStat("min_hit", "1050")
		e.self:ModifyNPCStat("max_hit", "3700")
	end
end

function event_timer(e)
	if e.timer == "adds" then
		spawn_add(e, SHADOW, 2, 45)
	elseif e.timer == "leash" then
		if math.abs(e.self:GetX() - sx) > 400 or math.abs(e.self:GetY() - sy) > 400 then
			e.self:Emote("fades back into his throne, the dead closing ranks.")
			clear_adds()
			e.self:SetHP(e.self:GetMaxHP())
			e.self:WipeHateList()
			e.self:GotoBind()
			eq.stop_timer("adds")
			eq.set_next_hp_event(80)
		end
	end
end

function event_death_complete(e)
	clear_adds()
	local dz = eq.get_expedition()
	if dz.valid then
		dz:AddLockout(EVENT, LOCKOUT)
	end
	dodh.grant_curse_zone("draygun")
	eq.zone_emote(MT.Yellow, "Emperor Draygun crumbles to dust, and the Nargilor Pits fall dark.")
end
