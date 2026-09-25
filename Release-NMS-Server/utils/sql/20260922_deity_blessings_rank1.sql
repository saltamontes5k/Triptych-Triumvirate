-- ============================================================================
-- Deity Blessings -- Rank 1: "Bring a Fired Idol"
-- Date: 2026-09-22
--
-- Adds the crafting chain + rank-1 delivery quests for the 16 deity trees
-- (incl. Veeshan) plus the Agnostic ("Unaligned") tree.
--
--   * Imbue Jacinth spell + Imbued Jacinth (tradable) + scroll
--   * Unfired/Golden Idol of Veeshan
--   * Unfired/Fired Idol of the Unaligned (agnostic)
--   * 17 one-shot rank-1 tasks (700001-700017), each a single Deliver activity
--   * 2 blessing NPCs spawned in The Bazaar (151) and Plane of Tranquility (203)
--
-- Idempotent: deletes the ids it owns before inserting.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- Cleanup (safe: these ids are dedicated to this system)
-- ---------------------------------------------------------------------------
DELETE FROM `tradeskill_recipe_entries` WHERE `recipe_id` IN (992007,992008,992009,992010);
DELETE FROM `tradeskill_recipe`         WHERE `id`        IN (992007,992008,992009,992010);
DELETE FROM `merchantlist`              WHERE `merchantid`= 202223 AND `item`=9910019;
DELETE FROM `task_activities`           WHERE `taskid` BETWEEN 700001 AND 700017;
DELETE FROM `tasks`                     WHERE `id` BETWEEN 700001 AND 700017;
DELETE FROM `spawn2`                    WHERE `id` IN (3390100,3390101);
DELETE FROM `spawnentry`                WHERE `spawngroupID` IN (5004100,5004101);
DELETE FROM `spawngroup`                WHERE `id` IN (5004100,5004101);
DELETE FROM `npc_types`                 WHERE `id` IN (344200,344201);
DELETE FROM `items`                     WHERE `id` IN (9910018,9910019,9910020,9910021,9910022,9910023);
DELETE FROM `spells_new`                WHERE `id`=50017;

-- ===========================================================================
-- Phase A -- Veeshan gem chain
-- ===========================================================================

-- Imbued Jacinth (tradable) -- clone of Imbued Diamond (22549)
DROP TEMPORARY TABLE IF EXISTS `tmp_item`;
CREATE TEMPORARY TABLE `tmp_item` AS SELECT * FROM `items` WHERE `id`=22549;
UPDATE `tmp_item` SET
    `id`=9910018,
    `Name`='Imbued Jacinth',
    `lore`='Imbued Jacinth-Veeshan',
    `loregroup`=0,
    `icon`=767,
    `price`=200000,
    `nodrop`=0,
    `magic`=0,
    `itemtype`=17,
    `minstatus`=0
WHERE `id`=22549;
INSERT INTO `items` SELECT * FROM `tmp_item`;
DROP TEMPORARY TABLE `tmp_item`;

-- Spell: Imbue Jacinth scroll -- clone of Spell: Imbue Diamond (15895)
DROP TEMPORARY TABLE IF EXISTS `tmp_item`;
CREATE TEMPORARY TABLE `tmp_item` AS SELECT * FROM `items` WHERE `id`=15895;
UPDATE `tmp_item` SET
    `id`=9910019,
    `Name`='Spell: Imbue Jacinth',
    `lore`='Spell: Imbue Jacinth',
    `loregroup`=0,
    `price`=2933,
    `scrolltype`=0,
    `scrolleffect`=50017,
    `itemtype`=20,
    `minstatus`=0
WHERE `id`=15895;
INSERT INTO `items` SELECT * FROM `tmp_item`;
DROP TEMPORARY TABLE `tmp_item`;

-- Imbue Jacinth -- clone of Imbue Emerald (1888), deity-locked to Veeshan (index 16)
DROP TEMPORARY TABLE IF EXISTS `tmp_spell`;
CREATE TEMPORARY TABLE `tmp_spell` AS SELECT * FROM `spells_new` WHERE `id`=1888;
UPDATE `tmp_spell` SET
    `id`=50017,
    `name`='Imbue Jacinth',
    `effect_base_value1`=9910018,
    `components1`=10053,
    `classes1`=255,
    `classes2`=29,
    `classes3`=255,
    `classes4`=255,
    `classes5`=255,
    `classes6`=29,
    `classes7`=255,
    `classes8`=255,
    `classes9`=255,
    `classes10`=255,
    `classes11`=255,
    `classes12`=255,
    `classes13`=255,
    `classes14`=255,
    `classes15`=255,
    `classes16`=255,
    `deities0`=0,`deities1`=0,`deities2`=0,`deities3`=0,`deities4`=0,
    `deities5`=0,`deities6`=0,`deities7`=0,`deities8`=0,`deities9`=0,
    `deities10`=0,`deities11`=0,`deities12`=0,`deities13`=0,`deities14`=0,
    `deities15`=0,`deities16`=-1
