--[[
	Mayong_Mistmoore (351118) - Demi-Plane of Blood (dreadspire, version 1)
	Depths of Darkhollow raid encounter - functional baseline.

	Mayong is spawned by spawn2 in the Demi-Plane (see task_sql/dod_raids.sql).
	HP phases bring in his ascendents and the Pact of the Wolf / an unseen force;
	a periodic wave adds more and a leash timer resets the fight.
]]

local dodh    = require("dodh_helper")
local memory  = require("nms_memory")

local BOSS_ID = 351118
local EVENT   = "Mayong Mistmoore"
local LOCKOUT = eq.seconds("5d12h")

local ASCENDANT = 351156
local PACT      = 351142
local UNSEEN    = 351160
local ADDS      = { ASCENDANT, PACT, UNSEEN, 351157, 351166 }

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
	eq.set_next_hp_event(90)
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
	if e.hp_event == 90 then
		e.self:Emote("smiles thinly. 'You will do nicely.'")
		spawn_add(e, ASCENDANT, 2, 40)
		eq.set_next_hp_event(70)
	elseif e.hp_event == 70 then
		e.self:Emote("calls upon the Pact of the Wolf.")
		spawn_add(e, PACT, 1, 30)
		eq.set_next_hp_event(50)
	elseif e.hp_event == 50 then
		e.self:Emote("'The demi-plane is mine. You are merely guests.'")
		spawn_add(e, ASCENDANT, 3, 45)
		e.self:SetHP(e.self:GetMaxHP() * 0.95)
		eq.set_next_hp_event(30)
	elseif e.hp_event == 30 then
		e.self:Emote("unleashes an unseen force.")
		spawn_add(e, UNSEEN, 1, 30)
		spawn_add(e, ASCENDANT, 2, 45)
		eq.set_next_hp_event(10)
	elseif e.hp_event == 10 then
		e.self:Emote("frenzies, his form blurring with ancient power.")
		e.self:ModifyNPCStat("min_hit", "1150")
		e.self:ModifyNPCStat("max_hit", "4000")
	end
end

function event_timer(e)
	if e.timer == "adds" then
		spawn_add(e, ASCENDANT, 2, 45)
	elseif e.timer == "leash" then
		if math.abs(e.self:GetX() - sx) > 400 or math.abs(e.self:GetY() - sy) > 400 then
			e.self:Emote("dissolves into mist and reforms upon his throne.")
			clear_adds()
			e.self:SetHP(e.self:GetMaxHP())
			e.self:WipeHateList()
			e.self:GotoBind()
			eq.stop_timer("adds")
			eq.set_next_hp_event(90)
		end
	end
end

function event_death_complete(e)
	clear_adds()
	local dz = eq.get_expedition()
	if dz.valid then
		dz:AddLockout(EVENT, LOCKOUT)
	end
	-- Defeating Mayong awards the full Curse of Blood set and immunity to the
	-- blood-raid curses, matching the live encounter.
	dodh.grant_all_curses_zone()
	dodh.grant_mayong_immunity_zone()
	eq.zone_emote(MT.Yellow, "Mayong Mistmoore's laughter fades, and the Demi-Plane of Blood begins to unravel.")

	-- NMS progression: Demi-Plane Mayong is a Prophecy of Ro gate
	-- (distinct objective from the Solteris Mayong Mistmoore used for SoF)
	memory.spawn(e, "PoR", "mayong mistmoore dreadspire")
end
