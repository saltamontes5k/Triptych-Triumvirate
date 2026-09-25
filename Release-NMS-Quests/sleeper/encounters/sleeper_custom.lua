-- Sleepers 2.0 (zone version 0) -- Kerafyrm's Chamber.
--
-- The four Ancients (Kildrukaun, Vyskudra, Tjudawos, Zeixshi-Kar) and The Final
-- Arbiter are the five seals of Kerafyrm's prison. Kerafyrm (#Kerafyrm, 128089)
-- stands visible but untargetable in the chamber for as long as any seal lives;
-- when the last seal falls he becomes targetable and the fight begins.
--
-- The classic Warder wake chain (kill the four Warders -> The Sleeper spawns
-- Kerafyrm -> he walks out) is gone. The Warder spawn condition is switched off
-- in favor of the Ancients, and the Ancients no longer despawn just because
-- Kerafyrm is present.
--
-- Slaying Kerafyrm drops a memory (global/26000.pl) that grants the SoD
-- "kerafyrm" objective; the Crystallos Kerafyrm grants the matching
-- "kerafyrm-crystallos" objective. Both are required to complete SoD.

local kerafrym_id = 128089;
local seal_ids    = { 128041, 128042, 128043, 128044, 128143 }; -- 4 Ancients + Final Arbiter

-- Resurrected servants / prismatic cultists Kerafyrm summons during the fight.
local event_npcs        = { 128020, 128259, 128291, 128292, 128293, 128241, 128243, 128242, 128244 };
local event_dragon_adds = { 128259, 128291, 128292, 128293, 128241, 128243, 128242, 128244 };

local next_event_hp = 90;
local unlocked      = false;
local seals_seen    = false;

-- True while any of the five seals is still standing.
local function seals_alive()
	local el = eq.get_entity_list();
	for _, id in ipairs(seal_ids) do
		if el:IsMobSpawnedByNpcTypeID(id) then
			return true;
		end
	end
	return false;
end

function evt_kera_spawn(e)
	unlocked = false;
	e.self:SetTargetable(false);
	e.self:SetSpecialAbility(24, 1); -- aggro immunity while sealed
	e.self:SetSpecialAbility(35, 1); -- cannot be harmed by clients while sealed
	seals_seen = false;
	eq.set_timer("sealcheck", 10000);
end

-- Called from Kerafyrm's own "sealcheck" timer, so eq.set_next_hp_event applies
-- to Kerafyrm himself.
function UnlockKerafyrm(e)
	if unlocked then
		return;
	end
	unlocked = true;

	e.self:SetSpecialAbility(24, 0); -- clear aggro immunity
	e.self:SetSpecialAbility(35, 0); -- clear harm-from-client immunity
	e.self:SetTargetable(true);
	e.self:Emote("shatters the prismatic ward and rises to his full height!");
	e.self:Shout("So the seals are broken at last. Come then, lesser things -- and be ended.");

	local door = eq.get_entity_list():FindDoor(46);
	if door.valid then
		door:SetLocation(500, 500, 500);
	end

	next_event_hp = 90;
	eq.set_next_hp_event(next_event_hp);
end

function evt_kera_combat(e)
	if not unlocked then
		return; -- still sealed; should not be reachable while untargetable
	end

	if e.joined then
		e.self:Emote(" ROARS!");

		eq.set_timer("aggrolink", 3 * 1000);
		eq.set_timer("TankAEDMG", math.random(1000, 3000));
		eq.stop_timer("reset");
	else -- he should never be completely off aggro; wipe/cheese guard
		e.self:Shout("Flee puny mortal, Flee for your life, I will be waiting here for you, more powerful than ever!");
		eq.debug("[Sleeper Event] - Event reset due to empty aggro table");
		reset_event(e);
	end
end

function evt_kera_timer(e)
	if e.timer == "sealcheck" then
		if seals_alive() then
			seals_seen = true; -- never unlock before the seals have existed at least once
		elseif seals_seen then
			eq.stop_timer("sealcheck");
			UnlockKerafyrm(e);
		end
		return;
	end

	eq.stop_timer(e.timer);

	if e.timer == "TankAEDMG" then
		eq.set_timer("TankAEDMG", 30 * 1000);
		-- Prismatic beam around the tank.
		e.self:CastSpell(42231, e.self:GetTarget():GetID());
	elseif e.timer == "AE" then
		eq.zone_emote(MT.Emote, "The dragon unleashes a wave of prismatic energy!");
		e.self:CameraEffect(1000, 5);
		e.self:CastSpell(23150, e.self:GetID());
		eq.stop_timer("TankAEDMG");
		eq.set_timer("TankAEDMG", 30 * 1000);

		if e.self:GetHPRatio() <= 25 then
			eq.set_timer("AE", 20 * 1000);
		else
			eq.set_timer("AE", 30 * 1000);
		end
	elseif e.timer == "SpawnAdds" then
		SpawnAdds(e);
	elseif e.timer == "aggrolink" then
		local npc_list = eq.get_entity_list():GetNPCList();
		for npc in npc_list.entries do
			if npc.valid and not npc:IsEngaged() and (npc:GetNPCTypeID() == 128020 or npc:GetNPCTypeID() == 128259 or npc:GetNPCTypeID() == 128291 or npc:GetNPCTypeID() == 128292 or npc:GetNPCTypeID() == 128293 or npc:GetNPCTypeID() == 128241 or npc:GetNPCTypeID() == 128243 or npc:GetNPCTypeID() == 128242 or npc:GetNPCTypeID() == 128244) then
				npc:AddToHateList(e.self:GetHateRandom(), 1);
			end
		end
	end