WHERE `id`=1888;
INSERT INTO `spells_new` SELECT * FROM `tmp_spell`;
DROP TEMPORARY TABLE `tmp_spell`;

-- Sell the scroll at the Bazaar cleric spell vendor (Vicar merchant 202223)
INSERT INTO `merchantlist` (`merchantid`,`slot`,`item`) VALUES (202223,93,9910019);

-- ===========================================================================
-- Phase B -- Veeshan idol chain
-- ===========================================================================

-- Unfired Idol of Veeshan -- clone of Unfired Idol of Bertoxxulous (9691)
DROP TEMPORARY TABLE IF EXISTS `tmp_item`;
CREATE TEMPORARY TABLE `tmp_item` AS SELECT * FROM `items` WHERE `id`=9691;
UPDATE `tmp_item` SET
    `id`=9910020,
    `Name`='Unfired Idol of Veeshan',
    `lore`='Unfired Idol of Veeshan',
    `loregroup`=0,
    `minstatus`=0
WHERE `id`=9691;
INSERT INTO `items` SELECT * FROM `tmp_item`;
DROP TEMPORARY TABLE `tmp_item`;

-- Golden Idol of Veeshan -- clone of Golden Idol of Prexus (9714)
DROP TEMPORARY TABLE IF EXISTS `tmp_item`;
CREATE TEMPORARY TABLE `tmp_item` AS SELECT * FROM `items` WHERE `id`=9714;
UPDATE `tmp_item` SET
    `id`=9910021,
    `Name`='Golden Idol of Veeshan',
    `lore`='Golden Idol of Veeshan',
    `loregroup`=0,
    `ac`=4,
    `minstatus`=0
WHERE `id`=9714;
INSERT INTO `items` SELECT * FROM `tmp_item`;
DROP TEMPORARY TABLE `tmp_item`;

INSERT INTO `tradeskill_recipe`
    (`id`,`name`,`tradeskill`,`skillneeded`,`trivial`,`nofail`,`replace_container`,`must_learn`,`learned_by_item_id`,`quest`,`enabled`,`min_expansion`,`max_expansion`)
VALUES
    (992007,'Unfired Idol Of Veeshan',69,0,335,0,0,0,0,0,1,-1,-1),
    (992008,'Golden Idol Of Veeshan',69,0,15,0,0,0,0,0,1,-1,-1),
    (992009,'Unfired Idol Of The Unaligned',69,0,38,0,0,0,0,0,1,-1,-1),
    (992010,'Fired Idol Of The Unaligned',69,0,40,0,0,0,0,0,1,-1,-1);

INSERT INTO `tradeskill_recipe_entries`
    (`recipe_id`,`item_id`,`successcount`,`failcount`,`componentcount`,`salvagecount`,`iscontainer`)
VALUES
    -- Unfired Idol Of Veeshan
    (992007,21625,1,0,1,0,0),
    (992007,9650, 0,0,1,0,0),
    (992007,10253,0,0,1,0,0),
    (992007,13006,0,0,1,0,0),
    (992007,16502,0,0,1,0,0),
    (992007,16895,0,0,1,0,0),
    (992007,16896,0,0,1,0,0),
    (992007,9910018,0,0,1,0,0),
    (992007,9910020,1,0,0,0,0),
    -- Golden Idol Of Veeshan
    (992008,9910020,0,0,1,0,0),
    (992008,16578,0,0,1,0,0),
    (992008,16908,0,0,1,0,0),
    (992008,9910021,1,0,0,0,0),
    -- Unfired Idol Of The Unaligned
    (992009,21625,1,0,1,0,0),
    (992009,9650, 0,0,1,0,0),
    (992009,16502,0,0,1,0,0),
    (992009,16895,0,0,1,0,0),
    (992009,10053,0,0,1,0,0),
    (992009,16896,0,0,1,0,0),
    (992009,10253,0,0,1,0,0),
    (992009,13006,0,0,1,0,0),
    (992009,9910022,1,0,0,0,0),
    -- Fired Idol Of The Unaligned
    (992010,9910022,0,0,1,0,0),
    (992010,16578,0,0,1,0,0),
    (992010,16908,0,0,1,0,0),
    (992010,9910023,1,0,0,0,0),
    -- container markers (required for the client recipe list; 21 = pottery wheel, 22 = kiln)
    (992007,21,0,0,0,0,1),
    (992008,22,0,0,0,0,1),
    (992009,21,0,0,0,0,1),
    (992010,22,0,0,0,0,1);

