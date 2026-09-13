--[[
	Matriarch Shyra (359037) - Lodge of the Fang (westkorlacha, version 3)
	Depths of Darkhollow raid encounter - functional baseline.

	HP phases call the Lodge's defenders; a periodic wave adds followers and a
	leash timer resets the fight if she is pulled away from the Lodge.
]]

local dodh      = require("dodh_helper")

local BOSS_ID   = 359037
local EVENT     = "Matriarch Shyra"
local LOCKOUT   = eq.seconds("5d12h")

local SHADOW    = 359031
local FOLLOWER  = 359033
local PROTECTOR = 359038
local ENFORCER  = 359039
local ADDS      = { SHADOW, FOLLOWER, PROTECTOR, ENFORCER }

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
		e.self:Emote("snarls a command and her protector and enforcer step from the shadows.")
		spawn_add(e, PROTECTOR, 1, 30)
		spawn_add(e, ENFORCER, 1, 30)
		eq.set_next_hp_event(60)
	elseif e.hp_event == 60 then
		e.self:Emote("calls up a shadow of herself to fight at her side.")
		spawn_add(e, SHADOW, 1, 25)
		eq.set_next_hp_event(40)
	elseif e.hp_event == 40 then
		e.self:Emote("howls, and the Lodge answers.")
		spawn_add(e, FOLLOWER, 3, 45)
		eq.set_next_hp_event(20)
	elseif e.hp_event == 20 then
		e.self:Emote("frenzies, her rage driving the pack into a bloodlust.")
		e.self:ModifyNPCStat("min_hit", "950")
		e.self:ModifyNPCStat("max_hit", "3400")
	end
end

function event_timer(e)
	if e.timer == "adds" then
		spawn_add(e, FOLLOWER, 2, 45)
	elseif e.timer == "leash" then
		if math.abs(e.self:GetX() - sx) > 400 or math.abs(e.self:GetY() - sy) > 400 then
			e.self:Emote("retreats into the Lodge, the pack closing ranks behind her.")
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
	dodh.grant_curse_zone("shyra")
	eq.zone_emote(MT.Yellow, "Matriarch Shyra falls, and the Lodge of the Fang falls silent.")
end