end

function evt_kera_hp(e)
	if e.hp_event == 90 or e.hp_event == 85 or e.hp_event == 80 then
		e.self:Shout("I THOUGHT YOU WEREN'T AFRAID OF ME ANYMORE!");
		e.self:CastSpell(6790, e.self:GetID()); -- Spell: terrifying roar

		next_event_hp = next_event_hp - 5;
		eq.set_next_hp_event(next_event_hp);

		local hate_list = e.self:CountHateList();
		if hate_list ~= nil and tonumber(hate_list) > 1 then
			local top_hate = e.self:GetHateTop();
			if top_hate.valid and top_hate:IsClient() then
				local top_hate_v = top_hate:CastToClient()
				if top_hate_v.valid then
					e.self:SetHate(top_hate_v, 1, 1)
				end
			end
		end
	elseif e.hp_event == 75 then
		e.self:Shout("YOU! WARDER! LIVE AGAIN AND SERVE ME!");
		SpawnWarder(e)
		eq.set_next_hp_event(50);
	elseif e.hp_event == 50 then
		e.self:Shout("THIS IS NOT HOW I WILL BE REMEMBERED!");
		eq.set_timer("AE", math.random(1000, 3000));
		eq.set_next_hp_event(25);
	elseif e.hp_event == 25 then
		eq.stop_timer("AE");
		e.self:Shout("GUARDS! Assist me!");
		e.self:CameraEffect(2000, 5);
		eq.zone_emote(MT.Emote, "Flapping of strong wings can be heard in the distance.");
		eq.set_timer("SpawnAdds", 60 * 1000);
	end
end

function evt_kera_death_complete(e)
	e.self:Shout("So then... my fate is sealed... until we meet again.");
end

function SpawnAdds(e)
	local xloc = e.self:GetX() + 75;
	local yloc = e.self:GetY() + 25;
	local zloc = e.self:GetZ();
	local heading = e.self:GetHeading();

	eq.zone_emote(MT.Emote, "Cultists of the Prismatic Scale have arrived!");

	for _ = 1, 10 do
		eq.spawn2(128020, 0, 0, xloc + math.random(-50, 50), yloc + math.random(-50, 50), zloc, heading):AddToHateList(e.self:GetHateRandom(), 1);
	end
end

function SpawnWarder(e)
	local x, y, z, h = e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading();
	local warder_spawn = eq.spawn2(event_dragon_adds[math.random(1, #event_dragon_adds)], 0, 0, x + 75, y + 25, z, h);

	if warder_spawn.valid then
		warder_spawn:CastToNPC():Shout("I LIVE AGAIN! Master, your wish is my command!")
		warder_spawn:CastToNPC():AddToHateList(e.self:GetHateTop(), 2000);
	end
end

function reset_event(e)
	eq.stop_all_timers();
	e.self:WipeHateList();
	e.self:GotoBind();
	e.self:BuffFadeAll();
	e.self:SetHP(e.self:GetMaxHP());
	e.self:SetTargetable(true);
	next_event_hp = 90;
	eq.set_next_hp_event(next_event_hp);

	for i = 1, #event_npcs do
		eq.depop_all(event_npcs[i])
	end
end

function evt_add_spawn(e)
	eq.set_timer("depop", 5 * 60 * 1000);
end

function evt_add_combat(e)
	if e.joined then
		if not eq.is_paused_timer("depop") then
			eq.pause_timer("depop");
		end
	else
		eq.resume_timer("depop");
	end
end

function evt_add_timer(e)
	if e.timer == "depop" then
		eq.depop();
	end
end

function event_encounter_load(e)
	-- Register handlers here; the bubble spawn/bootstrap happens post-Repop
	-- from the Sleeper_Tomb_Gatekeeper (1520000010.pl).
	eq.register_npc_event("sleeper_custom", Event.spawn,          kerafrym_id, evt_kera_spawn);
	eq.register_npc_event("sleeper_custom", Event.combat,         kerafrym_id, evt_kera_combat);
	eq.register_npc_event("sleeper_custom", Event.hp,             kerafrym_id, evt_kera_hp);
	eq.register_npc_event("sleeper_custom", Event.timer,          kerafrym_id, evt_kera_timer);
	eq.register_npc_event("sleeper_custom", Event.death_complete, kerafrym_id, evt_kera_death_complete);

	for i = 1, #event_npcs do
		eq.register_npc_event("sleeper_custom", Event.spawn,  event_npcs[i], evt_add_spawn);
		eq.register_npc_event("sleeper_custom", Event.combat, event_npcs[i], evt_add_combat);
		eq.register_npc_event("sleeper_custom", Event.timer,  event_npcs[i], evt_add_timer);
	end

	-- The seal set / bubble bootstrap runs post-Repop from
	-- 1520000010.pl (Sleeper_Tomb_Gatekeeper), which swaps the spawn
	-- conditions and spawns Kerafyrm in the chamber. See that script.
end
