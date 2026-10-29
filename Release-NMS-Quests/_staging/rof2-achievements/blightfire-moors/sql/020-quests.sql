-- Blightfire14 reconstruction. Read provenance/historical-sources.json before installing.
-- Best-supported researched minimum/repeat settings approved by user. XP defaults
-- are configurable PEQ-style reconstruction values, not original XP amounts.
-- Source-based faction quantities have later numerical corroboration; exact
-- May2013 amounts and original explore volumes remain unproven.
-- No character, guild, housing, inventory, or saved task-state tables are changed.
SET SESSION check_constraint_checks=1;
DROP TEMPORARY TABLE IF EXISTS _blightfire_guard;
CREATE TEMPORARY TABLE _blightfire_guard(check_name VARCHAR(80) PRIMARY KEY,ok TINYINT NOT NULL,CHECK(ok=1)) ENGINE=InnoDB;
INSERT INTO _blightfire_guard VALUES('task_identity',(NOT EXISTS(SELECT 1 FROM tasks WHERE id IN(3039801,3039802,3039803,3039804,3039805,3039806,3039807,3039808,3039809,3039810,3039811,3039812,3039813,3039814) AND NOT((id=3039801 AND type=2 AND title='Lost Memento') OR (id=3039802 AND type=2 AND title='Experienced Hunters Needed') OR (id=3039803 AND type=2 AND title='Wanted: Intrepid Explorer') OR (id=3039804 AND type=2 AND title='Wanted: Supply Runner') OR (id=3039805 AND type=2 AND title='Ore for Smelting') OR (id=3039806 AND type=2 AND title='Gnollish Tools') OR (id=3039807 AND type=2 AND title='The Mucktail Quarry') OR (id=3039808 AND type=2 AND title='The Mucktail Mines') OR (id=3039809 AND type=2 AND title='Rotwood, The Infected Treants') OR (id=3039810 AND type=2 AND title='Rotwood, The Spore Farms') OR (id=3039811 AND type=2 AND title='Rotwood: Molderahn') OR (id=3039812 AND type=2 AND title='Hardy Seeds') OR (id=3039813 AND type=2 AND title='Kindling for the Fires') OR (id=3039814 AND type=2 AND title='Green Ooze Buds')))));
INSERT INTO _blightfire_guard VALUES('orphan_activities',(NOT EXISTS(SELECT 1 FROM task_activities a LEFT JOIN tasks t ON t.id=a.taskid WHERE a.taskid IN(3039801,3039802,3039803,3039804,3039805,3039806,3039807,3039808,3039809,3039810,3039811,3039812,3039813,3039814) AND t.id IS NULL)));
INSERT INTO _blightfire_guard VALUES('component_identity',((SELECT COUNT(*) FROM achievement_components WHERE component_type=1 AND ((achievement_id=500020500 AND component_id=50060 AND sequence=1 AND name='Moors Sign Post - Lost Memento') OR (achievement_id=500020500 AND component_id=50061 AND sequence=2 AND name='Moors Sign Post - Experienced Hunters Needed') OR (achievement_id=500020500 AND component_id=50062 AND sequence=3 AND name='Moors Sign Post - Wanted: Intrepid Explorer') OR (achievement_id=500020500 AND component_id=50063 AND sequence=4 AND name='Moors Sign Post - Wanted: Supply Runner') OR (achievement_id=500020600 AND component_id=50064 AND sequence=1 AND name='Smithy Bronson - Ore for Smelting') OR (achievement_id=500020600 AND component_id=50065 AND sequence=2 AND name='Smithy Bronson - Gnollish Tools') OR (achievement_id=500020600 AND component_id=50066 AND sequence=3 AND name='Scout Zerak - The Mucktail Quarry') OR (achievement_id=500020600 AND component_id=50067 AND sequence=4 AND name='Scout Zerak - The Mucktail Mines') OR (achievement_id=500020700 AND component_id=50068 AND sequence=1 AND name='Roanoak - Rotwood, The Infected Treants') OR (achievement_id=500020700 AND component_id=50069 AND sequence=2 AND name='Roanoak - Rotwood, The Spore Farms') OR (achievement_id=500020700 AND component_id=50070 AND sequence=3 AND name='Roanoak - Rotwood: Molderahn') OR (achievement_id=500020700 AND component_id=50071 AND sequence=4 AND name='Farmer D`Resh - Hardy Seeds') OR (achievement_id=500020700 AND component_id=50072 AND sequence=5 AND name='Smithy Bronson - Kindling for the Fires') OR (achievement_id=500020700 AND component_id=50073 AND sequence=6 AND name='Fletcher Orshawn - Green Ooze Buds')))=14 AND (SELECT COUNT(*) FROM achievement_components WHERE component_type=1 AND component_id IN(50060,50061,50062,50063,50064,50065,50066,50067,50068,50069,50070,50071,50072,50073))=14));
INSERT INTO _blightfire_guard VALUES('criteria_ownership',(NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE component_type=1 AND component_id IN(50060,50061,50062,50063,50064,50065,50066,50067,50068,50069,50070,50071,50072,50073) AND (NOT((achievement_id=500020500 AND component_id=50060 AND component_sequence=1 AND target_id=3039801) OR (achievement_id=500020500 AND component_id=50061 AND component_sequence=2 AND target_id=3039802) OR (achievement_id=500020500 AND component_id=50062 AND component_sequence=3 AND target_id=3039803) OR (achievement_id=500020500 AND component_id=50063 AND component_sequence=4 AND target_id=3039804) OR (achievement_id=500020600 AND component_id=50064 AND component_sequence=1 AND target_id=3039805) OR (achievement_id=500020600 AND component_id=50065 AND component_sequence=2 AND target_id=3039806) OR (achievement_id=500020600 AND component_id=50066 AND component_sequence=3 AND target_id=3039807) OR (achievement_id=500020600 AND component_id=50067 AND component_sequence=4 AND target_id=3039808) OR (achievement_id=500020700 AND component_id=50068 AND component_sequence=1 AND target_id=3039809) OR (achievement_id=500020700 AND component_id=50069 AND component_sequence=2 AND target_id=3039810) OR (achievement_id=500020700 AND component_id=50070 AND component_sequence=3 AND target_id=3039811) OR (achievement_id=500020700 AND component_id=50071 AND component_sequence=4 AND target_id=3039812) OR (achievement_id=500020700 AND component_id=50072 AND component_sequence=5 AND target_id=3039813) OR (achievement_id=500020700 AND component_id=50073 AND component_sequence=6 AND target_id=3039814)) OR event_type<>4 OR progress_mode<>3 OR behavior<>0 OR target_id2<>0 OR target_value<>0 OR required_count<>1 OR enabled<>1))));
INSERT INTO _blightfire_guard VALUES('native_item_identities',((SELECT COUNT(*) FROM items WHERE (id=85756 AND Name='Anarynn''s Lost Gold Locket') OR (id=53506 AND Name='Blacksmith''s Bubbling Elixir') OR (id=85797 AND Name='Blightfire Bivouac Supplies') OR (id=85746 AND Name='Blightfire Snake Skin') OR (id=85745 AND Name='Bog Rat Pelt') OR (id=53523 AND Name='Elixir of Stalwart Regeneration') OR (id=53507 AND Name='Gnoll Hunter''s Cloak') OR (id=85758 AND Name='Green Ooze Bud') OR (id=53508 AND Name='Hammer of the Gnoll Slayer') OR (id=36197 AND Name='Hedge Devil Branch') OR (id=36193 AND Name='Hunk of Blightfire Ore') OR (id=36162 AND Name='Mucktail Mining Pick') OR (id=53509 AND Name='Ore Hauler''s Haversack') OR (id=53518 AND Name='Potion of Recovery') OR (id=85743 AND Name='Rock Breaker Hammer') OR (id=85752 AND Name='Rotwood Spore') OR (id=85744 AND Name='Scar''s Shattered Shield') OR (id=54656 AND Name='Seed Pod') OR (id=53533 AND Name='Treantwood Staff'))=19));
INSERT INTO _blightfire_guard VALUES('native_npc_identities',((SELECT COUNT(*) FROM npc_types WHERE (id=394004 AND name='#Anarynn') OR (id=394091 AND name='#Smithy_Bronson') OR (id=394154 AND name='Farmer_D`Resh') OR (id=395002 AND name='Moors_Sign_Post') OR (id=395008 AND name='a_Mucktail_rock_breaker') OR (id=395013 AND name='a_Mucktail_rock_breaker') OR (id=395017 AND name='a_Mucktail_rock_breaker') OR (id=395018 AND name='a_Mucktail_rock_breaker') OR (id=395021 AND name='a_Mucktail_rock_breaker') OR (id=395022 AND name='a_Mucktail_rock_breaker') OR (id=395023 AND name='a_Mucktail_miner') OR (id=395024 AND name='a_Mucktail_rock_breaker') OR (id=395025 AND name='a_Mucktail_miner') OR (id=395027 AND name='a_Mucktail_miner') OR (id=395032 AND name='a_Mucktail_rock_breaker') OR (id=395036 AND name='a_Mucktail_miner') OR (id=395037 AND name='a_Mucktail_miner') OR (id=395038 AND name='a_Mucktail_miner') OR (id=395042 AND name='a_Mucktail_miner') OR (id=395046 AND name='#Pit_Boss_Scar') OR (id=395049 AND name='a_Mucktail_rock_breaker') OR (id=395052 AND name='Scout_Zerak') OR (id=395057 AND name='a_rotwood_sapling') OR (id=395061 AND name='a_rotwood_sapling') OR (id=395070 AND name='#Ambassador_Orren') OR (id=395077 AND name='a_rotwood_sapling') OR (id=395079 AND name='#Roanoak') OR (id=395088 AND name='a_rotwood_treant') OR (id=395089 AND name='a_sporali_farmer') OR (id=395096 AND name='a_sporali_elder') OR (id=395097 AND name='a_sporali_farmer') OR (id=395098 AND name='a_sporali_warrior') OR (id=395111 AND name='a_sporali_warrior') OR (id=395113 AND name='a_sporali_warrior') OR (id=395115 AND name='a_sporali_farmer') OR (id=395118 AND name='#Ozzana_the_Trapper') OR (id=395120 AND name='Moors_Sign_Post') OR (id=395121 AND name='a_sporali_elder') OR (id=395126 AND name='a_sporali_elder') OR (id=395128 AND name='Scout_Captain_Slynn') OR (id=395137 AND name='#Molderahn') OR (id=395144 AND name='#Fletcher_Orshawn') OR (id=395146 AND name='a_rotwood_treant') OR (id=395147 AND name='a_rotwood_treant') OR (id=395149 AND name='a_hedge_devil') OR (id=395150 AND name='a_hedge_devil') OR (id=395151 AND name='a_hedge_devil') OR (id=395152 AND name='a_hedge_devil') OR (id=395155 AND name='a_hedge_devil') OR (id=395215 AND name='Cook_Idriak') OR (id=395277 AND name='a_hedge_devil') OR (id=395278 AND name='a_hedge_devil') OR (id=395280 AND name='a_hedge_devil'))=53));
INSERT INTO _blightfire_guard VALUES('shield_drop_identity',((SELECT COUNT(*) FROM lootdrop_entries WHERE lootdrop_id=120970)=1 AND (SELECT COUNT(*) FROM lootdrop_entries WHERE lootdrop_id=120970 AND item_id=85744 AND item_charges=1 AND chance=100 AND multiplier IN(1,3))=1));
INSERT INTO _blightfire_guard VALUES('shield_drop_owner',((SELECT COUNT(*) FROM loottable_entries WHERE lootdrop_id=120970)=1 AND (SELECT COUNT(*) FROM loottable_entries WHERE lootdrop_id=120970 AND loottable_id=96777 AND multiplier=1 AND probability=100)=1 AND (SELECT COUNT(*) FROM npc_types WHERE loottable_id=96777)=1 AND (SELECT COUNT(*) FROM npc_types WHERE id=395046 AND loottable_id=96777)=1));
INSERT INTO _blightfire_guard VALUES('faction_list_30398001',(NOT EXISTS(SELECT 1 FROM npc_faction WHERE id=30398001 AND (name<>'Blightfire quest: Rotwood initial factions' OR primaryfaction<>0 OR ignore_primary_assist<>0)) AND NOT EXISTS(SELECT 1 FROM npc_types WHERE npc_faction_id=30398001)));
INSERT INTO _blightfire_guard VALUES('faction_task_owner_30398001',(NOT EXISTS(SELECT 1 FROM tasks WHERE faction_reward=30398001 AND id NOT IN(3039801,3039802,3039803,3039804,3039805,3039806,3039807,3039808,3039809,3039810,3039811,3039812,3039813,3039814))));
INSERT INTO _blightfire_guard VALUES('faction_entries_30398001',(NOT EXISTS(SELECT 1 FROM npc_faction_entries WHERE npc_faction_id=30398001 AND NOT((faction_id=1110 AND value=10 AND npc_value=0 AND temp=0) OR (faction_id=1109 AND value=10 AND npc_value=0 AND temp=0) OR (faction_id=1111 AND value=-10 AND npc_value=0 AND temp=0)))));
INSERT INTO _blightfire_guard VALUES('faction_list_30398002',(NOT EXISTS(SELECT 1 FROM npc_faction WHERE id=30398002 AND (name<>'Blightfire quest: Rotwood final factions' OR primaryfaction<>0 OR ignore_primary_assist<>0)) AND NOT EXISTS(SELECT 1 FROM npc_types WHERE npc_faction_id=30398002)));
INSERT INTO _blightfire_guard VALUES('faction_task_owner_30398002',(NOT EXISTS(SELECT 1 FROM tasks WHERE faction_reward=30398002 AND id NOT IN(3039801,3039802,3039803,3039804,3039805,3039806,3039807,3039808,3039809,3039810,3039811,3039812,3039813,3039814))));
INSERT INTO _blightfire_guard VALUES('faction_entries_30398002',(NOT EXISTS(SELECT 1 FROM npc_faction_entries WHERE npc_faction_id=30398002 AND NOT((faction_id=1110 AND value=20 AND npc_value=0 AND temp=0) OR (faction_id=1109 AND value=20 AND npc_value=0 AND temp=0) OR (faction_id=1111 AND value=-20 AND npc_value=0 AND temp=0)))));
START TRANSACTION;
INSERT INTO tasks (id,type,title,description,reward_text,reward_id_list,cash_reward,exp_reward,reward_method,min_level,repeatable,faction_reward,faction_amount,enabled) VALUES
(3039801,2,'Lost Memento','Complete the objectives listed below. See the release provenance for reconstructed settings.','','',0,1000,0,15,1,0,0,1),
(3039802,2,'Experienced Hunters Needed','Complete the objectives listed below. See the release provenance for reconstructed settings.','','',0,1000,0,15,1,0,0,1),
(3039803,2,'Wanted: Intrepid Explorer','Complete the objectives listed below. See the release provenance for reconstructed settings.','','',5000,1000,0,20,0,1129,10,1),
(3039804,2,'Wanted: Supply Runner','Complete the objectives listed below. See the release provenance for reconstructed settings.','','',9000,1000,0,30,0,1129,10,1),
(3039805,2,'Ore for Smelting','Complete the objectives listed below. See the release provenance for reconstructed settings.','','53506,10',0,0,0,20,0,0,0,1),
(3039806,2,'Gnollish Tools','Complete the objectives listed below. See the release provenance for reconstructed settings.','','53509,1',0,1000,0,15,1,0,0,1),
(3039807,2,'The Mucktail Quarry','Complete the objectives listed below. See the release provenance for reconstructed settings.','','53507,1',0,1000,0,18,1,1129,10,1),
(3039808,2,'The Mucktail Mines','Complete the objectives listed below. See the release provenance for reconstructed settings.','','53508,1',0,1000,0,18,0,1129,20,1),
(3039809,2,'Rotwood, The Infected Treants','Complete the objectives listed below. See the release provenance for reconstructed settings.','','',0,1000,0,20,1,30398001,0,1),
(3039810,2,'Rotwood, The Spore Farms','Complete the objectives listed below. See the release provenance for reconstructed settings.','','',0,1000,0,20,1,30398001,0,1),
(3039811,2,'Rotwood: Molderahn','Complete the objectives listed below. See the release provenance for reconstructed settings.','','53533,1',0,1000,0,20,1,30398002,0,1),
(3039812,2,'Hardy Seeds','Complete the objectives listed below. See the release provenance for reconstructed settings.','','53518,10',0,1000,0,15,1,0,0,1),
(3039813,2,'Kindling for the Fires','Complete the objectives listed below. See the release provenance for reconstructed settings.','','',0,1000,0,25,0,0,0,1),
(3039814,2,'Green Ooze Buds','Complete the objectives listed below. See the release provenance for reconstructed settings.','','53523,10',0,1000,0,30,1,0,0,1)
ON DUPLICATE KEY UPDATE type=VALUES(type),title=VALUES(title),description=VALUES(description),reward_text=VALUES(reward_text),reward_id_list=VALUES(reward_id_list),cash_reward=VALUES(cash_reward),exp_reward=VALUES(exp_reward),reward_method=VALUES(reward_method),min_level=VALUES(min_level),repeatable=VALUES(repeatable),faction_reward=VALUES(faction_reward),faction_amount=VALUES(faction_amount),enabled=VALUES(enabled);
DELETE FROM task_activities WHERE taskid IN(3039801,3039802,3039803,3039804,3039805,3039806,3039807,3039808,3039809,3039810,3039811,3039812,3039813,3039814);
INSERT INTO task_activities (taskid,activityid,req_activity_id,step,activitytype,target_name,goalmethod,goalcount,description_override,npc_match_list,item_id_list,zones,spell_list,min_x,max_x,min_y,max_y,min_z,max_z) VALUES
(3039801,0,-1,1,1,'',0,1,'Deliver Anarynn''s Lost Gold Locket','394004','85756','394','',0,0,0,0,0,0),
(3039802,0,-1,1,1,'',0,4,'Deliver Bog Rat Pelt','395118','85745','395','',0,0,0,0,0,0),
(3039802,1,-1,1,1,'',0,4,'Deliver Blightfire Snake Skin','395118','85746','395','',0,0,0,0,0,0),
(3039803,0,-1,1,5,'',0,1,'Explore Ogre Stomp','','','395','',-2150,-1850,1700,2000,-5000,5000),
(3039803,1,-1,1,5,'',0,1,'Explore Roanoak''s Grove','','','395','',1050,1350,250,550,-5000,5000),
(3039803,2,-1,1,5,'',0,1,'Explore Sporali Farms','','','395','',1590,1890,1665,1965,-5000,5000),
(3039803,3,-1,1,5,'',0,1,'Explore Ghostpack Woods','','','395','',-3010,-2710,1425,1725,-5000,5000),
(3039803,4,-1,2,4,'',0,1,'Speak Scout Captain Slynn','395128','','395','',0,0,0,0,0,0),
(3039804,0,-1,1,4,'',0,1,'Speak Scout Captain Slynn','395128','','395','',0,0,0,0,0,0),
(3039804,1,-1,2,1,'',0,1,'Deliver Blightfire Bivouac Supplies','395215','85797','395','',0,0,0,0,0,0),
(3039805,0,-1,1,5,'',0,1,'Enter zone moors','','','395','',0,0,0,0,0,0),
(3039805,1,-1,2,2,'',0,10,'Kill Mucktail rock breakers/miners','395008|395013|395017|395018|395021|395022|395023|395024|395025|395027|395032|395036|395037|395038|395042|395049','','395','',0,0,0,0,0,0),
(3039805,2,-1,2,3,'',0,4,'Loot Hunk of Blightfire Ore','','36193','395','',0,0,0,0,0,0),
(3039805,3,-1,3,1,'',0,4,'Deliver Hunk of Blightfire Ore','394091','36193','394','',0,0,0,0,0,0),
(3039806,0,-1,1,5,'',0,1,'Enter zone moors','','','395','',0,0,0,0,0,0),
(3039806,1,-1,2,3,'',0,4,'Loot Rock Breaker Hammer','','85743','395','',0,0,0,0,0,0),
(3039806,2,-1,2,3,'',0,4,'Loot Mucktail Mining Pick','','36162','395','',0,0,0,0,0,0),
(3039806,3,-1,3,1,'',0,4,'Deliver Rock Breaker Hammer','394091','85743','394','',0,0,0,0,0,0),
(3039806,4,-1,3,1,'',0,4,'Deliver Mucktail Mining Pick','394091','36162','394','',0,0,0,0,0,0),
(3039807,0,-1,1,2,'',0,10,'Kill a Mucktail rock breaker','395008|395013|395017|395018|395021|395022|395024|395032|395049','','395','',0,0,0,0,0,0),
(3039807,1,-1,1,3,'',0,4,'Loot Rock Breaker Hammer','','85743','395','',0,0,0,0,0,0),
(3039807,2,-1,2,1,'',0,4,'Deliver Rock Breaker Hammer','395052','85743','395','',0,0,0,0,0,0),
(3039808,0,-1,1,2,'',0,10,'Kill a Mucktail miner','395023|395025|395027|395036|395037|395038|395042','','395','',0,0,0,0,0,0),
(3039808,1,-1,2,4,'',0,1,'Speak Ambassador Orren','395070','','395','',0,0,0,0,0,0),
(3039808,2,-1,3,2,'',0,1,'Kill Pit Boss Scar','395046','','395','',0,0,0,0,0,0),
(3039808,3,-1,3,3,'',0,1,'Loot Scar''s Shattered Shield','','85744','395','',0,0,0,0,0,0),
(3039808,4,-1,4,1,'',0,1,'Deliver Scar''s Shattered Shield','395052','85744','395','',0,0,0,0,0,0),
(3039809,0,-1,1,2,'',0,12,'Kill Rotwood Saplings','395057|395061|395077','','395','',0,0,0,0,0,0),
(3039809,1,-1,1,2,'',0,4,'Kill Rotwood Treants','395088|395146|395147','','395','',0,0,0,0,0,0),
(3039809,2,-1,2,4,'',0,1,'Speak Roanoak','395079','','395','',0,0,0,0,0,0),
(3039810,0,-1,1,2,'',0,15,'Kill Sporali Farmers','395089|395097|395115','','395','',0,0,0,0,0,0),
(3039810,1,-1,1,3,'',0,4,'Loot Rotwood Spore','','85752','395','',0,0,0,0,0,0),
(3039810,2,-1,2,1,'',0,4,'Deliver Rotwood Spore','395079','85752','395','',0,0,0,0,0,0),
(3039811,0,-1,1,2,'',0,3,'Kill Sporali Warriors','395098|395111|395113','','395','',0,0,0,0,0,0),
(3039811,1,-1,1,2,'',0,3,'Kill Sporali Elders','395096|395121|395126','','395','',0,0,0,0,0,0),
(3039811,2,-1,2,2,'',0,1,'Kill Molderahn','395137','','395','',0,0,0,0,0,0),
(3039811,3,-1,3,4,'',0,1,'Speak Roanoak','395079','','395','',0,0,0,0,0,0),
(3039812,0,-1,1,3,'',0,4,'Loot Seed Pod','','54656','395','',0,0,0,0,0,0),
(3039812,1,-1,2,1,'',0,4,'Deliver Seed Pod','394154','54656','394','',0,0,0,0,0,0),
(3039813,0,-1,1,5,'',0,1,'Enter zone moors','','','395','',0,0,0,0,0,0),
(3039813,1,-1,2,2,'',0,10,'Kill hedge devils','395149|395150|395151|395152|395155|395277|395278|395280','','395','',0,0,0,0,0,0),
(3039813,2,-1,2,3,'',0,4,'Loot Hedge Devil Branch','','36197','395','',0,0,0,0,0,0),
(3039813,3,-1,3,1,'',0,4,'Deliver Hedge Devil Branch','394091','36197','394','',0,0,0,0,0,0),
(3039814,0,-1,1,1,'',0,4,'Deliver Green Ooze Bud','395144','85758','395','',0,0,0,0,0,0);
DELETE FROM achievement_criteria WHERE component_type=1 AND component_id IN(50060,50061,50062,50063,50064,50065,50066,50067,50068,50069,50070,50071,50072,50073);
INSERT INTO achievement_criteria (achievement_id,component_type,component_sequence,component_id,event_type,progress_mode,behavior,target_id,target_id2,target_value,required_count,enabled) VALUES
(500020500,1,1,50060,4,3,0,3039801,0,0,1,1),
(500020500,1,2,50061,4,3,0,3039802,0,0,1,1),
(500020500,1,3,50062,4,3,0,3039803,0,0,1,1),
(500020500,1,4,50063,4,3,0,3039804,0,0,1,1),
(500020600,1,1,50064,4,3,0,3039805,0,0,1,1),
(500020600,1,2,50065,4,3,0,3039806,0,0,1,1),
(500020600,1,3,50066,4,3,0,3039807,0,0,1,1),
(500020600,1,4,50067,4,3,0,3039808,0,0,1,1),
(500020700,1,1,50068,4,3,0,3039809,0,0,1,1),
(500020700,1,2,50069,4,3,0,3039810,0,0,1,1),
(500020700,1,3,50070,4,3,0,3039811,0,0,1,1),
(500020700,1,4,50071,4,3,0,3039812,0,0,1,1),
(500020700,1,5,50072,4,3,0,3039813,0,0,1,1),
(500020700,1,6,50073,4,3,0,3039814,0,0,1,1);
INSERT INTO npc_faction (id,name,primaryfaction,ignore_primary_assist) VALUES
(30398001,'Blightfire quest: Rotwood initial factions',0,0)
ON DUPLICATE KEY UPDATE name=VALUES(name),primaryfaction=VALUES(primaryfaction),ignore_primary_assist=VALUES(ignore_primary_assist);
INSERT INTO npc_faction_entries (npc_faction_id,faction_id,value,npc_value,temp) VALUES
(30398001,1110,10,0,0)
ON DUPLICATE KEY UPDATE value=VALUES(value),npc_value=VALUES(npc_value),temp=VALUES(temp);
INSERT INTO npc_faction_entries (npc_faction_id,faction_id,value,npc_value,temp) VALUES
(30398001,1109,10,0,0)
ON DUPLICATE KEY UPDATE value=VALUES(value),npc_value=VALUES(npc_value),temp=VALUES(temp);
INSERT INTO npc_faction_entries (npc_faction_id,faction_id,value,npc_value,temp) VALUES
(30398001,1111,-10,0,0)
ON DUPLICATE KEY UPDATE value=VALUES(value),npc_value=VALUES(npc_value),temp=VALUES(temp);
INSERT INTO npc_faction (id,name,primaryfaction,ignore_primary_assist) VALUES
(30398002,'Blightfire quest: Rotwood final factions',0,0)
ON DUPLICATE KEY UPDATE name=VALUES(name),primaryfaction=VALUES(primaryfaction),ignore_primary_assist=VALUES(ignore_primary_assist);
INSERT INTO npc_faction_entries (npc_faction_id,faction_id,value,npc_value,temp) VALUES
(30398002,1110,20,0,0)
ON DUPLICATE KEY UPDATE value=VALUES(value),npc_value=VALUES(npc_value),temp=VALUES(temp);
INSERT INTO npc_faction_entries (npc_faction_id,faction_id,value,npc_value,temp) VALUES
(30398002,1109,20,0,0)
ON DUPLICATE KEY UPDATE value=VALUES(value),npc_value=VALUES(npc_value),temp=VALUES(temp);
INSERT INTO npc_faction_entries (npc_faction_id,faction_id,value,npc_value,temp) VALUES
(30398002,1111,-20,0,0)
ON DUPLICATE KEY UPDATE value=VALUES(value),npc_value=VALUES(npc_value),temp=VALUES(temp);
--2011-revised archived Mines guide: Scar drops three separate shield copies.
UPDATE lootdrop_entries SET multiplier=3 WHERE lootdrop_id=120970 AND item_id=85744;
COMMIT;
