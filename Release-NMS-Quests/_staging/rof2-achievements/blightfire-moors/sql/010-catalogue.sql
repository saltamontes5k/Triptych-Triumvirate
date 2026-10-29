-- Three historically admitted Blightfire identities; no inferred achievement rewards.
SET NAMES utf8mb4;
START TRANSACTION;
INSERT INTO `achievement_categories` (`id`,`parent_id`,`sequence`,`name`,`description`,`icon`) VALUES
(70,0,3,'The Hero''s Journey','The Hero''s Journey','A_HJNY'),
(72,70,2,'Advancement','Advancement','A_AdvancementSub')
ON DUPLICATE KEY UPDATE `id`=VALUES(`id`),`parent_id`=VALUES(`parent_id`),`sequence`=VALUES(`sequence`),`name`=VALUES(`name`),`description`=VALUES(`description`),`icon`=VALUES(`icon`);
INSERT INTO `achievements` (`id`,`name`,`description`,`icon_id`,`points`,`has_reward`,`client_flag`,`version`,`reset_on_version_change`,`enabled`) VALUES
(500020500,'Job Offers (Blightfire 20+)','Just outside of Crescent Reach a number of job offers are posted on the Moors Sign Post:',683,4,1,0,0,1,1),
(500020600,'Two Gnolls With One Stone (Blightfire 20+)','The Mucktail Gnolls are becoming a threat. Speak with Scout Zerak and Smithy Bronson about them:',1910,4,1,0,0,1,1),
(500020700,'Stemming the Threat (Blightfire 20+)','The plantlife of Blightfire is of particular interest to Farmer D`Resh, Fletcher Orshawn, Roanoak and Smithy Bronson:',2212,6,1,0,0,1,1)
ON DUPLICATE KEY UPDATE `id`=VALUES(`id`),`name`=VALUES(`name`),`description`=VALUES(`description`),`icon_id`=VALUES(`icon_id`),`points`=VALUES(`points`),`has_reward`=VALUES(`has_reward`),`client_flag`=VALUES(`client_flag`),`version`=VALUES(`version`),`reset_on_version_change`=VALUES(`reset_on_version_change`),`enabled`=VALUES(`enabled`);
INSERT INTO `achievement_components` (`achievement_id`,`component_type`,`sequence`,`component_id`,`name`,`description`) VALUES
(500020500,1,1,50060,'Moors Sign Post - Lost Memento',''),
(500020500,1,2,50061,'Moors Sign Post - Experienced Hunters Needed',''),
(500020500,1,3,50062,'Moors Sign Post - Wanted: Intrepid Explorer',''),
(500020500,1,4,50063,'Moors Sign Post - Wanted: Supply Runner',''),
(500020500,3,0,2028,'Reach Level 20',''),
(500020500,3,0,7011,'Serpent',''),
(500020600,1,1,50064,'Smithy Bronson - Ore for Smelting',''),
(500020600,1,2,50065,'Smithy Bronson - Gnollish Tools',''),
(500020600,1,3,50066,'Scout Zerak - The Mucktail Quarry',''),
(500020600,1,4,50067,'Scout Zerak - The Mucktail Mines',''),
(500020600,3,0,2028,'Reach Level 20',''),
(500020600,3,0,7011,'Serpent',''),
(500020700,1,1,50068,'Roanoak - Rotwood, The Infected Treants',''),
(500020700,1,2,50069,'Roanoak - Rotwood, The Spore Farms',''),
(500020700,1,3,50070,'Roanoak - Rotwood: Molderahn',''),
(500020700,1,4,50071,'Farmer D`Resh - Hardy Seeds',''),
(500020700,1,5,50072,'Smithy Bronson - Kindling for the Fires',''),
(500020700,1,6,50073,'Fletcher Orshawn - Green Ooze Buds',''),
(500020700,3,0,2028,'Reach Level 20',''),
(500020700,3,0,7011,'Serpent','')
ON DUPLICATE KEY UPDATE `achievement_id`=VALUES(`achievement_id`),`component_type`=VALUES(`component_type`),`sequence`=VALUES(`sequence`),`component_id`=VALUES(`component_id`),`name`=VALUES(`name`),`description`=VALUES(`description`);
INSERT INTO `achievement_category_associations` (`category_id`,`sequence`,`achievement_id`,`display_text`) VALUES
(72,0,500020500,''),
(72,0,500020600,''),
(72,0,500020700,'')
ON DUPLICATE KEY UPDATE `category_id`=VALUES(`category_id`),`sequence`=VALUES(`sequence`),`achievement_id`=VALUES(`achievement_id`),`display_text`=VALUES(`display_text`);
COMMIT;
