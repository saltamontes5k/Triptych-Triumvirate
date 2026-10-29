-- Two historical catalogue identities; no invented achievement rewards.
SET NAMES utf8mb4;
START TRANSACTION;
INSERT INTO `achievement_categories` (`id`,`parent_id`,`sequence`,`name`,`description`,`icon`) VALUES
(70,0,3,'The Hero''s Journey','The Hero''s Journey','A_HJNY'),
(72,70,2,'Advancement','Advancement','A_AdvancementSub')
ON DUPLICATE KEY UPDATE `id`=VALUES(`id`),`parent_id`=VALUES(`parent_id`),`sequence`=VALUES(`sequence`),`name`=VALUES(`name`),`description`=VALUES(`description`),`icon`=VALUES(`icon`);
INSERT INTO `achievements` (`id`,`name`,`description`,`icon_id`,`points`,`has_reward`,`client_flag`,`version`,`reset_on_version_change`,`enabled`) VALUES
(500020800,'Battling the Bixies (Blightfire 30+)','The Stone Hive Bixies are becoming a sizable threat. Speak with Fletcher Orshawn, Scout Bowen and Scout Ethaniel about them:',1908,9,1,0,0,1,1),
(500020900,'Makesn''s Plight (Blightfire 30+)','The misfortune befalling Merchant Makesn is quite grave. See if you can help her out:',3677,3,1,0,0,1,1)
ON DUPLICATE KEY UPDATE `id`=VALUES(`id`),`name`=VALUES(`name`),`description`=VALUES(`description`),`icon_id`=VALUES(`icon_id`),`points`=VALUES(`points`),`has_reward`=VALUES(`has_reward`),`client_flag`=VALUES(`client_flag`),`version`=VALUES(`version`),`reset_on_version_change`=VALUES(`reset_on_version_change`),`enabled`=VALUES(`enabled`);
INSERT INTO `achievement_components` (`achievement_id`,`component_type`,`sequence`,`component_id`,`name`,`description`) VALUES
(500020800,1,1,50074,'Scout Bowen - Bixie Menace, Drone Hatchery',''),
(500020800,1,2,50075,'Scout Bowen - Bixie Menace, Jum Jum Fields',''),
(500020800,1,3,50076,'Scout Bowen - Bixie Menace, The Silo',''),
(500020800,1,4,50077,'Scout Ethaniel - The Bixie Threat?',''),
(500020800,1,5,50078,'Scout Ethaniel - Bixie Jumjum',''),
(500020800,1,6,50079,'Scout Ethaniel - Bixie Plans',''),
(500020800,1,7,50080,'Scout Ethaniel - Bixie Thralls',''),
(500020800,1,8,50081,'Fletcher Orshawn - Stonehive Venom Stingers',''),
(500020800,1,9,50082,'Fletcher Orshawn - Buzzazar',''),
(500020800,3,0,2038,'Reach Level 30',''),
(500020800,3,0,7011,'Serpent',''),
(500020900,1,1,50083,'Merchant Makesn - A Widow''s Last Memory',''),
(500020900,1,2,50084,'Merchant Makesn - A Taste for Honey',''),
(500020900,1,3,50085,'Merchant Makesn - She Haunts My Dreams',''),
(500020900,3,0,2038,'Reach Level 30',''),
(500020900,3,0,7011,'Serpent','')
ON DUPLICATE KEY UPDATE `achievement_id`=VALUES(`achievement_id`),`component_type`=VALUES(`component_type`),`sequence`=VALUES(`sequence`),`component_id`=VALUES(`component_id`),`name`=VALUES(`name`),`description`=VALUES(`description`);
INSERT INTO `achievement_category_associations` (`category_id`,`sequence`,`achievement_id`,`display_text`) VALUES
(72,0,500020800,''),
(72,0,500020900,'')
ON DUPLICATE KEY UPDATE `category_id`=VALUES(`category_id`),`sequence`=VALUES(`sequence`),`achievement_id`=VALUES(`achievement_id`),`display_text`=VALUES(`display_text`);
COMMIT;
