-- 2026-10-29 Ogre melee DPS line. The stock seed ships no melee catalog for
-- the ogre (also missing: erudite/high elf/troll melee) - the broker rewire
-- needs the Ogre pirate rogue line, so it is authored here: 11-entry ladder
-- cloned 1:1 from the human melee chain. Also fixes the broker split (Gex was
-- 110 entries = over the MAX_MERC 100 cap; the corrected split is
-- Gex 99 / Rul 88) and adds the Ogre melee line to Hadya.
-- Rollback: DELETE the bands below + re-run 20261029_merc_broker_rewire.sql.
-- Generator: hand-written (tmp/gen_merc_species.py clone machinery).

DELETE FROM `merc_templates` WHERE `merc_template_id` BETWEEN 1338 AND 1348;
DELETE FROM `merc_stats` WHERE `merc_npc_type_id` BETWEEN 525 AND 535;
DELETE FROM `merc_armorinfo` WHERE `merc_npc_type_id` BETWEEN 525 AND 535;
DELETE FROM `merc_weaponinfo` WHERE `merc_npc_type_id` BETWEEN 525 AND 535;
DELETE FROM `merc_npc_types` WHERE `merc_npc_type_id` BETWEEN 525 AND 535;

INSERT INTO `merc_npc_types`
 (`merc_npc_type_id`,`proficiency_id`,`tier_id`,`class_id`,`name`) VALUES
 (525, 1, 1, 9, 'Ogre - Apprentice Melee DPS Tier I'),
 (526, 1, 2, 9, 'Ogre - Apprentice Melee DPS Tier II'),
 (527, 1, 3, 9, 'Ogre - Apprentice Melee DPS Tier III'),
 (528, 1, 4, 9, 'Ogre - Apprentice Melee DPS Tier IV'),
 (529, 1, 5, 9, 'Ogre - Apprentice Melee DPS Tier V'),
 (530, 2, 1, 9, 'Ogre - Journeyman Melee DPS Tier I'),
 (531, 2, 2, 9, 'Ogre - Journeyman Melee DPS Tier II'),
 (532, 3, 1, 9, 'Ogre - Master Melee DPS Tier I'),
 (533, 3, 2, 9, 'Ogre - Master Melee DPS Tier II'),
 (534, 4, 1, 9, 'Ogre - Legendary Melee DPS Tier I'),
 (535, 4, 2, 9, 'Ogre - Legendary Melee DPS Tier II');

INSERT INTO `merc_templates`
 (`merc_template_id`,`merc_type_id`,`merc_subtype_id`,`merc_npc_type_id`,`dbstring`,`name_type_id`,`clientversion`) VALUES
 (1338, 19, 11, 525, '10040101', 0, 4),
 (1339, 19, 12, 526, '10040102', 0, 4),
 (1340, 19, 13, 527, '10040103', 0, 4),
 (1341, 19, 14, 528, '10040104', 0, 4),
 (1342, 19, 15, 529, '10040105', 0, 4),
 (1343, 20, 11, 530, '10040201', 0, 4),
 (1344, 20, 12, 531, '10040202', 0, 4),
 (1345, 73, 11, 532, '10040301', 0, 4),
 (1346, 73, 12, 533, '10040302', 0, 4),
 (1347, 74, 11, 534, '10040401', 0, 4),
 (1348, 74, 12, 535, '10040402', 0, 4);

