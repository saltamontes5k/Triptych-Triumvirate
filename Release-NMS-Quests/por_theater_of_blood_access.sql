-- Prophecy of Ro - Theater of Blood access chain task definitions
--   Task 3010  Skylance: The Library
--   Task 3011  Skylance: The Oubliette
--   Task 3012  Skylance: The Laboratory
--   Task 3013  Samples of Corruption
--   Task 3014  The Key to the Past
--   Task 3015  The Burning Prince
--   Task 3016  Message from the Past
--
-- Idempotent: replaces the seven tasks and their activities.
--
-- NOTE (Phase 2): the Skylance / instanced Takish-Hiz encounters and their
-- versioned spawns are not yet built. The kill/loot steps below are defined but
-- 3015/3016 currently rely on an Explore + SpeakWith until the instances land.
--
-- Local ids: Tarnished Chime 36144, Harmonic 84159, Silent 84160, Twisted 84161/84168,
--   Twisted Harmonic blank/final 84162/84163, Codex Artifice 36142, eggs 36143/36145,
--   tablets 36135-36139, Vial of Corrupted Blood 84156, Sealed Runed Silver Box 84158.
-- NPCs: Spirit of Ao 369083, Oathmir 372000, Tak`Valnakor 392045, Queen Tak`Yaliz 392088.

DELETE FROM `task_activities` WHERE `taskid` BETWEEN 3010 AND 3016;
DELETE FROM `tasks` WHERE `id` BETWEEN 3010 AND 3016;

INSERT INTO `tasks`
 (`id`,`type`,`duration`,`duration_code`,`title`,`description`,`reward_text`,`reward_id_list`,
  `cash_reward`,`exp_reward`,`reward_method`,`reward_points`,`reward_point_type`,
  `min_level`,`max_level`,`level_spread`,`min_players`,`max_players`,`repeatable`,
  `faction_reward`,`completion_emote`,`replay_timer_group`,`replay_timer_seconds`,
  `request_timer_group`,`request_timer_seconds`,`dz_template_id`,`lock_activity_id`,
  `faction_amount`,`enabled`)
VALUES
 (3010,2,0,0,'Skylance: The Library','Recover the Codex Artifice from the library of Skylance.','', '',0,0,0,0,0,70,0,0,0,0,1,0,'',0,0,0,0,0,0,0,1),
 (3011,2,0,0,'Skylance: The Oubliette','Descend into the oubliette of Skylance and recover the Prototype Egg of Tallongast.','', '',0,0,0,0,0,70,0,0,0,0,1,0,'',0,0,0,0,0,0,0,1),
 (3012,2,0,0,'Skylance: The Laboratory','Incubate the Prototype Egg and recover the chime of Ayonae Ro.','', '',0,0,0,0,0,70,0,0,0,0,1,0,'',0,0,0,0,0,0,0,1),
 (3013,2,0,0,'Samples of Corruption','Gather corrupted blood within Razorthorn and seal it for Oathmir the Outcast.','', '',0,0,0,0,0,70,0,0,0,0,1,0,'',0,0,0,0,0,0,0,1),
 (3014,2,0,0,'The Key to the Past','Recover the five fragments of the sandstone tablet from the Root of Ro.','', '',0,0,0,0,0,70,0,0,0,0,1,0,'',0,0,0,0,0,0,0,1),
 (3015,2,0,0,'The Burning Prince','Return to the past, put the five priests and the Burning Prince, Tak`Salir, to rest.','', '',0,0,0,0,0,70,0,0,0,0,1,0,'',0,0,0,0,0,0,0,1),
 (3016,2,0,0,'Message from the Past','Carry word of the betrayal to Queen Tak`Yaliz in the past.','', '',0,0,0,0,0,70,0,0,0,0,1,0,'',0,0,0,0,0,0,0,1);

INSERT INTO `task_activities`
 (`taskid`,`activityid`,`req_activity_id`,`step`,`activitytype`,`target_name`,`goalmethod`,`goalcount`,
  `description_override`,`npc_match_list`,`item_id_list`,`item_list`,`dz_switch_id`,
  `min_x`,`min_y`,`min_z`,`max_x`,`max_y`,`max_z`,`skill_list`,`spell_list`,`zones`,
  `zone_version`,`optional`,`list_group`)
