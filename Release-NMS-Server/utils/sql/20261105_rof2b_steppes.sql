-- 20261105 rof2b port: steppes - Steppes quest routes (13 routes, 3 Hero's Journey defs).
-- Source: github.com/nightstalker6669/EQEmu branch rof2-achievements,
--   extensions/rof2/achievements/content/steppes (GPL-3.0), ported 2026-11-05.
-- Forward SQL files concatenated verbatim in install order; fail-closed
-- guards and session variables preserved. Reviewed-flag acceptance block
-- added here (upstream reconstruction defaults documented in the package's
-- provenance/ directory; see docs/rof2-zone-quests-attribution.md).
SET NAMES utf8mb4;
SET SESSION check_constraint_checks=1;
SET @steppes_catalogue_reviewed=1;
SET @steppes_reviewed=1;
SET @steppes_defaults_reviewed=1;
SET @steppes_activation_reviewed=1;
SET @steppes_shared_policy_reviewed=1;
-- (reviewed flags accepted: @steppes_catalogue_reviewed, @steppes_reviewed, @steppes_defaults_reviewed, @steppes_activation_reviewed, @steppes_shared_policy_reviewed)

-- ---- steppes/sql/000-shared-reward-state.sql ----
-- Required before enabling shared METHODSELECT tasks. No player rows modified.
-- The uint64 shared run identity is never truncated or encoded in a timestamp.
CREATE TABLE IF NOT EXISTS character_shared_task_reward_instances (
 character_id INT(10) UNSIGNED NOT NULL,
 shared_task_id BIGINT(20) UNSIGNED NOT NULL,
 task_id INT(10) UNSIGNED NOT NULL,
 occurrence_id BIGINT(20) UNSIGNED NOT NULL,
 PRIMARY KEY(character_id,shared_task_id),
 UNIQUE KEY shared_task_reward_occurrence(occurrence_id),
 KEY shared_task_reward_task(character_id,task_id)
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---- steppes/sql/005-shared-admission-schema.sql ----
-- Optional content policy. No player state/ordinary task row changes.
SET NAMES utf8mb4;
SET SESSION check_constraint_checks=1;
CREATE TABLE IF NOT EXISTS shared_task_admission_policies (
 task_id INT UNSIGNED NOT NULL,
 late_join_min_level TINYINT UNSIGNED NOT NULL,
 enabled TINYINT UNSIGNED NOT NULL DEFAULT 0,
 PRIMARY KEY(task_id),
 CHECK(late_join_min_level BETWEEN 1 AND 255),
 CHECK(enabled IN(0,1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
-- CREATE IF NOT EXISTS is not validation. Reject an incompatible pre-existing table.
DROP TEMPORARY TABLE IF EXISTS _shared_policy_schema_guard;
CREATE TEMPORARY TABLE _shared_policy_schema_guard(ok TINYINT NOT NULL CHECK(ok=1)) ENGINE=InnoDB;
INSERT INTO _shared_policy_schema_guard VALUES(
 (SELECT COUNT(*)FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE()AND TABLE_NAME='shared_task_admission_policies'AND TABLE_TYPE='BASE TABLE'AND ENGINE='InnoDB')=1
 AND(SELECT COUNT(*)FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()AND TABLE_NAME='shared_task_admission_policies')=3
 AND(SELECT COUNT(*)FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()AND TABLE_NAME='shared_task_admission_policies'AND COLUMN_NAME='task_id'AND DATA_TYPE='int'AND LOCATE('unsigned',COLUMN_TYPE)>0 AND IS_NULLABLE='NO')=1
 AND(SELECT COUNT(*)FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()AND TABLE_NAME='shared_task_admission_policies'AND COLUMN_NAME IN('late_join_min_level','enabled')AND DATA_TYPE='tinyint'AND LOCATE('unsigned',COLUMN_TYPE)>0 AND IS_NULLABLE='NO')=2
 AND(SELECT COUNT(*)FROM information_schema.STATISTICS WHERE TABLE_SCHEMA=DATABASE()AND TABLE_NAME='shared_task_admission_policies'AND INDEX_NAME='PRIMARY')=1
 AND(SELECT COUNT(*)FROM information_schema.STATISTICS WHERE TABLE_SCHEMA=DATABASE()AND TABLE_NAME='shared_task_admission_policies'AND INDEX_NAME='PRIMARY'AND COLUMN_NAME='task_id'AND SEQ_IN_INDEX=1)=1
);
DROP TEMPORARY TABLE _shared_policy_schema_guard;

-- ---- steppes/sql/010-catalogue.sql ----
-- Steppes catalogue-only prerequisite, staged disabled; no task/criteria/reward/player-state writes.
-- MariaDB with enforced CHECK constraints. Stop game services/back up these four content tables before deliberate installation.
-- Review provenance first; set @steppes_catalogue_reviewed=1 in this same session to authorize this file.
-- Do not use --force. All permanent inserts also require the combined preflight result, protecting against continued execution after guard failure.
SET NAMES utf8mb4;
SET SESSION check_constraint_checks=1;
DROP TEMPORARY TABLE IF EXISTS `_stp_achievement_categories`;
CREATE TEMPORARY TABLE `_stp_achievement_categories` LIKE `achievement_categories`;
INSERT INTO `_stp_achievement_categories`(`id`,`parent_id`,`sequence`,`name`,`description`,`icon`) VALUES
(70,0,3,CONVERT(0x546865204865726f2773204a6f75726e6579 USING utf8mb4),CONVERT(0x546865204865726f2773204a6f75726e6579 USING utf8mb4),CONVERT(0x415f484a4e59 USING utf8mb4)),
(71,70,1,CONVERT(0x50726f6772657373696f6e USING utf8mb4),CONVERT(0x50726f6772657373696f6e USING utf8mb4),CONVERT(0x415f50726f6772657373696f6e537562 USING utf8mb4)),
(72,70,2,CONVERT(0x416476616e63656d656e74 USING utf8mb4),CONVERT(0x416476616e63656d656e74 USING utf8mb4),CONVERT(0x415f416476616e63656d656e74537562 USING utf8mb4));
DROP TEMPORARY TABLE IF EXISTS `_stp_achievements`;
CREATE TEMPORARY TABLE `_stp_achievements` LIKE `achievements`;
INSERT INTO `_stp_achievements`(`id`,`name`,`description`,`icon_id`,`points`,`has_reward`,`client_flag`,`version`,`reset_on_version_change`,`enabled`) VALUES
(500060200,CONVERT(0x436f6e71756572696e67205468652053746570706573202836312d373029 USING utf8mb4),CONVERT(0x41206e756d626572206f662070656f706c6520696e204372657363656e742052656163682068617665206a6f627320696e766f6c76696e672054686520537465707065732e20537065616b20776974682057617264656e204a616b61722061626f7574207265647563696e672074686520476f626c696e20616e6420476e6f6c6c207468726561742061732077656c6c2061732044616572604c6167617220616e642053656c616e612061626f757420636f6c6c656374696e6720737570706c6965733a USING utf8mb4),1169,7,1,0,0,1,0),
(500060300,CONVERT(0x5374657070652052696768742055702028537465707065732036302b29 USING utf8mb4),CONVERT(0x546f65676e6173686572207365656b7320746865207061676573206f6620616e20616e6369656e7420746f6d652c205961766961207365656b7320616e792068656c70207368652063616e206765742c20616e6420426f7264616e20746865204375727365642077616e747320746f2064697370656c2074686520637572736520686973206772656564206561726e65642068696d3a USING utf8mb4),782,3,1,0,0,1,0),
(500060400,CONVERT(0x52656275696c64696e672074686520506f7274616c2028537465707065732036302b29 USING utf8mb4),CONVERT(0x4d6f6c6472656e20746865205769736520686173206120706c616e20746f20737065616b20746f2074686520616e6369656e7420747265616e742057696c706564207468652057697468657265642e20536565207768617420796f752063616e20646f20746f2068656c703a USING utf8mb4),1072,3,1,0,0,1,0);
DROP TEMPORARY TABLE IF EXISTS `_stp_achievement_components`;
CREATE TEMPORARY TABLE `_stp_achievement_components` LIKE `achievement_components`;
INSERT INTO `_stp_achievement_components`(`achievement_id`,`component_type`,`sequence`,`component_id`,`name`,`description`) VALUES
(500060200,1,1,50190,CONVERT(0x57617264656e204a616b6172202d205377656570696e672074686520537465707065733a20476f626c696e73 USING utf8mb4),''),
(500060200,1,2,50191,CONVERT(0x57617264656e204a616b6172202d205377656570696e672074686520537465707065733a20476e6f6c6c73 USING utf8mb4),''),
(500060200,1,3,50192,CONVERT(0x57617264656e204a616b6172202d2043756c6c2074686520476f626c696e73 USING utf8mb4),''),
(500060200,1,4,50193,CONVERT(0x57617264656e204a616b6172202d2043756c6c2074686520476e6f6c6c73 USING utf8mb4),''),
(500060200,1,5,50194,CONVERT(0x57617264656e204a616b6172202d20536f77696e672044697373656e74 USING utf8mb4),''),
(500060200,1,6,50195,CONVERT(0x44616572604c61676172202d20576f6f6420666f722043617276696e67 USING utf8mb4),''),
(500060200,1,7,50196,CONVERT(0x53656c616e61202d20436c617920666f722053656c616e61 USING utf8mb4),''),
(500060200,3,0,2068,CONVERT(0x5265616368204c6576656c203630 USING utf8mb4),''),
(500060200,3,0,7011,CONVERT(0x53657270656e74 USING utf8mb4),''),
(500060300,1,1,50197,CONVERT(0x5961766961202d20576562206f6620437572696f73697479 USING utf8mb4),''),
(500060300,1,2,50198,CONVERT(0x426f7264616e2074686520437572736564202d205472656173757265206f66207468652044656164 USING utf8mb4),''),
(500060300,1,3,50199,CONVERT(0x546f65676e6173686572202d20426f6f6b20666f7220546f65676e6173686572 USING utf8mb4),''),
(500060300,3,0,2068,CONVERT(0x5265616368204c6576656c203630 USING utf8mb4),''),
(500060300,3,0,7011,CONVERT(0x53657270656e74 USING utf8mb4),''),
(500060400,1,1,50200,CONVERT(0x4d6f6c6472656e207468652057697365202d205468652054616c6b696e6720506c616e74 USING utf8mb4),''),
(500060400,1,2,50201,CONVERT(0x4d6f6c6472656e207468652057697365202d20546865204c696272617279 USING utf8mb4),''),
(500060400,1,3,50202,CONVERT(0x57696c70656420746865205769746865726564202d205468652044657374726f79656420506f7274616c USING utf8mb4),''),
(500060400,3,0,2068,CONVERT(0x5265616368204c6576656c203630 USING utf8mb4),''),
(500060400,3,0,7011,CONVERT(0x53657270656e74 USING utf8mb4),'');
DROP TEMPORARY TABLE IF EXISTS `_stp_achievement_category_associations`;
CREATE TEMPORARY TABLE `_stp_achievement_category_associations` LIKE `achievement_category_associations`;
INSERT INTO `_stp_achievement_category_associations`(`category_id`,`sequence`,`achievement_id`,`display_text`) VALUES
(71,0,500060200,''),
(72,0,500060300,''),
(72,0,500060400,'');
DROP TEMPORARY TABLE IF EXISTS `_stp_catalogue_guard`;
CREATE TEMPORARY TABLE `_stp_catalogue_guard`(ok TINYINT NOT NULL CHECK(ok=1)) ENGINE=InnoDB;
START TRANSACTION;
SET @steppes_catalogue_ok=(COALESCE(@steppes_catalogue_reviewed,0)=1)
 AND (NOT EXISTS(SELECT 1 FROM `achievement_categories` a WHERE a.id IN(70,71,72) AND NOT EXISTS(SELECT 1 FROM `_stp_achievement_categories` e WHERE a.`id`<=>e.`id` AND a.`parent_id`<=>e.`parent_id` AND a.`sequence`<=>e.`sequence` AND BINARY a.`name`<=>BINARY e.`name` AND BINARY a.`description`<=>BINARY e.`description` AND BINARY a.`icon`<=>BINARY e.`icon`)))
 AND (NOT EXISTS(SELECT 1 FROM `achievements` a WHERE a.id IN(500060200,500060300,500060400) AND NOT EXISTS(SELECT 1 FROM `_stp_achievements` e WHERE a.`id`<=>e.`id` AND BINARY a.`name`<=>BINARY e.`name` AND BINARY a.`description`<=>BINARY e.`description` AND a.`icon_id`<=>e.`icon_id` AND a.`points`<=>e.`points` AND a.`has_reward`<=>e.`has_reward` AND a.`client_flag`<=>e.`client_flag` AND a.`version`<=>e.`version` AND a.`reset_on_version_change`<=>e.`reset_on_version_change`)))
 AND (NOT EXISTS(SELECT 1 FROM `achievement_components` a WHERE a.achievement_id IN(500060200,500060300,500060400) AND a.`component_id`<>7014 AND NOT EXISTS(SELECT 1 FROM `_stp_achievement_components` e WHERE a.`achievement_id`<=>e.`achievement_id` AND a.`component_type`<=>e.`component_type` AND a.`sequence`<=>e.`sequence` AND a.`component_id`<=>e.`component_id` AND BINARY a.`name`<=>BINARY e.`name` AND BINARY a.`description`<=>BINARY e.`description`)))
 AND (NOT EXISTS(SELECT 1 FROM `achievement_category_associations` a WHERE a.achievement_id IN(500060200,500060300,500060400) AND NOT EXISTS(SELECT 1 FROM `_stp_achievement_category_associations` e WHERE a.`category_id`<=>e.`category_id` AND a.`sequence`<=>e.`sequence` AND a.`achievement_id`<=>e.`achievement_id` AND BINARY a.`display_text`<=>BINARY e.`display_text`)))
 AND (NOT EXISTS(SELECT 1 FROM achievement_components WHERE component_id BETWEEN 50190 AND 50202 AND achievement_id NOT IN(500060200,500060300,500060400)))
 AND (NOT EXISTS(SELECT 1 FROM achievement_associations WHERE component_id BETWEEN 50190 AND 50202 AND required_count<>1))
 AND (SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME IN('achievement_categories','achievements','achievement_components','achievement_category_associations') AND ENGINE='InnoDB')=4;
INSERT INTO `_stp_catalogue_guard` VALUES(COALESCE(@steppes_catalogue_ok,0));
INSERT INTO `achievement_categories`(`id`,`parent_id`,`sequence`,`name`,`description`,`icon`)
SELECT e.`id`,e.`parent_id`,e.`sequence`,e.`name`,e.`description`,e.`icon` FROM `_stp_achievement_categories` e
WHERE @steppes_catalogue_ok=1 AND NOT EXISTS(SELECT 1 FROM `achievement_categories` a WHERE a.`id`=e.`id`);
INSERT INTO `achievements`(`id`,`name`,`description`,`icon_id`,`points`,`has_reward`,`client_flag`,`version`,`reset_on_version_change`,`enabled`)
SELECT e.`id`,e.`name`,e.`description`,e.`icon_id`,e.`points`,e.`has_reward`,e.`client_flag`,e.`version`,e.`reset_on_version_change`,e.`enabled` FROM `_stp_achievements` e
WHERE @steppes_catalogue_ok=1 AND NOT EXISTS(SELECT 1 FROM `achievements` a WHERE a.`id`=e.`id`);
INSERT INTO `achievement_components`(`achievement_id`,`component_type`,`sequence`,`component_id`,`name`,`description`)
SELECT e.`achievement_id`,e.`component_type`,e.`sequence`,e.`component_id`,e.`name`,e.`description` FROM `_stp_achievement_components` e
WHERE @steppes_catalogue_ok=1 AND NOT EXISTS(SELECT 1 FROM `achievement_components` a WHERE a.`achievement_id`=e.`achievement_id` AND a.`component_type`=e.`component_type` AND a.`component_id`=e.`component_id`);
INSERT INTO `achievement_category_associations`(`category_id`,`sequence`,`achievement_id`,`display_text`)
SELECT e.`category_id`,e.`sequence`,e.`achievement_id`,e.`display_text` FROM `_stp_achievement_category_associations` e
WHERE @steppes_catalogue_ok=1 AND NOT EXISTS(SELECT 1 FROM `achievement_category_associations` a WHERE a.`category_id`=e.`category_id` AND a.`achievement_id`=e.`achievement_id`);
COMMIT;
SET @steppes_catalogue_ok=NULL;
DROP TEMPORARY TABLE `_stp_achievement_categories`;
DROP TEMPORARY TABLE `_stp_achievements`;
DROP TEMPORARY TABLE `_stp_achievement_components`;
DROP TEMPORARY TABLE `_stp_achievement_category_associations`;
DROP TEMPORARY TABLE `_stp_catalogue_guard`;

-- ---- steppes/sql/020-tasks-rewards.sql ----
-- Complete disabled Steppes journal/reward candidate. OFFLINE, NOT INSTALLED.
SET NAMES utf8mb4;
SET SESSION check_constraint_checks=1;
DROP TEMPORARY TABLE IF EXISTS _steppes_guard;
CREATE TEMPORARY TABLE _steppes_guard(label VARCHAR(100)PRIMARY KEY,ok TINYINT NOT NULL,CHECK(ok=1))ENGINE=InnoDB;
INSERT INTO _steppes_guard VALUES('review',(COALESCE(@steppes_reviewed,0)=1));
INSERT INTO _steppes_guard VALUES('task_identity',(NOT EXISTS(SELECT 1 FROM tasks WHERE id IN(3040601,3040602,3040603,3040604,3040605,3040606,3040607,3040608,3040609,3040610,3040611,3040612,3040613) AND NOT((id=3040601 AND type=2 AND title='Clay for Selana') OR (id=3040602 AND type=2 AND title='Wood for Carving') OR (id=3040603 AND type=2 AND title='Cull the Gnolls') OR (id=3040604 AND type=2 AND title='Cull the Goblins') OR (id=3040605 AND type=1 AND title='Sweeping the Steppes: Goblins') OR (id=3040606 AND type=1 AND title='Sweeping the Steppes: Gnolls') OR (id=3040607 AND type=1 AND title='Sowing Dissent') OR (id=3040608 AND type=2 AND title='Book for Toegnasher') OR (id=3040609 AND type=1 AND title='Treasure of the Dead') OR (id=3040610 AND type=1 AND title='Web of Curiosity') OR (id=3040611 AND type=2 AND title='The Talking Plant') OR (id=3040612 AND type=2 AND title='The Library') OR (id=3040613 AND type=2 AND title='The Destroyed Portal')))));
INSERT INTO _steppes_guard VALUES('item_identity',((SELECT COUNT(*)FROM items WHERE (id=13063 AND Name='Piece of Parchment') OR (id=53613 AND Name='Totem of the Stonemight') OR (id=53614 AND Name='Gnollbiter') OR (id=53615 AND Name='Gnollcracker') OR (id=53616 AND Name='Gnollcleaver') OR (id=53617 AND Name='Darkfell Starstone') OR (id=53618 AND Name='Stonemight Cupcake') OR (id=53619 AND Name='Darkfell Wineshot') OR (id=53623 AND Name='Saplift Potion') OR (id=53628 AND Name='Healing Mud') OR (id=53629 AND Name='Assassin Weave Cape') OR (id=53630 AND Name='Plundered Krithgorian Knife') OR (id=53632 AND Name='Necklace of Warportal Fragments') OR (id=53635 AND Name='Toegnasher''s Token') OR (id=54667 AND Name='Ancient Charm') OR (id=54668 AND Name='Ancient Giant Book One') OR (id=54669 AND Name='Ancient Giant Book Two') OR (id=54670 AND Name='Portal Rock') OR (id=54671 AND Name='Portal Fragment') OR (id=84238 AND Name='Lump of Elemental Clay') OR (id=84239 AND Name='Living Wood Sample') OR (id=84240 AND Name='Darkfell Fang') OR (id=84241 AND Name='Stonemight Ear') OR (id=84243 AND Name='Gnoll Rune Trap') OR (id=87206 AND Name='Portal Fragment') OR (id=87207 AND Name='Portal Fragment') OR (id=87208 AND Name='Portal Fragment') OR (id=88137 AND Name='Ancient Parchment') OR (id=88138 AND Name='Ancient Parchment') OR (id=88139 AND Name='Ancient Parchment') OR (id=88140 AND Name='Copy of Druidic Rune') OR (id=88141 AND Name='Drakkin Trail Mix') OR (id=88142 AND Name='Fresh Glacier Water') OR (id=108404 AND Name='Intricate Soldier''s Gorget') OR (id=108405 AND Name='Intricate Soldier''s Pauldrons') OR (id=108414 AND Name='Intricate Scryer''s Necklace') OR (id=108415 AND Name='Intricate Scryer''s Shoulderpads') OR (id=108588 AND Name='Intricate Consigned Hammer') OR (id=108589 AND Name='Intricate Consigned Mace') OR (id=108590 AND Name='Intricate Consigned Katana') OR (id=108591 AND Name='Intricate Consigned Scimitar') OR (id=108592 AND Name='Intricate Consigned Sacrificial Dagger') OR (id=108598 AND Name='Intricate Consigned Bow') OR (id=108599 AND Name='Intricate Consigned Hammered Buckler') OR (id=108600 AND Name='Intricate Consigned Targ Shield'))=45));
INSERT INTO _steppes_guard VALUES('npc_identity',((SELECT COUNT(*)FROM npc_types WHERE (id=394153 AND name='Selana') OR (id=394191 AND name='Daer`Lagar') OR (id=394200 AND name='Warden_Jakar') OR (id=399010 AND name='a_Stonemight_goblin') OR (id=399011 AND name='a_Stonemight_goblin') OR (id=399013 AND name='a_Stonemight_goblin') OR (id=399014 AND name='a_Stonemight_goblin') OR (id=399017 AND name='a_Stonemight_elder') OR (id=399019 AND name='a_Stonemight_goblin') OR (id=399021 AND name='a_Stonemight_goblin') OR (id=399022 AND name='a_Stonemight_stonebinder') OR (id=399023 AND name='a_Stonemight_shaman') OR (id=399024 AND name='a_Stonemight_elder') OR (id=399025 AND name='a_Stonemight_goblin') OR (id=399026 AND name='a_Stonemight_tracker') OR (id=399028 AND name='a_Stonemight_stonebinder') OR (id=399030 AND name='a_Stonemight_warrior') OR (id=399031 AND name='a_Stonemight_tracker') OR (id=399032 AND name='Yavia') OR (id=399038 AND name='a_Stonemight_veteran') OR (id=399039 AND name='a_Stonemight_goblin') OR (id=399042 AND name='a_Stonemight_shaman') OR (id=399044 AND name='an_earthen_elemental') OR (id=399046 AND name='an_earthen_elemental') OR (id=399047 AND name='a_Stonemight_stonebinder') OR (id=399049 AND name='#Stonemight_Chieftain_Swiftear') OR (id=399050 AND name='a_Stonemight_shaman') OR (id=399051 AND name='a_Stonemight_raider') OR (id=399052 AND name='a_Stonemight_hunter') OR (id=399053 AND name='a_massive_elemental') OR (id=399056 AND name='a_Stonemight_marauder') OR (id=399057 AND name='a_Darkfell_elder') OR (id=399063 AND name='a_massive_elemental') OR (id=399064 AND name='a_massive_elemental') OR (id=399070 AND name='#Moldren_the_Wise') OR (id=399073 AND name='#Wilped_the_Withered') OR (id=399075 AND name='a_Darkfell_archer') OR (id=399076 AND name='a_Darkfell_archer') OR (id=399094 AND name='a_Darkfell_scavenger') OR (id=399096 AND name='a_Darkfell_huntmaster') OR (id=399097 AND name='a_Darkfell_sharpshooter') OR (id=399098 AND name='a_Darkfell_gnoll') OR (id=399099 AND name='a_Darkfell_gnoll') OR (id=399100 AND name='#Toegnasher') OR (id=399101 AND name='a_Darkfell_shaman') OR (id=399102 AND name='a_Darkfell_gnoll') OR (id=399103 AND name='a_Darkfell_gnoll') OR (id=399104 AND name='a_Darkfell_gnoll') OR (id=399105 AND name='a_Darkfell_gnoll') OR (id=399107 AND name='a_Darkfell_gnoll') OR (id=399108 AND name='a_Darkfell_shaman') OR (id=399109 AND name='a_Darkfell_gnoll') OR (id=399110 AND name='a_Darkfell_gnoll') OR (id=399111 AND name='a_Darkfell_shaman') OR (id=399113 AND name='a_Darkfell_captain') OR (id=399115 AND name='a_Darkfell_warrior') OR (id=399117 AND name='a_Darkfell_hunter') OR (id=399118 AND name='a_Darkfell_gnoll') OR (id=399119 AND name='a_Darkfell_warrior') OR (id=399125 AND name='a_Darkfell_scavenger') OR (id=399127 AND name='a_Darkfell_shaman') OR (id=399128 AND name='a_Darkfell_gnoll') OR (id=399129 AND name='a_Darkfell_archer') OR (id=399130 AND name='a_Darkfell_scavenger') OR (id=399136 AND name='a_Darkfell_gnoll') OR (id=399139 AND name='Bordan_the_Cursed') OR (id=399140 AND name='a_Darkfell_elder') OR (id=399141 AND name='a_Darkfell_captain') OR (id=399142 AND name='a_Darkfell_elder') OR (id=399153 AND name='a_Darkfell_militant') OR (id=399154 AND name='a_Darkfell_militant'))=71));
INSERT INTO _steppes_guard VALUES('component_identity',((SELECT COUNT(*)FROM achievement_components WHERE (achievement_id=500060200 AND component_type=1 AND component_id=50196 AND sequence=7 AND name='Selana - Clay for Selana') OR (achievement_id=500060200 AND component_type=1 AND component_id=50195 AND sequence=6 AND name='Daer`Lagar - Wood for Carving') OR (achievement_id=500060200 AND component_type=1 AND component_id=50193 AND sequence=4 AND name='Warden Jakar - Cull the Gnolls') OR (achievement_id=500060200 AND component_type=1 AND component_id=50192 AND sequence=3 AND name='Warden Jakar - Cull the Goblins') OR (achievement_id=500060200 AND component_type=1 AND component_id=50190 AND sequence=1 AND name='Warden Jakar - Sweeping the Steppes: Goblins') OR (achievement_id=500060200 AND component_type=1 AND component_id=50191 AND sequence=2 AND name='Warden Jakar - Sweeping the Steppes: Gnolls') OR (achievement_id=500060200 AND component_type=1 AND component_id=50194 AND sequence=5 AND name='Warden Jakar - Sowing Dissent') OR (achievement_id=500060300 AND component_type=1 AND component_id=50199 AND sequence=3 AND name='Toegnasher - Book for Toegnasher') OR (achievement_id=500060300 AND component_type=1 AND component_id=50198 AND sequence=2 AND name='Bordan the Cursed - Treasure of the Dead') OR (achievement_id=500060300 AND component_type=1 AND component_id=50197 AND sequence=1 AND name='Yavia - Web of Curiosity') OR (achievement_id=500060400 AND component_type=1 AND component_id=50200 AND sequence=1 AND name='Moldren the Wise - The Talking Plant') OR (achievement_id=500060400 AND component_type=1 AND component_id=50201 AND sequence=2 AND name='Moldren the Wise - The Library') OR (achievement_id=500060400 AND component_type=1 AND component_id=50202 AND sequence=3 AND name='Wilped the Withered - The Destroyed Portal'))=13));
INSERT INTO _steppes_guard VALUES('criteria_3040601',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500060200 AND component_type=1 AND component_id=50196 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040601 AND target_id2=0 AND target_value=0 AND component_sequence=7 AND required_count=1))));
INSERT INTO _steppes_guard VALUES('criteria_3040602',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500060200 AND component_type=1 AND component_id=50195 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040602 AND target_id2=0 AND target_value=0 AND component_sequence=6 AND required_count=1))));
INSERT INTO _steppes_guard VALUES('criteria_3040603',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500060200 AND component_type=1 AND component_id=50193 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040603 AND target_id2=0 AND target_value=0 AND component_sequence=4 AND required_count=1))));
INSERT INTO _steppes_guard VALUES('criteria_3040604',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500060200 AND component_type=1 AND component_id=50192 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040604 AND target_id2=0 AND target_value=0 AND component_sequence=3 AND required_count=1))));
INSERT INTO _steppes_guard VALUES('criteria_3040605',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500060200 AND component_type=1 AND component_id=50190 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040605 AND target_id2=0 AND target_value=0 AND component_sequence=1 AND required_count=1))));
INSERT INTO _steppes_guard VALUES('criteria_3040606',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500060200 AND component_type=1 AND component_id=50191 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040606 AND target_id2=0 AND target_value=0 AND component_sequence=2 AND required_count=1))));
INSERT INTO _steppes_guard VALUES('set_3040606',(NOT EXISTS(SELECT 1 FROM reward_sets WHERE reward_set_id=3040606 AND title<>'Sweeping the Steppes: Gnolls') AND NOT EXISTS(SELECT 1 FROM reward_sources WHERE reward_set_id=3040606 AND NOT(source_type=2 AND source_id=3040606)) AND NOT EXISTS(SELECT 1 FROM reward_sources WHERE source_type=2 AND source_id=3040606 AND reward_set_id<>3040606)));
INSERT INTO _steppes_guard VALUES('reward_304060610',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304060610 AND description<>'May2013 Steppes reward 304060610') AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304060610 AND NOT(reward_set_id=3040606 AND option_id=1)) AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304060610)));
INSERT INTO _steppes_guard VALUES('reward_304060620',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304060620 AND description<>'May2013 Steppes reward 304060620') AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304060620 AND NOT(reward_set_id=3040606 AND option_id=2)) AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304060620)));
INSERT INTO _steppes_guard VALUES('reward_304060630',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304060630 AND description<>'May2013 Steppes reward 304060630') AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304060630 AND NOT(reward_set_id=3040606 AND option_id=3)) AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304060630)));
INSERT INTO _steppes_guard VALUES('reward_304060640',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304060640 AND description<>'May2013 Steppes reward 304060640') AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304060640 AND NOT(reward_set_id=3040606 AND option_id=4)) AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304060640)));
INSERT INTO _steppes_guard VALUES('options_3040606',(NOT EXISTS(SELECT 1 FROM reward_options WHERE reward_set_id=3040606 AND NOT((option_id=1 AND label='Experience' AND common_to_all=1 AND class_mask=65535 AND flags=0) OR (option_id=2 AND label='Gnollbiter' AND common_to_all=0 AND class_mask=65535 AND flags=0) OR (option_id=3 AND label='Gnollcracker' AND common_to_all=0 AND class_mask=65535 AND flags=0) OR (option_id=4 AND label='Gnollcleaver' AND common_to_all=0 AND class_mask=65535 AND flags=0)))));
INSERT INTO _steppes_guard VALUES('links_3040606',(NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_set_id=3040606 AND NOT((option_id=1 AND sequence=0 AND reward_id=304060610) OR (option_id=2 AND sequence=0 AND reward_id=304060620) OR (option_id=3 AND sequence=0 AND reward_id=304060630) OR (option_id=4 AND sequence=0 AND reward_id=304060640)))));
INSERT INTO _steppes_guard VALUES('criteria_3040607',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500060200 AND component_type=1 AND component_id=50194 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040607 AND target_id2=0 AND target_value=0 AND component_sequence=5 AND required_count=1))));
INSERT INTO _steppes_guard VALUES('criteria_3040608',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500060300 AND component_type=1 AND component_id=50199 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040608 AND target_id2=0 AND target_value=0 AND component_sequence=3 AND required_count=1))));
INSERT INTO _steppes_guard VALUES('criteria_3040609',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500060300 AND component_type=1 AND component_id=50198 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040609 AND target_id2=0 AND target_value=0 AND component_sequence=2 AND required_count=1))));
INSERT INTO _steppes_guard VALUES('criteria_3040610',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500060300 AND component_type=1 AND component_id=50197 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040610 AND target_id2=0 AND target_value=0 AND component_sequence=1 AND required_count=1))));
INSERT INTO _steppes_guard VALUES('criteria_3040611',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500060400 AND component_type=1 AND component_id=50200 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040611 AND target_id2=0 AND target_value=0 AND component_sequence=1 AND required_count=1))));
INSERT INTO _steppes_guard VALUES('criteria_3040612',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500060400 AND component_type=1 AND component_id=50201 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040612 AND target_id2=0 AND target_value=0 AND component_sequence=2 AND required_count=1))));
INSERT INTO _steppes_guard VALUES('criteria_3040613',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500060400 AND component_type=1 AND component_id=50202 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040613 AND target_id2=0 AND target_value=0 AND component_sequence=3 AND required_count=1))));
INSERT INTO _steppes_guard VALUES('set_3040691',(NOT EXISTS(SELECT 1 FROM reward_sets WHERE reward_set_id=3040691 AND title<>'Conquering The Steppes (61-70)') AND NOT EXISTS(SELECT 1 FROM reward_sources WHERE reward_set_id=3040691 AND NOT(source_type=1 AND source_id=500060200)) AND NOT EXISTS(SELECT 1 FROM reward_sources WHERE source_type=1 AND source_id=500060200 AND reward_set_id<>3040691)));
INSERT INTO _steppes_guard VALUES('reward_304069110',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304069110 AND description<>'May2013 Steppes reward 304069110') AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304069110 AND NOT(reward_set_id=3040691 AND option_id=1)) AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304069110)));
INSERT INTO _steppes_guard VALUES('reward_304069111',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304069111 AND description<>'May2013 Steppes reward 304069111') AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304069111 AND NOT(reward_set_id=3040691 AND option_id=1)) AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304069111)));
INSERT INTO _steppes_guard VALUES('reward_304069120',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304069120 AND description<>'May2013 Steppes reward 304069120') AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304069120 AND NOT(reward_set_id=3040691 AND option_id=2)) AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304069120)));
INSERT INTO _steppes_guard VALUES('reward_304069121',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304069121 AND description<>'May2013 Steppes reward 304069121') AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304069121 AND NOT(reward_set_id=3040691 AND option_id=2)) AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304069121)));
INSERT INTO _steppes_guard VALUES('reward_304069130',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304069130 AND description<>'May2013 Steppes reward 304069130') AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304069130 AND NOT(reward_set_id=3040691 AND option_id=3)) AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304069130)));
INSERT INTO _steppes_guard VALUES('reward_304069131',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304069131 AND description<>'May2013 Steppes reward 304069131') AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304069131 AND NOT(reward_set_id=3040691 AND option_id=3)) AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304069131)));
INSERT INTO _steppes_guard VALUES('reward_304069140',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304069140 AND description<>'May2013 Steppes reward 304069140') AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304069140 AND NOT(reward_set_id=3040691 AND option_id=4)) AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304069140)));
INSERT INTO _steppes_guard VALUES('reward_304069141',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304069141 AND description<>'May2013 Steppes reward 304069141') AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304069141 AND NOT(reward_set_id=3040691 AND option_id=4)) AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304069141)));
INSERT INTO _steppes_guard VALUES('reward_304069150',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304069150 AND description<>'May2013 Steppes reward 304069150') AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304069150 AND NOT(reward_set_id=3040691 AND option_id=5)) AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304069150)));
INSERT INTO _steppes_guard VALUES('reward_304069151',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304069151 AND description<>'May2013 Steppes reward 304069151') AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304069151 AND NOT(reward_set_id=3040691 AND option_id=5)) AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304069151)));
INSERT INTO _steppes_guard VALUES('reward_304069160',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304069160 AND description<>'May2013 Steppes reward 304069160') AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304069160 AND NOT(reward_set_id=3040691 AND option_id=6)) AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304069160)));
INSERT INTO _steppes_guard VALUES('reward_304069161',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304069161 AND description<>'May2013 Steppes reward 304069161') AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304069161 AND NOT(reward_set_id=3040691 AND option_id=6)) AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304069161)));
INSERT INTO _steppes_guard VALUES('options_3040691',(NOT EXISTS(SELECT 1 FROM reward_options WHERE reward_set_id=3040691 AND NOT((option_id=1 AND label='Intricate Consigned Bow' AND common_to_all=0 AND class_mask=49629 AND flags=0) OR (option_id=2 AND label='Intricate Consigned Hammer' AND common_to_all=0 AND class_mask=49629 AND flags=0) OR (option_id=3 AND label='Intricate Consigned Katana' AND common_to_all=0 AND class_mask=49629 AND flags=0) OR (option_id=4 AND label='Intricate Consigned Sacrificial Dagger' AND common_to_all=0 AND class_mask=49629 AND flags=0) OR (option_id=5 AND label='Intricate Consigned Scimitar' AND common_to_all=0 AND class_mask=49629 AND flags=0) OR (option_id=6 AND label='Intricate caster shield and mace' AND common_to_all=0 AND class_mask=15906 AND flags=0)))));
INSERT INTO _steppes_guard VALUES('links_3040691',(NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_set_id=3040691 AND NOT((option_id=1 AND sequence=0 AND reward_id=304069110) OR (option_id=1 AND sequence=1 AND reward_id=304069111) OR (option_id=2 AND sequence=0 AND reward_id=304069120) OR (option_id=2 AND sequence=1 AND reward_id=304069121) OR (option_id=3 AND sequence=0 AND reward_id=304069130) OR (option_id=3 AND sequence=1 AND reward_id=304069131) OR (option_id=4 AND sequence=0 AND reward_id=304069140) OR (option_id=4 AND sequence=1 AND reward_id=304069141) OR (option_id=5 AND sequence=0 AND reward_id=304069150) OR (option_id=5 AND sequence=1 AND reward_id=304069151) OR (option_id=6 AND sequence=0 AND reward_id=304069160) OR (option_id=6 AND sequence=1 AND reward_id=304069161)))));
INSERT INTO _steppes_guard VALUES('set_3040692',(NOT EXISTS(SELECT 1 FROM reward_sets WHERE reward_set_id=3040692 AND title<>'Steppe Right Up (Steppes 60+)') AND NOT EXISTS(SELECT 1 FROM reward_sources WHERE reward_set_id=3040692 AND NOT(source_type=1 AND source_id=500060300)) AND NOT EXISTS(SELECT 1 FROM reward_sources WHERE source_type=1 AND source_id=500060300 AND reward_set_id<>3040692)));
INSERT INTO _steppes_guard VALUES('reward_304069210',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304069210 AND description<>'May2013 Steppes reward 304069210') AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304069210 AND NOT(reward_set_id=3040692 AND option_id=1)) AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304069210)));
INSERT INTO _steppes_guard VALUES('reward_304069220',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304069220 AND description<>'May2013 Steppes reward 304069220') AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304069220 AND NOT(reward_set_id=3040692 AND option_id=2)) AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304069220)));
INSERT INTO _steppes_guard VALUES('options_3040692',(NOT EXISTS(SELECT 1 FROM reward_options WHERE reward_set_id=3040692 AND NOT((option_id=1 AND label='Intricate Soldier''s Gorget' AND common_to_all=0 AND class_mask=49629 AND flags=0) OR (option_id=2 AND label='Intricate Scryer''s Necklace' AND common_to_all=0 AND class_mask=15906 AND flags=0)))));
INSERT INTO _steppes_guard VALUES('links_3040692',(NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_set_id=3040692 AND NOT((option_id=1 AND sequence=0 AND reward_id=304069210) OR (option_id=2 AND sequence=0 AND reward_id=304069220)))));
INSERT INTO _steppes_guard VALUES('set_3040693',(NOT EXISTS(SELECT 1 FROM reward_sets WHERE reward_set_id=3040693 AND title<>'Rebuilding the Portal (Steppes 60+)') AND NOT EXISTS(SELECT 1 FROM reward_sources WHERE reward_set_id=3040693 AND NOT(source_type=1 AND source_id=500060400)) AND NOT EXISTS(SELECT 1 FROM reward_sources WHERE source_type=1 AND source_id=500060400 AND reward_set_id<>3040693)));
INSERT INTO _steppes_guard VALUES('reward_304069310',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304069310 AND description<>'May2013 Steppes reward 304069310') AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304069310 AND NOT(reward_set_id=3040693 AND option_id=1)) AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304069310)));
INSERT INTO _steppes_guard VALUES('reward_304069320',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=304069320 AND description<>'May2013 Steppes reward 304069320') AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=304069320 AND NOT(reward_set_id=3040693 AND option_id=2)) AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=304069320)));
INSERT INTO _steppes_guard VALUES('options_3040693',(NOT EXISTS(SELECT 1 FROM reward_options WHERE reward_set_id=3040693 AND NOT((option_id=1 AND label='Intricate Soldier''s Pauldrons' AND common_to_all=0 AND class_mask=49629 AND flags=0) OR (option_id=2 AND label='Intricate Scryer''s Shoulderpads' AND common_to_all=0 AND class_mask=15906 AND flags=0)))));
INSERT INTO _steppes_guard VALUES('links_3040693',(NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_set_id=3040693 AND NOT((option_id=1 AND sequence=0 AND reward_id=304069310) OR (option_id=2 AND sequence=0 AND reward_id=304069320)))));
START TRANSACTION;
DELETE FROM task_activities WHERE taskid IN(3040601,3040602,3040603,3040604,3040605,3040606,3040607,3040608,3040609,3040610,3040611,3040612,3040613);
DELETE FROM tasks WHERE id IN(3040601,3040602,3040603,3040604,3040605,3040606,3040607,3040608,3040609,3040610,3040611,3040612,3040613);
INSERT INTO tasks(`id`,`type`,`duration`,`title`,`description`,`reward_text`,`reward_id_list`,`cash_reward`,`exp_reward`,`reward_method`,`min_level`,`level_spread`,`min_players`,`max_players`,`repeatable`,`faction_reward`,`faction_amount`,`enabled`)VALUES
(3040601,2,0,'Clay for Selana','Kill earthen and massive elementals; Loot Lump of Elemental Clay; Deliver clay to Selana.','','53628,10',0,1000,0,65,0,1,1,1,0,0,0),
(3040602,2,0,'Wood for Carving','Collect Living Wood Samples; Deliver wood to Daer`Lagar.','','53623,10',0,1000,0,65,0,1,1,1,0,0,0),
(3040603,2,0,'Cull the Gnolls','Collect Darkfell Fangs (held items accepted); Deliver Darkfell Fangs to Warden Jakar.','','53619,5',0,1000,0,60,0,1,1,1,0,0,0),
(3040604,2,0,'Cull the Goblins','Collect Stonemight Ears (held items accepted); Deliver Stonemight Ears to Warden Jakar.','','53618,5',0,1000,0,62,0,1,1,1,0,0,0),
(3040605,1,21600,'Sweeping the Steppes: Goblins','Slay Stonemight goblins; Kill the domesticated bear; Return to Warden Jakar.','','53613',0,1000,0,60,0,1,6,0,0,0,0),
(3040606,1,0,'Sweeping the Steppes: Gnolls','Slay Darkfell gnolls; Kill the tribal defenders; Kill the Darkfell elites; Return to Warden Jakar.','','',0,0,3,55,0,1,6,1,0,0,0),
(3040607,1,0,'Sowing Dissent','Steal and set a Gnoll Rune Trap in the goblin camps; Watch three goblins be slain by the trap; Return to Warden Jakar.','','53617',0,1000,0,60,0,1,6,1,0,0,0),
(3040608,2,0,'Book for Toegnasher','Deliver the first ancient page; Deliver the second ancient page; Deliver the third ancient page; Make a rubbing of the druid stone with parchment on cursor; Deliver Copy of Druidic Rune.','','53635',0,1000,0,70,0,1,1,1,0,0,0),
(3040609,1,0,'Treasure of the Dead','Find the burial chamber where Bordan obtained his curse; Check the treasure chest; Kill the Crypt Guardian; Return to Bordan the Cursed.','','53630',0,0,0,60,15,3,6,1,0,0,0),
(3040610,1,0,'Web of Curiosity','Deliver Drakkin Trail Mix to Yavia; Deliver Fresh Glacier Water to Yavia; Kill assassin spiderlings; Deliver Drakkin Trail Mix to Yavia; Deliver Fresh Glacier Water to Yavia; Kill assassin spiders; Deliver Drakkin Trail Mix to Yavia; Deliver Fresh Glacier Water to Yavia; Kill assassin spiders; Deliver Drakkin Trail Mix to Yavia; Deliver Fresh Glacier Water to Yavia; Kill mature assassin spiders; Deliver Drakkin Trail Mix to Yavia; Deliver Fresh Glacier Water to Yavia; Kill assassin spider queen; Speak to Yavia.','','53629',0,1000,0,53,0,1,6,1,0,0,0),
(3040611,2,0,'The Talking Plant','Explore the ancient giant crypt far to the north; Slay the Prophet Spirit; Loot the Ancient Charm; Deliver Ancient Charm to Moldren the Wise.','','87206',0,1000,0,65,0,1,1,0,0,0,0),
(3040612,2,0,'The Library','Explore Valdeholm homes with bookcases; Grab Ancient Giant Book One; Grab Ancient Giant Book Two; Deliver Ancient Giant Book One to Moldren; Deliver Ancient Giant Book Two to Moldren.','','87207',0,1000,0,60,0,1,1,1,0,0,0),
(3040613,2,0,'The Destroyed Portal','Loot Portal Fragments from Direwind golems; Loot Portal Rocks from Icefall kobolds; Explore the site of the destroyed portal; Kill the Portal Guardian; Deliver Portal Fragments to Moldren; Deliver Portal Rocks to Moldren.','','53632|87208',0,1000,0,60,0,1,1,1,0,0,0);
INSERT INTO task_activities(`taskid`,`activityid`,`req_activity_id`,`step`,`activitytype`,`target_name`,`goalmethod`,`goalcount`,`description_override`,`npc_match_list`,`item_id_list`,`zones`,`spell_list`,`optional`,`min_x`,`max_x`,`min_y`,`max_y`,`min_z`,`max_z`)VALUES
(3040601,0,-1,0,2,'',0,10,'Kill earthen and massive elementals','399044|399046|399053|399063|399064','','399','',0,0,0,0,0,0,0),
(3040601,1,-1,0,3,'',0,4,'Loot Lump of Elemental Clay','','84238','399','',0,0,0,0,0,0,0),
(3040601,2,-1,1,1,'',0,4,'Deliver clay to Selana','394153','84238','394','',0,0,0,0,0,0,0),
(3040602,0,-1,0,3,'',0,4,'Collect Living Wood Samples','','84239','399','',0,0,0,0,0,0,0),
(3040602,1,-1,1,1,'',0,4,'Deliver wood to Daer`Lagar','394191','84239','394','',0,0,0,0,0,0,0),
(3040603,0,-1,0,255,'',0,10,'Collect Darkfell Fangs (held items accepted)','','84240','399','',0,0,0,0,0,0,0),
(3040603,1,-1,1,1,'',0,10,'Deliver Darkfell Fangs to Warden Jakar','394200','84240','394','',0,0,0,0,0,0,0),
(3040604,0,-1,0,255,'',0,10,'Collect Stonemight Ears (held items accepted)','','84241','399','',0,0,0,0,0,0,0),
(3040604,1,-1,1,1,'',0,10,'Deliver Stonemight Ears to Warden Jakar','394200','84241','394','',0,0,0,0,0,0,0),
(3040605,0,-1,0,2,'',0,30,'Slay Stonemight goblins','399010|399011|399013|399014|399017|399019|399021|399022|399023|399024|399025|399026|399028|399030|399031|399038|399039|399042|399047|399049|399050|399051|399052|399056','','399','',0,0,0,0,0,0,0),
(3040605,1,-1,1,255,'',0,1,'Kill the domesticated bear','','','399','',0,0,0,0,0,0,0),
(3040605,2,-1,2,4,'',0,1,'Return to Warden Jakar','394200','','394','',0,0,0,0,0,0,0),
(3040606,0,-1,0,2,'',0,20,'Slay Darkfell gnolls','399057|399075|399076|399094|399096|399097|399098|399099|399101|399102|399103|399104|399105|399107|399108|399109|399110|399111|399113|399115|399117|399118|399119|399125|399127|399128|399129|399130|399136|399140|399141|399142|399153|399154','','399','',0,0,0,0,0,0,0),
(3040606,1,-1,0,255,'',0,4,'Kill the tribal defenders','','','399','',0,0,0,0,0,0,0),
(3040606,2,-1,0,255,'',0,3,'Kill the Darkfell elites','','','399','',0,0,0,0,0,0,0),
(3040606,3,-1,1,4,'',0,1,'Return to Warden Jakar','394200','','394','',0,0,0,0,0,0,0),
(3040607,0,-1,0,255,'',0,1,'Steal and set a Gnoll Rune Trap in the goblin camps','','84243','399','',0,0,0,0,0,0,0),
(3040607,1,-1,1,255,'',0,1,'Watch three goblins be slain by the trap','','','399','',0,0,0,0,0,0,0),
(3040607,2,-1,2,4,'',0,1,'Return to Warden Jakar','394200','','394','',0,0,0,0,0,0,0),
(3040608,0,-1,0,1,'',0,1,'Deliver the first ancient page','399100','88137','399','',0,0,0,0,0,0,0),
(3040608,1,-1,0,1,'',0,1,'Deliver the second ancient page','399100','88138','399','',0,0,0,0,0,0,0),
(3040608,2,-1,0,1,'',0,1,'Deliver the third ancient page','399100','88139','399','',0,0,0,0,0,0,0),
(3040608,3,-1,1,255,'',0,1,'Make a rubbing of the druid stone with parchment on cursor','','13063','399','',0,0,0,0,0,0,0),
(3040608,4,-1,2,1,'',0,1,'Deliver Copy of Druidic Rune','399100','88140','399','',0,0,0,0,0,0,0),
(3040609,0,-1,0,255,'',0,1,'Find the burial chamber where Bordan obtained his curse','','','399','',0,0,0,0,0,0,0),
(3040609,1,-1,1,255,'',0,1,'Check the treasure chest','','','399','',0,0,0,0,0,0,0),
(3040609,2,-1,2,255,'',0,1,'Kill the Crypt Guardian','','','399','',0,0,0,0,0,0,0),
(3040609,3,-1,3,4,'',0,1,'Return to Bordan the Cursed','399139','','399','',0,0,0,0,0,0,0),
(3040610,0,-1,0,1,'',0,1,'Deliver Drakkin Trail Mix to Yavia','399032','88141','399','',0,0,0,0,0,0,0),
(3040610,1,-1,0,1,'',0,1,'Deliver Fresh Glacier Water to Yavia','399032','88142','399','',0,0,0,0,0,0,0),
(3040610,2,-1,1,255,'',0,2,'Kill assassin spiderlings','','','399','',0,0,0,0,0,0,0),
(3040610,3,-1,2,1,'',0,1,'Deliver Drakkin Trail Mix to Yavia','399032','88141','399','',0,0,0,0,0,0,0),
(3040610,4,-1,2,1,'',0,1,'Deliver Fresh Glacier Water to Yavia','399032','88142','399','',0,0,0,0,0,0,0),
(3040610,5,-1,3,255,'',0,2,'Kill assassin spiders','','','399','',0,0,0,0,0,0,0),
(3040610,6,-1,4,1,'',0,1,'Deliver Drakkin Trail Mix to Yavia','399032','88141','399','',0,0,0,0,0,0,0),
(3040610,7,-1,4,1,'',0,1,'Deliver Fresh Glacier Water to Yavia','399032','88142','399','',0,0,0,0,0,0,0),
(3040610,8,-1,5,255,'',0,3,'Kill assassin spiders','','','399','',0,0,0,0,0,0,0),
(3040610,9,-1,6,1,'',0,1,'Deliver Drakkin Trail Mix to Yavia','399032','88141','399','',0,0,0,0,0,0,0),
(3040610,10,-1,6,1,'',0,1,'Deliver Fresh Glacier Water to Yavia','399032','88142','399','',0,0,0,0,0,0,0),
(3040610,11,-1,7,255,'',0,2,'Kill mature assassin spiders','','','399','',0,0,0,0,0,0,0),
(3040610,12,-1,8,1,'',0,1,'Deliver Drakkin Trail Mix to Yavia','399032','88141','399','',0,0,0,0,0,0,0),
(3040610,13,-1,8,1,'',0,1,'Deliver Fresh Glacier Water to Yavia','399032','88142','399','',0,0,0,0,0,0,0),
(3040610,14,-1,9,255,'',0,1,'Kill assassin spider queen','','','399','',0,0,0,0,0,0,0),
(3040610,15,-1,10,4,'',0,1,'Speak to Yavia','399032','','399','',0,0,0,0,0,0,0),
(3040611,0,-1,0,255,'',0,1,'Explore the ancient giant crypt far to the north','','','399','',0,0,0,0,0,0,0),
(3040611,1,-1,1,255,'',0,1,'Slay the Prophet Spirit','','','399','',0,0,0,0,0,0,0),
(3040611,2,-1,2,3,'',0,1,'Loot the Ancient Charm','','54667','399','',0,0,0,0,0,0,0),
(3040611,3,-1,3,1,'',0,1,'Deliver Ancient Charm to Moldren the Wise','399070','54667','399','',0,0,0,0,0,0,0),
(3040612,0,-1,0,255,'',0,1,'Explore Valdeholm homes with bookcases','','','401','',0,0,0,0,0,0,0),
(3040612,1,-1,1,3,'',0,1,'Grab Ancient Giant Book One','','54668','401','',0,0,0,0,0,0,0),
(3040612,2,-1,1,3,'',0,1,'Grab Ancient Giant Book Two','','54669','401','',0,0,0,0,0,0,0),
(3040612,3,-1,2,1,'',0,1,'Deliver Ancient Giant Book One to Moldren','399070','54668','399','',0,0,0,0,0,0,0),
(3040612,4,-1,2,1,'',0,1,'Deliver Ancient Giant Book Two to Moldren','399070','54669','399','',0,0,0,0,0,0,0),
(3040613,0,-1,0,3,'',0,4,'Loot Portal Fragments from Direwind golems','','54671','405','',0,0,0,0,0,0,0),
(3040613,1,-1,0,3,'',0,4,'Loot Portal Rocks from Icefall kobolds','','54670','400','',0,0,0,0,0,0,0),
(3040613,2,-1,1,255,'',0,1,'Explore the site of the destroyed portal','','','399','',0,0,0,0,0,0,0),
(3040613,3,-1,2,255,'',0,1,'Kill the Portal Guardian','','','399','',0,0,0,0,0,0,0),
(3040613,4,-1,3,1,'',0,4,'Deliver Portal Fragments to Moldren','399070','54671','399','',0,0,0,0,0,0,0),
(3040613,5,-1,3,1,'',0,4,'Deliver Portal Rocks to Moldren','399070','54670','399','',0,0,0,0,0,0,0);
DELETE FROM achievement_criteria WHERE achievement_id=500060200 AND component_type=1 AND component_id=50196;
DELETE FROM achievement_criteria WHERE achievement_id=500060200 AND component_type=1 AND component_id=50195;
DELETE FROM achievement_criteria WHERE achievement_id=500060200 AND component_type=1 AND component_id=50193;
DELETE FROM achievement_criteria WHERE achievement_id=500060200 AND component_type=1 AND component_id=50192;
DELETE FROM achievement_criteria WHERE achievement_id=500060200 AND component_type=1 AND component_id=50190;
DELETE FROM achievement_criteria WHERE achievement_id=500060200 AND component_type=1 AND component_id=50191;
DELETE FROM achievement_criteria WHERE achievement_id=500060200 AND component_type=1 AND component_id=50194;
DELETE FROM achievement_criteria WHERE achievement_id=500060300 AND component_type=1 AND component_id=50199;
DELETE FROM achievement_criteria WHERE achievement_id=500060300 AND component_type=1 AND component_id=50198;
DELETE FROM achievement_criteria WHERE achievement_id=500060300 AND component_type=1 AND component_id=50197;
DELETE FROM achievement_criteria WHERE achievement_id=500060400 AND component_type=1 AND component_id=50200;
DELETE FROM achievement_criteria WHERE achievement_id=500060400 AND component_type=1 AND component_id=50201;
DELETE FROM achievement_criteria WHERE achievement_id=500060400 AND component_type=1 AND component_id=50202;
INSERT INTO achievement_criteria(`achievement_id`,`component_type`,`component_sequence`,`component_id`,`event_type`,`progress_mode`,`behavior`,`target_id`,`target_id2`,`target_value`,`required_count`,`enabled`)VALUES
(500060200,1,7,50196,4,3,0,3040601,0,0,1,0),
(500060200,1,6,50195,4,3,0,3040602,0,0,1,0),
(500060200,1,4,50193,4,3,0,3040603,0,0,1,0),
(500060200,1,3,50192,4,3,0,3040604,0,0,1,0),
(500060200,1,1,50190,4,3,0,3040605,0,0,1,0),
(500060200,1,2,50191,4,3,0,3040606,0,0,1,0),
(500060200,1,5,50194,4,3,0,3040607,0,0,1,0),
(500060300,1,3,50199,4,3,0,3040608,0,0,1,0),
(500060300,1,2,50198,4,3,0,3040609,0,0,1,0),
(500060300,1,1,50197,4,3,0,3040610,0,0,1,0),
(500060400,1,1,50200,4,3,0,3040611,0,0,1,0),
(500060400,1,2,50201,4,3,0,3040612,0,0,1,0),
(500060400,1,3,50202,4,3,0,3040613,0,0,1,0);
DELETE FROM reward_option_entries WHERE reward_set_id IN(3040606,3040691,3040692,3040693);
DELETE FROM reward_options WHERE reward_set_id IN(3040606,3040691,3040692,3040693);
DELETE FROM reward_sources WHERE reward_set_id IN(3040606,3040691,3040692,3040693);
DELETE FROM reward_sets WHERE reward_set_id IN(3040606,3040691,3040692,3040693);
DELETE FROM rewards WHERE reward_id IN(304060610,304060620,304060630,304060640,304069110,304069111,304069120,304069121,304069130,304069131,304069140,304069141,304069150,304069151,304069160,304069161,304069210,304069220,304069310,304069320);
INSERT INTO reward_sets(`reward_set_id`,`title`,`enabled`)VALUES
(3040606,'Sweeping the Steppes: Gnolls',0),
(3040691,'Conquering The Steppes (61-70)',0),
(3040692,'Steppe Right Up (Steppes 60+)',0),
(3040693,'Rebuilding the Portal (Steppes 60+)',0);
INSERT INTO reward_sources(`source_type`,`source_id`,`reward_set_id`,`enabled`)VALUES
(2,3040606,3040606,0),
(1,500060200,3040691,0),
(1,500060300,3040692,0),
(1,500060400,3040693,0);
INSERT INTO rewards(`reward_id`,`reward_type`,`reward_data_id`,`amount`,`description`,`enabled`)VALUES
(304060610,1,1,1000,'May2013 Steppes reward 304060610',0),
(304060620,0,53614,1,'May2013 Steppes reward 304060620',0),
(304060630,0,53615,1,'May2013 Steppes reward 304060630',0),
(304060640,0,53616,1,'May2013 Steppes reward 304060640',0),
(304069110,0,108599,1,'May2013 Steppes reward 304069110',0),
(304069111,0,108598,1,'May2013 Steppes reward 304069111',0),
(304069120,0,108599,1,'May2013 Steppes reward 304069120',0),
(304069121,0,108588,1,'May2013 Steppes reward 304069121',0),
(304069130,0,108599,1,'May2013 Steppes reward 304069130',0),
(304069131,0,108590,1,'May2013 Steppes reward 304069131',0),
(304069140,0,108599,1,'May2013 Steppes reward 304069140',0),
(304069141,0,108592,1,'May2013 Steppes reward 304069141',0),
(304069150,0,108599,1,'May2013 Steppes reward 304069150',0),
(304069151,0,108591,1,'May2013 Steppes reward 304069151',0),
(304069160,0,108600,1,'May2013 Steppes reward 304069160',0),
(304069161,0,108589,1,'May2013 Steppes reward 304069161',0),
(304069210,0,108404,1,'May2013 Steppes reward 304069210',0),
(304069220,0,108414,1,'May2013 Steppes reward 304069220',0),
(304069310,0,108405,1,'May2013 Steppes reward 304069310',0),
(304069320,0,108415,1,'May2013 Steppes reward 304069320',0);
INSERT INTO reward_options(`reward_set_id`,`option_id`,`sequence`,`label`,`common_to_all`,`flags`,`enabled`,`class_mask`)VALUES
(3040606,1,1,'Experience',1,0,0,65535),
(3040606,2,2,'Gnollbiter',0,0,0,65535),
(3040606,3,3,'Gnollcracker',0,0,0,65535),
(3040606,4,4,'Gnollcleaver',0,0,0,65535),
(3040691,1,1,'Intricate Consigned Bow',0,0,0,49629),
(3040691,2,2,'Intricate Consigned Hammer',0,0,0,49629),
(3040691,3,3,'Intricate Consigned Katana',0,0,0,49629),
(3040691,4,4,'Intricate Consigned Sacrificial Dagger',0,0,0,49629),
(3040691,5,5,'Intricate Consigned Scimitar',0,0,0,49629),
(3040691,6,6,'Intricate caster shield and mace',0,0,0,15906),
(3040692,1,1,'Intricate Soldier''s Gorget',0,0,0,49629),
(3040692,2,2,'Intricate Scryer''s Necklace',0,0,0,15906),
(3040693,1,1,'Intricate Soldier''s Pauldrons',0,0,0,49629),
(3040693,2,2,'Intricate Scryer''s Shoulderpads',0,0,0,15906);
INSERT INTO reward_option_entries(`reward_set_id`,`option_id`,`sequence`,`reward_id`)VALUES
(3040606,1,0,304060610),
(3040606,2,0,304060620),
(3040606,3,0,304060630),
(3040606,4,0,304060640),
(3040691,1,0,304069110),
(3040691,1,1,304069111),
(3040691,2,0,304069120),
(3040691,2,1,304069121),
(3040691,3,0,304069130),
(3040691,3,1,304069131),
(3040691,4,0,304069140),
(3040691,4,1,304069141),
(3040691,5,0,304069150),
(3040691,5,1,304069151),
(3040691,6,0,304069160),
(3040691,6,1,304069161),
(3040692,1,0,304069210),
(3040692,2,0,304069220),
(3040693,1,0,304069310),
(3040693,2,0,304069320);
COMMIT;

