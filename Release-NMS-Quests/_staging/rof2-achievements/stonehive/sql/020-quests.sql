-- Stone Hive complete quest/scene package. See provenance/native-status.json.
SET NAMES utf8mb4;
SET SESSION check_constraint_checks=1;
DROP TEMPORARY TABLE IF EXISTS _stone_guard;
CREATE TEMPORARY TABLE _stone_guard(label VARCHAR(80)PRIMARY KEY,ok TINYINT NOT NULL,CHECK(ok=1))ENGINE=InnoDB;
INSERT INTO _stone_guard VALUES('task_identities',(NOT EXISTS(SELECT 1 FROM tasks WHERE id IN(3040301,3040302,3040303,3040304,3040305,3040306,3040307,3040308,3040309,3040310,3040311,3040312,3040313,3040314,3040315,3040316)AND NOT((id=3040301 AND type=2 AND title='Sticky Situation') OR (id=3040302 AND type=2 AND title='The Saving Salve') OR (id=3040303 AND type=2 AND title='Plans or No Plans') OR (id=3040304 AND type=2 AND title='Bee Prepared for War') OR (id=3040305 AND type=2 AND title='The Golden One') OR (id=3040306 AND type=2 AND title='A''mazin Plants') OR (id=3040307 AND type=2 AND title='Curious Seed') OR (id=3040308 AND type=2 AND title='Sappy Request') OR (id=3040309 AND type=2 AND title='Nothing to Stew About') OR (id=3040310 AND type=2 AND title='Touchy Feely Flan') OR (id=3040311 AND type=2 AND title='Heads Above the Rest') OR (id=3040312 AND type=2 AND title='Jumjum Research') OR (id=3040313 AND type=2 AND title='Who''s Who?') OR (id=3040314 AND type=2 AND title='Infiltrate the Hive') OR (id=3040315 AND type=2 AND title='Honey, I''m Home!') OR (id=3040316 AND type=2 AND title='The Queen Bixie')))));
INSERT INTO _stone_guard VALUES('components',((SELECT COUNT(*)FROM achievement_components WHERE component_type=1 AND((achievement_id=500030200 AND component_id=50086 AND sequence=1 AND name='Scout Vreshnar - Sticky Situation') OR (achievement_id=500030200 AND component_id=50087 AND sequence=2 AND name='Scout Neauza - The Saving Salve') OR (achievement_id=500030200 AND component_id=50088 AND sequence=3 AND name='Scout Neauza - Plans or No Plans') OR (achievement_id=500030200 AND component_id=50089 AND sequence=4 AND name='Scout Vreshnar - Bee Prepared for War') OR (achievement_id=500030200 AND component_id=50090 AND sequence=5 AND name='Scout Vreshnar - The Golden One') OR (achievement_id=500030400 AND component_id=50095 AND sequence=1 AND name='Botanist Brezuu - A''mazin'' Plants') OR (achievement_id=500030400 AND component_id=50096 AND sequence=2 AND name='Botanist Brezuu - Curious Seeds') OR (achievement_id=500030400 AND component_id=50097 AND sequence=3 AND name='Botanist Brezuu - Sappy Request') OR (achievement_id=500030500 AND component_id=50098 AND sequence=1 AND name='Cook Idriak - Nothing to Stew About') OR (achievement_id=500030500 AND component_id=50099 AND sequence=2 AND name='Cook Idriak - Touchy Feely Flan') OR (achievement_id=500030500 AND component_id=50100 AND sequence=3 AND name='Cook Idriak - Heads Above the Rest') OR (achievement_id=500030500 AND component_id=50101 AND sequence=4 AND name='Cook Idriak - Jumjum Research') OR (achievement_id=500030600 AND component_id=50102 AND sequence=1 AND name='Warwing Wendlez - Who''s Who?') OR (achievement_id=500030600 AND component_id=50103 AND sequence=2 AND name='Warwing Wendlez - Infiltrate the Hive') OR (achievement_id=500030600 AND component_id=50104 AND sequence=3 AND name='Warwing Wendlez - Honey, I''m Home!') OR (achievement_id=500030600 AND component_id=50105 AND sequence=4 AND name='Warwing Wendlez - The Queen Bixie')))=16));
INSERT INTO _stone_guard VALUES('item_identities',((SELECT COUNT(*)FROM items WHERE (id=21793 AND Name='Bixie War Plans' AND classes=0) OR (id=53578 AND Name='Jumjum Honey Mead' AND classes=65535) OR (id=53579 AND Name='Violasuthia Healing Potion' AND classes=65535) OR (id=53580 AND Name='Acantuss Mana Potion' AND classes=65535) OR (id=53581 AND Name='Honey-Touched Band' AND classes=65535) OR (id=53582 AND Name='Obsidian Bixie Bauble' AND classes=65535) OR (id=53583 AND Name='Buzzing Bixie Wand' AND classes=65535) OR (id=53584 AND Name='Honeycomb Blaster' AND classes=65535) OR (id=53586 AND Name='Bungled Bixie Zapper' AND classes=15360) OR (id=53587 AND Name='Bixie Zapper Enhancer' AND classes=65535) OR (id=53591 AND Name='Honeystone of Buzzitude' AND classes=65535) OR (id=53592 AND Name='Honeystone of Dream Delights' AND classes=15360) OR (id=53593 AND Name='Honeystone of Magicjum' AND classes=65535) OR (id=54616 AND Name='Intact Bixie Wing' AND classes=0) OR (id=54617 AND Name='Intact Bixie Flesh' AND classes=0) OR (id=54618 AND Name='Intact Bixie Scent Gland' AND classes=0) OR (id=54619 AND Name='Intact Bixie Antennae' AND classes=0) OR (id=54620 AND Name='Intact Stone Hive Insignia' AND classes=0) OR (id=54622 AND Name='Note to Neauza' AND classes=0) OR (id=54623 AND Name='Saving Salve' AND classes=0) OR (id=54624 AND Name='Muddied Bixie Plans' AND classes=0) OR (id=54626 AND Name='Fresh Jumjum' AND classes=0) OR (id=54627 AND Name='Jumjum Wine' AND classes=0) OR (id=54628 AND Name='Processed Jumjum' AND classes=0) OR (id=54629 AND Name='Jumjum Jam' AND classes=0) OR (id=54632 AND Name='Delectable Bixie Wing' AND classes=0) OR (id=54633 AND Name='Scrumptious Bixie Antennae' AND classes=0) OR (id=54634 AND Name='Ripe Bixie Head' AND classes=0) OR (id=54635 AND Name='Violasuthia Petal' AND classes=0) OR (id=54636 AND Name='Acantuss Seed' AND classes=0) OR (id=54637 AND Name='Symplokiss Sap' AND classes=0) OR (id=54640 AND Name='Bixie Spellbook' AND classes=0) OR (id=54641 AND Name='Bixie Potion Bottle' AND classes=0) OR (id=54642 AND Name='Bixie Alchemy Notes' AND classes=0))=34));
INSERT INTO _stone_guard VALUES('npc_identities',((SELECT COUNT(*)FROM npc_types WHERE (id=395211 AND name='Scout_Vreshnar') OR (id=395213 AND name='Botanist_Brezuu') OR (id=395215 AND name='Cook_Idriak') OR (id=396123 AND name='Warwing_Wendlez') OR (id=396173 AND name='a_bixie_enthraller') OR (id=396180 AND name='Neezzee') OR (id=396209 AND name='#Queen_Pelzia') OR (id=396229 AND name='Scout_Neauza') OR (id=396230 AND name='#Alchemist_Krizzia'))=9));
INSERT INTO _stone_guard VALUES('criterion_50086',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500030200 AND component_type=1 AND component_id=50086 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040301 AND target_id2=0 AND target_value=0 AND component_sequence=1 AND required_count=1 AND enabled=1))));
INSERT INTO _stone_guard VALUES('criterion_50087',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500030200 AND component_type=1 AND component_id=50087 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040302 AND target_id2=0 AND target_value=0 AND component_sequence=2 AND required_count=1 AND enabled=1))));
INSERT INTO _stone_guard VALUES('criterion_50088',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500030200 AND component_type=1 AND component_id=50088 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040303 AND target_id2=0 AND target_value=0 AND component_sequence=3 AND required_count=1 AND enabled=1))));
INSERT INTO _stone_guard VALUES('criterion_50089',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500030200 AND component_type=1 AND component_id=50089 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040304 AND target_id2=0 AND target_value=0 AND component_sequence=4 AND required_count=1 AND enabled=1))));
INSERT INTO _stone_guard VALUES('criterion_50090',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500030200 AND component_type=1 AND component_id=50090 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040305 AND target_id2=0 AND target_value=0 AND component_sequence=5 AND required_count=1 AND enabled=1))));
INSERT INTO _stone_guard VALUES('reward_set_3040305',(NOT EXISTS(SELECT 1 FROM reward_sets WHERE reward_set_id=3040305 AND title<>'The Golden One')AND NOT EXISTS(SELECT 1 FROM reward_sources WHERE reward_set_id=3040305 AND NOT(source_type=2 AND source_id=3040305))AND NOT EXISTS(SELECT 1 FROM reward_sources WHERE source_type=2 AND source_id=3040305 AND reward_set_id<>3040305)));
INSERT INTO _stone_guard VALUES('reward_30403051',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=30403051 AND description<>'May2013 Stone Hive option 30403051')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=30403051 AND NOT(reward_set_id=3040305 AND option_id=1))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=30403051)));
INSERT INTO _stone_guard VALUES('reward_30403052',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=30403052 AND description<>'May2013 Stone Hive option 30403052')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=30403052 AND NOT(reward_set_id=3040305 AND option_id=2))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=30403052)));
INSERT INTO _stone_guard VALUES('reward_30403053',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=30403053 AND description<>'May2013 Stone Hive option 30403053')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=30403053 AND NOT(reward_set_id=3040305 AND option_id=3))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=30403053)));
INSERT INTO _stone_guard VALUES('criterion_50095',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500030400 AND component_type=1 AND component_id=50095 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040306 AND target_id2=0 AND target_value=0 AND component_sequence=1 AND required_count=1 AND enabled=1))));
INSERT INTO _stone_guard VALUES('criterion_50096',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500030400 AND component_type=1 AND component_id=50096 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040307 AND target_id2=0 AND target_value=0 AND component_sequence=2 AND required_count=1 AND enabled=1))));
INSERT INTO _stone_guard VALUES('criterion_50097',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500030400 AND component_type=1 AND component_id=50097 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040308 AND target_id2=0 AND target_value=0 AND component_sequence=3 AND required_count=1 AND enabled=1))));
INSERT INTO _stone_guard VALUES('criterion_50098',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500030500 AND component_type=1 AND component_id=50098 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040309 AND target_id2=0 AND target_value=0 AND component_sequence=1 AND required_count=1 AND enabled=1))));
INSERT INTO _stone_guard VALUES('criterion_50099',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500030500 AND component_type=1 AND component_id=50099 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040310 AND target_id2=0 AND target_value=0 AND component_sequence=2 AND required_count=1 AND enabled=1))));
INSERT INTO _stone_guard VALUES('criterion_50100',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500030500 AND component_type=1 AND component_id=50100 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040311 AND target_id2=0 AND target_value=0 AND component_sequence=3 AND required_count=1 AND enabled=1))));
INSERT INTO _stone_guard VALUES('criterion_50101',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500030500 AND component_type=1 AND component_id=50101 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040312 AND target_id2=0 AND target_value=0 AND component_sequence=4 AND required_count=1 AND enabled=1))));
INSERT INTO _stone_guard VALUES('criterion_50102',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500030600 AND component_type=1 AND component_id=50102 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040313 AND target_id2=0 AND target_value=0 AND component_sequence=1 AND required_count=1 AND enabled=1))));
INSERT INTO _stone_guard VALUES('criterion_50103',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500030600 AND component_type=1 AND component_id=50103 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040314 AND target_id2=0 AND target_value=0 AND component_sequence=2 AND required_count=1 AND enabled=1))));
INSERT INTO _stone_guard VALUES('criterion_50104',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500030600 AND component_type=1 AND component_id=50104 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040315 AND target_id2=0 AND target_value=0 AND component_sequence=3 AND required_count=1 AND enabled=1))));
INSERT INTO _stone_guard VALUES('criterion_50105',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500030600 AND component_type=1 AND component_id=50105 AND NOT(event_type=4 AND progress_mode=3 AND behavior=0 AND target_id=3040316 AND target_id2=0 AND target_value=0 AND component_sequence=4 AND required_count=1 AND enabled=1))));
INSERT INTO _stone_guard VALUES('reward_set_3040316',(NOT EXISTS(SELECT 1 FROM reward_sets WHERE reward_set_id=3040316 AND title<>'The Queen Bixie')AND NOT EXISTS(SELECT 1 FROM reward_sources WHERE reward_set_id=3040316 AND NOT(source_type=2 AND source_id=3040316))AND NOT EXISTS(SELECT 1 FROM reward_sources WHERE source_type=2 AND source_id=3040316 AND reward_set_id<>3040316)));
INSERT INTO _stone_guard VALUES('reward_30403161',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=30403161 AND description<>'May2013 Stone Hive option 30403161')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=30403161 AND NOT(reward_set_id=3040316 AND option_id=1))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=30403161)));
INSERT INTO _stone_guard VALUES('reward_30403162',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=30403162 AND description<>'May2013 Stone Hive option 30403162')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=30403162 AND NOT(reward_set_id=3040316 AND option_id=2))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=30403162)));
INSERT INTO _stone_guard VALUES('reward_30403163',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=30403163 AND description<>'May2013 Stone Hive option 30403163')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=30403163 AND NOT(reward_set_id=3040316 AND option_id=3))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=30403163)));
INSERT INTO _stone_guard VALUES('reward_30403164',(NOT EXISTS(SELECT 1 FROM rewards WHERE reward_id=30403164 AND description<>'May2013 Stone Hive option 30403164')AND NOT EXISTS(SELECT 1 FROM reward_option_entries WHERE reward_id=30403164 AND NOT(reward_set_id=3040316 AND option_id=4))AND NOT EXISTS(SELECT 1 FROM reward_source_entries WHERE reward_id=30403164)));
START TRANSACTION;
INSERT INTO tasks(`id`,`type`,`title`,`description`,`reward_text`,`reward_id_list`,`cash_reward`,`exp_reward`,`reward_method`,`min_level`,`repeatable`,`faction_reward`,`faction_amount`,`enabled`,`duration`)VALUES
(3040301,2,'Sticky Situation','Deliver the note to Scout Neauza.','','',0,1000,0,30,1,0,0,1,0),
(3040302,2,'The Saving Salve','Defeat a bixie enthraller; Give Saving Salve to Scout Neauza.','','',0,1000,0,30,1,0,0,1,0),
(3040303,2,'Plans or No Plans','Deliver Muddied Bixie Plans to Scout Vreshnar.','','',0,1000,0,30,1,0,0,1,0),
(3040304,2,'Bee Prepared for War','Explore the botanical research area; Obtain Bixie Alchemy Notes; Find the Bixie Potion Bottle; Find the Bixie Spellbook; Deliver Bixie Alchemy Notes to Scout Vreshnar; Deliver Bixie Potion Bottle to Scout Vreshnar; Deliver Bixie Spellbook to Scout Vreshnar.','','',0,1000,0,30,1,0,0,1,0),
(3040305,2,'The Golden One','Explore the magical research area; Defeat Juzzulli.','','',0,0,3,35,1,0,0,1,0),
(3040306,2,'A''mazin Plants','Gather ten Violasuthia Petal.','','53579,1',0,1000,0,34,0,0,0,1,0),
(3040307,2,'Curious Seed','Gather ten Acantuss Seed.','','53580,1',0,1000,0,34,0,0,0,1,0),
(3040308,2,'Sappy Request','Gather ten Symplokiss Sap.','','53578,1',0,1000,0,28,0,0,0,1,0),
(3040309,2,'Nothing to Stew About','Deliver ten Delectable Bixie Wing to Cook Idriak.','','53581,1',0,1000,0,32,1,0,0,1,0),
(3040310,2,'Touchy Feely Flan','Deliver ten Scrumptious Bixie Antennae to Cook Idriak.','','53582,1',0,1000,0,34,1,0,0,1,0),
(3040311,2,'Heads Above the Rest','Deliver ten Ripe Bixie Head to Cook Idriak.','','53583,1',0,1000,0,38,0,0,0,1,0),
(3040312,2,'Jumjum Research','Deliver two Fresh Jumjum to Cook Idriak; Deliver two Jumjum Wine to Cook Idriak; Deliver two Processed Jumjum to Cook Idriak; Deliver two Jumjum Jam to Cook Idriak.','','53584,1',0,1000,0,32,1,0,0,1,0),
(3040313,2,'Who''s Who?','Find and hail Neezzee; Defeat Neezzee; Return to Warwing Wendlez.','','',0,1000,0,35,1,0,0,1,0),
(3040314,2,'Infiltrate the Hive','Deliver Bixie War Plans to Warwing.','','',0,1000,0,35,1,0,0,1,0),
(3040315,2,'Honey, I''m Home!','Deliver 2 Intact Bixie Wing to Warwing; Deliver 2 Intact Bixie Flesh to Warwing; Deliver 1 Intact Bixie Scent Gland to Warwing; Deliver 2 Intact Bixie Antennae to Warwing; Deliver 1 Intact Stone Hive Insignia to Warwing.','','',0,1000,0,35,1,0,0,1,0),
(3040316,2,'The Queen Bixie','Defeat Queen Pelzia.','','',0,0,3,35,1,0,0,1,0)
ON DUPLICATE KEY UPDATE `type`=VALUES(`type`),`title`=VALUES(`title`),`description`=VALUES(`description`),`reward_text`=VALUES(`reward_text`),`reward_id_list`=VALUES(`reward_id_list`),`cash_reward`=VALUES(`cash_reward`),`exp_reward`=VALUES(`exp_reward`),`reward_method`=VALUES(`reward_method`),`min_level`=VALUES(`min_level`),`repeatable`=VALUES(`repeatable`),`faction_reward`=VALUES(`faction_reward`),`faction_amount`=VALUES(`faction_amount`),`enabled`=VALUES(`enabled`),`duration`=VALUES(`duration`);
DELETE FROM task_activities WHERE taskid IN(3040301,3040302,3040303,3040304,3040305,3040306,3040307,3040308,3040309,3040310,3040311,3040312,3040313,3040314,3040315,3040316);
INSERT INTO task_activities(`taskid`,`activityid`,`req_activity_id`,`step`,`activitytype`,`target_name`,`goalmethod`,`goalcount`,`description_override`,`npc_match_list`,`item_id_list`,`zones`,`spell_list`)VALUES
(3040301,0,-1,0,1,'',0,1,'Deliver the note to Scout Neauza','396229','54622','396',''),
(3040302,0,-1,0,2,'',0,1,'Defeat a bixie enthraller','396173','','396',''),
(3040302,1,-1,1,1,'',0,1,'Give Saving Salve to Scout Neauza','396229','54623','396',''),
(3040303,0,-1,0,1,'',0,1,'Deliver Muddied Bixie Plans to Scout Vreshnar','395211','54624','395',''),
(3040304,0,-1,0,255,'',0,1,'Explore the botanical research area','','','396',''),
(3040304,1,-1,1,3,'',0,1,'Obtain Bixie Alchemy Notes','','54642','396',''),
(3040304,2,-1,1,255,'',0,1,'Find the Bixie Potion Bottle','','54641','396',''),
(3040304,3,-1,1,255,'',0,1,'Find the Bixie Spellbook','','54640','396',''),
(3040304,4,-1,2,1,'',0,1,'Deliver Bixie Alchemy Notes to Scout Vreshnar','395211','54642','395',''),
(3040304,5,-1,2,1,'',0,1,'Deliver Bixie Potion Bottle to Scout Vreshnar','395211','54641','395',''),
(3040304,6,-1,2,1,'',0,1,'Deliver Bixie Spellbook to Scout Vreshnar','395211','54640','395',''),
(3040305,0,-1,0,255,'',0,1,'Explore the magical research area','','','396',''),
(3040305,1,-1,1,2,'',0,1,'Defeat Juzzulli','396930','','396',''),
(3040306,0,-1,0,3,'',0,10,'Gather ten Violasuthia Petal','','54635','396',''),
(3040307,0,-1,0,3,'',0,10,'Gather ten Acantuss Seed','','54636','396',''),
(3040308,0,-1,0,3,'',0,10,'Gather ten Symplokiss Sap','','54637','396',''),
(3040309,0,-1,0,1,'',0,10,'Deliver ten Delectable Bixie Wing to Cook Idriak','395215','54632','395',''),
(3040310,0,-1,0,1,'',0,10,'Deliver ten Scrumptious Bixie Antennae to Cook Idriak','395215','54633','395',''),
(3040311,0,-1,0,1,'',0,10,'Deliver ten Ripe Bixie Head to Cook Idriak','395215','54634','395',''),
(3040312,0,-1,1,1,'',0,2,'Deliver two Fresh Jumjum to Cook Idriak','395215','54626','395',''),
(3040312,1,-1,1,1,'',0,2,'Deliver two Jumjum Wine to Cook Idriak','395215','54627','395',''),
(3040312,2,-1,1,1,'',0,2,'Deliver two Processed Jumjum to Cook Idriak','395215','54628','395',''),
(3040312,3,-1,1,1,'',0,2,'Deliver two Jumjum Jam to Cook Idriak','395215','54629','395',''),
(3040313,0,-1,0,4,'',0,1,'Find and hail Neezzee','396180','','396',''),
(3040313,1,-1,1,2,'',0,1,'Defeat Neezzee','396180','','396',''),
(3040313,2,-1,2,4,'',0,1,'Return to Warwing Wendlez','396123','','396',''),
(3040314,0,-1,0,1,'',0,1,'Deliver Bixie War Plans to Warwing','396123','21793','396',''),
(3040315,0,-1,1,1,'',0,2,'Deliver 2 Intact Bixie Wing to Warwing','396123','54616','396',''),
(3040315,1,-1,1,1,'',0,2,'Deliver 2 Intact Bixie Flesh to Warwing','396123','54617','396',''),
(3040315,2,-1,1,1,'',0,1,'Deliver 1 Intact Bixie Scent Gland to Warwing','396123','54618','396',''),
(3040315,3,-1,1,1,'',0,2,'Deliver 2 Intact Bixie Antennae to Warwing','396123','54619','396',''),
(3040315,4,-1,1,1,'',0,1,'Deliver 1 Intact Stone Hive Insignia to Warwing','396123','54620','396',''),
(3040316,0,-1,0,2,'',0,1,'Defeat Queen Pelzia','396209','','396','')
ON DUPLICATE KEY UPDATE `activityid`=VALUES(`activityid`),`req_activity_id`=VALUES(`req_activity_id`),`step`=VALUES(`step`),`activitytype`=VALUES(`activitytype`),`target_name`=VALUES(`target_name`),`goalmethod`=VALUES(`goalmethod`),`goalcount`=VALUES(`goalcount`),`description_override`=VALUES(`description_override`),`npc_match_list`=VALUES(`npc_match_list`),`item_id_list`=VALUES(`item_id_list`),`zones`=VALUES(`zones`),`spell_list`=VALUES(`spell_list`);
DELETE FROM achievement_criteria WHERE achievement_id=500030200 AND component_type=1 AND component_id=50086;
DELETE FROM achievement_criteria WHERE achievement_id=500030200 AND component_type=1 AND component_id=50087;
DELETE FROM achievement_criteria WHERE achievement_id=500030200 AND component_type=1 AND component_id=50088;
DELETE FROM achievement_criteria WHERE achievement_id=500030200 AND component_type=1 AND component_id=50089;
DELETE FROM achievement_criteria WHERE achievement_id=500030200 AND component_type=1 AND component_id=50090;
DELETE FROM achievement_criteria WHERE achievement_id=500030400 AND component_type=1 AND component_id=50095;
DELETE FROM achievement_criteria WHERE achievement_id=500030400 AND component_type=1 AND component_id=50096;
DELETE FROM achievement_criteria WHERE achievement_id=500030400 AND component_type=1 AND component_id=50097;
DELETE FROM achievement_criteria WHERE achievement_id=500030500 AND component_type=1 AND component_id=50098;
DELETE FROM achievement_criteria WHERE achievement_id=500030500 AND component_type=1 AND component_id=50099;
DELETE FROM achievement_criteria WHERE achievement_id=500030500 AND component_type=1 AND component_id=50100;
DELETE FROM achievement_criteria WHERE achievement_id=500030500 AND component_type=1 AND component_id=50101;
DELETE FROM achievement_criteria WHERE achievement_id=500030600 AND component_type=1 AND component_id=50102;
DELETE FROM achievement_criteria WHERE achievement_id=500030600 AND component_type=1 AND component_id=50103;
DELETE FROM achievement_criteria WHERE achievement_id=500030600 AND component_type=1 AND component_id=50104;
DELETE FROM achievement_criteria WHERE achievement_id=500030600 AND component_type=1 AND component_id=50105;
INSERT INTO achievement_criteria(`achievement_id`,`component_type`,`component_sequence`,`component_id`,`event_type`,`progress_mode`,`behavior`,`target_id`,`target_id2`,`target_value`,`required_count`,`enabled`)VALUES
(500030200,1,1,50086,4,3,0,3040301,0,0,1,1),
(500030200,1,2,50087,4,3,0,3040302,0,0,1,1),
(500030200,1,3,50088,4,3,0,3040303,0,0,1,1),
(500030200,1,4,50089,4,3,0,3040304,0,0,1,1),
(500030200,1,5,50090,4,3,0,3040305,0,0,1,1),
(500030400,1,1,50095,4,3,0,3040306,0,0,1,1),
(500030400,1,2,50096,4,3,0,3040307,0,0,1,1),
(500030400,1,3,50097,4,3,0,3040308,0,0,1,1),
(500030500,1,1,50098,4,3,0,3040309,0,0,1,1),
(500030500,1,2,50099,4,3,0,3040310,0,0,1,1),
(500030500,1,3,50100,4,3,0,3040311,0,0,1,1),
(500030500,1,4,50101,4,3,0,3040312,0,0,1,1),
(500030600,1,1,50102,4,3,0,3040313,0,0,1,1),
(500030600,1,2,50103,4,3,0,3040314,0,0,1,1),
(500030600,1,3,50104,4,3,0,3040315,0,0,1,1),
(500030600,1,4,50105,4,3,0,3040316,0,0,1,1)
ON DUPLICATE KEY UPDATE `component_type`=VALUES(`component_type`),`component_sequence`=VALUES(`component_sequence`),`component_id`=VALUES(`component_id`),`event_type`=VALUES(`event_type`),`progress_mode`=VALUES(`progress_mode`),`behavior`=VALUES(`behavior`),`target_id`=VALUES(`target_id`),`target_id2`=VALUES(`target_id2`),`target_value`=VALUES(`target_value`),`required_count`=VALUES(`required_count`),`enabled`=VALUES(`enabled`);
INSERT INTO reward_sets(`reward_set_id`,`title`,`enabled`)VALUES
(3040305,'The Golden One',1)
ON DUPLICATE KEY UPDATE `title`=VALUES(`title`),`enabled`=VALUES(`enabled`);
INSERT INTO reward_sources(`source_type`,`source_id`,`reward_set_id`,`enabled`)VALUES
(2,3040305,3040305,1)
ON DUPLICATE KEY UPDATE `source_id`=VALUES(`source_id`),`reward_set_id`=VALUES(`reward_set_id`),`enabled`=VALUES(`enabled`);
INSERT INTO reward_options(`reward_set_id`,`option_id`,`sequence`,`label`,`common_to_all`,`flags`,`enabled`,`class_mask`)VALUES
(3040305,1,0,'Experience',1,0,1,65535),
(3040305,2,2,'Bungled Bixie Zapper',0,0,1,15360),
(3040305,3,3,'Bixie Zapper Enhancer',0,0,1,65535)
ON DUPLICATE KEY UPDATE `option_id`=VALUES(`option_id`),`sequence`=VALUES(`sequence`),`label`=VALUES(`label`),`common_to_all`=VALUES(`common_to_all`),`flags`=VALUES(`flags`),`enabled`=VALUES(`enabled`),`class_mask`=VALUES(`class_mask`);
INSERT INTO rewards(`reward_id`,`reward_type`,`reward_data_id`,`amount`,`description`,`enabled`)VALUES
(30403051,1,1,1000,'May2013 Stone Hive option 30403051',1),
(30403052,0,53586,1,'May2013 Stone Hive option 30403052',1),
(30403053,0,53587,1,'May2013 Stone Hive option 30403053',1)
ON DUPLICATE KEY UPDATE `reward_type`=VALUES(`reward_type`),`reward_data_id`=VALUES(`reward_data_id`),`amount`=VALUES(`amount`),`description`=VALUES(`description`),`enabled`=VALUES(`enabled`);
INSERT INTO reward_option_entries(`reward_set_id`,`option_id`,`sequence`,`reward_id`)VALUES
(3040305,1,0,30403051),
(3040305,2,0,30403052),
(3040305,3,0,30403053)
ON DUPLICATE KEY UPDATE `option_id`=VALUES(`option_id`),`sequence`=VALUES(`sequence`),`reward_id`=VALUES(`reward_id`);
INSERT INTO reward_sets(`reward_set_id`,`title`,`enabled`)VALUES
(3040316,'The Queen Bixie',1)
ON DUPLICATE KEY UPDATE `title`=VALUES(`title`),`enabled`=VALUES(`enabled`);
INSERT INTO reward_sources(`source_type`,`source_id`,`reward_set_id`,`enabled`)VALUES
(2,3040316,3040316,1)
ON DUPLICATE KEY UPDATE `source_id`=VALUES(`source_id`),`reward_set_id`=VALUES(`reward_set_id`),`enabled`=VALUES(`enabled`);
INSERT INTO reward_options(`reward_set_id`,`option_id`,`sequence`,`label`,`common_to_all`,`flags`,`enabled`,`class_mask`)VALUES
(3040316,1,0,'Experience',1,0,1,65535),
(3040316,2,2,'Honeystone of Buzzitude',0,0,1,65535),
(3040316,3,3,'Honeystone of Dream Delights',0,0,1,15360),
(3040316,4,4,'Honeystone of Magicjum',0,0,1,65535)
ON DUPLICATE KEY UPDATE `option_id`=VALUES(`option_id`),`sequence`=VALUES(`sequence`),`label`=VALUES(`label`),`common_to_all`=VALUES(`common_to_all`),`flags`=VALUES(`flags`),`enabled`=VALUES(`enabled`),`class_mask`=VALUES(`class_mask`);
INSERT INTO rewards(`reward_id`,`reward_type`,`reward_data_id`,`amount`,`description`,`enabled`)VALUES
(30403161,1,1,1000,'May2013 Stone Hive option 30403161',1),
(30403162,0,53591,1,'May2013 Stone Hive option 30403162',1),
(30403163,0,53592,1,'May2013 Stone Hive option 30403163',1),
(30403164,0,53593,1,'May2013 Stone Hive option 30403164',1)
ON DUPLICATE KEY UPDATE `reward_type`=VALUES(`reward_type`),`reward_data_id`=VALUES(`reward_data_id`),`amount`=VALUES(`amount`),`description`=VALUES(`description`),`enabled`=VALUES(`enabled`);
INSERT INTO reward_option_entries(`reward_set_id`,`option_id`,`sequence`,`reward_id`)VALUES
(3040316,1,0,30403161),
(3040316,2,0,30403162),
(3040316,3,0,30403163),
(3040316,4,0,30403164)
ON DUPLICATE KEY UPDATE `option_id`=VALUES(`option_id`),`sequence`=VALUES(`sequence`),`reward_id`=VALUES(`reward_id`);
COMMIT;
