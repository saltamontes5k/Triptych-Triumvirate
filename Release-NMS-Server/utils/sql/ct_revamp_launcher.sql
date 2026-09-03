-- =====================================================================
-- Addendum: expedition launcher NPC (base CT) + Gimlik escort start (v1)
-- =====================================================================
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='';
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;

-- launcher npc (clone of the Echo_of_the_Past template)
INSERT INTO `npc_types` (`id`,`name`,`lastname`,`level`,`race`,`class`,`bodytype`,`hp`,`mana`,`gender`,`texture`,`helmtexture`,`herosforgemodel`,`size`,`hp_regen_rate`,`hp_regen_per_second`,`mana_regen_rate`,`loottable_id`,`merchant_id`,`greed`,`alt_currency_id`,`npc_spells_id`,`npc_spells_effects_id`,`npc_faction_id`,`adventure_template_id`,`trap_template`,`mindmg`,`maxdmg`,`attack_count`,`npcspecialattks`,`special_abilities`,`aggroradius`,`assistradius`,`face`,`luclin_hairstyle`,`luclin_haircolor`,`luclin_eyecolor`,`luclin_eyecolor2`,`luclin_beardcolor`,`luclin_beard`,`drakkin_heritage`,`drakkin_tattoo`,`drakkin_details`,`armortint_id`,`armortint_red`,`armortint_green`,`armortint_blue`,`d_melee_texture1`,`d_melee_texture2`,`ammo_idfile`,`prim_melee_type`,`sec_melee_type`,`ranged_type`,`runspeed`,`MR`,`CR`,`DR`,`FR`,`PR`,`Corrup`,`PhR`,`see_invis`,`see_invis_undead`,`qglobal`,`AC`,`npc_aggro`,`spawn_limit`,`attack_speed`,`attack_delay`,`findable`,`STR`,`STA`,`DEX`,`AGI`,`_INT`,`WIS`,`CHA`,`see_hide`,`see_improved_hide`,`trackable`,`isbot`,`exclude`,`ATK`,`Accuracy`,`Avoidance`,`slow_mitigation`,`version`,`maxlevel`,`scalerate`,`private_corpse`,`unique_spawn_by_name`,`underwater`,`isquest`,`emoteid`,`spellscale`,`healscale`,`no_target_hotkey`,`raid_target`,`armtexture`,`bracertexture`,`handtexture`,`legtexture`,`feettexture`,`light`,`walkspeed`,`peqid`,`unique_`,`fixed`,`ignore_despawn`,`show_name`,`untargetable`,`charm_ac`,`charm_min_dmg`,`charm_max_dmg`,`charm_attack_delay`,`charm_accuracy_rating`,`charm_avoidance_rating`,`charm_atk`,`skip_global_loot`,`rare_spawn`,`stuck_behavior`,`model`,`flymode`,`always_aggro`,`exp_mod`,`heroic_strikethrough`,`faction_amount`,`keeps_sold_items`,`is_parcel_merchant`,`multiquest_enabled`,`npc_tint_id`) VALUES ('1500000200','Echo_of_the_Temple','Cazic Thule','51','51','1','1','100000','0','2','0','0','0','5','0','0','0','0','0','0','0','0','0','0','0','0','0','0','-1','','12,1^13,1^14,1^15,1^16,1^17,1^18,1^19,1^20,1^21,1^22,1^23,1^24,1^25,1^28,1^31,1^35,1^39,1^46,1','0','0','0','1','1','1','1','1','0','0','0','0','0','0','0','0','20','20','IT10','28','28','7','50','0','0','0','0','0','0','0','1','1','0','0','0','0','0','30','1','75','75','75','75','80','75','75','1','1','1','0','1','0','0','0','0','0','0','100','0','0','0','0','0','100','100','0','0','0','0','0','0','0','0','0','0','0','0','0','1','0','0','0','0','0','0','0','0','0','0','0','0','-1','0','100','0','0','1','0','0','0');

-- spawngroup + spawnentry + spawn2 : launcher in base CT (v0) near the Echo
INSERT INTO `spawngroup` (id,name,spawn_limit) VALUES (60002000,'ct_revamp_launcher',0);
INSERT INTO `spawnentry` (spawngroupID,npcID,chance) VALUES (60002000,1500000200,100);
INSERT INTO `spawn2` (id,spawngroupID,zone,version,x,y,z,heading,respawntime,variance,pathgrid,_condition,cond_value,animation,min_expansion,max_expansion) VALUES (40001000,60002000,'cazicthule',0,-60,84,3,0,300,0,0,0,1,0,-1,-1);

-- spawngroup + spawnentry + spawn2 : Gimlik at the pyramid entrance (v1 instance only)
INSERT INTO `spawngroup` (id,name,spawn_limit) VALUES (60002001,'ct_revamp_gimlik',0);
INSERT INTO `spawnentry` (spawngroupID,npcID,chance) VALUES (60002001,1500000171,100);
INSERT INTO `spawn2` (id,spawngroupID,zone,version,x,y,z,heading,respawntime,variance,pathgrid,_condition,cond_value,animation,min_expansion,max_expansion) VALUES (40001001,60002001,'cazicthule',1,-468,254,18.9,0,600,0,0,0,1,0,-1,-1);

SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET SQL_MODE=@OLD_SQL_MODE;
-- DONE
