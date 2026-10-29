-- Fail-closed MariaDB10.2.1+ guards; run without --force. All guards precede persistent writes.
-- No character state. Deployment and native acceptance remain separate.
SET SESSION check_constraint_checks=1;
DROP TEMPORARY TABLE IF EXISTS _crescent_baker_guard;
CREATE TEMPORARY TABLE _crescent_baker_guard (
 check_name VARCHAR(80) NOT NULL PRIMARY KEY,
 ok TINYINT NOT NULL,
 CONSTRAINT crescent_baker_guard_ok CHECK(ok=1)
) ENGINE=InnoDB;
INSERT INTO _crescent_baker_guard VALUES ('task_identity',
 NOT EXISTS(SELECT 1 FROM tasks WHERE id IN(3039701,3039702) AND
  (type<>2 OR title<>CASE id WHEN 3039701 THEN 'Slightly Less Than One-Half of a Baker''s Dozen' ELSE 'Party Preparation' END)));
INSERT INTO _crescent_baker_guard VALUES ('component_identity',
 (SELECT COUNT(*) FROM achievement_components WHERE achievement_id=500010400 AND component_type=1 AND
  ((component_id=50024 AND sequence=4 AND name='Baker Shivra - Slightly Less Than One-Half of a Baker''s Dozen') OR
   (component_id=50025 AND sequence=5 AND name='Baker Shivra - Party Preparation')))=2 AND
 (SELECT COUNT(*) FROM achievement_components WHERE achievement_id=500010400 AND component_type=1 AND component_id IN(50024,50025))=2);
INSERT INTO _crescent_baker_guard VALUES ('criteria_identity',
 NOT EXISTS(SELECT 1 FROM achievement_criteria WHERE achievement_id=500010400 AND component_type=1 AND component_id IN(50024,50025) AND
  (component_sequence<>CASE component_id WHEN 50024 THEN 4 ELSE 5 END OR event_type<>4 OR progress_mode<>3 OR behavior<>0 OR
   target_id<>CASE component_id WHEN 50024 THEN 3039701 ELSE 3039702 END OR target_id2<>0 OR target_value<>0 OR required_count<>1 OR enabled<>1)));
INSERT INTO _crescent_baker_guard VALUES ('baker_identity',
 (SELECT COUNT(*) FROM npc_types WHERE id=394178 AND name='Baker_Shivra')=1);
INSERT INTO _crescent_baker_guard VALUES ('item_identities',
 (SELECT COUNT(*) FROM items WHERE (id=52637 AND Name='Tasty Truffles')OR(id=52638 AND Name='Fizzy Lemonade')OR
  (id=53487 AND Name='Pocket Flan Dessert')OR(id=53488 AND Name='Shivra''s Fizzy Lemonade'))=4);
INSERT INTO _crescent_baker_guard VALUES ('lootdrop_identity',
 NOT EXISTS(SELECT 1 FROM lootdrop WHERE id=30397001 AND name<>'Crescent Baker: Tasty Truffles'));
INSERT INTO _crescent_baker_guard VALUES ('lootdrop_item',
 NOT EXISTS(SELECT 1 FROM lootdrop_entries WHERE lootdrop_id=30397001 AND
  (item_id<>52637 OR COALESCE(item_charges,-1)<>1 OR COALESCE(equip_item,0)<>0 OR (COALESCE(chance,-1)<=0 OR COALESCE(chance,-1)>100) OR COALESCE(multiplier,-1)<>1)) AND
 (SELECT COUNT(*) FROM lootdrop_entries WHERE lootdrop_id=30397001)<=1);
INSERT INTO _crescent_baker_guard VALUES ('lootdrop_owner',
 NOT EXISTS(SELECT 1 FROM loottable_entries WHERE lootdrop_id=30397001 AND
  (loottable_id<>90171 OR COALESCE(multiplier,-1)<>1 OR COALESCE(droplimit,0)<>0 OR COALESCE(mindrop,0)<>0 OR COALESCE(probability,-1)<>100)));
INSERT INTO _crescent_baker_guard VALUES ('mushroom_owners',
 (SELECT COUNT(*) FROM npc_types WHERE id IN(394014,394049) AND loottable_id=90171)=2 AND
 NOT EXISTS(SELECT 1 FROM npc_types WHERE loottable_id=90171 AND id NOT IN(394014,394049)));
