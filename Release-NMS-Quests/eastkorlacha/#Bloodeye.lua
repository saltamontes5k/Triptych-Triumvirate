--[[
	#Bloodeye (363029) - Snarlstone Dens (eastkorlacha, version 2)
	Depths of Darkhollow raid encounter - functional baseline.

	HP phases call down crows; a periodic wave adds more and a leash timer resets
	the fight if he is dragged out of the dens.
]]

local dodh    = require("dodh_helper")

local BOSS_ID = 363029
local EVENT   = "Bloodeye"
local LOCKOUT = eq.seconds("5d12h")

local CROW_A  = 422017
local CROW_B  = 422067
local ADDS    = { CROW_A, CROW_B }

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
	eq.set_next_hp_event(75)
	local dz = eq.get_expedition()
	if dz.valid then
		dz:SetLootEventByNPCTypeID(BOSS_ID, EVENT)
	end
end

function event_combat(e)
	if e.joined then
		eq.set_timer("adds", 40000)
		eq.set_timer("leash", 6000)
	else
		eq.stop_timer("adds")
		eq.stop_timer("leash")
		clear_adds()
	end
end

function event_hp(e)
	if e.hp_event == 75 then
		e.self:Emote("throws back his head and howls, and the sky answers with beating wings.")
		spawn_add(e, CROW_A, 3, 40)
		eq.set_next_hp_event(50)
	elseif e.hp_event == 50 then
		e.self:Emote("snarls and the flock swells.")
		spawn_add(e, CROW_B, 2, 40)
		eq.set_next_hp_event(25)
	elseif e.hp_event == 25 then
		e.self:Emote("goes berserk, his flock shrieking in answer.")
		spawn_add(e, CROW_A, 3, 50)
		e.self:ModifyNPCStat("min_hit", "900")
		e.self:ModifyNPCStat("max_hit", "3300")
		eq.set_next_hp_event(10)
	elseif e.hp_event == 10 then
		e.self:Emote("frenzies, blood matting his fur.")
		e.self:ModifyNPCStat("min_hit", "1100")
		e.self:ModifyNPCStat("max_hit", "3800")
	end
end

function event_timer(e)
	if e.timer == "adds" then
		spawn_add(e, CROW_B, 2, 45)
	elseif e.timer == "leash" then
		if math.abs(e.self:GetX() - sx) > 350 or math.abs(e.self:GetY() - sy) > 350 then
			e.self:Emote("lopes back into the shadows of the dens.")
			clear_adds()
			e.self:SetHP(e.self:GetMaxHP())
			e.self:WipeHateList()
			e.self:GotoBind()
			eq.stop_timer("adds")
			eq.set_next_hp_event(75)
		end
	end
end

function event_death_complete(e)
	clear_adds()
	local dz = eq.get_expedition()
	if dz.valid then
		dz:AddLockout(EVENT, LOCKOUT)
	end
	dodh.grant_curse_zone("bloodeye")
	eq.zone_emote(MT.Yellow, "Bloodeye falls, and the last of his flock scatters into the dark.")
end
