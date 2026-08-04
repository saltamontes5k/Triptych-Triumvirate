-- Khati Sha Encounter

-- Event Vars
local as_event_failed			= false;
local as_event_started			= false;
local kr_event_failed			= false;
local kr_event_started			= false;
local boss						= false;
local wol_activated				= false;
local dialog_started			= false;
local life_seal					= false;
local death_seal				= false;
local ChantCounterA				= 0;
local ChantCounterB				= 0;
local chant_timer				= 60
local fail_timer				= 10 --default value (in minutes)
local scenario					= 1;
local deathguard_counter		= 0;
local arcanist_counter			= 0;
local leash_counter				= 0;
local as_chants					= 0;
local kr_chants					= 0;
local instance_id				= 0;

-- Event NPCS
local arcanist_trigger			= 154322;
local khati_sha_npc				= 154138;
local warder_of_life_npc		= 154154;
local warder_of_death_npc		= 154155;
local arcanist_true				= 154151;
local arcanist_false			= 154152;
local arcanist_final			= 154153;
local a_sacrifice				= 154150;
local spell_jammer				= 154147;
local defiled_minion			= 154054;
local spiritist_andro_shimi		= 154053;
local spiritist_kama_resan		= 154052;
local WDTrpMn					= 154130;
local a_deathguard				= 154358;
local elite_deathguard			= 154059;
local spiritwarder_true			= 154348;
local spiritwarder_false		= 154349;
local a_grimling_guard			= 154344;
local arcanists					= {arcanist_true, arcanist_false};
local grimling_spiritwarders	= {spiritwarder_true, spiritwarder_false};

-- Event Locs
local guard_locs				= {[1] = {361,-255,-8,384}, [2] = {326, -255, -8, 127}, [3] = {326, -215, -8, 127}, [4] = {361, -215, -8, 384}, [5] = {326, -295, -8, 127}, [6] = {326, -342, -8, 127}, [7] = {361, -295, -8, 384}, [8] = {361, -342, -8, 384}};
local west_grimling_locs		= {[1] = {615,-375,-23,128}, [2] = {655,-375,-23,374}, [3] = {635,-355,-23,256}, [4] = {635,-395,-23,0}};
local east_grimling_locs		= {[1] = {520,-375,-23,128}, [2] = {560,-375,-23,374}, [3] = {540,-355,-23,256}, [4] = {540,-395,-23,0}};
local deathguard_locs			= {[1] = {670,-388,-23,384}, [2] = {660,-388,-23,384}, [3] = {670,-363,-23,384}, [4] = {660,-363,-23,384}};
local khati_guard_locs			= {[1] = {972,-556,-41,330}, [2] = {970,-602,-41,442}, [3] = {910,-602,-41,70}, [4] = {905,-556,-41,182}};
local jammer_locs_A				= {[1] = {321,-258,-7,56}, [2] = {363,-259,-7,456}, [3] = {344,-207,-7,256}};	-- Jail Cell A (Kama)
local jammer_locs_B				= {[1] = {322,-294,-7,204}, [2] = {364,-296,-7,308}, [3] = {344,-347,-7,512}};	-- Jail Cell B (Andro)
local sacrifice_locs			= {[1] = {433,-338,36,260}, [2] = {393,-298,36,63}, [3] = {433,-258,36,128}};
local arcanist_locs				= {[1] = {540,-375,-24,128}, [2] = {635,-375,-24,380}};

local cells_xloc				= {344,344};	-- Cells: (1) Kama's (2) Andro's  
local cells_yloc				= {-232,-323};	-- Cells: (1) Kama's (2) Andro's  

-- Arcanist Trigger Logic
function evt_trigger_spawn(e)
	Setup();
	eq.depop(spiritist_kama_resan);		-- NPC: Spiritist_Kama_Resan
	eq.depop(spiritist_andro_shimi);	-- NPC: Spiritist_Andro_Shimi
	eq.set_timer("fail", 60 * 60 * 1000);  --60 min
	scenario = math.random(1,2);
	if scenario == 1 then
		eq.unique_spawn(arcanists[1],0,0,unpack(arcanist_locs[1]));	-- NPC: Spiritual Arcanist V1 (True Arcanist)
		eq.unique_spawn(arcanists[2],0,0,unpack(arcanist_locs[2]));	-- NPC: Spiritual Arcanist V2 (False Arcanist)

		SpawnMobs(spiritwarder_true,east_grimling_locs);
		SpawnMobs(spiritwarder_false,west_grimling_locs);
	else
		eq.unique_spawn(arcanists[2],0,0,unpack(arcanist_locs[1]));	-- NPC: Spiritual Arcanist V1 (False Arcanist)
		eq.unique_spawn(arcanists[1],0,0,unpack(arcanist_locs[2]));	-- NPC: Spiritual Arcanist V2 (True Arcanist)

		SpawnMobs(spiritwarder_false,east_grimling_locs);
		SpawnMobs(spiritwarder_true,west_grimling_locs);
	end
end

function evt_trigger_timer(e)
	if e.timer == "fail" then
		eq.stop_timer(e.timer);
		for n = 1,2 do 
			eq.depop(arcanists[n]);
			eq.depop_all(grimling_spiritwarders[n]);
		end
		eq.depop(arcanist_final);
		eq.depop();
	end
end