-- ---- steppes/sql/030-actors-pickups.sql ----
-- Compare ground Z at 0.001 zone units: an actual MariaDB FLOAT dump/restore
-- changed 183.34869384765625 to 183.3489990234375. Other identity guards remain.
-- OFFLINE labelled Steppes default proposal. Eleven unspawned NPC clones; six ground routes disabled by max_allowed0.
-- No original NPC, spawn2, object, quest, player row or active feature toggle is changed.
-- MariaDB; backup scoped tables, stop content writers, review values and SET @steppes_defaults_reviewed=1 in same session. Never use --force.
SET NAMES utf8mb4;
SET SESSION check_constraint_checks=1;
DROP TEMPORARY TABLE IF EXISTS `_stpd_npc_types`;
CREATE TEMPORARY TABLE `_stpd_npc_types` LIKE `npc_types`;
INSERT INTO `_stpd_npc_types`(`id`,`name`,`lastname`,`level`,`race`,`class`,`bodytype`,`hp`,`mana`,`gender`,`texture`,`helmtexture`,`herosforgemodel`,`size`,`hp_regen_rate`,`hp_regen_per_second`,`mana_regen_rate`,`loottable_id`,`merchant_id`,`greed`,`alt_currency_id`,`npc_spells_id`,`npc_spells_effects_id`,`npc_faction_id`,`adventure_template_id`,`trap_template`,`mindmg`,`maxdmg`,`attack_count`,`npcspecialattks`,`special_abilities`,`aggroradius`,`assistradius`,`face`,`luclin_hairstyle`,`luclin_haircolor`,`luclin_eyecolor`,`luclin_eyecolor2`,`luclin_beardcolor`,`luclin_beard`,`drakkin_heritage`,`drakkin_tattoo`,`drakkin_details`,`armortint_id`,`armortint_red`,`armortint_green`,`armortint_blue`,`d_melee_texture1`,`d_melee_texture2`,`ammo_idfile`,`prim_melee_type`,`sec_melee_type`,`ranged_type`,`runspeed`,`MR`,`CR`,`DR`,`FR`,`PR`,`Corrup`,`PhR`,`see_invis`,`see_invis_undead`,`qglobal`,`AC`,`npc_aggro`,`spawn_limit`,`attack_speed`,`attack_delay`,`findable`,`STR`,`STA`,`DEX`,`AGI`,`_INT`,`WIS`,`CHA`,`see_hide`,`see_improved_hide`,`trackable`,`isbot`,`exclude`,`ATK`,`Accuracy`,`Avoidance`,`slow_mitigation`,`version`,`maxlevel`,`scalerate`,`private_corpse`,`unique_spawn_by_name`,`underwater`,`isquest`,`emoteid`,`spellscale`,`healscale`,`no_target_hotkey`,`raid_target`,`armtexture`,`bracertexture`,`handtexture`,`legtexture`,`feettexture`,`light`,`walkspeed`,`peqid`,`unique_`,`fixed`,`ignore_despawn`,`show_name`,`untargetable`,`charm_ac`,`charm_min_dmg`,`charm_max_dmg`,`charm_attack_delay`,`charm_accuracy_rating`,`charm_avoidance_rating`,`charm_atk`,`skip_global_loot`,`rare_spawn`,`stuck_behavior`,`model`,`flymode`,`always_aggro`,`exp_mod`,`heroic_strikethrough`,`faction_amount`,`keeps_sold_items`,`is_parcel_merchant`,`multiquest_enabled`,`npc_tint_id`) VALUES
(399911,CONVERT(0x615f646f6d6573746963617465645f62656172 USING utf8mb4),'',64,43,1,21,64000,0,2,0,0,0,12,0,0,0,0,0,0,0,0,0,0,0,0,128,768,-1,'',CONVERT(0x31302c31 USING utf8mb4),45,0,255,0,0,0,0,0,255,0,0,0,0,0,0,0,0,0,CONVERT(0x49543130 USING utf8mb4),28,28,7,1.25,50,50,50,50,50,50,50,0,0,0,600,0,0,0,30,0,200,200,200,200,200,200,200,0,0,1,0,1,600,0,0,0,0,64,100,0,0,0,1,0,100,100,0,0,0,0,0,0,0,0,0.7,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,100,0,0,1,0,0,0),
(399912,CONVERT(0x615f74726962616c5f646566656e646572 USING utf8mb4),'',65,524,1,1,65000,0,2,0,0,0,9,0,0,0,0,0,0,0,0,0,0,0,0,130,780,-1,'',CONVERT(0x31302c31 USING utf8mb4),45,0,255,0,0,0,0,0,255,0,0,0,0,0,0,0,0,0,CONVERT(0x49543130 USING utf8mb4),28,28,7,1.25,50,50,50,50,50,50,50,0,0,0,600,0,0,0,30,0,200,200,200,200,200,200,200,0,0,1,0,1,600,0,0,0,0,65,100,0,0,0,1,0,100,100,0,0,0,0,0,0,0,0,0.7,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,100,0,0,1,0,0,0),
(399902,CONVERT(0x615f4461726b66656c6c5f656c697465 USING utf8mb4),'',67,524,1,1,67000,0,2,0,0,0,9,0,0,0,0,0,0,0,0,0,0,0,0,134,804,-1,'',CONVERT(0x31302c31 USING utf8mb4),45,0,255,0,0,0,0,0,255,0,0,0,0,0,0,0,0,0,CONVERT(0x49543130 USING utf8mb4),28,28,7,1.25,50,50,50,50,50,50,50,0,0,0,600,0,0,0,30,0,200,200,200,200,200,200,200,0,0,1,0,1,600,0,0,0,0,67,100,0,0,0,1,0,100,100,0,0,0,0,0,0,0,0,0.7,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,100,0,0,1,0,0,0),
(399903,CONVERT(0x615f676e6f6c6c6973685f72756e655f74726170 USING utf8mb4),'',1,127,1,11,1,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,'',CONVERT(0x31392c315e32302c315e32342c315e32352c315e33352c315e33392c31 USING utf8mb4),0,0,0,0,0,0,0,0,255,0,0,0,0,0,0,0,0,0,CONVERT(0x49543130 USING utf8mb4),28,28,7,0,50,50,50,50,50,50,50,0,0,0,0,0,0,0,30,0,200,200,200,200,200,200,200,0,0,0,0,1,0,0,0,0,0,1,100,0,0,0,1,0,100,100,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,-1,0,100,0,0,1,0,0,0),
(399904,CONVERT(0x43727970745f477561726469616e USING utf8mb4),'',65,523,1,3,70000,0,2,0,0,0,22,0,0,0,0,0,0,0,0,0,0,0,0,130,780,-1,'',CONVERT(0x31302c31 USING utf8mb4),45,0,255,0,0,0,0,0,255,0,0,0,0,0,0,0,0,0,CONVERT(0x49543130 USING utf8mb4),28,28,7,1.25,50,50,50,50,50,50,50,0,0,0,600,0,0,0,30,0,200,200,200,200,200,200,200,0,0,1,0,1,600,0,0,0,0,65,100,0,0,0,1,0,100,100,0,0,0,0,0,0,0,0,0.7,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,100,0,0,1,0,0,0),
(399905,CONVERT(0x617373617373696e5f7370696465726c696e67 USING utf8mb4),'',60,440,1,22,30000,0,2,2,2,0,12,0,0,0,0,0,0,0,0,0,0,0,0,120,600,-1,'',CONVERT(0x31302c31 USING utf8mb4),45,0,255,0,0,0,0,0,255,0,0,0,0,0,0,0,0,0,CONVERT(0x49543130 USING utf8mb4),28,28,7,1.25,50,50,50,50,50,50,50,1,0,0,600,0,0,0,30,0,200,200,200,200,200,200,200,0,0,1,0,1,600,0,0,0,0,60,100,0,0,0,1,0,100,100,0,0,0,0,0,0,0,0,0.7,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,100,0,0,1,0,0,0),
(399906,CONVERT(0x617373617373696e5f737069646572 USING utf8mb4),'',62,440,1,22,45000,0,2,2,2,0,17,0,0,0,0,0,0,0,0,0,0,0,0,124,700,-1,'',CONVERT(0x31302c31 USING utf8mb4),45,0,255,0,0,0,0,0,255,0,0,0,0,0,0,0,0,0,CONVERT(0x49543130 USING utf8mb4),28,28,7,1.25,50,50,50,50,50,50,50,1,0,0,600,0,0,0,30,0,200,200,200,200,200,200,200,0,0,1,0,1,600,0,0,0,0,62,100,0,0,0,1,0,100,100,0,0,0,0,0,0,0,0,0.7,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,100,0,0,1,0,0,0),
(399907,CONVERT(0x6d61747572655f617373617373696e5f737069646572 USING utf8mb4),'',64,440,1,22,64000,0,2,2,2,0,19,0,0,0,0,0,0,0,0,0,0,0,0,128,768,-1,'',CONVERT(0x31302c31 USING utf8mb4),45,0,255,0,0,0,0,0,255,0,0,0,0,0,0,0,0,0,CONVERT(0x49543130 USING utf8mb4),28,28,7,1.25,50,50,50,50,50,50,50,0,0,0,600,0,0,0,30,0,200,200,200,200,200,200,200,0,0,1,0,1,600,0,0,0,0,64,100,0,0,0,1,0,100,100,0,0,0,0,0,0,0,0,0.7,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,100,0,0,1,0,0,0),
(399908,CONVERT(0x617373617373696e5f7370696465725f717565656e USING utf8mb4),'',66,440,1,22,80000,0,2,2,2,0,23,0,0,0,0,0,0,0,0,0,0,0,0,132,792,-1,'',CONVERT(0x31302c31 USING utf8mb4),45,0,255,0,0,0,0,0,255,0,0,0,0,0,0,0,0,0,CONVERT(0x49543130 USING utf8mb4),28,28,7,1.25,50,50,50,50,50,50,50,1,0,0,600,0,0,0,30,0,200,200,200,200,200,200,200,0,0,1,0,1,600,0,0,0,0,66,100,0,0,0,1,0,100,100,0,0,0,0,0,0,0,0,0.7,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,100,0,0,1,0,0,0),
(399909,CONVERT(0x50726f706865745f537069726974 USING utf8mb4),'',70,523,1,3,79000,0,2,0,0,0,22,0,0,0,0,0,0,0,0,0,0,0,0,140,840,-1,'',CONVERT(0x31302c315e332c312c32302c315e31352c31 USING utf8mb4),45,0,255,0,0,0,0,0,255,0,0,0,0,0,0,0,0,0,CONVERT(0x49543130 USING utf8mb4),28,28,7,1.25,50,50,50,50,50,50,50,1,0,0,600,0,0,0,30,0,200,200,200,200,200,200,200,0,0,1,0,1,600,0,0,0,0,70,100,0,0,0,1,0,100,100,0,0,0,0,0,0,0,0,0.7,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,100,0,0,1,0,0,0),
(399910,CONVERT(0x5468655f506f7274616c5f477561726469616e USING utf8mb4),'',70,209,1,24,120000,0,2,0,0,0,15,0,0,0,0,0,0,0,399900,0,0,0,0,140,840,-1,'',CONVERT(0x31302c31 USING utf8mb4),45,0,255,0,0,0,0,0,255,0,0,0,0,0,0,0,0,0,CONVERT(0x49543130 USING utf8mb4),28,28,7,1.25,50,50,50,50,50,50,50,0,0,0,600,0,0,0,30,0,200,200,200,200,200,200,200,0,0,1,0,1,600,0,0,0,0,70,100,0,0,0,1,0,100,100,0,0,0,0,0,0,0,0,0.7,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,-1,0,100,0,0,1,0,0,0);
DROP TEMPORARY TABLE IF EXISTS `_stpd_npc_spells`;
CREATE TEMPORARY TABLE `_stpd_npc_spells` LIKE `npc_spells`;
INSERT INTO `_stpd_npc_spells`(`id`,`name`,`parent_list`,`attack_proc`,`proc_chance`,`range_proc`,`rproc_chance`,`defensive_proc`,`dproc_chance`,`fail_recast`,`engaged_no_sp_recast_min`,`engaged_no_sp_recast_max`,`engaged_b_self_chance`,`engaged_b_other_chance`,`engaged_d_chance`,`pursue_no_sp_recast_min`,`pursue_no_sp_recast_max`,`pursue_d_chance`,`idle_no_sp_recast_min`,`idle_no_sp_recast_max`,`idle_b_chance`) VALUES
(399900,CONVERT(0x5374657070657320636f6e666967757261626c6520506f7274616c20477561726469616e USING utf8mb4),0,-1,0,-1,0,-1,0,2000,2000,4000,0,0,35,2000,4000,35,30000,30000,0);
DROP TEMPORARY TABLE IF EXISTS `_stpd_npc_spells_entries`;
CREATE TEMPORARY TABLE `_stpd_npc_spells_entries` LIKE `npc_spells_entries`;
INSERT INTO `_stpd_npc_spells_entries`(`id`,`npc_spells_id`,`spellid`,`type`,`minlevel`,`maxlevel`,`manacost`,`recast_delay`,`priority`,`resist_adjust`,`min_hp`,`max_hp`,`min_expansion`,`max_expansion`,`content_flags`,`content_flags_disabled`) VALUES
(3999000,399900,9200,1,70,70,0,30,1,0,0,100,-1,-1,NULL,NULL),
(3999001,399900,9201,4,70,70,0,60,1,0,0,100,-1,-1,NULL,NULL);
DROP TEMPORARY TABLE IF EXISTS `_stpd_ground_spawns`;
CREATE TEMPORARY TABLE `_stpd_ground_spawns` LIKE `ground_spawns`;
INSERT INTO `_stpd_ground_spawns`(`id`,`zoneid`,`version`,`max_x`,`min_x`,`max_y`,`min_y`,`max_z`,`heading`,`name`,`item`,`max_allowed`,`respawn_timer`,`fix_z`,`comment`,`min_expansion`,`max_expansion`,`content_flags`,`content_flags_disabled`) VALUES
(399900,399,0,-1100,-1100,1840,1840,183.3487,0,CONVERT(0x495431303833315f4143544f52444546 USING utf8mb4),84243,0,300,1,CONVERT(0x53746570706573206c6162656c6c65642064656661756c742063616e6469646174653b2064697361626c6564206d61785f616c6c6f77656430 USING utf8mb4),-1,-1,NULL,NULL),
(399901,399,0,-1795,-1795,-1438,-1438,53.9146,0,CONVERT(0x495436335f4143544f52444546 USING utf8mb4),88141,0,10,1,CONVERT(0x53746570706573206c6162656c6c65642064656661756c742063616e6469646174653b2064697361626c6564206d61785f616c6c6f77656430 USING utf8mb4),-1,-1,NULL,NULL),
(399902,399,0,-1796,-1796,-1445,-1445,54.6425,0,CONVERT(0x495436335f4143544f52444546 USING utf8mb4),88142,0,10,1,CONVERT(0x53746570706573206c6162656c6c65642064656661756c742063616e6469646174653b2064697361626c6564206d61785f616c6c6f77656430 USING utf8mb4),-1,-1,NULL,NULL),
(399903,399,0,1209,963.19,209,-544.45,-99999,0,CONVERT(0x495436355f4143544f52444546 USING utf8mb4),88137,0,300,1,CONVERT(0x53746570706573206c6162656c6c65642064656661756c742063616e6469646174653b2064697361626c6564206d61785f616c6c6f77656430 USING utf8mb4),-1,-1,NULL,NULL),
(399904,401,0,-1230,-1230,-700,-700,0.692,0,CONVERT(0x495431303634355f4143544f52444546 USING utf8mb4),54668,0,300,1,CONVERT(0x53746570706573206c6162656c6c65642064656661756c742063616e6469646174653b2064697361626c6564206d61785f616c6c6f77656430 USING utf8mb4),-1,-1,NULL,NULL),
(399905,401,0,-1610,-1610,-435,-435,1.6283,0,CONVERT(0x495431303634355f4143544f52444546 USING utf8mb4),54669,0,300,1,CONVERT(0x53746570706573206c6162656c6c65642064656661756c742063616e6469646174653b2064697361626c6564206d61785f616c6c6f77656430 USING utf8mb4),-1,-1,NULL,NULL);
DROP TEMPORARY TABLE IF EXISTS `_stpd_guard`;
CREATE TEMPORARY TABLE `_stpd_guard`(ok TINYINT NOT NULL CHECK(ok=1)) ENGINE=InnoDB;
START TRANSACTION;
-- NMS adaptation: clear partial rows committed by earlier guarded attempts
-- (their own per-file commits), so the guards see the preimage state.
DELETE FROM `npc_spells_entries` WHERE npc_spells_id BETWEEN 399900 AND 399921;
DELETE FROM `npc_spells` WHERE id BETWEEN 399900 AND 399921;
DELETE FROM `npc_types` WHERE id BETWEEN 399902 AND 399921 AND npc_spells_id IN(0,399900,399901,399911,399912);
INSERT INTO ground_spawns SELECT * FROM `_stpd_ground_spawns` WHERE id IN(399900,399901)
  AND NOT EXISTS(SELECT 1 FROM ground_spawns g WHERE g.id=_stpd_ground_spawns.id);
