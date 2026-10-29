SET NAMES utf8mb4;
START TRANSACTION;
INSERT INTO `achievement_categories`(`id`,`parent_id`,`sequence`,`name`,`description`,`icon`)VALUES
(70,0,3,'The Hero''s Journey','The Hero''s Journey','A_HJNY'),
(71,70,1,'Progression','Progression','A_ProgressionSub'),
(72,70,2,'Advancement','Advancement','A_AdvancementSub')
ON DUPLICATE KEY UPDATE `id`=VALUES(`id`),`parent_id`=VALUES(`parent_id`),`sequence`=VALUES(`sequence`),`name`=VALUES(`name`),`description`=VALUES(`description`),`icon`=VALUES(`icon`);
INSERT INTO `achievements`(`id`,`name`,`description`,`icon_id`,`points`,`has_reward`,`client_flag`,`version`,`reset_on_version_change`,`enabled`)VALUES
(500030200,'Welcome to Stone Hive (36-45)','Scout Vreshnar has a plan to hinder the expansion of Stone Hive. Speak with him about it:',605,5,1,0,0,1,1),
(500030400,'Botanical Busywork (Stone Hive 35+)','Botanist Brezuu needs someone to collect samples of plant-life from Stone Hive:',2445,3,1,0,0,1,1),
(500030500,'Cooking with Honey (Stone Hive 35+)','Cook Idriak needs someone to collect some "ingredients" from Stone Hive:',1069,4,1,0,0,1,1),
(500030600,'Working for Warwing (Stone Hive 35+)','Warwing Wendlez aims to put an end to Queen Pelzia. You may want to enlist the help of friends for these tasks:',997,4,1,0,0,1,1)
ON DUPLICATE KEY UPDATE `id`=VALUES(`id`),`name`=VALUES(`name`),`description`=VALUES(`description`),`icon_id`=VALUES(`icon_id`),`points`=VALUES(`points`),`has_reward`=VALUES(`has_reward`),`client_flag`=VALUES(`client_flag`),`version`=VALUES(`version`),`reset_on_version_change`=VALUES(`reset_on_version_change`),`enabled`=VALUES(`enabled`);
INSERT INTO `achievement_components`(`achievement_id`,`component_type`,`sequence`,`component_id`,`name`,`description`)VALUES
(500030200,1,1,50086,'Scout Vreshnar - Sticky Situation',''),
(500030200,1,2,50087,'Scout Neauza - The Saving Salve',''),
(500030200,1,3,50088,'Scout Neauza - Plans or No Plans',''),
(500030200,1,4,50089,'Scout Vreshnar - Bee Prepared for War',''),
(500030200,1,5,50090,'Scout Vreshnar - The Golden One',''),
(500030200,3,0,2043,'Reach Level 35',''),
(500030200,3,0,7011,'Serpent',''),
(500030400,1,1,50095,'Botanist Brezuu - A''mazin'' Plants',''),
(500030400,1,2,50096,'Botanist Brezuu - Curious Seeds',''),
(500030400,1,3,50097,'Botanist Brezuu - Sappy Request',''),
(500030400,3,0,2043,'Reach Level 35',''),
(500030400,3,0,7011,'Serpent',''),
(500030500,1,1,50098,'Cook Idriak - Nothing to Stew About',''),
(500030500,1,2,50099,'Cook Idriak - Touchy Feely Flan',''),
(500030500,1,3,50100,'Cook Idriak - Heads Above the Rest',''),
(500030500,1,4,50101,'Cook Idriak - Jumjum Research',''),
(500030500,3,0,2043,'Reach Level 35',''),
(500030500,3,0,7011,'Serpent',''),
(500030600,1,1,50102,'Warwing Wendlez - Who''s Who?',''),
(500030600,1,2,50103,'Warwing Wendlez - Infiltrate the Hive',''),
(500030600,1,3,50104,'Warwing Wendlez - Honey, I''m Home!',''),
(500030600,1,4,50105,'Warwing Wendlez - The Queen Bixie',''),
(500030600,3,0,2043,'Reach Level 35',''),
(500030600,3,0,7011,'Serpent','')
ON DUPLICATE KEY UPDATE `achievement_id`=VALUES(`achievement_id`),`component_type`=VALUES(`component_type`),`sequence`=VALUES(`sequence`),`component_id`=VALUES(`component_id`),`name`=VALUES(`name`),`description`=VALUES(`description`);
INSERT INTO `achievement_category_associations`(`category_id`,`sequence`,`achievement_id`,`display_text`)VALUES
(71,0,500030200,''),
(72,0,500030400,''),
(72,0,500030500,''),
(72,0,500030600,'')
ON DUPLICATE KEY UPDATE `category_id`=VALUES(`category_id`),`sequence`=VALUES(`sequence`),`achievement_id`=VALUES(`achievement_id`),`display_text`=VALUES(`display_text`);
COMMIT;