function evt_trigger_signal(e)
	instance_id	= eq.get_zone_instance_id();

	if e.signal == 2 then
		boss = true;
	elseif e.signal == 20 then
		deathguard_counter = deathguard_counter + 1;
		if deathguard_counter >= 4 and not eq.get_entity_list():IsMobSpawnedByNpcTypeID(arcanist_final) and not eq.get_entity_list():IsMobSpawnedByNpcTypeID(a_deathguard) then 	-- Success - opens last seal and progresses event to final stage (requires deathguards and false grimling arcanist dead (if triggered)
			if eq.get_entity_list():IsMobSpawnedByNpcTypeID(khati_sha_npc) then -- NPC: Khati_Sha_the_Twisted
				eq.signal(arcanist_true,1)	 -- signals True Arcanist (if correct scenario chosen otherwise he will not be up)
				eq.set_global(instance_id.. "_IAC_Seal_2","1",3,"H2");	-- sets flag on 4 panel door to advance
				eq.zone_emote(MT.DimGray,"The caverns rumble and shake violently as the third protective seal is broken. Khati Sha shouts, 'Who dares break the seals and defile the inner sanctum?! Come forth so that I may crush you!'");
				SpawnMobs(elite_deathguard,deathguard_locs);
				eq.signal(khati_sha_npc,30); -- signal Khati`Sha to Activate (become targetable)
			elseif boss then	-- false arcanist dialogue
				eq.zone_emote(MT.Red,"Despite the Arcanist's warning, the halls beyond the sealed door remain silent and empty. Khati Sha has no interest in holding audience with you on this day...");
				eq.depop();
			else				-- true arcanist dialogue
				eq.zone_emote(MT.Red,"The arcanist appears much relieved to be released from that magical bondage. Having broken the seal and defeated the imposter, you attempt to open the door, yet it does not move... It appears that Khati Sha has no interest in holding audience with you on this day...");
				eq.depop();
			end
		end
	end
end

-- Spiritwarders
function evt_spiritwarders_spawn(e)
	e.self:SetSpecialAbility(24, 1); -- No Aggro
	eq.set_next_hp_event(99);
end

function evt_spiritwarders_combat(e)
	if e.joined then
		e.self:SetSpecialAbility(24,0); -- Allow Aggro
		eq.signal(e.self:GetNPCTypeID(),1);
	end
end

function evt_spiritwarders_signal(e)
	if e.signal == 1 then
		e.self:SetSpecialAbility(24,0);
	end
end

function evt_spiritwarders_hp(e)
	if e.hp_event == 99 then
		e.self:SetSpecialAbility(24,0);
		eq.signal(e.self:GetNPCTypeID(),1);	--signals other spiritwarders of same NPC type ID to aggro/assist
	end
end

-- Warder of Death
function evt_wod_spawn(e)
	eq.set_timer("sacrifice", math.random(15,30) * 1000);
	eq.unique_spawn(154396,0,0,433,-298,37,260) -- NPC: #a_sacrificial_cauldron
end

function evt_wod_timer(e)
	if e.timer == "sacrifice" then
		eq.stop_timer(e.timer);
		eq.set_timer("sacrifice", math.random(30,45) * 1000);
		eq.spawn2(a_sacrifice,0,0,unpack(sacrifice_locs[math.random(1,3)]));	-- NPC: a_sacrifice 
	end
end

function evt_wod_combat(e)
	if e.joined then
		e.self:Say("As guardian of the second seal, hear this: Mine is the seal of death, and only a fool would attempt to defeat it. You rush headlong to your demise.")
	end
end

function evt_wod_signal(e)
	if e.signal == 10 then	-- Event failure - timer up
		eq.depop(154396);	-- NPC: #a_sacrificial_cauldron
		eq.depop();
	end
end

function evt_wod_death_complete(e)
	eq.signal(WDTrpMn,11);	-- NPC: WDTrpMn - signal death seal is broken
	eq.zone_emote(MT.Red,"The Death Ward has been defeated. The second seal is broken.")
	eq.depop(154396);		-- NPC: #a_sacrificial_cauldron
end

-- Warder of Life
function evt_wol_spawn(e)
	eq.set_timer("adds", math.random(90,150) * 1000);
	ChantCounterA	= 0;
	ChantCounterB	= 0;
	wol_activated	= false;
	deactivate(e.self);
end

function evt_wol_timer(e)
	if e.timer == "adds" then
		SpawnAdds(math.random(1,3),1);	-- Spawns 1-3 adds in Kama's Cell
		SpawnAdds(math.random(1,3),2);	-- Spawns 1-3 adds in Andro's Cell
	end
end

function evt_wol_combat(e)
	if e.joined then
		e.self:Say("As the guardian of the first seal, hear this: The first seal is life, and it shall not be broken. None shall pass and death to those who would attempt to thwart me. Be gone!")
	end
end

function evt_wol_signal(e)
	if e.signal == 90 then
		ChantCounterA = ChantCounterA + 1;
		ChantSumCheck(e,ChantCounterA,ChantCounterB);
	elseif e.signal == 95 then
		ChantCounterB = ChantCounterB + 1;
		ChantSumCheck(e,ChantCounterA,ChantCounterB);
	end
end

function evt_wol_death_complete(e)
	eq.signal(WDTrpMn,10); -- NPC: WDTrpMn
	eq.zone_emote(MT.Red,"The Life Ward has been defeated. The first seal is broken.")
end

-- Arcanist_True
function evt_arcanist_true_spawn(e)
	eq.set_timer("warder_check", 1 * 1000);
end

function evt_arcanist_true_timer(e)
	if e.timer == "warder_check" then
		if not eq.get_entity_list():IsMobSpawnedByNpcTypeID(spiritwarder_true) then
			eq.stop_timer("dialogue");
			eq.stop_timer(e.timer);
			eq.depop_all(spiritwarder_false);
			eq.signal(arcanist_false,1);
			eq.signal(arcanist_false,1);
			if scenario == 1 then
				SpawnMobs(a_deathguard,east_grimling_locs);
			else
				SpawnMobs(a_deathguard,west_grimling_locs);
			end

			e.self:DoAnim(36);	-- kneeling
			e.self:Emote("collapses to his knees before you, the strain of the magical field about him obviously weakening him. After a moment, he stands, and says, 'You have chosen wisely, child, but this is only the first step, now you must vanquish this evil being, but beware, I will be unable to help you, as this seal has left me magically drained.");
			eq.depop(arcanist_false);
			eq.depop_all(spiritwarder_false);
			eq.set_timer("deathguard_check", 1 * 1000);
		end
	elseif e.timer == "deathguard_check" then
		if not eq.get_entity_list():IsMobSpawnedByNpcTypeID(a_deathguard) then
			eq.stop_timer(e.timer);
			eq.spawn2(arcanist_final,0,0,e.self:GetX(),e.self:GetY(),e.self:GetZ(), e.self:GetHeading());
		end
	elseif e.timer == "depop" then
		eq.depop();
	end
end

function evt_arcanist_true_signal(e)
	if e.signal == 1 then 	-- Signal received upon death of the 4 death guards
		e.self:Emote("is clearly exhausted, speaking only two words before cloaking himself from your field of view. You hear a faint noise near the door, just before several grimlings appear, trying to stop you from entering the door. A voice booms from somewhere inside the caverns, 'Farewell, warriors, and may you possess the strength to vanquish the evil beyond this doorway.");
		eq.depop();
	elseif e.signal == 10 then
		eq.stop_all_timers();
		e.self:SetAppearance(3);
		eq.set_timer("depop",10 * 1000);
	elseif e.signal == 80 then
		e.self:Say("Don't listen to him! Unbind me and I can help you.")
	elseif e.signal == 81 then
		e.self:Say("Do not set him free! You shall need my help for this! Free me!")
	elseif e.signal == 82 then
		e.self:Say("He lies! Free me and we shall fight together and destroy that evil being!")
	elseif e.signal == 83 then
		e.self:Say("Help, please! Destroy this barrier I am a prisoner!")
	elseif e.signal == 84 then
		e.self:Say("Faster, please! You must make a decision!")
	elseif e.signal == 85 then
		e.self:Say("He is trying to pressure you, follow your instincts. I am the one you need!");
	end
end

-- Arcanist_False
function evt_arcanist_false_spawn(e)
	eq.clear_proximity();
	eq.set_proximity(510, 535, -335, -315);
	arcanist_counter = 0;
	eq.set_timer("warder_check", 1 * 1000);
end

function evt_arcanist_false_timer(e)
	if e.timer == "warder_check" then
		if not eq.get_entity_list():IsMobSpawnedByNpcTypeID(spiritwarder_false)	then
			eq.stop_timer("dialogue");
			eq.stop_timer(e.timer);

			if scenario == 1 then
				SpawnMobs(a_deathguard,west_grimling_locs);
			else
				SpawnMobs(a_deathguard,east_grimling_locs);
			end

			eq.signal(arcanist_trigger,2);		-- signal arcanist_trigger that false arcanist is up
			eq.signal(arcanist_true,10);		-- signal true arcanist for failure emote
			eq.depop_all(spiritwarder_true);	-- depop other spiritwarders
			eq.set_timer("deathguard_check", 1 * 1000);
		end
	elseif e.timer == "deathguard_check" then
		if not eq.get_entity_list():IsMobSpawnedByNpcTypeID(a_deathguard) then
			eq.stop_timer(e.timer);

			eq.set_global(instance_id.. "_IAC_Seal_2","1",3,"H2");	-- sets flag on 4 panel door to advance
			eq.zone_emote(MT.DimGray,"The caverns rumble and shake violently as the third protective seal is broken. Khati Sha shouts, 'Who dares break the seals and defile the inner sanctum?! Come forth so that I may crush you!'");
			eq.spawn2(elite_deathguard,0,0,684,-389,-23,384);
			eq.spawn2(elite_deathguard,0,0,684,-379,-23,384);
			eq.spawn2(elite_deathguard,0,0,684,-369,-23,384);
			eq.spawn2(elite_deathguard,0,0,684,-359,-23,384);
			eq.signal(khati_sha_npc,30); -- signal Khati`Sha to Activate (become targetable)

			eq.depop_all(a_deathguard);
			eq.depop_all(arcanist_true);
			eq.depop_all(spiritwarder_true);
			eq.depop_all(arcanist_false);
			eq.depop_all(spiritwarder_false);
		end
	elseif e.timer == "dialogue" then
		arcanist_counter = arcanist_counter + 1;
		if arcanist_counter == 1 then
			e.self:Say("Psst, come here. This way. Tear down this barrier of magic, set me free!")
			eq.stop_timer(e.timer);
			eq.set_timer("dialogue", 20 * 1000);
			eq.signal(arcanist_true,80);
		elseif arcanist_counter == 2 then
			e.self:Say("Can't you see?  We are not the same! See the truth and make haste!")
			eq.stop_timer(e.timer);
			eq.set_timer("dialogue", 40 * 1000);
			eq.signal(arcanist_true,81, 20 * 1000);
		elseif arcanist_counter == 3 then
			e.self:Say("Listen carefully, you must choose wisely, only one of us can help you. Please break this circle and let me free!")
			eq.signal(arcanist_true,82, 20 * 1000);
		elseif arcanist_counter == 4 then
			e.self:Say("Help, please! Destroy this barrier I am a prisoner!")
			eq.signal(arcanist_true,83, 20 * 1000);
		elseif arcanist_counter == 5 then
			e.self:Say("We've become magically locked inside these seals, and these grimlings have been set here to reinforce the circle! Defeat these grimlings, and free me!")
			eq.signal(arcanist_true,84, 20 * 1000);
		elseif arcanist_counter == 6 then
			e.self:Say("Break the circle, and break the seal! Time is growing short.")
			eq.signal(arcanist_true,85, 20 * 1000);
			arcanist_counter = 1;
		end
	end
end

function evt_arcanist_false_enter(e)
	if not dialog_started then
		dialog_started = true;
		eq.set_timer("dialogue", 1 * 1000);
	end
end

function evt_arcanist_false_signal(e)
	if e.signal == 1 then
		e.self:SetAppearance(3);  -- Laydown
	end
end

-- Arcanist Boss
function evt_arcanist_final_spawn(e)
	eq.set_timer("depop", 60 * 60 * 1000);  -- 60 min depop
	eq.set_timer("leash", 1);
end

function evt_arcanist_final_timer(e)
	if e.timer == "depop" then
		eq.depop();
	elseif e.timer == "leash" then
		if e.self:GetY() >= -315 then
			e.self:GotoBind();
			e.self:WipeHateList();
			e.self:SpellFinished(3230,e.self); -- Spell: Balance of the Nameless
			e.self:BuffFadeAll();
		end
	end
end

function evt_arcanist_final_death_complete(e)
	eq.signal(arcanist_trigger,20);
end

-- a sacrafice
function evt_sacrifice_spawn(e)
	eq.set_timer("path", 2 * 1000);
	eq.set_next_hp_event(50);
end

function evt_sacrifice_timer(e)
	if e.timer == "path" then
		eq.set_timer("loc_check",1);
		eq.move_to(433,-298,36,260,true);	-- Moves to #a_sarificial_cauldron
	elseif e.timer == "loc_check" then
		if e.self:GetX() == 433 and e.self:GetY() == -298 and e.self:GetZ() == 36 then
			local cauldron = eq.get_entity_list():GetMobByNpcTypeID(154396);						-- NPC: #a_sacrificial_cauldron
			cauldron:CastSpell(1469,eq.get_entity_list():GetMobByNpcTypeID(154155):GetID(),0,0);	-- Gets target of #Warder of Death to cast CH if a_sacrifice reaches its target location
			eq.zone_emote(MT.LightGray,"As the sacrifice throws itself into the cauldron, the metal begins to steam as the grimling's soul prepares to empower the ward.");
			eq.depop();
		end
	elseif e.timer == "memblur" then
		e.self:WipeHateList();
	end
end

function evt_sacrifice_hp(e)
	if e.hp_event == 50 then
		eq.set_timer("memblur",500); -- Mob will begin to memblur itself at 50% health and begin pathing back to cauldron
	end
end

-- Spell Jammer
function evt_spell_jammer_spawn(e)
	if not unique_check(e) then
		eq.depop();
	end
end

-- Defiled Minion
function evt_defiled_minion_spawn(e)
	deactivate(e.self);
end

function evt_defiled_minion_combat(e)
	if e.joined then
		eq.set_timer("combat check", 15 * 1000);
		eq.set_timer("leash", 1);
	end
end

function evt_defiled_minion_timer(e)
	if e.timer == "combat_check" then
		if not e.self:IsEngaged() then
			eq.stop_timer(e.timer);
			deactivate(e.self);
		end
	elseif e.timer == "leash" then
		if not e.self:IsEngaged() then
			eq.stop_timer(e.timer)
		end;

		if e.self:GetY() >= -435 then
			e.self:GotoBind();
		end
	end
end

function evt_defiled_minion_signal(e)
	if e.signal == 1 then
		activate(e.self);
		e.self:AddToHateList(eq.get_entity_list():GetMobByNpcTypeID(khati_sha_npc):GetHateRandom(),1);
	end
end

-- Khati Sha
function evt_khati_sha_spawn(e)
	leash_counter = 0;
	khati_sha_deactivate(e.self);
	SpawnMinions();
end

function evt_khati_sha_timer(e)
	if e.timer == "deactivate" then
		khati_sha_deactivate(e.self);
	elseif e.timer == "leash" then
		if not e.self:IsEngaged() then
			eq.stop_timer(e.timer)
		end

		if e.self:GetY() >= -435 then
			leash_counter = leash_counter + 1;

			if leash_counter == 1 then e.self:Shout("You will not remove me from my chambers!") end
			if leash_counter == 5 then	-- 5 leashes till Khati and his guards will reset
				e.self:WipeHateList();
				SpawnMinions();
				leash_counter = 0;
			end
			e.self:GotoBind();
		end
	elseif e.timer == "guard_repop" then
		if not e.self:IsEngaged() then	-- Guards should not repop when engaged with Khati if already popped
			SpawnMinions();
			eq.stop_timer(e.timer);
		end
	end
end

function evt_khati_sha_signal(e)
	if e.signal == 30 then
		khati_sha_activate(e.self);
		eq.set_timer("deactivate", 120 * 60 * 1000); -- 2hrs till deactivation
	end
end

function evt_khati_sha_combat(e)
	if e.joined then
		eq.signal(defiled_minion,1, 2 * 1000);	-- Signals Guards to activate and attack
		eq.set_timer("leash", 1);
		leash_counter = 0;
	else
		eq.set_timer("guard_repop", 15 * 1000);
	end
end

-- Spiritist Andro Shimi
function evt_shimi_spawn(e)
	eq.set_timer("sit", 5 * 1000);
	as_event_failed		= false;
	as_event_started	= false;
end

function evt_shimi_say(e)
	if e.message:findi("hail") then
		if as_event_failed then
			e.self:Emote("stares back at you with cold and empty eyes.")
		elseif as_event_started then
			as_EventDialogue(e);
		elseif as_GuardCheck(e) then
			e.self:Say("I have an urgent matter I need your assistance with, however I cannot speak with the sanctum guardians this close.");
		else
			e.self:Say("Greetings, please speak with Kama.  She will explain what we need of you.  Hurry before the guards return.")
		end
	end
end

function evt_shimi_signal(e)
	if e.signal == 1 then
		e.self:Emote("begins to chant, when a circle of grimlings appear and silence the spell.");
		eq.set_timer("chant_check", 55 * 1000);
		as_event_started = true;
		as_chants = 0;
	elseif e.signal == 10 then
		eq.stop_timer("chant_check");
		as_event_failed = true;
		e.self:SetAppearance(3);
		e.self:Emote("falls over onto his side.  His breath slows as the last of his life drains from his body.")
		eq.set_timer("depop", 60 * 1000);
	end
end

function evt_shimi_timer(e)
	eq.stop_timer(e.timer);
	if e.timer == "sit" then
		e.self:SetAppearance(1);
	elseif e.timer == "chant_check" then
		eq.set_timer("chant_check", chant_timer * 1000);
		if not as_CheckJammers(e) then
			e.self:Emote("chants and rocks as the spell continues.")
			eq.signal(warder_of_life_npc,95)  -- Signals Ward of Life to sum up successful chants
			as_chants = as_chants + 1;
			if as_chants == 8 then
				eq.stop_timer(e.timer);
			end
		else
			e.self:Emote("'s chanting is cut short by the spell jammer's magic")
		end
	elseif e.timer == "depop" then
		eq.depop();
	end
end

function evt_shimi_death_complete(e)
	eq.signal(WDTrpMn,5,10); -- Signals WDTrapMN (event has failed)
end

-- Spiritist Kama Resan
function evt_resan_spawn(e)
	eq.set_timer("sit", 5*1000);
	kr_event_failed		= false;
	kr_event_started	= false;
end

function evt_resan_timer(e)
	eq.stop_timer(e.timer);
	if e.timer == "sit" then
		e.self:SetAppearance(1);
	elseif e.timer == "initial_chant" then
		e.self:Emote("begins to chant, when a circle of grimlings appear and silence the spell.");
		eq.set_timer("chant_check", 55 * 1000);	-- First spell check is 55 seconds rather than 60
		kr_chants = 0;
	elseif e.timer == "chant_check" then
		eq.set_timer("chant_check", chant_timer * 1000);
		if not kr_CheckJammers(e) then
			e.self:Emote("chants and rocks as the spell continues.")
			eq.signal(154154,90)  --signals Ward of Life to sum up successful chants
			kr_chants = kr_chants + 1;
			if kr_chants == 8 then 
				eq.stop_timer(e.timer);
			end
		else
			e.self:Emote("'s chanting is cut short by the spell jammer's magic")
		end
	elseif e.timer == "depop" then
		eq.depop();
	end
end

function evt_resan_say(e)
	if kr_event_started and kr_event_failed then
		e.self:Emote("stares back at you with cold and empty eyes.")
	elseif started then
		kr_EventDialogue(e);
	elseif kr_GuardCheck(e) and e.message:findi("hail") then
		e.self:Say("I have an urgent matter I need your assistance with, however I cannot speak with the sanctum guardians this close.");
	elseif not kr_GuardCheck(e) then
		if e.message:findi("hail") then
			e.self:Say("Thank you for coming. I am not sure what brought you here but I am glad that you have arrived. Andro and I came here as part of a raiding party. Our entire party was captured, all except Andro and I died. In the time we have been here, we have learned of 3 [seals] which protect the inner chambers.");
		elseif e.message:findi("seals") then
			e.self:Say("Interesting, from what we can tell each of the 3 seals embodies one of the principles with which the grimlings were created, Life, Death, and Spirit. Each of the seals has been enclosed in a Warder whose very existence is tied to the seal. Destroy the [Warder] and the seal falls with it.");
		elseif e.message:findi("warder") then
			e.self:Say("We have discovered that the Life Ward exists inside this chamber, while the Death Ward exists in a chamber above. The spirit ward is hidden somewhere deeper; we can sense its presence, but cannot find its exact location. We suspect that you cannot reach it with the life and death wards still whole. We fear that the [situation] may be complicated even further.");
		elseif e.message:findi("situation") then
			e.self:Say("The Wards are a by-product of the magic that was used to create the grimlings, there is symmetry between them. We have managed a [spell] that will destroy the magic hiding two of the Wards, the Life Ward and the Death Ward. Starting the spell will cause both to manifest, however the magic protecting the Life Ward will not fall completely until we have completed our spell.");
		elseif e.message:findi("casting") then
			e.self:Say("There is one more thing I should mention... While we were perfecting the spell, whenever we would get close the life ward would summon grimlings to disrupt our chants. We are not able to concentrate or focus with them present. You will have to make sure they are not around to stop our magic, and do not forget that the death and spirit wards will resurrect the life ward if one or the other isn't destroyed shortly after it falls. Let me know when you are [" .. eq.say_link("We are ready for you to begin your spell", false, "ready for us to begin our spell.") .. "]");
		elseif e.message:findi("ready") then
			eq.set_timer("initial_chant", 200);	-- added small delay to try to sync up emotes
			eq.signal(spiritist_andro_shimi,1);	-- signal Spiritist_Andro_Shimi for initial chant
			eq.signal(WDTrpMn,1,0);
			kr_event_started = true;
			--eq.spawn2(154156,0,0,342.75,-232.48,-7.94,374); -- Spawn Spiritist V2
			--eq.depop();
		elseif e.message:findi("spell") then
			e.self:Say("The spell will use our own life force to break the life ward's shields, we will die shortly after we begin casting, if we do not complete [casting] our spell. Even if we do our life force is tied to that of the Wards, we will die shortly after completion if either Life, or Death Wards still live.");
		end
	end
end

function evt_resan_signal(e)
	if e.signal == 10 then
		eq.stop_timer("chant_check");
		e.self:SetAppearance(3);
		e.self:Emote("gasps loudly as she realizes her spell has failed.  Her eyes gloss over as she stares silently into the abyss.")
		eq.set_timer("depop", 60 * 1000);
		kr_event_failed = true;
	end
end

function evt_resan_death_complete(e)
	eq.signal(WDTrpMn,5,10);
end

-- WDTrpMn
function evt_wdtrpmn_spawn(e)
	eq.set_timer("setup", 5 * 1000);
end

function evt_wdtrpmn_signal(e)
	if e.signal == 1 then
		SpawnJammers(3,jammer_locs_A);	-- initial wave always 3 mobs  
		SpawnJammers(3,jammer_locs_B);	-- initial wave always 3 mobs  
		eq.set_timer("jammers", 60 * 1000); -- 90 second jammer respawn time
		eq.set_timer("fail", fail_timer * 60 * 1000)
		eq.unique_spawn(warder_of_life_npc,0,0,315,-277,-6,260);		-- NPC: Warder of Life
		eq.unique_spawn(warder_of_death_npc,0,0,403,-219,37.06,260);	-- NPC: Warder of death	
		eq.signal(154404,99); -- NPC: #witchdoctor_spawner
	elseif e.signal == 2 then
		eq.stop_timer("jammers");
	elseif e.signal == 10 then
		life_seal = true;
		WardCheck();
	elseif e.signal == 11 then
		death_seal = true;
		WardCheck();
	end
end

function evt_wdtrpmn_timer(e)
	if e.timer == "jammers" then 
		SpawnJammers(math.random(2,3),jammer_locs_A);
		SpawnJammers(math.random(2,3),jammer_locs_B);
	elseif e.timer == "fail" then
		eq.zone_emote(MT.Red,"The image of the Ward beings to waver as its physical form fades and it falls behind protection again.");
		eq.signal(spiritist_kama_resan, 10);	-- Signal event failure to Spiritist_Kama_Resan
		eq.signal(spiritist_andro_shimi, 10);	-- Signal event failure to Spiritist_Andro_Shimi
		eq.depop(warder_of_life_npc);			-- Depop Warder of Life
		eq.signal(warder_of_death_npc, 10);		-- Depop Warder of death		
		eq.depop_all(154157); --depops Reanimated Guardians if up
		eq.depop_with_timer();
	elseif e.timer == "setup" then
		EventSetup();
	end
end

-- Adds
function evt_deathguard_spawn(e)
	eq.set_timer("depop", 60 * 60 * 1000);
end

function evt_deathguard_timer(e)
	if e.timer == "depop" then
		eq.depop();
	end
end

function evt_deathguard_death_complete(e)
	eq.signal(arcanist_trigger,20);
end

-- General Functions
function Setup()
	instance_id = eq.get_zone_instance_id();
	eq.delete_global(instance_id.. "_IAC_Seal_2");	-- clear qglobal if already up for some reason
	eq.depop_all(154159); 							-- NPC: a_diseased_grimling
	for n = 1,2 do
		eq.depop(arcanists[n]);						-- depop arcanists if up for some reason
		eq.depop_all(grimling_spiritwarders[n]);	-- depop spiritwarders if up for some reason
	end
	deathguard_counter = 0;
end

function SpawnMobs(npc, locs)	-- Used to spawn both spiritwarders and deathguards since both are in packs of 4
	for n = 1,4 do
		eq.spawn2(npc,0,0,unpack(locs[n]));
	end
end

function SpawnAdds(total,cell)
	for n = 1,total do
		eq.spawn2(eq.ChooseRandom(154157,154458),0,0,cells_xloc[cell] + math.random(-15,15),cells_yloc[cell] + math.random(-15,15),-7,256);	-- Randomize spawn in cell
	end
end

function ChantSumCheck(e,A,B)
	if A ~= nil and B ~= nil and not wol_activated then
		if A == 8 and B == 8 then	-- requires 8 successful chants by each (16 total )
			wol_activated = true;
			activate(e.self);
			eq.signal(WDTrpMn,2);	-- signals to  stop spawning of spell jammers
			eq.depop_all(154157);	-- NPC: a_reanimated_prisoner 
			eq.stop_timer("adds");
		end
	end
end

function deactivate(mob)
	mob:SetBodyType(11, true);
	mob:SetSpecialAbility(24, 1);
	mob:WipeHateList();
end

function activate(mob)
	mob:SetBodyType(3, true);
	mob:SetSpecialAbility(24, 0);
end

function khati_sha_deactivate(mob)
	eq.stop_all_timers();
	mob:SetBodyType(11, true);
	mob:SetSpecialAbility(24, 1);
	mob:WipeHateList();
	mob:GotoBind();
end

function khati_sha_activate(mob)
	mob:SetBodyType(15, true);
	mob:SetSpecialAbility(24, 0);
end

function unique_check(e)
	local npc_list = eq.get_entity_list():GetNPCList();

	if npc_list ~= nil then
		for npc in npc_list.entries do
			if npc:CalculateDistance(e.self:GetX(),e.self:GetY(),e.self:GetZ()) <= 5 and npc:GetNPCTypeID() == spell_jammer then
				return true;  --jammer in this location is still up, so will not spawn versus stacking up npcs
			end
		end
	else
		return false;  --returns false - no jammer already up so OK to spawn another
	end
end

function SpawnMinions()
	eq.depop_all(defiled_minion);

	for n = 1,4 do
		eq.spawn2(defiled_minion,0,0,unpack(khati_guard_locs[n])); -- NPC: Defiled Minion
	end
end

function as_GuardCheck(e)
	local npc_list = eq.get_entity_list():GetNPCList();

	if npc_list ~= nil then
		for npc in npc_list.entries do
			if npc:CalculateDistance(e.self:GetX(),e.self:GetY(),e.self:GetZ()) <= 35 and npc:GetNPCTypeID() ~= spiritist_andro_shimi and not npc:IsPet() then
				return true;
			end
		end
	else
		return false;
	end
end

function as_CheckJammers(e)
	local npc_list = eq.get_entity_list():GetNPCList();

	if npc_list ~= nil then
		for npc in npc_list.entries do
			if npc:CalculateDistance(e.self:GetX(),e.self:GetY(),e.self:GetZ()) <= 45 and npc:GetNPCTypeID() == spell_jammer then
				return true;
			end
		end
	else
		return false;
	end
end

function as_EventDialogue(e)
	if as_chants ~= nil then
		if as_chants < 2 then
			e.self:Say("I have just begun with my portion of the chant.  Stay vigilant, our work has just begun.")
		elseif as_chants < 4 then
			e.self:Say("You are doing well, I have made it through the first quarter of my incantations.")
		elseif as_chants <= 6 then
			e.self:Emote("takes a deep breath.  The spell is coming, keep your wits sharp.  Some of these skeletons are the remains of our companions.")
		elseif as_chants < 8 then
			e.self:Say("The end draws near, I only hope I can still finish before the Wards fall back behind their veil");
		elseif as_chants == 8 then
			e.self:Emote("looks tired and drained.  My portion of the spell is complete, but my survival, and our success is still dependant on the completion of the spell and the death of both Wards.")
		end
	end
end

function kr_GuardCheck(e)
	local npc_list = eq.get_entity_list():GetNPCList();

	if npc_list ~= nil then
		for npc in npc_list.entries do
			if npc:CalculateDistance(e.self:GetX(),e.self:GetY(),e.self:GetZ()) <= 35 and npc:GetNPCTypeID() ~= spiritist_kama_resan and not npc:IsPet() then
				return true;
			end
		end
	else
		return false;
	end
end

function kr_CheckJammers(e)
	local npc_list = eq.get_entity_list():GetNPCList();

	if npc_list ~= nil then
		for npc in npc_list.entries do
			if npc:CalculateDistance(e.self:GetX(),e.self:GetY(),e.self:GetZ()) <= 45 and npc:GetNPCTypeID() == spell_jammer then
				return true;
			end
		end
	else
		return false;
	end
end

function kr_EventDialogue(e)
	if kr_chants ~= nil then
		if kr_chants < 2 then
			e.self:Say("I have just begun with my portion of the chant.  Stay vigilant, our work has just begun.")
		elseif kr_chants < 4 then
			e.self:Say("You are doing well, I have made it through the first quarter of my incantations.")
		elseif kr_chants <= 6 then
			e.self:Emote("takes a deep breath.  The spell is coming, keep your wits sharp.  Some of these skeletons are the remains of our companions.")
		elseif kr_chants < 8 then
			e.self:Say("The end draws near, I only hope I can still finish before the Wards fall back behind their veil");
		elseif kr_chants == 8 then
			e.self:Emote("looks tired and drained.  My portion of the spell is complete, but my survival, and our success is still dependant on the completion of the spell and the death of both Wards.")
		end
	end
end

function SpawnJammers(total,cell)
	for n = 1,total do
		eq.spawn2(spell_jammer,0,0,unpack(cell[n]));
	end
end


function WardCheck() -- verifies both warders are dead before allowing progress to next stage of event
	if life_seal and death_seal then
		instance_id = eq.get_zone_instance_id();
		eq.stop_timer("fail");
		eq.spawn2(arcanist_trigger,0,0,614.00,-345.00,-23.00,374); -- Spawns Arcanist Trigger
		eq.set_global(instance_id.. "_IAC_Seal_1","1",3,"H2");
		eq.depop(spiritist_andro_shimi); -- Spiritist_Andro_Shimi
		eq.depop(spiritist_kama_resan); -- Spiritist_Kama_Resan 
		eq.depop_with_timer();
	end
end

function EventSetup()
	eq.stop_all_timers();
	eq.unique_spawn(spiritist_andro_shimi,0,0,344, -323.49, -7.94,512);	-- NPC: Spiritist_Andro_Shimi
	eq.unique_spawn(spiritist_kama_resan,0,0,344, -232.48, -7.94,512);	-- NPC: Spiritist_Kama_Resan 
	for n = 1,8 do
		eq.spawn2(a_grimling_guard,0,0,unpack(guard_locs[n]));
	end
	life_seal		= false;
	death_seal		= false;
end

-- Encounter Load
function event_encounter_load(e)
	eq.register_npc_event("khati_sha",	Event.spawn,				arcanist_trigger,			evt_trigger_spawn);
	eq.register_npc_event("khati_sha",	Event.timer,				arcanist_trigger,			evt_trigger_timer);
	eq.register_npc_event("khati_sha",	Event.signal,				arcanist_trigger,			evt_trigger_signal);

	eq.register_npc_event("khati_sha",	Event.spawn,				warder_of_death_npc,		evt_wod_spawn);
	eq.register_npc_event("khati_sha",	Event.timer,				warder_of_death_npc,		evt_wod_timer);
	eq.register_npc_event("khati_sha",	Event.combat,				warder_of_death_npc,		evt_wod_combat);
	eq.register_npc_event("khati_sha",	Event.signal,				warder_of_death_npc,		evt_wod_signal);
	eq.register_npc_event("khati_sha",	Event.death_complete,		warder_of_death_npc,		evt_wod_death_complete);

	eq.register_npc_event("khati_sha",	Event.spawn,				warder_of_life_npc,			evt_wol_spawn);
	eq.register_npc_event("khati_sha",	Event.timer,				warder_of_life_npc,			evt_wol_timer);
	eq.register_npc_event("khati_sha",	Event.combat,				warder_of_life_npc,			evt_wol_combat);
	eq.register_npc_event("khati_sha",	Event.signal,				warder_of_life_npc,			evt_wol_signal);
	eq.register_npc_event("khati_sha",	Event.death_complete,		warder_of_life_npc,			evt_wol_death_complete);

	eq.register_npc_event("khati_sha",	Event.spawn,				arcanist_true,				evt_arcanist_true_spawn);
	eq.register_npc_event("khati_sha",	Event.timer,				arcanist_true,				evt_arcanist_true_timer);
	eq.register_npc_event("khati_sha",	Event.signal,				arcanist_true,				evt_arcanist_true_signal);

	eq.register_npc_event("khati_sha",	Event.spawn,				arcanist_false,				evt_arcanist_false_spawn);
	eq.register_npc_event("khati_sha",	Event.timer,				arcanist_false,				evt_arcanist_false_timer);
	eq.register_npc_event("khati_sha",	Event.enter,				arcanist_false,				evt_arcanist_false_enter);
	eq.register_npc_event("khati_sha",	Event.signal,				arcanist_false,				evt_arcanist_false_signal);

	eq.register_npc_event("khati_sha",	Event.spawn,				arcanist_final,				evt_arcanist_final_spawn);
	eq.register_npc_event("khati_sha",	Event.timer,				arcanist_final,				evt_arcanist_final_timer);
	eq.register_npc_event("khati_sha",	Event.death_complete,		arcanist_final,				evt_arcanist_final_death_complete);

	eq.register_npc_event("khati_sha",	Event.spawn,				a_sacrifice,				evt_sacrifice_spawn);
	eq.register_npc_event("khati_sha",	Event.timer,				a_sacrifice,				evt_sacrifice_timer);
	eq.register_npc_event("khati_sha",	Event.hp,					a_sacrifice,				evt_sacrifice_hp);

	eq.register_npc_event("khati_sha",	Event.spawn,				spell_jammer,				evt_spell_jammer_spawn);

	eq.register_npc_event("khati_sha",	Event.spawn,				defiled_minion,				evt_defiled_minion_spawn);
	eq.register_npc_event("khati_sha",	Event.combat,				defiled_minion,				evt_defiled_minion_combat);
	eq.register_npc_event("khati_sha",	Event.timer,				defiled_minion,				evt_defiled_minion_timer);
	eq.register_npc_event("khati_sha",	Event.signal,				defiled_minion,				evt_defiled_minion_signal);

	eq.register_npc_event("khati_sha",	Event.spawn,				khati_sha_npc,				evt_khati_sha_spawn);
	eq.register_npc_event("khati_sha",	Event.timer,				khati_sha_npc,				evt_khati_sha_timer);
	eq.register_npc_event("khati_sha",	Event.signal,				khati_sha_npc,				evt_khati_sha_signal);
	eq.register_npc_event("khati_sha",	Event.combat,				khati_sha_npc,				evt_khati_sha_combat);

	eq.register_npc_event("khati_sha",	Event.spawn,				spiritist_andro_shimi,		evt_shimi_spawn);
	eq.register_npc_event("khati_sha",	Event.say,					spiritist_andro_shimi,		evt_shimi_say);
	eq.register_npc_event("khati_sha",	Event.signal,				spiritist_andro_shimi,		evt_shimi_signal);
	eq.register_npc_event("khati_sha",	Event.timer,				spiritist_andro_shimi,		evt_shimi_timer);
	eq.register_npc_event("khati_sha",	Event.death_complete,		spiritist_andro_shimi,		evt_shimi_death_complete);

	eq.register_npc_event("khati_sha",	Event.spawn,				spiritist_kama_resan,		evt_resan_spawn);
	eq.register_npc_event("khati_sha",	Event.say,					spiritist_kama_resan,		evt_resan_say);
	eq.register_npc_event("khati_sha",	Event.signal,				spiritist_kama_resan,		evt_resan_signal);
	eq.register_npc_event("khati_sha",	Event.timer,				spiritist_kama_resan,		evt_resan_timer);
	eq.register_npc_event("khati_sha",	Event.death_complete,		spiritist_kama_resan,		evt_resan_death_complete);

	eq.register_npc_event("khati_sha",	Event.spawn,				WDTrpMn,					evt_wdtrpmn_spawn);
	eq.register_npc_event("khati_sha",	Event.signal,				WDTrpMn,					evt_wdtrpmn_signal);
	eq.register_npc_event("khati_sha",	Event.timer,				WDTrpMn,					evt_wdtrpmn_timer);

	eq.register_npc_event("khati_sha",	Event.spawn,				a_deathguard,				evt_deathguard_spawn);
	eq.register_npc_event("khati_sha",	Event.timer,				a_deathguard,				evt_deathguard_timer);
	eq.register_npc_event("khati_sha",	Event.death_complete,		a_deathguard,				evt_deathguard_death_complete);

	for i = 1, #grimling_spiritwarders do
		eq.register_npc_event("khati_sha",	Event.spawn,			grimling_spiritwarders[i],	evt_spiritwarders_spawn);
		eq.register_npc_event("khati_sha",	Event.combat,			grimling_spiritwarders[i],	evt_spiritwarders_combat);
		eq.register_npc_event("khati_sha",	Event.signal,			grimling_spiritwarders[i],	evt_spiritwarders_signal);
		eq.register_npc_event("khati_sha",	Event.hp,				grimling_spiritwarders[i],	evt_spiritwarders_hp);
	end
end