-- stat/armor/weapon clones from the human melee chain
INSERT INTO `merc_stats` (`merc_npc_type_id`,`clientlevel`,`level`,`hp`,`mana`,`AC`,`ATK`,`STR`,`STA`,`DEX`,`AGI`,`_INT`,`WIS`,`CHA`,`MR`,`CR`,`DR`,`FR`,`PR`,`Corrup`,`mindmg`,`maxdmg`,`attack_count`,`attack_speed`,`attack_delay`,`special_abilities`,`Accuracy`,`hp_regen_rate`,`mana_regen_rate`,`runspeed`,`statscale`,`spellscale`,`healscale`)
SELECT 525,`clientlevel`,`level`,`hp`,`mana`,`AC`,`ATK`,`STR`,`STA`,`DEX`,`AGI`,`_INT`,`WIS`,`CHA`,`MR`,`CR`,`DR`,`FR`,`PR`,`Corrup`,`mindmg`,`maxdmg`,`attack_count`,`attack_speed`,`attack_delay`,`special_abilities`,`Accuracy`,`hp_regen_rate`,`mana_regen_rate`,`runspeed`,`statscale`,`spellscale`,`healscale` FROM `merc_stats` WHERE `merc_npc_type_id`=21;
INSERT INTO `merc_stats` (`merc_npc_type_id`,`clientlevel`,`level`,`hp`,`mana`,`AC`,`ATK`,`STR`,`STA`,`DEX`,`AGI`,`_INT`,`WIS`,`CHA`,`MR`,`CR`,`DR`,`FR`,`PR`,`Corrup`,`mindmg`,`maxdmg`,`attack_count`,`attack_speed`,`attack_delay`,`special_abilities`,`Accuracy`,`hp_regen_rate`,`mana_regen_rate`,`runspeed`,`statscale`,`spellscale`,`healscale`)
SELECT 526,`clientlevel`,`level`,`hp`,`mana`,`AC`,`ATK`,`STR`,`STA`,`DEX`,`AGI`,`_INT`,`WIS`,`CHA`,`MR`,`CR`,`DR`,`FR`,`PR`,`Corrup`,`mindmg`,`maxdmg`,`attack_count`,`attack_speed`,`attack_delay`,`special_abilities`,`Accuracy`,`hp_regen_rate`,`mana_regen_rate`,`runspeed`,`statscale`,`spellscale`,`healscale` FROM `merc_stats` WHERE `merc_npc_type_id`=22;
INSERT INTO `merc_stats` (`merc_npc_type_id`,`clientlevel`,`level`,`hp`,`mana`,`AC`,`ATK`,`STR`,`STA`,`DEX`,`AGI`,`_INT`,`WIS`,`CHA`,`MR`,`CR`,`DR`,`FR`,`PR`,`Corrup`,`mindmg`,`maxdmg`,`attack_count`,`attack_speed`,`attack_delay`,`special_abilities`,`Accuracy`,`hp_regen_rate`,`mana_regen_rate`,`runspeed`,`statscale`,`spellscale`,`healscale`)
SELECT 527,`clientlevel`,`level`,`hp`,`mana`,`AC`,`ATK`,`STR`,`STA`,`DEX`,`AGI`,`_INT`,`WIS`,`CHA`,`MR`,`CR`,`DR`,`FR`,`PR`,`Corrup`,`mindmg`,`maxdmg`,`attack_count`,`attack_speed`,`attack_delay`,`special_abilities`,`Accuracy`,`hp_regen_rate`,`mana_regen_rate`,`runspeed`,`statscale`,`spellscale`,`healscale` FROM `merc_stats` WHERE `merc_npc_type_id`=23;
INSERT INTO `merc_stats` (`merc_npc_type_id`,`clientlevel`,`level`,`hp`,`mana`,`AC`,`ATK`,`STR`,`STA`,`DEX`,`AGI`,`_INT`,`WIS`,`CHA`,`MR`,`CR`,`DR`,`FR`,`PR`,`Corrup`,`mindmg`,`maxdmg`,`attack_count`,`attack_speed`,`attack_delay`,`special_abilities`,`Accuracy`,`hp_regen_rate`,`mana_regen_rate`,`runspeed`,`statscale`,`spellscale`,`healscale`)
SELECT 528,`clientlevel`,`level`,`hp`,`mana`,`AC`,`ATK`,`STR`,`STA`,`DEX`,`AGI`,`_INT`,`WIS`,`CHA`,`MR`,`CR`,`DR`,`FR`,`PR`,`Corrup`,`mindmg`,`maxdmg`,`attack_count`,`attack_speed`,`attack_delay`,`special_abilities`,`Accuracy`,`hp_regen_rate`,`mana_regen_rate`,`runspeed`,`statscale`,`spellscale`,`healscale` FROM `merc_stats` WHERE `merc_npc_type_id`=24;
INSERT INTO `merc_stats` (`merc_npc_type_id`,`clientlevel`,`level`,`hp`,`mana`,`AC`,`ATK`,`STR`,`STA`,`DEX`,`AGI`,`_INT`,`WIS`,`CHA`,`MR`,`CR`,`DR`,`FR`,`PR`,`Corrup`,`mindmg`,`maxdmg`,`attack_count`,`attack_speed`,`attack_delay`,`special_abilities`,`Accuracy`,`hp_regen_rate`,`mana_regen_rate`,`runspeed`,`statscale`,`spellscale`,`healscale`)
SELECT 529,`clientlevel`,`level`,`hp`,`mana`,`AC`,`ATK`,`STR`,`STA`,`DEX`,`AGI`,`_INT`,`WIS`,`CHA`,`MR`,`CR`,`DR`,`FR`,`PR`,`Corrup`,`mindmg`,`maxdmg`,`attack_count`,`attack_speed`,`attack_delay`,`special_abilities`,`Accuracy`,`hp_regen_rate`,`mana_regen_rate`,`runspeed`,`statscale`,`spellscale`,`healscale` FROM `merc_stats` WHERE `merc_npc_type_id`=25;
INSERT INTO `merc_stats` (`merc_npc_type_id`,`clientlevel`,`level`,`hp`,`mana`,`AC`,`ATK`,`STR`,`STA`,`DEX`,`AGI`,`_INT`,`WIS`,`CHA`,`MR`,`CR`,`DR`,`FR`,`PR`,`Corrup`,`mindmg`,`maxdmg`,`attack_count`,`attack_speed`,`attack_delay`,`special_abilities`,`Accuracy`,`hp_regen_rate`,`mana_regen_rate`,`runspeed`,`statscale`,`spellscale`,`healscale`)
SELECT 530,`clientlevel`,`level`,`hp`,`mana`,`AC`,`ATK`,`STR`,`STA`,`DEX`,`AGI`,`_INT`,`WIS`,`CHA`,`MR`,`CR`,`DR`,`FR`,`PR`,`Corrup`,`mindmg`,`maxdmg`,`attack_count`,`attack_speed`,`attack_delay`,`special_abilities`,`Accuracy`,`hp_regen_rate`,`mana_regen_rate`,`runspeed`,`statscale`,`spellscale`,`healscale` FROM `merc_stats` WHERE `merc_npc_type_id`=26;
INSERT INTO `merc_stats` (`merc_npc_type_id`,`clientlevel`,`level`,`hp`,`mana`,`AC`,`ATK`,`STR`,`STA`,`DEX`,`AGI`,`_INT`,`WIS`,`CHA`,`MR`,`CR`,`DR`,`FR`,`PR`,`Corrup`,`mindmg`,`maxdmg`,`attack_count`,`attack_speed`,`attack_delay`,`special_abilities`,`Accuracy`,`hp_regen_rate`,`mana_regen_rate`,`runspeed`,`statscale`,`spellscale`,`healscale`)
SELECT 531,`clientlevel`,`level`,`hp`,`mana`,`AC`,`ATK`,`STR`,`STA`,`DEX`,`AGI`,`_INT`,`WIS`,`CHA`,`MR`,`CR`,`DR`,`FR`,`PR`,`Corrup`,`mindmg`,`maxdmg`,`attack_count`,`attack_speed`,`attack_delay`,`special_abilities`,`Accuracy`,`hp_regen_rate`,`mana_regen_rate`,`runspeed`,`statscale`,`spellscale`,`healscale` FROM `merc_stats` WHERE `merc_npc_type_id`=27;
INSERT INTO `merc_stats` (`merc_npc_type_id`,`clientlevel`,`level`,`hp`,`mana`,`AC`,`ATK`,`STR`,`STA`,`DEX`,`AGI`,`_INT`,`WIS`,`CHA`,`MR`,`CR`,`DR`,`FR`,`PR`,`Corrup`,`mindmg`,`maxdmg`,`attack_count`,`attack_speed`,`attack_delay`,`special_abilities`,`Accuracy`,`hp_regen_rate`,`mana_regen_rate`,`runspeed`,`statscale`,`spellscale`,`healscale`)
SELECT 532,`clientlevel`,`level`,`hp`,`mana`,`AC`,`ATK`,`STR`,`STA`,`DEX`,`AGI`,`_INT`,`WIS`,`CHA`,`MR`,`CR`,`DR`,`FR`,`PR`,`Corrup`,`mindmg`,`maxdmg`,`attack_count`,`attack_speed`,`attack_delay`,`special_abilities`,`Accuracy`,`hp_regen_rate`,`mana_regen_rate`,`runspeed`,`statscale`,`spellscale`,`healscale` FROM `merc_stats` WHERE `merc_npc_type_id`=76;
INSERT INTO `merc_stats` (`merc_npc_type_id`,`clientlevel`,`level`,`hp`,`mana`,`AC`,`ATK`,`STR`,`STA`,`DEX`,`AGI`,`_INT`,`WIS`,`CHA`,`MR`,`CR`,`DR`,`FR`,`PR`,`Corrup`,`mindmg`,`maxdmg`,`attack_count`,`attack_speed`,`attack_delay`,`special_abilities`,`Accuracy`,`hp_regen_rate`,`mana_regen_rate`,`runspeed`,`statscale`,`spellscale`,`healscale`)
SELECT 533,`clientlevel`,`level`,`hp`,`mana`,`AC`,`ATK`,`STR`,`STA`,`DEX`,`AGI`,`_INT`,`WIS`,`CHA`,`MR`,`CR`,`DR`,`FR`,`PR`,`Corrup`,`mindmg`,`maxdmg`,`attack_count`,`attack_speed`,`attack_delay`,`special_abilities`,`Accuracy`,`hp_regen_rate`,`mana_regen_rate`,`runspeed`,`statscale`,`spellscale`,`healscale` FROM `merc_stats` WHERE `merc_npc_type_id`=78;
INSERT INTO `merc_stats` (`merc_npc_type_id`,`clientlevel`,`level`,`hp`,`mana`,`AC`,`ATK`,`STR`,`STA`,`DEX`,`AGI`,`_INT`,`WIS`,`CHA`,`MR`,`CR`,`DR`,`FR`,`PR`,`Corrup`,`mindmg`,`maxdmg`,`attack_count`,`attack_speed`,`attack_delay`,`special_abilities`,`Accuracy`,`hp_regen_rate`,`mana_regen_rate`,`runspeed`,`statscale`,`spellscale`,`healscale`)
SELECT 534,`clientlevel`,`level`,`hp`,`mana`,`AC`,`ATK`,`STR`,`STA`,`DEX`,`AGI`,`_INT`,`WIS`,`CHA`,`MR`,`CR`,`DR`,`FR`,`PR`,`Corrup`,`mindmg`,`maxdmg`,`attack_count`,`attack_speed`,`attack_delay`,`special_abilities`,`Accuracy`,`hp_regen_rate`,`mana_regen_rate`,`runspeed`,`statscale`,`spellscale`,`healscale` FROM `merc_stats` WHERE `merc_npc_type_id`=77;
INSERT INTO `merc_stats` (`merc_npc_type_id`,`clientlevel`,`level`,`hp`,`mana`,`AC`,`ATK`,`STR`,`STA`,`DEX`,`AGI`,`_INT`,`WIS`,`CHA`,`MR`,`CR`,`DR`,`FR`,`PR`,`Corrup`,`mindmg`,`maxdmg`,`attack_count`,`attack_speed`,`attack_delay`,`special_abilities`,`Accuracy`,`hp_regen_rate`,`mana_regen_rate`,`runspeed`,`statscale`,`spellscale`,`healscale`)
SELECT 535,`clientlevel`,`level`,`hp`,`mana`,`AC`,`ATK`,`STR`,`STA`,`DEX`,`AGI`,`_INT`,`WIS`,`CHA`,`MR`,`CR`,`DR`,`FR`,`PR`,`Corrup`,`mindmg`,`maxdmg`,`attack_count`,`attack_speed`,`attack_delay`,`special_abilities`,`Accuracy`,`hp_regen_rate`,`mana_regen_rate`,`runspeed`,`statscale`,`spellscale`,`healscale` FROM `merc_stats` WHERE `merc_npc_type_id`=79;