INSERT INTO _crescent_baker_guard VALUES ('existing_crate_identity',
 (SELECT COUNT(*) FROM npc_types WHERE id=394093 AND name='a_crate_of_lemonade' AND loottable_id=90147)=1 AND
 (SELECT COUNT(*) FROM loottable_entries WHERE loottable_id=90147 AND lootdrop_id=90269 AND multiplier=1 AND probability=100)=1 AND
 (SELECT COUNT(*) FROM lootdrop_entries WHERE lootdrop_id=90269 AND item_id=52638 AND item_charges=1 AND chance=100 AND multiplier=1)=1);
START TRANSACTION;
INSERT INTO tasks (id,type,title,description,reward_text,reward_id_list,cash_reward,exp_reward,reward_method,min_level,repeatable,enabled) VALUES
(3039701,2,'Slightly Less Than One-Half of a Baker''s Dozen','Collect six Tasty Truffles from the mushroom grove, then deliver them to Baker Shivra.','Five Pocket Flan Desserts and experience','53487,5',0,@XP@,0,5,1,1),
(3039702,2,'Party Preparation','Find the missing Fizzy Lemonade in the puma cave and deliver it to Baker Shivra.','Five bottles of Shivra lemonade and experience','53488,5',0,@XP@,0,5,1,1)
ON DUPLICATE KEY UPDATE type=VALUES(type),title=VALUES(title),description=VALUES(description),reward_text=VALUES(reward_text),reward_id_list=VALUES(reward_id_list),cash_reward=VALUES(cash_reward),exp_reward=VALUES(exp_reward),reward_method=VALUES(reward_method),min_level=VALUES(min_level),repeatable=VALUES(repeatable),enabled=VALUES(enabled);
DELETE FROM task_activities WHERE taskid IN(3039701,3039702);
INSERT INTO task_activities (taskid,activityid,req_activity_id,step,activitytype,target_name,goalmethod,goalcount,description_override,npc_match_list,item_id_list,zones,spell_list) VALUES
(3039701,0,-1,1,3,'',0,6,'Collect six Tasty Truffles from the mushroom grove.','','52637','394',''),
(3039701,1,-1,2,1,'',0,6,'Deliver six Tasty Truffles to Baker Shivra.','394178','52637','394',''),
(3039702,0,-1,1,3,'',0,1,'Find the missing Fizzy Lemonade in the puma cave.','','52638','394',''),
(3039702,1,-1,2,1,'',0,1,'Deliver the Fizzy Lemonade to Baker Shivra.','394178','52638','394','');
DELETE FROM achievement_criteria WHERE achievement_id=500010400 AND component_type=1 AND component_id IN(50024,50025);
INSERT INTO achievement_criteria (achievement_id,component_type,component_sequence,component_id,event_type,progress_mode,behavior,target_id,target_id2,target_value,required_count,enabled)
SELECT achievement_id,1,sequence,component_id,4,3,0,CASE component_id WHEN 50024 THEN 3039701 ELSE 3039702 END,0,0,1,1 FROM achievement_components WHERE achievement_id=500010400 AND component_type=1 AND component_id IN(50024,50025);
-- Acquisition restoration: only two existing verified mushroom NPCs use loottable90171.
-- The50percent chance is a labelled configurable reconstruction default, NOT original drop proof.
INSERT INTO lootdrop (id,name) VALUES(30397001,'Crescent Baker: Tasty Truffles') ON DUPLICATE KEY UPDATE name=VALUES(name);
DELETE FROM lootdrop_entries WHERE lootdrop_id=30397001;
INSERT INTO lootdrop_entries (lootdrop_id,item_id,item_charges,equip_item,chance,multiplier) VALUES(30397001,52637,1,0,@DROP@,1);
DELETE FROM loottable_entries WHERE loottable_id=90171 AND lootdrop_id=30397001;
INSERT INTO loottable_entries (loottable_id,lootdrop_id,multiplier,droplimit,mindrop,probability) VALUES(90171,30397001,1,0,0,100);
-- Existing lemonade crate394093, spawn77023 and90147->90269->52638 remain unchanged.
COMMIT;
