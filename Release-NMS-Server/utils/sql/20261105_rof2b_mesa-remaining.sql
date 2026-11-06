-- 20261105 rof2b port: mesa-remaining - Mesa armor, gifts and living encounters (36 quests/277 activities/27 recipes).
-- Source: github.com/nightstalker6669/EQEmu branch rof2-achievements,
--   extensions/rof2/achievements/content/mesa-remaining (GPL-3.0), ported 2026-11-05.
-- Forward SQL files concatenated verbatim in install order; fail-closed
-- guards and session variables preserved. Reviewed-flag acceptance block
-- added here (upstream reconstruction defaults documented in the package's
-- provenance/ directory; see docs/rof2-zone-quests-attribution.md).
SET NAMES utf8mb4;
SET SESSION check_constraint_checks=1;
SET @mesa_scene_templates_reviewed=1;
SET @mesa_fantoma_acquisition_reviewed=1;
SET @mesa_remaining_recipes_reviewed=1;
SET @mesa_remaining_tasks_reviewed=1;
SET @mesa_parent_rewards_reviewed=1;
-- (reviewed flags accepted: @mesa_scene_templates_reviewed, @mesa_fantoma_acquisition_reviewed, @mesa_remaining_recipes_reviewed, @mesa_remaining_tasks_reviewed, @mesa_parent_rewards_reviewed)

-- ---- mesa-remaining/sql/000-reviewed-settings.sql ----
-- Read provenance/settings before accepting these reconstructed defaults.
SET @mesa_scene_templates_reviewed=1;
SET @mesa_fantoma_acquisition_reviewed=1;
SET @mesa_remaining_recipes_reviewed=1;
SET @mesa_remaining_tasks_reviewed=1;
SET @mesa_parent_rewards_reviewed=1;
-- Import all remaining SQL files in this SAME database session.

-- ---- mesa-remaining/sql/005-catalogue.sql ----
-- Four original May2013 catalogue definitions; no player state.
SET NAMES utf8mb4;
SET SESSION check_constraint_checks=1;
DROP TEMPORARY TABLE IF EXISTS _mesa_extended_catalogue_guard;
CREATE TEMPORARY TABLE _mesa_extended_catalogue_guard(label VARCHAR(80)PRIMARY KEY,ok TINYINT NOT NULL,CHECK(ok=1))ENGINE=InnoDB;
INSERT INTO _mesa_extended_catalogue_guard VALUES('achievements',(NOT EXISTS(SELECT 1 FROM `achievements` WHERE `id` IN(500040400,500040500,500040600,500040700)AND NOT((`id`<=>500040400 AND `name`<=>'Moving Up the Ranks (51-55)' AND `description`<=>'Marilena in the Windwillow''s Grove seeks help against the threats facing the Dryads. Tudor and Laurentiu at the Minohtens'' camp also have a few tasks to offer you:' AND `icon_id`<=>603 AND `points`<=>11 AND `has_reward`<=>1 AND `client_flag`<=>0 AND `version`<=>0 AND `reset_on_version_change`<=>1 AND (`enabled`<=>0 OR `enabled`<=>1)) OR (`id`<=>500040500 AND `name`<=>'Dorina''s Love (Mesa 40+)' AND `description`<=>'Travel to the sacred grove north of the path to Blightfire Moors and learn of Dorina''s plight:' AND `icon_id`<=>3794 AND `points`<=>6 AND `has_reward`<=>1 AND `client_flag`<=>0 AND `version`<=>0 AND `reset_on_version_change`<=>1 AND (`enabled`<=>0 OR `enabled`<=>1)) OR (`id`<=>500040600 AND `name`<=>'Madu''s Armor (Mesa 40+)' AND `description`<=>'Just west to the path to Blightfire Moors you will find Scout Madu. He is offering armor in exchange for completing a number of tasks:' AND `icon_id`<=>805 AND `points`<=>7 AND `has_reward`<=>1 AND `client_flag`<=>0 AND `version`<=>0 AND `reset_on_version_change`<=>1 AND (`enabled`<=>0 OR `enabled`<=>1)) OR (`id`<=>500040700 AND `name`<=>'Ciodaru''s Love (Mesa 45+)' AND `description`<=>'Travel to the Minohten camp to the west and learn of the troubles facing Ciodaru:' AND `icon_id`<=>3299 AND `points`<=>12 AND `has_reward`<=>1 AND `client_flag`<=>0 AND `version`<=>0 AND `reset_on_version_change`<=>1 AND (`enabled`<=>0 OR `enabled`<=>1))))));
INSERT INTO _mesa_extended_catalogue_guard VALUES('achievement_components',(NOT EXISTS(SELECT 1 FROM `achievement_components` WHERE `achievement_id` IN(500040400,500040400,500040400,500040400,500040400,500040400,500040400,500040400,500040400,500040400,500040400,500040400,500040400,500040500,500040500,500040500,500040500,500040500,500040500,500040500,500040500,500040600,500040600,500040600,500040600,500040600,500040600,500040600,500040600,500040600,500040700,500040700,500040700,500040700,500040700,500040700,500040700,500040700,500040700,500040700,500040700,500040700,500040700,500040700) AND `component_id`<>7014 AND NOT((`achievement_id`<=>500040400 AND `component_type`<=>1 AND `sequence`<=>1 AND `component_id`<=>50126 AND `name`<=>'Marilena - Pluck It!' AND `description`<=>'') OR (`achievement_id`<=>500040400 AND `component_type`<=>1 AND `sequence`<=>2 AND `component_id`<=>50127 AND `name`<=>'Marilena - Harpy Horrors' AND `description`<=>'') OR (`achievement_id`<=>500040400 AND `component_type`<=>1 AND `sequence`<=>3 AND `component_id`<=>50128 AND `name`<=>'Tudor - Tudor''s Beer' AND `description`<=>'') OR (`achievement_id`<=>500040400 AND `component_type`<=>1 AND `sequence`<=>4 AND `component_id`<=>50129 AND `name`<=>'Tudor - Tudor''s Ale' AND `description`<=>'') OR (`achievement_id`<=>500040400 AND `component_type`<=>1 AND `sequence`<=>5 AND `component_id`<=>50130 AND `name`<=>'Tudor - Tudor''s Wine' AND `description`<=>'') OR (`achievement_id`<=>500040400 AND `component_type`<=>1 AND `sequence`<=>6 AND `component_id`<=>50131 AND `name`<=>'Tudor - Tudor''s Spirits' AND `description`<=>'') OR (`achievement_id`<=>500040400 AND `component_type`<=>1 AND `sequence`<=>7 AND `component_id`<=>50132 AND `name`<=>'Laurentiu - Vermin Elimination' AND `description`<=>'') OR (`achievement_id`<=>500040400 AND `component_type`<=>1 AND `sequence`<=>8 AND `component_id`<=>50133 AND `name`<=>'Laurentiu - Birds of a Feather' AND `description`<=>'') OR (`achievement_id`<=>500040400 AND `component_type`<=>1 AND `sequence`<=>9 AND `component_id`<=>50134 AND `name`<=>'Laurentiu - Harping on Harpies' AND `description`<=>'') OR (`achievement_id`<=>500040400 AND `component_type`<=>1 AND `sequence`<=>10 AND `component_id`<=>50135 AND `name`<=>'Laurentiu - Dromrek Must Die' AND `description`<=>'') OR (`achievement_id`<=>500040400 AND `component_type`<=>1 AND `sequence`<=>11 AND `component_id`<=>50136 AND `name`<=>'Laurentiu - Cleanse Serpent''s Falls' AND `description`<=>'') OR (`achievement_id`<=>500040400 AND `component_type`<=>3 AND `sequence`<=>0 AND `component_id`<=>2058 AND `name`<=>'Reach Level 50' AND `description`<=>'') OR (`achievement_id`<=>500040400 AND `component_type`<=>3 AND `sequence`<=>0 AND `component_id`<=>7011 AND `name`<=>'Serpent' AND `description`<=>'') OR (`achievement_id`<=>500040500 AND `component_type`<=>1 AND `sequence`<=>1 AND `component_id`<=>50137 AND `name`<=>'Dorina - Dorina''s Love' AND `description`<=>'') OR (`achievement_id`<=>500040500 AND `component_type`<=>1 AND `sequence`<=>2 AND `component_id`<=>50138 AND `name`<=>'Dorina - Dorina''s Love Letter' AND `description`<=>'') OR (`achievement_id`<=>500040500 AND `component_type`<=>1 AND `sequence`<=>3 AND `component_id`<=>50139 AND `name`<=>'Dorina - Dorina''s Gift' AND `description`<=>'') OR (`achievement_id`<=>500040500 AND `component_type`<=>1 AND `sequence`<=>4 AND `component_id`<=>50140 AND `name`<=>'Dorina - Dorina''s Personalized Gift' AND `description`<=>'') OR (`achievement_id`<=>500040500 AND `component_type`<=>1 AND `sequence`<=>5 AND `component_id`<=>50141 AND `name`<=>'Dorina - Dorina''s Potion' AND `description`<=>'') OR (`achievement_id`<=>500040500 AND `component_type`<=>1 AND `sequence`<=>6 AND `component_id`<=>50142 AND `name`<=>'Dorina - Dorina''s Lament' AND `description`<=>'') OR (`achievement_id`<=>500040500 AND `component_type`<=>3 AND `sequence`<=>0 AND `component_id`<=>2048 AND `name`<=>'Reach Level 40' AND `description`<=>'') OR (`achievement_id`<=>500040500 AND `component_type`<=>3 AND `sequence`<=>0 AND `component_id`<=>7011 AND `name`<=>'Serpent' AND `description`<=>'') OR (`achievement_id`<=>500040600 AND `component_type`<=>1 AND `sequence`<=>1 AND `component_id`<=>50143 AND `name`<=>'Scout Madu - Wolf Skins for Madu' AND `description`<=>'') OR (`achievement_id`<=>500040600 AND `component_type`<=>1 AND `sequence`<=>2 AND `component_id`<=>50144 AND `name`<=>'Scout Madu - Bear Pelts for Madu' AND `description`<=>'') OR (`achievement_id`<=>500040600 AND `component_type`<=>1 AND `sequence`<=>3 AND `component_id`<=>50145 AND `name`<=>'Scout Madu - Snake Skins for Madu' AND `description`<=>'') OR (`achievement_id`<=>500040600 AND `component_type`<=>1 AND `sequence`<=>4 AND `component_id`<=>50146 AND `name`<=>'Scout Madu - Spider Silk for Madu' AND `description`<=>'') OR (`achievement_id`<=>500040600 AND `component_type`<=>1 AND `sequence`<=>5 AND `component_id`<=>50147 AND `name`<=>'Scout Madu - Madu Needs More Supplies' AND `description`<=>'') OR (`achievement_id`<=>500040600 AND `component_type`<=>1 AND `sequence`<=>6 AND `component_id`<=>50148 AND `name`<=>'Scout Madu - Kill Fantoma' AND `description`<=>'') OR (`achievement_id`<=>500040600 AND `component_type`<=>1 AND `sequence`<=>7 AND `component_id`<=>50149 AND `name`<=>'Scout Madu - Kill Ursalua' AND `description`<=>'') OR (`achievement_id`<=>500040600 AND `component_type`<=>3 AND `sequence`<=>0 AND `component_id`<=>2048 AND `name`<=>'Reach Level 40' AND `description`<=>'') OR (`achievement_id`<=>500040600 AND `component_type`<=>3 AND `sequence`<=>0 AND `component_id`<=>7011 AND `name`<=>'Serpent' AND `description`<=>'') OR (`achievement_id`<=>500040700 AND `component_type`<=>1 AND `sequence`<=>1 AND `component_id`<=>50150 AND `name`<=>'Ciodaru - Ciodaru''s Love' AND `description`<=>'') OR (`achievement_id`<=>500040700 AND `component_type`<=>1 AND `sequence`<=>2 AND `component_id`<=>50151 AND `name`<=>'Ciodaru - Ciodaru''s First Gift' AND `description`<=>'') OR (`achievement_id`<=>500040700 AND `component_type`<=>1 AND `sequence`<=>3 AND `component_id`<=>50152 AND `name`<=>'Ciodaru - Ciodaru''s Second Gift' AND `description`<=>'') OR (`achievement_id`<=>500040700 AND `component_type`<=>1 AND `sequence`<=>4 AND `component_id`<=>50153 AND `name`<=>'Ciodaru - Protect Kathryn' AND `description`<=>'') OR (`achievement_id`<=>500040700 AND `component_type`<=>1 AND `sequence`<=>5 AND `component_id`<=>50154 AND `name`<=>'Ciodaru - Ciodaru''s Third Gift' AND `description`<=>'') OR (`achievement_id`<=>500040700 AND `component_type`<=>1 AND `sequence`<=>6 AND `component_id`<=>50155 AND `name`<=>'Ciodaru - Ciodaru''s Fourth Gift' AND `description`<=>'') OR (`achievement_id`<=>500040700 AND `component_type`<=>1 AND `sequence`<=>7 AND `component_id`<=>50156 AND `name`<=>'Ciodaru - Protect Kathryn Again' AND `description`<=>'') OR (`achievement_id`<=>500040700 AND `component_type`<=>1 AND `sequence`<=>8 AND `component_id`<=>50157 AND `name`<=>'Ciodaru - Ciodaru''s Fifth Gift' AND `description`<=>'') OR (`achievement_id`<=>500040700 AND `component_type`<=>1 AND `sequence`<=>9 AND `component_id`<=>50158 AND `name`<=>'Ciodaru - Ciodaru''s Sixth Gift' AND `description`<=>'') OR (`achievement_id`<=>500040700 AND `component_type`<=>1 AND `sequence`<=>10 AND `component_id`<=>50159 AND `name`<=>'Ciodaru - Protect Kathryn Some More' AND `description`<=>'') OR (`achievement_id`<=>500040700 AND `component_type`<=>1 AND `sequence`<=>11 AND `component_id`<=>50160 AND `name`<=>'Ciodaru - Who Wants to Kill Kathryn?' AND `description`<=>'') OR (`achievement_id`<=>500040700 AND `component_type`<=>1 AND `sequence`<=>12 AND `component_id`<=>50161 AND `name`<=>'Ciodaru - Ciodaru''s Gift Box' AND `description`<=>'') OR (`achievement_id`<=>500040700 AND `component_type`<=>3 AND `sequence`<=>0 AND `component_id`<=>2053 AND `name`<=>'Reach Level 45' AND `description`<=>'') OR (`achievement_id`<=>500040700 AND `component_type`<=>3 AND `sequence`<=>0 AND `component_id`<=>7011 AND `name`<=>'Serpent' AND `description`<=>'')))));
INSERT INTO _mesa_extended_catalogue_guard VALUES('achievement_category_associations',(NOT EXISTS(SELECT 1 FROM `achievement_category_associations` WHERE `achievement_id` IN(500040400,500040500,500040600,500040700)AND NOT((`category_id`<=>71 AND `sequence`<=>0 AND `achievement_id`<=>500040400 AND `display_text`<=>'') OR (`category_id`<=>72 AND `sequence`<=>0 AND `achievement_id`<=>500040500 AND `display_text`<=>'') OR (`category_id`<=>72 AND `sequence`<=>0 AND `achievement_id`<=>500040600 AND `display_text`<=>'') OR (`category_id`<=>72 AND `sequence`<=>0 AND `achievement_id`<=>500040700 AND `display_text`<=>'')))));
INSERT INTO _mesa_extended_catalogue_guard VALUES('achievement_categories',(NOT EXISTS(SELECT 1 FROM `achievement_categories` WHERE `id` IN(70,71,72)AND NOT((`id`<=>70 AND `parent_id`<=>0 AND `sequence`<=>3 AND `name`<=>'The Hero''s Journey' AND `description`<=>'The Hero''s Journey' AND `icon`<=>'A_HJNY') OR (`id`<=>71 AND `parent_id`<=>70 AND `sequence`<=>1 AND `name`<=>'Progression' AND `description`<=>'Progression' AND `icon`<=>'A_ProgressionSub') OR (`id`<=>72 AND `parent_id`<=>70 AND `sequence`<=>2 AND `name`<=>'Advancement' AND `description`<=>'Advancement' AND `icon`<=>'A_AdvancementSub')))));
START TRANSACTION;
INSERT INTO `achievement_categories`(`id`,`parent_id`,`sequence`,`name`,`description`,`icon`)VALUES
(70,0,3,'The Hero''s Journey','The Hero''s Journey','A_HJNY'),
(71,70,1,'Progression','Progression','A_ProgressionSub'),
(72,70,2,'Advancement','Advancement','A_AdvancementSub')
ON DUPLICATE KEY UPDATE `id`=VALUES(`id`),`parent_id`=VALUES(`parent_id`),`sequence`=VALUES(`sequence`),`name`=VALUES(`name`),`description`=VALUES(`description`),`icon`=VALUES(`icon`);
INSERT INTO `achievements`(`id`,`name`,`description`,`icon_id`,`points`,`has_reward`,`client_flag`,`version`,`reset_on_version_change`,`enabled`)VALUES
(500040400,'Moving Up the Ranks (51-55)','Marilena in the Windwillow''s Grove seeks help against the threats facing the Dryads. Tudor and Laurentiu at the Minohtens'' camp also have a few tasks to offer you:',603,11,1,0,0,1,1),
(500040500,'Dorina''s Love (Mesa 40+)','Travel to the sacred grove north of the path to Blightfire Moors and learn of Dorina''s plight:',3794,6,1,0,0,1,1),
(500040600,'Madu''s Armor (Mesa 40+)','Just west to the path to Blightfire Moors you will find Scout Madu. He is offering armor in exchange for completing a number of tasks:',805,7,1,0,0,1,1),
(500040700,'Ciodaru''s Love (Mesa 45+)','Travel to the Minohten camp to the west and learn of the troubles facing Ciodaru:',3299,12,1,0,0,1,1)
ON DUPLICATE KEY UPDATE `id`=VALUES(`id`),`name`=VALUES(`name`),`description`=VALUES(`description`),`icon_id`=VALUES(`icon_id`),`points`=VALUES(`points`),`has_reward`=VALUES(`has_reward`),`client_flag`=VALUES(`client_flag`),`version`=VALUES(`version`),`reset_on_version_change`=VALUES(`reset_on_version_change`),`enabled`=VALUES(`enabled`);
INSERT INTO `achievement_components`(`achievement_id`,`component_type`,`sequence`,`component_id`,`name`,`description`)VALUES
(500040400,1,1,50126,'Marilena - Pluck It!',''),
(500040400,1,2,50127,'Marilena - Harpy Horrors',''),
(500040400,1,3,50128,'Tudor - Tudor''s Beer',''),
(500040400,1,4,50129,'Tudor - Tudor''s Ale',''),
(500040400,1,5,50130,'Tudor - Tudor''s Wine',''),
(500040400,1,6,50131,'Tudor - Tudor''s Spirits',''),
(500040400,1,7,50132,'Laurentiu - Vermin Elimination',''),
(500040400,1,8,50133,'Laurentiu - Birds of a Feather',''),
(500040400,1,9,50134,'Laurentiu - Harping on Harpies',''),
(500040400,1,10,50135,'Laurentiu - Dromrek Must Die',''),
(500040400,1,11,50136,'Laurentiu - Cleanse Serpent''s Falls',''),
(500040400,3,0,2058,'Reach Level 50',''),
(500040400,3,0,7011,'Serpent',''),
(500040500,1,1,50137,'Dorina - Dorina''s Love',''),
(500040500,1,2,50138,'Dorina - Dorina''s Love Letter',''),
(500040500,1,3,50139,'Dorina - Dorina''s Gift',''),
(500040500,1,4,50140,'Dorina - Dorina''s Personalized Gift',''),
(500040500,1,5,50141,'Dorina - Dorina''s Potion',''),
(500040500,1,6,50142,'Dorina - Dorina''s Lament',''),
(500040500,3,0,2048,'Reach Level 40',''),
(500040500,3,0,7011,'Serpent',''),
(500040600,1,1,50143,'Scout Madu - Wolf Skins for Madu',''),
(500040600,1,2,50144,'Scout Madu - Bear Pelts for Madu',''),
(500040600,1,3,50145,'Scout Madu - Snake Skins for Madu',''),
(500040600,1,4,50146,'Scout Madu - Spider Silk for Madu',''),
(500040600,1,5,50147,'Scout Madu - Madu Needs More Supplies',''),
(500040600,1,6,50148,'Scout Madu - Kill Fantoma',''),
(500040600,1,7,50149,'Scout Madu - Kill Ursalua',''),
(500040600,3,0,2048,'Reach Level 40',''),
(500040600,3,0,7011,'Serpent',''),
(500040700,1,1,50150,'Ciodaru - Ciodaru''s Love',''),
(500040700,1,2,50151,'Ciodaru - Ciodaru''s First Gift',''),
(500040700,1,3,50152,'Ciodaru - Ciodaru''s Second Gift',''),
(500040700,1,4,50153,'Ciodaru - Protect Kathryn',''),
(500040700,1,5,50154,'Ciodaru - Ciodaru''s Third Gift',''),
(500040700,1,6,50155,'Ciodaru - Ciodaru''s Fourth Gift',''),
(500040700,1,7,50156,'Ciodaru - Protect Kathryn Again',''),
(500040700,1,8,50157,'Ciodaru - Ciodaru''s Fifth Gift',''),
(500040700,1,9,50158,'Ciodaru - Ciodaru''s Sixth Gift',''),
(500040700,1,10,50159,'Ciodaru - Protect Kathryn Some More',''),
(500040700,1,11,50160,'Ciodaru - Who Wants to Kill Kathryn?',''),
(500040700,1,12,50161,'Ciodaru - Ciodaru''s Gift Box',''),
(500040700,3,0,2053,'Reach Level 45',''),
(500040700,3,0,7011,'Serpent','')
ON DUPLICATE KEY UPDATE `achievement_id`=VALUES(`achievement_id`),`component_type`=VALUES(`component_type`),`sequence`=VALUES(`sequence`),`component_id`=VALUES(`component_id`),`name`=VALUES(`name`),`description`=VALUES(`description`);
INSERT INTO `achievement_category_associations`(`category_id`,`sequence`,`achievement_id`,`display_text`)VALUES
(71,0,500040400,''),
(72,0,500040500,''),
(72,0,500040600,''),
(72,0,500040700,'')
ON DUPLICATE KEY UPDATE `category_id`=VALUES(`category_id`),`sequence`=VALUES(`sequence`),`achievement_id`=VALUES(`achievement_id`),`display_text`=VALUES(`display_text`);
COMMIT;

-- ---- mesa-remaining/sql/010-scene-templates.sql ----
-- RESEARCHED scene-template candidate; not deployed/native verified.
-- Historical identities/effects below; inherited PEQ combat/appearance remain labelled defaults.
-- Requires explicit review. Fantoma spawn and loot probability are separate unresolved dependencies.
SET SESSION check_constraint_checks=1;
DROP TEMPORARY TABLE IF EXISTS _mesa_scene_guard;
CREATE TEMPORARY TABLE _mesa_scene_guard(label VARCHAR(100) PRIMARY KEY,ok TINYINT NOT NULL,CHECK(ok=1))ENGINE=InnoDB;
INSERT INTO _mesa_scene_guard VALUES('review',COALESCE(@mesa_scene_templates_reviewed,0)=1);
SET @mesa_thug_hp=COALESCE(@mesa_thug_hp,3500);
INSERT INTO _mesa_scene_guard VALUES('setting_thug_hp',@mesa_thug_hp BETWEEN 1 AND 1000000 AND @mesa_thug_hp=FLOOR(@mesa_thug_hp));
SET @mesa_thug_min_hit=COALESCE(@mesa_thug_min_hit,20);
INSERT INTO _mesa_scene_guard VALUES('setting_thug_min_hit',@mesa_thug_min_hit BETWEEN 0 AND 10000 AND @mesa_thug_min_hit=FLOOR(@mesa_thug_min_hit));
SET @mesa_thug_max_hit=COALESCE(@mesa_thug_max_hit,80);
INSERT INTO _mesa_scene_guard VALUES('setting_thug_max_hit',@mesa_thug_max_hit BETWEEN 1 AND 10000 AND @mesa_thug_max_hit=FLOOR(@mesa_thug_max_hit));
SET @mesa_grabber_hp=COALESCE(@mesa_grabber_hp,3000);
INSERT INTO _mesa_scene_guard VALUES('setting_grabber_hp',@mesa_grabber_hp BETWEEN 1 AND 1000000 AND @mesa_grabber_hp=FLOOR(@mesa_grabber_hp));
SET @mesa_grabber_min_hit=COALESCE(@mesa_grabber_min_hit,15);
INSERT INTO _mesa_scene_guard VALUES('setting_grabber_min_hit',@mesa_grabber_min_hit BETWEEN 0 AND 10000 AND @mesa_grabber_min_hit=FLOOR(@mesa_grabber_min_hit));
SET @mesa_grabber_max_hit=COALESCE(@mesa_grabber_max_hit,65);
INSERT INTO _mesa_scene_guard VALUES('setting_grabber_max_hit',@mesa_grabber_max_hit BETWEEN 1 AND 10000 AND @mesa_grabber_max_hit=FLOOR(@mesa_grabber_max_hit));
SET @mesa_raider_hp=COALESCE(@mesa_raider_hp,4000);
INSERT INTO _mesa_scene_guard VALUES('setting_raider_hp',@mesa_raider_hp BETWEEN 1 AND 1000000 AND @mesa_raider_hp=FLOOR(@mesa_raider_hp));
SET @mesa_raider_min_hit=COALESCE(@mesa_raider_min_hit,25);
INSERT INTO _mesa_scene_guard VALUES('setting_raider_min_hit',@mesa_raider_min_hit BETWEEN 0 AND 10000 AND @mesa_raider_min_hit=FLOOR(@mesa_raider_min_hit));
SET @mesa_raider_max_hit=COALESCE(@mesa_raider_max_hit,100);
INSERT INTO _mesa_scene_guard VALUES('setting_raider_max_hit',@mesa_raider_max_hit BETWEEN 1 AND 10000 AND @mesa_raider_max_hit=FLOOR(@mesa_raider_max_hit));
SET @mesa_fantoma_hp=COALESCE(@mesa_fantoma_hp,6000);
INSERT INTO _mesa_scene_guard VALUES('setting_fantoma_hp',@mesa_fantoma_hp BETWEEN 1 AND 1000000 AND @mesa_fantoma_hp=FLOOR(@mesa_fantoma_hp));
SET @mesa_fantoma_min_hit=COALESCE(@mesa_fantoma_min_hit,25);
INSERT INTO _mesa_scene_guard VALUES('setting_fantoma_min_hit',@mesa_fantoma_min_hit BETWEEN 0 AND 10000 AND @mesa_fantoma_min_hit=FLOOR(@mesa_fantoma_min_hit));
SET @mesa_fantoma_max_hit=COALESCE(@mesa_fantoma_max_hit,50);
INSERT INTO _mesa_scene_guard VALUES('setting_fantoma_max_hit',@mesa_fantoma_max_hit BETWEEN 1 AND 10000 AND @mesa_fantoma_max_hit=FLOOR(@mesa_fantoma_max_hit));
SET @mesa_thug_proc_chance=COALESCE(@mesa_thug_proc_chance,3);
INSERT INTO _mesa_scene_guard VALUES('setting_thug_proc_chance',@mesa_thug_proc_chance BETWEEN 0 AND 127 AND @mesa_thug_proc_chance=FLOOR(@mesa_thug_proc_chance));
SET @mesa_fantoma_proc_chance=COALESCE(@mesa_fantoma_proc_chance,3);
INSERT INTO _mesa_scene_guard VALUES('setting_fantoma_proc_chance',@mesa_fantoma_proc_chance BETWEEN 0 AND 127 AND @mesa_fantoma_proc_chance=FLOOR(@mesa_fantoma_proc_chance));
INSERT INTO _mesa_scene_guard VALUES('hit_order_thug',@mesa_thug_min_hit+0<=@mesa_thug_max_hit+0);
INSERT INTO _mesa_scene_guard VALUES('hit_order_grabber',@mesa_grabber_min_hit+0<=@mesa_grabber_max_hit+0);
INSERT INTO _mesa_scene_guard VALUES('hit_order_raider',@mesa_raider_min_hit+0<=@mesa_raider_max_hit+0);
INSERT INTO _mesa_scene_guard VALUES('hit_order_fantoma',@mesa_fantoma_min_hit+0<=@mesa_fantoma_max_hit+0);
INSERT INTO _mesa_scene_guard SELECT 'spell_8639',COUNT(*)=1 FROM spells_new WHERE id=8639 AND name='Entrancing Song';
INSERT INTO _mesa_scene_guard SELECT 'spell_8712',COUNT(*)=1 FROM spells_new WHERE id=8712 AND name='Tendon Rip';
INSERT INTO _mesa_scene_guard SELECT 'npc_types_397901',NOT EXISTS(SELECT 1 FROM npc_types WHERE id=397901 AND NOT(`id`<=>397901 AND `name`<=>'a_Tuffein_thug' AND `lastname`<=>'' AND `level`<=>45 AND `race`<=>529 AND `class`<=>1 AND `bodytype`<=>1 AND `hp`<=>@mesa_thug_hp AND `mana`<=>0 AND `gender`<=>2 AND `texture`<=>1 AND `helmtexture`<=>1 AND `herosforgemodel`<=>0 AND `size`<=>6 AND `hp_regen_rate`<=>0 AND `hp_regen_per_second`<=>0 AND `mana_regen_rate`<=>0 AND `loottable_id`<=>0 AND `merchant_id`<=>0 AND `greed`<=>0 AND `alt_currency_id`<=>0 AND `npc_spells_id`<=>397901 AND `npc_spells_effects_id`<=>0 AND `npc_faction_id`<=>0 AND `adventure_template_id`<=>0 AND `trap_template`<=>0 AND `mindmg`<=>@mesa_thug_min_hit AND `maxdmg`<=>@mesa_thug_max_hit AND `attack_count`<=>-1 AND `npcspecialattks`<=>'' AND `special_abilities`<=>'' AND `aggroradius`<=>0 AND `assistradius`<=>0 AND `face`<=>0 AND `luclin_hairstyle`<=>0 AND `luclin_haircolor`<=>0 AND `luclin_eyecolor`<=>0 AND `luclin_eyecolor2`<=>0 AND `luclin_beardcolor`<=>0 AND `luclin_beard`<=>255 AND `drakkin_heritage`<=>0 AND `drakkin_tattoo`<=>0 AND `drakkin_details`<=>0 AND `armortint_id`<=>0 AND `armortint_red`<=>0 AND `armortint_green`<=>0 AND `armortint_blue`<=>0 AND `d_melee_texture1`<=>10872 AND `d_melee_texture2`<=>10985 AND `ammo_idfile`<=>'IT10' AND `prim_melee_type`<=>28 AND `sec_melee_type`<=>28 AND `ranged_type`<=>7 AND `runspeed`<=>1.25 AND `MR`<=>0 AND `CR`<=>0 AND `DR`<=>0 AND `FR`<=>0 AND `PR`<=>0 AND `Corrup`<=>0 AND `PhR`<=>10 AND `see_invis`<=>0 AND `see_invis_undead`<=>0 AND `qglobal`<=>0 AND `AC`<=>229 AND `npc_aggro`<=>0 AND `spawn_limit`<=>0 AND `attack_speed`<=>0 AND `attack_delay`<=>30 AND `findable`<=>0 AND `STR`<=>185 AND `STA`<=>185 AND `DEX`<=>185 AND `AGI`<=>185 AND `_INT`<=>185 AND `WIS`<=>185 AND `CHA`<=>185 AND `see_hide`<=>0 AND `see_improved_hide`<=>0 AND `trackable`<=>1 AND `isbot`<=>0 AND `exclude`<=>0 AND `ATK`<=>0 AND `Accuracy`<=>0 AND `Avoidance`<=>0 AND `slow_mitigation`<=>0 AND `version`<=>0 AND `maxlevel`<=>0 AND `scalerate`<=>100 AND `private_corpse`<=>0 AND `unique_spawn_by_name`<=>0 AND `underwater`<=>0 AND `isquest`<=>1 AND `emoteid`<=>0 AND `spellscale`<=>100 AND `healscale`<=>100 AND `no_target_hotkey`<=>0 AND `raid_target`<=>0 AND `armtexture`<=>0 AND `bracertexture`<=>0 AND `handtexture`<=>0 AND `legtexture`<=>0 AND `feettexture`<=>0 AND `light`<=>0 AND `walkspeed`<=>0 AND `peqid`<=>0 AND `unique_`<=>0 AND `fixed`<=>0 AND `ignore_despawn`<=>0 AND `show_name`<=>1 AND `untargetable`<=>0 AND `charm_ac`<=>0 AND `charm_min_dmg`<=>0 AND `charm_max_dmg`<=>0 AND `charm_attack_delay`<=>0 AND `charm_accuracy_rating`<=>0 AND `charm_avoidance_rating`<=>0 AND `charm_atk`<=>0 AND `skip_global_loot`<=>0 AND `rare_spawn`<=>0 AND `stuck_behavior`<=>0 AND `model`<=>0 AND `flymode`<=>-1 AND `always_aggro`<=>0 AND `exp_mod`<=>100 AND `heroic_strikethrough`<=>0 AND `faction_amount`<=>0 AND `keeps_sold_items`<=>1 AND `is_parcel_merchant`<=>0 AND `multiquest_enabled`<=>0 AND `npc_tint_id`<=>0));
INSERT INTO _mesa_scene_guard SELECT 'npc_types_397902',NOT EXISTS(SELECT 1 FROM npc_types WHERE id=397902 AND NOT(`id`<=>397902 AND `name`<=>'a_Tuffein_grabber' AND `lastname`<=>'' AND `level`<=>40 AND `race`<=>529 AND `class`<=>6 AND `bodytype`<=>1 AND `hp`<=>@mesa_grabber_hp AND `mana`<=>0 AND `gender`<=>2 AND `texture`<=>1 AND `helmtexture`<=>1 AND `herosforgemodel`<=>0 AND `size`<=>6 AND `hp_regen_rate`<=>0 AND `hp_regen_per_second`<=>0 AND `mana_regen_rate`<=>0 AND `loottable_id`<=>0 AND `merchant_id`<=>0 AND `greed`<=>0 AND `alt_currency_id`<=>0 AND `npc_spells_id`<=>0 AND `npc_spells_effects_id`<=>0 AND `npc_faction_id`<=>0 AND `adventure_template_id`<=>0 AND `trap_template`<=>0 AND `mindmg`<=>@mesa_grabber_min_hit AND `maxdmg`<=>@mesa_grabber_max_hit AND `attack_count`<=>-1 AND `npcspecialattks`<=>'' AND `special_abilities`<=>'' AND `aggroradius`<=>0 AND `assistradius`<=>0 AND `face`<=>0 AND `luclin_hairstyle`<=>0 AND `luclin_haircolor`<=>0 AND `luclin_eyecolor`<=>0 AND `luclin_eyecolor2`<=>0 AND `luclin_beardcolor`<=>0 AND `luclin_beard`<=>255 AND `drakkin_heritage`<=>0 AND `drakkin_tattoo`<=>0 AND `drakkin_details`<=>0 AND `armortint_id`<=>0 AND `armortint_red`<=>0 AND `armortint_green`<=>0 AND `armortint_blue`<=>0 AND `d_melee_texture1`<=>0 AND `d_melee_texture2`<=>0 AND `ammo_idfile`<=>'IT10' AND `prim_melee_type`<=>28 AND `sec_melee_type`<=>28 AND `ranged_type`<=>7 AND `runspeed`<=>1.25 AND `MR`<=>0 AND `CR`<=>0 AND `DR`<=>0 AND `FR`<=>0 AND `PR`<=>0 AND `Corrup`<=>0 AND `PhR`<=>10 AND `see_invis`<=>0 AND `see_invis_undead`<=>0 AND `qglobal`<=>0 AND `AC`<=>200 AND `npc_aggro`<=>0 AND `spawn_limit`<=>0 AND `attack_speed`<=>0 AND `attack_delay`<=>30 AND `findable`<=>0 AND `STR`<=>163 AND `STA`<=>163 AND `DEX`<=>163 AND `AGI`<=>163 AND `_INT`<=>163 AND `WIS`<=>163 AND `CHA`<=>163 AND `see_hide`<=>0 AND `see_improved_hide`<=>0 AND `trackable`<=>1 AND `isbot`<=>0 AND `exclude`<=>0 AND `ATK`<=>0 AND `Accuracy`<=>0 AND `Avoidance`<=>0 AND `slow_mitigation`<=>0 AND `version`<=>0 AND `maxlevel`<=>0 AND `scalerate`<=>100 AND `private_corpse`<=>0 AND `unique_spawn_by_name`<=>0 AND `underwater`<=>0 AND `isquest`<=>1 AND `emoteid`<=>0 AND `spellscale`<=>100 AND `healscale`<=>100 AND `no_target_hotkey`<=>0 AND `raid_target`<=>0 AND `armtexture`<=>0 AND `bracertexture`<=>0 AND `handtexture`<=>0 AND `legtexture`<=>0 AND `feettexture`<=>0 AND `light`<=>0 AND `walkspeed`<=>0 AND `peqid`<=>0 AND `unique_`<=>0 AND `fixed`<=>0 AND `ignore_despawn`<=>0 AND `show_name`<=>1 AND `untargetable`<=>0 AND `charm_ac`<=>0 AND `charm_min_dmg`<=>0 AND `charm_max_dmg`<=>0 AND `charm_attack_delay`<=>0 AND `charm_accuracy_rating`<=>0 AND `charm_avoidance_rating`<=>0 AND `charm_atk`<=>0 AND `skip_global_loot`<=>0 AND `rare_spawn`<=>0 AND `stuck_behavior`<=>0 AND `model`<=>0 AND `flymode`<=>-1 AND `always_aggro`<=>0 AND `exp_mod`<=>100 AND `heroic_strikethrough`<=>0 AND `faction_amount`<=>0 AND `keeps_sold_items`<=>1 AND `is_parcel_merchant`<=>0 AND `multiquest_enabled`<=>0 AND `npc_tint_id`<=>0));
INSERT INTO _mesa_scene_guard SELECT 'npc_types_397903',NOT EXISTS(SELECT 1 FROM npc_types WHERE id=397903 AND NOT(`id`<=>397903 AND `name`<=>'a_Tuffein_raider' AND `lastname`<=>'' AND `level`<=>45 AND `race`<=>529 AND `class`<=>1 AND `bodytype`<=>1 AND `hp`<=>@mesa_raider_hp AND `mana`<=>0 AND `gender`<=>2 AND `texture`<=>1 AND `helmtexture`<=>1 AND `herosforgemodel`<=>0 AND `size`<=>6 AND `hp_regen_rate`<=>0 AND `hp_regen_per_second`<=>0 AND `mana_regen_rate`<=>0 AND `loottable_id`<=>0 AND `merchant_id`<=>0 AND `greed`<=>0 AND `alt_currency_id`<=>0 AND `npc_spells_id`<=>0 AND `npc_spells_effects_id`<=>0 AND `npc_faction_id`<=>0 AND `adventure_template_id`<=>0 AND `trap_template`<=>0 AND `mindmg`<=>@mesa_raider_min_hit AND `maxdmg`<=>@mesa_raider_max_hit AND `attack_count`<=>-1 AND `npcspecialattks`<=>'' AND `special_abilities`<=>'' AND `aggroradius`<=>0 AND `assistradius`<=>0 AND `face`<=>0 AND `luclin_hairstyle`<=>0 AND `luclin_haircolor`<=>0 AND `luclin_eyecolor`<=>0 AND `luclin_eyecolor2`<=>0 AND `luclin_beardcolor`<=>0 AND `luclin_beard`<=>255 AND `drakkin_heritage`<=>0 AND `drakkin_tattoo`<=>0 AND `drakkin_details`<=>0 AND `armortint_id`<=>0 AND `armortint_red`<=>0 AND `armortint_green`<=>0 AND `armortint_blue`<=>0 AND `d_melee_texture1`<=>10872 AND `d_melee_texture2`<=>10985 AND `ammo_idfile`<=>'IT10' AND `prim_melee_type`<=>28 AND `sec_melee_type`<=>28 AND `ranged_type`<=>7 AND `runspeed`<=>1.25 AND `MR`<=>0 AND `CR`<=>0 AND `DR`<=>0 AND `FR`<=>0 AND `PR`<=>0 AND `Corrup`<=>0 AND `PhR`<=>10 AND `see_invis`<=>0 AND `see_invis_undead`<=>0 AND `qglobal`<=>0 AND `AC`<=>229 AND `npc_aggro`<=>0 AND `spawn_limit`<=>0 AND `attack_speed`<=>0 AND `attack_delay`<=>30 AND `findable`<=>0 AND `STR`<=>185 AND `STA`<=>185 AND `DEX`<=>185 AND `AGI`<=>185 AND `_INT`<=>185 AND `WIS`<=>185 AND `CHA`<=>185 AND `see_hide`<=>0 AND `see_improved_hide`<=>0 AND `trackable`<=>1 AND `isbot`<=>0 AND `exclude`<=>0 AND `ATK`<=>0 AND `Accuracy`<=>0 AND `Avoidance`<=>0 AND `slow_mitigation`<=>0 AND `version`<=>0 AND `maxlevel`<=>0 AND `scalerate`<=>100 AND `private_corpse`<=>0 AND `unique_spawn_by_name`<=>0 AND `underwater`<=>0 AND `isquest`<=>1 AND `emoteid`<=>0 AND `spellscale`<=>100 AND `healscale`<=>100 AND `no_target_hotkey`<=>0 AND `raid_target`<=>0 AND `armtexture`<=>0 AND `bracertexture`<=>0 AND `handtexture`<=>0 AND `legtexture`<=>0 AND `feettexture`<=>0 AND `light`<=>0 AND `walkspeed`<=>0 AND `peqid`<=>0 AND `unique_`<=>0 AND `fixed`<=>0 AND `ignore_despawn`<=>0 AND `show_name`<=>1 AND `untargetable`<=>0 AND `charm_ac`<=>0 AND `charm_min_dmg`<=>0 AND `charm_max_dmg`<=>0 AND `charm_attack_delay`<=>0 AND `charm_accuracy_rating`<=>0 AND `charm_avoidance_rating`<=>0 AND `charm_atk`<=>0 AND `skip_global_loot`<=>0 AND `rare_spawn`<=>0 AND `stuck_behavior`<=>0 AND `model`<=>0 AND `flymode`<=>-1 AND `always_aggro`<=>0 AND `exp_mod`<=>100 AND `heroic_strikethrough`<=>0 AND `faction_amount`<=>0 AND `keeps_sold_items`<=>1 AND `is_parcel_merchant`<=>0 AND `multiquest_enabled`<=>0 AND `npc_tint_id`<=>0));
INSERT INTO _mesa_scene_guard SELECT 'npc_types_397904',NOT EXISTS(SELECT 1 FROM npc_types WHERE id=397904 AND NOT(`id`<=>397904 AND `name`<=>'Fantoma' AND `lastname`<=>'' AND `level`<=>45 AND `race`<=>42 AND `class`<=>1 AND `bodytype`<=>21 AND `hp`<=>@mesa_fantoma_hp AND `mana`<=>0 AND `gender`<=>2 AND `texture`<=>0 AND `helmtexture`<=>0 AND `herosforgemodel`<=>0 AND `size`<=>4 AND `hp_regen_rate`<=>0 AND `hp_regen_per_second`<=>0 AND `mana_regen_rate`<=>0 AND `loottable_id`<=>397904 AND `merchant_id`<=>0 AND `greed`<=>0 AND `alt_currency_id`<=>0 AND `npc_spells_id`<=>397904 AND `npc_spells_effects_id`<=>0 AND `npc_faction_id`<=>0 AND `adventure_template_id`<=>0 AND `trap_template`<=>0 AND `mindmg`<=>@mesa_fantoma_min_hit AND `maxdmg`<=>@mesa_fantoma_max_hit AND `attack_count`<=>-1 AND `npcspecialattks`<=>'' AND `special_abilities`<=>'' AND `aggroradius`<=>0 AND `assistradius`<=>0 AND `face`<=>0 AND `luclin_hairstyle`<=>0 AND `luclin_haircolor`<=>0 AND `luclin_eyecolor`<=>0 AND `luclin_eyecolor2`<=>0 AND `luclin_beardcolor`<=>0 AND `luclin_beard`<=>255 AND `drakkin_heritage`<=>0 AND `drakkin_tattoo`<=>0 AND `drakkin_details`<=>0 AND `armortint_id`<=>0 AND `armortint_red`<=>0 AND `armortint_green`<=>0 AND `armortint_blue`<=>0 AND `d_melee_texture1`<=>0 AND `d_melee_texture2`<=>0 AND `ammo_idfile`<=>'IT10' AND `prim_melee_type`<=>28 AND `sec_melee_type`<=>28 AND `ranged_type`<=>7 AND `runspeed`<=>1.25 AND `MR`<=>0 AND `CR`<=>0 AND `DR`<=>0 AND `FR`<=>0 AND `PR`<=>0 AND `Corrup`<=>0 AND `PhR`<=>10 AND `see_invis`<=>0 AND `see_invis_undead`<=>0 AND `qglobal`<=>0 AND `AC`<=>208 AND `npc_aggro`<=>0 AND `spawn_limit`<=>0 AND `attack_speed`<=>0 AND `attack_delay`<=>30 AND `findable`<=>0 AND `STR`<=>169 AND `STA`<=>169 AND `DEX`<=>169 AND `AGI`<=>169 AND `_INT`<=>169 AND `WIS`<=>169 AND `CHA`<=>169 AND `see_hide`<=>0 AND `see_improved_hide`<=>0 AND `trackable`<=>1 AND `isbot`<=>0 AND `exclude`<=>0 AND `ATK`<=>0 AND `Accuracy`<=>0 AND `Avoidance`<=>0 AND `slow_mitigation`<=>0 AND `version`<=>0 AND `maxlevel`<=>0 AND `scalerate`<=>100 AND `private_corpse`<=>0 AND `unique_spawn_by_name`<=>0 AND `underwater`<=>0 AND `isquest`<=>1 AND `emoteid`<=>0 AND `spellscale`<=>100 AND `healscale`<=>100 AND `no_target_hotkey`<=>0 AND `raid_target`<=>0 AND `armtexture`<=>0 AND `bracertexture`<=>0 AND `handtexture`<=>0 AND `legtexture`<=>0 AND `feettexture`<=>0 AND `light`<=>0 AND `walkspeed`<=>0 AND `peqid`<=>0 AND `unique_`<=>0 AND `fixed`<=>0 AND `ignore_despawn`<=>0 AND `show_name`<=>1 AND `untargetable`<=>0 AND `charm_ac`<=>0 AND `charm_min_dmg`<=>0 AND `charm_max_dmg`<=>0 AND `charm_attack_delay`<=>0 AND `charm_accuracy_rating`<=>0 AND `charm_avoidance_rating`<=>0 AND `charm_atk`<=>0 AND `skip_global_loot`<=>0 AND `rare_spawn`<=>1 AND `stuck_behavior`<=>0 AND `model`<=>0 AND `flymode`<=>-1 AND `always_aggro`<=>0 AND `exp_mod`<=>100 AND `heroic_strikethrough`<=>0 AND `faction_amount`<=>0 AND `keeps_sold_items`<=>1 AND `is_parcel_merchant`<=>0 AND `multiquest_enabled`<=>0 AND `npc_tint_id`<=>0));
INSERT INTO _mesa_scene_guard SELECT 'npc_spells_397901',NOT EXISTS(SELECT 1 FROM npc_spells WHERE id=397901 AND NOT(`id`<=>397901 AND `parent_list`<=>0 AND `attack_proc`<=>8639 AND `proc_chance`<=>@mesa_thug_proc_chance AND `range_proc`<=>-1 AND `rproc_chance`<=>0 AND `defensive_proc`<=>-1 AND `dproc_chance`<=>0 AND `fail_recast`<=>0 AND `engaged_no_sp_recast_min`<=>0 AND `engaged_no_sp_recast_max`<=>0 AND `engaged_b_self_chance`<=>0 AND `engaged_b_other_chance`<=>0 AND `engaged_d_chance`<=>0 AND `pursue_no_sp_recast_min`<=>0 AND `pursue_no_sp_recast_max`<=>0 AND `pursue_d_chance`<=>0 AND `idle_no_sp_recast_min`<=>0 AND `idle_no_sp_recast_max`<=>0 AND `idle_b_chance`<=>0 AND `name`<=>'May2013 Mesa thug Entrancing Song'));
INSERT INTO _mesa_scene_guard SELECT 'npc_spells_397904',NOT EXISTS(SELECT 1 FROM npc_spells WHERE id=397904 AND NOT(`id`<=>397904 AND `parent_list`<=>0 AND `attack_proc`<=>8712 AND `proc_chance`<=>@mesa_fantoma_proc_chance AND `range_proc`<=>-1 AND `rproc_chance`<=>0 AND `defensive_proc`<=>-1 AND `dproc_chance`<=>0 AND `fail_recast`<=>0 AND `engaged_no_sp_recast_min`<=>0 AND `engaged_no_sp_recast_max`<=>0 AND `engaged_b_self_chance`<=>0 AND `engaged_b_other_chance`<=>0 AND `engaged_d_chance`<=>0 AND `pursue_no_sp_recast_min`<=>0 AND `pursue_no_sp_recast_max`<=>0 AND `pursue_d_chance`<=>0 AND `idle_no_sp_recast_min`<=>0 AND `idle_no_sp_recast_max`<=>0 AND `idle_b_chance`<=>0 AND `name`<=>'May2013 Mesa Fantoma Tendon Rip'));
START TRANSACTION;
INSERT INTO npc_spells(`id`,`parent_list`,`attack_proc`,`proc_chance`,`range_proc`,`rproc_chance`,`defensive_proc`,`dproc_chance`,`fail_recast`,`engaged_no_sp_recast_min`,`engaged_no_sp_recast_max`,`engaged_b_self_chance`,`engaged_b_other_chance`,`engaged_d_chance`,`pursue_no_sp_recast_min`,`pursue_no_sp_recast_max`,`pursue_d_chance`,`idle_no_sp_recast_min`,`idle_no_sp_recast_max`,`idle_b_chance`,`name`) SELECT 397901,0,8639,@mesa_thug_proc_chance,-1,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,'May2013 Mesa thug Entrancing Song' WHERE NOT EXISTS(SELECT 1 FROM npc_spells WHERE id=397901);
INSERT INTO npc_spells(`id`,`parent_list`,`attack_proc`,`proc_chance`,`range_proc`,`rproc_chance`,`defensive_proc`,`dproc_chance`,`fail_recast`,`engaged_no_sp_recast_min`,`engaged_no_sp_recast_max`,`engaged_b_self_chance`,`engaged_b_other_chance`,`engaged_d_chance`,`pursue_no_sp_recast_min`,`pursue_no_sp_recast_max`,`pursue_d_chance`,`idle_no_sp_recast_min`,`idle_no_sp_recast_max`,`idle_b_chance`,`name`) SELECT 397904,0,8712,@mesa_fantoma_proc_chance,-1,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,'May2013 Mesa Fantoma Tendon Rip' WHERE NOT EXISTS(SELECT 1 FROM npc_spells WHERE id=397904);
INSERT INTO npc_types(`id`,`name`,`lastname`,`level`,`race`,`class`,`bodytype`,`hp`,`mana`,`gender`,`texture`,`helmtexture`,`herosforgemodel`,`size`,`hp_regen_rate`,`hp_regen_per_second`,`mana_regen_rate`,`loottable_id`,`merchant_id`,`greed`,`alt_currency_id`,`npc_spells_id`,`npc_spells_effects_id`,`npc_faction_id`,`adventure_template_id`,`trap_template`,`mindmg`,`maxdmg`,`attack_count`,`npcspecialattks`,`special_abilities`,`aggroradius`,`assistradius`,`face`,`luclin_hairstyle`,`luclin_haircolor`,`luclin_eyecolor`,`luclin_eyecolor2`,`luclin_beardcolor`,`luclin_beard`,`drakkin_heritage`,`drakkin_tattoo`,`drakkin_details`,`armortint_id`,`armortint_red`,`armortint_green`,`armortint_blue`,`d_melee_texture1`,`d_melee_texture2`,`ammo_idfile`,`prim_melee_type`,`sec_melee_type`,`ranged_type`,`runspeed`,`MR`,`CR`,`DR`,`FR`,`PR`,`Corrup`,`PhR`,`see_invis`,`see_invis_undead`,`qglobal`,`AC`,`npc_aggro`,`spawn_limit`,`attack_speed`,`attack_delay`,`findable`,`STR`,`STA`,`DEX`,`AGI`,`_INT`,`WIS`,`CHA`,`see_hide`,`see_improved_hide`,`trackable`,`isbot`,`exclude`,`ATK`,`Accuracy`,`Avoidance`,`slow_mitigation`,`version`,`maxlevel`,`scalerate`,`private_corpse`,`unique_spawn_by_name`,`underwater`,`isquest`,`emoteid`,`spellscale`,`healscale`,`no_target_hotkey`,`raid_target`,`armtexture`,`bracertexture`,`handtexture`,`legtexture`,`feettexture`,`light`,`walkspeed`,`peqid`,`unique_`,`fixed`,`ignore_despawn`,`show_name`,`untargetable`,`charm_ac`,`charm_min_dmg`,`charm_max_dmg`,`charm_attack_delay`,`charm_accuracy_rating`,`charm_avoidance_rating`,`charm_atk`,`skip_global_loot`,`rare_spawn`,`stuck_behavior`,`model`,`flymode`,`always_aggro`,`exp_mod`,`heroic_strikethrough`,`faction_amount`,`keeps_sold_items`,`is_parcel_merchant`,`multiquest_enabled`,`npc_tint_id`) SELECT 397901,'a_Tuffein_thug','',45,529,1,1,@mesa_thug_hp,0,2,1,1,0,6,0,0,0,0,0,0,0,397901,0,0,0,0,@mesa_thug_min_hit,@mesa_thug_max_hit,-1,'','',0,0,0,0,0,0,0,0,255,0,0,0,0,0,0,0,10872,10985,'IT10',28,28,7,1.25,0,0,0,0,0,0,10,0,0,0,229,0,0,0,30,0,185,185,185,185,185,185,185,0,0,1,0,0,0,0,0,0,0,0,100,0,0,0,1,0,100,100,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,100,0,0,1,0,0,0 WHERE NOT EXISTS(SELECT 1 FROM npc_types WHERE id=397901);
INSERT INTO npc_types(`id`,`name`,`lastname`,`level`,`race`,`class`,`bodytype`,`hp`,`mana`,`gender`,`texture`,`helmtexture`,`herosforgemodel`,`size`,`hp_regen_rate`,`hp_regen_per_second`,`mana_regen_rate`,`loottable_id`,`merchant_id`,`greed`,`alt_currency_id`,`npc_spells_id`,`npc_spells_effects_id`,`npc_faction_id`,`adventure_template_id`,`trap_template`,`mindmg`,`maxdmg`,`attack_count`,`npcspecialattks`,`special_abilities`,`aggroradius`,`assistradius`,`face`,`luclin_hairstyle`,`luclin_haircolor`,`luclin_eyecolor`,`luclin_eyecolor2`,`luclin_beardcolor`,`luclin_beard`,`drakkin_heritage`,`drakkin_tattoo`,`drakkin_details`,`armortint_id`,`armortint_red`,`armortint_green`,`armortint_blue`,`d_melee_texture1`,`d_melee_texture2`,`ammo_idfile`,`prim_melee_type`,`sec_melee_type`,`ranged_type`,`runspeed`,`MR`,`CR`,`DR`,`FR`,`PR`,`Corrup`,`PhR`,`see_invis`,`see_invis_undead`,`qglobal`,`AC`,`npc_aggro`,`spawn_limit`,`attack_speed`,`attack_delay`,`findable`,`STR`,`STA`,`DEX`,`AGI`,`_INT`,`WIS`,`CHA`,`see_hide`,`see_improved_hide`,`trackable`,`isbot`,`exclude`,`ATK`,`Accuracy`,`Avoidance`,`slow_mitigation`,`version`,`maxlevel`,`scalerate`,`private_corpse`,`unique_spawn_by_name`,`underwater`,`isquest`,`emoteid`,`spellscale`,`healscale`,`no_target_hotkey`,`raid_target`,`armtexture`,`bracertexture`,`handtexture`,`legtexture`,`feettexture`,`light`,`walkspeed`,`peqid`,`unique_`,`fixed`,`ignore_despawn`,`show_name`,`untargetable`,`charm_ac`,`charm_min_dmg`,`charm_max_dmg`,`charm_attack_delay`,`charm_accuracy_rating`,`charm_avoidance_rating`,`charm_atk`,`skip_global_loot`,`rare_spawn`,`stuck_behavior`,`model`,`flymode`,`always_aggro`,`exp_mod`,`heroic_strikethrough`,`faction_amount`,`keeps_sold_items`,`is_parcel_merchant`,`multiquest_enabled`,`npc_tint_id`) SELECT 397902,'a_Tuffein_grabber','',40,529,6,1,@mesa_grabber_hp,0,2,1,1,0,6,0,0,0,0,0,0,0,0,0,0,0,0,@mesa_grabber_min_hit,@mesa_grabber_max_hit,-1,'','',0,0,0,0,0,0,0,0,255,0,0,0,0,0,0,0,0,0,'IT10',28,28,7,1.25,0,0,0,0,0,0,10,0,0,0,200,0,0,0,30,0,163,163,163,163,163,163,163,0,0,1,0,0,0,0,0,0,0,0,100,0,0,0,1,0,100,100,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,100,0,0,1,0,0,0 WHERE NOT EXISTS(SELECT 1 FROM npc_types WHERE id=397902);
INSERT INTO npc_types(`id`,`name`,`lastname`,`level`,`race`,`class`,`bodytype`,`hp`,`mana`,`gender`,`texture`,`helmtexture`,`herosforgemodel`,`size`,`hp_regen_rate`,`hp_regen_per_second`,`mana_regen_rate`,`loottable_id`,`merchant_id`,`greed`,`alt_currency_id`,`npc_spells_id`,`npc_spells_effects_id`,`npc_faction_id`,`adventure_template_id`,`trap_template`,`mindmg`,`maxdmg`,`attack_count`,`npcspecialattks`,`special_abilities`,`aggroradius`,`assistradius`,`face`,`luclin_hairstyle`,`luclin_haircolor`,`luclin_eyecolor`,`luclin_eyecolor2`,`luclin_beardcolor`,`luclin_beard`,`drakkin_heritage`,`drakkin_tattoo`,`drakkin_details`,`armortint_id`,`armortint_red`,`armortint_green`,`armortint_blue`,`d_melee_texture1`,`d_melee_texture2`,`ammo_idfile`,`prim_melee_type`,`sec_melee_type`,`ranged_type`,`runspeed`,`MR`,`CR`,`DR`,`FR`,`PR`,`Corrup`,`PhR`,`see_invis`,`see_invis_undead`,`qglobal`,`AC`,`npc_aggro`,`spawn_limit`,`attack_speed`,`attack_delay`,`findable`,`STR`,`STA`,`DEX`,`AGI`,`_INT`,`WIS`,`CHA`,`see_hide`,`see_improved_hide`,`trackable`,`isbot`,`exclude`,`ATK`,`Accuracy`,`Avoidance`,`slow_mitigation`,`version`,`maxlevel`,`scalerate`,`private_corpse`,`unique_spawn_by_name`,`underwater`,`isquest`,`emoteid`,`spellscale`,`healscale`,`no_target_hotkey`,`raid_target`,`armtexture`,`bracertexture`,`handtexture`,`legtexture`,`feettexture`,`light`,`walkspeed`,`peqid`,`unique_`,`fixed`,`ignore_despawn`,`show_name`,`untargetable`,`charm_ac`,`charm_min_dmg`,`charm_max_dmg`,`charm_attack_delay`,`charm_accuracy_rating`,`charm_avoidance_rating`,`charm_atk`,`skip_global_loot`,`rare_spawn`,`stuck_behavior`,`model`,`flymode`,`always_aggro`,`exp_mod`,`heroic_strikethrough`,`faction_amount`,`keeps_sold_items`,`is_parcel_merchant`,`multiquest_enabled`,`npc_tint_id`) SELECT 397903,'a_Tuffein_raider','',45,529,1,1,@mesa_raider_hp,0,2,1,1,0,6,0,0,0,0,0,0,0,0,0,0,0,0,@mesa_raider_min_hit,@mesa_raider_max_hit,-1,'','',0,0,0,0,0,0,0,0,255,0,0,0,0,0,0,0,10872,10985,'IT10',28,28,7,1.25,0,0,0,0,0,0,10,0,0,0,229,0,0,0,30,0,185,185,185,185,185,185,185,0,0,1,0,0,0,0,0,0,0,0,100,0,0,0,1,0,100,100,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,100,0,0,1,0,0,0 WHERE NOT EXISTS(SELECT 1 FROM npc_types WHERE id=397903);
INSERT INTO npc_types(`id`,`name`,`lastname`,`level`,`race`,`class`,`bodytype`,`hp`,`mana`,`gender`,`texture`,`helmtexture`,`herosforgemodel`,`size`,`hp_regen_rate`,`hp_regen_per_second`,`mana_regen_rate`,`loottable_id`,`merchant_id`,`greed`,`alt_currency_id`,`npc_spells_id`,`npc_spells_effects_id`,`npc_faction_id`,`adventure_template_id`,`trap_template`,`mindmg`,`maxdmg`,`attack_count`,`npcspecialattks`,`special_abilities`,`aggroradius`,`assistradius`,`face`,`luclin_hairstyle`,`luclin_haircolor`,`luclin_eyecolor`,`luclin_eyecolor2`,`luclin_beardcolor`,`luclin_beard`,`drakkin_heritage`,`drakkin_tattoo`,`drakkin_details`,`armortint_id`,`armortint_red`,`armortint_green`,`armortint_blue`,`d_melee_texture1`,`d_melee_texture2`,`ammo_idfile`,`prim_melee_type`,`sec_melee_type`,`ranged_type`,`runspeed`,`MR`,`CR`,`DR`,`FR`,`PR`,`Corrup`,`PhR`,`see_invis`,`see_invis_undead`,`qglobal`,`AC`,`npc_aggro`,`spawn_limit`,`attack_speed`,`attack_delay`,`findable`,`STR`,`STA`,`DEX`,`AGI`,`_INT`,`WIS`,`CHA`,`see_hide`,`see_improved_hide`,`trackable`,`isbot`,`exclude`,`ATK`,`Accuracy`,`Avoidance`,`slow_mitigation`,`version`,`maxlevel`,`scalerate`,`private_corpse`,`unique_spawn_by_name`,`underwater`,`isquest`,`emoteid`,`spellscale`,`healscale`,`no_target_hotkey`,`raid_target`,`armtexture`,`bracertexture`,`handtexture`,`legtexture`,`feettexture`,`light`,`walkspeed`,`peqid`,`unique_`,`fixed`,`ignore_despawn`,`show_name`,`untargetable`,`charm_ac`,`charm_min_dmg`,`charm_max_dmg`,`charm_attack_delay`,`charm_accuracy_rating`,`charm_avoidance_rating`,`charm_atk`,`skip_global_loot`,`rare_spawn`,`stuck_behavior`,`model`,`flymode`,`always_aggro`,`exp_mod`,`heroic_strikethrough`,`faction_amount`,`keeps_sold_items`,`is_parcel_merchant`,`multiquest_enabled`,`npc_tint_id`) SELECT 397904,'Fantoma','',45,42,1,21,@mesa_fantoma_hp,0,2,0,0,0,4,0,0,0,397904,0,0,0,397904,0,0,0,0,@mesa_fantoma_min_hit,@mesa_fantoma_max_hit,-1,'','',0,0,0,0,0,0,0,0,255,0,0,0,0,0,0,0,0,0,'IT10',28,28,7,1.25,0,0,0,0,0,0,10,0,0,0,208,0,0,0,30,0,169,169,169,169,169,169,169,0,0,1,0,0,0,0,0,0,0,0,100,0,0,0,1,0,100,100,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,1,0,0,-1,0,100,0,0,1,0,0,0 WHERE NOT EXISTS(SELECT 1 FROM npc_types WHERE id=397904);
COMMIT;

-- ---- mesa-remaining/sql/020-fantoma-acquisition.sql ----
-- Fantoma acquisition with explicitly reconstructed probabilities. User-approved configurable emulator defaults.
-- Original rare/loot percentages not recovered. No quest-accept guaranteed spawn.
-- Preserves all21 existing wolf spawn2 coordinates, grids, timers and expansion filters.
SET SESSION check_constraint_checks=1;
DROP TEMPORARY TABLE IF EXISTS _mesa_fantoma_guard;
CREATE TEMPORARY TABLE _mesa_fantoma_guard(label VARCHAR(100)PRIMARY KEY,ok TINYINT NOT NULL,CHECK(ok=1))ENGINE=InnoDB;
-- NMS adaptation (normalize-before-guards, 11-01 pattern): our stock spawn rows
-- for the 21 original Fantoma wolf pools carry chance=50; the reconstruction
-- preimage expects chance=100. Normalize before the guards, after which the
-- Fantoma percentage rows are inserted with the labelled 2% default.
UPDATE spawnentry SET chance=100 WHERE ((spawngroupID=73475 AND npcID=397001) OR (spawngroupID=73476 AND npcID=397002) OR (spawngroupID=73478 AND npcID=397004) OR (spawngroupID=73484 AND npcID=397001) OR (spawngroupID=73485 AND npcID=397004) OR (spawngroupID=73493 AND npcID=397001) OR (spawngroupID=73494 AND npcID=397001) OR (spawngroupID=73502 AND npcID=397002) OR (spawngroupID=73507 AND npcID=397002) OR (spawngroupID=73531 AND npcID=397002) OR (spawngroupID=73544 AND npcID=397035) OR (spawngroupID=73546 AND npcID=397001) OR (spawngroupID=73561 AND npcID=397004) OR (spawngroupID=73576 AND npcID=397002) OR (spawngroupID=73583 AND npcID=397004) OR (spawngroupID=73595 AND npcID=397004) OR (spawngroupID=73626 AND npcID=397004) OR (spawngroupID=73641 AND npcID=397001) OR (spawngroupID=73657 AND npcID=397001) OR (spawngroupID=73679 AND npcID=397004) OR (spawngroupID=73694 AND npcID=397002)) AND chance=50 AND condition_value_filter=1 AND min_time=0 AND max_time=0 AND min_expansion=-1 AND max_expansion=-1 AND content_flags IS NULL AND content_flags_disabled IS NULL;
INSERT INTO _mesa_fantoma_guard VALUES('review',COALESCE(@mesa_fantoma_acquisition_reviewed,0)=1);
SET @mesa_fantoma_spawn_percent=COALESCE(@mesa_fantoma_spawn_percent,2);
INSERT INTO _mesa_fantoma_guard VALUES('setting_spawn_percent',@mesa_fantoma_spawn_percent BETWEEN 1 AND 50 AND @mesa_fantoma_spawn_percent=FLOOR(@mesa_fantoma_spawn_percent));
SET @mesa_fantoma_pelt_percent=COALESCE(@mesa_fantoma_pelt_percent,100);
INSERT INTO _mesa_fantoma_guard VALUES('setting_pelt_percent',@mesa_fantoma_pelt_percent BETWEEN 1 AND 100 AND @mesa_fantoma_pelt_percent=FLOOR(@mesa_fantoma_pelt_percent));
SET @mesa_fantoma_boots_weight=COALESCE(@mesa_fantoma_boots_weight,50);
INSERT INTO _mesa_fantoma_guard VALUES('setting_boots_weight',@mesa_fantoma_boots_weight BETWEEN 0 AND 100 AND @mesa_fantoma_boots_weight=FLOOR(@mesa_fantoma_boots_weight));
SET @mesa_fantoma_club_weight=COALESCE(@mesa_fantoma_club_weight,50);
INSERT INTO _mesa_fantoma_guard VALUES('setting_club_weight',@mesa_fantoma_club_weight BETWEEN 0 AND 100 AND @mesa_fantoma_club_weight=FLOOR(@mesa_fantoma_club_weight));
INSERT INTO _mesa_fantoma_guard VALUES('gear_weights',@mesa_fantoma_boots_weight+@mesa_fantoma_club_weight=100);
INSERT INTO _mesa_fantoma_guard VALUES('npc_identity',((SELECT COUNT(*)FROM npc_types WHERE id=397904 AND name='Fantoma' AND level=45 AND race=42 AND loottable_id=397904)=1));
INSERT INTO _mesa_fantoma_guard VALUES('item_46332',((SELECT COUNT(*)FROM items WHERE id=46332 AND Name='Stained Snakeskin Boots')=1));
INSERT INTO _mesa_fantoma_guard VALUES('item_46338',((SELECT COUNT(*)FROM items WHERE id=46338 AND Name='Dromrek Billy Club')=1));
INSERT INTO _mesa_fantoma_guard VALUES('item_88127',((SELECT COUNT(*)FROM items WHERE id=88127 AND Name='Fantoma''s Pelt')=1));
INSERT INTO _mesa_fantoma_guard VALUES('loottable_ownership',(NOT EXISTS(SELECT 1 FROM loottable WHERE id=397904 AND NOT((`id`<=>397904 AND `name`<=>'May2013 Mesa Fantoma reconstructed loot' AND `mincash`<=>0 AND `maxcash`<=>0 AND `avgcoin`<=>0 AND `done`<=>0 AND `min_expansion`<=>-1 AND `max_expansion`<=>-1 AND `content_flags`<=>NULL AND `content_flags_disabled`<=>NULL)))));
INSERT INTO _mesa_fantoma_guard VALUES('loottable_unique_0',((SELECT COUNT(*)FROM loottable WHERE `id`<=>397904)<=1));
INSERT INTO _mesa_fantoma_guard VALUES('lootdrop_ownership',(NOT EXISTS(SELECT 1 FROM lootdrop WHERE id IN(397904,397905) AND NOT((`id`<=>397904 AND `name`<=>'May2013 Mesa Fantoma quest pelt' AND `min_expansion`<=>-1 AND `max_expansion`<=>-1 AND `content_flags`<=>NULL AND `content_flags_disabled`<=>NULL) OR (`id`<=>397905 AND `name`<=>'May2013 Mesa Fantoma reconstructed gear weights' AND `min_expansion`<=>-1 AND `max_expansion`<=>-1 AND `content_flags`<=>NULL AND `content_flags_disabled`<=>NULL)))));
INSERT INTO _mesa_fantoma_guard VALUES('lootdrop_unique_0',((SELECT COUNT(*)FROM lootdrop WHERE `id`<=>397904)<=1));
INSERT INTO _mesa_fantoma_guard VALUES('lootdrop_unique_1',((SELECT COUNT(*)FROM lootdrop WHERE `id`<=>397905)<=1));
INSERT INTO _mesa_fantoma_guard VALUES('loottable_entries_ownership',(NOT EXISTS(SELECT 1 FROM loottable_entries WHERE loottable_id=397904 AND NOT((`loottable_id`<=>397904 AND `lootdrop_id`<=>397904 AND `multiplier`<=>1 AND `droplimit`<=>0 AND `mindrop`<=>0 AND `probability`<=>100) OR (`loottable_id`<=>397904 AND `lootdrop_id`<=>397905 AND `multiplier`<=>1 AND `droplimit`<=>1 AND `mindrop`<=>1 AND `probability`<=>100)))));
INSERT INTO _mesa_fantoma_guard VALUES('loottable_entries_unique_0',((SELECT COUNT(*)FROM loottable_entries WHERE `loottable_id`<=>397904 AND `lootdrop_id`<=>397904)<=1));
INSERT INTO _mesa_fantoma_guard VALUES('loottable_entries_unique_1',((SELECT COUNT(*)FROM loottable_entries WHERE `loottable_id`<=>397904 AND `lootdrop_id`<=>397905)<=1));
INSERT INTO _mesa_fantoma_guard VALUES('lootdrop_entries_ownership',(NOT EXISTS(SELECT 1 FROM lootdrop_entries WHERE lootdrop_id IN(397904,397905) AND NOT((`lootdrop_id`<=>397904 AND `item_id`<=>88127 AND `item_charges`<=>1 AND `equip_item`<=>0 AND `chance`<=>@mesa_fantoma_pelt_percent AND `disabled_chance`<=>0 AND `trivial_min_level`<=>0 AND `trivial_max_level`<=>0 AND `multiplier`<=>1 AND `npc_min_level`<=>0 AND `npc_max_level`<=>0 AND `min_expansion`<=>-1 AND `max_expansion`<=>-1 AND `content_flags`<=>NULL AND `content_flags_disabled`<=>NULL) OR (`lootdrop_id`<=>397905 AND `item_id`<=>46332 AND `item_charges`<=>1 AND `equip_item`<=>0 AND `chance`<=>@mesa_fantoma_boots_weight AND `disabled_chance`<=>0 AND `trivial_min_level`<=>0 AND `trivial_max_level`<=>0 AND `multiplier`<=>1 AND `npc_min_level`<=>0 AND `npc_max_level`<=>0 AND `min_expansion`<=>-1 AND `max_expansion`<=>-1 AND `content_flags`<=>NULL AND `content_flags_disabled`<=>NULL) OR (`lootdrop_id`<=>397905 AND `item_id`<=>46338 AND `item_charges`<=>1 AND `equip_item`<=>0 AND `chance`<=>@mesa_fantoma_club_weight AND `disabled_chance`<=>0 AND `trivial_min_level`<=>0 AND `trivial_max_level`<=>0 AND `multiplier`<=>1 AND `npc_min_level`<=>0 AND `npc_max_level`<=>0 AND `min_expansion`<=>-1 AND `max_expansion`<=>-1 AND `content_flags`<=>NULL AND `content_flags_disabled`<=>NULL)))));
INSERT INTO _mesa_fantoma_guard VALUES('lootdrop_entries_unique_0',((SELECT COUNT(*)FROM lootdrop_entries WHERE `lootdrop_id`<=>397904 AND `item_id`<=>88127)<=1));
INSERT INTO _mesa_fantoma_guard VALUES('lootdrop_entries_unique_1',((SELECT COUNT(*)FROM lootdrop_entries WHERE `lootdrop_id`<=>397905 AND `item_id`<=>46332)<=1));
INSERT INTO _mesa_fantoma_guard VALUES('lootdrop_entries_unique_2',((SELECT COUNT(*)FROM lootdrop_entries WHERE `lootdrop_id`<=>397905 AND `item_id`<=>46338)<=1));
INSERT INTO _mesa_fantoma_guard VALUES('original_73475',((SELECT COUNT(*)FROM spawnentry WHERE `spawngroupID`<=>73475 AND `npcID`<=>397001 AND `condition_value_filter`<=>1 AND `min_time`<=>0 AND `max_time`<=>0 AND `min_expansion`<=>-1 AND `max_expansion`<=>-1 AND `content_flags`<=>NULL AND `content_flags_disabled`<=>NULL AND (chance=100 OR chance=100-@mesa_fantoma_spawn_percent))=1));
INSERT INTO _mesa_fantoma_guard VALUES('pool_73475',(NOT EXISTS(SELECT 1 FROM spawnentry WHERE spawngroupID=73475 AND NOT((npcID=397001) OR (`spawngroupID`<=>73475 AND `npcID`<=>397904 AND `chance`<=>@mesa_fantoma_spawn_percent AND `condition_value_filter`<=>1 AND `min_time`<=>0 AND `max_time`<=>0 AND `min_expansion`<=>-1 AND `max_expansion`<=>-1 AND `content_flags`<=>NULL AND `content_flags_disabled`<=>NULL)))));
INSERT INTO _mesa_fantoma_guard VALUES('rare_unique_73475',((SELECT COUNT(*)FROM spawnentry WHERE spawngroupID=73475 AND npcID=397904)<=1));
INSERT INTO _mesa_fantoma_guard VALUES('original_73476',((SELECT COUNT(*)FROM spawnentry WHERE `spawngroupID`<=>73476 AND `npcID`<=>397002 AND `condition_value_filter`<=>1 AND `min_time`<=>0 AND `max_time`<=>0 AND `min_expansion`<=>-1 AND `max_expansion`<=>-1 AND `content_flags`<=>NULL AND `content_flags_disabled`<=>NULL AND (chance=100 OR chance=100-@mesa_fantoma_spawn_percent))=1));
INSERT INTO _mesa_fantoma_guard VALUES('pool_73476',(NOT EXISTS(SELECT 1 FROM spawnentry WHERE spawngroupID=73476 AND NOT((npcID=397002) OR (`spawngroupID`<=>73476 AND `npcID`<=>397904 AND `chance`<=>@mesa_fantoma_spawn_percent AND `condition_value_filter`<=>1 AND `min_time`<=>0 AND `max_time`<=>0 AND `min_expansion`<=>-1 AND `max_expansion`<=>-1 AND `content_flags`<=>NULL AND `content_flags_disabled`<=>NULL)))));
INSERT INTO _mesa_fantoma_guard VALUES('rare_unique_73476',((SELECT COUNT(*)FROM spawnentry WHERE spawngroupID=73476 AND npcID=397904)<=1));
INSERT INTO _mesa_fantoma_guard VALUES('original_73478',((SELECT COUNT(*)FROM spawnentry WHERE `spawngroupID`<=>73478 AND `npcID`<=>397004 AND `condition_value_filter`<=>1 AND `min_time`<=>0 AND `max_time`<=>0 AND `min_expansion`<=>-1 AND `max_expansion`<=>-1 AND `content_flags`<=>NULL AND `content_flags_disabled`<=>NULL AND (chance=100 OR chance=100-@mesa_fantoma_spawn_percent))=1));
INSERT INTO _mesa_fantoma_guard VALUES('pool_73478',(NOT EXISTS(SELECT 1 FROM spawnentry WHERE spawngroupID=73478 AND NOT((npcID=397004) OR (`spawngroupID`<=>73478 AND `npcID`<=>397904 AND `chance`<=>@mesa_fantoma_spawn_percent AND `condition_value_filter`<=>1 AND `min_time`<=>0 AND `max_time`<=>0 AND `min_expansion`<=>-1 AND `max_expansion`<=>-1 AND `content_flags`<=>NULL AND `content_flags_disabled`<=>NULL)))));
INSERT INTO _mesa_fantoma_guard VALUES('rare_unique_73478',((SELECT COUNT(*)FROM spawnentry WHERE spawngroupID=73478 AND npcID=397904)<=1));
INSERT INTO _mesa_fantoma_guard VALUES('original_73484',((SELECT COUNT(*)FROM spawnentry WHERE `spawngroupID`<=>73484 AND `npcID`<=>397001 AND `condition_value_filter`<=>1 AND `min_time`<=>0 AND `max_time`<=>0 AND `min_expansion`<=>-1 AND `max_expansion`<=>-1 AND `content_flags`<=>NULL AND `content_flags_disabled`<=>NULL AND (chance=100 OR chance=100-@mesa_fantoma_spawn_percent))=1));
INSERT INTO _mesa_fantoma_guard VALUES('pool_73484',(NOT EXISTS(SELECT 1 FROM spawnentry WHERE spawngroupID=73484 AND NOT((npcID=397001) OR (`spawngroupID`<=>73484 AND `npcID`<=>397904 AND `chance`<=>@mesa_fantoma_spawn_percent AND `condition_value_filter`<=>1 AND `min_time`<=>0 AND `max_time`<=>0 AND `min_expansion`<=>-1 AND `max_expansion`<=>-1 AND `content_flags`<=>NULL AND `content_flags_disabled`<=>NULL)))));
INSERT INTO _mesa_fantoma_guard VALUES('rare_unique_73484',((SELECT COUNT(*)FROM spawnentry WHERE spawngroupID=73484 AND npcID=397904)<=1));
INSERT INTO _mesa_fantoma_guard VALUES('original_73485',((SELECT COUNT(*)FROM spawnentry WHERE `spawngroupID`<=>73485 AND `npcID`<=>397004 AND `condition_value_filter`<=>1 AND `min_time`<=>0 AND `max_time`<=>0 AND `min_expansion`<=>-1 AND `max_expansion`<=>-1 AND `content_flags`<=>NULL AND `content_flags_disabled`<=>NULL AND (chance=100 OR chance=100-@mesa_fantoma_spawn_percent))=1));
INSERT INTO _mesa_fantoma_guard VALUES('pool_73485',(NOT EXISTS(SELECT 1 FROM spawnentry WHERE spawngroupID=73485 AND NOT((npcID=397004) OR (`spawngroupID`<=>73485 AND `npcID`<=>397904 AND `chance`<=>@mesa_fantoma_spawn_percent AND `condition_value_filter`<=>1 AND `min_time`<=>0 AND `max_time`<=>0 AND `min_expansion`<=>-1 AND `max_expansion`<=>-1 AND `content_flags`<=>NULL AND `content_flags_disabled`<=>NULL)))));
INSERT INTO _mesa_fantoma_guard VALUES('rare_unique_73485',((SELECT COUNT(*)FROM spawnentry WHERE spawngroupID=73485 AND npcID=397904)<=1));
INSERT INTO _mesa_fantoma_guard VALUES('original_73493',((SELECT COUNT(*)FROM spawnentry WHERE `spawngroupID`<=>73493 AND `npcID`<=>397001 AND `condition_value_filter`<=>1 AND `min_time`<=>0 AND `max_time`<=>0 AND `min_expansion`<=>-1 AND `max_expansion`<=>-1 AND `content_flags`<=>NULL AND `content_flags_disabled`<=>NULL AND (chance=100 OR chance=100-@mesa_fantoma_spawn_percent))=1));
INSERT INTO _mesa_fantoma_guard VALUES('pool_73493',(NOT EXISTS(SELECT 1 FROM spawnentry WHERE spawngroupID=73493 AND NOT((npcID=397001) OR (`spawngroupID`<=>73493 AND `npcID`<=>397904 AND `chance`<=>@mesa_fantoma_spawn_percent AND `condition_value_filter`<=>1 AND `min_time`<=>0 AND `max_time`<=>0 AND `min_expansion`<=>-1 AND `max_expansion`<=>-1 AND `content_flags`<=>NULL AND `content_flags_disabled`<=>NULL)))));
INSERT INTO _mesa_fantoma_guard VALUES('rare_unique_73493',((SELECT COUNT(*)FROM spawnentry WHERE spawngroupID=73493 AND npcID=397904)<=1));
INSERT INTO _mesa_fantoma_guard VALUES('original_73494',((SELECT COUNT(*)FROM spawnentry WHERE `spawngroupID`<=>73494 AND `npcID`<=>397001 AND `condition_value_filter`<=>1 AND `min_time`<=>0 AND `max_time`<=>0 AND `min_expansion`<=>-1 AND `max_expansion`<=>-1 AND `content_flags`<=>NULL AND `content_flags_disabled`<=>NULL AND (chance=100 OR chance=100-@mesa_fantoma_spawn_percent))=1));
INSERT INTO _mesa_fantoma_guard VALUES('pool_73494',(NOT EXISTS(SELECT 1 FROM spawnentry WHERE spawngroupID=73494 AND NOT((npcID=397001) OR (`spawngroupID`<=>73494 AND `npcID`<=>397904 AND `chance`<=>@mesa_fantoma_spawn_percent AND `condition_value_filter`<=>1 AND `min_time`<=>0 AND `max_time`<=>0 AND `min_expansion`<=>-1 AND `max_expansion`<=>-1 AND `content_flags`<=>NULL AND `content_flags_disabled`<=>NULL)))));
INSERT INTO _mesa_fantoma_guard VALUES('rare_unique_73494',((SELECT COUNT(*)FROM spawnentry WHERE spawngroupID=73494 AND npcID=397904)<=1));
INSERT INTO _mesa_fantoma_guard VALUES('original_73502',((SELECT COUNT(*)FROM spawnentry WHERE `spawngroupID`<=>73502 AND `npcID`<=>397002 AND `condition_value_filter`<=>1 AND `min_time`<=>0 AND `max_time`<=>0 AND `min_expansion`<=>-1 AND `max_expansion`<=>-1 AND `content_flags`<=>NULL AND `content_flags_disabled`<=>NULL AND (chance=100 OR chance=100-@mesa_fantoma_spawn_percent))=1));
INSERT INTO _mesa_fantoma_guard VALUES('pool_73502',(NOT EXISTS(SELECT 1 FROM spawnentry WHERE spawngroupID=73502 AND NOT((npcID=397002) OR (`spawngroupID`<=>73502 AND `npcID`<=>397904 AND `chance`<=>@mesa_fantoma_spawn_percent AND `condition_value_filter`<=>1 AND `min_time`<=>0 AND `max_time`<=>0 AND `min_expansion`<=>-1 AND `max_expansion`<=>-1 AND `content_flags`<=>NULL AND `content_flags_disabled`<=>NULL)))));
INSERT INTO _mesa_fantoma_guard VALUES('rare_unique_73502',((SELECT COUNT(*)FROM spawnentry WHERE spawngroupID=73502 AND npcID=397904)<=1));
INSERT INTO _mesa_fantoma_guard VALUES('original_73507',((SELECT COUNT(*)FROM spawnentry WHERE `spawngroupID`<=>73507 AND `npcID`<=>397002 AND `condition_value_filter`<=>1 AND `min_time`<=>0 AND `max_time`<=>0 AND `min_expansion`<=>-1 AND `max_expansion`<=>-1 AND `content_flags`<=>NULL AND `content_flags_disabled`<=>NULL AND (chance=100 OR chance=100-@mesa_fantoma_spawn_percent))=1));
INSERT INTO _mesa_fantoma_guard VALUES('pool_73507',(NOT EXISTS(SELECT 1 FROM spawnentry WHERE spawngroupID=73507 AND NOT((npcID=397002) OR (`spawngroupID`<=>73507 AND `npcID`<=>397904 AND `chance`<=>@mesa_fantoma_spawn_percent AND `condition_value_filter`<=>1 AND `min_time`<=>0 AND `max_time`<=>0 AND `min_expansion`<=>-1 AND `max_expansion`<=>-1 AND `content_flags`<=>NULL AND `content_flags_disabled`<=>NULL)))));
INSERT INTO _mesa_fantoma_guard VALUES('rare_unique_73507',((SELECT COUNT(*)FROM spawnentry WHERE spawngroupID=73507 AND npcID=397904)<=1));
INSERT INTO _mesa_fantoma_guard VALUES('original_73531',((SELECT COUNT(*)FROM spawnentry WHERE `spawngroupID`<=>73531 AND `npcID`<=>397002 AND `condition_value_filter`<=>1 AND `min_time`<=>0 AND `max_time`<=>0 AND `min_expansion`<=>-1 AND `max_expansion`<=>-1 AND `content_flags`<=>NULL AND `content_flags_disabled`<=>NULL AND (chance=100 OR chance=100-@mesa_fantoma_spawn_percent))=1));
INSERT INTO _mesa_fantoma_guard VALUES('pool_73531',(NOT EXISTS(SELECT 1 FROM spawnentry WHERE spawngroupID=73531 AND NOT((npcID=397002) OR (`spawngroupID`<=>73531 AND `npcID`<=>397904 AND `chance`<=>@mesa_fantoma_spawn_percent AND `condition_value_filter`<=>1 AND `min_time`<=>0 AND `max_time`<=>0 AND `min_expansion`<=>-1 AND `max_expansion`<=>-1 AND `content_flags`<=>NULL AND `content_flags_disabled`<=>NULL)))));
INSERT INTO _mesa_fantoma_guard VALUES('rare_unique_73531',((SELECT COUNT(*)FROM spawnentry WHERE spawngroupID=73531 AND npcID=397904)<=1));
INSERT INTO _mesa_fantoma_guard VALUES('original_73544',((SELECT COUNT(*)FROM spawnentry WHERE `spawngroupID`<=>73544 AND `npcID`<=>397035 AND `condition_value_filter`<=>1 AND `min_time`<=>0 AND `max_time`<=>0 AND `min_expansion`<=>-1 AND `max_expansion`<=>-1 AND `content_flags`<=>NULL AND `content_flags_disabled`<=>NULL AND (chance=100 OR chance=100-@mesa_fantoma_spawn_percent))=1));
INSERT INTO _mesa_fantoma_guard VALUES('pool_73544',(NOT EXISTS(SELECT 1 FROM spawnentry WHERE spawngroupID=73544 AND NOT((npcID=397035) OR (`spawngroupID`<=>73544 AND `npcID`<=>397904 AND `chance`<=>@mesa_fantoma_spawn_percent AND `condition_value_filter`<=>1 AND `min_time`<=>0 AND `max_time`<=>0 AND `min_expansion`<=>-1 AND `max_expansion`<=>-1 AND `content_flags`<=>NULL AND `content_flags_disabled`<=>NULL)))));
INSERT INTO _mesa_fantoma_guard VALUES('rare_unique_73544',((SELECT COUNT(*)FROM spawnentry WHERE spawngroupID=73544 AND npcID=397904)<=1));
INSERT INTO _mesa_fantoma_guard VALUES('original_73546',((SELECT COUNT(*)FROM spawnentry WHERE `spawngroupID`<=>73546 AND `npcID`<=>397001 AND `condition_value_filter`<=>1 AND `min_time`<=>0 AND `max_time`<=>0 AND `min_expansion`<=>-1 AND `max_expansion`<=>-1 AND `content_flags`<=>NULL AND `content_flags_disabled`<=>NULL AND (chance=100 OR chance=100-@mesa_fantoma_spawn_percent))=1));
INSERT INTO _mesa_fantoma_guard VALUES('pool_73546',(NOT EXISTS(SELECT 1 FROM spawnentry WHERE spawngroupID=73546 AND NOT((npcID=397001) OR (`spawngroupID`<=>73546 AND `npcID`<=>397904 AND `chance`<=>@mesa_fantoma_spawn_percent AND `condition_value_filter`<=>1 AND `min_time`<=>0 AND `max_time`<=>0 AND `min_expansion`<=>-1 AND `max_expansion`<=>-1 AND `content_flags`<=>NULL AND `content_flags_disabled`<=>NULL)))));
INSERT INTO _mesa_fantoma_guard VALUES('rare_unique_73546',((SELECT COUNT(*)FROM spawnentry WHERE spawngroupID=73546 AND npcID=397904)<=1));
INSERT INTO _mesa_fantoma_guard VALUES('original_73561',((SELECT COUNT(*)FROM spawnentry WHERE `spawngroupID`<=>73561 AND `npcID`<=>397004 AND `condition_value_filter`<=>1 AND `min_time`<=>0 AND `max_time`<=>0 AND `min_expansion`<=>-1 AND `max_expansion`<=>-1 AND `content_flags`<=>NULL AND `content_flags_disabled`<=>NULL AND (chance=100 OR chance=100-@mesa_fantoma_spawn_percent))=1));
INSERT INTO _mesa_fantoma_guard VALUES('pool_73561',(NOT EXISTS(SELECT 1 FROM spawnentry WHERE spawngroupID=73561 AND NOT((npcID=397004) OR (`spawngroupID`<=>73561 AND `npcID`<=>397904 AND `chance`<=>@mesa_fantoma_spawn_percent AND `condition_value_filter`<=>1 AND `min_time`<=>0 AND `max_time`<=>0 AND `min_expansion`<=>-1 AND `max_expansion`<=>-1 AND `content_flags`<=>NULL AND `content_flags_disabled`<=>NULL)))));
INSERT INTO _mesa_fantoma_guard VALUES('rare_unique_73561',((SELECT COUNT(*)FROM spawnentry WHERE spawngroupID=73561 AND npcID=397904)<=1));
INSERT INTO _mesa_fantoma_guard VALUES('original_73576',((SELECT COUNT(*)FROM spawnentry WHERE `spawngroupID`<=>73576 AND `npcID`<=>397002 AND `condition_value_filter`<=>1 AND `min_time`<=>0 AND `max_time`<=>0 AND `min_expansion`<=>-1 AND `max_expansion`<=>-1 AND `content_flags`<=>NULL AND `content_flags_disabled`<=>NULL AND (chance=100 OR chance=100-@mesa_fantoma_spawn_percent))=1));
INSERT INTO _mesa_fantoma_guard VALUES('pool_73576',(NOT EXISTS(SELECT 1 FROM spawnentry WHERE spawngroupID=73576 AND NOT((npcID=397002) OR (`spawngroupID`<=>73576 AND `npcID`<=>397904 AND `chance`<=>@mesa_fantoma_spawn_percent AND `condition_value_filter`<=>1 AND `min_time`<=>0 AND `max_time`<=>0 AND `min_expansion`<=>-1 AND `max_expansion`<=>-1 AND `content_flags`<=>NULL AND `content_flags_disabled`<=>NULL)))));
INSERT INTO _mesa_fantoma_guard VALUES('rare_unique_73576',((SELECT COUNT(*)FROM spawnentry WHERE spawngroupID=73576 AND npcID=397904)<=1));
INSERT INTO _mesa_fantoma_guard VALUES('original_73583',((SELECT COUNT(*)FROM spawnentry WHERE `spawngroupID`<=>73583 AND `npcID`<=>397004 AND `condition_value_filter`<=>1 AND `min_time`<=>0 AND `max_time`<=>0 AND `min_expansion`<=>-1 AND `max_expansion`<=>-1 AND `content_flags`<=>NULL AND `content_flags_disabled`<=>NULL AND (chance=100 OR chance=100-@mesa_fantoma_spawn_percent))=1));
INSERT INTO _mesa_fantoma_guard VALUES('pool_73583',(NOT EXISTS(SELECT 1 FROM spawnentry WHERE spawngroupID=73583 AND NOT((npcID=397004) OR (`spawngroupID`<=>73583 AND `npcID`<=>397904 AND `chance`<=>@mesa_fantoma_spawn_percent AND `condition_value_filter`<=>1 AND `min_time`<=>0 AND `max_time`<=>0 AND `min_expansion`<=>-1 AND `max_expansion`<=>-1 AND `content_flags`<=>NULL AND `content_flags_disabled`<=>NULL)))));
INSERT INTO _mesa_fantoma_guard VALUES('rare_unique_73583',((SELECT COUNT(*)FROM spawnentry WHERE spawngroupID=73583 AND npcID=397904)<=1));
INSERT INTO _mesa_fantoma_guard VALUES('original_73595',((SELECT COUNT(*)FROM spawnentry WHERE `spawngroupID`<=>73595 AND `npcID`<=>397004 AND `condition_value_filter`<=>1 AND `min_time`<=>0 AND `max_time`<=>0 AND `min_expansion`<=>-1 AND `max_expansion`<=>-1 AND `content_flags`<=>NULL AND `content_flags_disabled`<=>NULL AND (chance=100 OR chance=100-@mesa_fantoma_spawn_percent))=1));
INSERT INTO _mesa_fantoma_guard VALUES('pool_73595',(NOT EXISTS(SELECT 1 FROM spawnentry WHERE spawngroupID=73595 AND NOT((npcID=397004) OR (`spawngroupID`<=>73595 AND `npcID`<=>397904 AND `chance`<=>@mesa_fantoma_spawn_percent AND `condition_value_filter`<=>1 AND `min_time`<=>0 AND `max_time`<=>0 AND `min_expansion`<=>-1 AND `max_expansion`<=>-1 AND `content_flags`<=>NULL AND `content_flags_disabled`<=>NULL)))));
INSERT INTO _mesa_fantoma_guard VALUES('rare_unique_73595',((SELECT COUNT(*)FROM spawnentry WHERE spawngroupID=73595 AND npcID=397904)<=1));
INSERT INTO _mesa_fantoma_guard VALUES('original_73626',((SELECT COUNT(*)FROM spawnentry WHERE `spawngroupID`<=>73626 AND `npcID`<=>397004 AND `condition_value_filter`<=>1 AND `min_time`<=>0 AND `max_time`<=>0 AND `min_expansion`<=>-1 AND `max_expansion`<=>-1 AND `content_flags`<=>NULL AND `content_flags_disabled`<=>NULL AND (chance=100 OR chance=100-@mesa_fantoma_spawn_percent))=1));
INSERT INTO _mesa_fantoma_guard VALUES('pool_73626',(NOT EXISTS(SELECT 1 FROM spawnentry WHERE spawngroupID=73626 AND NOT((npcID=397004) OR (`spawngroupID`<=>73626 AND `npcID`<=>397904 AND `chance`<=>@mesa_fantoma_spawn_percent AND `condition_value_filter`<=>1 AND `min_time`<=>0 AND `max_time`<=>0 AND `min_expansion`<=>-1 AND `max_expansion`<=>-1 AND `content_flags`<=>NULL AND `content_flags_disabled`<=>NULL)))));
INSERT INTO _mesa_fantoma_guard VALUES('rare_unique_73626',((SELECT COUNT(*)FROM spawnentry WHERE spawngroupID=73626 AND npcID=397904)<=1));
INSERT INTO _mesa_fantoma_guard VALUES('original_73641',((SELECT COUNT(*)FROM spawnentry WHERE `spawngroupID`<=>73641 AND `npcID`<=>397001 AND `condition_value_filter`<=>1 AND `min_time`<=>0 AND `max_time`<=>0 AND `min_expansion`<=>-1 AND `max_expansion`<=>-1 AND `content_flags`<=>NULL AND `content_flags_disabled`<=>NULL AND (chance=100 OR chance=100-@mesa_fantoma_spawn_percent))=1));
INSERT INTO _mesa_fantoma_guard VALUES('pool_73641',(NOT EXISTS(SELECT 1 FROM spawnentry WHERE spawngroupID=73641 AND NOT((npcID=397001) OR (`spawngroupID`<=>73641 AND `npcID`<=>397904 AND `chance`<=>@mesa_fantoma_spawn_percent AND `condition_value_filter`<=>1 AND `min_time`<=>0 AND `max_time`<=>0 AND `min_expansion`<=>-1 AND `max_expansion`<=>-1 AND `content_flags`<=>NULL AND `content_flags_disabled`<=>NULL)))));
INSERT INTO _mesa_fantoma_guard VALUES('rare_unique_73641',((SELECT COUNT(*)FROM spawnentry WHERE spawngroupID=73641 AND npcID=397904)<=1));
INSERT INTO _mesa_fantoma_guard VALUES('original_73657',((SELECT COUNT(*)FROM spawnentry WHERE `spawngroupID`<=>73657 AND `npcID`<=>397001 AND `condition_value_filter`<=>1 AND `min_time`<=>0 AND `max_time`<=>0 AND `min_expansion`<=>-1 AND `max_expansion`<=>-1 AND `content_flags`<=>NULL AND `content_flags_disabled`<=>NULL AND (chance=100 OR chance=100-@mesa_fantoma_spawn_percent))=1));
INSERT INTO _mesa_fantoma_guard VALUES('pool_73657',(NOT EXISTS(SELECT 1 FROM spawnentry WHERE spawngroupID=73657 AND NOT((npcID=397001) OR (`spawngroupID`<=>73657 AND `npcID`<=>397904 AND `chance`<=>@mesa_fantoma_spawn_percent AND `condition_value_filter`<=>1 AND `min_time`<=>0 AND `max_time`<=>0 AND `min_expansion`<=>-1 AND `max_expansion`<=>-1 AND `content_flags`<=>NULL AND `content_flags_disabled`<=>NULL)))));
INSERT INTO _mesa_fantoma_guard VALUES('rare_unique_73657',((SELECT COUNT(*)FROM spawnentry WHERE spawngroupID=73657 AND npcID=397904)<=1));
INSERT INTO _mesa_fantoma_guard VALUES('original_73679',((SELECT COUNT(*)FROM spawnentry WHERE `spawngroupID`<=>73679 AND `npcID`<=>397004 AND `condition_value_filter`<=>1 AND `min_time`<=>0 AND `max_time`<=>0 AND `min_expansion`<=>-1 AND `max_expansion`<=>-1 AND `content_flags`<=>NULL AND `content_flags_disabled`<=>NULL AND (chance=100 OR chance=100-@mesa_fantoma_spawn_percent))=1));
INSERT INTO _mesa_fantoma_guard VALUES('pool_73679',(NOT EXISTS(SELECT 1 FROM spawnentry WHERE spawngroupID=73679 AND NOT((npcID=397004) OR (`spawngroupID`<=>73679 AND `npcID`<=>397904 AND `chance`<=>@mesa_fantoma_spawn_percent AND `condition_value_filter`<=>1 AND `min_time`<=>0 AND `max_time`<=>0 AND `min_expansion`<=>-1 AND `max_expansion`<=>-1 AND `content_flags`<=>NULL AND `content_flags_disabled`<=>NULL)))));
INSERT INTO _mesa_fantoma_guard VALUES('rare_unique_73679',((SELECT COUNT(*)FROM spawnentry WHERE spawngroupID=73679 AND npcID=397904)<=1));
INSERT INTO _mesa_fantoma_guard VALUES('original_73694',((SELECT COUNT(*)FROM spawnentry WHERE `spawngroupID`<=>73694 AND `npcID`<=>397002 AND `condition_value_filter`<=>1 AND `min_time`<=>0 AND `max_time`<=>0 AND `min_expansion`<=>-1 AND `max_expansion`<=>-1 AND `content_flags`<=>NULL AND `content_flags_disabled`<=>NULL AND (chance=100 OR chance=100-@mesa_fantoma_spawn_percent))=1));
INSERT INTO _mesa_fantoma_guard VALUES('pool_73694',(NOT EXISTS(SELECT 1 FROM spawnentry WHERE spawngroupID=73694 AND NOT((npcID=397002) OR (`spawngroupID`<=>73694 AND `npcID`<=>397904 AND `chance`<=>@mesa_fantoma_spawn_percent AND `condition_value_filter`<=>1 AND `min_time`<=>0 AND `max_time`<=>0 AND `min_expansion`<=>-1 AND `max_expansion`<=>-1 AND `content_flags`<=>NULL AND `content_flags_disabled`<=>NULL)))));
INSERT INTO _mesa_fantoma_guard VALUES('rare_unique_73694',((SELECT COUNT(*)FROM spawnentry WHERE spawngroupID=73694 AND npcID=397904)<=1));
START TRANSACTION;
INSERT INTO loottable(`id`,`name`,`mincash`,`maxcash`,`avgcoin`,`done`,`min_expansion`,`max_expansion`,`content_flags`,`content_flags_disabled`)SELECT 397904,'May2013 Mesa Fantoma reconstructed loot',0,0,0,0,-1,-1,NULL,NULL WHERE NOT EXISTS(SELECT 1 FROM loottable WHERE `id`<=>397904);
INSERT INTO lootdrop(`id`,`name`,`min_expansion`,`max_expansion`,`content_flags`,`content_flags_disabled`)SELECT 397904,'May2013 Mesa Fantoma quest pelt',-1,-1,NULL,NULL WHERE NOT EXISTS(SELECT 1 FROM lootdrop WHERE `id`<=>397904);
INSERT INTO lootdrop(`id`,`name`,`min_expansion`,`max_expansion`,`content_flags`,`content_flags_disabled`)SELECT 397905,'May2013 Mesa Fantoma reconstructed gear weights',-1,-1,NULL,NULL WHERE NOT EXISTS(SELECT 1 FROM lootdrop WHERE `id`<=>397905);
INSERT INTO loottable_entries(`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`)SELECT 397904,397904,1,0,0,100 WHERE NOT EXISTS(SELECT 1 FROM loottable_entries WHERE `loottable_id`<=>397904 AND `lootdrop_id`<=>397904);
INSERT INTO loottable_entries(`loottable_id`,`lootdrop_id`,`multiplier`,`droplimit`,`mindrop`,`probability`)SELECT 397904,397905,1,1,1,100 WHERE NOT EXISTS(SELECT 1 FROM loottable_entries WHERE `loottable_id`<=>397904 AND `lootdrop_id`<=>397905);
INSERT INTO lootdrop_entries(`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`,`content_flags`,`content_flags_disabled`)SELECT 397904,88127,1,0,@mesa_fantoma_pelt_percent,0,0,0,1,0,0,-1,-1,NULL,NULL WHERE NOT EXISTS(SELECT 1 FROM lootdrop_entries WHERE `lootdrop_id`<=>397904 AND `item_id`<=>88127);
INSERT INTO lootdrop_entries(`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`,`content_flags`,`content_flags_disabled`)SELECT 397905,46332,1,0,@mesa_fantoma_boots_weight,0,0,0,1,0,0,-1,-1,NULL,NULL WHERE NOT EXISTS(SELECT 1 FROM lootdrop_entries WHERE `lootdrop_id`<=>397905 AND `item_id`<=>46332);
INSERT INTO lootdrop_entries(`lootdrop_id`,`item_id`,`item_charges`,`equip_item`,`chance`,`disabled_chance`,`trivial_min_level`,`trivial_max_level`,`multiplier`,`npc_min_level`,`npc_max_level`,`min_expansion`,`max_expansion`,`content_flags`,`content_flags_disabled`)SELECT 397905,46338,1,0,@mesa_fantoma_club_weight,0,0,0,1,0,0,-1,-1,NULL,NULL WHERE NOT EXISTS(SELECT 1 FROM lootdrop_entries WHERE `lootdrop_id`<=>397905 AND `item_id`<=>46338);
UPDATE spawnentry SET chance=100-@mesa_fantoma_spawn_percent WHERE `spawngroupID`<=>73475 AND `npcID`<=>397001;
INSERT INTO spawnentry(`spawngroupID`,`npcID`,`chance`,`condition_value_filter`,`min_time`,`max_time`,`min_expansion`,`max_expansion`,`content_flags`,`content_flags_disabled`)SELECT 73475,397904,@mesa_fantoma_spawn_percent,1,0,0,-1,-1,NULL,NULL WHERE NOT EXISTS(SELECT 1 FROM spawnentry WHERE spawngroupID=73475 AND npcID=397904);
UPDATE spawnentry SET chance=100-@mesa_fantoma_spawn_percent WHERE `spawngroupID`<=>73476 AND `npcID`<=>397002;
INSERT INTO spawnentry(`spawngroupID`,`npcID`,`chance`,`condition_value_filter`,`min_time`,`max_time`,`min_expansion`,`max_expansion`,`content_flags`,`content_flags_disabled`)SELECT 73476,397904,@mesa_fantoma_spawn_percent,1,0,0,-1,-1,NULL,NULL WHERE NOT EXISTS(SELECT 1 FROM spawnentry WHERE spawngroupID=73476 AND npcID=397904);
UPDATE spawnentry SET chance=100-@mesa_fantoma_spawn_percent WHERE `spawngroupID`<=>73478 AND `npcID`<=>397004;
INSERT INTO spawnentry(`spawngroupID`,`npcID`,`chance`,`condition_value_filter`,`min_time`,`max_time`,`min_expansion`,`max_expansion`,`content_flags`,`content_flags_disabled`)SELECT 73478,397904,@mesa_fantoma_spawn_percent,1,0,0,-1,-1,NULL,NULL WHERE NOT EXISTS(SELECT 1 FROM spawnentry WHERE spawngroupID=73478 AND npcID=397904);
UPDATE spawnentry SET chance=100-@mesa_fantoma_spawn_percent WHERE `spawngroupID`<=>73484 AND `npcID`<=>397001;
INSERT INTO spawnentry(`spawngroupID`,`npcID`,`chance`,`condition_value_filter`,`min_time`,`max_time`,`min_expansion`,`max_expansion`,`content_flags`,`content_flags_disabled`)SELECT 73484,397904,@mesa_fantoma_spawn_percent,1,0,0,-1,-1,NULL,NULL WHERE NOT EXISTS(SELECT 1 FROM spawnentry WHERE spawngroupID=73484 AND npcID=397904);
UPDATE spawnentry SET chance=100-@mesa_fantoma_spawn_percent WHERE `spawngroupID`<=>73485 AND `npcID`<=>397004;
INSERT INTO spawnentry(`spawngroupID`,`npcID`,`chance`,`condition_value_filter`,`min_time`,`max_time`,`min_expansion`,`max_expansion`,`content_flags`,`content_flags_disabled`)SELECT 73485,397904,@mesa_fantoma_spawn_percent,1,0,0,-1,-1,NULL,NULL WHERE NOT EXISTS(SELECT 1 FROM spawnentry WHERE spawngroupID=73485 AND npcID=397904);
UPDATE spawnentry SET chance=100-@mesa_fantoma_spawn_percent WHERE `spawngroupID`<=>73493 AND `npcID`<=>397001;
INSERT INTO spawnentry(`spawngroupID`,`npcID`,`chance`,`condition_value_filter`,`min_time`,`max_time`,`min_expansion`,`max_expansion`,`content_flags`,`content_flags_disabled`)SELECT 73493,397904,@mesa_fantoma_spawn_percent,1,0,0,-1,-1,NULL,NULL WHERE NOT EXISTS(SELECT 1 FROM spawnentry WHERE spawngroupID=73493 AND npcID=397904);
UPDATE spawnentry SET chance=100-@mesa_fantoma_spawn_percent WHERE `spawngroupID`<=>73494 AND `npcID`<=>397001;
INSERT INTO spawnentry(`spawngroupID`,`npcID`,`chance`,`condition_value_filter`,`min_time`,`max_time`,`min_expansion`,`max_expansion`,`content_flags`,`content_flags_disabled`)SELECT 73494,397904,@mesa_fantoma_spawn_percent,1,0,0,-1,-1,NULL,NULL WHERE NOT EXISTS(SELECT 1 FROM spawnentry WHERE spawngroupID=73494 AND npcID=397904);
UPDATE spawnentry SET chance=100-@mesa_fantoma_spawn_percent WHERE `spawngroupID`<=>73502 AND `npcID`<=>397002;
INSERT INTO spawnentry(`spawngroupID`,`npcID`,`chance`,`condition_value_filter`,`min_time`,`max_time`,`min_expansion`,`max_expansion`,`content_flags`,`content_flags_disabled`)SELECT 73502,397904,@mesa_fantoma_spawn_percent,1,0,0,-1,-1,NULL,NULL WHERE NOT EXISTS(SELECT 1 FROM spawnentry WHERE spawngroupID=73502 AND npcID=397904);
UPDATE spawnentry SET chance=100-@mesa_fantoma_spawn_percent WHERE `spawngroupID`<=>73507 AND `npcID`<=>397002;
INSERT INTO spawnentry(`spawngroupID`,`npcID`,`chance`,`condition_value_filter`,`min_time`,`max_time`,`min_expansion`,`max_expansion`,`content_flags`,`content_flags_disabled`)SELECT 73507,397904,@mesa_fantoma_spawn_percent,1,0,0,-1,-1,NULL,NULL WHERE NOT EXISTS(SELECT 1 FROM spawnentry WHERE spawngroupID=73507 AND npcID=397904);
UPDATE spawnentry SET chance=100-@mesa_fantoma_spawn_percent WHERE `spawngroupID`<=>73531 AND `npcID`<=>397002;
INSERT INTO spawnentry(`spawngroupID`,`npcID`,`chance`,`condition_value_filter`,`min_time`,`max_time`,`min_expansion`,`max_expansion`,`content_flags`,`content_flags_disabled`)SELECT 73531,397904,@mesa_fantoma_spawn_percent,1,0,0,-1,-1,NULL,NULL WHERE NOT EXISTS(SELECT 1 FROM spawnentry WHERE spawngroupID=73531 AND npcID=397904);
UPDATE spawnentry SET chance=100-@mesa_fantoma_spawn_percent WHERE `spawngroupID`<=>73544 AND `npcID`<=>397035;
INSERT INTO spawnentry(`spawngroupID`,`npcID`,`chance`,`condition_value_filter`,`min_time`,`max_time`,`min_expansion`,`max_expansion`,`content_flags`,`content_flags_disabled`)SELECT 73544,397904,@mesa_fantoma_spawn_percent,1,0,0,-1,-1,NULL,NULL WHERE NOT EXISTS(SELECT 1 FROM spawnentry WHERE spawngroupID=73544 AND npcID=397904);
UPDATE spawnentry SET chance=100-@mesa_fantoma_spawn_percent WHERE `spawngroupID`<=>73546 AND `npcID`<=>397001;
INSERT INTO spawnentry(`spawngroupID`,`npcID`,`chance`,`condition_value_filter`,`min_time`,`max_time`,`min_expansion`,`max_expansion`,`content_flags`,`content_flags_disabled`)SELECT 73546,397904,@mesa_fantoma_spawn_percent,1,0,0,-1,-1,NULL,NULL WHERE NOT EXISTS(SELECT 1 FROM spawnentry WHERE spawngroupID=73546 AND npcID=397904);
UPDATE spawnentry SET chance=100-@mesa_fantoma_spawn_percent WHERE `spawngroupID`<=>73561 AND `npcID`<=>397004;
INSERT INTO spawnentry(`spawngroupID`,`npcID`,`chance`,`condition_value_filter`,`min_time`,`max_time`,`min_expansion`,`max_expansion`,`content_flags`,`content_flags_disabled`)SELECT 73561,397904,@mesa_fantoma_spawn_percent,1,0,0,-1,-1,NULL,NULL WHERE NOT EXISTS(SELECT 1 FROM spawnentry WHERE spawngroupID=73561 AND npcID=397904);
UPDATE spawnentry SET chance=100-@mesa_fantoma_spawn_percent WHERE `spawngroupID`<=>73576 AND `npcID`<=>397002;
INSERT INTO spawnentry(`spawngroupID`,`npcID`,`chance`,`condition_value_filter`,`min_time`,`max_time`,`min_expansion`,`max_expansion`,`content_flags`,`content_flags_disabled`)SELECT 73576,397904,@mesa_fantoma_spawn_percent,1,0,0,-1,-1,NULL,NULL WHERE NOT EXISTS(SELECT 1 FROM spawnentry WHERE spawngroupID=73576 AND npcID=397904);
UPDATE spawnentry SET chance=100-@mesa_fantoma_spawn_percent WHERE `spawngroupID`<=>73583 AND `npcID`<=>397004;
INSERT INTO spawnentry(`spawngroupID`,`npcID`,`chance`,`condition_value_filter`,`min_time`,`max_time`,`min_expansion`,`max_expansion`,`content_flags`,`content_flags_disabled`)SELECT 73583,397904,@mesa_fantoma_spawn_percent,1,0,0,-1,-1,NULL,NULL WHERE NOT EXISTS(SELECT 1 FROM spawnentry WHERE spawngroupID=73583 AND npcID=397904);
UPDATE spawnentry SET chance=100-@mesa_fantoma_spawn_percent WHERE `spawngroupID`<=>73595 AND `npcID`<=>397004;
INSERT INTO spawnentry(`spawngroupID`,`npcID`,`chance`,`condition_value_filter`,`min_time`,`max_time`,`min_expansion`,`max_expansion`,`content_flags`,`content_flags_disabled`)SELECT 73595,397904,@mesa_fantoma_spawn_percent,1,0,0,-1,-1,NULL,NULL WHERE NOT EXISTS(SELECT 1 FROM spawnentry WHERE spawngroupID=73595 AND npcID=397904);
UPDATE spawnentry SET chance=100-@mesa_fantoma_spawn_percent WHERE `spawngroupID`<=>73626 AND `npcID`<=>397004;
INSERT INTO spawnentry(`spawngroupID`,`npcID`,`chance`,`condition_value_filter`,`min_time`,`max_time`,`min_expansion`,`max_expansion`,`content_flags`,`content_flags_disabled`)SELECT 73626,397904,@mesa_fantoma_spawn_percent,1,0,0,-1,-1,NULL,NULL WHERE NOT EXISTS(SELECT 1 FROM spawnentry WHERE spawngroupID=73626 AND npcID=397904);
UPDATE spawnentry SET chance=100-@mesa_fantoma_spawn_percent WHERE `spawngroupID`<=>73641 AND `npcID`<=>397001;
INSERT INTO spawnentry(`spawngroupID`,`npcID`,`chance`,`condition_value_filter`,`min_time`,`max_time`,`min_expansion`,`max_expansion`,`content_flags`,`content_flags_disabled`)SELECT 73641,397904,@mesa_fantoma_spawn_percent,1,0,0,-1,-1,NULL,NULL WHERE NOT EXISTS(SELECT 1 FROM spawnentry WHERE spawngroupID=73641 AND npcID=397904);
UPDATE spawnentry SET chance=100-@mesa_fantoma_spawn_percent WHERE `spawngroupID`<=>73657 AND `npcID`<=>397001;
INSERT INTO spawnentry(`spawngroupID`,`npcID`,`chance`,`condition_value_filter`,`min_time`,`max_time`,`min_expansion`,`max_expansion`,`content_flags`,`content_flags_disabled`)SELECT 73657,397904,@mesa_fantoma_spawn_percent,1,0,0,-1,-1,NULL,NULL WHERE NOT EXISTS(SELECT 1 FROM spawnentry WHERE spawngroupID=73657 AND npcID=397904);
UPDATE spawnentry SET chance=100-@mesa_fantoma_spawn_percent WHERE `spawngroupID`<=>73679 AND `npcID`<=>397004;
INSERT INTO spawnentry(`spawngroupID`,`npcID`,`chance`,`condition_value_filter`,`min_time`,`max_time`,`min_expansion`,`max_expansion`,`content_flags`,`content_flags_disabled`)SELECT 73679,397904,@mesa_fantoma_spawn_percent,1,0,0,-1,-1,NULL,NULL WHERE NOT EXISTS(SELECT 1 FROM spawnentry WHERE spawngroupID=73679 AND npcID=397904);
UPDATE spawnentry SET chance=100-@mesa_fantoma_spawn_percent WHERE `spawngroupID`<=>73694 AND `npcID`<=>397002;
INSERT INTO spawnentry(`spawngroupID`,`npcID`,`chance`,`condition_value_filter`,`min_time`,`max_time`,`min_expansion`,`max_expansion`,`content_flags`,`content_flags_disabled`)SELECT 73694,397904,@mesa_fantoma_spawn_percent,1,0,0,-1,-1,NULL,NULL WHERE NOT EXISTS(SELECT 1 FROM spawnentry WHERE spawngroupID=73694 AND npcID=397904);
COMMIT;

-- ---- mesa-remaining/sql/030-recipes.sql ----
-- Researched Mesa recipe migration.
SET NAMES utf8mb4;
SET SESSION check_constraint_checks=1;
DROP TEMPORARY TABLE IF EXISTS _mesa_recipes_guard;
CREATE TEMPORARY TABLE _mesa_recipes_guard(label VARCHAR(100)PRIMARY KEY,ok TINYINT NOT NULL,CHECK(ok=1))ENGINE=InnoDB;
-- NMS adaptation (normalize-before-guards): stock peq already carries 25 brew/craft
-- recipes for these same May-2013 Mesa items (930423,930619,930620,930621,930628,
-- 930629,931771,932871,932872,932873,933775,933776,933782,935701,935702,935703,
-- 939561,939562,939564,939566,939567,939568,939569,939570,939571). The researched
-- overlays below (3041001-3041027) replace them one-for-one; retire the stock
-- duplicate producers so each item has exactly one recipe.
DELETE FROM tradeskill_recipe_entries WHERE recipe_id IN (930423,930619,930620,930621,930628,930629,931771,932871,932872,932873,933775,933776,933782,935701,935702,935703,939561,939562,939564,939566,939567,939568,939569,939570,939571);
DELETE FROM tradeskill_recipe WHERE id IN (930423,930619,930620,930621,930628,930629,931771,932871,932872,932873,933775,933776,933782,935701,935702,935703,939561,939562,939564,939566,939567,939568,939569,939570,939571);
INSERT INTO _mesa_recipes_guard VALUES('explicit_review',COALESCE(@mesa_remaining_recipes_reviewed,0)=1);
INSERT INTO _mesa_recipes_guard VALUES('recipe_identity_0',(NOT EXISTS(SELECT 1 FROM tradeskill_recipe WHERE id=3041001 AND NOT(name='Liviu''s Dark Stout' AND notes='May2013 Mesa researched recipe overlay'))));
INSERT INTO _mesa_recipes_guard VALUES('recipe_identity_1',(NOT EXISTS(SELECT 1 FROM tradeskill_recipe_entries WHERE successcount>0 AND item_id=87167 AND recipe_id<>3041001)));
INSERT INTO _mesa_recipes_guard VALUES('recipe_identity_2',(NOT EXISTS(SELECT 1 FROM tradeskill_recipe WHERE id=3041002 AND NOT(name='Liviu''s Finest Brew' AND notes='May2013 Mesa researched recipe overlay'))));
INSERT INTO _mesa_recipes_guard VALUES('recipe_identity_3',(NOT EXISTS(SELECT 1 FROM tradeskill_recipe_entries WHERE successcount>0 AND item_id=87168 AND recipe_id<>3041002)));
INSERT INTO _mesa_recipes_guard VALUES('recipe_identity_4',(NOT EXISTS(SELECT 1 FROM tradeskill_recipe WHERE id=3041003 AND NOT(name='Tudor''s Aged Merlot' AND notes='May2013 Mesa researched recipe overlay'))));
INSERT INTO _mesa_recipes_guard VALUES('recipe_identity_5',(NOT EXISTS(SELECT 1 FROM tradeskill_recipe_entries WHERE successcount>0 AND item_id=87169 AND recipe_id<>3041003)));
INSERT INTO _mesa_recipes_guard VALUES('recipe_identity_6',(NOT EXISTS(SELECT 1 FROM tradeskill_recipe WHERE id=3041004 AND NOT(name='Tudor''s Stormwater Whiskey' AND notes='May2013 Mesa researched recipe overlay'))));
INSERT INTO _mesa_recipes_guard VALUES('recipe_identity_7',(NOT EXISTS(SELECT 1 FROM tradeskill_recipe_entries WHERE successcount>0 AND item_id=87170 AND recipe_id<>3041004)));
INSERT INTO _mesa_recipes_guard VALUES('recipe_identity_8',(NOT EXISTS(SELECT 1 FROM tradeskill_recipe WHERE id=3041005 AND NOT(name='Glowing Green Silver' AND notes='May2013 Mesa researched recipe overlay'))));
INSERT INTO _mesa_recipes_guard VALUES('recipe_identity_9',(NOT EXISTS(SELECT 1 FROM tradeskill_recipe_entries WHERE successcount>0 AND item_id=97740 AND recipe_id<>3041005)));
INSERT INTO _mesa_recipes_guard VALUES('recipe_identity_10',(NOT EXISTS(SELECT 1 FROM tradeskill_recipe WHERE id=3041006 AND NOT(name='Glowing Emerald Pendant' AND notes='May2013 Mesa researched recipe overlay'))));
INSERT INTO _mesa_recipes_guard VALUES('recipe_identity_11',(NOT EXISTS(SELECT 1 FROM tradeskill_recipe_entries WHERE successcount>0 AND item_id=97739 AND recipe_id<>3041006)));
INSERT INTO _mesa_recipes_guard VALUES('recipe_identity_12',(NOT EXISTS(SELECT 1 FROM tradeskill_recipe WHERE id=3041007 AND NOT(name='Spider Silk Filter' AND notes='May2013 Mesa researched recipe overlay'))));
INSERT INTO _mesa_recipes_guard VALUES('recipe_identity_13',(NOT EXISTS(SELECT 1 FROM tradeskill_recipe_entries WHERE successcount>0 AND item_id=97745 AND recipe_id<>3041007)));
INSERT INTO _mesa_recipes_guard VALUES('recipe_identity_14',(NOT EXISTS(SELECT 1 FROM tradeskill_recipe WHERE id=3041008 AND NOT(name='Chilled Pure Water' AND notes='May2013 Mesa researched recipe overlay'))));
INSERT INTO _mesa_recipes_guard VALUES('recipe_identity_15',(NOT EXISTS(SELECT 1 FROM tradeskill_recipe_entries WHERE successcount>0 AND item_id=97728 AND recipe_id<>3041008)));
INSERT INTO _mesa_recipes_guard VALUES('recipe_identity_16',(NOT EXISTS(SELECT 1 FROM tradeskill_recipe WHERE id=3041009 AND NOT(name='Spiced Wind Willow Acorns' AND notes='May2013 Mesa researched recipe overlay'))));
INSERT INTO _mesa_recipes_guard VALUES('recipe_identity_17',(NOT EXISTS(SELECT 1 FROM tradeskill_recipe_entries WHERE successcount>0 AND item_id=97744 AND recipe_id<>3041009)));
INSERT INTO _mesa_recipes_guard VALUES('recipe_identity_18',(NOT EXISTS(SELECT 1 FROM tradeskill_recipe WHERE id=3041010 AND NOT(name='Forest Green Silk Swatch' AND notes='May2013 Mesa researched recipe overlay'))));
INSERT INTO _mesa_recipes_guard VALUES('recipe_identity_19',(NOT EXISTS(SELECT 1 FROM tradeskill_recipe_entries WHERE successcount>0 AND item_id=97738 AND recipe_id<>3041010)));
INSERT INTO _mesa_recipes_guard VALUES('recipe_identity_20',(NOT EXISTS(SELECT 1 FROM tradeskill_recipe WHERE id=3041011 AND NOT(name='Shimmering Dryad Dress' AND notes='May2013 Mesa researched recipe overlay'))));
INSERT INTO _mesa_recipes_guard VALUES('recipe_identity_21',(NOT EXISTS(SELECT 1 FROM tradeskill_recipe_entries WHERE successcount>0 AND item_id=97743 AND recipe_id<>3041011)));
INSERT INTO _mesa_recipes_guard VALUES('recipe_identity_22',(NOT EXISTS(SELECT 1 FROM tradeskill_recipe WHERE id=3041012 AND NOT(name='Envenomed Steel' AND notes='May2013 Mesa researched recipe overlay'))));
INSERT INTO _mesa_recipes_guard VALUES('recipe_identity_23',(NOT EXISTS(SELECT 1 FROM tradeskill_recipe_entries WHERE successcount>0 AND item_id=97733 AND recipe_id<>3041012)));
INSERT INTO _mesa_recipes_guard VALUES('recipe_identity_24',(NOT EXISTS(SELECT 1 FROM tradeskill_recipe WHERE id=3041013 AND NOT(name='Envenomed Steel Blade' AND notes='May2013 Mesa researched recipe overlay'))));
INSERT INTO _mesa_recipes_guard VALUES('recipe_identity_25',(NOT EXISTS(SELECT 1 FROM tradeskill_recipe_entries WHERE successcount>0 AND item_id=97734 AND recipe_id<>3041013)));
INSERT INTO _mesa_recipes_guard VALUES('recipe_identity_26',(NOT EXISTS(SELECT 1 FROM tradeskill_recipe WHERE id=3041014 AND NOT(name='Envenomed Athame' AND notes='May2013 Mesa researched recipe overlay'))));
INSERT INTO _mesa_recipes_guard VALUES('recipe_identity_27',(NOT EXISTS(SELECT 1 FROM tradeskill_recipe_entries WHERE successcount>0 AND item_id=97732 AND recipe_id<>3041014)));
INSERT INTO _mesa_recipes_guard VALUES('recipe_identity_28',(NOT EXISTS(SELECT 1 FROM tradeskill_recipe WHERE id=3041015 AND NOT(name='Fine White Clay' AND notes='May2013 Mesa researched recipe overlay'))));
INSERT INTO _mesa_recipes_guard VALUES('recipe_identity_29',(NOT EXISTS(SELECT 1 FROM tradeskill_recipe_entries WHERE successcount>0 AND item_id=97737 AND recipe_id<>3041015)));
INSERT INTO _mesa_recipes_guard VALUES('recipe_identity_30',(NOT EXISTS(SELECT 1 FROM tradeskill_recipe WHERE id=3041016 AND NOT(name='Unfired Fine Green Perfume Bottle' AND notes='May2013 Mesa researched recipe overlay'))));
INSERT INTO _mesa_recipes_guard VALUES('recipe_identity_31',(NOT EXISTS(SELECT 1 FROM tradeskill_recipe_entries WHERE successcount>0 AND item_id=97746 AND recipe_id<>3041016)));
INSERT INTO _mesa_recipes_guard VALUES('recipe_identity_32',(NOT EXISTS(SELECT 1 FROM tradeskill_recipe WHERE id=3041017 AND NOT(name='Fine Green Perfume Bottle' AND notes='May2013 Mesa researched recipe overlay'))));
INSERT INTO _mesa_recipes_guard VALUES('recipe_identity_33',(NOT EXISTS(SELECT 1 FROM tradeskill_recipe_entries WHERE successcount>0 AND item_id=97736 AND recipe_id<>3041017)));
INSERT INTO _mesa_recipes_guard VALUES('recipe_identity_34',(NOT EXISTS(SELECT 1 FROM tradeskill_recipe WHERE id=3041018 AND NOT(name='Ciodaru''s Gift Box Parts' AND notes='May2013 Mesa researched recipe overlay'))));
INSERT INTO _mesa_recipes_guard VALUES('recipe_identity_35',(NOT EXISTS(SELECT 1 FROM tradeskill_recipe_entries WHERE successcount>0 AND item_id=97731 AND recipe_id<>3041018)));
INSERT INTO _mesa_recipes_guard VALUES('recipe_identity_36',(NOT EXISTS(SELECT 1 FROM tradeskill_recipe WHERE id=3041019 AND NOT(name='Petrified Spider Eyes' AND notes='May2013 Mesa researched recipe overlay'))));
INSERT INTO _mesa_recipes_guard VALUES('recipe_identity_37',(NOT EXISTS(SELECT 1 FROM tradeskill_recipe_entries WHERE successcount>0 AND item_id=97741 AND recipe_id<>3041019)));
INSERT INTO _mesa_recipes_guard VALUES('recipe_identity_38',(NOT EXISTS(SELECT 1 FROM tradeskill_recipe WHERE id=3041020 AND NOT(name='Ciodaru''s Gift Box' AND notes='May2013 Mesa researched recipe overlay'))));
INSERT INTO _mesa_recipes_guard VALUES('recipe_identity_39',(NOT EXISTS(SELECT 1 FROM tradeskill_recipe_entries WHERE successcount>0 AND item_id=97729 AND recipe_id<>3041020)));
INSERT INTO _mesa_recipes_guard VALUES('recipe_identity_40',(NOT EXISTS(SELECT 1 FROM tradeskill_recipe WHERE id=3041021 AND NOT(name='Ciodaru''s Gift Box (sealed)' AND notes='May2013 Mesa researched recipe overlay'))));
INSERT INTO _mesa_recipes_guard VALUES('recipe_identity_41',(NOT EXISTS(SELECT 1 FROM tradeskill_recipe_entries WHERE successcount>0 AND item_id=97730 AND recipe_id<>3041021)));
INSERT INTO _mesa_recipes_guard VALUES('recipe_identity_42',(NOT EXISTS(SELECT 1 FROM tradeskill_recipe WHERE id=3041022 AND NOT(name='Spider Silk Thread' AND notes='May2013 Mesa researched recipe overlay'))));
INSERT INTO _mesa_recipes_guard VALUES('recipe_identity_43',(NOT EXISTS(SELECT 1 FROM tradeskill_recipe_entries WHERE successcount>0 AND item_id=88117 AND recipe_id<>3041022)));
INSERT INTO _mesa_recipes_guard VALUES('recipe_identity_44',(NOT EXISTS(SELECT 1 FROM tradeskill_recipe WHERE id=3041023 AND NOT(name='Spool of Spider Silk Thread' AND notes='May2013 Mesa researched recipe overlay'))));
INSERT INTO _mesa_recipes_guard VALUES('recipe_identity_45',(NOT EXISTS(SELECT 1 FROM tradeskill_recipe_entries WHERE successcount>0 AND item_id=88118 AND recipe_id<>3041023)));
INSERT INTO _mesa_recipes_guard VALUES('recipe_identity_46',(NOT EXISTS(SELECT 1 FROM tradeskill_recipe WHERE id=3041024 AND NOT(name='Wolf Canine Bead' AND notes='May2013 Mesa researched recipe overlay'))));
INSERT INTO _mesa_recipes_guard VALUES('recipe_identity_47',(NOT EXISTS(SELECT 1 FROM tradeskill_recipe_entries WHERE successcount>0 AND item_id=88146 AND recipe_id<>3041024)));
INSERT INTO _mesa_recipes_guard VALUES('recipe_identity_48',(NOT EXISTS(SELECT 1 FROM tradeskill_recipe WHERE id=3041025 AND NOT(name='Snake Fang Bead' AND notes='May2013 Mesa researched recipe overlay'))));
INSERT INTO _mesa_recipes_guard VALUES('recipe_identity_49',(NOT EXISTS(SELECT 1 FROM tradeskill_recipe_entries WHERE successcount>0 AND item_id=88147 AND recipe_id<>3041025)));
INSERT INTO _mesa_recipes_guard VALUES('recipe_identity_50',(NOT EXISTS(SELECT 1 FROM tradeskill_recipe WHERE id=3041026 AND NOT(name='String of Teeth' AND notes='May2013 Mesa researched recipe overlay'))));
INSERT INTO _mesa_recipes_guard VALUES('recipe_identity_51',(NOT EXISTS(SELECT 1 FROM tradeskill_recipe_entries WHERE successcount>0 AND item_id=88148 AND recipe_id<>3041026)));
INSERT INTO _mesa_recipes_guard VALUES('recipe_identity_52',(NOT EXISTS(SELECT 1 FROM tradeskill_recipe WHERE id=3041027 AND NOT(name='Folded Silkfang Pack' AND notes='May2013 Mesa researched recipe overlay'))));
INSERT INTO _mesa_recipes_guard VALUES('recipe_identity_53',(NOT EXISTS(SELECT 1 FROM tradeskill_recipe_entries WHERE successcount>0 AND item_id=88112 AND recipe_id<>3041027)));
INSERT INTO _mesa_recipes_guard VALUES('input_output_identities',((SELECT COUNT(*)FROM items WHERE (id=9650 AND Name='Celestial Essence') OR (id=10029 AND Name='Emerald') OR (id=10064 AND Name='Sewing Needle') OR (id=10300 AND Name='Lightstone') OR (id=10468 AND Name='Small Brick of High Quality Ore') OR (id=12089 AND Name='Backpack Pattern') OR (id=13006 AND Name='Water Flask') OR (id=13041 AND Name='Spider Silk') OR (id=13425 AND Name='Spices') OR (id=16482 AND Name='Silk Swatch') OR (id=16486 AND Name='Silk Thread') OR (id=16590 AND Name='Barley') OR (id=16591 AND Name='Hops') OR (id=16595 AND Name='Malt') OR (id=16598 AND Name='Bottle') OR (id=16908 AND Name='High Quality Firing Sheet') OR (id=22075 AND Name='Thin Blade Mold') OR (id=22104 AND Name='Dark Green Dye') OR (id=29355 AND Name='Glaze Lacquer') OR (id=29742 AND Name='Butter') OR (id=51850 AND Name='Spider Fang') OR (id=58280 AND Name='Garlic') OR (id=87151 AND Name='Fresh Mesa Streamwater') OR (id=87154 AND Name='Indigenous Mesa Yeast') OR (id=87157 AND Name='Worn Cask') OR (id=87158 AND Name='Rawhide Canteen') OR (id=87161 AND Name='Griffon Feather Spores') OR (id=87162 AND Name='Dromrek Barbera Grapes') OR (id=87163 AND Name='Tanglewood Seed Pod') OR (id=87164 AND Name='Lingering Dryad Skull') OR (id=87165 AND Name='Goru`kar Oakwood Barrel') OR (id=87166 AND Name='Flask of Mesa Stormwater') OR (id=87167 AND Name='Liviu''s Dark Stout') OR (id=87168 AND Name='Liviu''s Finest Brew') OR (id=87169 AND Name='Tudor''s Aged Merlot') OR (id=87170 AND Name='Tudor''s Stormwater Whiskey') OR (id=88112 AND Name='Folded Silkfang Pack') OR (id=88113 AND Name='Recluse Spider Fang') OR (id=88114 AND Name='Wolf Canine') OR (id=88115 AND Name='Supple Wolf Pelt') OR (id=88117 AND Name='Spider Silk Thread') OR (id=88118 AND Name='Spool of Spider Silk Thread') OR (id=88121 AND Name='Snake Skin') OR (id=88146 AND Name='Wolf Canine Bead') OR (id=88147 AND Name='Snake Fang Bead') OR (id=88148 AND Name='String of Teeth') OR (id=97194 AND Name='Faceted Lightstone') OR (id=97228 AND Name='Earthen Ooze Slime') OR (id=97229 AND Name='Large Snake Fang') OR (id=97230 AND Name='Mesa Recluse Spinneret') OR (id=97231 AND Name='Section of Mesa Snake Pancreas') OR (id=97233 AND Name='Raw Silver') OR (id=97234 AND Name='Recluse Venom Sac') OR (id=97235 AND Name='Spider Eye') OR (id=97236 AND Name='Windwillow Acorn') OR (id=97237 AND Name='Windwillow Branch') OR (id=97728 AND Name='Chilled Pure Water') OR (id=97729 AND Name='Ciodaru''s Gift Box') OR (id=97730 AND Name='Ciodaru''s Gift Box') OR (id=97731 AND Name='Ciodaru''s Gift Box Parts') OR (id=97732 AND Name='Envenomed Athame') OR (id=97733 AND Name='Envenomed Steel') OR (id=97734 AND Name='Envenomed Steel Blade') OR (id=97735 AND Name='Everchilled Flask') OR (id=97736 AND Name='Fine Green Perfume Bottle') OR (id=97737 AND Name='Fine White Clay') OR (id=97738 AND Name='Forest Green Silk Swatch') OR (id=97739 AND Name='Glowing Emerald Pendant') OR (id=97740 AND Name='Glowing Green Silver') OR (id=97741 AND Name='Petrified Spider Eyes') OR (id=97742 AND Name='Pond Water') OR (id=97743 AND Name='Shimmering Dryad Dress') OR (id=97744 AND Name='Spiced Wind Willow Acorns') OR (id=97745 AND Name='Spider Silk Filter') OR (id=97746 AND Name='Unfired Fine Green Perfume Bottle') OR (id=97747 AND Name='Earthen Perfume') OR (id=97753 AND Name='Fine Green Perfume Bottle Sketch'))=77));
START TRANSACTION;
DELETE FROM tradeskill_recipe_entries WHERE recipe_id IN(3041001,3041002,3041003,3041004,3041005,3041006,3041007,3041008,3041009,3041010,3041011,3041012,3041013,3041014,3041015,3041016,3041017,3041018,3041019,3041020,3041021,3041022,3041023,3041024,3041025,3041026,3041027);
DELETE FROM tradeskill_recipe WHERE id IN(3041001,3041002,3041003,3041004,3041005,3041006,3041007,3041008,3041009,3041010,3041011,3041012,3041013,3041014,3041015,3041016,3041017,3041018,3041019,3041020,3041021,3041022,3041023,3041024,3041025,3041026,3041027);
INSERT INTO tradeskill_recipe(`id`,`name`,`tradeskill`,`skillneeded`,`trivial`,`nofail`,`replace_container`,`notes`,`must_learn`,`learned_by_item_id`,`quest`,`enabled`,`min_expansion`,`max_expansion`) VALUES
(3041001,'Liviu''s Dark Stout',65,0,172,0,0,'May2013 Mesa researched recipe overlay',0,0,0,1,-1,-1),
(3041002,'Liviu''s Finest Brew',65,0,210,0,0,'May2013 Mesa researched recipe overlay',0,0,0,1,-1,-1),
(3041003,'Tudor''s Aged Merlot',65,0,250,0,0,'May2013 Mesa researched recipe overlay',0,0,0,1,-1,-1),
(3041004,'Tudor''s Stormwater Whiskey',65,0,290,0,0,'May2013 Mesa researched recipe overlay',0,0,0,1,-1,-1),
(3041005,'Glowing Green Silver',68,0,190,0,0,'May2013 Mesa researched recipe overlay',0,0,0,1,-1,-1),
(3041006,'Glowing Emerald Pendant',68,0,190,0,0,'May2013 Mesa researched recipe overlay',0,0,0,1,-1,-1),
(3041007,'Spider Silk Filter',61,0,190,0,0,'May2013 Mesa researched recipe overlay',0,0,0,1,-1,-1),
(3041008,'Chilled Pure Water',65,0,190,0,0,'May2013 Mesa researched recipe overlay',0,0,0,1,-1,-1),
(3041009,'Spiced Wind Willow Acorns',60,0,190,0,0,'May2013 Mesa researched recipe overlay',0,0,0,1,-1,-1),
(3041010,'Forest Green Silk Swatch',61,0,190,0,0,'May2013 Mesa researched recipe overlay',0,0,0,1,-1,-1),
(3041011,'Shimmering Dryad Dress',61,0,190,0,0,'May2013 Mesa researched recipe overlay',0,0,0,1,-1,-1),
(3041012,'Envenomed Steel',63,0,190,0,0,'May2013 Mesa researched recipe overlay',0,0,0,1,-1,-1),
(3041013,'Envenomed Steel Blade',63,0,190,0,0,'May2013 Mesa researched recipe overlay',0,0,0,1,-1,-1),
(3041014,'Envenomed Athame',63,0,190,0,0,'May2013 Mesa researched recipe overlay',0,0,0,1,-1,-1),
(3041015,'Fine White Clay',69,0,190,0,0,'May2013 Mesa researched recipe overlay',0,0,0,1,-1,-1),
(3041016,'Unfired Fine Green Perfume Bottle',69,0,190,0,0,'May2013 Mesa researched recipe overlay',0,0,0,1,-1,-1),
(3041017,'Fine Green Perfume Bottle',69,0,190,0,0,'May2013 Mesa researched recipe overlay',0,0,0,1,-1,-1),
(3041018,'Ciodaru''s Gift Box Parts',64,0,190,0,0,'May2013 Mesa researched recipe overlay',0,0,0,1,-1,-1),
(3041019,'Petrified Spider Eyes',68,0,190,0,0,'May2013 Mesa researched recipe overlay',0,0,0,1,-1,-1),
(3041020,'Ciodaru''s Gift Box',64,0,190,0,0,'May2013 Mesa researched recipe overlay',0,0,0,1,-1,-1),
(3041021,'Ciodaru''s Gift Box (sealed)',75,0,0,1,1,'May2013 Mesa researched recipe overlay',0,0,0,1,-1,-1),
(3041022,'Spider Silk Thread',61,0,50,0,0,'May2013 Mesa researched recipe overlay',0,0,0,1,-1,-1),
(3041023,'Spool of Spider Silk Thread',61,0,50,0,0,'May2013 Mesa researched recipe overlay',0,0,0,1,-1,-1),
(3041024,'Wolf Canine Bead',61,0,50,0,0,'May2013 Mesa researched recipe overlay',0,0,0,1,-1,-1),
(3041025,'Snake Fang Bead',61,0,50,0,0,'May2013 Mesa researched recipe overlay',0,0,0,1,-1,-1),
(3041026,'String of Teeth',61,0,92,0,0,'May2013 Mesa researched recipe overlay',0,0,0,1,-1,-1),
(3041027,'Folded Silkfang Pack',61,0,170,0,0,'May2013 Mesa researched recipe overlay',0,0,0,1,-1,-1);
INSERT INTO tradeskill_recipe_entries(`recipe_id`,`item_id`,`successcount`,`failcount`,`componentcount`,`salvagecount`,`iscontainer`) VALUES
(3041001,87151,0,0,1,0,0),
(3041001,16591,0,0,1,0,0),
(3041001,87154,0,0,1,0,0),
(3041001,16595,0,0,1,0,0),
(3041001,87167,1,0,0,0,0),
(3041001,19,0,0,0,0,1),
(3041001,17179,0,0,0,0,1),
(3041001,17521,0,0,0,0,1),
(3041002,16590,0,0,1,0,0),
(3041002,16591,0,0,1,0,0),
(3041002,87157,0,0,1,0,0),
(3041002,87158,0,0,1,0,0),
(3041002,87168,1,0,0,0,0),
(3041002,19,0,0,0,0,1),
(3041002,17179,0,0,0,0,1),
(3041002,17521,0,0,0,0,1),
(3041003,16598,0,1,1,0,0),
(3041003,87162,0,0,1,0,0),
(3041003,87161,0,0,1,0,0),
(3041003,13006,0,0,1,0,0),
(3041003,87169,1,0,0,0,0),
(3041003,19,0,0,0,0,1),
(3041003,17179,0,0,0,0,1),
(3041003,17521,0,0,0,0,1),
(3041004,87166,0,0,1,0,0),
(3041004,87165,0,0,1,0,0),
(3041004,87164,0,0,1,0,0),
(3041004,87163,0,0,1,0,0),
(3041004,87170,1,0,0,0,0),
(3041004,19,0,0,0,0,1),
(3041004,17179,0,0,0,0,1),
(3041004,17521,0,0,0,0,1),
(3041005,97233,0,0,1,0,0),
(3041005,10300,0,0,1,0,0),
(3041005,97231,0,0,1,0,0),
(3041005,97740,1,0,0,0,0),
(3041005,20,0,0,0,0,1),
(3041005,17187,0,0,0,0,1),
(3041005,17764,0,0,0,0,1),
(3041005,17912,0,0,0,0,1),
(3041005,62480,0,0,0,0,1),
(3041006,97740,0,0,1,0,0),
(3041006,10029,0,0,1,0,0),
(3041006,97739,1,0,0,0,0),
(3041006,20,0,0,0,0,1),
(3041006,17187,0,0,0,0,1),
(3041006,17764,0,0,0,0,1),
(3041006,17912,0,0,0,0,1),
(3041006,62480,0,0,0,0,1),
(3041007,9650,0,0,1,0,0),
(3041007,97230,0,0,1,0,0),
(3041007,13041,0,0,2,0,0),
(3041007,97745,1,0,0,0,0),
(3041007,16,0,0,0,0,1),
(3041007,17165,0,0,0,0,1),
(3041007,17768,0,0,0,0,1),
(3041007,17863,0,0,0,0,1),
(3041007,17880,0,0,0,0,1),
(3041007,17966,0,0,0,0,1),
(3041008,97735,0,1,1,0,0),
(3041008,97742,0,0,1,0,0),
(3041008,97745,0,0,1,0,0),
(3041008,97728,1,0,0,0,0),
(3041008,19,0,0,0,0,1),
(3041008,17179,0,0,0,0,1),
(3041008,17521,0,0,0,0,1),
(3041009,29742,0,0,1,0,0),
(3041009,97228,0,0,1,0,0),
(3041009,58280,0,0,1,0,0),
(3041009,13425,0,0,1,0,0),
(3041009,97236,0,0,4,0,0),
(3041009,97744,1,0,0,0,0),
(3041009,15,0,0,0,0,1),
(3041010,22104,0,0,1,0,0),
(3041010,16482,0,0,2,0,0),
(3041010,16486,0,0,2,0,0),
(3041010,97738,1,0,0,0,0),
(3041010,16,0,0,0,0,1),
(3041010,17165,0,0,0,0,1),
(3041010,17768,0,0,0,0,1),
(3041010,17863,0,0,0,0,1),
(3041010,17880,0,0,0,0,1),
(3041010,17966,0,0,0,0,1),
(3041011,97738,0,0,1,0,0),
(3041011,97230,0,0,1,0,0),
(3041011,88121,0,0,4,0,0),
(3041011,97743,1,0,0,0,0),
(3041011,16,0,0,0,0,1),
(3041011,17165,0,0,0,0,1),
(3041011,17768,0,0,0,0,1),
(3041011,17863,0,0,0,0,1),
(3041011,17880,0,0,0,0,1),
(3041011,17966,0,0,0,0,1),
(3041012,97228,0,0,1,0,0),
(3041012,97234,0,0,1,0,0),
(3041012,10468,0,0,1,0,0),
(3041012,97733,1,0,0,0,0),
(3041012,17,0,0,0,0,1),
(3041013,97733,0,0,1,0,0),
(3041013,22075,0,0,1,0,0),
(3041013,97734,1,0,0,0,0),
(3041013,17,0,0,0,0,1),
(3041014,97734,0,0,1,0,0),
(3041014,97229,0,0,2,0,0),
(3041014,88121,0,0,1,0,0),
(3041014,97732,1,0,0,0,0),
(3041014,17,0,0,0,0,1),
(3041015,97228,0,0,1,0,0),
(3041015,97230,0,0,1,0,0),
(3041015,51850,0,0,8,0,0),
(3041015,97737,1,0,0,0,0),
(3041015,21,0,0,0,0,1),
(3041016,97194,0,0,1,0,0),
(3041016,97753,0,0,1,0,0),
(3041016,97737,0,0,1,0,0),
(3041016,97746,1,0,0,0,0),
(3041016,21,0,0,0,0,1),
(3041017,29355,0,0,1,0,0),
(3041017,16908,0,0,1,0,0),
(3041017,97746,0,0,1,0,0),
(3041017,97736,1,0,0,0,0),
(3041017,22,0,0,0,0,1),
(3041018,97237,0,0,6,0,0),
(3041018,97731,1,0,0,0,0),
(3041018,18,0,0,0,0,1),
(3041018,17189,0,0,0,0,1),
(3041018,17762,0,0,0,0,1),
(3041018,17910,0,0,0,0,1),
(3041019,97228,0,0,1,0,0),
(3041019,97235,0,0,2,0,0),
(3041019,97741,1,0,0,0,0),
(3041019,20,0,0,0,0,1),
(3041019,17187,0,0,0,0,1),
(3041019,17764,0,0,0,0,1),
(3041019,17912,0,0,0,0,1),
(3041019,62480,0,0,0,0,1),
(3041020,97731,0,0,1,0,0),
(3041020,97229,0,0,4,0,0),
(3041020,97741,0,0,1,0,0),
(3041020,97729,1,0,0,0,0),
(3041020,18,0,0,0,0,1),
(3041020,17189,0,0,0,0,1),
(3041020,17762,0,0,0,0,1),
(3041020,17910,0,0,0,0,1),
(3041021,97728,0,0,1,0,0),
(3041021,97747,0,0,1,0,0),
(3041021,97732,0,0,1,0,0),
(3041021,97739,0,0,1,0,0),
(3041021,97743,0,0,1,0,0),
(3041021,97744,0,0,1,0,0),
(3041021,97730,1,0,0,0,0),
(3041021,97729,0,0,0,0,1),
(3041022,13041,0,0,8,0,0),
(3041022,88117,1,0,0,0,0),
(3041022,16,0,0,0,0,1),
(3041022,17165,0,0,0,0,1),
(3041022,17768,0,0,0,0,1),
(3041022,17863,0,0,0,0,1),
(3041022,17880,0,0,0,0,1),
(3041022,17966,0,0,0,0,1),
(3041023,88113,0,0,1,0,0),
(3041023,88117,0,0,3,0,0),
(3041023,88118,1,0,0,0,0),
(3041023,16,0,0,0,0,1),
(3041023,17165,0,0,0,0,1),
(3041023,17768,0,0,0,0,1),
(3041023,17863,0,0,0,0,1),
(3041023,17880,0,0,0,0,1),
(3041023,17966,0,0,0,0,1),
(3041024,10064,1,1,1,0,0),
(3041024,88114,0,0,1,0,0),
(3041024,88146,1,0,0,0,0),
(3041024,16,0,0,0,0,1),
(3041024,17165,0,0,0,0,1),
(3041024,17768,0,0,0,0,1),
(3041024,17863,0,0,0,0,1),
(3041024,17880,0,0,0,0,1),
(3041024,17966,0,0,0,0,1),
(3041025,10064,1,1,1,0,0),
(3041025,97229,0,0,1,0,0),
(3041025,88147,1,0,0,0,0),
(3041025,16,0,0,0,0,1),
(3041025,17165,0,0,0,0,1),
(3041025,17768,0,0,0,0,1),
(3041025,17863,0,0,0,0,1),
(3041025,17880,0,0,0,0,1),
(3041025,17966,0,0,0,0,1),
(3041026,88147,0,0,5,0,0),
(3041026,88117,0,0,1,0,0),
(3041026,88146,0,0,4,0,0),
(3041026,88148,1,0,0,0,0),
(3041026,16,0,0,0,0,1),
(3041026,17966,0,0,0,0,1),
(3041027,12089,0,0,1,0,0),
(3041027,88118,0,0,1,0,0),
(3041027,88148,0,0,1,0,0),
(3041027,88115,0,0,1,0,0),
(3041027,88112,1,0,0,0,0),
(3041027,16,0,0,0,0,1),
(3041027,17165,0,0,0,0,1),
(3041027,17768,0,0,0,0,1),
(3041027,17863,0,0,0,0,1),
(3041027,17880,0,0,0,0,1),
(3041027,17966,0,0,0,0,1);
COMMIT;

-- ---- mesa-remaining/sql/040-tasks.sql ----
-- RESEARCHED disabled candidate for36quests. Complete spawn/scene closure before enabling.
SET NAMES utf8mb4;
SET SESSION check_constraint_checks=1;
DROP TEMPORARY TABLE IF EXISTS _mesa_remaining_guard;
CREATE TEMPORARY TABLE _mesa_remaining_guard(label VARCHAR(100)PRIMARY KEY,ok TINYINT NOT NULL,CHECK(ok=1))ENGINE=InnoDB;
INSERT INTO _mesa_remaining_guard VALUES('review',(COALESCE(@mesa_remaining_tasks_reviewed,0)=1));
INSERT INTO _mesa_remaining_guard VALUES('task_identity',(NOT EXISTS(SELECT 1 FROM tasks WHERE id IN(3040421,3040422,3040423,3040424,3040425,3040426,3040427,3040428,3040429,3040430,3040431,3040432,3040433,3040434,3040435,3040436,3040437,3040438,3040439,3040440,3040441,3040442,3040443,3040444,3040445,3040446,3040447,3040448,3040449,3040450,3040451,3040452,3040453,3040454,3040455,3040456) AND NOT((id=3040421 AND type=2 AND title='Wolf Skins for Madu') OR (id=3040422 AND type=2 AND title='Bear Pelts for Madu') OR (id=3040423 AND type=2 AND title='Snake Skins for Madu') OR (id=3040424 AND type=2 AND title='Spider Silk for Madu') OR (id=3040425 AND type=2 AND title='Madu Needs More Supplies') OR (id=3040426 AND type=2 AND title='Kill Fantoma') OR (id=3040427 AND type=2 AND title='Kill Ursalua') OR (id=3040428 AND type=2 AND title='Pluck It!') OR (id=3040429 AND type=2 AND title='Harpy Horrors') OR (id=3040430 AND type=2 AND title='Vermin Elimination') OR (id=3040431 AND type=2 AND title='Birds of a Feather') OR (id=3040432 AND type=2 AND title='Harping on Harpies') OR (id=3040433 AND type=2 AND title='Dromrek Must Die') OR (id=3040434 AND type=2 AND title='Cleanse Serpent''s Falls') OR (id=3040435 AND type=2 AND title='Tudor''s Beer') OR (id=3040436 AND type=2 AND title='Tudor''s Ale') OR (id=3040437 AND type=2 AND title='Tudor''s Wine') OR (id=3040438 AND type=2 AND title='Tudor''s Spirits') OR (id=3040439 AND type=2 AND title='Ciodaru''s Love') OR (id=3040440 AND type=2 AND title='Ciodaru''s First Gift') OR (id=3040441 AND type=2 AND title='Ciodaru''s Second Gift') OR (id=3040442 AND type=2 AND title='Protect Kathryn') OR (id=3040443 AND type=2 AND title='Ciodaru''s Third Gift') OR (id=3040444 AND type=2 AND title='Ciodaru''s Fourth Gift') OR (id=3040445 AND type=2 AND title='Protect Kathryn Again') OR (id=3040446 AND type=2 AND title='Ciodaru''s Fifth Gift') OR (id=3040447 AND type=2 AND title='Ciodaru''s Sixth Gift') OR (id=3040448 AND type=2 AND title='Protect Kathryn Some More') OR (id=3040449 AND type=2 AND title='Who Wants to Kill Kathryn?') OR (id=3040450 AND type=2 AND title='Ciodaru''s Gift Box') OR (id=3040451 AND type=2 AND title='Dorina''s Love') OR (id=3040452 AND type=2 AND title='Dorina''s Love Letter') OR (id=3040453 AND type=2 AND title='Dorina''s Gift') OR (id=3040454 AND type=2 AND title='Dorina''s Personalized Gift') OR (id=3040455 AND type=2 AND title='Dorina''s Potion') OR (id=3040456 AND type=2 AND title='Dorina''s Lament')))));
INSERT INTO _mesa_remaining_guard VALUES('component_identity',((SELECT COUNT(*)FROM achievement_components WHERE component_type=1 AND((achievement_id=500040600 AND component_id=50143 AND sequence=1 AND name='Scout Madu - Wolf Skins for Madu') OR (achievement_id=500040600 AND component_id=50144 AND sequence=2 AND name='Scout Madu - Bear Pelts for Madu') OR (achievement_id=500040600 AND component_id=50145 AND sequence=3 AND name='Scout Madu - Snake Skins for Madu') OR (achievement_id=500040600 AND component_id=50146 AND sequence=4 AND name='Scout Madu - Spider Silk for Madu') OR (achievement_id=500040600 AND component_id=50147 AND sequence=5 AND name='Scout Madu - Madu Needs More Supplies') OR (achievement_id=500040600 AND component_id=50148 AND sequence=6 AND name='Scout Madu - Kill Fantoma') OR (achievement_id=500040600 AND component_id=50149 AND sequence=7 AND name='Scout Madu - Kill Ursalua') OR (achievement_id=500040400 AND component_id=50126 AND sequence=1 AND name='Marilena - Pluck It!') OR (achievement_id=500040400 AND component_id=50127 AND sequence=2 AND name='Marilena - Harpy Horrors') OR (achievement_id=500040400 AND component_id=50132 AND sequence=7 AND name='Laurentiu - Vermin Elimination') OR (achievement_id=500040400 AND component_id=50133 AND sequence=8 AND name='Laurentiu - Birds of a Feather') OR (achievement_id=500040400 AND component_id=50134 AND sequence=9 AND name='Laurentiu - Harping on Harpies') OR (achievement_id=500040400 AND component_id=50135 AND sequence=10 AND name='Laurentiu - Dromrek Must Die') OR (achievement_id=500040400 AND component_id=50136 AND sequence=11 AND name='Laurentiu - Cleanse Serpent''s Falls') OR (achievement_id=500040400 AND component_id=50128 AND sequence=3 AND name='Tudor - Tudor''s Beer') OR (achievement_id=500040400 AND component_id=50129 AND sequence=4 AND name='Tudor - Tudor''s Ale') OR (achievement_id=500040400 AND component_id=50130 AND sequence=5 AND name='Tudor - Tudor''s Wine') OR (achievement_id=500040400 AND component_id=50131 AND sequence=6 AND name='Tudor - Tudor''s Spirits') OR (achievement_id=500040700 AND component_id=50150 AND sequence=1 AND name='Ciodaru - Ciodaru''s Love') OR (achievement_id=500040700 AND component_id=50151 AND sequence=2 AND name='Ciodaru - Ciodaru''s First Gift') OR (achievement_id=500040700 AND component_id=50152 AND sequence=3 AND name='Ciodaru - Ciodaru''s Second Gift') OR (achievement_id=500040700 AND component_id=50153 AND sequence=4 AND name='Ciodaru - Protect Kathryn') OR (achievement_id=500040700 AND component_id=50154 AND sequence=5 AND name='Ciodaru - Ciodaru''s Third Gift') OR (achievement_id=500040700 AND component_id=50155 AND sequence=6 AND name='Ciodaru - Ciodaru''s Fourth Gift') OR (achievement_id=500040700 AND component_id=50156 AND sequence=7 AND name='Ciodaru - Protect Kathryn Again') OR (achievement_id=500040700 AND component_id=50157 AND sequence=8 AND name='Ciodaru - Ciodaru''s Fifth Gift') OR (achievement_id=500040700 AND component_id=50158 AND sequence=9 AND name='Ciodaru - Ciodaru''s Sixth Gift') OR (achievement_id=500040700 AND component_id=50159 AND sequence=10 AND name='Ciodaru - Protect Kathryn Some More') OR (achievement_id=500040700 AND component_id=50160 AND sequence=11 AND name='Ciodaru - Who Wants to Kill Kathryn?') OR (achievement_id=500040700 AND component_id=50161 AND sequence=12 AND name='Ciodaru - Ciodaru''s Gift Box') OR (achievement_id=500040500 AND component_id=50137 AND sequence=1 AND name='Dorina - Dorina''s Love') OR (achievement_id=500040500 AND component_id=50138 AND sequence=2 AND name='Dorina - Dorina''s Love Letter') OR (achievement_id=500040500 AND component_id=50139 AND sequence=3 AND name='Dorina - Dorina''s Gift') OR (achievement_id=500040500 AND component_id=50140 AND sequence=4 AND name='Dorina - Dorina''s Personalized Gift') OR (achievement_id=500040500 AND component_id=50141 AND sequence=5 AND name='Dorina - Dorina''s Potion') OR (achievement_id=500040500 AND component_id=50142 AND sequence=6 AND name='Dorina - Dorina''s Lament')))=36));
INSERT INTO _mesa_remaining_guard VALUES('item_identity',((SELECT COUNT(*)FROM items WHERE (id=9650 AND Name='Celestial Essence' AND classes=65535) OR (id=10029 AND Name='Emerald' AND classes=65535) OR (id=10300 AND Name='Lightstone' AND classes=65535) OR (id=10468 AND Name='Small Brick of High Quality Ore' AND classes=65535) OR (id=13006 AND Name='Water Flask' AND classes=65535) OR (id=13041 AND Name='Spider Silk' AND classes=65535) OR (id=13067 AND Name='Snake Fang' AND classes=65535) OR (id=13088 AND Name='Snake Egg' AND classes=65535) OR (id=13099 AND Name='Spiderling Silk' AND classes=65535) OR (id=13417 AND Name='Spider Legs' AND classes=65535) OR (id=13425 AND Name='Spices' AND classes=65535) OR (id=13750 AND Name='Low Quality Bear Skin' AND classes=65535) OR (id=13751 AND Name='Medium Quality Bear Skin' AND classes=65535) OR (id=13752 AND Name='High Quality Bear Skin' AND classes=65535) OR (id=13753 AND Name='Low Quality Wolf Skin' AND classes=65535) OR (id=13754 AND Name='Medium Quality Wolf Skin' AND classes=65535) OR (id=13755 AND Name='High Quality Wolf Skin' AND classes=65535) OR (id=16482 AND Name='Silk Swatch' AND classes=65535) OR (id=16486 AND Name='Silk Thread' AND classes=65535) OR (id=16590 AND Name='Barley' AND classes=65535) OR (id=16591 AND Name='Hops' AND classes=65535) OR (id=16595 AND Name='Malt' AND classes=65535) OR (id=16598 AND Name='Bottle' AND classes=65535) OR (id=16908 AND Name='High Quality Firing Sheet' AND classes=65535) OR (id=22075 AND Name='Thin Blade Mold' AND classes=65535) OR (id=22104 AND Name='Dark Green Dye' AND classes=65535) OR (id=29355 AND Name='Glaze Lacquer' AND classes=65535) OR (id=29742 AND Name='Butter' AND classes=65535) OR (id=51850 AND Name='Spider Fang' AND classes=65535) OR (id=53121 AND Name='Iron Forged Plate Helm' AND classes=1) OR (id=53122 AND Name='Iron Forged Plate Vambraces' AND classes=1) OR (id=53123 AND Name='Iron Forged Plate Bracer' AND classes=1) OR (id=53124 AND Name='Iron Forged Plate Gauntlets' AND classes=1) OR (id=53125 AND Name='Iron Forged Plate Boots' AND classes=1) OR (id=53126 AND Name='Iron Forged Plate Breastplate' AND classes=1) OR (id=53127 AND Name='Iron Forged Plate Greaves' AND classes=1) OR (id=53128 AND Name='Fire Sanctified Plate Helm' AND classes=2) OR (id=53129 AND Name='Fire Sanctified Plate Vambraces' AND classes=2) OR (id=53130 AND Name='Fire Sanctified Plate Bracer' AND classes=2) OR (id=53131 AND Name='Fire Sanctified Plate Gauntlets' AND classes=2) OR (id=53132 AND Name='Fire Sanctified Plate Boots' AND classes=2) OR (id=53133 AND Name='Fire Sanctified Plate Breastplate' AND classes=2) OR (id=53134 AND Name='Fire Sanctified Plate Greaves' AND classes=2) OR (id=53135 AND Name='Maiden Blessed Plate Helm' AND classes=4) OR (id=53136 AND Name='Maiden Blessed Plate Vambraces' AND classes=4) OR (id=53137 AND Name='Maiden Blessed Plate Bracer' AND classes=4) OR (id=53138 AND Name='Maiden Blessed Plate Gauntlets' AND classes=4) OR (id=53139 AND Name='Maiden Blessed Plate Boots' AND classes=4) OR (id=53140 AND Name='Maiden Blessed Plate Breastplate' AND classes=4) OR (id=53141 AND Name='Maiden Blessed Plate Greaves' AND classes=4) OR (id=53142 AND Name='Thorn Bonded Chain Coif' AND classes=8) OR (id=53143 AND Name='Thorn Bonded Chain Sleeves' AND classes=8) OR (id=53144 AND Name='Thorn Bonded Chain Wristguard' AND classes=8) OR (id=53145 AND Name='Thorn Bonded Chain Gauntlets' AND classes=8) OR (id=53146 AND Name='Thorn Bonded Chain Boots' AND classes=8) OR (id=53147 AND Name='Thorn Bonded Chain Coat' AND classes=8) OR (id=53148 AND Name='Thorn Bonded Chain Leggings' AND classes=8) OR (id=53149 AND Name='Swamp Dredged Plate Helm' AND classes=16) OR (id=53150 AND Name='Swamp Dredged Plate Vambraces' AND classes=16) OR (id=53151 AND Name='Swamp Dredged Plate Bracer' AND classes=16) OR (id=53152 AND Name='Swamp Dredged Plate Gauntlets' AND classes=16) OR (id=53153 AND Name='Swamp Dredged Plate Boots' AND classes=16) OR (id=53154 AND Name='Swamp Dredged Plate Breastplate' AND classes=16) OR (id=53155 AND Name='Swamp Dredged Plate Greaves' AND classes=16) OR (id=53156 AND Name='Vine Imprinted Leather Cowl' AND classes=32) OR (id=53157 AND Name='Vine Imprinted Leather Armwraps' AND classes=32) OR (id=53158 AND Name='Vine Imprinted Leather Wristguard' AND classes=32) OR (id=53159 AND Name='Vine Imprinted Leather Gloves' AND classes=32) OR (id=53160 AND Name='Vine Imprinted Leather Boots' AND classes=32) OR (id=53161 AND Name='Vine Imprinted Leather Tunic' AND classes=32) OR (id=53162 AND Name='Vine Imprinted Leather Leggings' AND classes=32) OR (id=53163 AND Name='Stone Formed Leather Cowl' AND classes=64) OR (id=53164 AND Name='Stone Formed Leather Armwraps' AND classes=64) OR (id=53165 AND Name='Stone Formed Leather Wristguard' AND classes=64) OR (id=53166 AND Name='Stone Formed Leather Gloves' AND classes=64) OR (id=53167 AND Name='Stone Formed Leather Boots' AND classes=64) OR (id=53168 AND Name='Stone Formed Leather Tunic' AND classes=64) OR (id=53169 AND Name='Stone Formed Leather Leggings' AND classes=64) OR (id=53170 AND Name='Steel Toned Plate Helm' AND classes=128) OR (id=53171 AND Name='Steel Toned Plate Vambraces' AND classes=128) OR (id=53172 AND Name='Steel Toned Plate Bracer' AND classes=128) OR (id=53173 AND Name='Steel Toned Plate Gauntlets' AND classes=128) OR (id=53174 AND Name='Steel Toned Plate Boots' AND classes=128) OR (id=53175 AND Name='Steel Toned Plate Breastplate' AND classes=128) OR (id=53176 AND Name='Steel Toned Plate Greaves' AND classes=128) OR (id=53177 AND Name='Blood Blackened Chain Coif' AND classes=256) OR (id=53178 AND Name='Blood Blackened Chain Sleeves' AND classes=256) OR (id=53179 AND Name='Blood Blackened Chain Wristguard' AND classes=256) OR (id=53180 AND Name='Blood Blackened Chain Gauntlets' AND classes=256) OR (id=53181 AND Name='Blood Blackened Chain Boots' AND classes=256) OR (id=53182 AND Name='Blood Blackened Chain Coat' AND classes=256) OR (id=53183 AND Name='Blood Blackened Chain Leggings' AND classes=256) OR (id=53184 AND Name='Ritual Embossed Chain Coif' AND classes=512) OR (id=53185 AND Name='Ritual Embossed Chain Sleeves' AND classes=512) OR (id=53186 AND Name='Ritual Embossed Chain Wristguard' AND classes=512) OR (id=53187 AND Name='Ritual Embossed Chain Gauntlets' AND classes=512) OR (id=53188 AND Name='Ritual Embossed Chain Boots' AND classes=512) OR (id=53189 AND Name='Ritual Embossed Chain Coat' AND classes=512) OR (id=53190 AND Name='Ritual Embossed Chain Leggings' AND classes=512) OR (id=53191 AND Name='Bone Twisted Cloth Cap' AND classes=1024) OR (id=53192 AND Name='Bone Twisted Cloth Sleeves' AND classes=1024) OR (id=53193 AND Name='Bone Twisted Cloth Wristband' AND classes=1024) OR (id=53194 AND Name='Bone Twisted Cloth Gloves' AND classes=1024) OR (id=53195 AND Name='Bone Twisted Cloth Sandals' AND classes=1024) OR (id=53196 AND Name='Bone Twisted Cloth Robe' AND classes=1024) OR (id=53197 AND Name='Bone Twisted Cloth Pants' AND classes=1024) OR (id=53198 AND Name='Ice Woven Cloth Cap' AND classes=2048) OR (id=53199 AND Name='Ice Woven Cloth Sleeves' AND classes=2048) OR (id=53200 AND Name='Ice Woven Cloth Wristband' AND classes=2048) OR (id=53201 AND Name='Ice Woven Cloth Gloves' AND classes=2048) OR (id=53202 AND Name='Ice Woven Cloth Sandals' AND classes=2048) OR (id=53203 AND Name='Ice Woven Cloth Robe' AND classes=2048) OR (id=53204 AND Name='Ice Woven Cloth Pants' AND classes=2048) OR (id=53205 AND Name='Earth Melded Cloth Cap' AND classes=4096) OR (id=53206 AND Name='Earth Melded Cloth Sleeves' AND classes=4096) OR (id=53207 AND Name='Earth Melded Cloth Wristband' AND classes=4096) OR (id=53208 AND Name='Earth Melded Cloth Gloves' AND classes=4096) OR (id=53209 AND Name='Earth Melded Cloth Sandals' AND classes=4096) OR (id=53210 AND Name='Earth Melded Cloth Robe' AND classes=4096) OR (id=53211 AND Name='Earth Melded Cloth Pants' AND classes=4096) OR (id=53212 AND Name='Rune Tailored Cloth Cap' AND classes=8192) OR (id=53213 AND Name='Rune Tailored Cloth Sleeves' AND classes=8192) OR (id=53214 AND Name='Rune Tailored Cloth Wristband' AND classes=8192) OR (id=53215 AND Name='Rune Tailored Cloth Gloves' AND classes=8192) OR (id=53216 AND Name='Rune Tailored Cloth Sandals' AND classes=8192) OR (id=53217 AND Name='Rune Tailored Cloth Robe' AND classes=8192) OR (id=53218 AND Name='Rune Tailored Cloth Pants' AND classes=8192) OR (id=53219 AND Name='Savage Runic Leather Cowl' AND classes=16384) OR (id=53220 AND Name='Savage Runic Leather Armwraps' AND classes=16384) OR (id=53221 AND Name='Savage Runic Leather Wristguard' AND classes=16384) OR (id=53222 AND Name='Savage Runic Leather Gloves' AND classes=16384) OR (id=53223 AND Name='Savage Runic Leather Boots' AND classes=16384) OR (id=53224 AND Name='Savage Runic Leather Tunic' AND classes=16384) OR (id=53225 AND Name='Savage Runic Leather Leggings' AND classes=16384) OR (id=53226 AND Name='Blade Notched Chain Coif' AND classes=32768) OR (id=53227 AND Name='Blade Notched Chain Sleeves' AND classes=32768) OR (id=53228 AND Name='Blade Notched Chain Wristguard' AND classes=32768) OR (id=53229 AND Name='Blade Notched Chain Gauntlets' AND classes=32768) OR (id=53230 AND Name='Blade Notched Chain Boots' AND classes=32768) OR (id=53231 AND Name='Blade Notched Chain Coat' AND classes=32768) OR (id=53232 AND Name='Blade Notched Chain Leggings' AND classes=32768) OR (id=53559 AND Name='Dryad Tender Bauble' AND classes=65535) OR (id=53560 AND Name='Dryad Focusing Bauble' AND classes=65535) OR (id=53561 AND Name='Dryad Protector Bauble' AND classes=65535) OR (id=53562 AND Name='Dryad Maiden Bauble' AND classes=65535) OR (id=57015 AND Name='Sleek Griffon Feather' AND classes=65535) OR (id=57016 AND Name='Harpy Plume' AND classes=65535) OR (id=58280 AND Name='Garlic' AND classes=65535) OR (id=87151 AND Name='Fresh Mesa Streamwater' AND classes=65535) OR (id=87154 AND Name='Indigenous Mesa Yeast' AND classes=65535) OR (id=87157 AND Name='Worn Cask' AND classes=65535) OR (id=87158 AND Name='Rawhide Canteen' AND classes=65535) OR (id=87161 AND Name='Griffon Feather Spores' AND classes=65535) OR (id=87162 AND Name='Dromrek Barbera Grapes' AND classes=65535) OR (id=87163 AND Name='Tanglewood Seed Pod' AND classes=65535) OR (id=87164 AND Name='Lingering Dryad Skull' AND classes=65535) OR (id=87165 AND Name='Goru`kar Oakwood Barrel' AND classes=65535) OR (id=87166 AND Name='Flask of Mesa Stormwater' AND classes=65535) OR (id=87167 AND Name='Liviu''s Dark Stout' AND classes=65535) OR (id=87168 AND Name='Liviu''s Finest Brew' AND classes=65535) OR (id=87169 AND Name='Tudor''s Aged Merlot' AND classes=65535) OR (id=87170 AND Name='Tudor''s Stormwater Whiskey' AND classes=65535) OR (id=88110 AND Name='Letter to Simu' AND classes=0) OR (id=88112 AND Name='Folded Silkfang Pack' AND classes=65535) OR (id=88113 AND Name='Recluse Spider Fang' AND classes=65535) OR (id=88114 AND Name='Wolf Canine' AND classes=65535) OR (id=88115 AND Name='Supple Wolf Pelt' AND classes=65535) OR (id=88117 AND Name='Spider Silk Thread' AND classes=65535) OR (id=88118 AND Name='Spool of Spider Silk Thread' AND classes=65535) OR (id=88119 AND Name='Bear Heart' AND classes=65535) OR (id=88120 AND Name='Spider Brain' AND classes=65535) OR (id=88121 AND Name='Snake Skin' AND classes=65535) OR (id=88122 AND Name='Blood-soaked Patch of Fur' AND classes=65535) OR (id=88123 AND Name='Philter of Anamorata' AND classes=65535) OR (id=88124 AND Name='Honeycomb' AND classes=65535) OR (id=88125 AND Name='Cultivated Jumjum Pollen' AND classes=65535) OR (id=88126 AND Name='Soporific Honey' AND classes=65535) OR (id=88127 AND Name='Fantoma''s Pelt' AND classes=65535) OR (id=88128 AND Name='Ursalua''s Pelt' AND classes=65535) OR (id=88146 AND Name='Wolf Canine Bead' AND classes=65535) OR (id=88147 AND Name='Snake Fang Bead' AND classes=65535) OR (id=88148 AND Name='String of Teeth' AND classes=65535) OR (id=97194 AND Name='Faceted Lightstone' AND classes=65535) OR (id=97228 AND Name='Earthen Ooze Slime' AND classes=65535) OR (id=97229 AND Name='Large Snake Fang' AND classes=65535) OR (id=97230 AND Name='Mesa Recluse Spinneret' AND classes=65535) OR (id=97231 AND Name='Section of Mesa Snake Pancreas' AND classes=65535) OR (id=97233 AND Name='Raw Silver' AND classes=65535) OR (id=97234 AND Name='Recluse Venom Sac' AND classes=65535) OR (id=97235 AND Name='Spider Eye' AND classes=65535) OR (id=97236 AND Name='Windwillow Acorn' AND classes=65535) OR (id=97237 AND Name='Windwillow Branch' AND classes=65535) OR (id=97238 AND Name='Note from Razvan' AND classes=0) OR (id=97728 AND Name='Chilled Pure Water' AND classes=65535) OR (id=97729 AND Name='Ciodaru''s Gift Box' AND classes=65535) OR (id=97730 AND Name='Ciodaru''s Gift Box' AND classes=0) OR (id=97731 AND Name='Ciodaru''s Gift Box Parts' AND classes=65535) OR (id=97732 AND Name='Envenomed Athame' AND classes=65535) OR (id=97733 AND Name='Envenomed Steel' AND classes=65535) OR (id=97734 AND Name='Envenomed Steel Blade' AND classes=65535) OR (id=97735 AND Name='Everchilled Flask' AND classes=0) OR (id=97736 AND Name='Fine Green Perfume Bottle' AND classes=0) OR (id=97737 AND Name='Fine White Clay' AND classes=65535) OR (id=97738 AND Name='Forest Green Silk Swatch' AND classes=65535) OR (id=97739 AND Name='Glowing Emerald Pendant' AND classes=65535) OR (id=97740 AND Name='Glowing Green Silver' AND classes=65535) OR (id=97741 AND Name='Petrified Spider Eyes' AND classes=65535) OR (id=97742 AND Name='Pond Water' AND classes=65535) OR (id=97743 AND Name='Shimmering Dryad Dress' AND classes=65535) OR (id=97744 AND Name='Spiced Wind Willow Acorns' AND classes=65535) OR (id=97745 AND Name='Spider Silk Filter' AND classes=65535) OR (id=97746 AND Name='Unfired Fine Green Perfume Bottle' AND classes=65535))=212));
INSERT INTO _mesa_remaining_guard VALUES('npc_identity',((SELECT COUNT(*)FROM npc_types WHERE (id=394060 AND name='Potter_Subira') OR (id=394066 AND name='Smith_Yahya') OR (id=394083 AND name='Tailor_Panya') OR (id=394115 AND name='Jeweler_Nailah') OR (id=394146 AND name='Brewmaster_Ishaq') OR (id=394155 AND name='Fletcher_Tahirah') OR (id=394168 AND name='Cook_Kosey') OR (id=394228 AND name='Alchemist_Naeema') OR (id=395210 AND name='Scout_Ethaniel') OR (id=397001 AND name='a_mesa_wolf') OR (id=397002 AND name='a_mesa_wolf') OR (id=397003 AND name='a_mesa_snake') OR (id=397004 AND name='a_mesa_wolf') OR (id=397005 AND name='a_mesa_bear') OR (id=397007 AND name='Scout_Madu') OR (id=397008 AND name='a_mesa_snake') OR (id=397010 AND name='a_mesa_snake') OR (id=397015 AND name='a_mesa_bear') OR (id=397016 AND name='a_diamondback_snake') OR (id=397017 AND name='a_diamondback_snake') OR (id=397018 AND name='a_diamondback_snake') OR (id=397020 AND name='a_mesa_bear') OR (id=397035 AND name='a_mesa_alpha_wolf') OR (id=397043 AND name='Marilena') OR (id=397073 AND name='#Ursalua') OR (id=397078 AND name='#Razvan') OR (id=397086 AND name='Dorina') OR (id=397089 AND name='a_mesa_recluse') OR (id=397096 AND name='Tudor') OR (id=397097 AND name='Laurentiu') OR (id=397100 AND name='Kathryn') OR (id=397118 AND name='Ciodaru') OR (id=397120 AND name='Simu') OR (id=397133 AND name='a_large_mesa_recluse') OR (id=397135 AND name='a_mesa_recluse') OR (id=397141 AND name='a_mesa_recluse') OR (id=397144 AND name='an_earthen_ooze') OR (id=397154 AND name='an_earthen_ooze') OR (id=397155 AND name='a_Dromrek_basher') OR (id=397156 AND name='an_earthen_ooze') OR (id=397163 AND name='a_Dromrek_basher') OR (id=397164 AND name='a_Dromrek_hunter') OR (id=397166 AND name='an_earthen_ooze') OR (id=397167 AND name='a_Dromrek_basher') OR (id=397171 AND name='a_Dromrek_hunter') OR (id=397175 AND name='a_Dromrek_shaman') OR (id=397177 AND name='a_Dromrek_shaman') OR (id=397187 AND name='a_Dromrek_hunter') OR (id=397189 AND name='a_Dromrek_shaman') OR (id=397190 AND name='a_Dromrek_hunter') OR (id=397194 AND name='a_Dromrek_shaman') OR (id=397197 AND name='a_Dromrek_hunter') OR (id=397198 AND name='a_Dromrek_hunter') OR (id=397209 AND name='a_Dromrek_shaman') OR (id=397217 AND name='a_Dromrek_basher') OR (id=397223 AND name='a_Dromrek_basher') OR (id=397233 AND name='a_potameid_noble') OR (id=397236 AND name='a_potameid_protector') OR (id=397237 AND name='a_potameid_noble') OR (id=397238 AND name='a_potameid_protector') OR (id=397240 AND name='a_potameid_retainer') OR (id=397241 AND name='a_griffon_bloodtalon') OR (id=397242 AND name='a_potameid_retainer') OR (id=397244 AND name='a_potameid_retainer') OR (id=397245 AND name='a_young_griffon') OR (id=397248 AND name='a_harpy_hunter') OR (id=397249 AND name='a_Dromrek_basher') OR (id=397252 AND name='a_harpy_songstress') OR (id=397254 AND name='a_harpy_hunter') OR (id=397256 AND name='a_harpy_griffonmaster_') OR (id=397257 AND name='a_harpy_songstress') OR (id=397258 AND name='a_potameid_retainer') OR (id=397260 AND name='a_harpy_raider') OR (id=397261 AND name='a_young_griffon') OR (id=397262 AND name='a_potameid_protector') OR (id=397264 AND name='a_harpy_griffonmaster_') OR (id=397266 AND name='a_griffon_bloodtalon') OR (id=397267 AND name='a_young_griffon') OR (id=397269 AND name='a_harpy_raider') OR (id=397270 AND name='a_harpy_griffonmaster_') OR (id=397271 AND name='a_harpy_hunter') OR (id=397273 AND name='a_harpy_watcher') OR (id=397274 AND name='a_harpy_watcher') OR (id=397901 AND name='a_Tuffein_thug') OR (id=397902 AND name='a_Tuffein_grabber') OR (id=397904 AND name='Fantoma'))=86));
INSERT INTO _mesa_remaining_guard VALUES('criterion_50143',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500040600 AND component_type=1 AND component_id=50143 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040421 AND target_id2=0 AND target_value=0 AND component_sequence=1 AND required_count=1))));
INSERT INTO _mesa_remaining_guard VALUES('reward_set_3040421',(NOT EXISTS(SELECT 1 FROM reward_sets WHERE reward_set_id=3040421 AND title<>'Wolf Skins for Madu')AND NOT EXISTS(SELECT 1 FROM reward_sources WHERE reward_set_id=3040421 AND NOT(source_type=2 AND source_id=3040421))AND NOT EXISTS(SELECT 1 FROM reward_sources WHERE source_type=2 AND source_id=3040421 AND reward_set_id<>3040421)));
INSERT INTO _mesa_remaining_guard VALUES('option_ownership_3040421',(NOT EXISTS(SELECT 1 FROM reward_options WHERE reward_set_id=3040421 AND NOT((option_id=1 AND label='Experience' AND common_to_all=1 AND flags=0 AND class_mask=65535) OR (option_id=2 AND label='Iron Forged Plate Bracer' AND common_to_all=0 AND flags=0 AND class_mask=1) OR (option_id=3 AND label='Fire Sanctified Plate Bracer' AND common_to_all=0 AND flags=0 AND class_mask=2) OR (option_id=4 AND label='Maiden Blessed Plate Bracer' AND common_to_all=0 AND flags=0 AND class_mask=4) OR (option_id=5 AND label='Thorn Bonded Chain Wristguard' AND common_to_all=0 AND flags=0 AND class_mask=8) OR (option_id=6 AND label='Swamp Dredged Plate Bracer' AND common_to_all=0 AND flags=0 AND class_mask=16) OR (option_id=7 AND label='Vine Imprinted Leather Wristguard' AND common_to_all=0 AND flags=0 AND class_mask=32) OR (option_id=8 AND label='Stone Formed Leather Wristguard' AND common_to_all=0 AND flags=0 AND class_mask=64) OR (option_id=9 AND label='Steel Toned Plate Bracer' AND common_to_all=0 AND flags=0 AND class_mask=128) OR (option_id=10 AND label='Blood Blackened Chain Wristguard' AND common_to_all=0 AND flags=0 AND class_mask=256) OR (option_id=11 AND label='Ritual Embossed Chain Wristguard' AND common_to_all=0 AND flags=0 AND class_mask=512) OR (option_id=12 AND label='Bone Twisted Cloth Wristband' AND common_to_all=0 AND flags=0 AND class_mask=1024) OR (option_id=13 AND label='Ice Woven Cloth Wristband' AND common_to_all=0 AND flags=0 AND class_mask=2048) OR (option_id=14 AND label='Earth Melded Cloth Wristband' AND common_to_all=0 AND flags=0 AND class_mask=4096) OR (option_id=15 AND label='Rune Tailored Cloth Wristband' AND common_to_all=0 AND flags=0 AND class_mask=8192) OR (option_id=16 AND label='Savage Runic Leather Wristguard' AND common_to_all=0 AND flags=0 AND class_mask=16384) OR (option_id=17 AND label='Blade Notched Chain Wristguard' AND common_to_all=0 AND flags=0 AND class_mask=32768)))));
INSERT INTO _mesa_remaining_guard VALUES('option_links_3040421',(NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_set_id=3040421 AND NOT((option_id=1 AND sequence=0 AND reward_id=304042101) OR (option_id=2 AND sequence=0 AND reward_id=304042102) OR (option_id=3 AND sequence=0 AND reward_id=304042103) OR (option_id=4 AND sequence=0 AND reward_id=304042104) OR (option_id=5 AND sequence=0 AND reward_id=304042105) OR (option_id=6 AND sequence=0 AND reward_id=304042106) OR (option_id=7 AND sequence=0 AND reward_id=304042107) OR (option_id=8 AND sequence=0 AND reward_id=304042108) OR (option_id=9 AND sequence=0 AND reward_id=304042109) OR (option_id=10 AND sequence=0 AND reward_id=304042110) OR (option_id=11 AND sequence=0 AND reward_id=304042111) OR (option_id=12 AND sequence=0 AND reward_id=304042112) OR (option_id=13 AND sequence=0 AND reward_id=304042113) OR (option_id=14 AND sequence=0 AND reward_id=304042114) OR (option_id=15 AND sequence=0 AND reward_id=304042115) OR (option_id=16 AND sequence=0 AND reward_id=304042116) OR (option_id=17 AND sequence=0 AND reward_id=304042117)))));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042101',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042101 AND description<>'May2013 Mesa remaining option 304042101')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042101 AND NOT(reward_set_id=3040421 AND option_id=1))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042101)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042102',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042102 AND description<>'May2013 Mesa remaining option 304042102')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042102 AND NOT(reward_set_id=3040421 AND option_id=2))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042102)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042103',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042103 AND description<>'May2013 Mesa remaining option 304042103')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042103 AND NOT(reward_set_id=3040421 AND option_id=3))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042103)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042104',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042104 AND description<>'May2013 Mesa remaining option 304042104')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042104 AND NOT(reward_set_id=3040421 AND option_id=4))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042104)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042105',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042105 AND description<>'May2013 Mesa remaining option 304042105')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042105 AND NOT(reward_set_id=3040421 AND option_id=5))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042105)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042106',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042106 AND description<>'May2013 Mesa remaining option 304042106')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042106 AND NOT(reward_set_id=3040421 AND option_id=6))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042106)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042107',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042107 AND description<>'May2013 Mesa remaining option 304042107')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042107 AND NOT(reward_set_id=3040421 AND option_id=7))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042107)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042108',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042108 AND description<>'May2013 Mesa remaining option 304042108')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042108 AND NOT(reward_set_id=3040421 AND option_id=8))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042108)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042109',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042109 AND description<>'May2013 Mesa remaining option 304042109')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042109 AND NOT(reward_set_id=3040421 AND option_id=9))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042109)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042110',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042110 AND description<>'May2013 Mesa remaining option 304042110')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042110 AND NOT(reward_set_id=3040421 AND option_id=10))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042110)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042111',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042111 AND description<>'May2013 Mesa remaining option 304042111')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042111 AND NOT(reward_set_id=3040421 AND option_id=11))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042111)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042112',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042112 AND description<>'May2013 Mesa remaining option 304042112')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042112 AND NOT(reward_set_id=3040421 AND option_id=12))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042112)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042113',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042113 AND description<>'May2013 Mesa remaining option 304042113')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042113 AND NOT(reward_set_id=3040421 AND option_id=13))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042113)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042114',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042114 AND description<>'May2013 Mesa remaining option 304042114')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042114 AND NOT(reward_set_id=3040421 AND option_id=14))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042114)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042115',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042115 AND description<>'May2013 Mesa remaining option 304042115')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042115 AND NOT(reward_set_id=3040421 AND option_id=15))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042115)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042116',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042116 AND description<>'May2013 Mesa remaining option 304042116')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042116 AND NOT(reward_set_id=3040421 AND option_id=16))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042116)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042117',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042117 AND description<>'May2013 Mesa remaining option 304042117')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042117 AND NOT(reward_set_id=3040421 AND option_id=17))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042117)));
INSERT INTO _mesa_remaining_guard VALUES('criterion_50144',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500040600 AND component_type=1 AND component_id=50144 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040422 AND target_id2=0 AND target_value=0 AND component_sequence=2 AND required_count=1))));
INSERT INTO _mesa_remaining_guard VALUES('reward_set_3040422',(NOT EXISTS(SELECT 1 FROM reward_sets WHERE reward_set_id=3040422 AND title<>'Bear Pelts for Madu')AND NOT EXISTS(SELECT 1 FROM reward_sources WHERE reward_set_id=3040422 AND NOT(source_type=2 AND source_id=3040422))AND NOT EXISTS(SELECT 1 FROM reward_sources WHERE source_type=2 AND source_id=3040422 AND reward_set_id<>3040422)));
INSERT INTO _mesa_remaining_guard VALUES('option_ownership_3040422',(NOT EXISTS(SELECT 1 FROM reward_options WHERE reward_set_id=3040422 AND NOT((option_id=1 AND label='Experience' AND common_to_all=1 AND flags=0 AND class_mask=65535) OR (option_id=2 AND label='Iron Forged Plate Boots' AND common_to_all=0 AND flags=0 AND class_mask=1) OR (option_id=3 AND label='Fire Sanctified Plate Boots' AND common_to_all=0 AND flags=0 AND class_mask=2) OR (option_id=4 AND label='Maiden Blessed Plate Boots' AND common_to_all=0 AND flags=0 AND class_mask=4) OR (option_id=5 AND label='Thorn Bonded Chain Boots' AND common_to_all=0 AND flags=0 AND class_mask=8) OR (option_id=6 AND label='Swamp Dredged Plate Boots' AND common_to_all=0 AND flags=0 AND class_mask=16) OR (option_id=7 AND label='Vine Imprinted Leather Boots' AND common_to_all=0 AND flags=0 AND class_mask=32) OR (option_id=8 AND label='Stone Formed Leather Boots' AND common_to_all=0 AND flags=0 AND class_mask=64) OR (option_id=9 AND label='Steel Toned Plate Boots' AND common_to_all=0 AND flags=0 AND class_mask=128) OR (option_id=10 AND label='Blood Blackened Chain Boots' AND common_to_all=0 AND flags=0 AND class_mask=256) OR (option_id=11 AND label='Ritual Embossed Chain Boots' AND common_to_all=0 AND flags=0 AND class_mask=512) OR (option_id=12 AND label='Bone Twisted Cloth Sandals' AND common_to_all=0 AND flags=0 AND class_mask=1024) OR (option_id=13 AND label='Ice Woven Cloth Sandals' AND common_to_all=0 AND flags=0 AND class_mask=2048) OR (option_id=14 AND label='Earth Melded Cloth Sandals' AND common_to_all=0 AND flags=0 AND class_mask=4096) OR (option_id=15 AND label='Rune Tailored Cloth Sandals' AND common_to_all=0 AND flags=0 AND class_mask=8192) OR (option_id=16 AND label='Savage Runic Leather Boots' AND common_to_all=0 AND flags=0 AND class_mask=16384) OR (option_id=17 AND label='Blade Notched Chain Boots' AND common_to_all=0 AND flags=0 AND class_mask=32768)))));
INSERT INTO _mesa_remaining_guard VALUES('option_links_3040422',(NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_set_id=3040422 AND NOT((option_id=1 AND sequence=0 AND reward_id=304042201) OR (option_id=2 AND sequence=0 AND reward_id=304042202) OR (option_id=3 AND sequence=0 AND reward_id=304042203) OR (option_id=4 AND sequence=0 AND reward_id=304042204) OR (option_id=5 AND sequence=0 AND reward_id=304042205) OR (option_id=6 AND sequence=0 AND reward_id=304042206) OR (option_id=7 AND sequence=0 AND reward_id=304042207) OR (option_id=8 AND sequence=0 AND reward_id=304042208) OR (option_id=9 AND sequence=0 AND reward_id=304042209) OR (option_id=10 AND sequence=0 AND reward_id=304042210) OR (option_id=11 AND sequence=0 AND reward_id=304042211) OR (option_id=12 AND sequence=0 AND reward_id=304042212) OR (option_id=13 AND sequence=0 AND reward_id=304042213) OR (option_id=14 AND sequence=0 AND reward_id=304042214) OR (option_id=15 AND sequence=0 AND reward_id=304042215) OR (option_id=16 AND sequence=0 AND reward_id=304042216) OR (option_id=17 AND sequence=0 AND reward_id=304042217)))));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042201',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042201 AND description<>'May2013 Mesa remaining option 304042201')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042201 AND NOT(reward_set_id=3040422 AND option_id=1))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042201)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042202',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042202 AND description<>'May2013 Mesa remaining option 304042202')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042202 AND NOT(reward_set_id=3040422 AND option_id=2))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042202)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042203',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042203 AND description<>'May2013 Mesa remaining option 304042203')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042203 AND NOT(reward_set_id=3040422 AND option_id=3))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042203)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042204',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042204 AND description<>'May2013 Mesa remaining option 304042204')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042204 AND NOT(reward_set_id=3040422 AND option_id=4))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042204)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042205',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042205 AND description<>'May2013 Mesa remaining option 304042205')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042205 AND NOT(reward_set_id=3040422 AND option_id=5))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042205)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042206',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042206 AND description<>'May2013 Mesa remaining option 304042206')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042206 AND NOT(reward_set_id=3040422 AND option_id=6))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042206)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042207',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042207 AND description<>'May2013 Mesa remaining option 304042207')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042207 AND NOT(reward_set_id=3040422 AND option_id=7))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042207)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042208',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042208 AND description<>'May2013 Mesa remaining option 304042208')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042208 AND NOT(reward_set_id=3040422 AND option_id=8))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042208)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042209',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042209 AND description<>'May2013 Mesa remaining option 304042209')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042209 AND NOT(reward_set_id=3040422 AND option_id=9))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042209)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042210',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042210 AND description<>'May2013 Mesa remaining option 304042210')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042210 AND NOT(reward_set_id=3040422 AND option_id=10))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042210)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042211',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042211 AND description<>'May2013 Mesa remaining option 304042211')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042211 AND NOT(reward_set_id=3040422 AND option_id=11))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042211)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042212',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042212 AND description<>'May2013 Mesa remaining option 304042212')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042212 AND NOT(reward_set_id=3040422 AND option_id=12))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042212)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042213',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042213 AND description<>'May2013 Mesa remaining option 304042213')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042213 AND NOT(reward_set_id=3040422 AND option_id=13))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042213)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042214',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042214 AND description<>'May2013 Mesa remaining option 304042214')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042214 AND NOT(reward_set_id=3040422 AND option_id=14))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042214)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042215',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042215 AND description<>'May2013 Mesa remaining option 304042215')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042215 AND NOT(reward_set_id=3040422 AND option_id=15))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042215)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042216',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042216 AND description<>'May2013 Mesa remaining option 304042216')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042216 AND NOT(reward_set_id=3040422 AND option_id=16))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042216)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042217',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042217 AND description<>'May2013 Mesa remaining option 304042217')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042217 AND NOT(reward_set_id=3040422 AND option_id=17))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042217)));
INSERT INTO _mesa_remaining_guard VALUES('criterion_50145',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500040600 AND component_type=1 AND component_id=50145 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040423 AND target_id2=0 AND target_value=0 AND component_sequence=3 AND required_count=1))));
INSERT INTO _mesa_remaining_guard VALUES('reward_set_3040423',(NOT EXISTS(SELECT 1 FROM reward_sets WHERE reward_set_id=3040423 AND title<>'Snake Skins for Madu')AND NOT EXISTS(SELECT 1 FROM reward_sources WHERE reward_set_id=3040423 AND NOT(source_type=2 AND source_id=3040423))AND NOT EXISTS(SELECT 1 FROM reward_sources WHERE source_type=2 AND source_id=3040423 AND reward_set_id<>3040423)));
INSERT INTO _mesa_remaining_guard VALUES('option_ownership_3040423',(NOT EXISTS(SELECT 1 FROM reward_options WHERE reward_set_id=3040423 AND NOT((option_id=1 AND label='Experience' AND common_to_all=1 AND flags=0 AND class_mask=65535) OR (option_id=2 AND label='Iron Forged Plate Gauntlets' AND common_to_all=0 AND flags=0 AND class_mask=1) OR (option_id=3 AND label='Fire Sanctified Plate Gauntlets' AND common_to_all=0 AND flags=0 AND class_mask=2) OR (option_id=4 AND label='Maiden Blessed Plate Gauntlets' AND common_to_all=0 AND flags=0 AND class_mask=4) OR (option_id=5 AND label='Thorn Bonded Chain Gauntlets' AND common_to_all=0 AND flags=0 AND class_mask=8) OR (option_id=6 AND label='Swamp Dredged Plate Gauntlets' AND common_to_all=0 AND flags=0 AND class_mask=16) OR (option_id=7 AND label='Vine Imprinted Leather Gloves' AND common_to_all=0 AND flags=0 AND class_mask=32) OR (option_id=8 AND label='Stone Formed Leather Gloves' AND common_to_all=0 AND flags=0 AND class_mask=64) OR (option_id=9 AND label='Steel Toned Plate Gauntlets' AND common_to_all=0 AND flags=0 AND class_mask=128) OR (option_id=10 AND label='Blood Blackened Chain Gauntlets' AND common_to_all=0 AND flags=0 AND class_mask=256) OR (option_id=11 AND label='Ritual Embossed Chain Gauntlets' AND common_to_all=0 AND flags=0 AND class_mask=512) OR (option_id=12 AND label='Bone Twisted Cloth Gloves' AND common_to_all=0 AND flags=0 AND class_mask=1024) OR (option_id=13 AND label='Ice Woven Cloth Gloves' AND common_to_all=0 AND flags=0 AND class_mask=2048) OR (option_id=14 AND label='Earth Melded Cloth Gloves' AND common_to_all=0 AND flags=0 AND class_mask=4096) OR (option_id=15 AND label='Rune Tailored Cloth Gloves' AND common_to_all=0 AND flags=0 AND class_mask=8192) OR (option_id=16 AND label='Savage Runic Leather Gloves' AND common_to_all=0 AND flags=0 AND class_mask=16384) OR (option_id=17 AND label='Blade Notched Chain Gauntlets' AND common_to_all=0 AND flags=0 AND class_mask=32768)))));
INSERT INTO _mesa_remaining_guard VALUES('option_links_3040423',(NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_set_id=3040423 AND NOT((option_id=1 AND sequence=0 AND reward_id=304042301) OR (option_id=2 AND sequence=0 AND reward_id=304042302) OR (option_id=3 AND sequence=0 AND reward_id=304042303) OR (option_id=4 AND sequence=0 AND reward_id=304042304) OR (option_id=5 AND sequence=0 AND reward_id=304042305) OR (option_id=6 AND sequence=0 AND reward_id=304042306) OR (option_id=7 AND sequence=0 AND reward_id=304042307) OR (option_id=8 AND sequence=0 AND reward_id=304042308) OR (option_id=9 AND sequence=0 AND reward_id=304042309) OR (option_id=10 AND sequence=0 AND reward_id=304042310) OR (option_id=11 AND sequence=0 AND reward_id=304042311) OR (option_id=12 AND sequence=0 AND reward_id=304042312) OR (option_id=13 AND sequence=0 AND reward_id=304042313) OR (option_id=14 AND sequence=0 AND reward_id=304042314) OR (option_id=15 AND sequence=0 AND reward_id=304042315) OR (option_id=16 AND sequence=0 AND reward_id=304042316) OR (option_id=17 AND sequence=0 AND reward_id=304042317)))));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042301',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042301 AND description<>'May2013 Mesa remaining option 304042301')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042301 AND NOT(reward_set_id=3040423 AND option_id=1))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042301)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042302',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042302 AND description<>'May2013 Mesa remaining option 304042302')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042302 AND NOT(reward_set_id=3040423 AND option_id=2))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042302)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042303',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042303 AND description<>'May2013 Mesa remaining option 304042303')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042303 AND NOT(reward_set_id=3040423 AND option_id=3))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042303)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042304',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042304 AND description<>'May2013 Mesa remaining option 304042304')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042304 AND NOT(reward_set_id=3040423 AND option_id=4))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042304)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042305',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042305 AND description<>'May2013 Mesa remaining option 304042305')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042305 AND NOT(reward_set_id=3040423 AND option_id=5))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042305)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042306',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042306 AND description<>'May2013 Mesa remaining option 304042306')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042306 AND NOT(reward_set_id=3040423 AND option_id=6))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042306)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042307',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042307 AND description<>'May2013 Mesa remaining option 304042307')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042307 AND NOT(reward_set_id=3040423 AND option_id=7))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042307)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042308',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042308 AND description<>'May2013 Mesa remaining option 304042308')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042308 AND NOT(reward_set_id=3040423 AND option_id=8))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042308)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042309',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042309 AND description<>'May2013 Mesa remaining option 304042309')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042309 AND NOT(reward_set_id=3040423 AND option_id=9))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042309)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042310',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042310 AND description<>'May2013 Mesa remaining option 304042310')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042310 AND NOT(reward_set_id=3040423 AND option_id=10))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042310)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042311',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042311 AND description<>'May2013 Mesa remaining option 304042311')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042311 AND NOT(reward_set_id=3040423 AND option_id=11))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042311)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042312',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042312 AND description<>'May2013 Mesa remaining option 304042312')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042312 AND NOT(reward_set_id=3040423 AND option_id=12))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042312)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042313',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042313 AND description<>'May2013 Mesa remaining option 304042313')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042313 AND NOT(reward_set_id=3040423 AND option_id=13))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042313)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042314',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042314 AND description<>'May2013 Mesa remaining option 304042314')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042314 AND NOT(reward_set_id=3040423 AND option_id=14))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042314)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042315',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042315 AND description<>'May2013 Mesa remaining option 304042315')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042315 AND NOT(reward_set_id=3040423 AND option_id=15))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042315)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042316',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042316 AND description<>'May2013 Mesa remaining option 304042316')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042316 AND NOT(reward_set_id=3040423 AND option_id=16))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042316)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042317',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042317 AND description<>'May2013 Mesa remaining option 304042317')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042317 AND NOT(reward_set_id=3040423 AND option_id=17))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042317)));
INSERT INTO _mesa_remaining_guard VALUES('criterion_50146',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500040600 AND component_type=1 AND component_id=50146 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040424 AND target_id2=0 AND target_value=0 AND component_sequence=4 AND required_count=1))));
INSERT INTO _mesa_remaining_guard VALUES('reward_set_3040424',(NOT EXISTS(SELECT 1 FROM reward_sets WHERE reward_set_id=3040424 AND title<>'Spider Silk for Madu')AND NOT EXISTS(SELECT 1 FROM reward_sources WHERE reward_set_id=3040424 AND NOT(source_type=2 AND source_id=3040424))AND NOT EXISTS(SELECT 1 FROM reward_sources WHERE source_type=2 AND source_id=3040424 AND reward_set_id<>3040424)));
INSERT INTO _mesa_remaining_guard VALUES('option_ownership_3040424',(NOT EXISTS(SELECT 1 FROM reward_options WHERE reward_set_id=3040424 AND NOT((option_id=1 AND label='Experience' AND common_to_all=1 AND flags=0 AND class_mask=65535) OR (option_id=2 AND label='Iron Forged Plate Helm' AND common_to_all=0 AND flags=0 AND class_mask=1) OR (option_id=3 AND label='Fire Sanctified Plate Helm' AND common_to_all=0 AND flags=0 AND class_mask=2) OR (option_id=4 AND label='Maiden Blessed Plate Helm' AND common_to_all=0 AND flags=0 AND class_mask=4) OR (option_id=5 AND label='Thorn Bonded Chain Coif' AND common_to_all=0 AND flags=0 AND class_mask=8) OR (option_id=6 AND label='Swamp Dredged Plate Helm' AND common_to_all=0 AND flags=0 AND class_mask=16) OR (option_id=7 AND label='Vine Imprinted Leather Cowl' AND common_to_all=0 AND flags=0 AND class_mask=32) OR (option_id=8 AND label='Stone Formed Leather Cowl' AND common_to_all=0 AND flags=0 AND class_mask=64) OR (option_id=9 AND label='Steel Toned Plate Helm' AND common_to_all=0 AND flags=0 AND class_mask=128) OR (option_id=10 AND label='Blood Blackened Chain Coif' AND common_to_all=0 AND flags=0 AND class_mask=256) OR (option_id=11 AND label='Ritual Embossed Chain Coif' AND common_to_all=0 AND flags=0 AND class_mask=512) OR (option_id=12 AND label='Bone Twisted Cloth Cap' AND common_to_all=0 AND flags=0 AND class_mask=1024) OR (option_id=13 AND label='Ice Woven Cloth Cap' AND common_to_all=0 AND flags=0 AND class_mask=2048) OR (option_id=14 AND label='Earth Melded Cloth Cap' AND common_to_all=0 AND flags=0 AND class_mask=4096) OR (option_id=15 AND label='Rune Tailored Cloth Cap' AND common_to_all=0 AND flags=0 AND class_mask=8192) OR (option_id=16 AND label='Savage Runic Leather Cowl' AND common_to_all=0 AND flags=0 AND class_mask=16384) OR (option_id=17 AND label='Blade Notched Chain Coif' AND common_to_all=0 AND flags=0 AND class_mask=32768)))));
INSERT INTO _mesa_remaining_guard VALUES('option_links_3040424',(NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_set_id=3040424 AND NOT((option_id=1 AND sequence=0 AND reward_id=304042401) OR (option_id=2 AND sequence=0 AND reward_id=304042402) OR (option_id=3 AND sequence=0 AND reward_id=304042403) OR (option_id=4 AND sequence=0 AND reward_id=304042404) OR (option_id=5 AND sequence=0 AND reward_id=304042405) OR (option_id=6 AND sequence=0 AND reward_id=304042406) OR (option_id=7 AND sequence=0 AND reward_id=304042407) OR (option_id=8 AND sequence=0 AND reward_id=304042408) OR (option_id=9 AND sequence=0 AND reward_id=304042409) OR (option_id=10 AND sequence=0 AND reward_id=304042410) OR (option_id=11 AND sequence=0 AND reward_id=304042411) OR (option_id=12 AND sequence=0 AND reward_id=304042412) OR (option_id=13 AND sequence=0 AND reward_id=304042413) OR (option_id=14 AND sequence=0 AND reward_id=304042414) OR (option_id=15 AND sequence=0 AND reward_id=304042415) OR (option_id=16 AND sequence=0 AND reward_id=304042416) OR (option_id=17 AND sequence=0 AND reward_id=304042417)))));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042401',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042401 AND description<>'May2013 Mesa remaining option 304042401')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042401 AND NOT(reward_set_id=3040424 AND option_id=1))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042401)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042402',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042402 AND description<>'May2013 Mesa remaining option 304042402')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042402 AND NOT(reward_set_id=3040424 AND option_id=2))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042402)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042403',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042403 AND description<>'May2013 Mesa remaining option 304042403')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042403 AND NOT(reward_set_id=3040424 AND option_id=3))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042403)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042404',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042404 AND description<>'May2013 Mesa remaining option 304042404')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042404 AND NOT(reward_set_id=3040424 AND option_id=4))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042404)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042405',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042405 AND description<>'May2013 Mesa remaining option 304042405')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042405 AND NOT(reward_set_id=3040424 AND option_id=5))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042405)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042406',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042406 AND description<>'May2013 Mesa remaining option 304042406')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042406 AND NOT(reward_set_id=3040424 AND option_id=6))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042406)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042407',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042407 AND description<>'May2013 Mesa remaining option 304042407')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042407 AND NOT(reward_set_id=3040424 AND option_id=7))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042407)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042408',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042408 AND description<>'May2013 Mesa remaining option 304042408')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042408 AND NOT(reward_set_id=3040424 AND option_id=8))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042408)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042409',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042409 AND description<>'May2013 Mesa remaining option 304042409')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042409 AND NOT(reward_set_id=3040424 AND option_id=9))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042409)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042410',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042410 AND description<>'May2013 Mesa remaining option 304042410')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042410 AND NOT(reward_set_id=3040424 AND option_id=10))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042410)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042411',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042411 AND description<>'May2013 Mesa remaining option 304042411')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042411 AND NOT(reward_set_id=3040424 AND option_id=11))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042411)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042412',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042412 AND description<>'May2013 Mesa remaining option 304042412')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042412 AND NOT(reward_set_id=3040424 AND option_id=12))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042412)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042413',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042413 AND description<>'May2013 Mesa remaining option 304042413')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042413 AND NOT(reward_set_id=3040424 AND option_id=13))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042413)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042414',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042414 AND description<>'May2013 Mesa remaining option 304042414')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042414 AND NOT(reward_set_id=3040424 AND option_id=14))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042414)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042415',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042415 AND description<>'May2013 Mesa remaining option 304042415')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042415 AND NOT(reward_set_id=3040424 AND option_id=15))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042415)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042416',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042416 AND description<>'May2013 Mesa remaining option 304042416')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042416 AND NOT(reward_set_id=3040424 AND option_id=16))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042416)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042417',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042417 AND description<>'May2013 Mesa remaining option 304042417')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042417 AND NOT(reward_set_id=3040424 AND option_id=17))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042417)));
INSERT INTO _mesa_remaining_guard VALUES('criterion_50147',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500040600 AND component_type=1 AND component_id=50147 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040425 AND target_id2=0 AND target_value=0 AND component_sequence=5 AND required_count=1))));
INSERT INTO _mesa_remaining_guard VALUES('reward_set_3040425',(NOT EXISTS(SELECT 1 FROM reward_sets WHERE reward_set_id=3040425 AND title<>'Madu Needs More Supplies')AND NOT EXISTS(SELECT 1 FROM reward_sources WHERE reward_set_id=3040425 AND NOT(source_type=2 AND source_id=3040425))AND NOT EXISTS(SELECT 1 FROM reward_sources WHERE source_type=2 AND source_id=3040425 AND reward_set_id<>3040425)));
INSERT INTO _mesa_remaining_guard VALUES('option_ownership_3040425',(NOT EXISTS(SELECT 1 FROM reward_options WHERE reward_set_id=3040425 AND NOT((option_id=1 AND label='Experience' AND common_to_all=1 AND flags=0 AND class_mask=65535) OR (option_id=2 AND label='Iron Forged Plate Vambraces' AND common_to_all=0 AND flags=0 AND class_mask=1) OR (option_id=3 AND label='Fire Sanctified Plate Vambraces' AND common_to_all=0 AND flags=0 AND class_mask=2) OR (option_id=4 AND label='Maiden Blessed Plate Vambraces' AND common_to_all=0 AND flags=0 AND class_mask=4) OR (option_id=5 AND label='Thorn Bonded Chain Sleeves' AND common_to_all=0 AND flags=0 AND class_mask=8) OR (option_id=6 AND label='Swamp Dredged Plate Vambraces' AND common_to_all=0 AND flags=0 AND class_mask=16) OR (option_id=7 AND label='Vine Imprinted Leather Armwraps' AND common_to_all=0 AND flags=0 AND class_mask=32) OR (option_id=8 AND label='Stone Formed Leather Armwraps' AND common_to_all=0 AND flags=0 AND class_mask=64) OR (option_id=9 AND label='Steel Toned Plate Vambraces' AND common_to_all=0 AND flags=0 AND class_mask=128) OR (option_id=10 AND label='Blood Blackened Chain Sleeves' AND common_to_all=0 AND flags=0 AND class_mask=256) OR (option_id=11 AND label='Ritual Embossed Chain Sleeves' AND common_to_all=0 AND flags=0 AND class_mask=512) OR (option_id=12 AND label='Bone Twisted Cloth Sleeves' AND common_to_all=0 AND flags=0 AND class_mask=1024) OR (option_id=13 AND label='Ice Woven Cloth Sleeves' AND common_to_all=0 AND flags=0 AND class_mask=2048) OR (option_id=14 AND label='Earth Melded Cloth Sleeves' AND common_to_all=0 AND flags=0 AND class_mask=4096) OR (option_id=15 AND label='Rune Tailored Cloth Sleeves' AND common_to_all=0 AND flags=0 AND class_mask=8192) OR (option_id=16 AND label='Savage Runic Leather Armwraps' AND common_to_all=0 AND flags=0 AND class_mask=16384) OR (option_id=17 AND label='Blade Notched Chain Sleeves' AND common_to_all=0 AND flags=0 AND class_mask=32768)))));
INSERT INTO _mesa_remaining_guard VALUES('option_links_3040425',(NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_set_id=3040425 AND NOT((option_id=1 AND sequence=0 AND reward_id=304042501) OR (option_id=2 AND sequence=0 AND reward_id=304042502) OR (option_id=3 AND sequence=0 AND reward_id=304042503) OR (option_id=4 AND sequence=0 AND reward_id=304042504) OR (option_id=5 AND sequence=0 AND reward_id=304042505) OR (option_id=6 AND sequence=0 AND reward_id=304042506) OR (option_id=7 AND sequence=0 AND reward_id=304042507) OR (option_id=8 AND sequence=0 AND reward_id=304042508) OR (option_id=9 AND sequence=0 AND reward_id=304042509) OR (option_id=10 AND sequence=0 AND reward_id=304042510) OR (option_id=11 AND sequence=0 AND reward_id=304042511) OR (option_id=12 AND sequence=0 AND reward_id=304042512) OR (option_id=13 AND sequence=0 AND reward_id=304042513) OR (option_id=14 AND sequence=0 AND reward_id=304042514) OR (option_id=15 AND sequence=0 AND reward_id=304042515) OR (option_id=16 AND sequence=0 AND reward_id=304042516) OR (option_id=17 AND sequence=0 AND reward_id=304042517)))));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042501',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042501 AND description<>'May2013 Mesa remaining option 304042501')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042501 AND NOT(reward_set_id=3040425 AND option_id=1))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042501)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042502',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042502 AND description<>'May2013 Mesa remaining option 304042502')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042502 AND NOT(reward_set_id=3040425 AND option_id=2))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042502)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042503',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042503 AND description<>'May2013 Mesa remaining option 304042503')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042503 AND NOT(reward_set_id=3040425 AND option_id=3))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042503)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042504',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042504 AND description<>'May2013 Mesa remaining option 304042504')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042504 AND NOT(reward_set_id=3040425 AND option_id=4))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042504)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042505',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042505 AND description<>'May2013 Mesa remaining option 304042505')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042505 AND NOT(reward_set_id=3040425 AND option_id=5))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042505)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042506',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042506 AND description<>'May2013 Mesa remaining option 304042506')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042506 AND NOT(reward_set_id=3040425 AND option_id=6))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042506)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042507',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042507 AND description<>'May2013 Mesa remaining option 304042507')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042507 AND NOT(reward_set_id=3040425 AND option_id=7))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042507)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042508',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042508 AND description<>'May2013 Mesa remaining option 304042508')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042508 AND NOT(reward_set_id=3040425 AND option_id=8))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042508)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042509',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042509 AND description<>'May2013 Mesa remaining option 304042509')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042509 AND NOT(reward_set_id=3040425 AND option_id=9))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042509)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042510',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042510 AND description<>'May2013 Mesa remaining option 304042510')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042510 AND NOT(reward_set_id=3040425 AND option_id=10))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042510)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042511',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042511 AND description<>'May2013 Mesa remaining option 304042511')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042511 AND NOT(reward_set_id=3040425 AND option_id=11))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042511)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042512',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042512 AND description<>'May2013 Mesa remaining option 304042512')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042512 AND NOT(reward_set_id=3040425 AND option_id=12))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042512)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042513',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042513 AND description<>'May2013 Mesa remaining option 304042513')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042513 AND NOT(reward_set_id=3040425 AND option_id=13))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042513)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042514',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042514 AND description<>'May2013 Mesa remaining option 304042514')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042514 AND NOT(reward_set_id=3040425 AND option_id=14))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042514)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042515',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042515 AND description<>'May2013 Mesa remaining option 304042515')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042515 AND NOT(reward_set_id=3040425 AND option_id=15))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042515)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042516',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042516 AND description<>'May2013 Mesa remaining option 304042516')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042516 AND NOT(reward_set_id=3040425 AND option_id=16))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042516)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042517',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042517 AND description<>'May2013 Mesa remaining option 304042517')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042517 AND NOT(reward_set_id=3040425 AND option_id=17))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042517)));
INSERT INTO _mesa_remaining_guard VALUES('criterion_50148',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500040600 AND component_type=1 AND component_id=50148 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040426 AND target_id2=0 AND target_value=0 AND component_sequence=6 AND required_count=1))));
INSERT INTO _mesa_remaining_guard VALUES('reward_set_3040426',(NOT EXISTS(SELECT 1 FROM reward_sets WHERE reward_set_id=3040426 AND title<>'Kill Fantoma')AND NOT EXISTS(SELECT 1 FROM reward_sources WHERE reward_set_id=3040426 AND NOT(source_type=2 AND source_id=3040426))AND NOT EXISTS(SELECT 1 FROM reward_sources WHERE source_type=2 AND source_id=3040426 AND reward_set_id<>3040426)));
INSERT INTO _mesa_remaining_guard VALUES('option_ownership_3040426',(NOT EXISTS(SELECT 1 FROM reward_options WHERE reward_set_id=3040426 AND NOT((option_id=1 AND label='Experience' AND common_to_all=1 AND flags=0 AND class_mask=65535) OR (option_id=2 AND label='Iron Forged Plate Greaves' AND common_to_all=0 AND flags=0 AND class_mask=1) OR (option_id=3 AND label='Fire Sanctified Plate Greaves' AND common_to_all=0 AND flags=0 AND class_mask=2) OR (option_id=4 AND label='Maiden Blessed Plate Greaves' AND common_to_all=0 AND flags=0 AND class_mask=4) OR (option_id=5 AND label='Thorn Bonded Chain Leggings' AND common_to_all=0 AND flags=0 AND class_mask=8) OR (option_id=6 AND label='Swamp Dredged Plate Greaves' AND common_to_all=0 AND flags=0 AND class_mask=16) OR (option_id=7 AND label='Vine Imprinted Leather Leggings' AND common_to_all=0 AND flags=0 AND class_mask=32) OR (option_id=8 AND label='Stone Formed Leather Leggings' AND common_to_all=0 AND flags=0 AND class_mask=64) OR (option_id=9 AND label='Steel Toned Plate Greaves' AND common_to_all=0 AND flags=0 AND class_mask=128) OR (option_id=10 AND label='Blood Blackened Chain Leggings' AND common_to_all=0 AND flags=0 AND class_mask=256) OR (option_id=11 AND label='Ritual Embossed Chain Leggings' AND common_to_all=0 AND flags=0 AND class_mask=512) OR (option_id=12 AND label='Bone Twisted Cloth Pants' AND common_to_all=0 AND flags=0 AND class_mask=1024) OR (option_id=13 AND label='Ice Woven Cloth Pants' AND common_to_all=0 AND flags=0 AND class_mask=2048) OR (option_id=14 AND label='Earth Melded Cloth Pants' AND common_to_all=0 AND flags=0 AND class_mask=4096) OR (option_id=15 AND label='Rune Tailored Cloth Pants' AND common_to_all=0 AND flags=0 AND class_mask=8192) OR (option_id=16 AND label='Savage Runic Leather Leggings' AND common_to_all=0 AND flags=0 AND class_mask=16384) OR (option_id=17 AND label='Blade Notched Chain Leggings' AND common_to_all=0 AND flags=0 AND class_mask=32768)))));
INSERT INTO _mesa_remaining_guard VALUES('option_links_3040426',(NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_set_id=3040426 AND NOT((option_id=1 AND sequence=0 AND reward_id=304042601) OR (option_id=2 AND sequence=0 AND reward_id=304042602) OR (option_id=3 AND sequence=0 AND reward_id=304042603) OR (option_id=4 AND sequence=0 AND reward_id=304042604) OR (option_id=5 AND sequence=0 AND reward_id=304042605) OR (option_id=6 AND sequence=0 AND reward_id=304042606) OR (option_id=7 AND sequence=0 AND reward_id=304042607) OR (option_id=8 AND sequence=0 AND reward_id=304042608) OR (option_id=9 AND sequence=0 AND reward_id=304042609) OR (option_id=10 AND sequence=0 AND reward_id=304042610) OR (option_id=11 AND sequence=0 AND reward_id=304042611) OR (option_id=12 AND sequence=0 AND reward_id=304042612) OR (option_id=13 AND sequence=0 AND reward_id=304042613) OR (option_id=14 AND sequence=0 AND reward_id=304042614) OR (option_id=15 AND sequence=0 AND reward_id=304042615) OR (option_id=16 AND sequence=0 AND reward_id=304042616) OR (option_id=17 AND sequence=0 AND reward_id=304042617)))));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042601',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042601 AND description<>'May2013 Mesa remaining option 304042601')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042601 AND NOT(reward_set_id=3040426 AND option_id=1))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042601)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042602',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042602 AND description<>'May2013 Mesa remaining option 304042602')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042602 AND NOT(reward_set_id=3040426 AND option_id=2))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042602)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042603',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042603 AND description<>'May2013 Mesa remaining option 304042603')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042603 AND NOT(reward_set_id=3040426 AND option_id=3))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042603)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042604',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042604 AND description<>'May2013 Mesa remaining option 304042604')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042604 AND NOT(reward_set_id=3040426 AND option_id=4))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042604)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042605',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042605 AND description<>'May2013 Mesa remaining option 304042605')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042605 AND NOT(reward_set_id=3040426 AND option_id=5))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042605)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042606',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042606 AND description<>'May2013 Mesa remaining option 304042606')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042606 AND NOT(reward_set_id=3040426 AND option_id=6))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042606)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042607',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042607 AND description<>'May2013 Mesa remaining option 304042607')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042607 AND NOT(reward_set_id=3040426 AND option_id=7))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042607)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042608',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042608 AND description<>'May2013 Mesa remaining option 304042608')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042608 AND NOT(reward_set_id=3040426 AND option_id=8))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042608)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042609',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042609 AND description<>'May2013 Mesa remaining option 304042609')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042609 AND NOT(reward_set_id=3040426 AND option_id=9))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042609)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042610',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042610 AND description<>'May2013 Mesa remaining option 304042610')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042610 AND NOT(reward_set_id=3040426 AND option_id=10))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042610)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042611',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042611 AND description<>'May2013 Mesa remaining option 304042611')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042611 AND NOT(reward_set_id=3040426 AND option_id=11))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042611)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042612',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042612 AND description<>'May2013 Mesa remaining option 304042612')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042612 AND NOT(reward_set_id=3040426 AND option_id=12))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042612)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042613',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042613 AND description<>'May2013 Mesa remaining option 304042613')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042613 AND NOT(reward_set_id=3040426 AND option_id=13))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042613)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042614',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042614 AND description<>'May2013 Mesa remaining option 304042614')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042614 AND NOT(reward_set_id=3040426 AND option_id=14))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042614)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042615',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042615 AND description<>'May2013 Mesa remaining option 304042615')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042615 AND NOT(reward_set_id=3040426 AND option_id=15))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042615)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042616',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042616 AND description<>'May2013 Mesa remaining option 304042616')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042616 AND NOT(reward_set_id=3040426 AND option_id=16))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042616)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042617',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042617 AND description<>'May2013 Mesa remaining option 304042617')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042617 AND NOT(reward_set_id=3040426 AND option_id=17))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042617)));
INSERT INTO _mesa_remaining_guard VALUES('criterion_50149',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500040600 AND component_type=1 AND component_id=50149 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040427 AND target_id2=0 AND target_value=0 AND component_sequence=7 AND required_count=1))));
INSERT INTO _mesa_remaining_guard VALUES('reward_set_3040427',(NOT EXISTS(SELECT 1 FROM reward_sets WHERE reward_set_id=3040427 AND title<>'Kill Ursalua')AND NOT EXISTS(SELECT 1 FROM reward_sources WHERE reward_set_id=3040427 AND NOT(source_type=2 AND source_id=3040427))AND NOT EXISTS(SELECT 1 FROM reward_sources WHERE source_type=2 AND source_id=3040427 AND reward_set_id<>3040427)));
INSERT INTO _mesa_remaining_guard VALUES('option_ownership_3040427',(NOT EXISTS(SELECT 1 FROM reward_options WHERE reward_set_id=3040427 AND NOT((option_id=1 AND label='Experience' AND common_to_all=1 AND flags=0 AND class_mask=65535) OR (option_id=2 AND label='Iron Forged Plate Breastplate' AND common_to_all=0 AND flags=0 AND class_mask=1) OR (option_id=3 AND label='Fire Sanctified Plate Breastplate' AND common_to_all=0 AND flags=0 AND class_mask=2) OR (option_id=4 AND label='Maiden Blessed Plate Breastplate' AND common_to_all=0 AND flags=0 AND class_mask=4) OR (option_id=5 AND label='Thorn Bonded Chain Coat' AND common_to_all=0 AND flags=0 AND class_mask=8) OR (option_id=6 AND label='Swamp Dredged Plate Breastplate' AND common_to_all=0 AND flags=0 AND class_mask=16) OR (option_id=7 AND label='Vine Imprinted Leather Tunic' AND common_to_all=0 AND flags=0 AND class_mask=32) OR (option_id=8 AND label='Stone Formed Leather Tunic' AND common_to_all=0 AND flags=0 AND class_mask=64) OR (option_id=9 AND label='Steel Toned Plate Breastplate' AND common_to_all=0 AND flags=0 AND class_mask=128) OR (option_id=10 AND label='Blood Blackened Chain Coat' AND common_to_all=0 AND flags=0 AND class_mask=256) OR (option_id=11 AND label='Ritual Embossed Chain Coat' AND common_to_all=0 AND flags=0 AND class_mask=512) OR (option_id=12 AND label='Bone Twisted Cloth Robe' AND common_to_all=0 AND flags=0 AND class_mask=1024) OR (option_id=13 AND label='Ice Woven Cloth Robe' AND common_to_all=0 AND flags=0 AND class_mask=2048) OR (option_id=14 AND label='Earth Melded Cloth Robe' AND common_to_all=0 AND flags=0 AND class_mask=4096) OR (option_id=15 AND label='Rune Tailored Cloth Robe' AND common_to_all=0 AND flags=0 AND class_mask=8192) OR (option_id=16 AND label='Savage Runic Leather Tunic' AND common_to_all=0 AND flags=0 AND class_mask=16384) OR (option_id=17 AND label='Blade Notched Chain Coat' AND common_to_all=0 AND flags=0 AND class_mask=32768)))));
INSERT INTO _mesa_remaining_guard VALUES('option_links_3040427',(NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_set_id=3040427 AND NOT((option_id=1 AND sequence=0 AND reward_id=304042701) OR (option_id=2 AND sequence=0 AND reward_id=304042702) OR (option_id=3 AND sequence=0 AND reward_id=304042703) OR (option_id=4 AND sequence=0 AND reward_id=304042704) OR (option_id=5 AND sequence=0 AND reward_id=304042705) OR (option_id=6 AND sequence=0 AND reward_id=304042706) OR (option_id=7 AND sequence=0 AND reward_id=304042707) OR (option_id=8 AND sequence=0 AND reward_id=304042708) OR (option_id=9 AND sequence=0 AND reward_id=304042709) OR (option_id=10 AND sequence=0 AND reward_id=304042710) OR (option_id=11 AND sequence=0 AND reward_id=304042711) OR (option_id=12 AND sequence=0 AND reward_id=304042712) OR (option_id=13 AND sequence=0 AND reward_id=304042713) OR (option_id=14 AND sequence=0 AND reward_id=304042714) OR (option_id=15 AND sequence=0 AND reward_id=304042715) OR (option_id=16 AND sequence=0 AND reward_id=304042716) OR (option_id=17 AND sequence=0 AND reward_id=304042717)))));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042701',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042701 AND description<>'May2013 Mesa remaining option 304042701')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042701 AND NOT(reward_set_id=3040427 AND option_id=1))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042701)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042702',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042702 AND description<>'May2013 Mesa remaining option 304042702')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042702 AND NOT(reward_set_id=3040427 AND option_id=2))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042702)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042703',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042703 AND description<>'May2013 Mesa remaining option 304042703')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042703 AND NOT(reward_set_id=3040427 AND option_id=3))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042703)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042704',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042704 AND description<>'May2013 Mesa remaining option 304042704')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042704 AND NOT(reward_set_id=3040427 AND option_id=4))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042704)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042705',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042705 AND description<>'May2013 Mesa remaining option 304042705')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042705 AND NOT(reward_set_id=3040427 AND option_id=5))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042705)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042706',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042706 AND description<>'May2013 Mesa remaining option 304042706')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042706 AND NOT(reward_set_id=3040427 AND option_id=6))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042706)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042707',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042707 AND description<>'May2013 Mesa remaining option 304042707')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042707 AND NOT(reward_set_id=3040427 AND option_id=7))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042707)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042708',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042708 AND description<>'May2013 Mesa remaining option 304042708')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042708 AND NOT(reward_set_id=3040427 AND option_id=8))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042708)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042709',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042709 AND description<>'May2013 Mesa remaining option 304042709')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042709 AND NOT(reward_set_id=3040427 AND option_id=9))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042709)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042710',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042710 AND description<>'May2013 Mesa remaining option 304042710')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042710 AND NOT(reward_set_id=3040427 AND option_id=10))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042710)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042711',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042711 AND description<>'May2013 Mesa remaining option 304042711')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042711 AND NOT(reward_set_id=3040427 AND option_id=11))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042711)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042712',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042712 AND description<>'May2013 Mesa remaining option 304042712')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042712 AND NOT(reward_set_id=3040427 AND option_id=12))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042712)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042713',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042713 AND description<>'May2013 Mesa remaining option 304042713')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042713 AND NOT(reward_set_id=3040427 AND option_id=13))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042713)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042714',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042714 AND description<>'May2013 Mesa remaining option 304042714')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042714 AND NOT(reward_set_id=3040427 AND option_id=14))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042714)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042715',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042715 AND description<>'May2013 Mesa remaining option 304042715')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042715 AND NOT(reward_set_id=3040427 AND option_id=15))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042715)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042716',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042716 AND description<>'May2013 Mesa remaining option 304042716')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042716 AND NOT(reward_set_id=3040427 AND option_id=16))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042716)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304042717',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304042717 AND description<>'May2013 Mesa remaining option 304042717')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304042717 AND NOT(reward_set_id=3040427 AND option_id=17))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304042717)));
INSERT INTO _mesa_remaining_guard VALUES('criterion_50126',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500040400 AND component_type=1 AND component_id=50126 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040428 AND target_id2=0 AND target_value=0 AND component_sequence=1 AND required_count=1))));
INSERT INTO _mesa_remaining_guard VALUES('criterion_50127',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500040400 AND component_type=1 AND component_id=50127 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040429 AND target_id2=0 AND target_value=0 AND component_sequence=2 AND required_count=1))));
INSERT INTO _mesa_remaining_guard VALUES('criterion_50132',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500040400 AND component_type=1 AND component_id=50132 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040430 AND target_id2=0 AND target_value=0 AND component_sequence=7 AND required_count=1))));
INSERT INTO _mesa_remaining_guard VALUES('criterion_50133',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500040400 AND component_type=1 AND component_id=50133 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040431 AND target_id2=0 AND target_value=0 AND component_sequence=8 AND required_count=1))));
INSERT INTO _mesa_remaining_guard VALUES('criterion_50134',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500040400 AND component_type=1 AND component_id=50134 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040432 AND target_id2=0 AND target_value=0 AND component_sequence=9 AND required_count=1))));
INSERT INTO _mesa_remaining_guard VALUES('criterion_50135',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500040400 AND component_type=1 AND component_id=50135 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040433 AND target_id2=0 AND target_value=0 AND component_sequence=10 AND required_count=1))));
INSERT INTO _mesa_remaining_guard VALUES('criterion_50136',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500040400 AND component_type=1 AND component_id=50136 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040434 AND target_id2=0 AND target_value=0 AND component_sequence=11 AND required_count=1))));
INSERT INTO _mesa_remaining_guard VALUES('criterion_50128',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500040400 AND component_type=1 AND component_id=50128 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040435 AND target_id2=0 AND target_value=0 AND component_sequence=3 AND required_count=1))));
INSERT INTO _mesa_remaining_guard VALUES('criterion_50129',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500040400 AND component_type=1 AND component_id=50129 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040436 AND target_id2=0 AND target_value=0 AND component_sequence=4 AND required_count=1))));
INSERT INTO _mesa_remaining_guard VALUES('criterion_50130',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500040400 AND component_type=1 AND component_id=50130 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040437 AND target_id2=0 AND target_value=0 AND component_sequence=5 AND required_count=1))));
INSERT INTO _mesa_remaining_guard VALUES('criterion_50131',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500040400 AND component_type=1 AND component_id=50131 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040438 AND target_id2=0 AND target_value=0 AND component_sequence=6 AND required_count=1))));
INSERT INTO _mesa_remaining_guard VALUES('criterion_50150',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500040700 AND component_type=1 AND component_id=50150 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040439 AND target_id2=0 AND target_value=0 AND component_sequence=1 AND required_count=1))));
INSERT INTO _mesa_remaining_guard VALUES('criterion_50151',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500040700 AND component_type=1 AND component_id=50151 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040440 AND target_id2=0 AND target_value=0 AND component_sequence=2 AND required_count=1))));
INSERT INTO _mesa_remaining_guard VALUES('criterion_50152',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500040700 AND component_type=1 AND component_id=50152 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040441 AND target_id2=0 AND target_value=0 AND component_sequence=3 AND required_count=1))));
INSERT INTO _mesa_remaining_guard VALUES('criterion_50153',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500040700 AND component_type=1 AND component_id=50153 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040442 AND target_id2=0 AND target_value=0 AND component_sequence=4 AND required_count=1))));
INSERT INTO _mesa_remaining_guard VALUES('criterion_50154',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500040700 AND component_type=1 AND component_id=50154 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040443 AND target_id2=0 AND target_value=0 AND component_sequence=5 AND required_count=1))));
INSERT INTO _mesa_remaining_guard VALUES('criterion_50155',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500040700 AND component_type=1 AND component_id=50155 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040444 AND target_id2=0 AND target_value=0 AND component_sequence=6 AND required_count=1))));
INSERT INTO _mesa_remaining_guard VALUES('criterion_50156',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500040700 AND component_type=1 AND component_id=50156 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040445 AND target_id2=0 AND target_value=0 AND component_sequence=7 AND required_count=1))));
INSERT INTO _mesa_remaining_guard VALUES('criterion_50157',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500040700 AND component_type=1 AND component_id=50157 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040446 AND target_id2=0 AND target_value=0 AND component_sequence=8 AND required_count=1))));
INSERT INTO _mesa_remaining_guard VALUES('criterion_50158',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500040700 AND component_type=1 AND component_id=50158 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040447 AND target_id2=0 AND target_value=0 AND component_sequence=9 AND required_count=1))));
INSERT INTO _mesa_remaining_guard VALUES('criterion_50159',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500040700 AND component_type=1 AND component_id=50159 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040448 AND target_id2=0 AND target_value=0 AND component_sequence=10 AND required_count=1))));
INSERT INTO _mesa_remaining_guard VALUES('criterion_50160',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500040700 AND component_type=1 AND component_id=50160 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040449 AND target_id2=0 AND target_value=0 AND component_sequence=11 AND required_count=1))));
INSERT INTO _mesa_remaining_guard VALUES('criterion_50161',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500040700 AND component_type=1 AND component_id=50161 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040450 AND target_id2=0 AND target_value=0 AND component_sequence=12 AND required_count=1))));
INSERT INTO _mesa_remaining_guard VALUES('criterion_50137',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500040500 AND component_type=1 AND component_id=50137 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040451 AND target_id2=0 AND target_value=0 AND component_sequence=1 AND required_count=1))));
INSERT INTO _mesa_remaining_guard VALUES('criterion_50138',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500040500 AND component_type=1 AND component_id=50138 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040452 AND target_id2=0 AND target_value=0 AND component_sequence=2 AND required_count=1))));
INSERT INTO _mesa_remaining_guard VALUES('criterion_50139',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500040500 AND component_type=1 AND component_id=50139 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040453 AND target_id2=0 AND target_value=0 AND component_sequence=3 AND required_count=1))));
INSERT INTO _mesa_remaining_guard VALUES('criterion_50140',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500040500 AND component_type=1 AND component_id=50140 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040454 AND target_id2=0 AND target_value=0 AND component_sequence=4 AND required_count=1))));
INSERT INTO _mesa_remaining_guard VALUES('criterion_50141',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500040500 AND component_type=1 AND component_id=50141 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040455 AND target_id2=0 AND target_value=0 AND component_sequence=5 AND required_count=1))));
INSERT INTO _mesa_remaining_guard VALUES('criterion_50142',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500040500 AND component_type=1 AND component_id=50142 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040456 AND target_id2=0 AND target_value=0 AND component_sequence=6 AND required_count=1))));
INSERT INTO _mesa_remaining_guard VALUES('reward_set_3040456',(NOT EXISTS(SELECT 1 FROM reward_sets WHERE reward_set_id=3040456 AND title<>'Dorina''s Lament')AND NOT EXISTS(SELECT 1 FROM reward_sources WHERE reward_set_id=3040456 AND NOT(source_type=2 AND source_id=3040456))AND NOT EXISTS(SELECT 1 FROM reward_sources WHERE source_type=2 AND source_id=3040456 AND reward_set_id<>3040456)));
INSERT INTO _mesa_remaining_guard VALUES('option_ownership_3040456',(NOT EXISTS(SELECT 1 FROM reward_options WHERE reward_set_id=3040456 AND NOT((option_id=1 AND label='Experience' AND common_to_all=1 AND flags=0 AND class_mask=65535) OR (option_id=2 AND label='Dryad Tender Bauble' AND common_to_all=0 AND flags=0 AND class_mask=65535) OR (option_id=3 AND label='Dryad Focusing Bauble' AND common_to_all=0 AND flags=0 AND class_mask=65535) OR (option_id=4 AND label='Dryad Protector Bauble' AND common_to_all=0 AND flags=0 AND class_mask=65535) OR (option_id=5 AND label='Dryad Maiden Bauble' AND common_to_all=0 AND flags=0 AND class_mask=65535)))));
INSERT INTO _mesa_remaining_guard VALUES('option_links_3040456',(NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_set_id=3040456 AND NOT((option_id=1 AND sequence=0 AND reward_id=304045601) OR (option_id=2 AND sequence=0 AND reward_id=304045602) OR (option_id=3 AND sequence=0 AND reward_id=304045603) OR (option_id=4 AND sequence=0 AND reward_id=304045604) OR (option_id=5 AND sequence=0 AND reward_id=304045605)))));
INSERT INTO _mesa_remaining_guard VALUES('reward_304045601',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304045601 AND description<>'May2013 Mesa remaining option 304045601')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304045601 AND NOT(reward_set_id=3040456 AND option_id=1))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304045601)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304045602',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304045602 AND description<>'May2013 Mesa remaining option 304045602')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304045602 AND NOT(reward_set_id=3040456 AND option_id=2))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304045602)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304045603',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304045603 AND description<>'May2013 Mesa remaining option 304045603')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304045603 AND NOT(reward_set_id=3040456 AND option_id=3))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304045603)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304045604',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304045604 AND description<>'May2013 Mesa remaining option 304045604')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304045604 AND NOT(reward_set_id=3040456 AND option_id=4))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304045604)));
INSERT INTO _mesa_remaining_guard VALUES('reward_304045605',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304045605 AND description<>'May2013 Mesa remaining option 304045605')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304045605 AND NOT(reward_set_id=3040456 AND option_id=5))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304045605)));
START TRANSACTION;
INSERT INTO tasks(`id`,`type`,`title`,`description`,`reward_text`,`reward_id_list`,`cash_reward`,`exp_reward`,`reward_method`,`min_level`,`repeatable`,`faction_reward`,`faction_amount`,`enabled`,`duration`)VALUES
(3040421,2,'Wolf Skins for Madu','Wolf Skins: slay the required creatures; Loot Low Quality Wolf Skin; Loot Medium Quality Wolf Skin; Loot High Quality Wolf Skin; Deliver Low Quality Wolf Skin to Scout Madu; Deliver Medium Quality Wolf Skin to Scout Madu; Deliver High Quality Wolf Skin to Scout Madu.','','',0,0,3,40,1,0,0,0,0),
(3040422,2,'Bear Pelts for Madu','Bear Pelts: slay the required creatures; Loot Low Quality Bear Skin; Loot Medium Quality Bear Skin; Loot High Quality Bear Skin; Deliver Low Quality Bear Skin to Scout Madu; Deliver Medium Quality Bear Skin to Scout Madu; Deliver High Quality Bear Skin to Scout Madu.','','',0,0,3,40,1,0,0,0,0),
(3040423,2,'Snake Skins for Madu','Snake Skins: slay the required creatures; Loot Large Snake Fang; Loot Snake Skin; Loot Snake Egg; Deliver Large Snake Fang to Scout Madu; Deliver Snake Skin to Scout Madu; Deliver Snake Egg to Scout Madu.','','',0,0,3,40,1,0,0,0,0),
(3040424,2,'Spider Silk for Madu','Spider Silk: slay the required creatures; Loot Spider Silk; Loot Spider Legs; Loot Recluse Venom Sac; Deliver Spider Silk to Scout Madu; Deliver Spider Legs to Scout Madu; Deliver Recluse Venom Sac to Scout Madu.','','',0,0,3,40,1,0,0,0,0),
(3040425,2,'Madu Needs More Supplies','Loot Low Quality Wolf Skin; Loot Medium Quality Wolf Skin; Loot Low Quality Bear Skin; Loot Medium Quality Bear Skin; Loot Snake Skin; Loot Snake Fang; Loot Spider Silk; Loot Spider Legs; Deliver Low Quality Wolf Skin to Scout Madu; Deliver Medium Quality Wolf Skin to Scout Madu; Deliver Low Quality Bear Skin to Scout Madu; Deliver Medium Quality Bear Skin to Scout Madu; Deliver Snake Skin to Scout Madu; Deliver Snake Fang to Scout Madu; Deliver Spider Silk to Scout Madu; Deliver Spider Legs to Scout Madu.','','',0,0,3,40,1,0,0,0,0),
(3040426,2,'Kill Fantoma','Kill Fantoma: slay the required creatures; Loot Fantoma''s Pelt; Deliver Fantoma''s Pelt to Scout Madu.','','',0,0,3,40,1,0,0,0,0),
(3040427,2,'Kill Ursalua','Kill Ursalua: slay the required creatures; Loot Ursalua''s Pelt; Deliver Ursalua''s Pelt to Scout Madu.','','',0,0,3,40,1,0,0,0,0),
(3040428,2,'Pluck It!','Collect Sleek Griffon Feather; Hail Marilena at the Windwillow.','','',0,1000,0,45,1,0,0,0,0),
(3040429,2,'Harpy Horrors','Collect Harpy Plume; Hail Marilena at the Windwillow.','','',0,1000,0,45,1,0,0,0,0),
(3040430,2,'Vermin Elimination','Kill Wolves; Kill Bears; Kill Diamondback snakes; Kill Earthen ooze; Hail Laurentiu at the Minohten camp.','','',0,1000,0,40,1,0,0,0,0),
(3040431,2,'Birds of a Feather','Kill Griffons; Hail Laurentiu at the Minohten camp.','','',0,1000,0,45,0,0,0,0,0),
(3040432,2,'Harping on Harpies','Kill Harpies; Hail Laurentiu at the Minohten camp.','','',0,1000,0,45,0,0,0,0,0),
(3040433,2,'Dromrek Must Die','Kill Dromrek; Hail Laurentiu at the Minohten camp.','','',0,1000,0,50,0,0,0,0,0),
(3040434,2,'Cleanse Serpent''s Falls','Kill Waterfall potameids; Hail Laurentiu at the Minohten camp.','','',0,1000,0,53,0,0,0,0,0),
(3040435,2,'Tudor''s Beer','Gather Fresh Mesa Streamwater; Gather Hops; Gather Indigenous Mesa Yeast; Gather Malt; Create Liviu''s Dark Stout; Deliver Liviu''s Dark Stout to Tudor.','','',0,1000,0,40,0,0,0,0,0),
(3040436,2,'Tudor''s Ale','Gather Barley; Gather Hops; Gather Worn Cask; Gather Rawhide Canteen; Create Liviu''s Finest Brew; Deliver Liviu''s Finest Brew to Tudor.','','',0,1000,0,40,0,0,0,0,0),
(3040437,2,'Tudor''s Wine','Gather Bottle; Gather Dromrek Barbera Grapes; Gather Griffon Feather Spores; Gather Water Flask; Create Tudor''s Aged Merlot; Deliver Tudor''s Aged Merlot to Tudor.','','',0,1000,0,40,0,0,0,0,0),
(3040438,2,'Tudor''s Spirits','Gather Flask of Mesa Stormwater; Gather Goru`kar Oakwood Barrel; Gather Lingering Dryad Skull; Gather Tanglewood Seed Pod; Create Tudor''s Stormwater Whiskey; Deliver Tudor''s Stormwater Whiskey to Tudor.','','',0,1000,0,40,0,0,0,0,0),
(3040439,2,'Ciodaru''s Love','Speak with 397100; Ask Kathryn about her health; Ask Kathryn about her gemstone; Ask Kathryn about her drink; Ask Kathryn about her food; Ask Kathryn about her color; Ask Kathryn about her scent; Tell Ciodaru about Kathryn''s health; Tell Ciodaru about Kathryn''s gemstone; Tell Ciodaru about Kathryn''s drink; Tell Ciodaru about Kathryn''s food; Tell Ciodaru about Kathryn''s color; Tell Ciodaru about Kathryn''s scent; Speak with 397118.','','',0,1000,0,45,1,0,0,0,0),
(3040440,2,'Ciodaru''s First Gift','Speak with 394115; Loot Raw Silver; Loot Lightstone; Loot Section of Mesa Snake Pancreas; Create Glowing Green Silver; Create Glowing Emerald Pendant; Deliver Glowing Emerald Pendant; (Optional) Give crafting material 97233; (Optional) Give crafting material 10300; (Optional) Give crafting material 97231; (Optional) Give crafting material 10029; (Optional) Pay10platinum for the completed combine.','','',0,1000,0,45,1,0,0,0,0),
(3040441,2,'Ciodaru''s Second Gift','Speak with 394146; Collect Pond Water behind Ekaterina; Loot Spider Silk; Loot Mesa Recluse Spinneret; Create Spider Silk Filter; Create Chilled Pure Water; Deliver Chilled Pure Water; (Optional) Give crafting material 97742; (Optional) Give crafting material 13041; (Optional) Give crafting material 97230; (Optional) Give crafting material 9650; (Optional) Give crafting material 97735; (Optional) Pay10platinum for the completed combine.','','',0,1000,0,45,1,0,0,0,0),
(3040442,2,'Protect Kathryn','Approach Kathryn and defend her; Kill a Tuffein thug; Speak with 397118.','','',0,1000,0,45,1,0,0,0,0),
(3040443,2,'Ciodaru''s Third Gift','Speak with 394168; Loot Windwillow Acorn; Loot Earthen Ooze Slime; Create Spiced Wind Willow Acorns; Deliver Spiced Wind Willow Acorns; (Optional) Give crafting material 97236; (Optional) Give crafting material 97228; (Optional) Give crafting material 13425; (Optional) Give crafting material 29742; (Optional) Give crafting material 58280; (Optional) Pay10platinum for the completed combine.','','',0,1000,0,45,1,0,0,0,0),
(3040444,2,'Ciodaru''s Fourth Gift','Speak with 394083; Loot Spider Silk; Loot Mesa Recluse Spinneret; Loot Snake Skin; Loot Spiderling Silk; Create Silk Swatch; Create Silk Thread; Create Forest Green Silk Swatch; Create Shimmering Dryad Dress; Deliver Shimmering Dryad Dress; (Optional) Give crafting material 13041; (Optional) Give crafting material 97230; (Optional) Give crafting material 88121; (Optional) Give crafting material 13099; (Optional) Give crafting material 22104; (Optional) Pay10platinum for the completed combine.','','',0,1000,0,45,1,0,0,0,0),
(3040445,2,'Protect Kathryn Again','Approach Kathryn and defend her; Kill a Tuffein thug; Kill a Tuffein grabber; Speak with 397118.','','',0,1000,0,45,1,0,0,0,0),
(3040446,2,'Ciodaru''s Fifth Gift','Speak with 394066; Loot Recluse Venom Sac; Loot Large Snake Fang; Loot Snake Skin; Loot Earthen Ooze Slime; Create Envenomed Steel; Create Envenomed Steel Blade; Create Envenomed Athame; Deliver Envenomed Athame; (Optional) Give crafting material 97234; (Optional) Give crafting material 97229; (Optional) Give crafting material 88121; (Optional) Give crafting material 97228; (Optional) Give crafting material 22075; (Optional) Give crafting material 10468; (Optional) Pay10platinum for the completed combine.','','',0,1000,0,45,1,0,0,0,0),
(3040447,2,'Ciodaru''s Sixth Gift','Speak with 394060; Loot Spider Fang; Loot Mesa Recluse Spinneret; Loot Earthen Ooze Slime; Loot Faceted Lightstone; Create Fine White Clay; Create Unfired Fine Green Perfume Bottle; Create Fine Green Perfume Bottle; Deliver Fine Green Perfume Bottle; (Optional) Give crafting material 51850; (Optional) Give crafting material 97230; (Optional) Give crafting material 97228; (Optional) Give crafting material 97194; (Optional) Give crafting material 29355; (Optional) Give crafting material 16908; (Optional) Pay10platinum for the completed combine.','','',0,1000,0,45,1,0,0,0,0),
(3040448,2,'Protect Kathryn Some More','Approach Kathryn and defend her; Kill a Tuffein thug; Kill a Tuffein grabber; Kill a Tuffein thug; Kill a Tuffein grabber; Loot Note from Razvan; Deliver Note from Razvan.','','',0,1000,0,45,1,0,0,0,0),
(3040449,2,'Who Wants to Kill Kathryn?','Find Tuffein encampment; Kill Tuffein; Kill Razvan; Speak with 397118.','','',0,1000,0,45,1,0,0,0,0),
(3040450,2,'Ciodaru''s Gift Box','Speak with 394155; Loot Windwillow Branch; Loot Spider Eye; Loot Large Snake Fang; Loot Earthen Ooze Slime; Create Ciodaru''s Gift Box Parts; Create Petrified Spider Eyes; Create Ciodaru''s Gift Box; Deliver Ciodaru''s Gift Box; Deliver Ciodaru''s Gift Box; Tell Ciodaru Kathryn loves him; (Optional) Give crafting material 97237; (Optional) Give crafting material 97235; (Optional) Give crafting material 97229; (Optional) Give crafting material 97228; (Optional) Pay10platinum for the completed combine.','','',0,1000,0,45,1,0,0,0,0),
(3040451,2,'Dorina''s Love','Observe Simu''s day at camp 1; Observe Simu''s day at camp 2; Observe Simu''s day at camp 3; Observe Simu''s day at camp 4; Observe Simu''s day at ridge 5; Observe Simu''s day at ridge 6; Observe Simu''s day at tent 7; Speak with 397086.','','',0,1000,0,40,0,0,0,0,0),
(3040452,2,'Dorina''s Love Letter','Deliver Letter to Simu; Give Simu space to read the letter; Speak with 397120; Speak with 397086.','','',0,1000,0,40,0,0,0,0,0),
(3040453,2,'Dorina''s Gift','Loot Spider Silk; Loot Recluse Spider Fang; Loot Wolf Canine; Loot Supple Wolf Pelt; Loot Large Snake Fang; Deliver Spider Silk; Deliver Recluse Spider Fang; Deliver Wolf Canine; Deliver Supple Wolf Pelt; Deliver Large Snake Fang; Deliver Folded Silkfang Pack; Speak with 397086.','','',0,1000,0,40,0,0,0,0,0),
(3040454,2,'Dorina''s Personalized Gift','Create Spider Silk Thread; Create Spool of Spider Silk Thread; Create Wolf Canine Bead; Create Snake Fang Bead; Create String of Teeth; Create Folded Silkfang Pack; Deliver Folded Silkfang Pack; Deliver Folded Silkfang Pack; Speak with 397086.','','',0,1000,0,40,0,0,0,0,0),
(3040455,2,'Dorina''s Potion','Speak with 394228; Loot Bear Heart; Loot Spider Brain; Loot Snake Skin; Loot Blood-soaked Patch of Fur; Deliver Bear Heart; Deliver Spider Brain; Deliver Snake Skin; Deliver Blood-soaked Patch of Fur; Pay Alchemist Naeema10gold; Deliver Philter of Anamorata; Deliver Philter of Anamorata; Speak with 397086.','','',0,1000,0,40,0,0,0,0,0),
(3040456,2,'Dorina''s Lament','Speak with 395210; Loot Cultivated Jumjum Pollen; Loot Honeycomb; Deliver Cultivated Jumjum Pollen; Deliver Honeycomb; Deliver Soporific Honey; Protect Simu on his walk to Dorina; Speak with 397086.','','',0,0,3,40,0,0,0,0,0)
ON DUPLICATE KEY UPDATE `type`=VALUES(`type`),`title`=VALUES(`title`),`description`=VALUES(`description`),`reward_text`=VALUES(`reward_text`),`reward_id_list`=VALUES(`reward_id_list`),`cash_reward`=VALUES(`cash_reward`),`exp_reward`=VALUES(`exp_reward`),`reward_method`=VALUES(`reward_method`),`min_level`=VALUES(`min_level`),`repeatable`=VALUES(`repeatable`),`faction_reward`=VALUES(`faction_reward`),`faction_amount`=VALUES(`faction_amount`),`enabled`=VALUES(`enabled`),`duration`=VALUES(`duration`);
DELETE FROM task_activities WHERE taskid IN(3040421,3040422,3040423,3040424,3040425,3040426,3040427,3040428,3040429,3040430,3040431,3040432,3040433,3040434,3040435,3040436,3040437,3040438,3040439,3040440,3040441,3040442,3040443,3040444,3040445,3040446,3040447,3040448,3040449,3040450,3040451,3040452,3040453,3040454,3040455,3040456);
INSERT INTO task_activities(`taskid`,`activityid`,`req_activity_id`,`step`,`activitytype`,`target_name`,`goalmethod`,`goalcount`,`description_override`,`npc_match_list`,`item_id_list`,`zones`,`spell_list`,`optional`,`min_x`,`max_x`,`min_y`,`max_y`,`min_z`,`max_z`)VALUES
(3040421,0,-1,1,2,'',0,10,'Wolf Skins: slay the required creatures','397001|397002|397004|397035','','397','',0,0,0,0,0,0,0),
(3040421,1,-1,1,3,'',0,5,'Loot Low Quality Wolf Skin','','13753','397','',0,0,0,0,0,0,0),
(3040421,2,-1,1,3,'',0,3,'Loot Medium Quality Wolf Skin','','13754','397','',0,0,0,0,0,0,0),
(3040421,3,-1,1,3,'',0,1,'Loot High Quality Wolf Skin','','13755','397','',0,0,0,0,0,0,0),
(3040421,4,-1,2,1,'',0,5,'Deliver Low Quality Wolf Skin to Scout Madu','397007','13753','397','',0,0,0,0,0,0,0),
(3040421,5,-1,2,1,'',0,3,'Deliver Medium Quality Wolf Skin to Scout Madu','397007','13754','397','',0,0,0,0,0,0,0),
(3040421,6,-1,2,1,'',0,1,'Deliver High Quality Wolf Skin to Scout Madu','397007','13755','397','',0,0,0,0,0,0,0),
(3040422,0,-1,1,2,'',0,15,'Bear Pelts: slay the required creatures','397005|397015|397020','','397','',0,0,0,0,0,0,0),
(3040422,1,-1,1,3,'',0,5,'Loot Low Quality Bear Skin','','13750','397','',0,0,0,0,0,0,0),
(3040422,2,-1,1,3,'',0,3,'Loot Medium Quality Bear Skin','','13751','397','',0,0,0,0,0,0,0),
(3040422,3,-1,1,3,'',0,1,'Loot High Quality Bear Skin','','13752','397','',0,0,0,0,0,0,0),
(3040422,4,-1,2,1,'',0,5,'Deliver Low Quality Bear Skin to Scout Madu','397007','13750','397','',0,0,0,0,0,0,0),
(3040422,5,-1,2,1,'',0,3,'Deliver Medium Quality Bear Skin to Scout Madu','397007','13751','397','',0,0,0,0,0,0,0),
(3040422,6,-1,2,1,'',0,1,'Deliver High Quality Bear Skin to Scout Madu','397007','13752','397','',0,0,0,0,0,0,0),
(3040423,0,-1,1,2,'',0,10,'Snake Skins: slay the required creatures','397003|397008|397010','','397','',0,0,0,0,0,0,0),
(3040423,1,-1,1,3,'',0,5,'Loot Large Snake Fang','','97229','397','',0,0,0,0,0,0,0),
(3040423,2,-1,1,3,'',0,3,'Loot Snake Skin','','88121','397','',0,0,0,0,0,0,0),
(3040423,3,-1,1,3,'',0,1,'Loot Snake Egg','','13088','397','',0,0,0,0,0,0,0),
(3040423,4,-1,2,1,'',0,5,'Deliver Large Snake Fang to Scout Madu','397007','97229','397','',0,0,0,0,0,0,0),
(3040423,5,-1,2,1,'',0,3,'Deliver Snake Skin to Scout Madu','397007','88121','397','',0,0,0,0,0,0,0),
(3040423,6,-1,2,1,'',0,1,'Deliver Snake Egg to Scout Madu','397007','13088','397','',0,0,0,0,0,0,0),
(3040424,0,-1,1,2,'',0,15,'Spider Silk: slay the required creatures','397089|397133|397135|397141','','397','',0,0,0,0,0,0,0),
(3040424,1,-1,1,3,'',0,5,'Loot Spider Silk','','13041','397','',0,0,0,0,0,0,0),
(3040424,2,-1,1,3,'',0,3,'Loot Spider Legs','','13417','397','',0,0,0,0,0,0,0),
(3040424,3,-1,1,3,'',0,1,'Loot Recluse Venom Sac','','97234','397','',0,0,0,0,0,0,0),
(3040424,4,-1,2,1,'',0,5,'Deliver Spider Silk to Scout Madu','397007','13041','397','',0,0,0,0,0,0,0),
(3040424,5,-1,2,1,'',0,3,'Deliver Spider Legs to Scout Madu','397007','13417','397','',0,0,0,0,0,0,0),
(3040424,6,-1,2,1,'',0,1,'Deliver Recluse Venom Sac to Scout Madu','397007','97234','397','',0,0,0,0,0,0,0),
(3040425,0,-1,1,3,'',0,5,'Loot Low Quality Wolf Skin','','13753','397','',0,0,0,0,0,0,0),
(3040425,1,-1,1,3,'',0,3,'Loot Medium Quality Wolf Skin','','13754','397','',0,0,0,0,0,0,0),
(3040425,2,-1,1,3,'',0,5,'Loot Low Quality Bear Skin','','13750','397','',0,0,0,0,0,0,0),
(3040425,3,-1,1,3,'',0,3,'Loot Medium Quality Bear Skin','','13751','397','',0,0,0,0,0,0,0),
(3040425,4,-1,1,3,'',0,5,'Loot Snake Skin','','88121','397','',0,0,0,0,0,0,0),
(3040425,5,-1,1,3,'',0,3,'Loot Snake Fang','','13067','397','',0,0,0,0,0,0,0),
(3040425,6,-1,1,3,'',0,5,'Loot Spider Silk','','13041','397','',0,0,0,0,0,0,0),
(3040425,7,-1,1,3,'',0,3,'Loot Spider Legs','','13417','397','',0,0,0,0,0,0,0),
(3040425,8,-1,2,1,'',0,5,'Deliver Low Quality Wolf Skin to Scout Madu','397007','13753','397','',0,0,0,0,0,0,0),
(3040425,9,-1,2,1,'',0,3,'Deliver Medium Quality Wolf Skin to Scout Madu','397007','13754','397','',0,0,0,0,0,0,0),
(3040425,10,-1,2,1,'',0,5,'Deliver Low Quality Bear Skin to Scout Madu','397007','13750','397','',0,0,0,0,0,0,0),
(3040425,11,-1,2,1,'',0,3,'Deliver Medium Quality Bear Skin to Scout Madu','397007','13751','397','',0,0,0,0,0,0,0),
(3040425,12,-1,2,1,'',0,5,'Deliver Snake Skin to Scout Madu','397007','88121','397','',0,0,0,0,0,0,0),
(3040425,13,-1,2,1,'',0,3,'Deliver Snake Fang to Scout Madu','397007','13067','397','',0,0,0,0,0,0,0),
(3040425,14,-1,2,1,'',0,5,'Deliver Spider Silk to Scout Madu','397007','13041','397','',0,0,0,0,0,0,0),
(3040425,15,-1,2,1,'',0,3,'Deliver Spider Legs to Scout Madu','397007','13417','397','',0,0,0,0,0,0,0),
(3040426,0,-1,1,2,'',0,1,'Kill Fantoma: slay the required creatures','397904','','397','',0,0,0,0,0,0,0),
(3040426,1,-1,1,3,'',0,1,'Loot Fantoma''s Pelt','','88127','397','',0,0,0,0,0,0,0),
(3040426,2,-1,2,1,'',0,1,'Deliver Fantoma''s Pelt to Scout Madu','397007','88127','397','',0,0,0,0,0,0,0),
(3040427,0,-1,1,2,'',0,1,'Kill Ursalua: slay the required creatures','397073','','397','',0,0,0,0,0,0,0),
(3040427,1,-1,1,3,'',0,1,'Loot Ursalua''s Pelt','','88128','397','',0,0,0,0,0,0,0),
(3040427,2,-1,2,1,'',0,1,'Deliver Ursalua''s Pelt to Scout Madu','397007','88128','397','',0,0,0,0,0,0,0),
(3040428,0,-1,1,3,'',0,8,'Collect Sleek Griffon Feather','','57015','397','',0,0,0,0,0,0,0),
(3040428,1,-1,2,4,'',0,1,'Hail Marilena at the Windwillow','397043','','397','',0,0,0,0,0,0,0),
(3040429,0,-1,1,3,'',0,8,'Collect Harpy Plume','','57016','397','',0,0,0,0,0,0,0),
(3040429,1,-1,2,4,'',0,1,'Hail Marilena at the Windwillow','397043','','397','',0,0,0,0,0,0,0),
(3040430,0,-1,1,2,'',0,4,'Kill Wolves','397001|397002|397004|397035','','397','',0,0,0,0,0,0,0),
(3040430,1,-1,1,2,'',0,4,'Kill Bears','397005|397015|397020','','397','',0,0,0,0,0,0,0),
(3040430,2,-1,1,2,'',0,4,'Kill Diamondback snakes','397016|397017|397018','','397','',0,0,0,0,0,0,0),
(3040430,3,-1,1,2,'',0,4,'Kill Earthen ooze','397144|397154|397156|397166','','397','',0,0,0,0,0,0,0),
(3040430,4,-1,2,4,'',0,1,'Hail Laurentiu at the Minohten camp','397097','','397','',0,0,0,0,0,0,0),
(3040431,0,-1,1,2,'',0,12,'Kill Griffons','397241|397245|397261|397266|397267','','397','',0,0,0,0,0,0,0),
(3040431,1,-1,2,4,'',0,1,'Hail Laurentiu at the Minohten camp','397097','','397','',0,0,0,0,0,0,0),
(3040432,0,-1,1,2,'',0,12,'Kill Harpies','397248|397252|397254|397256|397257|397260|397264|397269|397270|397271|397273|397274','','397','',0,0,0,0,0,0,0),
(3040432,1,-1,2,4,'',0,1,'Hail Laurentiu at the Minohten camp','397097','','397','',0,0,0,0,0,0,0),
(3040433,0,-1,1,2,'',0,12,'Kill Dromrek','397155|397163|397164|397167|397171|397175|397177|397187|397189|397190|397194|397197|397198|397209|397217|397223|397249','','397','',0,0,0,0,0,0,0),
(3040433,1,-1,2,4,'',0,1,'Hail Laurentiu at the Minohten camp','397097','','397','',0,0,0,0,0,0,0),
(3040434,0,-1,1,2,'',0,12,'Kill Waterfall potameids','397233|397236|397237|397238|397240|397242|397244|397258|397262','','397','',0,0,0,0,0,0,0),
(3040434,1,-1,2,4,'',0,1,'Hail Laurentiu at the Minohten camp','397097','','397','',0,0,0,0,0,0,0),
(3040435,0,-1,1,255,'',0,1,'Gather Fresh Mesa Streamwater','','87151','397','',0,0,0,0,0,0,0),
(3040435,1,-1,1,255,'',0,1,'Gather Hops','','16591','397','',0,0,0,0,0,0,0),
(3040435,2,-1,1,255,'',0,1,'Gather Indigenous Mesa Yeast','','87154','397','',0,0,0,0,0,0,0),
(3040435,3,-1,1,255,'',0,1,'Gather Malt','','16595','397','',0,0,0,0,0,0,0),
(3040435,4,-1,2,6,'',0,1,'Create Liviu''s Dark Stout','','87167','0','',0,0,0,0,0,0,0),
(3040435,5,-1,3,1,'',0,1,'Deliver Liviu''s Dark Stout to Tudor','397096','87167','397','',0,0,0,0,0,0,0),
(3040436,0,-1,1,255,'',0,1,'Gather Barley','','16590','397','',0,0,0,0,0,0,0),
(3040436,1,-1,1,255,'',0,1,'Gather Hops','','16591','397','',0,0,0,0,0,0,0),
(3040436,2,-1,1,255,'',0,1,'Gather Worn Cask','','87157','397','',0,0,0,0,0,0,0),
(3040436,3,-1,1,255,'',0,1,'Gather Rawhide Canteen','','87158','397','',0,0,0,0,0,0,0),
(3040436,4,-1,2,6,'',0,1,'Create Liviu''s Finest Brew','','87168','0','',0,0,0,0,0,0,0),
(3040436,5,-1,3,1,'',0,1,'Deliver Liviu''s Finest Brew to Tudor','397096','87168','397','',0,0,0,0,0,0,0),
(3040437,0,-1,1,255,'',0,1,'Gather Bottle','','16598','397','',0,0,0,0,0,0,0),
(3040437,1,-1,1,255,'',0,1,'Gather Dromrek Barbera Grapes','','87162','397','',0,0,0,0,0,0,0),
(3040437,2,-1,1,255,'',0,1,'Gather Griffon Feather Spores','','87161','397','',0,0,0,0,0,0,0),
(3040437,3,-1,1,255,'',0,1,'Gather Water Flask','','13006','397','',0,0,0,0,0,0,0),
(3040437,4,-1,2,6,'',0,1,'Create Tudor''s Aged Merlot','','87169','0','',0,0,0,0,0,0,0),
(3040437,5,-1,3,1,'',0,1,'Deliver Tudor''s Aged Merlot to Tudor','397096','87169','397','',0,0,0,0,0,0,0),
(3040438,0,-1,1,255,'',0,1,'Gather Flask of Mesa Stormwater','','87166','397','',0,0,0,0,0,0,0),
(3040438,1,-1,1,255,'',0,1,'Gather Goru`kar Oakwood Barrel','','87165','397','',0,0,0,0,0,0,0),
(3040438,2,-1,1,255,'',0,1,'Gather Lingering Dryad Skull','','87164','397','',0,0,0,0,0,0,0),
(3040438,3,-1,1,255,'',0,1,'Gather Tanglewood Seed Pod','','87163','397','',0,0,0,0,0,0,0),
(3040438,4,-1,2,6,'',0,1,'Create Tudor''s Stormwater Whiskey','','87170','0','',0,0,0,0,0,0,0),
(3040438,5,-1,3,1,'',0,1,'Deliver Tudor''s Stormwater Whiskey to Tudor','397096','87170','397','',0,0,0,0,0,0,0),
(3040439,0,-1,1,4,'',0,1,'Speak with 397100','397100','','397','',0,0,0,0,0,0,0),
(3040439,1,-1,2,255,'',0,1,'Ask Kathryn about her health','397100','','397','',0,0,0,0,0,0,0),
(3040439,2,-1,2,255,'',0,1,'Ask Kathryn about her gemstone','397100','','397','',0,0,0,0,0,0,0),
(3040439,3,-1,2,255,'',0,1,'Ask Kathryn about her drink','397100','','397','',0,0,0,0,0,0,0),
(3040439,4,-1,2,255,'',0,1,'Ask Kathryn about her food','397100','','397','',0,0,0,0,0,0,0),
(3040439,5,-1,2,255,'',0,1,'Ask Kathryn about her color','397100','','397','',0,0,0,0,0,0,0),
(3040439,6,-1,2,255,'',0,1,'Ask Kathryn about her scent','397100','','397','',0,0,0,0,0,0,0),
(3040439,7,-1,3,255,'',0,1,'Tell Ciodaru about Kathryn''s health','397118','','397','',0,0,0,0,0,0,0),
(3040439,8,-1,3,255,'',0,1,'Tell Ciodaru about Kathryn''s gemstone','397118','','397','',0,0,0,0,0,0,0),
(3040439,9,-1,3,255,'',0,1,'Tell Ciodaru about Kathryn''s drink','397118','','397','',0,0,0,0,0,0,0),
(3040439,10,-1,3,255,'',0,1,'Tell Ciodaru about Kathryn''s food','397118','','397','',0,0,0,0,0,0,0),
(3040439,11,-1,3,255,'',0,1,'Tell Ciodaru about Kathryn''s color','397118','','397','',0,0,0,0,0,0,0),
(3040439,12,-1,3,255,'',0,1,'Tell Ciodaru about Kathryn''s scent','397118','','397','',0,0,0,0,0,0,0),
(3040439,13,-1,4,4,'',0,1,'Speak with 397118','397118','','397','',0,0,0,0,0,0,0),
(3040440,0,-1,1,4,'',0,1,'Speak with 394115','394115','','394','',0,0,0,0,0,0,0),
(3040440,1,-1,2,3,'',0,1,'Loot Raw Silver','','97233','397','',0,0,0,0,0,0,0),
(3040440,2,-1,2,3,'',0,1,'Loot Lightstone','','10300','397','',0,0,0,0,0,0,0),
(3040440,3,-1,2,3,'',0,1,'Loot Section of Mesa Snake Pancreas','','97231','397','',0,0,0,0,0,0,0),
(3040440,4,-1,3,6,'',0,1,'Create Glowing Green Silver','','97740','0','',0,0,0,0,0,0,0),
(3040440,5,-1,3,6,'',0,1,'Create Glowing Emerald Pendant','','97739','0','',0,0,0,0,0,0,0),
(3040440,6,-1,4,1,'',0,1,'Deliver Glowing Emerald Pendant','397118','97739','397','',0,0,0,0,0,0,0),
(3040440,7,-1,3,1,'',0,1,'(Optional) Give crafting material 97233','394115','97233','394','',1,0,0,0,0,0,0),
(3040440,8,-1,3,1,'',0,1,'(Optional) Give crafting material 10300','394115','10300','394','',1,0,0,0,0,0,0),
(3040440,9,-1,3,1,'',0,1,'(Optional) Give crafting material 97231','394115','97231','394','',1,0,0,0,0,0,0),
(3040440,10,-1,3,1,'',0,1,'(Optional) Give crafting material 10029','394115','10029','394','',1,0,0,0,0,0,0),
(3040440,11,-1,3,255,'',0,1,'(Optional) Pay10platinum for the completed combine','394115','','394','',1,0,0,0,0,0,0),
(3040441,0,-1,1,4,'',0,1,'Speak with 394146','394146','','394','',0,0,0,0,0,0,0),
(3040441,1,-1,2,255,'',0,1,'Collect Pond Water behind Ekaterina','','97742','397','',0,0,0,0,0,0,0),
(3040441,2,-1,3,3,'',0,2,'Loot Spider Silk','','13041','397','',0,0,0,0,0,0,0),
(3040441,3,-1,3,3,'',0,1,'Loot Mesa Recluse Spinneret','','97230','397','',0,0,0,0,0,0,0),
(3040441,4,-1,4,6,'',0,1,'Create Spider Silk Filter','','97745','0','',0,0,0,0,0,0,0),
(3040441,5,-1,4,6,'',0,1,'Create Chilled Pure Water','','97728','0','',0,0,0,0,0,0,0),
(3040441,6,-1,5,1,'',0,1,'Deliver Chilled Pure Water','397118','97728','397','',0,0,0,0,0,0,0),
(3040441,7,-1,4,1,'',0,1,'(Optional) Give crafting material 97742','394146','97742','394','',1,0,0,0,0,0,0),
(3040441,8,-1,4,1,'',0,2,'(Optional) Give crafting material 13041','394146','13041','394','',1,0,0,0,0,0,0),
(3040441,9,-1,4,1,'',0,1,'(Optional) Give crafting material 97230','394146','97230','394','',1,0,0,0,0,0,0),
(3040441,10,-1,4,1,'',0,1,'(Optional) Give crafting material 9650','394146','9650','394','',1,0,0,0,0,0,0),
(3040441,11,-1,4,1,'',0,1,'(Optional) Give crafting material 97735','394146','97735','394','',1,0,0,0,0,0,0),
(3040441,12,-1,4,255,'',0,1,'(Optional) Pay10platinum for the completed combine','394146','','394','',1,0,0,0,0,0,0),
(3040442,0,-1,1,255,'',0,1,'Approach Kathryn and defend her','397100','','397','',0,0,0,0,0,0,0),
(3040442,1,-1,2,2,'',2,1,'Kill a Tuffein thug','397901','','397','',0,0,0,0,0,0,0),
(3040442,2,-1,3,4,'',0,1,'Speak with 397118','397118','','397','',0,0,0,0,0,0,0),
(3040443,0,-1,1,4,'',0,1,'Speak with 394168','394168','','394','',0,0,0,0,0,0,0),
(3040443,1,-1,2,3,'',0,4,'Loot Windwillow Acorn','','97236','397','',0,0,0,0,0,0,0),
(3040443,2,-1,2,3,'',0,1,'Loot Earthen Ooze Slime','','97228','397','',0,0,0,0,0,0,0),
(3040443,3,-1,3,6,'',0,1,'Create Spiced Wind Willow Acorns','','97744','0','',0,0,0,0,0,0,0),
(3040443,4,-1,4,1,'',0,1,'Deliver Spiced Wind Willow Acorns','397118','97744','397','',0,0,0,0,0,0,0),
(3040443,5,-1,3,1,'',0,4,'(Optional) Give crafting material 97236','394168','97236','394','',1,0,0,0,0,0,0),
(3040443,6,-1,3,1,'',0,1,'(Optional) Give crafting material 97228','394168','97228','394','',1,0,0,0,0,0,0),
(3040443,7,-1,3,1,'',0,1,'(Optional) Give crafting material 13425','394168','13425','394','',1,0,0,0,0,0,0),
(3040443,8,-1,3,1,'',0,1,'(Optional) Give crafting material 29742','394168','29742','394','',1,0,0,0,0,0,0),
(3040443,9,-1,3,1,'',0,1,'(Optional) Give crafting material 58280','394168','58280','394','',1,0,0,0,0,0,0),
(3040443,10,-1,3,255,'',0,1,'(Optional) Pay10platinum for the completed combine','394168','','394','',1,0,0,0,0,0,0),
(3040444,0,-1,1,4,'',0,1,'Speak with 394083','394083','','394','',0,0,0,0,0,0,0),
(3040444,1,-1,2,3,'',0,4,'Loot Spider Silk','','13041','397','',0,0,0,0,0,0,0),
(3040444,2,-1,2,3,'',0,1,'Loot Mesa Recluse Spinneret','','97230','397','',0,0,0,0,0,0,0),
(3040444,3,-1,2,3,'',0,4,'Loot Snake Skin','','88121','397','',0,0,0,0,0,0,0),
(3040444,4,-1,2,3,'',0,4,'Loot Spiderling Silk','','13099','397','',0,0,0,0,0,0,0),
(3040444,5,-1,3,6,'',0,2,'Create Silk Swatch','','16482','0','',0,0,0,0,0,0,0),
(3040444,6,-1,3,6,'',0,2,'Create Silk Thread','','16486','0','',0,0,0,0,0,0,0),
(3040444,7,-1,3,6,'',0,1,'Create Forest Green Silk Swatch','','97738','0','',0,0,0,0,0,0,0),
(3040444,8,-1,3,6,'',0,1,'Create Shimmering Dryad Dress','','97743','0','',0,0,0,0,0,0,0),
(3040444,9,-1,4,1,'',0,1,'Deliver Shimmering Dryad Dress','397118','97743','397','',0,0,0,0,0,0,0),
(3040444,10,-1,3,1,'',0,4,'(Optional) Give crafting material 13041','394083','13041','394','',1,0,0,0,0,0,0),
(3040444,11,-1,3,1,'',0,1,'(Optional) Give crafting material 97230','394083','97230','394','',1,0,0,0,0,0,0),
(3040444,12,-1,3,1,'',0,4,'(Optional) Give crafting material 88121','394083','88121','394','',1,0,0,0,0,0,0),
(3040444,13,-1,3,1,'',0,4,'(Optional) Give crafting material 13099','394083','13099','394','',1,0,0,0,0,0,0),
(3040444,14,-1,3,1,'',0,1,'(Optional) Give crafting material 22104','394083','22104','394','',1,0,0,0,0,0,0),
(3040444,15,-1,3,255,'',0,1,'(Optional) Pay10platinum for the completed combine','394083','','394','',1,0,0,0,0,0,0),
(3040445,0,-1,1,255,'',0,1,'Approach Kathryn and defend her','397100','','397','',0,0,0,0,0,0,0),
(3040445,1,-1,2,2,'',2,1,'Kill a Tuffein thug','397901','','397','',0,0,0,0,0,0,0),
(3040445,2,-1,3,2,'',2,1,'Kill a Tuffein grabber','397902','','397','',0,0,0,0,0,0,0),
(3040445,3,-1,4,4,'',0,1,'Speak with 397118','397118','','397','',0,0,0,0,0,0,0),
(3040446,0,-1,1,4,'',0,1,'Speak with 394066','394066','','394','',0,0,0,0,0,0,0),
(3040446,1,-1,2,3,'',0,1,'Loot Recluse Venom Sac','','97234','397','',0,0,0,0,0,0,0),
(3040446,2,-1,2,3,'',0,2,'Loot Large Snake Fang','','97229','397','',0,0,0,0,0,0,0),
(3040446,3,-1,2,3,'',0,1,'Loot Snake Skin','','88121','397','',0,0,0,0,0,0,0),
(3040446,4,-1,2,3,'',0,1,'Loot Earthen Ooze Slime','','97228','397','',0,0,0,0,0,0,0),
(3040446,5,-1,3,6,'',0,1,'Create Envenomed Steel','','97733','0','',0,0,0,0,0,0,0),
(3040446,6,-1,3,6,'',0,1,'Create Envenomed Steel Blade','','97734','0','',0,0,0,0,0,0,0),
(3040446,7,-1,3,6,'',0,1,'Create Envenomed Athame','','97732','0','',0,0,0,0,0,0,0),
(3040446,8,-1,4,1,'',0,1,'Deliver Envenomed Athame','397118','97732','397','',0,0,0,0,0,0,0),
(3040446,9,-1,3,1,'',0,1,'(Optional) Give crafting material 97234','394066','97234','394','',1,0,0,0,0,0,0),
(3040446,10,-1,3,1,'',0,2,'(Optional) Give crafting material 97229','394066','97229','394','',1,0,0,0,0,0,0),
(3040446,11,-1,3,1,'',0,1,'(Optional) Give crafting material 88121','394066','88121','394','',1,0,0,0,0,0,0),
(3040446,12,-1,3,1,'',0,1,'(Optional) Give crafting material 97228','394066','97228','394','',1,0,0,0,0,0,0),
(3040446,13,-1,3,1,'',0,1,'(Optional) Give crafting material 22075','394066','22075','394','',1,0,0,0,0,0,0),
(3040446,14,-1,3,1,'',0,1,'(Optional) Give crafting material 10468','394066','10468','394','',1,0,0,0,0,0,0),
(3040446,15,-1,3,255,'',0,1,'(Optional) Pay10platinum for the completed combine','394066','','394','',1,0,0,0,0,0,0),
(3040447,0,-1,1,4,'',0,1,'Speak with 394060','394060','','394','',0,0,0,0,0,0,0),
(3040447,1,-1,2,3,'',0,8,'Loot Spider Fang','','51850','397','',0,0,0,0,0,0,0),
(3040447,2,-1,2,3,'',0,1,'Loot Mesa Recluse Spinneret','','97230','397','',0,0,0,0,0,0,0),
(3040447,3,-1,2,3,'',0,1,'Loot Earthen Ooze Slime','','97228','397','',0,0,0,0,0,0,0),
(3040447,4,-1,2,3,'',0,1,'Loot Faceted Lightstone','','97194','397','',0,0,0,0,0,0,0),
(3040447,5,-1,3,6,'',0,1,'Create Fine White Clay','','97737','0','',0,0,0,0,0,0,0),
(3040447,6,-1,3,6,'',0,1,'Create Unfired Fine Green Perfume Bottle','','97746','0','',0,0,0,0,0,0,0),
(3040447,7,-1,3,6,'',0,1,'Create Fine Green Perfume Bottle','','97736','0','',0,0,0,0,0,0,0),
(3040447,8,-1,4,1,'',0,1,'Deliver Fine Green Perfume Bottle','397118','97736','397','',0,0,0,0,0,0,0),
(3040447,9,-1,3,1,'',0,8,'(Optional) Give crafting material 51850','394060','51850','394','',1,0,0,0,0,0,0),
(3040447,10,-1,3,1,'',0,1,'(Optional) Give crafting material 97230','394060','97230','394','',1,0,0,0,0,0,0),
(3040447,11,-1,3,1,'',0,1,'(Optional) Give crafting material 97228','394060','97228','394','',1,0,0,0,0,0,0),
(3040447,12,-1,3,1,'',0,1,'(Optional) Give crafting material 97194','394060','97194','394','',1,0,0,0,0,0,0),
(3040447,13,-1,3,1,'',0,1,'(Optional) Give crafting material 29355','394060','29355','394','',1,0,0,0,0,0,0),
(3040447,14,-1,3,1,'',0,1,'(Optional) Give crafting material 16908','394060','16908','394','',1,0,0,0,0,0,0),
(3040447,15,-1,3,255,'',0,1,'(Optional) Pay10platinum for the completed combine','394060','','394','',1,0,0,0,0,0,0),
(3040448,0,-1,1,255,'',0,1,'Approach Kathryn and defend her','397100','','397','',0,0,0,0,0,0,0),
(3040448,1,-1,2,2,'',2,1,'Kill a Tuffein thug','397901','','397','',0,0,0,0,0,0,0),
(3040448,2,-1,3,2,'',2,1,'Kill a Tuffein grabber','397902','','397','',0,0,0,0,0,0,0),
(3040448,3,-1,4,2,'',2,1,'Kill a Tuffein thug','397901','','397','',0,0,0,0,0,0,0),
(3040448,4,-1,5,2,'',2,1,'Kill a Tuffein grabber','397902','','397','',0,0,0,0,0,0,0),
(3040448,5,-1,6,3,'',0,1,'Loot Note from Razvan','','97238','397','',0,0,0,0,0,0,0),
(3040448,6,-1,7,1,'',0,1,'Deliver Note from Razvan','397118','97238','397','',0,0,0,0,0,0,0),
(3040449,0,-1,1,255,'',0,1,'Find Tuffein encampment','','','397','',0,0,0,0,0,0,0),
(3040449,1,-1,2,2,'',0,10,'Kill Tuffein','','','397','',0,0,0,0,0,0,0),
(3040449,2,-1,3,2,'',0,1,'Kill Razvan','397078','','397','',0,0,0,0,0,0,0),
(3040449,3,-1,4,4,'',0,1,'Speak with 397118','397118','','397','',0,0,0,0,0,0,0),
(3040450,0,-1,1,4,'',0,1,'Speak with 394155','394155','','394','',0,0,0,0,0,0,0),
(3040450,1,-1,2,3,'',0,6,'Loot Windwillow Branch','','97237','397','',0,0,0,0,0,0,0),
(3040450,2,-1,2,3,'',0,2,'Loot Spider Eye','','97235','397','',0,0,0,0,0,0,0),
(3040450,3,-1,2,3,'',0,4,'Loot Large Snake Fang','','97229','397','',0,0,0,0,0,0,0),
(3040450,4,-1,2,3,'',0,1,'Loot Earthen Ooze Slime','','97228','397','',0,0,0,0,0,0,0),
(3040450,5,-1,3,6,'',0,1,'Create Ciodaru''s Gift Box Parts','','97731','0','',0,0,0,0,0,0,0),
(3040450,6,-1,3,6,'',0,1,'Create Petrified Spider Eyes','','97741','0','',0,0,0,0,0,0,0),
(3040450,7,-1,3,6,'',0,1,'Create Ciodaru''s Gift Box','','97729','0','',0,0,0,0,0,0,0),
(3040450,8,-1,4,1,'',0,1,'Deliver Ciodaru''s Gift Box','397118','97729','397','',0,0,0,0,0,0,0),
(3040450,9,-1,5,1,'',0,1,'Deliver Ciodaru''s Gift Box','397100','97730','397','',0,0,0,0,0,0,0),
(3040450,10,-1,6,255,'',0,1,'Tell Ciodaru Kathryn loves him','397118','','397','',0,0,0,0,0,0,0),
(3040450,11,-1,3,1,'',0,6,'(Optional) Give crafting material 97237','394155','97237','394','',1,0,0,0,0,0,0),
(3040450,12,-1,3,1,'',0,2,'(Optional) Give crafting material 97235','394155','97235','394','',1,0,0,0,0,0,0),
(3040450,13,-1,3,1,'',0,4,'(Optional) Give crafting material 97229','394155','97229','394','',1,0,0,0,0,0,0),
(3040450,14,-1,3,1,'',0,1,'(Optional) Give crafting material 97228','394155','97228','394','',1,0,0,0,0,0,0),
(3040450,15,-1,3,255,'',0,1,'(Optional) Pay10platinum for the completed combine','394155','','394','',1,0,0,0,0,0,0),
(3040451,0,-1,1,5,'',2,1,'Observe Simu''s day at camp 1','','','397','',0,0,0,0,0,0,0),
(3040451,1,-1,1,5,'',2,1,'Observe Simu''s day at camp 2','','','397','',0,0,0,0,0,0,0),
(3040451,2,-1,1,5,'',2,1,'Observe Simu''s day at camp 3','','','397','',0,0,0,0,0,0,0),
(3040451,3,-1,1,5,'',2,1,'Observe Simu''s day at camp 4','','','397','',0,0,0,0,0,0,0),
(3040451,4,-1,1,5,'',2,1,'Observe Simu''s day at ridge 5','','','397','',0,0,0,0,0,0,0),
(3040451,5,-1,1,5,'',2,1,'Observe Simu''s day at ridge 6','','','397','',0,0,0,0,0,0,0),
(3040451,6,-1,2,5,'',2,1,'Observe Simu''s day at tent 7','','','397','',0,0,0,0,0,0,0),
(3040451,7,-1,2,4,'',0,1,'Speak with 397086','397086','','397','',0,0,0,0,0,0,0),
(3040452,0,-1,1,1,'',0,1,'Deliver Letter to Simu','397120','88110','397','',0,0,0,0,0,0,0),
(3040452,1,-1,2,255,'',0,1,'Give Simu space to read the letter','','','397','',0,0,0,0,0,0,0),
(3040452,2,-1,3,4,'',0,1,'Speak with 397120','397120','','397','',0,0,0,0,0,0,0),
(3040452,3,-1,4,4,'',0,1,'Speak with 397086','397086','','397','',0,0,0,0,0,0,0),
(3040453,0,-1,1,3,'',0,32,'Loot Spider Silk','','13041','397','',0,0,0,0,0,0,0),
(3040453,1,-1,1,3,'',0,1,'Loot Recluse Spider Fang','','88113','397','',0,0,0,0,0,0,0),
(3040453,2,-1,1,3,'',0,4,'Loot Wolf Canine','','88114','397','',0,0,0,0,0,0,0),
(3040453,3,-1,1,3,'',0,1,'Loot Supple Wolf Pelt','','88115','397','',0,0,0,0,0,0,0),
(3040453,4,-1,1,3,'',0,5,'Loot Large Snake Fang','','97229','397','',0,0,0,0,0,0,0),
(3040453,5,-1,2,1,'',0,32,'Deliver Spider Silk','397086','13041','397','',0,0,0,0,0,0,0),
(3040453,6,-1,2,1,'',0,1,'Deliver Recluse Spider Fang','397086','88113','397','',0,0,0,0,0,0,0),
(3040453,7,-1,2,1,'',0,4,'Deliver Wolf Canine','397086','88114','397','',0,0,0,0,0,0,0),
(3040453,8,-1,2,1,'',0,1,'Deliver Supple Wolf Pelt','397086','88115','397','',0,0,0,0,0,0,0),
(3040453,9,-1,3,1,'',0,5,'Deliver Large Snake Fang','397086','97229','397','',0,0,0,0,0,0,0),
(3040453,10,-1,4,1,'',0,1,'Deliver Folded Silkfang Pack','397120','88112','397','',0,0,0,0,0,0,0),
(3040453,11,-1,5,4,'',0,1,'Speak with 397086','397086','','397','',0,0,0,0,0,0,0),
(3040454,0,-1,1,6,'',0,4,'Create Spider Silk Thread','','88117','0','',0,0,0,0,0,0,0),
(3040454,1,-1,2,6,'',0,1,'Create Spool of Spider Silk Thread','','88118','0','',0,0,0,0,0,0,0),
(3040454,2,-1,3,6,'',0,4,'Create Wolf Canine Bead','','88146','0','',0,0,0,0,0,0,0),
(3040454,3,-1,3,6,'',0,5,'Create Snake Fang Bead','','88147','0','',0,0,0,0,0,0,0),
(3040454,4,-1,4,6,'',0,1,'Create String of Teeth','','88148','0','',0,0,0,0,0,0,0),
(3040454,5,-1,5,6,'',0,1,'Create Folded Silkfang Pack','','88112','0','',0,0,0,0,0,0,0),
(3040454,6,-1,6,1,'',0,1,'Deliver Folded Silkfang Pack','397086','88112','397','',0,0,0,0,0,0,0),
(3040454,7,-1,7,1,'',0,1,'Deliver Folded Silkfang Pack','397120','88112','397','',0,0,0,0,0,0,0),
(3040454,8,-1,8,4,'',0,1,'Speak with 397086','397086','','397','',0,0,0,0,0,0,0),
(3040455,0,-1,1,4,'',0,1,'Speak with 394228','394228','','394','',0,0,0,0,0,0,0),
(3040455,1,-1,2,3,'',0,1,'Loot Bear Heart','','88119','397','',0,0,0,0,0,0,0),
(3040455,2,-1,3,3,'',0,1,'Loot Spider Brain','','88120','397','',0,0,0,0,0,0,0),
(3040455,3,-1,4,3,'',0,1,'Loot Snake Skin','','88121','397','',0,0,0,0,0,0,0),
(3040455,4,-1,5,3,'',0,1,'Loot Blood-soaked Patch of Fur','','88122','397','',0,0,0,0,0,0,0),
(3040455,5,-1,6,1,'',0,1,'Deliver Bear Heart','394228','88119','394','',0,0,0,0,0,0,0),
(3040455,6,-1,7,1,'',0,1,'Deliver Spider Brain','394228','88120','394','',0,0,0,0,0,0,0),
(3040455,7,-1,8,1,'',0,1,'Deliver Snake Skin','394228','88121','394','',0,0,0,0,0,0,0),
(3040455,8,-1,9,1,'',0,1,'Deliver Blood-soaked Patch of Fur','394228','88122','394','',0,0,0,0,0,0,0),
(3040455,9,-1,10,255,'',0,1,'Pay Alchemist Naeema10gold','394228','','394','',0,0,0,0,0,0,0),
(3040455,10,-1,11,1,'',0,1,'Deliver Philter of Anamorata','397086','88123','397','',0,0,0,0,0,0,0),
(3040455,11,-1,12,1,'',0,1,'Deliver Philter of Anamorata','397120','88123','397','',0,0,0,0,0,0,0),
(3040455,12,-1,13,4,'',0,1,'Speak with 397086','397086','','397','',0,0,0,0,0,0,0),
(3040456,0,-1,1,4,'',0,1,'Speak with 395210','395210','','395','',0,0,0,0,0,0,0),
(3040456,1,-1,2,3,'',0,4,'Loot Cultivated Jumjum Pollen','','88125','396','',0,0,0,0,0,0,0),
(3040456,2,-1,2,3,'',0,4,'Loot Honeycomb','','88124','396','',0,0,0,0,0,0,0),
(3040456,3,-1,3,1,'',0,4,'Deliver Cultivated Jumjum Pollen','397086','88125','397','',0,0,0,0,0,0,0),
(3040456,4,-1,3,1,'',0,4,'Deliver Honeycomb','397086','88124','397','',0,0,0,0,0,0,0),
(3040456,5,-1,4,1,'',0,1,'Deliver Soporific Honey','397120','88126','397','',0,0,0,0,0,0,0),
(3040456,6,-1,5,255,'',0,1,'Protect Simu on his walk to Dorina','','','397','',0,0,0,0,0,0,0),
(3040456,7,-1,6,4,'',0,1,'Speak with 397086','397086','','397','',0,0,0,0,0,0,0)
ON DUPLICATE KEY UPDATE `activityid`=VALUES(`activityid`),`req_activity_id`=VALUES(`req_activity_id`),`step`=VALUES(`step`),`activitytype`=VALUES(`activitytype`),`target_name`=VALUES(`target_name`),`goalmethod`=VALUES(`goalmethod`),`goalcount`=VALUES(`goalcount`),`description_override`=VALUES(`description_override`),`npc_match_list`=VALUES(`npc_match_list`),`item_id_list`=VALUES(`item_id_list`),`zones`=VALUES(`zones`),`spell_list`=VALUES(`spell_list`),`optional`=VALUES(`optional`),`min_x`=VALUES(`min_x`),`max_x`=VALUES(`max_x`),`min_y`=VALUES(`min_y`),`max_y`=VALUES(`max_y`),`min_z`=VALUES(`min_z`),`max_z`=VALUES(`max_z`);
DELETE FROM achievement_criteria WHERE achievement_id=500040600 AND component_type=1 AND component_id=50143;
DELETE FROM achievement_criteria WHERE achievement_id=500040600 AND component_type=1 AND component_id=50144;
DELETE FROM achievement_criteria WHERE achievement_id=500040600 AND component_type=1 AND component_id=50145;
DELETE FROM achievement_criteria WHERE achievement_id=500040600 AND component_type=1 AND component_id=50146;
DELETE FROM achievement_criteria WHERE achievement_id=500040600 AND component_type=1 AND component_id=50147;
DELETE FROM achievement_criteria WHERE achievement_id=500040600 AND component_type=1 AND component_id=50148;
DELETE FROM achievement_criteria WHERE achievement_id=500040600 AND component_type=1 AND component_id=50149;
DELETE FROM achievement_criteria WHERE achievement_id=500040400 AND component_type=1 AND component_id=50126;
DELETE FROM achievement_criteria WHERE achievement_id=500040400 AND component_type=1 AND component_id=50127;
DELETE FROM achievement_criteria WHERE achievement_id=500040400 AND component_type=1 AND component_id=50132;
DELETE FROM achievement_criteria WHERE achievement_id=500040400 AND component_type=1 AND component_id=50133;
DELETE FROM achievement_criteria WHERE achievement_id=500040400 AND component_type=1 AND component_id=50134;
DELETE FROM achievement_criteria WHERE achievement_id=500040400 AND component_type=1 AND component_id=50135;
DELETE FROM achievement_criteria WHERE achievement_id=500040400 AND component_type=1 AND component_id=50136;
DELETE FROM achievement_criteria WHERE achievement_id=500040400 AND component_type=1 AND component_id=50128;
DELETE FROM achievement_criteria WHERE achievement_id=500040400 AND component_type=1 AND component_id=50129;
DELETE FROM achievement_criteria WHERE achievement_id=500040400 AND component_type=1 AND component_id=50130;
DELETE FROM achievement_criteria WHERE achievement_id=500040400 AND component_type=1 AND component_id=50131;
DELETE FROM achievement_criteria WHERE achievement_id=500040700 AND component_type=1 AND component_id=50150;
DELETE FROM achievement_criteria WHERE achievement_id=500040700 AND component_type=1 AND component_id=50151;
DELETE FROM achievement_criteria WHERE achievement_id=500040700 AND component_type=1 AND component_id=50152;
DELETE FROM achievement_criteria WHERE achievement_id=500040700 AND component_type=1 AND component_id=50153;
DELETE FROM achievement_criteria WHERE achievement_id=500040700 AND component_type=1 AND component_id=50154;
DELETE FROM achievement_criteria WHERE achievement_id=500040700 AND component_type=1 AND component_id=50155;
DELETE FROM achievement_criteria WHERE achievement_id=500040700 AND component_type=1 AND component_id=50156;
DELETE FROM achievement_criteria WHERE achievement_id=500040700 AND component_type=1 AND component_id=50157;
DELETE FROM achievement_criteria WHERE achievement_id=500040700 AND component_type=1 AND component_id=50158;
DELETE FROM achievement_criteria WHERE achievement_id=500040700 AND component_type=1 AND component_id=50159;
DELETE FROM achievement_criteria WHERE achievement_id=500040700 AND component_type=1 AND component_id=50160;
DELETE FROM achievement_criteria WHERE achievement_id=500040700 AND component_type=1 AND component_id=50161;
DELETE FROM achievement_criteria WHERE achievement_id=500040500 AND component_type=1 AND component_id=50137;
DELETE FROM achievement_criteria WHERE achievement_id=500040500 AND component_type=1 AND component_id=50138;
DELETE FROM achievement_criteria WHERE achievement_id=500040500 AND component_type=1 AND component_id=50139;
DELETE FROM achievement_criteria WHERE achievement_id=500040500 AND component_type=1 AND component_id=50140;
DELETE FROM achievement_criteria WHERE achievement_id=500040500 AND component_type=1 AND component_id=50141;
DELETE FROM achievement_criteria WHERE achievement_id=500040500 AND component_type=1 AND component_id=50142;
INSERT INTO achievement_criteria(`achievement_id`,`component_type`,`component_sequence`,`component_id`,`event_type`,`progress_mode`,`behavior`,`target_id`,`target_id2`,`target_value`,`required_count`,`enabled`)VALUES
(500040600,1,1,50143,4,3,0,3040421,0,0,1,0),
(500040600,1,2,50144,4,3,0,3040422,0,0,1,0),
(500040600,1,3,50145,4,3,0,3040423,0,0,1,0),
(500040600,1,4,50146,4,3,0,3040424,0,0,1,0),
(500040600,1,5,50147,4,3,0,3040425,0,0,1,0),
(500040600,1,6,50148,4,3,0,3040426,0,0,1,0),
(500040600,1,7,50149,4,3,0,3040427,0,0,1,0),
(500040400,1,1,50126,4,3,0,3040428,0,0,1,0),
(500040400,1,2,50127,4,3,0,3040429,0,0,1,0),
(500040400,1,7,50132,4,3,0,3040430,0,0,1,0),
(500040400,1,8,50133,4,3,0,3040431,0,0,1,0),
(500040400,1,9,50134,4,3,0,3040432,0,0,1,0),
(500040400,1,10,50135,4,3,0,3040433,0,0,1,0),
(500040400,1,11,50136,4,3,0,3040434,0,0,1,0),
(500040400,1,3,50128,4,3,0,3040435,0,0,1,0),
(500040400,1,4,50129,4,3,0,3040436,0,0,1,0),
(500040400,1,5,50130,4,3,0,3040437,0,0,1,0),
(500040400,1,6,50131,4,3,0,3040438,0,0,1,0),
(500040700,1,1,50150,4,3,0,3040439,0,0,1,0),
(500040700,1,2,50151,4,3,0,3040440,0,0,1,0),
(500040700,1,3,50152,4,3,0,3040441,0,0,1,0),
(500040700,1,4,50153,4,3,0,3040442,0,0,1,0),
(500040700,1,5,50154,4,3,0,3040443,0,0,1,0),
(500040700,1,6,50155,4,3,0,3040444,0,0,1,0),
(500040700,1,7,50156,4,3,0,3040445,0,0,1,0),
(500040700,1,8,50157,4,3,0,3040446,0,0,1,0),
(500040700,1,9,50158,4,3,0,3040447,0,0,1,0),
(500040700,1,10,50159,4,3,0,3040448,0,0,1,0),
(500040700,1,11,50160,4,3,0,3040449,0,0,1,0),
(500040700,1,12,50161,4,3,0,3040450,0,0,1,0),
(500040500,1,1,50137,4,3,0,3040451,0,0,1,0),
(500040500,1,2,50138,4,3,0,3040452,0,0,1,0),
(500040500,1,3,50139,4,3,0,3040453,0,0,1,0),
(500040500,1,4,50140,4,3,0,3040454,0,0,1,0),
(500040500,1,5,50141,4,3,0,3040455,0,0,1,0),
(500040500,1,6,50142,4,3,0,3040456,0,0,1,0)
ON DUPLICATE KEY UPDATE `component_type`=VALUES(`component_type`),`component_sequence`=VALUES(`component_sequence`),`component_id`=VALUES(`component_id`),`event_type`=VALUES(`event_type`),`progress_mode`=VALUES(`progress_mode`),`behavior`=VALUES(`behavior`),`target_id`=VALUES(`target_id`),`target_id2`=VALUES(`target_id2`),`target_value`=VALUES(`target_value`),`required_count`=VALUES(`required_count`),`enabled`=VALUES(`enabled`);
INSERT INTO reward_sets(`reward_set_id`,`title`,`enabled`)VALUES
(3040421,'Wolf Skins for Madu',0),
(3040422,'Bear Pelts for Madu',0),
(3040423,'Snake Skins for Madu',0),
(3040424,'Spider Silk for Madu',0),
(3040425,'Madu Needs More Supplies',0),
(3040426,'Kill Fantoma',0),
(3040427,'Kill Ursalua',0),
(3040456,'Dorina''s Lament',0)
ON DUPLICATE KEY UPDATE `title`=VALUES(`title`),`enabled`=VALUES(`enabled`);
INSERT INTO reward_sources(`source_type`,`source_id`,`reward_set_id`,`enabled`)VALUES
(2,3040421,3040421,0),
(2,3040422,3040422,0),
(2,3040423,3040423,0),
(2,3040424,3040424,0),
(2,3040425,3040425,0),
(2,3040426,3040426,0),
(2,3040427,3040427,0),
(2,3040456,3040456,0)
ON DUPLICATE KEY UPDATE `source_id`=VALUES(`source_id`),`reward_set_id`=VALUES(`reward_set_id`),`enabled`=VALUES(`enabled`);
INSERT INTO reward_options(`reward_set_id`,`option_id`,`sequence`,`label`,`common_to_all`,`flags`,`enabled`,`class_mask`)VALUES
(3040421,1,1,'Experience',1,0,0,65535),
(3040421,2,2,'Iron Forged Plate Bracer',0,0,0,1),
(3040421,3,3,'Fire Sanctified Plate Bracer',0,0,0,2),
(3040421,4,4,'Maiden Blessed Plate Bracer',0,0,0,4),
(3040421,5,5,'Thorn Bonded Chain Wristguard',0,0,0,8),
(3040421,6,6,'Swamp Dredged Plate Bracer',0,0,0,16),
(3040421,7,7,'Vine Imprinted Leather Wristguard',0,0,0,32),
(3040421,8,8,'Stone Formed Leather Wristguard',0,0,0,64),
(3040421,9,9,'Steel Toned Plate Bracer',0,0,0,128),
(3040421,10,10,'Blood Blackened Chain Wristguard',0,0,0,256),
(3040421,11,11,'Ritual Embossed Chain Wristguard',0,0,0,512),
(3040421,12,12,'Bone Twisted Cloth Wristband',0,0,0,1024),
(3040421,13,13,'Ice Woven Cloth Wristband',0,0,0,2048),
(3040421,14,14,'Earth Melded Cloth Wristband',0,0,0,4096),
(3040421,15,15,'Rune Tailored Cloth Wristband',0,0,0,8192),
(3040421,16,16,'Savage Runic Leather Wristguard',0,0,0,16384),
(3040421,17,17,'Blade Notched Chain Wristguard',0,0,0,32768),
(3040422,1,1,'Experience',1,0,0,65535),
(3040422,2,2,'Iron Forged Plate Boots',0,0,0,1),
(3040422,3,3,'Fire Sanctified Plate Boots',0,0,0,2),
(3040422,4,4,'Maiden Blessed Plate Boots',0,0,0,4),
(3040422,5,5,'Thorn Bonded Chain Boots',0,0,0,8),
(3040422,6,6,'Swamp Dredged Plate Boots',0,0,0,16),
(3040422,7,7,'Vine Imprinted Leather Boots',0,0,0,32),
(3040422,8,8,'Stone Formed Leather Boots',0,0,0,64),
(3040422,9,9,'Steel Toned Plate Boots',0,0,0,128),
(3040422,10,10,'Blood Blackened Chain Boots',0,0,0,256),
(3040422,11,11,'Ritual Embossed Chain Boots',0,0,0,512),
(3040422,12,12,'Bone Twisted Cloth Sandals',0,0,0,1024),
(3040422,13,13,'Ice Woven Cloth Sandals',0,0,0,2048),
(3040422,14,14,'Earth Melded Cloth Sandals',0,0,0,4096),
(3040422,15,15,'Rune Tailored Cloth Sandals',0,0,0,8192),
(3040422,16,16,'Savage Runic Leather Boots',0,0,0,16384),
(3040422,17,17,'Blade Notched Chain Boots',0,0,0,32768),
(3040423,1,1,'Experience',1,0,0,65535),
(3040423,2,2,'Iron Forged Plate Gauntlets',0,0,0,1),
(3040423,3,3,'Fire Sanctified Plate Gauntlets',0,0,0,2),
(3040423,4,4,'Maiden Blessed Plate Gauntlets',0,0,0,4),
(3040423,5,5,'Thorn Bonded Chain Gauntlets',0,0,0,8),
(3040423,6,6,'Swamp Dredged Plate Gauntlets',0,0,0,16),
(3040423,7,7,'Vine Imprinted Leather Gloves',0,0,0,32),
(3040423,8,8,'Stone Formed Leather Gloves',0,0,0,64),
(3040423,9,9,'Steel Toned Plate Gauntlets',0,0,0,128),
(3040423,10,10,'Blood Blackened Chain Gauntlets',0,0,0,256),
(3040423,11,11,'Ritual Embossed Chain Gauntlets',0,0,0,512),
(3040423,12,12,'Bone Twisted Cloth Gloves',0,0,0,1024),
(3040423,13,13,'Ice Woven Cloth Gloves',0,0,0,2048),
(3040423,14,14,'Earth Melded Cloth Gloves',0,0,0,4096),
(3040423,15,15,'Rune Tailored Cloth Gloves',0,0,0,8192),
(3040423,16,16,'Savage Runic Leather Gloves',0,0,0,16384),
(3040423,17,17,'Blade Notched Chain Gauntlets',0,0,0,32768),
(3040424,1,1,'Experience',1,0,0,65535),
(3040424,2,2,'Iron Forged Plate Helm',0,0,0,1),
(3040424,3,3,'Fire Sanctified Plate Helm',0,0,0,2),
(3040424,4,4,'Maiden Blessed Plate Helm',0,0,0,4),
(3040424,5,5,'Thorn Bonded Chain Coif',0,0,0,8),
(3040424,6,6,'Swamp Dredged Plate Helm',0,0,0,16),
(3040424,7,7,'Vine Imprinted Leather Cowl',0,0,0,32),
(3040424,8,8,'Stone Formed Leather Cowl',0,0,0,64),
(3040424,9,9,'Steel Toned Plate Helm',0,0,0,128),
(3040424,10,10,'Blood Blackened Chain Coif',0,0,0,256),
(3040424,11,11,'Ritual Embossed Chain Coif',0,0,0,512),
(3040424,12,12,'Bone Twisted Cloth Cap',0,0,0,1024),
(3040424,13,13,'Ice Woven Cloth Cap',0,0,0,2048),
(3040424,14,14,'Earth Melded Cloth Cap',0,0,0,4096),
(3040424,15,15,'Rune Tailored Cloth Cap',0,0,0,8192),
(3040424,16,16,'Savage Runic Leather Cowl',0,0,0,16384),
(3040424,17,17,'Blade Notched Chain Coif',0,0,0,32768),
(3040425,1,1,'Experience',1,0,0,65535),
(3040425,2,2,'Iron Forged Plate Vambraces',0,0,0,1),
(3040425,3,3,'Fire Sanctified Plate Vambraces',0,0,0,2),
(3040425,4,4,'Maiden Blessed Plate Vambraces',0,0,0,4),
(3040425,5,5,'Thorn Bonded Chain Sleeves',0,0,0,8),
(3040425,6,6,'Swamp Dredged Plate Vambraces',0,0,0,16),
(3040425,7,7,'Vine Imprinted Leather Armwraps',0,0,0,32),
(3040425,8,8,'Stone Formed Leather Armwraps',0,0,0,64),
(3040425,9,9,'Steel Toned Plate Vambraces',0,0,0,128),
(3040425,10,10,'Blood Blackened Chain Sleeves',0,0,0,256),
(3040425,11,11,'Ritual Embossed Chain Sleeves',0,0,0,512),
(3040425,12,12,'Bone Twisted Cloth Sleeves',0,0,0,1024),
(3040425,13,13,'Ice Woven Cloth Sleeves',0,0,0,2048),
(3040425,14,14,'Earth Melded Cloth Sleeves',0,0,0,4096),
(3040425,15,15,'Rune Tailored Cloth Sleeves',0,0,0,8192),
(3040425,16,16,'Savage Runic Leather Armwraps',0,0,0,16384),
(3040425,17,17,'Blade Notched Chain Sleeves',0,0,0,32768),
(3040426,1,1,'Experience',1,0,0,65535),
(3040426,2,2,'Iron Forged Plate Greaves',0,0,0,1),
(3040426,3,3,'Fire Sanctified Plate Greaves',0,0,0,2),
(3040426,4,4,'Maiden Blessed Plate Greaves',0,0,0,4),
(3040426,5,5,'Thorn Bonded Chain Leggings',0,0,0,8),
(3040426,6,6,'Swamp Dredged Plate Greaves',0,0,0,16),
(3040426,7,7,'Vine Imprinted Leather Leggings',0,0,0,32),
(3040426,8,8,'Stone Formed Leather Leggings',0,0,0,64),
(3040426,9,9,'Steel Toned Plate Greaves',0,0,0,128),
(3040426,10,10,'Blood Blackened Chain Leggings',0,0,0,256),
(3040426,11,11,'Ritual Embossed Chain Leggings',0,0,0,512),
(3040426,12,12,'Bone Twisted Cloth Pants',0,0,0,1024),
(3040426,13,13,'Ice Woven Cloth Pants',0,0,0,2048),
(3040426,14,14,'Earth Melded Cloth Pants',0,0,0,4096),
(3040426,15,15,'Rune Tailored Cloth Pants',0,0,0,8192),
(3040426,16,16,'Savage Runic Leather Leggings',0,0,0,16384),
(3040426,17,17,'Blade Notched Chain Leggings',0,0,0,32768),
(3040427,1,1,'Experience',1,0,0,65535),
(3040427,2,2,'Iron Forged Plate Breastplate',0,0,0,1),
(3040427,3,3,'Fire Sanctified Plate Breastplate',0,0,0,2),
(3040427,4,4,'Maiden Blessed Plate Breastplate',0,0,0,4),
(3040427,5,5,'Thorn Bonded Chain Coat',0,0,0,8),
(3040427,6,6,'Swamp Dredged Plate Breastplate',0,0,0,16),
(3040427,7,7,'Vine Imprinted Leather Tunic',0,0,0,32),
(3040427,8,8,'Stone Formed Leather Tunic',0,0,0,64),
(3040427,9,9,'Steel Toned Plate Breastplate',0,0,0,128),
(3040427,10,10,'Blood Blackened Chain Coat',0,0,0,256),
(3040427,11,11,'Ritual Embossed Chain Coat',0,0,0,512),
(3040427,12,12,'Bone Twisted Cloth Robe',0,0,0,1024),
(3040427,13,13,'Ice Woven Cloth Robe',0,0,0,2048),
(3040427,14,14,'Earth Melded Cloth Robe',0,0,0,4096),
(3040427,15,15,'Rune Tailored Cloth Robe',0,0,0,8192),
(3040427,16,16,'Savage Runic Leather Tunic',0,0,0,16384),
(3040427,17,17,'Blade Notched Chain Coat',0,0,0,32768),
(3040456,1,1,'Experience',1,0,0,65535),
(3040456,2,2,'Dryad Tender Bauble',0,0,0,65535),
(3040456,3,3,'Dryad Focusing Bauble',0,0,0,65535),
(3040456,4,4,'Dryad Protector Bauble',0,0,0,65535),
(3040456,5,5,'Dryad Maiden Bauble',0,0,0,65535)
ON DUPLICATE KEY UPDATE `option_id`=VALUES(`option_id`),`sequence`=VALUES(`sequence`),`label`=VALUES(`label`),`common_to_all`=VALUES(`common_to_all`),`flags`=VALUES(`flags`),`enabled`=VALUES(`enabled`),`class_mask`=VALUES(`class_mask`);
INSERT INTO rewards(`reward_id`,`reward_type`,`reward_data_id`,`amount`,`description`,`enabled`)VALUES
(304042101,1,1,1000,'May2013 Mesa remaining option 304042101',0),
(304042102,0,53123,1,'May2013 Mesa remaining option 304042102',0),
(304042103,0,53130,1,'May2013 Mesa remaining option 304042103',0),
(304042104,0,53137,1,'May2013 Mesa remaining option 304042104',0),
(304042105,0,53144,1,'May2013 Mesa remaining option 304042105',0),
(304042106,0,53151,1,'May2013 Mesa remaining option 304042106',0),
(304042107,0,53158,1,'May2013 Mesa remaining option 304042107',0),
(304042108,0,53165,1,'May2013 Mesa remaining option 304042108',0),
(304042109,0,53172,1,'May2013 Mesa remaining option 304042109',0),
(304042110,0,53179,1,'May2013 Mesa remaining option 304042110',0),
(304042111,0,53186,1,'May2013 Mesa remaining option 304042111',0),
(304042112,0,53193,1,'May2013 Mesa remaining option 304042112',0),
(304042113,0,53200,1,'May2013 Mesa remaining option 304042113',0),
(304042114,0,53207,1,'May2013 Mesa remaining option 304042114',0),
(304042115,0,53214,1,'May2013 Mesa remaining option 304042115',0),
(304042116,0,53221,1,'May2013 Mesa remaining option 304042116',0),
(304042117,0,53228,1,'May2013 Mesa remaining option 304042117',0),
(304042201,1,1,1000,'May2013 Mesa remaining option 304042201',0),
(304042202,0,53125,1,'May2013 Mesa remaining option 304042202',0),
(304042203,0,53132,1,'May2013 Mesa remaining option 304042203',0),
(304042204,0,53139,1,'May2013 Mesa remaining option 304042204',0),
(304042205,0,53146,1,'May2013 Mesa remaining option 304042205',0),
(304042206,0,53153,1,'May2013 Mesa remaining option 304042206',0),
(304042207,0,53160,1,'May2013 Mesa remaining option 304042207',0),
(304042208,0,53167,1,'May2013 Mesa remaining option 304042208',0),
(304042209,0,53174,1,'May2013 Mesa remaining option 304042209',0),
(304042210,0,53181,1,'May2013 Mesa remaining option 304042210',0),
(304042211,0,53188,1,'May2013 Mesa remaining option 304042211',0),
(304042212,0,53195,1,'May2013 Mesa remaining option 304042212',0),
(304042213,0,53202,1,'May2013 Mesa remaining option 304042213',0),
(304042214,0,53209,1,'May2013 Mesa remaining option 304042214',0),
(304042215,0,53216,1,'May2013 Mesa remaining option 304042215',0),
(304042216,0,53223,1,'May2013 Mesa remaining option 304042216',0),
(304042217,0,53230,1,'May2013 Mesa remaining option 304042217',0),
(304042301,1,1,1000,'May2013 Mesa remaining option 304042301',0),
(304042302,0,53124,1,'May2013 Mesa remaining option 304042302',0),
(304042303,0,53131,1,'May2013 Mesa remaining option 304042303',0),
(304042304,0,53138,1,'May2013 Mesa remaining option 304042304',0),
(304042305,0,53145,1,'May2013 Mesa remaining option 304042305',0),
(304042306,0,53152,1,'May2013 Mesa remaining option 304042306',0),
(304042307,0,53159,1,'May2013 Mesa remaining option 304042307',0),
(304042308,0,53166,1,'May2013 Mesa remaining option 304042308',0),
(304042309,0,53173,1,'May2013 Mesa remaining option 304042309',0),
(304042310,0,53180,1,'May2013 Mesa remaining option 304042310',0),
(304042311,0,53187,1,'May2013 Mesa remaining option 304042311',0),
(304042312,0,53194,1,'May2013 Mesa remaining option 304042312',0),
(304042313,0,53201,1,'May2013 Mesa remaining option 304042313',0),
(304042314,0,53208,1,'May2013 Mesa remaining option 304042314',0),
(304042315,0,53215,1,'May2013 Mesa remaining option 304042315',0),
(304042316,0,53222,1,'May2013 Mesa remaining option 304042316',0),
(304042317,0,53229,1,'May2013 Mesa remaining option 304042317',0),
(304042401,1,1,1000,'May2013 Mesa remaining option 304042401',0),
(304042402,0,53121,1,'May2013 Mesa remaining option 304042402',0),
(304042403,0,53128,1,'May2013 Mesa remaining option 304042403',0),
(304042404,0,53135,1,'May2013 Mesa remaining option 304042404',0),
(304042405,0,53142,1,'May2013 Mesa remaining option 304042405',0),
(304042406,0,53149,1,'May2013 Mesa remaining option 304042406',0),
(304042407,0,53156,1,'May2013 Mesa remaining option 304042407',0),
(304042408,0,53163,1,'May2013 Mesa remaining option 304042408',0),
(304042409,0,53170,1,'May2013 Mesa remaining option 304042409',0),
(304042410,0,53177,1,'May2013 Mesa remaining option 304042410',0),
(304042411,0,53184,1,'May2013 Mesa remaining option 304042411',0),
(304042412,0,53191,1,'May2013 Mesa remaining option 304042412',0),
(304042413,0,53198,1,'May2013 Mesa remaining option 304042413',0),
(304042414,0,53205,1,'May2013 Mesa remaining option 304042414',0),
(304042415,0,53212,1,'May2013 Mesa remaining option 304042415',0),
(304042416,0,53219,1,'May2013 Mesa remaining option 304042416',0),
(304042417,0,53226,1,'May2013 Mesa remaining option 304042417',0),
(304042501,1,1,1000,'May2013 Mesa remaining option 304042501',0),
(304042502,0,53122,1,'May2013 Mesa remaining option 304042502',0),
(304042503,0,53129,1,'May2013 Mesa remaining option 304042503',0),
(304042504,0,53136,1,'May2013 Mesa remaining option 304042504',0),
(304042505,0,53143,1,'May2013 Mesa remaining option 304042505',0),
(304042506,0,53150,1,'May2013 Mesa remaining option 304042506',0),
(304042507,0,53157,1,'May2013 Mesa remaining option 304042507',0),
(304042508,0,53164,1,'May2013 Mesa remaining option 304042508',0),
(304042509,0,53171,1,'May2013 Mesa remaining option 304042509',0),
(304042510,0,53178,1,'May2013 Mesa remaining option 304042510',0),
(304042511,0,53185,1,'May2013 Mesa remaining option 304042511',0),
(304042512,0,53192,1,'May2013 Mesa remaining option 304042512',0),
(304042513,0,53199,1,'May2013 Mesa remaining option 304042513',0),
(304042514,0,53206,1,'May2013 Mesa remaining option 304042514',0),
(304042515,0,53213,1,'May2013 Mesa remaining option 304042515',0),
(304042516,0,53220,1,'May2013 Mesa remaining option 304042516',0),
(304042517,0,53227,1,'May2013 Mesa remaining option 304042517',0),
(304042601,1,1,1000,'May2013 Mesa remaining option 304042601',0),
(304042602,0,53127,1,'May2013 Mesa remaining option 304042602',0),
(304042603,0,53134,1,'May2013 Mesa remaining option 304042603',0),
(304042604,0,53141,1,'May2013 Mesa remaining option 304042604',0),
(304042605,0,53148,1,'May2013 Mesa remaining option 304042605',0),
(304042606,0,53155,1,'May2013 Mesa remaining option 304042606',0),
(304042607,0,53162,1,'May2013 Mesa remaining option 304042607',0),
(304042608,0,53169,1,'May2013 Mesa remaining option 304042608',0),
(304042609,0,53176,1,'May2013 Mesa remaining option 304042609',0),
(304042610,0,53183,1,'May2013 Mesa remaining option 304042610',0),
(304042611,0,53190,1,'May2013 Mesa remaining option 304042611',0),
(304042612,0,53197,1,'May2013 Mesa remaining option 304042612',0),
(304042613,0,53204,1,'May2013 Mesa remaining option 304042613',0),
(304042614,0,53211,1,'May2013 Mesa remaining option 304042614',0),
(304042615,0,53218,1,'May2013 Mesa remaining option 304042615',0),
(304042616,0,53225,1,'May2013 Mesa remaining option 304042616',0),
(304042617,0,53232,1,'May2013 Mesa remaining option 304042617',0),
(304042701,1,1,1000,'May2013 Mesa remaining option 304042701',0),
(304042702,0,53126,1,'May2013 Mesa remaining option 304042702',0),
(304042703,0,53133,1,'May2013 Mesa remaining option 304042703',0),
(304042704,0,53140,1,'May2013 Mesa remaining option 304042704',0),
(304042705,0,53147,1,'May2013 Mesa remaining option 304042705',0),
(304042706,0,53154,1,'May2013 Mesa remaining option 304042706',0),
(304042707,0,53161,1,'May2013 Mesa remaining option 304042707',0),
(304042708,0,53168,1,'May2013 Mesa remaining option 304042708',0),
(304042709,0,53175,1,'May2013 Mesa remaining option 304042709',0),
(304042710,0,53182,1,'May2013 Mesa remaining option 304042710',0),
(304042711,0,53189,1,'May2013 Mesa remaining option 304042711',0),
(304042712,0,53196,1,'May2013 Mesa remaining option 304042712',0),
(304042713,0,53203,1,'May2013 Mesa remaining option 304042713',0),
(304042714,0,53210,1,'May2013 Mesa remaining option 304042714',0),
(304042715,0,53217,1,'May2013 Mesa remaining option 304042715',0),
(304042716,0,53224,1,'May2013 Mesa remaining option 304042716',0),
(304042717,0,53231,1,'May2013 Mesa remaining option 304042717',0),
(304045601,1,1,1000,'May2013 Mesa remaining option 304045601',0),
(304045602,0,53559,1,'May2013 Mesa remaining option 304045602',0),
(304045603,0,53560,1,'May2013 Mesa remaining option 304045603',0),
(304045604,0,53561,1,'May2013 Mesa remaining option 304045604',0),
(304045605,0,53562,1,'May2013 Mesa remaining option 304045605',0)
ON DUPLICATE KEY UPDATE `reward_type`=VALUES(`reward_type`),`reward_data_id`=VALUES(`reward_data_id`),`amount`=VALUES(`amount`),`description`=VALUES(`description`),`enabled`=VALUES(`enabled`);
INSERT INTO reward_option_entries(`reward_set_id`,`option_id`,`sequence`,`reward_id`)VALUES
(3040421,1,0,304042101),
(3040421,2,0,304042102),
(3040421,3,0,304042103),
(3040421,4,0,304042104),
(3040421,5,0,304042105),
(3040421,6,0,304042106),
(3040421,7,0,304042107),
(3040421,8,0,304042108),
(3040421,9,0,304042109),
(3040421,10,0,304042110),
(3040421,11,0,304042111),
(3040421,12,0,304042112),
(3040421,13,0,304042113),
(3040421,14,0,304042114),
(3040421,15,0,304042115),
(3040421,16,0,304042116),
(3040421,17,0,304042117),
(3040422,1,0,304042201),
(3040422,2,0,304042202),
(3040422,3,0,304042203),
(3040422,4,0,304042204),
(3040422,5,0,304042205),
(3040422,6,0,304042206),
(3040422,7,0,304042207),
(3040422,8,0,304042208),
(3040422,9,0,304042209),
(3040422,10,0,304042210),
(3040422,11,0,304042211),
(3040422,12,0,304042212),
(3040422,13,0,304042213),
(3040422,14,0,304042214),
(3040422,15,0,304042215),
(3040422,16,0,304042216),
(3040422,17,0,304042217),
(3040423,1,0,304042301),
(3040423,2,0,304042302),
(3040423,3,0,304042303),
(3040423,4,0,304042304),
(3040423,5,0,304042305),
(3040423,6,0,304042306),
(3040423,7,0,304042307),
(3040423,8,0,304042308),
(3040423,9,0,304042309),
(3040423,10,0,304042310),
(3040423,11,0,304042311),
(3040423,12,0,304042312),
(3040423,13,0,304042313),
(3040423,14,0,304042314),
(3040423,15,0,304042315),
(3040423,16,0,304042316),
(3040423,17,0,304042317),
(3040424,1,0,304042401),
(3040424,2,0,304042402),
(3040424,3,0,304042403),
(3040424,4,0,304042404),
(3040424,5,0,304042405),
(3040424,6,0,304042406),
(3040424,7,0,304042407),
(3040424,8,0,304042408),
(3040424,9,0,304042409),
(3040424,10,0,304042410),
(3040424,11,0,304042411),
(3040424,12,0,304042412),
(3040424,13,0,304042413),
(3040424,14,0,304042414),
(3040424,15,0,304042415),
(3040424,16,0,304042416),
(3040424,17,0,304042417),
(3040425,1,0,304042501),
(3040425,2,0,304042502),
(3040425,3,0,304042503),
(3040425,4,0,304042504),
(3040425,5,0,304042505),
(3040425,6,0,304042506),
(3040425,7,0,304042507),
(3040425,8,0,304042508),
(3040425,9,0,304042509),
(3040425,10,0,304042510),
(3040425,11,0,304042511),
(3040425,12,0,304042512),
(3040425,13,0,304042513),
(3040425,14,0,304042514),
(3040425,15,0,304042515),
(3040425,16,0,304042516),
(3040425,17,0,304042517),
(3040426,1,0,304042601),
(3040426,2,0,304042602),
(3040426,3,0,304042603),
(3040426,4,0,304042604),
(3040426,5,0,304042605),
(3040426,6,0,304042606),
(3040426,7,0,304042607),
(3040426,8,0,304042608),
(3040426,9,0,304042609),
(3040426,10,0,304042610),
(3040426,11,0,304042611),
(3040426,12,0,304042612),
(3040426,13,0,304042613),
(3040426,14,0,304042614),
(3040426,15,0,304042615),
(3040426,16,0,304042616),
(3040426,17,0,304042617),
(3040427,1,0,304042701),
(3040427,2,0,304042702),
(3040427,3,0,304042703),
(3040427,4,0,304042704),
(3040427,5,0,304042705),
(3040427,6,0,304042706),
(3040427,7,0,304042707),
(3040427,8,0,304042708),
(3040427,9,0,304042709),
(3040427,10,0,304042710),
(3040427,11,0,304042711),
(3040427,12,0,304042712),
(3040427,13,0,304042713),
(3040427,14,0,304042714),
(3040427,15,0,304042715),
(3040427,16,0,304042716),
(3040427,17,0,304042717),
(3040456,1,0,304045601),
(3040456,2,0,304045602),
(3040456,3,0,304045603),
(3040456,4,0,304045604),
(3040456,5,0,304045605)
ON DUPLICATE KEY UPDATE `option_id`=VALUES(`option_id`),`sequence`=VALUES(`sequence`),`reward_id`=VALUES(`reward_id`);
COMMIT;

-- ---- mesa-remaining/sql/050-parent-rewards.sql ----
-- RESEARCHED disabled candidate; four period-confirmed Mesa parent gear rewards.
SET SESSION check_constraint_checks=1;
DROP TEMPORARY TABLE IF EXISTS _mesa_parent_guard;
CREATE TEMPORARY TABLE _mesa_parent_guard(label VARCHAR(100)PRIMARY KEY,ok TINYINT NOT NULL,CHECK(ok=1))ENGINE=InnoDB;
INSERT INTO _mesa_parent_guard VALUES('review',COALESCE(@mesa_parent_rewards_reviewed,0)=1);
INSERT INTO _mesa_parent_guard VALUES('achievement_500040400',((SELECT COUNT(*)FROM achievements WHERE id=500040400 AND name='Moving Up the Ranks (51-55)' AND has_reward=1)=1));
INSERT INTO _mesa_parent_guard VALUES('source_ownership_500040400',(NOT EXISTS(SELECT 1 FROM reward_sources WHERE source_type=1 AND source_id=500040400 AND reward_set_id<>3050404)AND NOT EXISTS(SELECT 1 FROM reward_sources WHERE reward_set_id=3050404 AND NOT(source_type=1 AND source_id=500040400))));
INSERT INTO _mesa_parent_guard VALUES('item_108123',((SELECT COUNT(*)FROM items WHERE id=108123 AND Name='Flawed Consigned Breastplate' AND classes=151)=1));
INSERT INTO _mesa_parent_guard VALUES('item_108130',((SELECT COUNT(*)FROM items WHERE id=108130 AND Name='Flawed Consigned Chain Tunic' AND classes=33544)=1));
INSERT INTO _mesa_parent_guard VALUES('item_108137',((SELECT COUNT(*)FROM items WHERE id=108137 AND Name='Flawed Consigned Leather Tunic' AND classes=16480)=1));
INSERT INTO _mesa_parent_guard VALUES('item_108144',((SELECT COUNT(*)FROM items WHERE id=108144 AND Name='Flawed Consigned Silk Robe' AND classes=15360)=1));
INSERT INTO _mesa_parent_guard VALUES('achievement_500040500',((SELECT COUNT(*)FROM achievements WHERE id=500040500 AND name='Dorina''s Love (Mesa 40+)' AND has_reward=1)=1));
INSERT INTO _mesa_parent_guard VALUES('source_ownership_500040500',(NOT EXISTS(SELECT 1 FROM reward_sources WHERE source_type=1 AND source_id=500040500 AND reward_set_id<>3050405)AND NOT EXISTS(SELECT 1 FROM reward_sources WHERE reward_set_id=3050405 AND NOT(source_type=1 AND source_id=500040500))));
INSERT INTO _mesa_parent_guard VALUES('item_108385',((SELECT COUNT(*)FROM items WHERE id=108385 AND Name='Flawed Soldier''s Cloak' AND classes=49629)=1));
INSERT INTO _mesa_parent_guard VALUES('item_108395',((SELECT COUNT(*)FROM items WHERE id=108395 AND Name='Flawed Scryer''s Cape' AND classes=15906)=1));
INSERT INTO _mesa_parent_guard VALUES('achievement_500040600',((SELECT COUNT(*)FROM achievements WHERE id=500040600 AND name='Madu''s Armor (Mesa 40+)' AND has_reward=1)=1));
INSERT INTO _mesa_parent_guard VALUES('source_ownership_500040600',(NOT EXISTS(SELECT 1 FROM reward_sources WHERE source_type=1 AND source_id=500040600 AND reward_set_id<>3050406)AND NOT EXISTS(SELECT 1 FROM reward_sources WHERE reward_set_id=3050406 AND NOT(source_type=1 AND source_id=500040600))));
INSERT INTO _mesa_parent_guard VALUES('item_108384',((SELECT COUNT(*)FROM items WHERE id=108384 AND Name='Flawed Soldier''s Pauldrons' AND classes=49629)=1));
INSERT INTO _mesa_parent_guard VALUES('item_108394',((SELECT COUNT(*)FROM items WHERE id=108394 AND Name='Flawed Scryer''s Shoulderpads' AND classes=15906)=1));
INSERT INTO _mesa_parent_guard VALUES('achievement_500040700',((SELECT COUNT(*)FROM achievements WHERE id=500040700 AND name='Ciodaru''s Love (Mesa 45+)' AND has_reward=1)=1));
INSERT INTO _mesa_parent_guard VALUES('source_ownership_500040700',(NOT EXISTS(SELECT 1 FROM reward_sources WHERE source_type=1 AND source_id=500040700 AND reward_set_id<>3050407)AND NOT EXISTS(SELECT 1 FROM reward_sources WHERE reward_set_id=3050407 AND NOT(source_type=1 AND source_id=500040700))));
INSERT INTO _mesa_parent_guard VALUES('item_108382',((SELECT COUNT(*)FROM items WHERE id=108382 AND Name='Flawed Soldier''s Eyepatch' AND classes=49629)=1));
INSERT INTO _mesa_parent_guard VALUES('item_108392',((SELECT COUNT(*)FROM items WHERE id=108392 AND Name='Flawed Scryer''s Facemask' AND classes=15906)=1));
INSERT INTO _mesa_parent_guard VALUES('reward_sets_identity',(NOT EXISTS(SELECT 1 FROM reward_sets WHERE reward_set_id IN(3050404,3050405,3050406,3050407) AND NOT((`reward_set_id`=3050404 AND `title`='Moving Up the Ranks (51-55)') OR (`reward_set_id`=3050405 AND `title`='Dorina''s Love (Mesa 40+)') OR (`reward_set_id`=3050406 AND `title`='Madu''s Armor (Mesa 40+)') OR (`reward_set_id`=3050407 AND `title`='Ciodaru''s Love (Mesa 45+)')))));
INSERT INTO _mesa_parent_guard VALUES('reward_sources_identity',(NOT EXISTS(SELECT 1 FROM reward_sources WHERE reward_set_id IN(3050404,3050405,3050406,3050407) AND NOT((`source_type`=1 AND `source_id`=500040400 AND `reward_set_id`=3050404) OR (`source_type`=1 AND `source_id`=500040500 AND `reward_set_id`=3050405) OR (`source_type`=1 AND `source_id`=500040600 AND `reward_set_id`=3050406) OR (`source_type`=1 AND `source_id`=500040700 AND `reward_set_id`=3050407)))));
INSERT INTO _mesa_parent_guard VALUES('reward_options_identity',(NOT EXISTS(SELECT 1 FROM reward_options WHERE reward_set_id IN(3050404,3050405,3050406,3050407) AND NOT((`reward_set_id`=3050404 AND `option_id`=1 AND `sequence`=1 AND `label`='Flawed Consigned Breastplate' AND `common_to_all`=0 AND `flags`=0 AND `class_mask`=151) OR (`reward_set_id`=3050404 AND `option_id`=2 AND `sequence`=2 AND `label`='Flawed Consigned Chain Tunic' AND `common_to_all`=0 AND `flags`=0 AND `class_mask`=33544) OR (`reward_set_id`=3050404 AND `option_id`=3 AND `sequence`=3 AND `label`='Flawed Consigned Leather Tunic' AND `common_to_all`=0 AND `flags`=0 AND `class_mask`=16480) OR (`reward_set_id`=3050404 AND `option_id`=4 AND `sequence`=4 AND `label`='Flawed Consigned Silk Robe' AND `common_to_all`=0 AND `flags`=0 AND `class_mask`=15360) OR (`reward_set_id`=3050405 AND `option_id`=1 AND `sequence`=1 AND `label`='Flawed Soldier''s Cloak' AND `common_to_all`=0 AND `flags`=0 AND `class_mask`=49629) OR (`reward_set_id`=3050405 AND `option_id`=2 AND `sequence`=2 AND `label`='Flawed Scryer''s Cape' AND `common_to_all`=0 AND `flags`=0 AND `class_mask`=15906) OR (`reward_set_id`=3050406 AND `option_id`=1 AND `sequence`=1 AND `label`='Flawed Soldier''s Pauldrons' AND `common_to_all`=0 AND `flags`=0 AND `class_mask`=49629) OR (`reward_set_id`=3050406 AND `option_id`=2 AND `sequence`=2 AND `label`='Flawed Scryer''s Shoulderpads' AND `common_to_all`=0 AND `flags`=0 AND `class_mask`=15906) OR (`reward_set_id`=3050407 AND `option_id`=1 AND `sequence`=1 AND `label`='Flawed Soldier''s Eyepatch' AND `common_to_all`=0 AND `flags`=0 AND `class_mask`=49629) OR (`reward_set_id`=3050407 AND `option_id`=2 AND `sequence`=2 AND `label`='Flawed Scryer''s Facemask' AND `common_to_all`=0 AND `flags`=0 AND `class_mask`=15906)))));
INSERT INTO _mesa_parent_guard VALUES('rewards_identity',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id IN(305040401,305040402,305040403,305040404,305040501,305040502,305040601,305040602,305040701,305040702) AND NOT((`reward_id`=305040401 AND `reward_type`=0 AND `reward_data_id`=108123 AND `amount`=1 AND `description`='May2013 Mesa parent 500040400 Flawed Consigned Breastplate') OR (`reward_id`=305040402 AND `reward_type`=0 AND `reward_data_id`=108130 AND `amount`=1 AND `description`='May2013 Mesa parent 500040400 Flawed Consigned Chain Tunic') OR (`reward_id`=305040403 AND `reward_type`=0 AND `reward_data_id`=108137 AND `amount`=1 AND `description`='May2013 Mesa parent 500040400 Flawed Consigned Leather Tunic') OR (`reward_id`=305040404 AND `reward_type`=0 AND `reward_data_id`=108144 AND `amount`=1 AND `description`='May2013 Mesa parent 500040400 Flawed Consigned Silk Robe') OR (`reward_id`=305040501 AND `reward_type`=0 AND `reward_data_id`=108385 AND `amount`=1 AND `description`='May2013 Mesa parent 500040500 Flawed Soldier''s Cloak') OR (`reward_id`=305040502 AND `reward_type`=0 AND `reward_data_id`=108395 AND `amount`=1 AND `description`='May2013 Mesa parent 500040500 Flawed Scryer''s Cape') OR (`reward_id`=305040601 AND `reward_type`=0 AND `reward_data_id`=108384 AND `amount`=1 AND `description`='May2013 Mesa parent 500040600 Flawed Soldier''s Pauldrons') OR (`reward_id`=305040602 AND `reward_type`=0 AND `reward_data_id`=108394 AND `amount`=1 AND `description`='May2013 Mesa parent 500040600 Flawed Scryer''s Shoulderpads') OR (`reward_id`=305040701 AND `reward_type`=0 AND `reward_data_id`=108382 AND `amount`=1 AND `description`='May2013 Mesa parent 500040700 Flawed Soldier''s Eyepatch') OR (`reward_id`=305040702 AND `reward_type`=0 AND `reward_data_id`=108392 AND `amount`=1 AND `description`='May2013 Mesa parent 500040700 Flawed Scryer''s Facemask')))));
INSERT INTO _mesa_parent_guard VALUES('reward_option_entries_identity',(NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_set_id IN(3050404,3050405,3050406,3050407) AND NOT((`reward_set_id`=3050404 AND `option_id`=1 AND `sequence`=0 AND `reward_id`=305040401) OR (`reward_set_id`=3050404 AND `option_id`=2 AND `sequence`=0 AND `reward_id`=305040402) OR (`reward_set_id`=3050404 AND `option_id`=3 AND `sequence`=0 AND `reward_id`=305040403) OR (`reward_set_id`=3050404 AND `option_id`=4 AND `sequence`=0 AND `reward_id`=305040404) OR (`reward_set_id`=3050405 AND `option_id`=1 AND `sequence`=0 AND `reward_id`=305040501) OR (`reward_set_id`=3050405 AND `option_id`=2 AND `sequence`=0 AND `reward_id`=305040502) OR (`reward_set_id`=3050406 AND `option_id`=1 AND `sequence`=0 AND `reward_id`=305040601) OR (`reward_set_id`=3050406 AND `option_id`=2 AND `sequence`=0 AND `reward_id`=305040602) OR (`reward_set_id`=3050407 AND `option_id`=1 AND `sequence`=0 AND `reward_id`=305040701) OR (`reward_set_id`=3050407 AND `option_id`=2 AND `sequence`=0 AND `reward_id`=305040702)))));
INSERT INTO _mesa_parent_guard VALUES('reward_links_305040401',(NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=305040401)AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=305040401 AND NOT(`reward_set_id`=3050404 AND `option_id`=1 AND `sequence`=0 AND `reward_id`=305040401))));
INSERT INTO _mesa_parent_guard VALUES('reward_links_305040402',(NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=305040402)AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=305040402 AND NOT(`reward_set_id`=3050404 AND `option_id`=2 AND `sequence`=0 AND `reward_id`=305040402))));
INSERT INTO _mesa_parent_guard VALUES('reward_links_305040403',(NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=305040403)AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=305040403 AND NOT(`reward_set_id`=3050404 AND `option_id`=3 AND `sequence`=0 AND `reward_id`=305040403))));
INSERT INTO _mesa_parent_guard VALUES('reward_links_305040404',(NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=305040404)AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=305040404 AND NOT(`reward_set_id`=3050404 AND `option_id`=4 AND `sequence`=0 AND `reward_id`=305040404))));
INSERT INTO _mesa_parent_guard VALUES('reward_links_305040501',(NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=305040501)AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=305040501 AND NOT(`reward_set_id`=3050405 AND `option_id`=1 AND `sequence`=0 AND `reward_id`=305040501))));
INSERT INTO _mesa_parent_guard VALUES('reward_links_305040502',(NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=305040502)AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=305040502 AND NOT(`reward_set_id`=3050405 AND `option_id`=2 AND `sequence`=0 AND `reward_id`=305040502))));
INSERT INTO _mesa_parent_guard VALUES('reward_links_305040601',(NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=305040601)AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=305040601 AND NOT(`reward_set_id`=3050406 AND `option_id`=1 AND `sequence`=0 AND `reward_id`=305040601))));
INSERT INTO _mesa_parent_guard VALUES('reward_links_305040602',(NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=305040602)AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=305040602 AND NOT(`reward_set_id`=3050406 AND `option_id`=2 AND `sequence`=0 AND `reward_id`=305040602))));
INSERT INTO _mesa_parent_guard VALUES('reward_links_305040701',(NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=305040701)AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=305040701 AND NOT(`reward_set_id`=3050407 AND `option_id`=1 AND `sequence`=0 AND `reward_id`=305040701))));
INSERT INTO _mesa_parent_guard VALUES('reward_links_305040702',(NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=305040702)AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=305040702 AND NOT(`reward_set_id`=3050407 AND `option_id`=2 AND `sequence`=0 AND `reward_id`=305040702))));
START TRANSACTION;
INSERT INTO reward_sets(`reward_set_id`,`title`,`enabled`)SELECT 3050404,'Moving Up the Ranks (51-55)',0 WHERE NOT EXISTS(SELECT 1 FROM reward_sets WHERE `reward_set_id`=3050404);
INSERT INTO reward_sets(`reward_set_id`,`title`,`enabled`)SELECT 3050405,'Dorina''s Love (Mesa 40+)',0 WHERE NOT EXISTS(SELECT 1 FROM reward_sets WHERE `reward_set_id`=3050405);
INSERT INTO reward_sets(`reward_set_id`,`title`,`enabled`)SELECT 3050406,'Madu''s Armor (Mesa 40+)',0 WHERE NOT EXISTS(SELECT 1 FROM reward_sets WHERE `reward_set_id`=3050406);
INSERT INTO reward_sets(`reward_set_id`,`title`,`enabled`)SELECT 3050407,'Ciodaru''s Love (Mesa 45+)',0 WHERE NOT EXISTS(SELECT 1 FROM reward_sets WHERE `reward_set_id`=3050407);
INSERT INTO reward_sources(`source_type`,`source_id`,`reward_set_id`,`enabled`)SELECT 1,500040400,3050404,0 WHERE NOT EXISTS(SELECT 1 FROM reward_sources WHERE `source_type`=1 AND `source_id`=500040400 AND `reward_set_id`=3050404);
INSERT INTO reward_sources(`source_type`,`source_id`,`reward_set_id`,`enabled`)SELECT 1,500040500,3050405,0 WHERE NOT EXISTS(SELECT 1 FROM reward_sources WHERE `source_type`=1 AND `source_id`=500040500 AND `reward_set_id`=3050405);
INSERT INTO reward_sources(`source_type`,`source_id`,`reward_set_id`,`enabled`)SELECT 1,500040600,3050406,0 WHERE NOT EXISTS(SELECT 1 FROM reward_sources WHERE `source_type`=1 AND `source_id`=500040600 AND `reward_set_id`=3050406);
INSERT INTO reward_sources(`source_type`,`source_id`,`reward_set_id`,`enabled`)SELECT 1,500040700,3050407,0 WHERE NOT EXISTS(SELECT 1 FROM reward_sources WHERE `source_type`=1 AND `source_id`=500040700 AND `reward_set_id`=3050407);
INSERT INTO reward_options(`reward_set_id`,`option_id`,`sequence`,`label`,`common_to_all`,`flags`,`enabled`,`class_mask`)SELECT 3050404,1,1,'Flawed Consigned Breastplate',0,0,0,151 WHERE NOT EXISTS(SELECT 1 FROM reward_options WHERE `reward_set_id`=3050404 AND `option_id`=1);
INSERT INTO reward_options(`reward_set_id`,`option_id`,`sequence`,`label`,`common_to_all`,`flags`,`enabled`,`class_mask`)SELECT 3050404,2,2,'Flawed Consigned Chain Tunic',0,0,0,33544 WHERE NOT EXISTS(SELECT 1 FROM reward_options WHERE `reward_set_id`=3050404 AND `option_id`=2);
INSERT INTO reward_options(`reward_set_id`,`option_id`,`sequence`,`label`,`common_to_all`,`flags`,`enabled`,`class_mask`)SELECT 3050404,3,3,'Flawed Consigned Leather Tunic',0,0,0,16480 WHERE NOT EXISTS(SELECT 1 FROM reward_options WHERE `reward_set_id`=3050404 AND `option_id`=3);
INSERT INTO reward_options(`reward_set_id`,`option_id`,`sequence`,`label`,`common_to_all`,`flags`,`enabled`,`class_mask`)SELECT 3050404,4,4,'Flawed Consigned Silk Robe',0,0,0,15360 WHERE NOT EXISTS(SELECT 1 FROM reward_options WHERE `reward_set_id`=3050404 AND `option_id`=4);
INSERT INTO reward_options(`reward_set_id`,`option_id`,`sequence`,`label`,`common_to_all`,`flags`,`enabled`,`class_mask`)SELECT 3050405,1,1,'Flawed Soldier''s Cloak',0,0,0,49629 WHERE NOT EXISTS(SELECT 1 FROM reward_options WHERE `reward_set_id`=3050405 AND `option_id`=1);
INSERT INTO reward_options(`reward_set_id`,`option_id`,`sequence`,`label`,`common_to_all`,`flags`,`enabled`,`class_mask`)SELECT 3050405,2,2,'Flawed Scryer''s Cape',0,0,0,15906 WHERE NOT EXISTS(SELECT 1 FROM reward_options WHERE `reward_set_id`=3050405 AND `option_id`=2);
INSERT INTO reward_options(`reward_set_id`,`option_id`,`sequence`,`label`,`common_to_all`,`flags`,`enabled`,`class_mask`)SELECT 3050406,1,1,'Flawed Soldier''s Pauldrons',0,0,0,49629 WHERE NOT EXISTS(SELECT 1 FROM reward_options WHERE `reward_set_id`=3050406 AND `option_id`=1);
INSERT INTO reward_options(`reward_set_id`,`option_id`,`sequence`,`label`,`common_to_all`,`flags`,`enabled`,`class_mask`)SELECT 3050406,2,2,'Flawed Scryer''s Shoulderpads',0,0,0,15906 WHERE NOT EXISTS(SELECT 1 FROM reward_options WHERE `reward_set_id`=3050406 AND `option_id`=2);
INSERT INTO reward_options(`reward_set_id`,`option_id`,`sequence`,`label`,`common_to_all`,`flags`,`enabled`,`class_mask`)SELECT 3050407,1,1,'Flawed Soldier''s Eyepatch',0,0,0,49629 WHERE NOT EXISTS(SELECT 1 FROM reward_options WHERE `reward_set_id`=3050407 AND `option_id`=1);
INSERT INTO reward_options(`reward_set_id`,`option_id`,`sequence`,`label`,`common_to_all`,`flags`,`enabled`,`class_mask`)SELECT 3050407,2,2,'Flawed Scryer''s Facemask',0,0,0,15906 WHERE NOT EXISTS(SELECT 1 FROM reward_options WHERE `reward_set_id`=3050407 AND `option_id`=2);
INSERT INTO rewards(`reward_id`,`reward_type`,`reward_data_id`,`amount`,`description`,`enabled`)SELECT 305040401,0,108123,1,'May2013 Mesa parent 500040400 Flawed Consigned Breastplate',0 WHERE NOT EXISTS(SELECT 1 FROM rewards WHERE `reward_id`=305040401);
INSERT INTO rewards(`reward_id`,`reward_type`,`reward_data_id`,`amount`,`description`,`enabled`)SELECT 305040402,0,108130,1,'May2013 Mesa parent 500040400 Flawed Consigned Chain Tunic',0 WHERE NOT EXISTS(SELECT 1 FROM rewards WHERE `reward_id`=305040402);
INSERT INTO rewards(`reward_id`,`reward_type`,`reward_data_id`,`amount`,`description`,`enabled`)SELECT 305040403,0,108137,1,'May2013 Mesa parent 500040400 Flawed Consigned Leather Tunic',0 WHERE NOT EXISTS(SELECT 1 FROM rewards WHERE `reward_id`=305040403);
INSERT INTO rewards(`reward_id`,`reward_type`,`reward_data_id`,`amount`,`description`,`enabled`)SELECT 305040404,0,108144,1,'May2013 Mesa parent 500040400 Flawed Consigned Silk Robe',0 WHERE NOT EXISTS(SELECT 1 FROM rewards WHERE `reward_id`=305040404);
INSERT INTO rewards(`reward_id`,`reward_type`,`reward_data_id`,`amount`,`description`,`enabled`)SELECT 305040501,0,108385,1,'May2013 Mesa parent 500040500 Flawed Soldier''s Cloak',0 WHERE NOT EXISTS(SELECT 1 FROM rewards WHERE `reward_id`=305040501);
INSERT INTO rewards(`reward_id`,`reward_type`,`reward_data_id`,`amount`,`description`,`enabled`)SELECT 305040502,0,108395,1,'May2013 Mesa parent 500040500 Flawed Scryer''s Cape',0 WHERE NOT EXISTS(SELECT 1 FROM rewards WHERE `reward_id`=305040502);
INSERT INTO rewards(`reward_id`,`reward_type`,`reward_data_id`,`amount`,`description`,`enabled`)SELECT 305040601,0,108384,1,'May2013 Mesa parent 500040600 Flawed Soldier''s Pauldrons',0 WHERE NOT EXISTS(SELECT 1 FROM rewards WHERE `reward_id`=305040601);
INSERT INTO rewards(`reward_id`,`reward_type`,`reward_data_id`,`amount`,`description`,`enabled`)SELECT 305040602,0,108394,1,'May2013 Mesa parent 500040600 Flawed Scryer''s Shoulderpads',0 WHERE NOT EXISTS(SELECT 1 FROM rewards WHERE `reward_id`=305040602);
INSERT INTO rewards(`reward_id`,`reward_type`,`reward_data_id`,`amount`,`description`,`enabled`)SELECT 305040701,0,108382,1,'May2013 Mesa parent 500040700 Flawed Soldier''s Eyepatch',0 WHERE NOT EXISTS(SELECT 1 FROM rewards WHERE `reward_id`=305040701);
INSERT INTO rewards(`reward_id`,`reward_type`,`reward_data_id`,`amount`,`description`,`enabled`)SELECT 305040702,0,108392,1,'May2013 Mesa parent 500040700 Flawed Scryer''s Facemask',0 WHERE NOT EXISTS(SELECT 1 FROM rewards WHERE `reward_id`=305040702);
INSERT INTO reward_option_entries(`reward_set_id`,`option_id`,`sequence`,`reward_id`)SELECT 3050404,1,0,305040401 WHERE NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE `reward_set_id`=3050404 AND `option_id`=1 AND `sequence`=0);
INSERT INTO reward_option_entries(`reward_set_id`,`option_id`,`sequence`,`reward_id`)SELECT 3050404,2,0,305040402 WHERE NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE `reward_set_id`=3050404 AND `option_id`=2 AND `sequence`=0);
INSERT INTO reward_option_entries(`reward_set_id`,`option_id`,`sequence`,`reward_id`)SELECT 3050404,3,0,305040403 WHERE NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE `reward_set_id`=3050404 AND `option_id`=3 AND `sequence`=0);
INSERT INTO reward_option_entries(`reward_set_id`,`option_id`,`sequence`,`reward_id`)SELECT 3050404,4,0,305040404 WHERE NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE `reward_set_id`=3050404 AND `option_id`=4 AND `sequence`=0);
INSERT INTO reward_option_entries(`reward_set_id`,`option_id`,`sequence`,`reward_id`)SELECT 3050405,1,0,305040501 WHERE NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE `reward_set_id`=3050405 AND `option_id`=1 AND `sequence`=0);
INSERT INTO reward_option_entries(`reward_set_id`,`option_id`,`sequence`,`reward_id`)SELECT 3050405,2,0,305040502 WHERE NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE `reward_set_id`=3050405 AND `option_id`=2 AND `sequence`=0);
INSERT INTO reward_option_entries(`reward_set_id`,`option_id`,`sequence`,`reward_id`)SELECT 3050406,1,0,305040601 WHERE NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE `reward_set_id`=3050406 AND `option_id`=1 AND `sequence`=0);
INSERT INTO reward_option_entries(`reward_set_id`,`option_id`,`sequence`,`reward_id`)SELECT 3050406,2,0,305040602 WHERE NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE `reward_set_id`=3050406 AND `option_id`=2 AND `sequence`=0);
INSERT INTO reward_option_entries(`reward_set_id`,`option_id`,`sequence`,`reward_id`)SELECT 3050407,1,0,305040701 WHERE NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE `reward_set_id`=3050407 AND `option_id`=1 AND `sequence`=0);
INSERT INTO reward_option_entries(`reward_set_id`,`option_id`,`sequence`,`reward_id`)SELECT 3050407,2,0,305040702 WHERE NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE `reward_set_id`=3050407 AND `option_id`=2 AND `sequence`=0);
COMMIT;

-- ---- mesa-remaining/sql/060-enable-content.sql ----
-- Reviewed QA activation only; no player/progress grants.
START TRANSACTION;
UPDATE tasks SET enabled=1 WHERE id BETWEEN 3040421 AND 3040456;
UPDATE achievement_criteria SET enabled=1 WHERE event_type=4 AND target_id BETWEEN 3040421 AND 3040456 AND ((achievement_id=500040600 AND component_type=1 AND component_id=50143) OR (achievement_id=500040600 AND component_type=1 AND component_id=50144) OR (achievement_id=500040600 AND component_type=1 AND component_id=50145) OR (achievement_id=500040600 AND component_type=1 AND component_id=50146) OR (achievement_id=500040600 AND component_type=1 AND component_id=50147) OR (achievement_id=500040600 AND component_type=1 AND component_id=50148) OR (achievement_id=500040600 AND component_type=1 AND component_id=50149) OR (achievement_id=500040400 AND component_type=1 AND component_id=50126) OR (achievement_id=500040400 AND component_type=1 AND component_id=50127) OR (achievement_id=500040400 AND component_type=1 AND component_id=50132) OR (achievement_id=500040400 AND component_type=1 AND component_id=50133) OR (achievement_id=500040400 AND component_type=1 AND component_id=50134) OR (achievement_id=500040400 AND component_type=1 AND component_id=50135) OR (achievement_id=500040400 AND component_type=1 AND component_id=50136) OR (achievement_id=500040400 AND component_type=1 AND component_id=50128) OR (achievement_id=500040400 AND component_type=1 AND component_id=50129) OR (achievement_id=500040400 AND component_type=1 AND component_id=50130) OR (achievement_id=500040400 AND component_type=1 AND component_id=50131) OR (achievement_id=500040700 AND component_type=1 AND component_id=50150) OR (achievement_id=500040700 AND component_type=1 AND component_id=50151) OR (achievement_id=500040700 AND component_type=1 AND component_id=50152) OR (achievement_id=500040700 AND component_type=1 AND component_id=50153) OR (achievement_id=500040700 AND component_type=1 AND component_id=50154) OR (achievement_id=500040700 AND component_type=1 AND component_id=50155) OR (achievement_id=500040700 AND component_type=1 AND component_id=50156) OR (achievement_id=500040700 AND component_type=1 AND component_id=50157) OR (achievement_id=500040700 AND component_type=1 AND component_id=50158) OR (achievement_id=500040700 AND component_type=1 AND component_id=50159) OR (achievement_id=500040700 AND component_type=1 AND component_id=50160) OR (achievement_id=500040700 AND component_type=1 AND component_id=50161) OR (achievement_id=500040500 AND component_type=1 AND component_id=50137) OR (achievement_id=500040500 AND component_type=1 AND component_id=50138) OR (achievement_id=500040500 AND component_type=1 AND component_id=50139) OR (achievement_id=500040500 AND component_type=1 AND component_id=50140) OR (achievement_id=500040500 AND component_type=1 AND component_id=50141) OR (achievement_id=500040500 AND component_type=1 AND component_id=50142));
UPDATE reward_sets SET enabled=1 WHERE reward_set_id IN(3040421,3040422,3040423,3040424,3040425,3040426,3040427,3040456,3050404,3050405,3050406,3050407);
UPDATE reward_options SET enabled=1 WHERE reward_set_id IN(3040421,3040422,3040423,3040424,3040425,3040426,3040427,3040456,3050404,3050405,3050406,3050407);
UPDATE reward_sources SET enabled=1 WHERE source_type=2 AND source_id BETWEEN 3040421 AND 3040456 AND reward_set_id IN(3040421,3040422,3040423,3040424,3040425,3040426,3040427,3040456,3050404,3050405,3050406,3050407);
UPDATE reward_sources SET enabled=1 WHERE source_type=1 AND source_id IN(500040400,500040500,500040600,500040700) AND reward_set_id IN(3040421,3040422,3040423,3040424,3040425,3040426,3040427,3040456,3050404,3050405,3050406,3050407);
UPDATE rewards SET enabled=1 WHERE reward_id IN(304042101,304042102,304042103,304042104,304042105,304042106,304042107,304042108,304042109,304042110,304042111,304042112,304042113,304042114,304042115,304042116,304042117,304042201,304042202,304042203,304042204,304042205,304042206,304042207,304042208,304042209,304042210,304042211,304042212,304042213,304042214,304042215,304042216,304042217,304042301,304042302,304042303,304042304,304042305,304042306,304042307,304042308,304042309,304042310,304042311,304042312,304042313,304042314,304042315,304042316,304042317,304042401,304042402,304042403,304042404,304042405,304042406,304042407,304042408,304042409,304042410,304042411,304042412,304042413,304042414,304042415,304042416,304042417,304042501,304042502,304042503,304042504,304042505,304042506,304042507,304042508,304042509,304042510,304042511,304042512,304042513,304042514,304042515,304042516,304042517,304042601,304042602,304042603,304042604,304042605,304042606,304042607,304042608,304042609,304042610,304042611,304042612,304042613,304042614,304042615,304042616,304042617,304042701,304042702,304042703,304042704,304042705,304042706,304042707,304042708,304042709,304042710,304042711,304042712,304042713,304042714,304042715,304042716,304042717,304045601,304045602,304045603,304045604,304045605,305040401,305040402,305040403,305040404,305040501,305040502,305040601,305040602,305040701,305040702);
COMMIT;
