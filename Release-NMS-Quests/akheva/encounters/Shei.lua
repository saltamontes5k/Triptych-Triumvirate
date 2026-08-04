-- Shei (179157/179032) event in Akheva ruins

-- NPCs
local fake_shei			= 179157;
local real_shei			= 179032;
local secondary_adds	= {179142, 179147, 179160, 179161};

local primary_adds		= {
	[179174] = {-1714, 1128, 20, 256};	-- NPC: #Diabo_Tatrua
	[179181] = {-1769, 1035, 20, 90};	-- NPC: #Tavuel_Tatrua
	[179164] = {-1771, 1126, 20, 164};	-- NPC: #Thall_Tatrua
	[179173] = {-1715, 1034, 20, 0};	-- NPC: #Va_Tatrua
};

-- Vars
local dt_timer		= false;
local dt_spellid	= 2859;		-- (982: Cazic touch, 2859: Touch of Vinitras)
local dt_recast		= 2 * 60;	-- (in seconds)

-- Exclude Spells
local DA_spell_table = {
	130,	--Harmshield
	199, 	--Divine Barrier
	207,	--Divine Aura	
	1612,	--Quivering Veil of Xarn
	1749,	--Kazumi's Note of Preservation
	2741	--Sacred Barrier
};

-- Encounter
function evt_add_death(e)
	if eq.get_entity_list():IsMobSpawnedByNpcTypeID(real_shei) or eq.get_entity_list():IsMobSpawnedByNpcTypeID(fake_shei) then
		local id = e.self:GetNPCTypeID()
		local loc = primary_adds[id]
		
		if loc then
			local newadd = eq.spawn2(id, 0, 0, loc[1], loc[2], loc[3], loc[4])
			eq.set_timer('depop', 120 * 60 * 1000, newadd)
		end
	end
end


function evt_slay(e)
	if e.other:IsClient() or e.other:IsPet() then -- not sure why this is necessary, but otherwise will occasionally spawn adds when an event mob dies
		if eq.get_entity_list():IsMobSpawnedByNpcTypeID(real_shei) or eq.get_entity_list():IsMobSpawnedByNpcTypeID(fake_shei) then
			e.self:Emote('strikes through the chest of the corpse, rending the soul from the flesh and animating it into an undead servant.')
			local mob		= eq.ChooseRandom(unpack(secondary_adds));
			local newadd	= eq.spawn2(mob,0,0,e.other:GetX(),e.other:GetY(),e.other:GetZ(),e.other:GetHeading());
			eq.set_timer('depop', 2 * 60 * 60 * 1000, newadd);
		end
	end
end

function evt_add_timer(e)
    if e.timer == "depop" then
       eq.depop()
    end
end

function evt_shei_combat(e)
	if e.joined then
		local add_cheese = false
		e.self:Say('Sivuelaeus Rulour ans Rashan!');

		for id,loc in pairs(primary_adds) do
			if not eq.get_entity_list():IsMobSpawnedByNpcTypeID(id) then
				add_cheese = true;
			end
		end

		if add_cheese then
			for id,loc in pairs(primary_adds) do
				local newadd = eq.unique_spawn(id,0,0,loc[1],loc[2],loc[3],loc[4]);
				eq.set_timer('depop', 2 * 60 * 60 * 1000, newadd);
			end
		end

		if e.self:GetNPCTypeID() == real_shei then
			if not dt_timer then
				eq.set_timer("shei_dt",math.random(2,6) * 1000);
				dt_timer = true;
			end
			eq.set_timer('aggro_guards', 30 * 1000);
			eq.set_timer("shei_despawn_full", 60 * 60 * 1000);
		end
	else
		if e.self:GetNPCTypeID() == real_shei then
			eq.stop_timer("shei_dt");
			eq.stop_timer('aggro_guards');
		end
	end
end

function evt_fake_shei_death(e)
	eq.unique_spawn(real_shei, 0, 0, -1736, 1082, 22.6, 128);
end

function evt_shei_timer(e)
	eq.stop_timer(e.timer);

	if e.timer == "shei_dt" then
		if e.self:IsEngaged() then
			local target = e.self:GetHateTop();

			if target:DivineAura() then
				for n = 1 , #DA_spell_table do
					if target:FindBuff(DA_spell_table[n]) then
						target:BuffFadeBySpellID(DA_spell_table[n])
					end
				end
			end

 			if target:IsPet() then
				target = target:GetOwner();
			end

			e.self:SpellFinished(dt_spellid,target);
			e.self:Shout(string.format("%s!", string.upper(target:GetName())));
			eq.stop_timer(e.timer);
			eq.set_timer("shei_dt",dt_recast * 1000);
		else
			dt_timer = false;
			eq.stop_timer("shei_dt");
		end
	elseif e.timer == 'aggro_guards' then
		aggro_guards(e.self:GetTarget());
		eq.set_timer("aggro_guards", 30 * 1000);
	elseif e.timer == "shei_despawn_full" then
		e.self:Depop();
	end
end

function aggro_guards(mob)
	for guard,_ in pairs(primary_adds) do
		local guard_mob = eq.get_entity_list():GetNPCByNPCTypeID(guard);
		if guard_mob ~= nil then
			guard_mob:AddToHateList(mob);
		end
	end
end

function event_encounter_load(e)
	dt_timer = false;

	eq.register_npc_event("Shei", Event.combat,				fake_shei,			evt_shei_combat);
	eq.register_npc_event("Shei", Event.timer,				fake_shei,			evt_shei_timer);
	eq.register_npc_event("Shei", Event.slay,				fake_shei,			evt_slay);
	eq.register_npc_event("Shei", Event.death_complete,		fake_shei,			evt_fake_shei_death);

	eq.register_npc_event("Shei", Event.combat,				real_shei,			evt_shei_combat);
	eq.register_npc_event("Shei", Event.timer,				real_shei,			evt_shei_timer);
	eq.register_npc_event("Shei", Event.slay,				real_shei,			evt_slay);

	for id,loc in pairs(primary_adds) do
		eq.register_npc_event("Shei", Event.death_complete, id,					evt_add_death);
		eq.register_npc_event("Shei", Event.slay,			id,					evt_slay);
		eq.register_npc_event("Shei", Event.timer,			id,					evt_add_timer);
	end

	for i = 1, #secondary_adds do
		eq.register_npc_event("Shei", Event.death_complete, secondary_adds[i],	evt_add_death);
		eq.register_npc_event("Shei", Event.slay,			secondary_adds[i],	evt_slay);
		eq.register_npc_event("Shei", Event.timer,			secondary_adds[i],	evt_add_timer);
	end
end