UPDATE ground_spawns g JOIN `_stpd_ground_spawns` e ON g.id=e.id SET g.zoneid=e.zoneid, g.version=e.version, g.min_x=e.min_x, g.max_x=e.max_x, g.min_y=e.min_y, g.max_y=e.max_y, g.heading=e.heading, g.name=e.name, g.item=e.item, g.max_allowed=e.max_allowed, g.comment=e.comment, g.respawn_timer=e.respawn_timer, g.fix_z=e.fix_z WHERE g.id IN(399902,399903,399904,399905);
SET @steppes_defaults_ok=COALESCE(@steppes_defaults_reviewed,0)=1
 AND ((SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME IN('npc_types','npc_spells','npc_spells_entries','ground_spawns') AND ENGINE='InnoDB')=4)
 AND (NOT EXISTS(SELECT 1 FROM `npc_types` a WHERE a.id IN(399911,399912,399902,399903,399904,399905,399906,399907,399908,399909,399910) AND NOT EXISTS(SELECT 1 FROM `_stpd_npc_types` e WHERE a.`id`<=>e.`id` AND BINARY a.`name`<=>BINARY e.`name` AND BINARY a.`lastname`<=>BINARY e.`lastname` AND a.`level`<=>e.`level` AND a.`race`<=>e.`race` AND a.`class`<=>e.`class` AND a.`bodytype`<=>e.`bodytype` AND a.`hp`<=>e.`hp` AND a.`mana`<=>e.`mana` AND a.`gender`<=>e.`gender` AND a.`texture`<=>e.`texture` AND a.`helmtexture`<=>e.`helmtexture` AND a.`herosforgemodel`<=>e.`herosforgemodel` AND a.`size`<=>e.`size` AND a.`hp_regen_rate`<=>e.`hp_regen_rate` AND a.`hp_regen_per_second`<=>e.`hp_regen_per_second` AND a.`mana_regen_rate`<=>e.`mana_regen_rate` AND a.`loottable_id`<=>e.`loottable_id` AND a.`merchant_id`<=>e.`merchant_id` AND a.`greed`<=>e.`greed` AND a.`alt_currency_id`<=>e.`alt_currency_id` AND a.`npc_spells_id`<=>e.`npc_spells_id` AND a.`npc_spells_effects_id`<=>e.`npc_spells_effects_id` AND a.`npc_faction_id`<=>e.`npc_faction_id` AND a.`adventure_template_id`<=>e.`adventure_template_id` AND a.`trap_template`<=>e.`trap_template` AND a.`mindmg`<=>e.`mindmg` AND a.`maxdmg`<=>e.`maxdmg` AND a.`attack_count`<=>e.`attack_count` AND BINARY a.`npcspecialattks`<=>BINARY e.`npcspecialattks` AND BINARY a.`special_abilities`<=>BINARY e.`special_abilities` AND a.`aggroradius`<=>e.`aggroradius` AND a.`assistradius`<=>e.`assistradius` AND a.`face`<=>e.`face` AND a.`luclin_hairstyle`<=>e.`luclin_hairstyle` AND a.`luclin_haircolor`<=>e.`luclin_haircolor` AND a.`luclin_eyecolor`<=>e.`luclin_eyecolor` AND a.`luclin_eyecolor2`<=>e.`luclin_eyecolor2` AND a.`luclin_beardcolor`<=>e.`luclin_beardcolor` AND a.`luclin_beard`<=>e.`luclin_beard` AND a.`drakkin_heritage`<=>e.`drakkin_heritage` AND a.`drakkin_tattoo`<=>e.`drakkin_tattoo` AND a.`drakkin_details`<=>e.`drakkin_details` AND a.`armortint_id`<=>e.`armortint_id` AND a.`armortint_red`<=>e.`armortint_red` AND a.`armortint_green`<=>e.`armortint_green` AND a.`armortint_blue`<=>e.`armortint_blue` AND a.`d_melee_texture1`<=>e.`d_melee_texture1` AND a.`d_melee_texture2`<=>e.`d_melee_texture2` AND BINARY a.`ammo_idfile`<=>BINARY e.`ammo_idfile` AND a.`prim_melee_type`<=>e.`prim_melee_type` AND a.`sec_melee_type`<=>e.`sec_melee_type` AND a.`ranged_type`<=>e.`ranged_type` AND ROUND(a.`runspeed`,5)<=>ROUND(e.`runspeed`,5) AND a.`MR`<=>e.`MR` AND a.`CR`<=>e.`CR` AND a.`DR`<=>e.`DR` AND a.`FR`<=>e.`FR` AND a.`PR`<=>e.`PR` AND a.`Corrup`<=>e.`Corrup` AND a.`PhR`<=>e.`PhR` AND a.`see_invis`<=>e.`see_invis` AND a.`see_invis_undead`<=>e.`see_invis_undead` AND a.`qglobal`<=>e.`qglobal` AND a.`AC`<=>e.`AC` AND a.`npc_aggro`<=>e.`npc_aggro` AND a.`spawn_limit`<=>e.`spawn_limit` AND a.`attack_speed`<=>e.`attack_speed` AND a.`attack_delay`<=>e.`attack_delay` AND a.`findable`<=>e.`findable` AND a.`STR`<=>e.`STR` AND a.`STA`<=>e.`STA` AND a.`DEX`<=>e.`DEX` AND a.`AGI`<=>e.`AGI` AND a.`_INT`<=>e.`_INT` AND a.`WIS`<=>e.`WIS` AND a.`CHA`<=>e.`CHA` AND a.`see_hide`<=>e.`see_hide` AND a.`see_improved_hide`<=>e.`see_improved_hide` AND a.`trackable`<=>e.`trackable` AND a.`isbot`<=>e.`isbot` AND a.`exclude`<=>e.`exclude` AND a.`ATK`<=>e.`ATK` AND a.`Accuracy`<=>e.`Accuracy` AND a.`Avoidance`<=>e.`Avoidance` AND a.`slow_mitigation`<=>e.`slow_mitigation` AND a.`version`<=>e.`version` AND a.`maxlevel`<=>e.`maxlevel` AND a.`scalerate`<=>e.`scalerate` AND a.`private_corpse`<=>e.`private_corpse` AND a.`unique_spawn_by_name`<=>e.`unique_spawn_by_name` AND a.`underwater`<=>e.`underwater` AND a.`isquest`<=>e.`isquest` AND a.`emoteid`<=>e.`emoteid` AND a.`spellscale`<=>e.`spellscale` AND a.`healscale`<=>e.`healscale` AND a.`no_target_hotkey`<=>e.`no_target_hotkey` AND a.`raid_target`<=>e.`raid_target` AND a.`armtexture`<=>e.`armtexture` AND a.`bracertexture`<=>e.`bracertexture` AND a.`handtexture`<=>e.`handtexture` AND a.`legtexture`<=>e.`legtexture` AND a.`feettexture`<=>e.`feettexture` AND a.`light`<=>e.`light` AND ROUND(a.`walkspeed`,5)<=>ROUND(e.`walkspeed`,5) AND a.`peqid`<=>e.`peqid` AND a.`unique_`<=>e.`unique_` AND a.`fixed`<=>e.`fixed` AND a.`ignore_despawn`<=>e.`ignore_despawn` AND a.`show_name`<=>e.`show_name` AND a.`untargetable`<=>e.`untargetable` AND a.`charm_ac`<=>e.`charm_ac` AND a.`charm_min_dmg`<=>e.`charm_min_dmg` AND a.`charm_max_dmg`<=>e.`charm_max_dmg` AND a.`charm_attack_delay`<=>e.`charm_attack_delay` AND a.`charm_accuracy_rating`<=>e.`charm_accuracy_rating` AND a.`charm_avoidance_rating`<=>e.`charm_avoidance_rating` AND a.`charm_atk`<=>e.`charm_atk` AND a.`skip_global_loot`<=>e.`skip_global_loot` AND a.`rare_spawn`<=>e.`rare_spawn` AND a.`stuck_behavior`<=>e.`stuck_behavior` AND a.`model`<=>e.`model` AND a.`flymode`<=>e.`flymode` AND a.`always_aggro`<=>e.`always_aggro` AND a.`exp_mod`<=>e.`exp_mod` AND a.`heroic_strikethrough`<=>e.`heroic_strikethrough` AND a.`faction_amount`<=>e.`faction_amount` AND a.`keeps_sold_items`<=>e.`keeps_sold_items` AND a.`is_parcel_merchant`<=>e.`is_parcel_merchant` AND a.`multiquest_enabled`<=>e.`multiquest_enabled` AND a.`npc_tint_id`<=>e.`npc_tint_id`)))
 AND (NOT EXISTS(SELECT 1 FROM `npc_spells` a WHERE a.id IN(399900) AND NOT EXISTS(SELECT 1 FROM `_stpd_npc_spells` e WHERE a.`id`<=>e.`id` AND BINARY a.`name`<=>BINARY e.`name` AND a.`parent_list`<=>e.`parent_list` AND a.`attack_proc`<=>e.`attack_proc` AND a.`proc_chance`<=>e.`proc_chance` AND a.`range_proc`<=>e.`range_proc` AND a.`rproc_chance`<=>e.`rproc_chance` AND a.`defensive_proc`<=>e.`defensive_proc` AND a.`dproc_chance`<=>e.`dproc_chance` AND a.`fail_recast`<=>e.`fail_recast` AND a.`engaged_no_sp_recast_min`<=>e.`engaged_no_sp_recast_min` AND a.`engaged_no_sp_recast_max`<=>e.`engaged_no_sp_recast_max` AND a.`engaged_b_self_chance`<=>e.`engaged_b_self_chance` AND a.`engaged_b_other_chance`<=>e.`engaged_b_other_chance` AND a.`engaged_d_chance`<=>e.`engaged_d_chance` AND a.`pursue_no_sp_recast_min`<=>e.`pursue_no_sp_recast_min` AND a.`pursue_no_sp_recast_max`<=>e.`pursue_no_sp_recast_max` AND a.`pursue_d_chance`<=>e.`pursue_d_chance` AND a.`idle_no_sp_recast_min`<=>e.`idle_no_sp_recast_min` AND a.`idle_no_sp_recast_max`<=>e.`idle_no_sp_recast_max` AND a.`idle_b_chance`<=>e.`idle_b_chance`)))
 AND (NOT EXISTS(SELECT 1 FROM `npc_spells_entries` a WHERE a.id IN(3999000,3999001) AND NOT EXISTS(SELECT 1 FROM `_stpd_npc_spells_entries` e WHERE a.`id`<=>e.`id` AND a.`npc_spells_id`<=>e.`npc_spells_id` AND a.`spellid`<=>e.`spellid` AND a.`type`<=>e.`type` AND a.`minlevel`<=>e.`minlevel` AND a.`maxlevel`<=>e.`maxlevel` AND a.`manacost`<=>e.`manacost` AND a.`recast_delay`<=>e.`recast_delay` AND a.`priority`<=>e.`priority` AND a.`resist_adjust`<=>e.`resist_adjust` AND a.`min_hp`<=>e.`min_hp` AND a.`max_hp`<=>e.`max_hp` AND a.`min_expansion`<=>e.`min_expansion` AND a.`max_expansion`<=>e.`max_expansion` AND a.`content_flags`<=>e.`content_flags` AND a.`content_flags_disabled`<=>e.`content_flags_disabled`)))
 AND (NOT EXISTS(SELECT 1 FROM `ground_spawns` a WHERE a.id IN(399900,399901,399902,399903,399904,399905) AND NOT EXISTS(SELECT 1 FROM `_stpd_ground_spawns` e WHERE a.`id`<=>e.`id` AND a.`zoneid`<=>e.`zoneid` AND a.`version`<=>e.`version` AND a.`max_x`<=>e.`max_x` AND a.`min_x`<=>e.`min_x` AND a.`max_y`<=>e.`max_y` AND a.`min_y`<=>e.`min_y` AND ROUND(a.`max_z`,3)<=>ROUND(e.`max_z`,3) AND a.`heading`<=>e.`heading` AND BINARY a.`name`<=>BINARY e.`name` AND a.`item`<=>e.`item` AND a.`max_allowed` IN (0,1) AND a.`respawn_timer`<=>e.`respawn_timer` AND a.`fix_z`<=>e.`fix_z` AND BINARY a.`comment`<=>BINARY e.`comment` AND a.`min_expansion`<=>e.`min_expansion` AND a.`max_expansion`<=>e.`max_expansion` AND a.`content_flags`<=>e.`content_flags` AND a.`content_flags_disabled`<=>e.`content_flags_disabled`)))
 AND (NOT EXISTS(SELECT 1 FROM npc_spells_entries WHERE npc_spells_id=399900 AND id NOT IN(3999000,3999001)))
 AND (EXISTS(SELECT 1 FROM npc_types WHERE `id`<=>399004 AND `name`<=>CONVERT(0x615f796f756e675f776173705f737069646572 USING utf8mb4) AND `race`<=>440 AND `texture`<=>2 AND `gender`<=>2 AND `size`<=>15))
 AND (EXISTS(SELECT 1 FROM npc_types WHERE `id`<=>399027 AND `name`<=>CONVERT(0x615f776173705f737069646572 USING utf8mb4) AND `race`<=>440 AND `texture`<=>2 AND `gender`<=>2 AND `size`<=>17))
 AND (EXISTS(SELECT 1 FROM npc_types WHERE `id`<=>399036 AND `name`<=>CONVERT(0x615f6d61747572655f776173705f737069646572 USING utf8mb4) AND `race`<=>440 AND `texture`<=>2 AND `gender`<=>2 AND `size`<=>19))
 AND (EXISTS(SELECT 1 FROM npc_types WHERE `id`<=>399053 AND `name`<=>CONVERT(0x615f6d6173736976655f656c656d656e74616c USING utf8mb4) AND `race`<=>209 AND `texture`<=>0 AND `gender`<=>2 AND `size`<=>15))
 AND (EXISTS(SELECT 1 FROM npc_types WHERE `id`<=>399115 AND `name`<=>CONVERT(0x615f4461726b66656c6c5f77617272696f72 USING utf8mb4) AND `race`<=>524 AND `texture`<=>0 AND `gender`<=>2 AND `size`<=>9))
 AND (EXISTS(SELECT 1 FROM npc_types WHERE `id`<=>399131 AND `name`<=>CONVERT(0x615f6275726c795f68696c6c5f6769616e74 USING utf8mb4) AND `race`<=>523 AND `texture`<=>0 AND `gender`<=>2 AND `size`<=>22))
 AND (EXISTS(SELECT 1 FROM npc_types WHERE `id`<=>399133 AND `name`<=>CONVERT(0x615f62726f776e5f62656172 USING utf8mb4) AND `race`<=>43 AND `texture`<=>0 AND `gender`<=>2 AND `size`<=>12))
 AND (EXISTS(SELECT 1 FROM npc_types WHERE `id`<=>399136 AND `name`<=>CONVERT(0x615f4461726b66656c6c5f676e6f6c6c USING utf8mb4) AND `race`<=>524 AND `texture`<=>0 AND `gender`<=>2 AND `size`<=>9))
 AND (EXISTS(SELECT 1 FROM npc_types WHERE `id`<=>399151 AND `name`<=>'' AND `race`<=>127 AND `texture`<=>0 AND `gender`<=>0 AND `size`<=>6));
