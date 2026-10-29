-- Historical achievement identity and component metadata.
SET NAMES utf8mb4;
START TRANSACTION;
INSERT INTO `achievement_categories` (`id`,`parent_id`,`sequence`,`name`,`description`,`icon`) VALUES
(70,0,3,'The Hero''s Journey','The Hero''s Journey','A_HJNY'),
(71,70,1,'Progression','Progression','A_ProgressionSub')
ON DUPLICATE KEY UPDATE `id`=VALUES(`id`),`parent_id`=VALUES(`parent_id`),`sequence`=VALUES(`sequence`),`name`=VALUES(`name`),`description`=VALUES(`description`),`icon`=VALUES(`icon`);
INSERT INTO `achievements` (`id`,`name`,`description`,`icon_id`,`points`,`has_reward`,`client_flag`,`version`,`reset_on_version_change`,`enabled`) VALUES
(500020300,'Battling Blightfire (26-30)','Akins in Crescent Reach, Gubjak the Lost, and Outpost Guard Gorath in the Moors are all seeking the help of adventurers:',575,7,1,0,0,1,1)
ON DUPLICATE KEY UPDATE `id`=VALUES(`id`),`name`=VALUES(`name`),`description`=VALUES(`description`),`icon_id`=VALUES(`icon_id`),`points`=VALUES(`points`),`has_reward`=VALUES(`has_reward`),`client_flag`=VALUES(`client_flag`),`version`=VALUES(`version`),`reset_on_version_change`=VALUES(`reset_on_version_change`),`enabled`=VALUES(`enabled`);
INSERT INTO `achievement_components` (`achievement_id`,`component_type`,`sequence`,`component_id`,`name`,`description`) VALUES
(500020300,1,1,50045,'Akins - Dead Wood, The Shambling Mounds',''),
(500020300,1,2,50046,'Akins - Dead Wood, Treants',''),
(500020300,1,3,50047,'Akins - Spooky!',''),
(500020300,1,4,50048,'Akins - The Everburning',''),
(500020300,1,5,50049,'Gubjak the Lost - Summon the Spirits',''),
(500020300,1,6,50050,'Gubjak the Lost - Lay Them to Rest',''),
(500020300,1,7,50051,'Outpost Guard Gorath - The Fallen Dragon',''),
(500020300,3,0,2033,'Reach Level 25',''),
(500020300,3,0,7011,'Serpent','')
ON DUPLICATE KEY UPDATE `achievement_id`=VALUES(`achievement_id`),`component_type`=VALUES(`component_type`),`sequence`=VALUES(`sequence`),`component_id`=VALUES(`component_id`),`name`=VALUES(`name`),`description`=VALUES(`description`);
INSERT INTO `achievement_category_associations` (`category_id`,`sequence`,`achievement_id`,`display_text`) VALUES
(71,0,500020300,'')
ON DUPLICATE KEY UPDATE `category_id`=VALUES(`category_id`),`sequence`=VALUES(`sequence`),`achievement_id`=VALUES(`achievement_id`),`display_text`=VALUES(`display_text`);
COMMIT;