-- ===========================================================================
-- Phase C -- Agnostic ("Unaligned") idol chain
-- ===========================================================================

-- Unfired Idol of the Unaligned -- clone of generic Unfired Idol (21610)
DROP TEMPORARY TABLE IF EXISTS `tmp_item`;
CREATE TEMPORARY TABLE `tmp_item` AS SELECT * FROM `items` WHERE `id`=21610;
UPDATE `tmp_item` SET
    `id`=9910022,
    `Name`='Unfired Idol of the Unaligned',
    `lore`='Unfired Idol of the Unaligned',
    `loregroup`=0,
    `minstatus`=0
WHERE `id`=21610;
INSERT INTO `items` SELECT * FROM `tmp_item`;
DROP TEMPORARY TABLE `tmp_item`;

-- Fired Idol of the Unaligned -- clone of Golden Idol of Prexus (9714)
DROP TEMPORARY TABLE IF EXISTS `tmp_item`;
CREATE TEMPORARY TABLE `tmp_item` AS SELECT * FROM `items` WHERE `id`=9714;
UPDATE `tmp_item` SET
    `id`=9910023,
    `Name`='Fired Idol of the Unaligned',
    `lore`='Fired Idol of the Unaligned',
    `loregroup`=0,
    `ac`=4,
    `minstatus`=0
WHERE `id`=9714;
INSERT INTO `items` SELECT * FROM `tmp_item`;
DROP TEMPORARY TABLE `tmp_item`;

-- ===========================================================================
-- Phase D -- 2 blessing NPCs (The Bazaar 151, Plane of Tranquility 203)
-- ===========================================================================
INSERT INTO `npc_types`
    (`id`,`Name`,`lastname`,`level`,`race`,`class`,`bodytype`,`hp`,`mana`,`gender`,`texture`,`helmtexture`,`size`,`runspeed`,`merchant_id`,`npc_spells_id`)
VALUES
    (344200,'Blessing_of_the_Gods','Keeper of Devotion',70,6,1,1,32000,0,2,0,0,5,1.25,0,0),
    (344201,'Blessing_of_the_Gods','Keeper of Devotion',70,6,1,1,32000,0,2,0,0,5,1.25,0,0);

INSERT INTO `spawngroup` (`id`,`name`) VALUES
    (5004100,'blessing_of_the_gods_bazaar'),
    (5004101,'blessing_of_the_gods_potranquility');

INSERT INTO `spawnentry` (`spawngroupID`,`npcID`,`chance`) VALUES
    (5004100,344200,100),
    (5004101,344201,100);

INSERT INTO `spawn2`
    (`id`,`spawngroupID`,`zone`,`x`,`y`,`z`,`heading`,`respawntime`,`variance`)
VALUES
    (3390100,5004100,'bazaar',        -91,96,-16,0,7200,0),
    (3390101,5004101,'potranquility', -1480,590,-876,253,7200,0);

-- ===========================================================================
-- Phase E -- Rank-1 tasks (one per tree) + Deliver activities
-- ===========================================================================
INSERT INTO `tasks`
    (`id`,`type`,`duration`,`duration_code`,`title`,`description`,`reward_text`,
     `cash_reward`,`exp_reward`,`reward_method`,`reward_points`,`reward_point_type`,
     `min_level`,`max_level`,`level_spread`,`min_players`,`max_players`,`repeatable`,
     `faction_reward`,`completion_emote`,`replay_timer_group`,`replay_timer_seconds`,
     `request_timer_group`,`request_timer_seconds`,`dz_template_id`,`lock_activity_id`,
     `faction_amount`,`enabled`)
