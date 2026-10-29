-- Champion of the Moors task content; see provenance/native-status.json.
SET NAMES utf8mb4;
SET SESSION check_constraint_checks=1;
DROP TEMPORARY TABLE IF EXISTS _champion_guard;
CREATE TEMPORARY TABLE _champion_guard(label VARCHAR(80)PRIMARY KEY,ok TINYINT NOT NULL,CHECK(ok=1))ENGINE=InnoDB;
INSERT INTO _champion_guard VALUES('task_names',(NOT EXISTS(SELECT 1 FROM tasks WHERE id IN(3040201,3040202,3040203,3040204,3040205,3040206,3040207,3040208)AND NOT((id=3040201 AND type=2 AND title='Pieces of the Past') OR (id=3040202 AND type=2 AND title='Historian Pewdri''s Task') OR (id=3040203 AND type=2 AND title='Feather for Your Cap') OR (id=3040204 AND type=2 AND title='The Dark Tower: Flickering Torches') OR (id=3040205 AND type=2 AND title='The Dark Tower: Fallen Guard') OR (id=3040206 AND type=2 AND title='The Dark Tower: Lord of the Tower') OR (id=3040207 AND type=2 AND title='The Blightfire Witches') OR (id=3040208 AND type=2 AND title='Return of the Moorwalkers')))));
INSERT INTO _champion_guard VALUES('components',((SELECT COUNT(*)FROM achievement_components WHERE achievement_id=500020400 AND component_type=1 AND((component_id=50052 AND sequence=1 AND name='Historian Pewdri - Pieces of the Past') OR (component_id=50053 AND sequence=2 AND name='Historian Pewdri - Historian Pewdri''s Task') OR (component_id=50054 AND sequence=3 AND name='Tailor Ulen - Feather for Your Cap') OR (component_id=50055 AND sequence=4 AND name='Shaytherrin the Exorcist - The Dark Tower, Flickering Torches') OR (component_id=50056 AND sequence=5 AND name='Shaytherrin the Exorcist - The Dark Tower, Fallen Guard') OR (component_id=50057 AND sequence=6 AND name='Shaytherrin the Exorcist - The Dark Tower: Lord of the Tower') OR (component_id=50058 AND sequence=7 AND name='Zan the Witch Hunter - The Blightfire Witches') OR (component_id=50059 AND sequence=8 AND name='Arch Druid Springthorn - Return of the Moorwalkers')))=8));
INSERT INTO _champion_guard VALUES('criteria',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500020400 AND component_type=1 AND component_id BETWEEN 50052 AND 50059 AND(NOT((component_id=50052 AND target_id=3040201 AND component_sequence=1) OR (component_id=50053 AND target_id=3040202 AND component_sequence=2) OR (component_id=50054 AND target_id=3040203 AND component_sequence=3) OR (component_id=50055 AND target_id=3040204 AND component_sequence=4) OR (component_id=50056 AND target_id=3040205 AND component_sequence=5) OR (component_id=50057 AND target_id=3040206 AND component_sequence=6) OR (component_id=50058 AND target_id=3040207 AND component_sequence=7) OR (component_id=50059 AND target_id=3040208 AND component_sequence=8))OR event_type<>4 OR progress_mode<>3 OR behavior<>0 OR required_count<>1 OR enabled<>1 OR target_id2<>0 OR target_value<>0))));
INSERT INTO _champion_guard VALUES('items',((SELECT COUNT(*)FROM items WHERE (id=28693 AND Name='Watchtower Remains' AND classes=0) OR (id=36163 AND Name='Flickering Watchtower Torch' AND classes=65535) OR (id=52643 AND Name='Pristine Ridge Griffon Feather' AND classes=65535) OR (id=53514 AND Name='Sphere of the Ancients' AND classes=65535) OR (id=53515 AND Name='Feathered Cap' AND classes=65535) OR (id=53527 AND Name='Signet of the Witch Hunter' AND classes=65535) OR (id=53534 AND Name='Plate Greaves of the Exorcist' AND classes=151) OR (id=53535 AND Name='Chain Vest of the Exorcist' AND classes=33544) OR (id=53536 AND Name='Leather Greaves of the Exorcist' AND classes=16480) OR (id=53537 AND Name='Robes of the Exorcist' AND classes=15360) OR (id=53538 AND Name='Mantle of the Exorcist' AND classes=65535) OR (id=53551 AND Name='Belt of Briarthorn' AND classes=65535) OR (id=54638 AND Name='Ogre Relic' AND classes=0) OR (id=85760 AND Name='The Moorwalker Runestaff' AND classes=65535) OR (id=85761 AND Name='Shattered Staff of the Green Witch' AND classes=0) OR (id=85762 AND Name='Shattered Staff of the Scarlet Witch' AND classes=0) OR (id=85763 AND Name='Shattered Staff of the Gray Witch' AND classes=0) OR (id=85764 AND Name='Shattered Staff of the Shadow Witch' AND classes=0) OR (id=85765 AND Name='Sergeant Strall''s Battle Crest' AND classes=65535) OR (id=85766 AND Name='Sergeant Janx''s Battle Crest' AND classes=65535) OR (id=85767 AND Name='Chaplain Bloodmoon''s Battle Crest' AND classes=65535) OR (id=85773 AND Name='Watchtower Battle Crests' AND classes=65535))=22));
INSERT INTO _champion_guard VALUES('npcs',((SELECT COUNT(*)FROM npc_types WHERE (id=394059 AND name='Moonreader_Ewera') OR (id=394092 AND name='Historian_Pewdri') OR (id=394126 AND name='Tailor_Ulen') OR (id=395069 AND name='a_watchtower_guardian') OR (id=395073 AND name='a_torch') OR (id=395074 AND name='a_watchtower_guardian') OR (id=395076 AND name='a_watchtower_guardian') OR (id=395080 AND name='Defan_the_Watch_Captain') OR (id=395083 AND name='a_watchtower_guardian') OR (id=395085 AND name='a_signal_fire') OR (id=395090 AND name='a_watchtower_guardian') OR (id=395123 AND name='Shaytherrin_the_Exorcist') OR (id=395153 AND name='Western_Moorwalker') OR (id=395174 AND name='Southern_Moorwalker') OR (id=395184 AND name='#Arch_Druid_Springthorn') OR (id=395185 AND name='#Agatha_the_Gray_Witch') OR (id=395221 AND name='Northern_Moorwalker') OR (id=395245 AND name='#Zan_the_Witch_Hunter') OR (id=395249 AND name='Eastern_Moorwalker'))=19));
INSERT INTO _champion_guard VALUES('reward_set',(NOT EXISTS(SELECT 1 FROM reward_sets WHERE reward_set_id=3040206 AND title<>'The Dark Tower: Lord of the Tower')AND NOT EXISTS(SELECT 1 FROM reward_sources WHERE reward_set_id=3040206 AND NOT(source_type=2 AND source_id=3040206))AND NOT EXISTS(SELECT 1 FROM reward_sources WHERE source_type=2 AND source_id=3040206 AND reward_set_id<>3040206)));
INSERT INTO _champion_guard VALUES('reward_30402061',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=30402061 AND description<>'May2013 Dark Tower option 1')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=30402061 AND NOT(reward_set_id=3040206 AND option_id=1))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=30402061)));
INSERT INTO _champion_guard VALUES('reward_30402062',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=30402062 AND description<>'May2013 Dark Tower option 2')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=30402062 AND NOT(reward_set_id=3040206 AND option_id=2))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=30402062)));
INSERT INTO _champion_guard VALUES('reward_30402063',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=30402063 AND description<>'May2013 Dark Tower option 3')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=30402063 AND NOT(reward_set_id=3040206 AND option_id=3))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=30402063)));
INSERT INTO _champion_guard VALUES('reward_30402064',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=30402064 AND description<>'May2013 Dark Tower option 4')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=30402064 AND NOT(reward_set_id=3040206 AND option_id=4))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=30402064)));
INSERT INTO _champion_guard VALUES('reward_30402065',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=30402065 AND description<>'May2013 Dark Tower option 5')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=30402065 AND NOT(reward_set_id=3040206 AND option_id=5))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=30402065)));
INSERT INTO _champion_guard VALUES('reward_30402066',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=30402066 AND description<>'May2013 Dark Tower option 6')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=30402066 AND NOT(reward_set_id=3040206 AND option_id=6))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=30402066)));
START TRANSACTION;
INSERT INTO tasks (`id`,`type`,`title`,`description`,`reward_text`,`reward_id_list`,`cash_reward`,`exp_reward`,`reward_method`,`min_level`,`repeatable`,`faction_reward`,`faction_amount`,`enabled`,`duration`)VALUES
(3040201,2,'Pieces of the Past','Loot 10 Ogre Relics; Deliver 10 relics to Historian Pewdri.','','53514,1',0,1000,0,15,1,0,0,1,0),
(3040202,2,'Historian Pewdri''s Task','Deliver Watchtower Remains from the tower bone pile to Historian Pewdri.','','',0,1000,0,15,0,0,0,1,28800),
(3040203,2,'Feather for Your Cap','Loot 12 Pristine Ridge Griffon Feathers; Deliver 12 feathers to Tailor Ulen.','','53515,1',0,1000,0,30,0,0,0,1,0),
(3040204,2,'The Dark Tower: Flickering Torches','Loot 10 Flickering Watchtower Torches; Speak with Shaytherrin; retain the torches.','','',0,1000,0,30,1,0,0,1,0),
(3040205,2,'The Dark Tower: Fallen Guard','Defeat 5 watchtower guardians; Deliver Sergeant Strall''s Battle Crest; Deliver Sergeant Janx''s Battle Crest; Deliver Chaplain Bloodmoon''s Battle Crest; Speak with Shaytherrin.','','85773,1',0,1000,0,30,1,0,0,1,0),
(3040206,2,'The Dark Tower: Lord of the Tower','Hail Defan and give him the Watchtower Battle Crests; Defeat Defan after his retreat to the roof.','','',0,0,3,30,1,0,0,1,0),
(3040207,2,'The Blightfire Witches','Deliver the Green Witch staff to Zan; Deliver the Gray Witch staff to Shaytherrin; Deliver the Scarlet Witch staff to Shaytherrin; Deliver the Shadow Witch staff to Shaytherrin.','','53527,1',0,1000,0,35,0,0,0,1,0),
(3040208,2,'Return of the Moorwalkers','Use the Runestaff to put the Northern Moorwalker to sleep; Use the Runestaff to put the Southern Moorwalker to sleep; Use the Runestaff to put the Eastern Moorwalker to sleep; Use the Runestaff to put the Western Moorwalker to sleep; Return the Runestaff to Moonreader Ewera.','','53551,1',0,1000,0,30,0,0,0,1,0)
ON DUPLICATE KEY UPDATE `type`=VALUES(`type`),`title`=VALUES(`title`),`description`=VALUES(`description`),`reward_text`=VALUES(`reward_text`),`reward_id_list`=VALUES(`reward_id_list`),`cash_reward`=VALUES(`cash_reward`),`exp_reward`=VALUES(`exp_reward`),`reward_method`=VALUES(`reward_method`),`min_level`=VALUES(`min_level`),`repeatable`=VALUES(`repeatable`),`faction_reward`=VALUES(`faction_reward`),`faction_amount`=VALUES(`faction_amount`),`enabled`=VALUES(`enabled`),`duration`=VALUES(`duration`);
DELETE FROM task_activities WHERE taskid IN(3040201,3040202,3040203,3040204,3040205,3040206,3040207,3040208);
INSERT INTO task_activities (`taskid`,`activityid`,`req_activity_id`,`step`,`activitytype`,`target_name`,`goalmethod`,`goalcount`,`description_override`,`npc_match_list`,`item_id_list`,`zones`,`spell_list`)VALUES
(3040201,0,-1,0,3,'',0,10,'Loot 10 Ogre Relics','','54638','395',''),
(3040201,1,-1,1,1,'',0,10,'Deliver 10 relics to Historian Pewdri','394092','54638','394',''),
(3040202,0,-1,0,1,'',0,1,'Deliver Watchtower Remains from the tower bone pile to Historian Pewdri','394092','28693','394',''),
(3040203,0,-1,0,3,'',0,12,'Loot 12 Pristine Ridge Griffon Feathers','','52643','395',''),
(3040203,1,-1,1,1,'',0,12,'Deliver 12 feathers to Tailor Ulen','394126','52643','394',''),
(3040204,0,-1,0,3,'',0,10,'Loot 10 Flickering Watchtower Torches','','36163','395',''),
(3040204,1,-1,1,4,'',0,1,'Speak with Shaytherrin; retain the torches','395123','','395',''),
(3040205,0,-1,0,2,'',0,5,'Defeat 5 watchtower guardians','395069|395074|395076|395083|395090','','395',''),
(3040205,1,-1,0,1,'',0,1,'Deliver Sergeant Strall''s Battle Crest','395123','85765','395',''),
(3040205,2,-1,0,1,'',0,1,'Deliver Sergeant Janx''s Battle Crest','395123','85766','395',''),
(3040205,3,-1,0,1,'',0,1,'Deliver Chaplain Bloodmoon''s Battle Crest','395123','85767','395',''),
(3040205,4,-1,1,4,'',0,1,'Speak with Shaytherrin','395123','','395',''),
(3040206,0,-1,0,255,'',0,1,'Hail Defan and give him the Watchtower Battle Crests','','','395',''),
(3040206,1,-1,1,255,'',0,1,'Defeat Defan after his retreat to the roof','','','395',''),
(3040207,0,-1,0,1,'',0,1,'Deliver the Green Witch staff to Zan','395245','85761','395',''),
(3040207,1,-1,1,1,'',0,1,'Deliver the Gray Witch staff to Shaytherrin','395123','85763','395',''),
(3040207,2,-1,1,1,'',0,1,'Deliver the Scarlet Witch staff to Shaytherrin','395123','85762','395',''),
(3040207,3,-1,1,1,'',0,1,'Deliver the Shadow Witch staff to Shaytherrin','395123','85764','395',''),
(3040208,0,-1,0,255,'',0,1,'Use the Runestaff to put the Northern Moorwalker to sleep','','','395',''),
(3040208,1,-1,0,255,'',0,1,'Use the Runestaff to put the Southern Moorwalker to sleep','','','395',''),
(3040208,2,-1,0,255,'',0,1,'Use the Runestaff to put the Eastern Moorwalker to sleep','','','395',''),
(3040208,3,-1,0,255,'',0,1,'Use the Runestaff to put the Western Moorwalker to sleep','','','395',''),
(3040208,4,-1,1,1,'',0,1,'Return the Runestaff to Moonreader Ewera','394059','85760','394','')
ON DUPLICATE KEY UPDATE `activityid`=VALUES(`activityid`),`req_activity_id`=VALUES(`req_activity_id`),`step`=VALUES(`step`),`activitytype`=VALUES(`activitytype`),`target_name`=VALUES(`target_name`),`goalmethod`=VALUES(`goalmethod`),`goalcount`=VALUES(`goalcount`),`description_override`=VALUES(`description_override`),`npc_match_list`=VALUES(`npc_match_list`),`item_id_list`=VALUES(`item_id_list`),`zones`=VALUES(`zones`),`spell_list`=VALUES(`spell_list`);
DELETE FROM achievement_criteria WHERE achievement_id=500020400 AND component_type=1 AND component_id BETWEEN 50052 AND 50059;
INSERT INTO achievement_criteria (`achievement_id`,`component_type`,`component_sequence`,`component_id`,`event_type`,`progress_mode`,`behavior`,`target_id`,`target_id2`,`target_value`,`required_count`,`enabled`)VALUES
(500020400,1,1,50052,4,3,0,3040201,0,0,1,1),
(500020400,1,2,50053,4,3,0,3040202,0,0,1,1),
(500020400,1,3,50054,4,3,0,3040203,0,0,1,1),
(500020400,1,4,50055,4,3,0,3040204,0,0,1,1),
(500020400,1,5,50056,4,3,0,3040205,0,0,1,1),
(500020400,1,6,50057,4,3,0,3040206,0,0,1,1),
(500020400,1,7,50058,4,3,0,3040207,0,0,1,1),
(500020400,1,8,50059,4,3,0,3040208,0,0,1,1)
ON DUPLICATE KEY UPDATE `component_type`=VALUES(`component_type`),`component_sequence`=VALUES(`component_sequence`),`component_id`=VALUES(`component_id`),`event_type`=VALUES(`event_type`),`progress_mode`=VALUES(`progress_mode`),`behavior`=VALUES(`behavior`),`target_id`=VALUES(`target_id`),`target_id2`=VALUES(`target_id2`),`target_value`=VALUES(`target_value`),`required_count`=VALUES(`required_count`),`enabled`=VALUES(`enabled`);
INSERT INTO reward_sets (`reward_set_id`,`title`,`enabled`)VALUES
(3040206,'The Dark Tower: Lord of the Tower',1)
ON DUPLICATE KEY UPDATE `title`=VALUES(`title`),`enabled`=VALUES(`enabled`);
INSERT INTO reward_sources (`source_type`,`source_id`,`reward_set_id`,`enabled`)VALUES
(2,3040206,3040206,1)
ON DUPLICATE KEY UPDATE `source_id`=VALUES(`source_id`),`reward_set_id`=VALUES(`reward_set_id`),`enabled`=VALUES(`enabled`);
INSERT INTO reward_options (`reward_set_id`,`option_id`,`sequence`,`label`,`common_to_all`,`flags`,`enabled`,`class_mask`)VALUES
(3040206,1,0,'Experience',1,0,1,65535),
(3040206,2,2,'Plate Greaves of the Exorcist',0,0,1,151),
(3040206,3,3,'Chain Vest of the Exorcist',0,0,1,33544),
(3040206,4,4,'Leather Greaves of the Exorcist',0,0,1,16480),
(3040206,5,5,'Robes of the Exorcist',0,0,1,15360),
(3040206,6,6,'Mantle of the Exorcist',0,0,1,65535)
ON DUPLICATE KEY UPDATE `option_id`=VALUES(`option_id`),`sequence`=VALUES(`sequence`),`label`=VALUES(`label`),`common_to_all`=VALUES(`common_to_all`),`flags`=VALUES(`flags`),`enabled`=VALUES(`enabled`),`class_mask`=VALUES(`class_mask`);
INSERT INTO rewards (`reward_id`,`reward_type`,`reward_data_id`,`amount`,`description`,`enabled`)VALUES
(30402061,1,1,1000,'May2013 Dark Tower option 1',1),
(30402062,0,53534,1,'May2013 Dark Tower option 2',1),
(30402063,0,53535,1,'May2013 Dark Tower option 3',1),
(30402064,0,53536,1,'May2013 Dark Tower option 4',1),
(30402065,0,53537,1,'May2013 Dark Tower option 5',1),
(30402066,0,53538,1,'May2013 Dark Tower option 6',1)
ON DUPLICATE KEY UPDATE `reward_type`=VALUES(`reward_type`),`reward_data_id`=VALUES(`reward_data_id`),`amount`=VALUES(`amount`),`description`=VALUES(`description`),`enabled`=VALUES(`enabled`);
INSERT INTO reward_option_entries (`reward_set_id`,`option_id`,`sequence`,`reward_id`)VALUES
(3040206,1,0,30402061),
(3040206,2,0,30402062),
(3040206,3,0,30402063),
(3040206,4,0,30402064),
(3040206,5,0,30402065),
(3040206,6,0,30402066)
ON DUPLICATE KEY UPDATE `option_id`=VALUES(`option_id`),`sequence`=VALUES(`sequence`),`reward_id`=VALUES(`reward_id`);
COMMIT;