INSERT INTO `merc_armorinfo` (`merc_npc_type_id`,`minlevel`,`maxlevel`,`texture`,`helmtexture`,`armortint_id`,`armortint_red`,`armortint_green`,`armortint_blue`)
SELECT 525,`minlevel`,`maxlevel`,`texture`,`helmtexture`,`armortint_id`,`armortint_red`,`armortint_green`,`armortint_blue` FROM `merc_armorinfo` WHERE `merc_npc_type_id`=21;
INSERT INTO `merc_armorinfo` (`merc_npc_type_id`,`minlevel`,`maxlevel`,`texture`,`helmtexture`,`armortint_id`,`armortint_red`,`armortint_green`,`armortint_blue`)
SELECT 526,`minlevel`,`maxlevel`,`texture`,`helmtexture`,`armortint_id`,`armortint_red`,`armortint_green`,`armortint_blue` FROM `merc_armorinfo` WHERE `merc_npc_type_id`=22;
INSERT INTO `merc_armorinfo` (`merc_npc_type_id`,`minlevel`,`maxlevel`,`texture`,`helmtexture`,`armortint_id`,`armortint_red`,`armortint_green`,`armortint_blue`)
SELECT 527,`minlevel`,`maxlevel`,`texture`,`helmtexture`,`armortint_id`,`armortint_red`,`armortint_green`,`armortint_blue` FROM `merc_armorinfo` WHERE `merc_npc_type_id`=23;
INSERT INTO `merc_armorinfo` (`merc_npc_type_id`,`minlevel`,`maxlevel`,`texture`,`helmtexture`,`armortint_id`,`armortint_red`,`armortint_green`,`armortint_blue`)
SELECT 528,`minlevel`,`maxlevel`,`texture`,`helmtexture`,`armortint_id`,`armortint_red`,`armortint_green`,`armortint_blue` FROM `merc_armorinfo` WHERE `merc_npc_type_id`=24;
INSERT INTO `merc_armorinfo` (`merc_npc_type_id`,`minlevel`,`maxlevel`,`texture`,`helmtexture`,`armortint_id`,`armortint_red`,`armortint_green`,`armortint_blue`)
SELECT 529,`minlevel`,`maxlevel`,`texture`,`helmtexture`,`armortint_id`,`armortint_red`,`armortint_green`,`armortint_blue` FROM `merc_armorinfo` WHERE `merc_npc_type_id`=25;
INSERT INTO `merc_armorinfo` (`merc_npc_type_id`,`minlevel`,`maxlevel`,`texture`,`helmtexture`,`armortint_id`,`armortint_red`,`armortint_green`,`armortint_blue`)
SELECT 530,`minlevel`,`maxlevel`,`texture`,`helmtexture`,`armortint_id`,`armortint_red`,`armortint_green`,`armortint_blue` FROM `merc_armorinfo` WHERE `merc_npc_type_id`=26;
INSERT INTO `merc_armorinfo` (`merc_npc_type_id`,`minlevel`,`maxlevel`,`texture`,`helmtexture`,`armortint_id`,`armortint_red`,`armortint_green`,`armortint_blue`)
SELECT 531,`minlevel`,`maxlevel`,`texture`,`helmtexture`,`armortint_id`,`armortint_red`,`armortint_green`,`armortint_blue` FROM `merc_armorinfo` WHERE `merc_npc_type_id`=27;
INSERT INTO `merc_armorinfo` (`merc_npc_type_id`,`minlevel`,`maxlevel`,`texture`,`helmtexture`,`armortint_id`,`armortint_red`,`armortint_green`,`armortint_blue`)
SELECT 532,`minlevel`,`maxlevel`,`texture`,`helmtexture`,`armortint_id`,`armortint_red`,`armortint_green`,`armortint_blue` FROM `merc_armorinfo` WHERE `merc_npc_type_id`=76;
INSERT INTO `merc_armorinfo` (`merc_npc_type_id`,`minlevel`,`maxlevel`,`texture`,`helmtexture`,`armortint_id`,`armortint_red`,`armortint_green`,`armortint_blue`)
SELECT 533,`minlevel`,`maxlevel`,`texture`,`helmtexture`,`armortint_id`,`armortint_red`,`armortint_green`,`armortint_blue` FROM `merc_armorinfo` WHERE `merc_npc_type_id`=78;
INSERT INTO `merc_armorinfo` (`merc_npc_type_id`,`minlevel`,`maxlevel`,`texture`,`helmtexture`,`armortint_id`,`armortint_red`,`armortint_green`,`armortint_blue`)
SELECT 534,`minlevel`,`maxlevel`,`texture`,`helmtexture`,`armortint_id`,`armortint_red`,`armortint_green`,`armortint_blue` FROM `merc_armorinfo` WHERE `merc_npc_type_id`=77;
INSERT INTO `merc_armorinfo` (`merc_npc_type_id`,`minlevel`,`maxlevel`,`texture`,`helmtexture`,`armortint_id`,`armortint_red`,`armortint_green`,`armortint_blue`)
SELECT 535,`minlevel`,`maxlevel`,`texture`,`helmtexture`,`armortint_id`,`armortint_red`,`armortint_green`,`armortint_blue` FROM `merc_armorinfo` WHERE `merc_npc_type_id`=79;

