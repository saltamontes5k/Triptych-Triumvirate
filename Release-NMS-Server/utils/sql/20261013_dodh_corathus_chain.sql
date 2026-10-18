-- v154: DoDH Corathus chain completion.
--   1) Scavenger Hunting (task 505762, Treddlehoop #365284, Corathus Creep):
--      loot 1x Shiliskin Tentacle Cluster (88002), 1x Drachnid Silk Gland
--      (88003), 2x Chopping Sword (88004), deliver all to Treddlehoop.
--      Reward Treddlehoop's Signature Monocle (88001), paid by Lua
--      (corathus/#Treddlehoop.lua, bucket-guarded). All three items already
--      drop in PEQ MAGELO-GEN loottables (Illsalin shiliskin, drachnids,
--      Stoneroot Deep orcs); nothing referenced 88001 before this.
--   2) Parts for Bellfast caster/research variant (task 505763) for
--      ENC/MAG/NEC/WIZ (#Bellfast.lua class-gates the assignment). Casters
--      buy the Spell Research Kit (93492, already on CGXIV's merchantlist),
--      combine the ten Mechanoinstruction Scraps into three Tattered
--      Mechanoinstructions, deliver them for Pages 2-4, deliver 5 pinions +
--      2 gears for Page 5, and combine the five pages (recipe 938039) into
--      Scrindite's Mechanoinstruction Manual (33295) themselves. Page 1 is
--      granted on task accept by the script. Completing either variant
--      unlocks 505756-505759.
--   3) Recipe repair so the three research combines work live-accurately:
--      PEQ shipped 938046/938047 both making 33296 from 3x the SAME scrap
--      (32731), and 33297/33298 had no recipes at all. Rewritten per the
--      scraps' lore words: 938046 Mechanotabiet = scraps 32731-33 -> 33296,
--      938047 Configuration = scraps 32734-37 -> 33297, new 938048
--      Advisorybook = scraps 32738-40 -> 33298. 938039 (5 pages -> 33295)
--      was already correct and is untouched.
-- Twin content of manifest entry '20261013_dodh_corathus_chain' (v154) in
-- common/database/database_update_manifest_custom.cpp (keep in sync).
-- Rollback = utils/sql/20261013_dodh_corathus_chain_rollback.sql.

-- ---------------------------------------------------------------------------
-- Tasks
-- ---------------------------------------------------------------------------

INSERT INTO `tasks`
  (`id`,`type`,`duration`,`duration_code`,`title`,`description`,`reward_text`,
   `cash_reward`,`exp_reward`,`reward_method`,`min_level`,`max_level`,
   `repeatable`,`enabled`)
VALUES
  (505762, 2, 21600, 0, 'Scavenger Hunting',
   'Treddlehoop survived the wreck of Expedition 328 and collects curiosities from the Deep. Gather a Shiliskin Tentacle Cluster from Illsalin, a Drachnid Silk Gland from the drachnids, and two Chopping Swords off the Deep orcs of Stoneroot Falls, and bring them to him in the Creep.',
   'Treddlehoop''s Signature Monocle', 0, 0, 2, 0, 0, 0, 1),
  (505763, 2, 0, 0, 'Parts for Bellfast',
   'Bellfast repairs the clockworks of Expedition 328. Research-minded folk restore Scrindite''s Mechanoinstruction Manual the scholar''s way: buy a Spell Research Kit from Merchant Model CGXIV, combine the Mechanoinstruction Scraps into Tattered Mechanoinstructions, and trade them to Bellfast for the missing manual pages.',
   'Scrindite''s Mechanoinstruction Manual', 0, 0, 2, 0, 0, 0, 1);

-- ---------------------------------------------------------------------------
-- Task activities. Column usage mirrors the shipped 505755 rows:
-- deliver/loot items live in item_id_list, NPC ids in npc_match_list.
-- ---------------------------------------------------------------------------

INSERT INTO `task_activities`
  (`taskid`,`activityid`,`req_activity_id`,`step`,`activitytype`,`target_name`,
   `goalmethod`,`goalcount`,`description_override`,`npc_match_list`,
   `item_id_list`,`item_list`,`dz_switch_id`,
   `min_x`,`min_y`,`min_z`,`max_x`,`max_y`,`max_z`,
   `skill_list`,`spell_list`,`zones`,`zone_version`,`optional`,`list_group`)
VALUES
  -- 505762 Scavenger Hunting: 3 loot + 3 deliver
  (505762,0,-1,1,3,'',0,1,'Loot 1 Shiliskin Tentacle Cluster from the depths of Illsalin','','88002','','',0,0,0,0,0,0,0,'0','',-1,0,0),
  (505762,1,-1,2,3,'',0,1,'Loot 1 Drachnid Silk Gland from the drachnids of the Creep and the Hive','','88003','','',0,0,0,0,0,0,0,'0','',-1,0,0),
  (505762,2,-1,3,3,'',0,2,'Loot 2 Chopping Swords from the Deep orcs of Stoneroot Falls','','88004','','',0,0,0,0,0,0,0,'0','',-1,0,0),
  (505762,3,-1,4,1,'',0,1,'Deliver 1 Shiliskin Tentacle Cluster to Treddlehoop','365284','88002','','',0,0,0,0,0,0,0,'0','',-1,0,0),
  (505762,4,-1,5,1,'',0,1,'Deliver 1 Drachnid Silk Gland to Treddlehoop','365284','88003','','',0,0,0,0,0,0,0,'0','',-1,0,0),
  (505762,5,-1,6,1,'',0,2,'Deliver 2 Chopping Swords to Treddlehoop','365284','88004','','',0,0,0,0,0,0,0,'0','',-1,0,0),
  -- 505763 Parts for Bellfast (research variant): find, report,
  -- create/deliver 3 tattered, loot/deliver pinions + gears, combine manual
  (505763,0,-1,1,4,'',0,1,'Find Merchant Model CGXIV at the camp of Expedition 328 and buy a Spell Research Kit','365276','','','',0,0,0,0,0,0,0,'0','',-1,0,0),
  (505763,1,-1,2,4,'',0,1,'Report back to Bellfast','365286','','','',0,0,0,0,0,0,0,'0','',-1,0,0),
  (505763,2,-1,3,6,'',0,1,'Use spell research to combine the first three Mechanoinstruction Scraps into a Tattered Mechanoinstruction','','33296','','',0,0,0,0,0,0,0,'0','',-1,0,0),
  (505763,3,-1,3,1,'',0,1,'Deliver the Tattered Mechanoinstruction to Bellfast for the second page of Scrindite''s manual','365286','33296','','',0,0,0,0,0,0,0,'0','',-1,0,0),
  (505763,4,-1,4,6,'',0,1,'Use spell research to combine the next four Mechanoinstruction Scraps into a Tattered Mechanoinstruction','','33297','','',0,0,0,0,0,0,0,'0','',-1,0,0),
  (505763,5,-1,4,1,'',0,1,'Deliver the Tattered Mechanoinstruction to Bellfast for the third page of Scrindite''s manual','365286','33297','','',0,0,0,0,0,0,0,'0','',-1,0,0),
  (505763,6,-1,5,6,'',0,1,'Use spell research to combine the last three Mechanoinstruction Scraps into a Tattered Mechanoinstruction','','33298','','',0,0,0,0,0,0,0,'0','',-1,0,0),
  (505763,7,-1,5,1,'',0,1,'Deliver the Tattered Mechanoinstruction to Bellfast for the fourth page of Scrindite''s manual','365286','33298','','',0,0,0,0,0,0,0,'0','',-1,0,0),
  (505763,8,-1,6,3,'',0,5,'Loot 5 Clockwork Pinion Gears','','32684','','',0,0,0,0,0,0,0,'0','',-1,0,0),
  (505763,9,-1,7,3,'',0,2,'Loot 2 Clockwork Gears','','32683','','',0,0,0,0,0,0,0,'0','',-1,0,0),
  (505763,10,-1,8,1,'',0,5,'Deliver 5 Clockwork Pinion Gears to Bellfast','365286','32684','','',0,0,0,0,0,0,0,'0','',-1,0,0),
  (505763,11,-1,8,1,'',0,2,'Deliver 2 Clockwork Gears to Bellfast for the fifth page of Scrindite''s manual','365286','32683','','',0,0,0,0,0,0,0,'0','',-1,0,0),
  (505763,12,-1,9,6,'',0,1,'Combine Scrindite''s five Manual Pages with spell research into the finished Mechanoinstruction Manual','','33295','','',0,0,0,0,0,0,0,'0','',-1,0,0);

-- ---------------------------------------------------------------------------
-- Recipe repair (see header). DELETE+INSERT keeps this idempotent.
-- ---------------------------------------------------------------------------

DELETE FROM `tradeskill_recipe_entries` WHERE `recipe_id` IN (938046, 938047);

-- 938046 "Mechanotabiet": scraps 32731-33 -> Tattered Mechanoinstruction 33296
INSERT INTO `tradeskill_recipe_entries`
  (`recipe_id`,`item_id`,`successcount`,`failcount`,`componentcount`,`salvagecount`,`iscontainer`)
VALUES
  (938046, 32731, 0, 0, 1, 0, 0),
  (938046, 32732, 0, 0, 1, 0, 0),
  (938046, 32733, 0, 0, 1, 0, 0),
  (938046, 33296, 1, 0, 0, 0, 0);

-- 938047 "Configuration": scraps 32734-37 -> Tattered Mechanoinstruction 33297
INSERT INTO `tradeskill_recipe_entries`
  (`recipe_id`,`item_id`,`successcount`,`failcount`,`componentcount`,`salvagecount`,`iscontainer`)
VALUES
  (938047, 32734, 0, 0, 1, 0, 0),
  (938047, 32735, 0, 0, 1, 0, 0),
  (938047, 32736, 0, 0, 1, 0, 0),
  (938047, 32737, 0, 0, 1, 0, 0),
  (938047, 33297, 1, 0, 0, 0, 0);

-- 938048 "Advisorybook": scraps 32738-40 -> Tattered Mechanoinstruction 33298
INSERT INTO `tradeskill_recipe`
  (`id`,`name`,`tradeskill`,`skillneeded`,`trivial`,`nofail`,`replace_container`,
   `quest`,`enabled`,`min_expansion`,`max_expansion`)
VALUES
  (938048, 'Tattered Mechanoinstruction', 58, 0, 15, 1, 0, 0, 1, -1, -1);

INSERT INTO `tradeskill_recipe_entries`
  (`recipe_id`,`item_id`,`successcount`,`failcount`,`componentcount`,`salvagecount`,`iscontainer`)
VALUES
  (938048, 32738, 0, 0, 1, 0, 0),
  (938048, 32739, 0, 0, 1, 0, 0),
  (938048, 32740, 0, 0, 1, 0, 0),
  (938048, 33298, 1, 0, 0, 0, 0);
