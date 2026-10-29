-- One historically admitted Shards Partisan identity; no inferred achievement reward.
SET NAMES utf8mb4;
START TRANSACTION;
INSERT INTO `achievement_categories` (`id`,`parent_id`,`sequence`,`name`,`description`,`icon`) VALUES
(2000,0,25,'Rain of Fear','Rain of Fear','A_ROF'),
(2004,2000,4,'Quests','Quests','A_QuestsSub')
ON DUPLICATE KEY UPDATE `id`=VALUES(`id`),`parent_id`=VALUES(`parent_id`),`sequence`=VALUES(`sequence`),`name`=VALUES(`name`),`description`=VALUES(`description`),`icon`=VALUES(`icon`);
INSERT INTO `achievements` (`id`,`name`,`description`,`icon_id`,`points`,`has_reward`,`client_flag`,`version`,`reset_on_version_change`,`enabled`) VALUES
(2075225,'Partisan of Shard''s Landing','This achievement is gained upon completing the following quests in Shard''s Landing:',4671,10,1,0,0,1,1)
ON DUPLICATE KEY UPDATE `id`=VALUES(`id`),`name`=VALUES(`name`),`description`=VALUES(`description`),`icon_id`=VALUES(`icon_id`),`points`=VALUES(`points`),`has_reward`=VALUES(`has_reward`),`client_flag`=VALUES(`client_flag`),`version`=VALUES(`version`),`reset_on_version_change`=VALUES(`reset_on_version_change`),`enabled`=VALUES(`enabled`);
INSERT INTO `achievement_components` (`achievement_id`,`component_type`,`sequence`,`component_id`,`name`,`description`) VALUES
(2075225,1,1,2075225,'Overseer Drent - Welcome to Shard''s Landing',''),
(2075225,1,3,2075227,'Councilman Nostulia - Words of the Unspoken',''),
(2075225,1,5,2075229,'Engineer Eilisia - Unusual Goral Coral',''),
(2075225,1,6,2075230,'Director Idris Manaar - The Harbingers of Thule',''),
(2075225,1,7,2075231,'Director Idris Manaar - Conquering Your Fears',''),
(2075225,1,8,2075232,'Harbinger Glask - The Believers',''),
(2075225,2,2,2075226,'Overseer Drent - Exploring Shard''s Landing',''),
(2075225,2,4,2075228,'Councilman Nostulia - Unspoken Verse','')
ON DUPLICATE KEY UPDATE `achievement_id`=VALUES(`achievement_id`),`component_type`=VALUES(`component_type`),`sequence`=VALUES(`sequence`),`component_id`=VALUES(`component_id`),`name`=VALUES(`name`),`description`=VALUES(`description`);
INSERT INTO `achievement_category_associations` (`category_id`,`sequence`,`achievement_id`,`display_text`) VALUES
(2004,2,2075225,'')
ON DUPLICATE KEY UPDATE `category_id`=VALUES(`category_id`),`sequence`=VALUES(`sequence`),`achievement_id`=VALUES(`achievement_id`),`display_text`=VALUES(`display_text`);
DELETE FROM achievement_criteria WHERE achievement_id=2075225;
INSERT INTO `achievement_criteria` (`achievement_id`,`component_type`,`component_sequence`,`component_id`,`event_type`,`progress_mode`,`behavior`,`target_id`,`target_id2`,`target_value`,`required_count`,`enabled`) VALUES
(2075225,1,1,2075225,4,3,0,910000,0,0,1,1),
(2075225,1,3,2075227,4,3,0,910021,0,0,1,1),
(2075225,1,5,2075229,4,3,0,910023,0,0,1,1),
(2075225,1,6,2075230,4,3,0,910024,0,0,1,1),
(2075225,1,7,2075231,4,3,0,910025,0,0,1,1),
(2075225,1,8,2075232,4,3,0,910026,0,0,1,1),
(2075225,2,2,2075226,4,3,1,910020,0,0,1,1),
(2075225,2,4,2075228,4,3,1,910022,0,0,1,1)
ON DUPLICATE KEY UPDATE `achievement_id`=VALUES(`achievement_id`),`component_type`=VALUES(`component_type`),`component_sequence`=VALUES(`component_sequence`),`component_id`=VALUES(`component_id`),`event_type`=VALUES(`event_type`),`progress_mode`=VALUES(`progress_mode`),`behavior`=VALUES(`behavior`),`target_id`=VALUES(`target_id`),`target_id2`=VALUES(`target_id2`),`target_value`=VALUES(`target_value`),`required_count`=VALUES(`required_count`),`enabled`=VALUES(`enabled`);
COMMIT;