VALUES
 -- 3010 Skylance: The Library
 (3010,0,-1,1,3,'',0,1,'Recover the Codex Artifice','','36142','',0, 0,0,0,0,0,0,'','','371',-1,0,0),
 (3010,1,-1,2,1,'Spirit of Ao the Fourth Born',0,1,'Return the Codex Artifice to Ao','369083','36142','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 -- 3011 Skylance: The Oubliette
 (3011,0,-1,1,3,'',0,1,'Recover the Prototype Egg of Tallongast','','36143','',0, 0,0,0,0,0,0,'','','371',-1,0,0),
 (3011,1,-1,2,1,'Spirit of Ao the Fourth Born',0,1,'Return the Prototype Egg to Ao','369083','36143','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 -- 3012 Skylance: The Laboratory
 (3012,0,-1,1,3,'',0,1,'Incubate and recover the egg','','36145','',0, 0,0,0,0,0,0,'','','371',-1,0,0),
 (3012,1,-1,2,3,'',0,1,'Recover the Tarnished Chime','','36144','',0, 0,0,0,0,0,0,'','','371',-1,0,0),
 -- 3013 Samples of Corruption
 (3013,0,-1,1,3,'',0,10,'Loot vials of Corrupted Blood within Razorthorn','','84156','',0, 0,0,0,0,0,0,'','','375',-1,0,0),
 (3013,1,-1,2,1,'Oathmir the Outcast',0,1,'Deliver the Sealed Runed Silver Box to Oathmir','372000','84158','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 -- 3014 The Key to the Past
 (3014,0,-1,1,3,'',0,1,'Recover a Sandstone Tablet Chunk','','36135','',0, 0,0,0,0,0,0,'','','377',-1,0,0),
 (3014,1,-1,2,3,'',0,1,'Recover a Piece of a Sandstone Tablet','','36136','',0, 0,0,0,0,0,0,'','','377',-1,0,0),
 (3014,2,-1,3,3,'',0,1,'Recover a Part of a Sandstone Tablet','','36137','',0, 0,0,0,0,0,0,'','','377',-1,0,0),
 (3014,3,-1,4,3,'',0,1,'Recover a Portion of a Sandstone Tablet','','36138','',0, 0,0,0,0,0,0,'','','377',-1,0,0),
 (3014,4,-1,5,3,'',0,1,'Recover a Broken Section of a SandStone Tablet','','36139','',0, 0,0,0,0,0,0,'','','377',-1,0,0),
 (3014,5,-1,6,1,'Tak`Valnakor',0,1,'Deliver a Sandstone Tablet Chunk','392045','36135','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3014,6,-1,7,1,'Tak`Valnakor',0,1,'Deliver a Piece of a Sandstone Tablet','392045','36136','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3014,7,-1,8,1,'Tak`Valnakor',0,1,'Deliver a Part of a Sandstone Tablet','392045','36137','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3014,8,-1,9,1,'Tak`Valnakor',0,1,'Deliver a Portion of a Sandstone Tablet','392045','36138','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 (3014,9,-1,10,1,'Tak`Valnakor',0,1,'Deliver a Broken Section of a SandStone Tablet','392045','36139','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 -- 3015 The Burning Prince (Phase 2 will add the priest/Prince kill steps)
 (3015,0,-1,1,5,'',0,1,'Enter the Ruins of Takish-Hiz','','','',0, 0,0,0,0,0,0,'','','377',-1,0,0),
 (3015,1,-1,2,4,'Queen Tak`Yaliz',0,1,'Speak with Queen Tak`Yaliz','392088','','',0, 0,0,0,0,0,0,'','','',-1,0,0),
 -- 3016 Message from the Past (Phase 2 will add the Scepter/Wand/Signet steps)
 (3016,0,-1,1,5,'',0,1,'Enter the Ruins of Takish-Hiz','','','',0, 0,0,0,0,0,0,'','','376',-1,0,0),
 (3016,1,-1,2,4,'Queen Tak`Yaliz',0,1,'Speak with Queen Tak`Yaliz','392088','','',0, 0,0,0,0,0,0,'','','',-1,0,0);
