--[[
	Antraygus, the Sporali King (366028) - Sporali Caverns (corathusa, version 1)
	Depths of Darkhollow raid encounter - functional baseline.

	HP phases release sporali adds; a periodic wave tops them up and a leash
	timer resets the fight if the raid drags him out of the cavern.
]]

local BOSS_ID = 366028
local EVENT   = "Antraygus, the Sporali King"
local LOCKOUT = eq.seconds("5d12h")

local STOUT   = 366020
local GLOWING = 366021
local MINDS   = 366023
local REPLEN  = 366024
local SHAMAN  = 366025
local ADDS    = { STOUT, GLOWING, MINDS, REPLEN, SHAMAN }

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
		eq.set_timer("adds", 45000)
		eq.set_timer("leash", 6000)
	else
		eq.stop_timer("adds")
		eq.stop_timer("leash")
		clear_adds()
	end
end

function event_hp(e)
	if e.hp_event == 75 then
		e.self:Emote("shudders and tears loose a cloud of spores.")
		spawn_add(e, STOUT, 3, 40)
		eq.set_next_hp_event(50)
	elseif e.hp_event == 50 then
		e.self:Emote("calls its shaman to mend its wounds.")
		spawn_add(e, SHAMAN, 2, 40)
		e.self:SetHP(e.self:GetMaxHP())
		eq.set_next_hp_event(25)
	elseif e.hp_event == 25 then
		e.self:Emote("lets out a deafening shriek as its spores erupt.")
		spawn_add(e, GLOWING, 4, 50)
		eq.set_next_hp_event(10)
	elseif e.hp_event == 10 then
		e.self:Emote("frenzies, its body swollen with spores.")
		e.self:ModifyNPCStat("min_hit", "900")
		e.self:ModifyNPCStat("max_hit", "3200")
	end
end

function event_timer(e)
	if e.timer == "adds" then
		spawn_add(e, REPLEN, 2, 45)
	elseif e.timer == "leash" then
		if math.abs(e.self:GetX() - sx) > 350 or math.abs(e.self:GetY() - sy) > 350 then
			e.self:Emote("recedes into the cavern, its spores settling.")
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
	eq.zone_emote(MT.Yellow, "The Sporali King collapses, his spores drifting away on the still air.")
end
