--[[
	#Korlach, the Deep Leviathan (361048) - Lair of the Korlach (westkorlachc, version 3)
	Depths of Darkhollow raid encounter - functional baseline.

	The leviathan has no reliable add NPCs, so this baseline runs HP phases with
	tidal emotes, regenerative surges and a leash reset if it is pulled from its
	lair. Tune spells/adds to taste.
]]

local BOSS_ID = 361048
local EVENT   = "Korlach, the Deep Leviathan"
local LOCKOUT = eq.seconds("5d12h")

local sx, sy, sz

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
		eq.set_timer("tide", 30000)
		eq.set_timer("leash", 6000)
	else
		eq.stop_timer("tide")
		eq.stop_timer("leash")
	end
end

function event_hp(e)
	if e.hp_event == 75 then
		e.self:Emote("coils in the deep, sending a wall of water crashing through the lair.")
		e.self:SetHP(e.self:GetMaxHP() * 0.90)
		eq.set_next_hp_event(50)
	elseif e.hp_event == 50 then
		e.self:Emote("bellows, its hide hardening against the raid's blows.")
		e.self:ModifyNPCStat("max_hit", "3400")
		eq.set_next_hp_event(25)
	elseif e.hp_event == 25 then
		e.self:Emote("surges upward, the water churning around its bulk.")
		e.self:SetHP(e.self:GetMaxHP() * 0.80)
		eq.set_next_hp_event(10)
	elseif e.hp_event == 10 then
		e.self:Emote("frenzies, its roars shaking the very stone.")
		e.self:ModifyNPCStat("min_hit", "1000")
		e.self:ModifyNPCStat("max_hit", "3800")
	end
end

function event_timer(e)
	if e.timer == "tide" then
		e.self:Emote("lashes out with the tide.")
	elseif e.timer == "leash" then
		if math.abs(e.self:GetX() - sx) > 350 or math.abs(e.self:GetY() - sy) > 350 then
			e.self:Emote("sinks back into the depths of its lair.")
			e.self:SetHP(e.self:GetMaxHP())
			e.self:WipeHateList()
			e.self:GotoBind()
			eq.stop_timer("tide")
			eq.set_next_hp_event(75)
		end
	end
end

function event_death_complete(e)
	local dz = eq.get_expedition()
	if dz.valid then
		dz:AddLockout(EVENT, LOCKOUT)
	end
	eq.zone_emote(MT.Yellow, "Korlach, the Deep Leviathan, sinks for the last time, and the lair falls still.")
end