VALUES
    (700001,2,0,0,'Devotion to Bertoxxulous','Deliver a forged idol of Bertoxxulous to the Keeper of Devotion.','',0,0,0,0,0,1,125,0,1,1,0,0,'',0,0,0,0,0,-1,0,1),
    (700002,2,0,0,'Devotion to Brell Serilis','Deliver a forged idol of Brell Serilis to the Keeper of Devotion.','',0,0,0,0,0,1,125,0,1,1,0,0,'',0,0,0,0,0,-1,0,1),
    (700003,2,0,0,'Devotion to Cazic-Thule','Deliver a forged idol of Cazic-Thule to the Keeper of Devotion.','',0,0,0,0,0,1,125,0,1,1,0,0,'',0,0,0,0,0,-1,0,1),
    (700004,2,0,0,'Devotion to Erollisi Marr','Deliver a forged idol of Erollisi Marr to the Keeper of Devotion.','',0,0,0,0,0,1,125,0,1,1,0,0,'',0,0,0,0,0,-1,0,1),
    (700005,2,0,0,'Devotion to Bristlebane','Deliver a forged idol of Bristlebane to the Keeper of Devotion.','',0,0,0,0,0,1,125,0,1,1,0,0,'',0,0,0,0,0,-1,0,1),
    (700006,2,0,0,'Devotion to Innoruuk','Deliver a forged idol of Innoruuk to the Keeper of Devotion.','',0,0,0,0,0,1,125,0,1,1,0,0,'',0,0,0,0,0,-1,0,1),
    (700007,2,0,0,'Devotion to Karana','Deliver a forged idol of Karana to the Keeper of Devotion.','',0,0,0,0,0,1,125,0,1,1,0,0,'',0,0,0,0,0,-1,0,1),
    (700008,2,0,0,'Devotion to Mithaniel Marr','Deliver a forged idol of Mithaniel Marr to the Keeper of Devotion.','',0,0,0,0,0,1,125,0,1,1,0,0,'',0,0,0,0,0,-1,0,1),
    (700009,2,0,0,'Devotion to Prexus','Deliver a forged idol of Prexus to the Keeper of Devotion.','',0,0,0,0,0,1,125,0,1,1,0,0,'',0,0,0,0,0,-1,0,1),
    (700010,2,0,0,'Devotion to Quellious','Deliver a forged idol of Quellious to the Keeper of Devotion.','',0,0,0,0,0,1,125,0,1,1,0,0,'',0,0,0,0,0,-1,0,1),
    (700011,2,0,0,'Devotion to Rallos Zek','Deliver a forged idol of Rallos Zek to the Keeper of Devotion.','',0,0,0,0,0,1,125,0,1,1,0,0,'',0,0,0,0,0,-1,0,1),
    (700012,2,0,0,'Devotion to Rodcet Nife','Deliver a forged idol of Rodcet Nife to the Keeper of Devotion.','',0,0,0,0,0,1,125,0,1,1,0,0,'',0,0,0,0,0,-1,0,1),
    (700013,2,0,0,'Devotion to Solusek Ro','Deliver a forged idol of Solusek Ro to the Keeper of Devotion.','',0,0,0,0,0,1,125,0,1,1,0,0,'',0,0,0,0,0,-1,0,1),
    (700014,2,0,0,'Devotion to the Tribunal','Deliver a forged idol of the Tribunal to the Keeper of Devotion.','',0,0,0,0,0,1,125,0,1,1,0,0,'',0,0,0,0,0,-1,0,1),
    (700015,2,0,0,'Devotion to Tunare','Deliver a forged idol of Tunare to the Keeper of Devotion.','',0,0,0,0,0,1,125,0,1,1,0,0,'',0,0,0,0,0,-1,0,1),
    (700016,2,0,0,'Devotion to Veeshan','Deliver a forged idol of Veeshan to the Keeper of Devotion.','',0,0,0,0,0,1,125,0,1,1,0,0,'',0,0,0,0,0,-1,0,1),
    (700017,2,0,0,'Devotion of the Unaligned','Deliver a forged idol of the Unaligned to the Keeper of Devotion.','',0,0,0,0,0,1,125,0,1,1,0,0,'',0,0,0,0,0,-1,0,1);

INSERT INTO `task_activities`
    (`taskid`,`activityid`,`req_activity_id`,`step`,`activitytype`,`target_name`,`goalmethod`,
     `goalcount`,`description_override`,`npc_match_list`,`item_id_list`,`item_list`,`dz_switch_id`,
     `min_x`,`min_y`,`min_z`,`max_x`,`max_y`,`max_z`,`skill_list`,`spell_list`,`zones`,
     `zone_version`,`optional`,`list_group`)
