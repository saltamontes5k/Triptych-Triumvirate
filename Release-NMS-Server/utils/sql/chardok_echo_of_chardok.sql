-- ============================================================================
-- #Echo_of_Chardok (103161) — missing npc_types row
-- ----------------------------------------------------------------------------
-- Audit (2026-09-13) for the Veeshan's Peak key / Cipher of Veeshan quest:
-- the base peq import ships the three chardok spawn points and the 100%
-- "Essence of Chardok" (69308) loot table (14486, lootdrop 23168) for
-- #Echo_of_Chardok, but the npc_types row itself is absent. As a result the
-- spawn points had a dangling npcID and the "essence" branch of
-- Cipher of Veeshan (recipe 9716) was unreachable.
--
-- Restores the PEQ row verbatim (level 67, race 155, warrior, faction 1444,
-- npc_spells 606) and re-asserts the spawn wiring idempotently so this file
-- is self-contained after any reimport.
--
-- Idempotent: INSERT IGNORE keyed on the fixed ids (npc 103161,
-- spawngroups 8376/8452/12978, spawn2 21003/21133/21305). No other rows are
-- touched. Re-apply verbatim after any reimport.
-- ============================================================================

INSERT IGNORE INTO `npc_types` (`id`, `name`, `lastname`, `level`, `race`, `class`, `bodytype`, `hp`, `mana`, `gender`, `texture`, `helmtexture`, `herosforgemodel`, `size`, `hp_regen_rate`, `hp_regen_per_second`, `mana_regen_rate`, `loottable_id`, `merchant_id`, `greed`, `alt_currency_id`, `npc_spells_id`, `npc_spells_effects_id`, `npc_faction_id`, `adventure_template_id`, `trap_template`, `mindmg`, `maxdmg`, `attack_count`, `npcspecialattks`, `special_abilities`, `aggroradius`, `assistradius`, `face`, `luclin_hairstyle`, `luclin_haircolor`, `luclin_eyecolor`, `luclin_eyecolor2`, `luclin_beardcolor`, `luclin_beard`, `drakkin_heritage`, `drakkin_tattoo`, `drakkin_details`, `armortint_id`, `armortint_red`, `armortint_green`, `armortint_blue`, `d_melee_texture1`, `d_melee_texture2`, `ammo_idfile`, `prim_melee_type`, `sec_melee_type`, `ranged_type`, `runspeed`, `MR`, `CR`, `DR`, `FR`, `PR`, `Corrup`, `PhR`, `see_invis`, `see_invis_undead`, `qglobal`, `AC`, `npc_aggro`, `spawn_limit`, `attack_speed`, `attack_delay`, `findable`, `STR`, `STA`, `DEX`, `AGI`, `_INT`, `WIS`, `CHA`, `see_hide`, `see_improved_hide`, `trackable`, `isbot`, `exclude`, `ATK`, `Accuracy`, `Avoidance`, `slow_mitigation`, `version`, `maxlevel`, `scalerate`, `private_corpse`, `unique_spawn_by_name`, `underwater`, `isquest`, `emoteid`, `spellscale`, `healscale`, `no_target_hotkey`, `raid_target`, `armtexture`, `bracertexture`, `handtexture`, `legtexture`, `feettexture`, `light`, `walkspeed`, `peqid`, `unique_`, `fixed`, `ignore_despawn`, `show_name`, `untargetable`, `charm_ac`, `charm_min_dmg`, `charm_max_dmg`, `charm_attack_delay`, `charm_accuracy_rating`, `charm_avoidance_rating`, `charm_atk`, `skip_global_loot`, `rare_spawn`, `stuck_behavior`, `model`, `flymode`, `always_aggro`, `exp_mod`, `heroic_strikethrough`, `faction_amount`, `keeps_sold_items`, `is_parcel_merchant`, `multiquest_enabled`, `npc_tint_id`) VALUES (103161,'#Echo_of_Chardok','',67,155,1,3,59412,0,2,0,0,0,6,25,0,0,14486,0,0,0,606,0,1444,0,0,150,750,-1,'SERNDf','1,1^2,1^5,1^8,1^13,1^14,1^15,1^16,1^17,1^21,1^31,1',60,85,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,'IT10',28,28,7,1.25,150,150,150,150,150,92,48,1,0,0,283,0,0,-22,18,0,215,215,215,215,215,215,215,0,0,1,0,1,100,0,0,0,0,0,100,0,0,0,0,0,100,100,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,100,0,0,1,0,0,0);

INSERT IGNORE INTO spawngroup (id,name,spawn_limit,dist,max_x,min_x,max_y,min_y,delay,mindelay,despawn,despawn_timer,wp_spawns) VALUES
 (8376,'chardok_89',0,0,0,0,0,0,0,15000,0,15285,0),
 (8452,'chardok_13',0,0,0,0,0,0,0,15000,0,9870,0),
 (12978,'chardok_188',0,0,0,0,0,0,0,15000,0,100,0);

INSERT IGNORE INTO spawnentry (spawngroupID,npcID,chance,condition_value_filter,min_time,max_time,min_expansion,max_expansion) VALUES
 (8376,103161,50,1,0,0,-1,-1),
 (8452,103161,50,1,0,0,-1,-1),
 (12978,103161,50,1,0,0,-1,-1);

INSERT IGNORE INTO spawn2 (id,spawngroupID,zone,version,x,y,z,heading,respawntime,variance,pathgrid,path_when_zone_idle,_condition,cond_value,animation,min_expansion,max_expansion) VALUES
 (21133,8376,'chardok',0,-329.0,-507.0,-138.63,234.0,640,0,0,0,0,1,0,-1,-1),
 (21003,8452,'chardok',0,166.0,415.0,-305.0,138.0,640,0,0,0,0,1,0,-1,-1),
 (21305,12978,'chardok',0,339.0,19.0,-273.5,130.0,640,0,0,0,0,1,0,-1,-1);