INSERT INTO `_stpd_guard` VALUES(COALESCE(@steppes_defaults_ok,0));
INSERT INTO `npc_spells`(`id`,`name`,`parent_list`,`attack_proc`,`proc_chance`,`range_proc`,`rproc_chance`,`defensive_proc`,`dproc_chance`,`fail_recast`,`engaged_no_sp_recast_min`,`engaged_no_sp_recast_max`,`engaged_b_self_chance`,`engaged_b_other_chance`,`engaged_d_chance`,`pursue_no_sp_recast_min`,`pursue_no_sp_recast_max`,`pursue_d_chance`,`idle_no_sp_recast_min`,`idle_no_sp_recast_max`,`idle_b_chance`) SELECT e.`id`,e.`name`,e.`parent_list`,e.`attack_proc`,e.`proc_chance`,e.`range_proc`,e.`rproc_chance`,e.`defensive_proc`,e.`dproc_chance`,e.`fail_recast`,e.`engaged_no_sp_recast_min`,e.`engaged_no_sp_recast_max`,e.`engaged_b_self_chance`,e.`engaged_b_other_chance`,e.`engaged_d_chance`,e.`pursue_no_sp_recast_min`,e.`pursue_no_sp_recast_max`,e.`pursue_d_chance`,e.`idle_no_sp_recast_min`,e.`idle_no_sp_recast_max`,e.`idle_b_chance` FROM `_stpd_npc_spells` e WHERE @steppes_defaults_ok=1 AND NOT EXISTS(SELECT 1 FROM `npc_spells` a WHERE a.id=e.id);
INSERT INTO `npc_spells_entries`(`id`,`npc_spells_id`,`spellid`,`type`,`minlevel`,`maxlevel`,`manacost`,`recast_delay`,`priority`,`resist_adjust`,`min_hp`,`max_hp`,`min_expansion`,`max_expansion`,`content_flags`,`content_flags_disabled`) SELECT e.`id`,e.`npc_spells_id`,e.`spellid`,e.`type`,e.`minlevel`,e.`maxlevel`,e.`manacost`,e.`recast_delay`,e.`priority`,e.`resist_adjust`,e.`min_hp`,e.`max_hp`,e.`min_expansion`,e.`max_expansion`,e.`content_flags`,e.`content_flags_disabled` FROM `_stpd_npc_spells_entries` e WHERE @steppes_defaults_ok=1 AND NOT EXISTS(SELECT 1 FROM `npc_spells_entries` a WHERE a.id=e.id);
INSERT INTO `npc_types`(`id`,`name`,`lastname`,`level`,`race`,`class`,`bodytype`,`hp`,`mana`,`gender`,`texture`,`helmtexture`,`herosforgemodel`,`size`,`hp_regen_rate`,`hp_regen_per_second`,`mana_regen_rate`,`loottable_id`,`merchant_id`,`greed`,`alt_currency_id`,`npc_spells_id`,`npc_spells_effects_id`,`npc_faction_id`,`adventure_template_id`,`trap_template`,`mindmg`,`maxdmg`,`attack_count`,`npcspecialattks`,`special_abilities`,`aggroradius`,`assistradius`,`face`,`luclin_hairstyle`,`luclin_haircolor`,`luclin_eyecolor`,`luclin_eyecolor2`,`luclin_beardcolor`,`luclin_beard`,`drakkin_heritage`,`drakkin_tattoo`,`drakkin_details`,`armortint_id`,`armortint_red`,`armortint_green`,`armortint_blue`,`d_melee_texture1`,`d_melee_texture2`,`ammo_idfile`,`prim_melee_type`,`sec_melee_type`,`ranged_type`,`runspeed`,`MR`,`CR`,`DR`,`FR`,`PR`,`Corrup`,`PhR`,`see_invis`,`see_invis_undead`,`qglobal`,`AC`,`npc_aggro`,`spawn_limit`,`attack_speed`,`attack_delay`,`findable`,`STR`,`STA`,`DEX`,`AGI`,`_INT`,`WIS`,`CHA`,`see_hide`,`see_improved_hide`,`trackable`,`isbot`,`exclude`,`ATK`,`Accuracy`,`Avoidance`,`slow_mitigation`,`version`,`maxlevel`,`scalerate`,`private_corpse`,`unique_spawn_by_name`,`underwater`,`isquest`,`emoteid`,`spellscale`,`healscale`,`no_target_hotkey`,`raid_target`,`armtexture`,`bracertexture`,`handtexture`,`legtexture`,`feettexture`,`light`,`walkspeed`,`peqid`,`unique_`,`fixed`,`ignore_despawn`,`show_name`,`untargetable`,`charm_ac`,`charm_min_dmg`,`charm_max_dmg`,`charm_attack_delay`,`charm_accuracy_rating`,`charm_avoidance_rating`,`charm_atk`,`skip_global_loot`,`rare_spawn`,`stuck_behavior`,`model`,`flymode`,`always_aggro`,`exp_mod`,`heroic_strikethrough`,`faction_amount`,`keeps_sold_items`,`is_parcel_merchant`,`multiquest_enabled`,`npc_tint_id`) SELECT e.`id`,e.`name`,e.`lastname`,e.`level`,e.`race`,e.`class`,e.`bodytype`,e.`hp`,e.`mana`,e.`gender`,e.`texture`,e.`helmtexture`,e.`herosforgemodel`,e.`size`,e.`hp_regen_rate`,e.`hp_regen_per_second`,e.`mana_regen_rate`,e.`loottable_id`,e.`merchant_id`,e.`greed`,e.`alt_currency_id`,e.`npc_spells_id`,e.`npc_spells_effects_id`,e.`npc_faction_id`,e.`adventure_template_id`,e.`trap_template`,e.`mindmg`,e.`maxdmg`,e.`attack_count`,e.`npcspecialattks`,e.`special_abilities`,e.`aggroradius`,e.`assistradius`,e.`face`,e.`luclin_hairstyle`,e.`luclin_haircolor`,e.`luclin_eyecolor`,e.`luclin_eyecolor2`,e.`luclin_beardcolor`,e.`luclin_beard`,e.`drakkin_heritage`,e.`drakkin_tattoo`,e.`drakkin_details`,e.`armortint_id`,e.`armortint_red`,e.`armortint_green`,e.`armortint_blue`,e.`d_melee_texture1`,e.`d_melee_texture2`,e.`ammo_idfile`,e.`prim_melee_type`,e.`sec_melee_type`,e.`ranged_type`,e.`runspeed`,e.`MR`,e.`CR`,e.`DR`,e.`FR`,e.`PR`,e.`Corrup`,e.`PhR`,e.`see_invis`,e.`see_invis_undead`,e.`qglobal`,e.`AC`,e.`npc_aggro`,e.`spawn_limit`,e.`attack_speed`,e.`attack_delay`,e.`findable`,e.`STR`,e.`STA`,e.`DEX`,e.`AGI`,e.`_INT`,e.`WIS`,e.`CHA`,e.`see_hide`,e.`see_improved_hide`,e.`trackable`,e.`isbot`,e.`exclude`,e.`ATK`,e.`Accuracy`,e.`Avoidance`,e.`slow_mitigation`,e.`version`,e.`maxlevel`,e.`scalerate`,e.`private_corpse`,e.`unique_spawn_by_name`,e.`underwater`,e.`isquest`,e.`emoteid`,e.`spellscale`,e.`healscale`,e.`no_target_hotkey`,e.`raid_target`,e.`armtexture`,e.`bracertexture`,e.`handtexture`,e.`legtexture`,e.`feettexture`,e.`light`,e.`walkspeed`,e.`peqid`,e.`unique_`,e.`fixed`,e.`ignore_despawn`,e.`show_name`,e.`untargetable`,e.`charm_ac`,e.`charm_min_dmg`,e.`charm_max_dmg`,e.`charm_attack_delay`,e.`charm_accuracy_rating`,e.`charm_avoidance_rating`,e.`charm_atk`,e.`skip_global_loot`,e.`rare_spawn`,e.`stuck_behavior`,e.`model`,e.`flymode`,e.`always_aggro`,e.`exp_mod`,e.`heroic_strikethrough`,e.`faction_amount`,e.`keeps_sold_items`,e.`is_parcel_merchant`,e.`multiquest_enabled`,e.`npc_tint_id` FROM `_stpd_npc_types` e WHERE @steppes_defaults_ok=1 AND NOT EXISTS(SELECT 1 FROM `npc_types` a WHERE a.id=e.id);
INSERT INTO `ground_spawns`(`id`,`zoneid`,`version`,`max_x`,`min_x`,`max_y`,`min_y`,`max_z`,`heading`,`name`,`item`,`max_allowed`,`respawn_timer`,`fix_z`,`comment`,`min_expansion`,`max_expansion`,`content_flags`,`content_flags_disabled`) SELECT e.`id`,e.`zoneid`,e.`version`,e.`max_x`,e.`min_x`,e.`max_y`,e.`min_y`,e.`max_z`,e.`heading`,e.`name`,e.`item`,e.`max_allowed`,e.`respawn_timer`,e.`fix_z`,e.`comment`,e.`min_expansion`,e.`max_expansion`,e.`content_flags`,e.`content_flags_disabled` FROM `_stpd_ground_spawns` e WHERE @steppes_defaults_ok=1 AND NOT EXISTS(SELECT 1 FROM `ground_spawns` a WHERE a.id=e.id);
COMMIT;
SET @steppes_defaults_ok=NULL;
DROP TEMPORARY TABLE `_stpd_npc_types`;
DROP TEMPORARY TABLE `_stpd_npc_spells`;
DROP TEMPORARY TABLE `_stpd_npc_spells_entries`;
DROP TEMPORARY TABLE `_stpd_ground_spawns`;
DROP TEMPORARY TABLE `_stpd_guard`;