INSERT INTO `merc_weaponinfo` (`merc_npc_type_id`,`minlevel`,`maxlevel`,`d_melee_texture1`,`d_melee_texture2`,`prim_melee_type`,`sec_melee_type`)
SELECT 525,`minlevel`,`maxlevel`,`d_melee_texture1`,`d_melee_texture2`,`prim_melee_type`,`sec_melee_type` FROM `merc_weaponinfo` WHERE `merc_npc_type_id`=21;
INSERT INTO `merc_weaponinfo` (`merc_npc_type_id`,`minlevel`,`maxlevel`,`d_melee_texture1`,`d_melee_texture2`,`prim_melee_type`,`sec_melee_type`)
SELECT 526,`minlevel`,`maxlevel`,`d_melee_texture1`,`d_melee_texture2`,`prim_melee_type`,`sec_melee_type` FROM `merc_weaponinfo` WHERE `merc_npc_type_id`=22;
INSERT INTO `merc_weaponinfo` (`merc_npc_type_id`,`minlevel`,`maxlevel`,`d_melee_texture1`,`d_melee_texture2`,`prim_melee_type`,`sec_melee_type`)
SELECT 527,`minlevel`,`maxlevel`,`d_melee_texture1`,`d_melee_texture2`,`prim_melee_type`,`sec_melee_type` FROM `merc_weaponinfo` WHERE `merc_npc_type_id`=23;
INSERT INTO `merc_weaponinfo` (`merc_npc_type_id`,`minlevel`,`maxlevel`,`d_melee_texture1`,`d_melee_texture2`,`prim_melee_type`,`sec_melee_type`)
SELECT 528,`minlevel`,`maxlevel`,`d_melee_texture1`,`d_melee_texture2`,`prim_melee_type`,`sec_melee_type` FROM `merc_weaponinfo` WHERE `merc_npc_type_id`=24;
INSERT INTO `merc_weaponinfo` (`merc_npc_type_id`,`minlevel`,`maxlevel`,`d_melee_texture1`,`d_melee_texture2`,`prim_melee_type`,`sec_melee_type`)
SELECT 529,`minlevel`,`maxlevel`,`d_melee_texture1`,`d_melee_texture2`,`prim_melee_type`,`sec_melee_type` FROM `merc_weaponinfo` WHERE `merc_npc_type_id`=25;
INSERT INTO `merc_weaponinfo` (`merc_npc_type_id`,`minlevel`,`maxlevel`,`d_melee_texture1`,`d_melee_texture2`,`prim_melee_type`,`sec_melee_type`)
SELECT 530,`minlevel`,`maxlevel`,`d_melee_texture1`,`d_melee_texture2`,`prim_melee_type`,`sec_melee_type` FROM `merc_weaponinfo` WHERE `merc_npc_type_id`=26;
INSERT INTO `merc_weaponinfo` (`merc_npc_type_id`,`minlevel`,`maxlevel`,`d_melee_texture1`,`d_melee_texture2`,`prim_melee_type`,`sec_melee_type`)
SELECT 531,`minlevel`,`maxlevel`,`d_melee_texture1`,`d_melee_texture2`,`prim_melee_type`,`sec_melee_type` FROM `merc_weaponinfo` WHERE `merc_npc_type_id`=27;
INSERT INTO `merc_weaponinfo` (`merc_npc_type_id`,`minlevel`,`maxlevel`,`d_melee_texture1`,`d_melee_texture2`,`prim_melee_type`,`sec_melee_type`)
SELECT 532,`minlevel`,`maxlevel`,`d_melee_texture1`,`d_melee_texture2`,`prim_melee_type`,`sec_melee_type` FROM `merc_weaponinfo` WHERE `merc_npc_type_id`=76;
INSERT INTO `merc_weaponinfo` (`merc_npc_type_id`,`minlevel`,`maxlevel`,`d_melee_texture1`,`d_melee_texture2`,`prim_melee_type`,`sec_melee_type`)
SELECT 533,`minlevel`,`maxlevel`,`d_melee_texture1`,`d_melee_texture2`,`prim_melee_type`,`sec_melee_type` FROM `merc_weaponinfo` WHERE `merc_npc_type_id`=78;
INSERT INTO `merc_weaponinfo` (`merc_npc_type_id`,`minlevel`,`maxlevel`,`d_melee_texture1`,`d_melee_texture2`,`prim_melee_type`,`sec_melee_type`)
SELECT 534,`minlevel`,`maxlevel`,`d_melee_texture1`,`d_melee_texture2`,`prim_melee_type`,`sec_melee_type` FROM `merc_weaponinfo` WHERE `merc_npc_type_id`=77;
INSERT INTO `merc_weaponinfo` (`merc_npc_type_id`,`minlevel`,`maxlevel`,`d_melee_texture1`,`d_melee_texture2`,`prim_melee_type`,`sec_melee_type`)
SELECT 535,`minlevel`,`maxlevel`,`d_melee_texture1`,`d_melee_texture2`,`prim_melee_type`,`sec_melee_type` FROM `merc_weaponinfo` WHERE `merc_npc_type_id`=79;

