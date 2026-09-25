-- Sleeper's Tomb 1.0 -- classic Al'Kabor "awaken the Sleeper" encounter.
-- Looted from EQMacEmu/quests (sleeper/encounters/Sleeper.lua) and adapted to
-- this server: the warders/sleeper are instance-local clones, and Kerafyrm
-- walks a real engine grid with wander type GridOneWayDepop.
local CONTROLLER_TYPE = 128134; -- StaticShoutOne
local SLEEPER_TYPE    = 1520000005; -- #The_Sleeper (asleep, clone)
local KERAFYRM_TYPE   = 128089; -- #Kerafyrm (awakened, walks out)
local GRID_ID         = 1520000000; -- walk path, type 6 = GridOneWayDepop
local WARDER_TYPES    = { 1520000001, 1520000002, 1520000003, 1520000004 };
local SIGNAL_TYPES    = { 119112, 120084, 32040, 73057, 108510, 123011 }; -- nag, vox, klandicar etc

function ControllerSignal(e)
	if ( e.signal == 1 ) then
		local sleeper = eq.get_entity_list():GetNPCByNPCTypeID(SLEEPER_TYPE);
		if ( not sleeper.valid ) then
			eq.debug("Sleeper NPC is missing; aborting");
			return;
		end

		local rng = math.random(33); -- 3% chance to wake
		if ( rng > 1 ) then
			eq.debug("All warders killed and Sleeper roll failed. ("..rng..")");
			return;
		end

		local kerafyrm = eq.spawn2(KERAFYRM_TYPE, GRID_ID, 0, sleeper:GetX(), sleeper:GetY(), sleeper:GetZ(), sleeper:GetHeading()):CastToNPC();
		sleeper:Depop();

		kerafyrm:SetSpecialAbility(24, 0); -- remove aggro immunity
		kerafyrm:SetSpecialAbility(35, 0); -- remove harm-from-client immunity

		kerafyrm:Shout("I AM FREE!");

		local npcList = eq.get_entity_list():GetNPCList();
		for npc in npcList.entries do
			if ( npc.valid and npc:GetPrimaryFaction() == 472 ) then -- Warders of The Claw
				npc:SetNPCAggro(true);
			end
		end

		for _, t in ipairs(SIGNAL_TYPES) do
			eq.signal(t, 1);
		end
	end
end

function WarderDeath(e)
	for _, id in ipairs(WARDER_TYPES) do
		if ( eq.get_entity_list():IsMobSpawnedByNpcTypeID(id) ) then
			return;
		end
	end
	eq.debug("all warders slain");
	eq.signal(CONTROLLER_TYPE, 1, 25000);
end

function event_encounter_load(e)
	for _, id in ipairs(WARDER_TYPES) do
		eq.register_npc_event("Sleeper", Event.death_complete, id, WarderDeath);
	end

	eq.register_npc_event("Sleeper", Event.signal, CONTROLLER_TYPE, ControllerSignal);
end