-- ---- steppes/sql/090-enable-reviewed-content.sql ----
-- Enable the complete Steppes task/encounter batch after source/schema/script review.
-- Historical unknown combat/trigger/timing values use the labelled companion defaults.
-- The adjacent portal raid is not required and is not activated.
SET SESSION check_constraint_checks=1;
DROP TEMPORARY TABLE IF EXISTS _steppes_enable_guard;
CREATE TEMPORARY TABLE _steppes_enable_guard(label VARCHAR(64) PRIMARY KEY,ok TINYINT NOT NULL CHECK(ok=1)) ENGINE=InnoDB;
INSERT INTO _steppes_enable_guard VALUES
 ('review',COALESCE(@steppes_activation_reviewed,0)=1),
 ('tasks',(SELECT COUNT(*) FROM tasks WHERE id BETWEEN 3040601 AND 3040613)=13),
 ('activities',(SELECT COUNT(*) FROM task_activities WHERE taskid BETWEEN 3040601 AND 3040613)=59),
 ('criteria',(SELECT COUNT(*) FROM achievement_criteria WHERE achievement_id IN(500060200,500060300,500060400) AND target_id BETWEEN 3040601 AND 3040613 AND event_type=4 AND progress_mode=3 AND required_count=1)=13),
 ('definitions',(SELECT COUNT(*) FROM achievements WHERE id IN(500060200,500060300,500060400))=3),
 ('clones',(SELECT COUNT(*) FROM npc_types WHERE id IN(399902,399903,399904,399905,399906,399907,399908,399909,399910,399911,399912))=11),
 ('pickups',(SELECT COUNT(*) FROM ground_spawns WHERE id BETWEEN 399900 AND 399905 AND item IN(84243,88141,88142,88137,54668,54669))=6),
 ('page_distribution',(SELECT COUNT(*) FROM ground_spawns WHERE id=399903 AND item=88137 AND ROUND(min_x,2)=963.19 AND max_x=1209 AND ROUND(min_y,2)=-544.45 AND max_y=209 AND max_z=-99999 AND fix_z=1)=1),
 ('reward_sets',(SELECT COUNT(*) FROM reward_sets WHERE reward_set_id IN(3040606,3040691,3040692,3040693))=4),
 ('reward_options',(SELECT COUNT(*) FROM reward_options WHERE reward_set_id IN(3040606,3040691,3040692,3040693))=14),
 ('reward_entries',(SELECT COUNT(*) FROM reward_option_entries WHERE reward_set_id IN(3040606,3040691,3040692,3040693))=20),
 ('yavia_health',(SELECT COUNT(*) FROM npc_types WHERE id=399032 AND hp=4200)=1),
 ('shared_state_table',(SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='character_shared_task_reward_instances' AND ENGINE='InnoDB')=1);
