-- If you found this, please don't spoil it for everyone else. This will be EPIC.
-- If I catch you spoiling this before velious release, you WILL be banned.

local event_npcs				= {128020, 128259, 128291, 128292, 128293, 128241, 128043, 128042, 128044};
local event_dragon_adds			= {128259, 128291, 128292, 128293, 128241, 128243, 128242, 128244}
local next_event_hp				= 90;
local kerafrym_id       		= 128089;
local warder_instance_status	= 0;

function evt_kera_spawn(e)
	e.self:Shout("Insolent lesser races, in thanks for freeing me from centuries of slumber, I shall grant you a quick death!");
    eq.get_entity_list():FindDoor(46):SetLocation(500, 500, 500);
	eq.set_next_hp_event(next_event_hp);
end

function evt_kera_combat(e)
	if e.joined then
		eq.depop_all(128020); -- Sanity Check
		e.self:Emote(" ROARS!");

		--lets get some pressure on the tank, and anyone who is stupid enough
		--be in front of the mob :)
        eq.set_timer("aggrolink", 3 * 1000);
		eq.set_timer("TankAEDMG", math.random(1000,3000));
		eq.stop_timer("reset");

		-- Sanity Depop incase a warder is left up from a previous wipe and zone idled.
		for i = 1, #event_npcs do
			eq.depop_all(event_npcs[i])
		end
	else -- He should never be completely off aggro, if so someone is trying to cheese or is wiping and trying to get away.
        e.self:Shout("Flee puny mortal, Flee for your life, I will be waiting here for you, more powerful than ever!");
        eq.debug("[Sleeper Event] - Event reset due to empty aggro table")
		reset_event(e);
	end
end

function evt_kera_timer(e)
	eq.stop_timer(e.timer);
	if e.timer == "TankAEDMG" then
		eq.set_timer("TankAEDMG",30 * 1000);

		--Prismatic beam, 1.5k to 2.5k -100 Prismatic resist. 75% resist max
		--AOE dmg around the tank
		e.self:CastSpell(42231,e.self:GetTarget():GetID());
	elseif e.timer == "AE" then
		--big bada boom time, once every 60 sec
		eq.zone_emote(MT.Emote, "The dragon unleashes a wave of prismatic energy!");
		e.self:CameraEffect(1000,5);
		e.self:CastSpell(23150,e.self:GetID())
		eq.stop_timer("TankAEDMG"); --lets not overlap our tank buster AE with the 60 sec AE
		eq.set_timer("TankAEDMG",30 * 1000); --lets go again in 30 sec!

		if e.self:GetHPRatio() <= 25 then
			eq.set_timer("AE", 20 * 1000); --if under 25% change to every 20 seconds
		else
			eq.set_timer("AE", 30 * 1000); --if above 25% every 30 sec
		end
	elseif e.timer == "SpawnAdds" then
		SpawnAdds(e);
    elseif e.timer == "aggrolink" then
		local npc_list =  eq.get_entity_list():GetNPCList();
		for npc in npc_list.entries do
			if npc.valid and not npc:IsEngaged() and (npc:GetNPCTypeID() == 128020 or npc:GetNPCTypeID() == 128259 or npc:GetNPCTypeID() == 128291 or npc:GetNPCTypeID() == 128292 or npc:GetNPCTypeID() == 128293 or npc:GetNPCTypeID() == 128241 or npc:GetNPCTypeID() == 128243 or npc:GetNPCTypeID() == 128242 or npc:GetNPCTypeID() == 128244) then
				npc:AddToHateList(e.self:GetHateRandom(),1);
			end
		end
	end
end

function evt_kera_hp(e)
	if e.hp_event == 90 or e.hp_event == 85 or e.hp_event == 80 then
		e.self:Shout("'I THOUGHT YOU WEREN'T AFRAID OF ME ANYMORE!");
		e.self:CastSpell(6790,e.self:GetID()); --Spell: terrifying roar, -1k resist poison, 300 range

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
		eq.set_timer("AE", math.random(1000,3000));
		eq.set_next_hp_event(25);
	elseif e.hp_event == 25 then
		eq.stop_timer("AE");
		e.self:Shout("GUARDS! Assist me!");
		e.self:CameraEffect(2000,5);
		eq.zone_emote(MT.Emote,"Flapping of strong wings can be heard in the distance.");
		eq.set_timer("SpawnAdds",60 * 1000);
	end
end

function evt_kera_death_complete(e)
	e.self:Shout("So then... my fate is sealed... until we meet again.");
end