VALUES
    (700001,0,-1,1,1,'Keeper of Devotion',0,1,'Deliver a forged idol of Bertoxxulous to the Keeper of Devotion.','344200|344201','9706','',0,0,0,0,0,0,0,-1,0,'151;203',-1,0,0),
    (700002,0,-1,1,1,'Keeper of Devotion',0,1,'Deliver a forged idol of Brell Serilis to the Keeper of Devotion.','344200|344201','9707','',0,0,0,0,0,0,0,-1,0,'151;203',-1,0,0),
    (700003,0,-1,1,1,'Keeper of Devotion',0,1,'Deliver a forged idol of Cazic-Thule to the Keeper of Devotion.','344200|344201','9708','',0,0,0,0,0,0,0,-1,0,'151;203',-1,0,0),
    (700004,0,-1,1,1,'Keeper of Devotion',0,1,'Deliver a forged idol of Erollisi Marr to the Keeper of Devotion.','344200|344201','9709','',0,0,0,0,0,0,0,-1,0,'151;203',-1,0,0),
    (700005,0,-1,1,1,'Keeper of Devotion',0,1,'Deliver a forged idol of Bristlebane to the Keeper of Devotion.','344200|344201','9710','',0,0,0,0,0,0,0,-1,0,'151;203',-1,0,0),
    (700006,0,-1,1,1,'Keeper of Devotion',0,1,'Deliver a forged idol of Innoruuk to the Keeper of Devotion.','344200|344201','9711','',0,0,0,0,0,0,0,-1,0,'151;203',-1,0,0),
    (700007,0,-1,1,1,'Keeper of Devotion',0,1,'Deliver a forged idol of Karana to the Keeper of Devotion.','344200|344201','9712','',0,0,0,0,0,0,0,-1,0,'151;203',-1,0,0),
    (700008,0,-1,1,1,'Keeper of Devotion',0,1,'Deliver a forged idol of Mithaniel Marr to the Keeper of Devotion.','344200|344201','9713','',0,0,0,0,0,0,0,-1,0,'151;203',-1,0,0),
    (700009,0,-1,1,1,'Keeper of Devotion',0,1,'Deliver a forged idol of Prexus to the Keeper of Devotion.','344200|344201','9714','',0,0,0,0,0,0,0,-1,0,'151;203',-1,0,0),
    (700010,0,-1,1,1,'Keeper of Devotion',0,1,'Deliver a forged idol of Quellious to the Keeper of Devotion.','344200|344201','9715','',0,0,0,0,0,0,0,-1,0,'151;203',-1,0,0),
    (700011,0,-1,1,1,'Keeper of Devotion',0,1,'Deliver a forged idol of Rallos Zek to the Keeper of Devotion.','344200|344201','9716','',0,0,0,0,0,0,0,-1,0,'151;203',-1,0,0),
    (700012,0,-1,1,1,'Keeper of Devotion',0,1,'Deliver a forged idol of Rodcet Nife to the Keeper of Devotion.','344200|344201','9717','',0,0,0,0,0,0,0,-1,0,'151;203',-1,0,0),
    (700013,0,-1,1,1,'Keeper of Devotion',0,1,'Deliver a forged idol of Solusek Ro to the Keeper of Devotion.','344200|344201','9718','',0,0,0,0,0,0,0,-1,0,'151;203',-1,0,0),
    (700014,0,-1,1,1,'Keeper of Devotion',0,1,'Deliver a forged idol of the Tribunal to the Keeper of Devotion.','344200|344201','9719','',0,0,0,0,0,0,0,-1,0,'151;203',-1,0,0),
    (700015,0,-1,1,1,'Keeper of Devotion',0,1,'Deliver a forged idol of Tunare to the Keeper of Devotion.','344200|344201','9720','',0,0,0,0,0,0,0,-1,0,'151;203',-1,0,0),
    (700016,0,-1,1,1,'Keeper of Devotion',0,1,'Deliver a forged idol of Veeshan to the Keeper of Devotion.','344200|344201','9910021','',0,0,0,0,0,0,0,-1,0,'151;203',-1,0,0),
    (700017,0,-1,1,1,'Keeper of Devotion',0,1,'Deliver a forged idol of the Unaligned to the Keeper of Devotion.','344200|344201','9910023','',0,0,0,0,0,0,0,-1,0,'151;203',-1,0,0);
