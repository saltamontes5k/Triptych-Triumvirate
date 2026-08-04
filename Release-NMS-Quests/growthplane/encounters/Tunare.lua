-- Tunare Encounter - Growth Plane

local tunare1		= 127001;
local tunare2		= 127098;
local controller	= 127097;

-- set to true to enable debug messages
local show_debug = false;

function TunareSpawn(e)
	eq.set_timer("SpawnTunare",1000);
end

function TunareTimer(e)
	if e.timer == "SpawnTunare" then
		eq.stop_timer("SpawnTunare");
		eq.unique_spawn(tunare1,0,0,-1632,1525,206,0); -- Tunare back in her tree.
	end
end

function TunareSignal(e)
	if e.signal == 1 then
		eq.unique_spawn(tunare2,0,0,-247,1609,-40,424); -- NPC: #Tunare
		eq.depop(tunare1);
	elseif e.signal == 2 then
		eq.unique_spawn(tunare1,0,0,-1632,1525,206,0); -- reset Tunare back in her tree.
		eq.depop(tunare2);
	elseif e.signal == 3 then
		eq.depop_with_timer(); -- set the respawn timer
	end
end

function TunareCombat(e)
	if e.joined then
		eq.signal(controller,1); -- send signal to spawn the 2nd Tunare.
	end
end

function Tunare2Spawn(e)
	eq.set_timer("depop",900000);
end

function Tunare2Timer(e)
	if e.timer == "depop" then
		eq.stop_timer(e.timer)
		eq.signal(controller,2);
	elseif e.timer == "assist_check" then
		call_zone_to_assist(e);
	end
end

function Tunare2Combat(e)
	if e.joined then
		call_zone_to_assist(e);
		if not eq.is_paused_timer("depop") then
			eq.pause_timer("depop");
		end
		eq.set_timer("assist_check", 1 * 60 * 1000);
	else
		eq.stop_timer("assist_check");
		eq.resume_timer("depop");
	end
end

function Tunare2Death(e)
	eq.signal(controller,3);

	local killer = eq.get_entity_list():GetClientByID(e.killer_id)
    if killer and killer:GetLevel() <= 60 then
        killer:CastToClient():SetBucket('flag-semaphore', '204')
        killer:Signal(100)
    end

	eq.stop_timer("depop");
end

function call_zone_to_assist(e)
	-- grab the entity list
	local entity_list = eq.get_entity_list();
	-- aggro the zone onto whoever attacked me.
	-- do not aggro these mobs #_Tunare (127001), #Tunare (127098), a_warm_light (127004)
	-- #BouncerMan (127097), Prince_Thirneg (127096), a_thifling_focuser (127006 and 127005)
	local exclude_npc_list = Set {127001,127004,127097,127098,127096,127006,127005};
	local npc_list = entity_list:GetNPCList();
	if npc_list ~= nil then
		for npc in npc_list.entries do
			if exclude_npc_list[npc:GetNPCTypeID()] == nil then
				-- npc.valid will be true if the NPC is actually spawned
				if npc.valid then
					npc:CastToNPC():AddToHateList(e.self:GetHateRandom(),1);
					if show_debug then eq.debug("NPCID: " .. npc:GetNPCTypeID() .. " is valid, adding hate on " .. npc:GetName() .. "."); end
				else
					if show_debug then eq.debug("NPCID: " .. npc:GetNPCTypeID() .. " is invalid, unable to add hate on " .. npc:GetName() .. "."); end
				end
			else
				if show_debug then eq.debug("NPCID: " .. npc:GetNPCTypeID() .. " is excluded, not adding hate on " .. npc:GetName() .. "."); end
			end
		end
	end
end

function Set (list)
	local set = {}
	for _, l in ipairs(list) do set[l] = true end
	return set
end

function event_encounter_load(e)
	eq.register_npc_event("Tunare", Event.spawn,            controller, TunareSpawn);
	eq.register_npc_event("Tunare", Event.timer,            controller, TunareTimer);
	eq.register_npc_event("Tunare", Event.signal,           controller, TunareSignal);
	eq.register_npc_event("Tunare", Event.combat,           tunare1,	TunareCombat);
	eq.register_npc_event("Tunare", Event.spawn,            tunare2,	Tunare2Spawn);
	eq.register_npc_event("Tunare", Event.timer,            tunare2,	Tunare2Timer);
	eq.register_npc_event("Tunare", Event.combat,           tunare2,	Tunare2Combat);
	eq.register_npc_event("Tunare", Event.death_complete,   tunare2,	Tunare2Death);
end