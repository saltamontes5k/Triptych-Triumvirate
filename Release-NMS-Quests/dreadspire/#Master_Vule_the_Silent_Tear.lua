--[[
	#Master_Vule_the_Silent_Tear (351034) - Dreadspire Keep (static, version 0)
	Depths of Darkhollow raid encounter - functional baseline.

	Vule is a static Dreadspire target (no expedition), so the lockout is only
	recorded when a valid expedition is present. The fight adds Dreadspire
	gargoyles in two waves and leashes back to its crypt.
]]

local BOSS_ID = 351034
local EVENT   = "Master Vule the Silent Tear"
local LOCKOUT = eq.seconds("5d12h")

local GARGOYLE = 351126
local ADDS     = { GARGOYLE }

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
	eq.set_next_hp_event(66)
end

function event_combat(e)
	if e.joined then
		eq.set_timer("leash", 6000)
	else
		eq.stop_timer("leash")
		clear_adds()
	end
end

function event_hp(e)
	if e.hp_event == 66 then
		e.self:Emote("gestures, and the crypt's gargoyles stir to life.")
		spawn_add(e, GARGOYLE, 2, 35)
		eq.set_next_hp_event(33)
	elseif e.hp_event == 33 then
		e.self:Emote("hisses, and every shadow in the crypt answers him.")
		spawn_add(e, GARGOYLE, 3, 40)
		e.self:ModifyNPCStat("min_hit", "950")
		e.self:ModifyNPCStat("max_hit", "3400")
	end
end

function event_timer(e)
	if e.timer == "leash" then
		if math.abs(e.self:GetX() - sx) > 350 or math.abs(e.self:GetY() - sy) > 350 then
			e.self:Emote("withdraws into the dark of his crypt.")
			clear_adds()
			e.self:SetHP(e.self:GetMaxHP())
			e.self:WipeHateList()
			e.self:GotoBind()
			eq.set_next_hp_event(66)
		end
	end
end

function event_death_complete(e)
	clear_adds()
	local dz = eq.get_expedition()
	if dz.valid then
		dz:AddLockout(EVENT, LOCKOUT)
	end
	eq.zone_emote(MT.Yellow, "Master Vule lets out a final, silent sigh and is no more.")
end