START TRANSACTION;
UPDATE tasks SET enabled=1 WHERE id BETWEEN 3040601 AND 3040613;
UPDATE achievement_criteria SET enabled=1 WHERE achievement_id IN(500060200,500060300,500060400) AND target_id BETWEEN 3040601 AND 3040613;
UPDATE achievements SET enabled=1 WHERE id IN(500060200,500060300,500060400);
UPDATE ground_spawns SET max_allowed=1 WHERE id BETWEEN 399900 AND 399905;
UPDATE reward_sets SET enabled=1 WHERE reward_set_id IN(3040606,3040691,3040692,3040693);
UPDATE reward_sources SET enabled=1 WHERE reward_set_id IN(3040606,3040691,3040692,3040693);
UPDATE reward_options SET enabled=1 WHERE reward_set_id IN(3040606,3040691,3040692,3040693);
UPDATE rewards SET enabled=1 WHERE reward_id IN(304060610,304060620,304060630,304060640,304069110,304069111,304069120,304069121,304069130,304069131,304069140,304069141,304069150,304069151,304069160,304069161,304069210,304069220,304069310,304069320);
COMMIT;
DROP TEMPORARY TABLE _steppes_enable_guard;

-- ---- steppes/sql/095-gnoll-late-join-policy.sql ----
-- Reviewed historical exception included after task activation.
-- Request and every initial member remain governed by tasks.min_level55.
-- Only late invite/join minimum changes to54. Below54 and initial54 are unproved.
-- Apply only after schema preflight and matched world/zone build with datetime prerequisite.
-- Explicit same-session @steppes_shared_policy_reviewed=1 required. Never use --force.
SET NAMES utf8mb4;
SET SESSION check_constraint_checks=1;
DROP TEMPORARY TABLE IF EXISTS _shared_policy_guard;
CREATE TEMPORARY TABLE _shared_policy_guard(ok TINYINT NOT NULL CHECK(ok=1))ENGINE=InnoDB;
START TRANSACTION;
SET @steppes_shared_policy_ok=COALESCE(@steppes_shared_policy_reviewed,0)=1
 AND(SELECT COUNT(*)FROM tasks WHERE id=3040606 AND type=1 AND BINARY title=BINARY'Sweeping the Steppes: Gnolls'AND min_level=55 AND max_level=0 AND repeatable=1 AND enabled=1)=1
 AND NOT EXISTS(SELECT 1 FROM shared_task_admission_policies WHERE task_id=3040606 AND NOT(late_join_min_level=54 AND enabled IN(0,1)));
INSERT INTO _shared_policy_guard VALUES(COALESCE(@steppes_shared_policy_ok,0));
INSERT INTO shared_task_admission_policies(task_id,late_join_min_level,enabled)
 SELECT 3040606,54,1 WHERE @steppes_shared_policy_ok=1
 ON DUPLICATE KEY UPDATE enabled=IF(@steppes_shared_policy_ok=1,VALUES(enabled),enabled);
COMMIT;
SET @steppes_shared_policy_ok=NULL;
DROP TEMPORARY TABLE _shared_policy_guard;
