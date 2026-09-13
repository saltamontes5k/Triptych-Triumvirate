--[[
	Sendaii, the Hive Queen (357016) - Queen Sendaii's Lair (drachnidhivec, version 1)
	Depths of Darkhollow raid encounter - functional baseline.

	HP phases fill the lair with pulsing eggs; a periodic wave adds more and a
	leash timer resets the fight if she is pulled out of the chamber.
]]

local dodh    = require("dodh_helper")

local BOSS_ID = 357016
local EVENT   = "Sendaii, the Hive Queen"
local LOCKOUT = eq.seconds("5d12h")

local EGG     = 357015
local ADDS    = { EGG }

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
		eq.set_timer("adds", 50000)
		eq.set_timer("leash", 6000)
	else
		eq.stop_timer("adds")
		eq.stop_timer("leash")
		clear_adds()
	end
end

function event_hp(e)
	if e.hp_event == 80 then
		e.self:Emote("lets out a piercing chitter and the lair begins to pulse with new eggs.")
		spawn_add(e, EGG, 3, 45)
		eq.set_next_hp_event(60)
	elseif e.hp_event == 60 then
		e.self:Emote("screeches, calling her brood to her side.")
		spawn_add(e, EGG, 2, 45)
		eq.set_next_hp_event(40)
	elseif e.hp_event == 40 then
		e.self:Emote("slams her forelegs down and the floor crawls with spawn!")
		spawn_add(e, EGG, 4, 55)
		eq.set_next_hp_event(20)
	elseif e.hp_event == 20 then
		e.self:Emote("frenzies, her brood swarming to defend the Queen.")
		e.self:ModifyNPCStat("min_hit", "950")
		e.self:ModifyNPCStat("max_hit", "3400")
	end
end

function event_timer(e)
	if e.timer == "adds" then
		spawn_add(e, EGG, 2, 50)
	elseif e.timer == "leash" then
		if math.abs(e.self:GetX() - sx) > 400 or math.abs(e.self:GetY() - sy) > 400 then
			e.self:Emote("withdraws into the dark of her lair.")
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
	dodh.grant_curse_zone("sendaii")
	eq.zone_emote(MT.Yellow, "Sendaii shudders once and is still. The Hive falls silent.")
end