function SpawnAdds(e)
	local xloc = e.self:GetX()+75;
	local yloc = e.self:GetY()+25;
	local zloc = e.self:GetZ();
	local heading = e.self:GetHeading();

	eq.zone_emote(MT.Emote,"Cultists of the Prismatic Scale have arrived!");

	eq.spawn2(128020,0,0,xloc + math.random(-50,50),yloc + math.random(-50,50),zloc,heading):AddToHateList(e.self:GetHateRandom(),1);
	eq.spawn2(128020,0,0,xloc + math.random(-50,50),yloc + math.random(-50,50),zloc,heading):AddToHateList(e.self:GetHateRandom(),1);
	eq.spawn2(128020,0,0,xloc + math.random(-50,50),yloc + math.random(-50,50),zloc,heading):AddToHateList(e.self:GetHateRandom(),1);
	eq.spawn2(128020,0,0,xloc + math.random(-50,50),yloc + math.random(-50,50),zloc,heading):AddToHateList(e.self:GetHateRandom(),1);
	eq.spawn2(128020,0,0,xloc + math.random(-50,50),yloc + math.random(-50,50),zloc,heading):AddToHateList(e.self:GetHateRandom(),1);
	eq.spawn2(128020,0,0,xloc + math.random(-50,50),yloc + math.random(-50,50),zloc,heading):AddToHateList(e.self:GetHateRandom(),1);
	eq.spawn2(128020,0,0,xloc + math.random(-50,50),yloc + math.random(-50,50),zloc,heading):AddToHateList(e.self:GetHateRandom(),1);
	eq.spawn2(128020,0,0,xloc + math.random(-50,50),yloc + math.random(-50,50),zloc,heading):AddToHateList(e.self:GetHateRandom(),1);
	eq.spawn2(128020,0,0,xloc + math.random(-50,50),yloc + math.random(-50,50),zloc,heading):AddToHateList(e.self:GetHateRandom(),1);
	eq.spawn2(128020,0,0,xloc + math.random(-50,50),yloc + math.random(-50,50),zloc,heading):AddToHateList(e.self:GetHateRandom(),1);
end

function SpawnWarder(e)
    local x,y,z,h = e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading();
    local warder_spawn = eq.spawn2(event_dragon_adds[math.random(1,#event_dragon_adds)], 0, 0, x + 75, y + 25, z, h);

	if warder_spawn.valid then
        warder_spawn:CastToNPC():Shout("I LIVE AGAIN! Master, your wish is my command!")
		warder_spawn:CastToNPC():AddToHateList(e.self:GetHateTop(),2000);
	end
end

function reset_event(e)
	eq.stop_all_timers();
	e.self:WipeHateList();
	e.self:GotoBind();
	e.self:BuffFadeAll();
	e.self:SetHP(e.self:GetMaxHP());
	next_event_hp		= 90;
	eq.set_next_hp_event(next_event_hp);

	for i = 1, #event_npcs do
		eq.depop_all(event_npcs[i])
	end
end

function evt_add_spawn(e)
	warder_instance_status	= tonumber(eq.get_data("Sleeper_Warder_Status-"..eq.get_zone_instance_id())) or 0;

	if warder_instance_status == 1 then -- Clear item list if mob was previously spawned and killed in this instance to prevent exploit farming.
		e.self:ClearItemList();
	end
	eq.set_timer("depop", 5 * 60 * 1000);
end

function evt_add_combat(e)
	local kerafrym = eq.get_entity_list():GetMobByNpcTypeID(kerafrym_id);

	-- Sanity Check, if Kerafrym is up and is >= 95% hp then depop the add in question
	if kerafrym.valid then
		if kerafrym:CastToNPC():GetHPRatio() >= 95 then
			eq.depop();
		end
	end

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

function evt_warder_death(e)
	eq.set_data("Sleeper_Warder_Status-"..eq.get_zone_instance_id(), "1","H6");
end

function event_encounter_load(e)
	eq.register_npc_event("sleeper_custom",     Event.spawn,			    kerafrym_id,    		evt_kera_spawn);
	eq.register_npc_event("sleeper_custom",     Event.combat,			    kerafrym_id,    		evt_kera_combat);
	eq.register_npc_event("sleeper_custom",     Event.hp,				    kerafrym_id,    		evt_kera_hp);
	eq.register_npc_event("sleeper_custom",     Event.timer,			    kerafrym_id,    		evt_kera_timer);
	eq.register_npc_event("sleeper_custom",     Event.death_complete,	    kerafrym_id,    		evt_kera_death_complete);

	for i = 1, #event_npcs do
		eq.register_npc_event("sleeper_custom",     Event.spawn,			event_npcs[i],  		evt_add_spawn);
		eq.register_npc_event("sleeper_custom",     Event.combat,			event_npcs[i],  		evt_add_combat);
		eq.register_npc_event("sleeper_custom",     Event.timer,			event_npcs[i],			evt_add_timer);
	end

	for i = 1, #event_dragon_adds do
		eq.register_npc_event("sleeper_custom",     Event.death_complete,	event_dragon_adds[i],	evt_warder_death);
	end

	warder_instance_status	= tonumber(eq.get_data("Sleeper_Warder_Status-"..eq.get_zone_instance_id())) or 0
end