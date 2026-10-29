SET NAMES utf8mb4;
START TRANSACTION;
INSERT INTO `achievement_categories` (`id`,`parent_id`,`sequence`,`name`,`description`,`icon`) VALUES
(70,0,3,'The Hero''s Journey','The Hero''s Journey','A_HJNY'),
(71,70,1,'Progression','Progression','A_ProgressionSub')
ON DUPLICATE KEY UPDATE `id`=VALUES(`id`),`parent_id`=VALUES(`parent_id`),`sequence`=VALUES(`sequence`),`name`=VALUES(`name`),`description`=VALUES(`description`),`icon`=VALUES(`icon`);
INSERT INTO `achievements` (`id`,`name`,`description`,`icon_id`,`points`,`has_reward`,`client_flag`,`version`,`reset_on_version_change`,`enabled`) VALUES
(500020200,'Welcome to the Moors (21-25)','Alchemist Ella, Hammerstock, Ordunn the Miner and Ozzana the Trapper are in need of assistance:',575,8,1,0,0,1,1)
ON DUPLICATE KEY UPDATE `id`=VALUES(`id`),`name`=VALUES(`name`),`description`=VALUES(`description`),`icon_id`=VALUES(`icon_id`),`points`=VALUES(`points`),`has_reward`=VALUES(`has_reward`),`client_flag`=VALUES(`client_flag`),`version`=VALUES(`version`),`reset_on_version_change`=VALUES(`reset_on_version_change`),`enabled`=VALUES(`enabled`);
INSERT INTO `achievement_components` (`achievement_id`,`component_type`,`sequence`,`component_id`,`name`,`description`) VALUES
(500020200,1,1,50037,'Ordunn the Miner - The Golden Pick I',''),
(500020200,1,2,50038,'Ordunn the Miner - The Golden Pick II',''),
(500020200,1,3,50039,'Ordunn the Miner - The Golden Pick III',''),
(500020200,1,4,50040,'Ozzana the Trapper - The Darkwater Pools',''),
(500020200,1,5,50041,'Ozzana the Trapper - The Slashclaw Cliffs',''),
(500020200,1,6,50042,'Ozzana the Trapper - The Ghostpack Fens',''),
(500020200,1,7,50043,'Hammerstock - The Ticking Crocodile',''),
(500020200,1,8,50044,'Alchemist Ella - Witchlamps',''),
(500020200,3,0,2028,'Reach Level 20',''),
(500020200,3,0,7011,'Serpent','')
ON DUPLICATE KEY UPDATE `achievement_id`=VALUES(`achievement_id`),`component_type`=VALUES(`component_type`),`sequence`=VALUES(`sequence`),`component_id`=VALUES(`component_id`),`name`=VALUES(`name`),`description`=VALUES(`description`);
INSERT INTO `achievement_category_associations` (`category_id`,`sequence`,`achievement_id`,`display_text`) VALUES
(71,0,500020200,'')
ON DUPLICATE KEY UPDATE `category_id`=VALUES(`category_id`),`sequence`=VALUES(`sequence`),`achievement_id`=VALUES(`achievement_id`),`display_text`=VALUES(`display_text`);
COMMIT;