-- ---- corrected wiring ----
-- Hadya (27): Ogre melee line (the missing ninth pirate line)
INSERT INTO `merc_merchant_template_entries` (`merc_merchant_template_id`,`merc_template_id`)
SELECT 27, T.merc_template_id FROM merc_templates T
 JOIN merc_types MY ON MY.merc_type_id=T.merc_type_id
 JOIN merc_subtypes MS ON MS.merc_subtype_id=T.merc_subtype_id
 WHERE MY.race_id=10 AND MS.class_id=9
   AND (MY.proficiency_id, MS.tier_id) IN ((1,1),(1,2),(1,3),(1,4),(1,5),(2,1),(2,2),(3,1),(3,2),(4,1),(4,2));

-- Broker Gex (30): Goblin x4, Nihil x4, Aviak tank  (99)
DELETE FROM `merc_merchant_template_entries` WHERE `merc_merchant_template_id`=30;
INSERT INTO `merc_merchant_template_entries` (`merc_merchant_template_id`,`merc_template_id`)
SELECT 30, T.merc_template_id FROM merc_templates T
 JOIN merc_types MY ON MY.merc_type_id=T.merc_type_id
 JOIN merc_subtypes MS ON MS.merc_subtype_id=T.merc_subtype_id
 WHERE (MY.race_id, MS.class_id) IN ((433,1),(433,2),(433,9),(433,12),(385,1),(385,2),(385,9),(385,12),(13,1))
   AND (MY.proficiency_id, MS.tier_id) IN ((1,1),(1,2),(1,3),(1,4),(1,5),(2,1),(2,2),(3,1),(3,2),(4,1),(4,2));

