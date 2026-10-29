SET NAMES utf8mb4;
START TRANSACTION;
INSERT INTO `achievement_categories`(`id`,`parent_id`,`sequence`,`name`,`description`,`icon`)VALUES
(70,0,3,'The Hero''s Journey','The Hero''s Journey','A_HJNY'),
(71,70,1,'Progression','Progression','A_ProgressionSub')
ON DUPLICATE KEY UPDATE `id`=VALUES(`id`),`parent_id`=VALUES(`parent_id`),`sequence`=VALUES(`sequence`),`name`=VALUES(`name`),`description`=VALUES(`description`),`icon`=VALUES(`icon`);
INSERT INTO `achievements`(`id`,`name`,`description`,`icon_id`,`points`,`has_reward`,`client_flag`,`version`,`reset_on_version_change`,`enabled`)VALUES
(500020400,'Champion of the Moors (31-35)','Arch Druid Springthorn, Historian Pewdri, Shaytherrin the Exorcist, Tailor Ulen and Zan the Witch Hunter have a number of jobs for you:',575,8,1,0,0,1,1)
ON DUPLICATE KEY UPDATE `id`=VALUES(`id`),`name`=VALUES(`name`),`description`=VALUES(`description`),`icon_id`=VALUES(`icon_id`),`points`=VALUES(`points`),`has_reward`=VALUES(`has_reward`),`client_flag`=VALUES(`client_flag`),`version`=VALUES(`version`),`reset_on_version_change`=VALUES(`reset_on_version_change`),`enabled`=VALUES(`enabled`);
INSERT INTO `achievement_components`(`achievement_id`,`component_type`,`sequence`,`component_id`,`name`,`description`)VALUES
(500020400,1,1,50052,'Historian Pewdri - Pieces of the Past',''),
(500020400,1,2,50053,'Historian Pewdri - Historian Pewdri''s Task',''),
(500020400,1,3,50054,'Tailor Ulen - Feather for Your Cap',''),
(500020400,1,4,50055,'Shaytherrin the Exorcist - The Dark Tower, Flickering Torches',''),
(500020400,1,5,50056,'Shaytherrin the Exorcist - The Dark Tower, Fallen Guard',''),
(500020400,1,6,50057,'Shaytherrin the Exorcist - The Dark Tower: Lord of the Tower',''),
(500020400,1,7,50058,'Zan the Witch Hunter - The Blightfire Witches',''),
(500020400,1,8,50059,'Arch Druid Springthorn - Return of the Moorwalkers',''),
(500020400,3,0,2038,'Reach Level 30',''),
(500020400,3,0,7011,'Serpent','')
ON DUPLICATE KEY UPDATE `achievement_id`=VALUES(`achievement_id`),`component_type`=VALUES(`component_type`),`sequence`=VALUES(`sequence`),`component_id`=VALUES(`component_id`),`name`=VALUES(`name`),`description`=VALUES(`description`);
INSERT INTO `achievement_category_associations`(`category_id`,`sequence`,`achievement_id`,`display_text`)VALUES
(71,0,500020400,'')
ON DUPLICATE KEY UPDATE `category_id`=VALUES(`category_id`),`sequence`=VALUES(`sequence`),`achievement_id`=VALUES(`achievement_id`),`display_text`=VALUES(`display_text`);
COMMIT;
