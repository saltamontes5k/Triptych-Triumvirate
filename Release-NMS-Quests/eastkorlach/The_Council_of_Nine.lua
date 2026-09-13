--[[
	The_Council_of_Nine (900208) - The Undershore (eastkorlach)
	Depths of Darkhollow raid encounter - functional baseline.

	The Council is fought as a nine-strong conclave: the lead councilor holds
	the loot table and the other eight are called in as the fight progresses.
	NOTE: the council members are not present in the stock DB, so this is a
	functional reconstruction (name/coords are NMS-authored).
]]

local dodh      = require("dodh_helper")

local BOSS_ID   = 900208
local EVENT     = "The Council of Nine"
local LOCKOUT   = eq.seconds("3d")
local COUNCILOR = 900209
local sx, sy, sz

local function spawn_council(e, count, dist)
	for _ = 1, count do
		local m = eq.spawn2(COUNCILOR, 0, 0,
			e.self:GetX() + math.random(-dist, dist),
			e.self:GetY() + math.random(-dist, dist),
			e.self:GetZ(), e.self:GetHeading())
		local t = e.self:GetTarget()
		if m and t then m:AddToHateList(t, 1) end
	end
end

function event_spawn(e)
	sx, sy, sz = e.self:GetX(), e.self:GetY(), e.self:GetZ()
	eq.set_next_hp_event(80)
	local dz = eq.get_expedition()
	if dz.valid then dz:SetLootEventByNPCTypeID(BOSS_ID, EVENT) end
end

function event_combat(e)
	if e.joined then
		spawn_council(e, 4, 40)
		eq.set_timer("adds", 45000)
		eq.set_timer("leash", 6000)
	else
		eq.stop_timer("adds"); eq.stop_timer("leash"); eq.depop_all(COUNCILOR)
	end
end

function event_hp(e)
	if e.hp_event == 80 then
		e.self:Emote("raises a withered hand and four councilors step from the dark.")
		spawn_council(e, 4, 40)
		eq.set_next_hp_event(50)
	elseif e.hp_event == 50 then
		e.self:Emote("the conclave closes ranks.")
		spawn_council(e, 2, 35)
		eq.set_next_hp_event(25)
	elseif e.hp_event == 25 then
		e.self:Emote("the Nine speak as one, and the air turns to poison.")
		spawn_council(e, 3, 45)
		e.self:ModifyNPCStat("max_hit", "3600")
	end
end

function event_timer(e)
	if e.timer == "adds" then
		spawn_council(e, 2, 45)
	elseif e.timer == "leash" then
		if math.abs(e.self:GetX() - sx) > 400 or math.abs(e.self:GetY() - sy) > 400 then
			e.self:Emote("the Council recedes into the Undershore.")
			eq.depop_all(COUNCILOR)
			e.self:SetHP(e.self:GetMaxHP())
			e.self:WipeHateList(); e.self:GotoBind()
			eq.stop_timer("adds"); eq.set_next_hp_event(80)
		end
	end
end

function event_death_complete(e)
	eq.depop_all(COUNCILOR)
	local dz = eq.get_expedition()
	if dz.valid then dz:AddLockout(EVENT, LOCKOUT) end
	dodh.grant_curse_zone("council")
	eq.zone_emote(MT.Yellow, "The Council of Nine is broken, and the Undershore falls quiet.")
end