-- Broker Rul (31): Aviak healer/melee/caster, Dragorn x4, Gelidran healer  (88)
DELETE FROM `merc_merchant_template_entries` WHERE `merc_merchant_template_id`=31;
INSERT INTO `merc_merchant_template_entries` (`merc_merchant_template_id`,`merc_template_id`)
SELECT 31, T.merc_template_id FROM merc_templates T
 JOIN merc_types MY ON MY.merc_type_id=T.merc_type_id
 JOIN merc_subtypes MS ON MS.merc_subtype_id=T.merc_subtype_id
 WHERE (MY.race_id, MS.class_id) IN ((13,2),(13,9),(13,12),(413,1),(413,2),(413,9),(413,12),(417,2))
   AND (MY.proficiency_id, MS.tier_id) IN ((1,1),(1,2),(1,3),(1,4),(1,5),(2,1),(2,2),(3,1),(3,2),(4,1),(4,2));

SELECT E.merc_merchant_template_id g, COUNT(*) c, MAX(ME.merchant_id) liaison
FROM merc_merchant_template_entries E
 LEFT JOIN merc_merchant_entries ME ON ME.merc_merchant_template_id=E.merc_merchant_template_id
WHERE E.merc_merchant_template_id IN (25,26,27,28,29,30,31)
GROUP BY E.merc_merchant_template_id;
